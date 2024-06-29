program AppSettings;
{$R Fonts.res}


uses
  Vcl.Forms,
  Controls.Hack in 'API\Controls.Hack.pas',
  API.Logger in 'API\API_Logger\API.Logger.pas',
  App.Settings.Interfaces in 'API\App_Setting\App.Settings.Interfaces.pas',
  App.Splash in 'API\App_Setting\Splash\App.Splash.pas' {App_Splash},
  App.EmbedFonts in 'API\App_Setting\EmbedFonts\App.EmbedFonts.pas',
  App.Settings in 'API\App_Setting\Logic\App.Settings.pas',
  App.Helper in 'API\App_Helper\App.Helper.pas',
  Main.View in 'Main.View.pas' {MainView};

{$R *.res}

var
  MainView: TMainView;
begin
  MyApp.Initialize;

  MyApp.Settings
    .Splash
      .Show_Splash
      .&End
    .EmbedFonts
      .&End
    .Apply;

  MyApp.MainFormOnTaskbar := True;
  MyApp.CreateForm(TMainView, MainView);
  MyApp.Run;
end.
