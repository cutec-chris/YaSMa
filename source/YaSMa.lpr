program YaSMa;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, uMain, sqlitevirtualtables, sqlitefilesystemtable,
  usqleditor, sqliteeventtable, uYasMaClasses, avamm_dblayer_sqldb
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TfMain, fMain);
  Application.Run;
end.

