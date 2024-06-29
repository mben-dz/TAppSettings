unit API.Logger;

interface
uses
  Controls.Hack
  ;

type
//  TControl = class(Vcl.Controls.TControl); // To Access Protected Control Text Property..


  I_Logger = interface ['{57803DB1-A6DD-4ADF-BA89-D1C17CF6E18D}']
    function Set_LogCtrl(aLogCtrl: TControl): I_Logger;
    function Log(const aLog: string; aUseSleep_After: Boolean = True; aSleep: Byte = 100): I_Logger;

    function Set_ProgressCtrls(aProgressCtrl, aProgressBar: TControl): I_Logger;
    function LogProgress(const ProgressMsg: string;
                              aProgressCtrl: TControl;
                              aProgressBar: TControl;
                              aProgress, aTotal: Cardinal): I_Logger;
  end;



 function Get_Logger: I_Logger;

implementation

uses
  System.SysUtils
, Vcl.ComCtrls
  ;

type
  TLogger = class(TInterfacedObject, I_Logger)
  private
    fLogCtrl,
    fProgressCtrl,
    fProgressBar: TControl;
  protected
    function Set_LogCtrl(aLogCtrl: TControl): I_Logger;
    function Log(const aLog: string; aUseSleep_After: Boolean = True; aSleep: Byte = 100): I_Logger;

    function Set_ProgressCtrls(aProgressCtrl, aProgressBar: TControl): I_Logger;
    function LogProgress(const ProgressMsg: string;
                              aProgressCtrl: TControl;
                              aProgressBar: TControl;
                              aProgress, aTotal: Cardinal): I_Logger;
  public
    constructor Create;
    destructor Destroy; override;
  end;

{ TLog }

{$REGION '  [constructor||destructor] .. '}
constructor TLogger.Create;
begin
  fLogCtrl      := nil;
  fProgressCtrl := nil;
  fProgressBar  := nil;
end;

destructor TLogger.Destroy;
begin
  inherited Destroy;
end;
{$ENDREGION}

function TLogger.Set_LogCtrl(aLogCtrl: TControl): I_Logger;
begin
  Result := Self;

  fLogCtrl := aLogCtrl;
end;

function TLogger.Set_ProgressCtrls(aProgressCtrl,
  aProgressBar: TControl): I_Logger;
begin
  Result := Self;

  fProgressCtrl := aProgressCtrl;
  fProgressBar  := aProgressBar;
end;

function TLogger.Log(const aLog: string; aUseSleep_After: Boolean; aSleep: Byte): I_Logger;
begin
  Result := Self;

  if Assigned(fLogCtrl) then
    fLogCtrl.LText := aLog;

  if aUseSleep_After then
    Sleep(aSleep);

end;

function TLogger.LogProgress(const ProgressMsg: string;
                                  aProgressCtrl: TControl;
                                  aProgressBar: TControl;
                                  aProgress, aTotal: Cardinal): I_Logger;
var
  L_Percent_Complete: Cardinal;
begin
  Result := Self;

  if aTotal > 0 then
    L_Percent_Complete := (aProgress * 100) div aTotal
  else
    L_Percent_Complete := 0;

  if Assigned(fProgressCtrl) then begin
    fProgressCtrl.Visible := True;
    fProgressCtrl.LText := ProgressMsg;
  end;

  if Assigned(fProgressBar) then begin
    fProgressBar.Visible := True;
    TProgressBar(fProgressBar).Position := L_Percent_Complete;
  end;
end;

function Get_Logger: I_Logger; begin
  Result := TLogger.Create;
end;


end.
