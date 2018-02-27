unit usqleditor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, SynHighlighterSQL, Forms, Controls,
  Graphics, Dialogs, ComCtrls, DBGrids, DbCtrls, ActnList, ExtCtrls,
  uYaSMadblayer, db;

type

  { TfSQLEditor }

  TfSQLEditor = class(TForm)
    acExecute: TAction;
    ActionList1: TActionList;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    DBNavigator1: TDBNavigator;
    ImageList1: TImageList;
    mEdit: TSynEdit;
    pBottom: TPanel;
    StatusBar1: TStatusBar;
    SynSQLSyn1: TSynSQLSyn;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    procedure acExecuteExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FDBLyer: TMinimalDBLayer;
    Transaction: TMDBLayerTransaction;
    Query: TMDBLayerRecord;
    procedure SetDBLayer(AValue: TMinimalDBLayer);
    { private declarations }
  public
    { public declarations }
    property DBLayer : TMinimalDBLayer read FDBLyer write SetDBLayer;
  end;

implementation

{$R *.lfm}

{ TfSQLEditor }

procedure TfSQLEditor.FormCreate(Sender: TObject);
begin
end;

procedure TfSQLEditor.acExecuteExecute(Sender: TObject);
begin
  Query.SQL.Assign(mEdit.Lines);
  Query.Open;
end;

procedure TfSQLEditor.SetDBLayer(AValue: TMinimalDBLayer);
begin
  if FDBLyer=AValue then Exit;
  FDBLyer:=AValue;
  Query := DBLayer.GetRecord;
  Transaction := DBLayer.GetTransaction(Query.Connection);
  Query.Transaction := Transaction;
  DataSource1.DataSet := Query.DataSet;
end;

end.

