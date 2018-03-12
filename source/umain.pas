unit uMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, ActnList, StdCtrls, uAbstractDBLayer, uYasMaClasses;

type

  { TfMain }

  TfMain = class(TForm)
    acNewTab: TAction;
    acConnect: TAction;
    ActionList1: TActionList;
    ImageList1: TImageList;
    lbLog: TListBox;
    pcPages: TPageControl;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    TreeView1: TTreeView;
    procedure acNewTabExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
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

implementation

uses usqleditor,usqlite3virtualTable,uSqlite3EventTables,uSqlite3VTFilesystem;

{$R *.lfm}

{ TfMain }

procedure TfMain.FormCreate(Sender: TObject);
var
  Table: TSQLiteVirtualTable;
begin
  DBLayer := TAbstractDBModule.Create(Self);
  DBLayer.OnLog:=@DBLayerLog;
  DBLayer.SetProperties('sqlite-3;;memory:;');
  Table := TEventTable.Create(DBLayer);
  Table.RegisterToSQLite(DBLayer.MainConnection.Handle);
  DBLayer.ExecuteDirect('CREATE VIRTUAL TABLE temp.internal_event USING event');
  Table := TFSTable.Create(DBLayer);
  Table.RegisterToSQLite(DBLayer.MainConnection.Handle);
  DBLayer.ExecuteDirect('CREATE VIRTUAL TABLE temp.internal_filesystem USING filesystem');
  Connections := TConnectionSettings.CreateEx(Self,DBLayer);
  Connections.Open;
end;

procedure TfMain.FormShow(Sender: TObject);
begin
  //add an clean SQL Editor Tab
  acNewTab.Execute;
end;

procedure TfMain.DBLayerLog(Sender: TComponent; Log: string);
begin
  lbLog.Items.Add(Log);
end;

procedure TfMain.acNewTabExecute(Sender: TObject);
var
  aTab: TTabSheet;
  aEditor: TfSQLEditor;
begin
  aTab := pcPages.AddTabSheet;
  aTab.Caption:='Abfrage';
  aEditor := TfSQLEditor.Create(aTab);
  aEditor.DBLayer := DBLayer;
  aEditor.Parent := aTab;
  aEditor.Visible:=True;
  aEditor.Align:=alClient;
end;

end.

