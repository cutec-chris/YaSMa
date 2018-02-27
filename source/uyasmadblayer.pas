unit uYaSMadblayer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqlite3conn, sqldb, db;

type
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

  { TMDBLayerTransaction }

  TMDBLayerTransaction = class(TComponent)
  private
    FTransaction: TComponent;
  protected
    property Transaction : TComponent read FTransaction;
  public
  end;

  { TMDBLayerRecord }

  TMDBLayerRecord = class(TPersistent)
  private
    FDataSet: TDataSet;
    FFieldDefs: TMDBLFieldDefs;
    FTransaction: TMDBLayerTransaction;
    procedure SetTranscation(AValue: TMDBLayerTransaction);virtual;
  public
    property DataSet : TDataSet read FDataSet;
    property FieldDefs : TMDBLFieldDefs read FFieldDefs;
    property Transaction : TMDBLayerTransaction read FTransaction write SetTranscation;
  end;

  { TMinimalDBLayer }

  TMinimalDBLayer = class(TComponent)
  protected
    function GetActive: Boolean;virtual;abstract;
    procedure SetActive(AValue: Boolean);virtual;abstract;
  public
    property Active : Boolean read GetActive write SetActive;
    function GetRecord : TMDBLayerRecord;virtual;abstract;
    function GetTransaction : TMDBLayerTransaction;virtual;abstract;
  end;

  { TYaSMaDBRecord }

  { TYaSMaDBTransaction }

  TYaSMaDBTransaction = class(TMDBLayerTransaction)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  { TYaSMaDBRecord }

  TYaSMaDBRecord = class(TMDBLayerRecord)
  private
    procedure SetTranscation(AValue: TMDBLayerTransaction); override;
  public
    constructor Create(Connection : TComponent);
  end;

  { TYaSMaDBLayer }

  TYaSMaDBLayer = class(TMinimalDBLayer)
  private
    FSettingsFile: string;
    FMainConnection: TSQLite3Connection;
    procedure SetSettingsFile(AValue: string);
  protected
    function GetActive: Boolean;override;
    procedure SetActive(AValue: Boolean);override;
  public
    property MainConnection : TSQLite3Connection read FMainConnection;
    property SettingsFile : string read FSettingsFile write SetSettingsFile;
    constructor Create(AOwner: TComponent); override;
    function GetRecord: TMDBLayerRecord; override;
  end;

implementation

{ TYaSMaDBTransaction }

constructor TYaSMaDBTransaction.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTransaction := TSQLTransaction.Create(AOwner);
end;

{ TMDBLayerRecord }

procedure TMDBLayerRecord.SetTranscation(AValue: TMDBLayerTransaction);
begin
  if FTransaction=AValue then Exit;
  FTransaction:=AValue;
end;

{ TYaSMaDBRecord }

procedure TYaSMaDBRecord.SetTranscation(AValue: TMDBLayerTransaction);
begin
  inherited SetTranscation(AValue);
  TSQLQuery(FDataSet).Transaction := TSQLTransaction(AValue.Transaction);
end;

constructor TYaSMaDBRecord.Create(Connection: TComponent);
begin
  FDataSet := TSQLQuery.Create(Connection);
  TSQLQuery(FDataSet).DataBase:= TDatabase(Connection);
end;

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
  FMainConnection.DatabaseName:=AValue;
end;

function TYaSMaDBLayer.GetActive: Boolean;
begin
  Result := FMainConnection.Connected;
end;

procedure TYaSMaDBLayer.SetActive(AValue: Boolean);
begin
  if AValue then
    FMainConnection.Open
  else FMainConnection.Close;
end;

constructor TYaSMaDBLayer.Create(AOwner: TComponent);
begin
  FMainConnection := TSQLite3Connection.Create(Self);
  SettingsFile := ':memory:';
end;

function TYaSMaDBLayer.GetRecord: TMDBLayerRecord;
begin
  Result := TYaSMaDBRecord.Create(Self);
end;

end.

