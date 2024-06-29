unit App.Settings;

interface
uses
  App.Settings.Interfaces
  ;

type
  TAppSettings = class(TInterfacedObject, I_AppSettings)
  private
    fSplash: I_Splash;
    fEmbedFonts: I_EmbedFonts;
//    fDB: I_DB;
//    fTheme: I_Theme;
//    fLang: I_Lang;
//    fLicence: I_Licence;
  protected
    function Splash: I_Splash;
    function EmbedFonts: I_EmbedFonts;
//    function DB: I_DB;
//    function Theme: I_Theme;
//    function Lang: I_Lang;
//    function Licence: I_Licence;
    procedure Apply;
  public
    constructor Create;
    class function New: I_AppSettings;
  	destructor Destroy; override;
  end;

implementation

uses
  Vcl.Forms
, System.SysUtils
, System.Classes
, System.Threading
//
, App.Splash
, App.EmbedFonts
, API.Logger
//
, Controls.Hack
  ;

{ TAppSettings }

{$REGION '  [APP Assign Custom Exception] .. '}
constructor TAppSettings.Create;
begin
  fSplash     := TApp_Splash.New(Application, Self);
  fEmbedFonts := TApp_EmbedFonts.New(Self);
//  fDB         := TApp_DB.New(Self);
//  fTheme      := TAppTheme.New(Self);
//  fLang       := TAppLang.New(Self);
//  fLicence    := TAppLicence.New(Self);
end;

class function TAppSettings.New: I_AppSettings;
begin
  Result := Self.Create;
end;

destructor TAppSettings.Destroy;
begin
  inherited;
end;
{$ENDREGION}

function TAppSettings.Splash: I_Splash;
begin
  Result := fSplash;
end;

function TAppSettings.EmbedFonts: I_EmbedFonts;
begin
  Result := fEmbedFonts;
end;

procedure TAppSettings.Apply;
var
  L_Task: ITask;
begin
  App_Logger
    .Set_LogCtrl(TControl(fSplash.Log_Ctrl))
    .Set_ProgressCtrls(TControl(fSplash.Progress_Ctrl), TControl(fSplash.Progress_Bar));
  try
    L_Task := TTask.Create(procedure begin

      fEmbedFonts
        .Load_Extracted_EmbedFonts;

    end);
  finally
    L_Task.Start;
  end;

  while L_Task.Status <> TTaskStatus.Completed do
  begin
    Application.ProcessMessages;
    Sleep(100); // Prevent high CPU usage
  end;

  fSplash.&End(True);
end;

function Get_App_Logger: I_Logger; begin
  if not Assigned(App_Logger) then
    App_Logger := Get_Logger;

  Result := App_Logger;
end;

initialization
   Get_App_Logger;

end.
