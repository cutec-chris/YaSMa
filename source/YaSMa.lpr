program YaSMa;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, avamm_dblayer_sqlitedb, uMain, sqlitevirtualtables, sqlitefilesystemtable,
  usqleditor, sqliteeventtable, uYasMaClasses;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TfMain, fMain);
  Application.Run;
end.

