unit uYaSMadblayer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqlite3conn, db;

type

  { TMinimalDBLayer }

  TMinimalDBLayer = class(TComponent)
  end;

  TMDBLayerRecord = class;

  { TMDBLFieldDef }

  TMDBLFieldDef = class(TFieldDef)
  private
    FDefault: Variant;
    procedure SetDefault(AValue: Variant);
  public
    property DefaultValue : Variant read FDefault write SetDefault;
  end;

  { TMDBLFieldDefs }

  TMDBLFieldDefs = class(TOwnedCollection)
  public
    constructor Create(ADataSet: TMDBLayerRecord);
  end;

  { TMDBLayerRecord }

  TMDBLayerRecord = class(TPersistent)
  private
    FDataSet: TDataSet;
    FFieldDefs: TMDBLFieldDefs;
  public
    property DataSet : TDataSet read FDataSet;
    property FieldDefs : TMDBLFieldDefs read FFieldDefs;
  end;

  { TYaSMaDBLayer }

  TYaSMaDBLayer = class(TMinimalDBLayer)
  private
    FSettingsFile: string;
    FMainConnection: TSQLite3Connection;
    procedure SetSettingsFile(AValue: string);
  public
    property SettingsFile : string read FSettingsFile write SetSettingsFile;
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{ TMDBLFieldDef }

procedure TMDBLFieldDef.SetDefault(AValue: Variant);
begin
  if FDefault=AValue then Exit;
  FDefault:=AValue;
end;

{ TMDBLFieldDefs }

constructor TMDBLFieldDefs.Create(ADataSet: TMDBLayerRecord);
begin
  Inherited Create(ADataSet,TMDBLFieldDef);
end;


procedure TYaSMaDBLayer.SetSettingsFile(AValue: string);
begin
  if FSettingsFile=AValue then Exit;
  FSettingsFile:=AValue;
end;

constructor TYaSMaDBLayer.Create(AOwner: TComponent);
begin
  SettingsFile := 'settings.db';
  FMainConnection := TSQLite3Connection.Create(Self);
end;

end.

