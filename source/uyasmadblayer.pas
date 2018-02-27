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
    function GetConnection: TComponent;virtual;abstract;
    procedure SetActive(AValue: Boolean);
    procedure SetConnection(AValue: TComponent);virtual;abstract;
    procedure SetTranscation(AValue: TMDBLayerTransaction);virtual;
    function GetActive: Boolean;virtual;abstract;
    function GetSQL: TStrings;virtual;abstract;
    function GetDataSource: TDataSource;virtual;abstract;
    procedure SetDataSource(AValue: TDataSource);virtual;abstract;
  public
    constructor Create(Connection : TComponent);virtual;
    property DataSet : TDataSet read FDataSet;
    property FieldDefs : TMDBLFieldDefs read FFieldDefs;
    property Transaction : TMDBLayerTransaction read FTransaction write SetTranscation;
    property SQL : TStrings read GetSQL;
    procedure Open;virtual;abstract;
    procedure Close;virtual;abstract;
    property Active : Boolean read GetActive write SetActive;
    procedure First;virtual;abstract;
    procedure Prior;virtual;abstract;
    procedure Next;virtual;abstract;
    procedure Last;virtual;abstract;
    function Locate(const KeyFields: string; const KeyValues: Variant; Options: TLocateOptions) : boolean; virtual;abstract;
    Property DataSource : TDataSource Read GetDataSource Write SetDataSource;
    property Connection : TComponent read GetConnection write SetConnection;
  end;

  TMDBConnectionSource = (csPool, //get an Connection from the Connection Pool that is not Buisy at the Moment
                          csAbstract); //get an Abstract Connection that is driven over SQLite to merge different Datasources

  { TMinimalDBLayer }

  TMinimalDBLayer = class(TComponent)
  protected
    function GetActive: Boolean;virtual;abstract;
    procedure SetActive(AValue: Boolean);virtual;abstract;
  public
    property Active : Boolean read GetActive write SetActive;
    function GetRecord(From : TMDBConnectionSource = csAbstract; aConnection: TComponent=
      nil) : TMDBLayerRecord;virtual;abstract;
    function GetTransaction(aConnection : TComponent) : TMDBLayerTransaction;virtual;abstract;
  end;

  { TYaSMaDBTransaction }

  TYaSMaDBTransaction = class(TMDBLayerTransaction)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  { TYaSMaDBRecord }

  TYaSMaDBRecord = class(TMDBLayerRecord)
  private
    procedure SetTranscation(AValue: TMDBLayerTransaction); override;
    function GetSQL: TStrings; override;
    function GetActive: Boolean; override;
    function GetDataSource: TDataSource; override;
    procedure SetDataSource(AValue: TDataSource); override;
    function GetConnection: TComponent; override;
    procedure SetConnection(AValue: TComponent); override;
  public
    constructor Create(aConnection : TComponent);override;
    procedure Open; override;
    procedure Close; override;
    procedure First; override;
    procedure Prior; override;
    procedure Next; override;
    procedure Last; override;
    function Locate(const KeyFields: string; const KeyValues: Variant;
                    Options: TLocateOptions): boolean; override;
  end;

  { TYaSMaDBLayer }

  TYaSMaDBLayer = class(TMinimalDBLayer)
  private
    FSettingsFile: string;
    FMainConnection: TSQLite3Connection;
    FMainTransaction : TSQLTransaction;
    procedure SetSettingsFile(AValue: string);
  protected
    function GetActive: Boolean;override;
    procedure SetActive(AValue: Boolean);override;
  public
    property MainConnection : TSQLite3Connection read FMainConnection;
    property SettingsFile : string read FSettingsFile write SetSettingsFile;
    constructor Create(AOwner: TComponent); override;
    function GetRecord(From: TMDBConnectionSource; aConnection: TComponent=
      nil): TMDBLayerRecord; override;
    function GetTransaction(aConnection : TComponent): TMDBLayerTransaction; override;
  end;

implementation

{ TYaSMaDBTransaction }

constructor TYaSMaDBTransaction.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTransaction := TSQLTransaction.Create(AOwner);
  TSQLTransaction(FTransaction).DataBase := TDatabase(AOwner);
end;

{ TMDBLayerRecord }

procedure TMDBLayerRecord.SetActive(AValue: Boolean);
begin
  if AValue then Open
  else Close;
end;

procedure TMDBLayerRecord.SetTranscation(AValue: TMDBLayerTransaction);
begin
  if FTransaction=AValue then Exit;
  FTransaction:=AValue;
end;

constructor TMDBLayerRecord.Create(Connection: TComponent);
begin
end;

{ TYaSMaDBRecord }

procedure TYaSMaDBRecord.SetTranscation(AValue: TMDBLayerTransaction);
begin
  inherited SetTranscation(AValue);
  TSQLQuery(FDataSet).Transaction := TSQLTransaction(AValue.Transaction);
end;

function TYaSMaDBRecord.GetSQL: TStrings;
begin
  Result := TSQLQuery(FDataSet).SQL;
end;

function TYaSMaDBRecord.GetActive: Boolean;
begin
  Result := TSQLQuery(FDataSet).Active;
end;

function TYaSMaDBRecord.GetDataSource: TDataSource;
begin
  Result := TSQLQuery(FDataSet).DataSource;
end;

procedure TYaSMaDBRecord.SetDataSource(AValue: TDataSource);
begin
  TSQLQuery(FDataSet).DataSource := AValue;
end;

function TYaSMaDBRecord.GetConnection: TComponent;
begin
  Result := TSQLQuery(FDataSet).DataBase;
end;

procedure TYaSMaDBRecord.SetConnection(AValue: TComponent);
begin
  TSQLQuery(FDataSet).DataBase := TDataBase(AValue);
end;

constructor TYaSMaDBRecord.Create(aConnection: TComponent);
begin
  inherited;
  FDataSet := TSQLQuery.Create(aConnection);
  TSQLQuery(FDataSet).DataBase:= TDatabase(aConnection);
end;

procedure TYaSMaDBRecord.Open;
begin
  TSQLQuery(FDataSet).Open;
end;

procedure TYaSMaDBRecord.Close;
begin
  TSQLQuery(FDataSet).Close;
end;

procedure TYaSMaDBRecord.First;
begin
  TSQLQuery(FDataSet).First;
end;

procedure TYaSMaDBRecord.Prior;
begin
  TSQLQuery(FDataSet).Prior;
end;

procedure TYaSMaDBRecord.Next;
begin
  TSQLQuery(FDataSet).Next;
end;

procedure TYaSMaDBRecord.Last;
begin
  TSQLQuery(FDataSet).Last;
end;

function TYaSMaDBRecord.Locate(const KeyFields: string;
  const KeyValues: Variant; Options: TLocateOptions): boolean;
begin
  Result := TSQLQuery(FDataSet).Locate(KeyFields,KeyValues,Options);
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
  FMainTransaction := TSQLTransaction.Create(Self);
  FMainConnection.Transaction := FMainTransaction;
  SettingsFile := ':memory:';
end;

function TYaSMaDBLayer.GetRecord(From: TMDBConnectionSource;aConnection : TComponent = nil): TMDBLayerRecord;
begin
  if aConnection=nil then
    begin
      if From = csAbstract then
        Result := TYaSMaDBRecord.Create(MainConnection)
      else raise Exception.Create('not implemented !');
    end
  else
    Result := TYaSMaDBRecord.Create(aConnection);
  TSQLQuery(TYaSMaDBRecord(Result).DataSet).Transaction := TSQLTransaction(FMainTransaction);
end;

function TYaSMaDBLayer.GetTransaction(aConnection: TComponent
  ): TMDBLayerTransaction;
begin
  Result := TYaSMaDBTransaction.Create(aConnection);
end;

end.

