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
    SynEdit1: TSynEdit;
    SynSQLSyn1: TSynSQLSyn;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    tsSQL: TTabSheet;
    tsResults: TTabSheet;
  private
    FDBLyer: TMinimalDBLayer;
    procedure SetDBLayer(AValue: TMinimalDBLayer);
    { private declarations }
  public
    { public declarations }
    property DBLayer : TMinimalDBLayer read FDBLyer write SetDBLayer;
  end;

implementation

{$R *.lfm}

{ TfSQLEditor }

procedure TfSQLEditor.SetDBLayer(AValue: TMinimalDBLayer);
begin
  if FDBLyer=AValue then Exit;
  FDBLyer:=AValue;
end;

end.

