unit uMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, ActnList;

type

  { TfMain }

  TfMain = class(TForm)
    acNewTab: TAction;
    ActionList1: TActionList;
    pcPages: TPageControl;
    Splitter1: TSplitter;
    ToolBar1: TToolBar;
    TreeView1: TTreeView;
    procedure acNewTabExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);

private
    { private declarations }
  public
    { public declarations }
  end;

var
  fMain: TfMain;

implementation

uses usqleditor;

{$R *.lfm}

{ TfMain }

procedure TfMain.FormCreate(Sender: TObject);
begin
end;

procedure TfMain.FormShow(Sender: TObject);
begin
  //add an clean SQL Editor Tab
  acNewTab.Execute;
end;

procedure TfMain.acNewTabExecute(Sender: TObject);
var
  aTab: TTabSheet;
  aEditor: TfSQLEditor;
begin
  aTab := pcPages.AddTabSheet;
  aTab.Caption:='Abfrage';
  aEditor := TfSQLEditor.Create(aTab);
  aEditor.Parent := aTab;
  aEditor.Visible:=True;
  aEditor.Align:=alClient;
end;

end.

