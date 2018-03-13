unit uYasMaClasses;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uAbstractDBLayer, uBaseDatasetInterfaces, db;

type

  { TConnectionSettings }

  TConnectionSettings = class(TAbstractDBDataset)
  public
    procedure DefineFields(aDataSet: TDataSet); override;
  end;

implementation

{ TConnectionSettings }

procedure TConnectionSettings.DefineFields(aDataSet: TDataSet);
begin
  inherited DefineFields(aDataSet);
  with aDataSet as IBaseManageDB do
    begin
      TableName := 'CONNECTIONS';
      with ManagedFieldDefs do
        begin
          Add('NAME',ftString,60,True);
          Add('PROPERTYS',ftString,200,True);
        end;
    end;
end;

end.

