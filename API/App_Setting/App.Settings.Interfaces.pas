unit App.Settings.Interfaces;

interface

uses
  System.Types
, Vcl.Controls
, Vcl.ComCtrls
//
, API.Logger
  ;

type

  TProgressCallback = reference to procedure(FileName: string; Progress, Total: Integer);

  I_AppSettings = interface; // forward ..

  I_Splash = interface ['{8894E56E-117B-4123-894A-F5534036A02A}']

    function Log_Ctrl: TControl;
    function Progress_Ctrl: TControl;
    function Progress_Bar: TProgressBar;
    function Show_Splash: I_Splash;
    function UpdateUI: I_Splash;
    function &End(aWithClose: Boolean = False): I_AppSettings;
  end;

  I_EmbedFonts = interface ['{0D743FE1-A1A8-4C72-BB55-58DDA2EF4477}']

    function Load_Extracted_EmbedFonts: I_EmbedFonts;
    function &End: I_AppSettings;
  end;

  I_AppSettings = interface ['{22FC4AB3-A826-4659-ADA0-93D49BF2F024}']
    function Splash: I_Splash;
    function EmbedFonts: I_EmbedFonts;
//    function DB: I_DB;
//    function Theme: I_Theme;
//    function Lang: I_Lang;
//    function Licence: I_Licence;
    procedure Apply;
  end;

var
  App_Logger: I_Logger = nil;

implementation

end.
