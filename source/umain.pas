unit uMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, ActnList, StdCtrls, uAbstractDBLayer, uYasMaClasses, db;

type
  { TRefreshTreeThread }

  TRefreshTreeThread = class(TThread)
  private
    Databases: TDataSet;
    Master: TDataSet;
  public
    procedure Execute; override;
    destructor Destroy; override;
    procedure RefreshDBList;
    procedure RefreshTables;
  end;

  { TfMain }

  TfMain = class(TForm)
    acNewTab: TAction;
    acConnect: TAction;
    acRefresh: TAction;
    ActionList1: TActionList;
    ImageList1: TImageList;
    lbLog: TListBox;
    pcPages: TPageControl;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    ToolButton2: TToolButton;
    tsNewTab: TTabSheet;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    tvMain: TTreeView;
    procedure acNewTabExecute(Sender: TObject);
    procedure acRefreshExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure pcPagesCloseTabClicked(Sender: TObject);
    procedure tsNewTabShow(Sender: TObject);
    procedure tvMainEditing(Sender: TObject; Node: TTreeNode;
      var AllowEdit: Boolean);
  private
    procedure DBLayerLog(Sender: TComponent; Log: string);
    { private declarations }
  public
    { public declarations }
    DBLayer : TAbstractDBModule;
    Connections : TConnectionSettings;
  end;

var
  fMain: TfMain;

const
  IMAGE_REFRESH                       = 2;
resourcestring
  strTables                           = 'Tabellen';

implementation

uses usqleditor,usqlite3virtualTable,uSqlite3EventTables,uSqlite3VTFilesystem;

{$R *.lfm}

{ TRfreshTreeThread }

procedure TRefreshTreeThread.Execute;
begin
  Databases := fMain.DBLayer.GetNewDataSet('PRAGMA database_list;');
  Databases.Open;
  Synchronize(@RefreshDBList);
  with Databases do
    begin
      First;
      while not EOF do
        begin
          Master := fMain.DBLayer.GetNewDataSet('select * from '+FieldByName('name').AsString+'.sqlite_master');
          Master.Open;
          Synchronize(@RefreshTables);
          Master.Free;
          Next;
        end;
    end;
end;

destructor TRefreshTreeThread.Destroy;
begin
  FreeAndNil(Databases);
  inherited Destroy;
end;

procedure TRefreshTreeThread.RefreshDBList;
var
  aNode, tmpNode: TTreeNode;
  i: Integer;
begin
  for i := 0 to fMain.tvMain.Items.Count-1 do
    fMain.tvMain.Items[i].Data:=@Self;
  with Databases do
    begin
      First;
      while not EOF do
        begin
          aNode := fMain.tvMain.Items.FindTopLvlNode(FieldByName('name').AsString);
          if not Assigned(aNode) then
            begin
              aNode := fMain.tvMain.Items.Add(nil,FieldByName('name').AsString);
              aNode.ImageIndex:=27;
              aNode.SelectedIndex:=aNode.ImageIndex;
            end;
          aNode.Data := nil;
          Next;
        end;
    end;
  aNode := fMain.tvMain.Items[0];
  while Assigned(aNode) do
    begin
      if aNode.Data=@Self then
        begin
          tmpNode := aNode;
          aNode := aNode.GetPrevSibling;
          tmpNode.Delete;
        end
      else
        aNode := aNode.GetNextSibling;
    end
end;

procedure TRefreshTreeThread.RefreshTables;
var
  aNode, bNode: TTreeNode;
  i: Integer;
begin
  aNode := fMain.tvMain.Items.FindTopLvlNode(Databases.FieldByName('name').AsString);
  if not Assigned(aNode) then exit;
  for i := 0 to aNode.Count-1 do
    aNode.Items[i].ImageIndex:=IMAGE_REFRESH;
  with Master do
    begin
      First;
      while not EOF do
        begin
          bNode := aNode.FindNode(Master.FieldByName('name').AsString);
          if (not Assigned(bNode))
          and (FieldByName('type').AsString = 'table')
          then
            bNode := fMain.tvMain.Items.AddChild(aNode,Master.FieldByName('name').AsString);
          if Assigned(bNode) then
            begin
              case FieldByName('type').AsString of
              'table':bNode.ImageIndex:=26;
              'trigger':bNode.ImageIndex:=28;
              'view':bNode.ImageIndex:=29;
              else
                bNode.ImageIndex:=-1;
              end;
              bNode.SelectedIndex:=bNode.ImageIndex;
            end;
          Next;
        end;
    end;
end;

{ TfMain }

procedure TfMain.FormCreate(Sender: TObject);
var
  Table: TSQLiteVirtualTable;
begin
  DBLayer := TAbstractDBModule.Create(Self);
  DBLayer.OnLog:=@DBLayerLog;
  DBLayer.SetProperties('sqlite-3;;:memory:;');
  Table := TEventTable.Create(DBLayer);
  DBLayer.ExecuteDirect('ATTACH '':memory:'' as system;',nil,False);
  Table.RegisterToSQLite(DBLayer.MainConnection.Handle);
  DBLayer.ExecuteDirect('CREATE VIRTUAL TABLE if not exists system.events USING event');
  Table := TFSTable.Create(DBLayer);
  Table.RegisterToSQLite(DBLayer.MainConnection.Handle);
  DBLayer.ExecuteDirect('CREATE VIRTUAL TABLE if not exists system.filesystem USING filesystem');
  Connections := TConnectionSettings.CreateEx(Self,DBLayer);
  Connections.Open;
  acRefresh.Execute;
end;

procedure TfMain.pcPagesCloseTabClicked(Sender: TObject);
begin
  (Sender as TTabSheet).Free;
end;

procedure TfMain.tsNewTabShow(Sender: TObject);
begin
  acNewTab.Execute;
end;

procedure TfMain.tvMainEditing(Sender: TObject; Node: TTreeNode;
  var AllowEdit: Boolean);
begin
  AllowEdit:=False;
end;

procedure TfMain.DBLayerLog(Sender: TComponent; Log: string);
begin
  lbLog.Items.Insert(0,Log);
  lbLog.ScrollBy(0,-100);
end;

procedure TfMain.acNewTabExecute(Sender: TObject);
var
  aTab: TTabSheet;
  aEditor: TfSQLEditor;
begin
  aTab := pcPages.AddTabSheet;
  aTab.Caption:='Abfrage';
  aTab.PageIndex:=aTab.PageIndex-1;
  aEditor := TfSQLEditor.Create(aTab);
  aEditor.DBLayer := DBLayer;
  aEditor.Parent := aTab;
  aEditor.Visible:=True;
  aEditor.Align:=alClient;
  pcPages.ActivePage := aTab;
end;

procedure TfMain.acRefreshExecute(Sender: TObject);
var
  aThread: TRefreshTreeThread;
begin
  aThread := TRefreshTreeThread.Create(False);
end;

end.

