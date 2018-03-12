unit usqleditor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, SynHighlighterSQL, Forms, Controls,
  Graphics, Dialogs, ComCtrls, DBGrids, DbCtrls, ActnList, ExtCtrls,
  uAbstractDBLayer, db, Grids;

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
    Splitter1: TSplitter;
    StatusBar1: TStatusBar;
    SynSQLSyn1: TSynSQLSyn;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    procedure acExecuteExecute(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure FormCreate(Sender: TObject);
  private
    FDBLyer: TAbstractDBModule;
    Query: TAbstractDBQuery;
    procedure SetDBLayer(AValue: TAbstractDBModule);
    { private declarations }
  public
    { public declarations }
    property DBLayer : TAbstractDBModule read FDBLyer write SetDBLayer;
  end;

implementation

{$R *.lfm}

{ TfSQLEditor }

procedure TfSQLEditor.FormCreate(Sender: TObject);
begin
end;

procedure TfSQLEditor.acExecuteExecute(Sender: TObject);
var
  aSQL: TStringList;
begin
  Query.Close;
  aSQL := TStringList.Create;
  aSQL.Assign(mEdit.Lines);
  aSQL.Text := StringReplace(aSQL.Text,'Internal.','internal_',[rfReplaceAll,rfIgnoreCase]);
  Query.SQL := aSQL.Text;
  aSQL.Free;
  Query.Open;
end;

procedure TfSQLEditor.DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  Bmp: TBitmap;
  OutRect: TRect;
begin
  if not Column.Field.IsBlob then
    exit
  else
  begin
    with DBGrid1 do
      begin
        // clear area
        Canvas.FillRect (Rect);
        // copy the rectangle
        OutRect := Rect;
        // output field data
        if Column.Field is TGraphicField then
        begin
          Bmp := TBitmap.Create;
          try
            Bmp.Assign (Column.Field);
            Canvas.StretchDraw (OutRect, Bmp);
          finally
            Bmp.Free;
          end;
        end
        else if Column.Field is TMemoField then
        begin
          Canvas.TextOut(Outrect.Left,OutRect.Top,copy(Column.Field.AsString,0,100));
        end
        else // draw single line vertically centered
          Canvas.TextOut(Outrect.Left,OutRect.Top,copy(Column.Field.AsString,0,100));
      end;
  end;
end;

procedure TfSQLEditor.SetDBLayer(AValue: TAbstractDBModule);
begin
  if FDBLyer=AValue then Exit;
  FDBLyer:=AValue;
  Query := TAbstractDBQuery(DBLayer.GetNewDataSet(''));
  DataSource1.DataSet := Query;
end;

end.

