unit usqleditor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, SynHighlighterSQL, Forms, Controls,
  Graphics, Dialogs, ComCtrls, DBGrids, DbCtrls, ActnList, uYaSMadblayer;

type

  { TfSQLEditor }

  TfSQLEditor = class(TForm)
    acExecute: TAction;
    ActionList1: TActionList;
    DBGrid1: TDBGrid;
    DBNavigator1: TDBNavigator;
    pcPages: TPageControl;
    StatusBar1: TStatusBar;
    mEdit: TSynEdit;
    SynSQLSyn1: TSynSQLSyn;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    tsSQL: TTabSheet;
    tsResults: TTabSheet;
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

procedure TfSQLEditor.SetDBLayer(AValue: TMinimalDBLayer);
begin
  if FDBLyer=AValue then Exit;
  FDBLyer:=AValue;
  Transaction := DBLayer.GetTransaction;
  Query := DBLayer.GetRecord;
  Query.Transaction := Transaction;
end;

end.

