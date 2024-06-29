# [TAppSettings] TAppSettings Project Tool (developer helper tool)
 
 # Simplifyin developer life using Ready to use tool without coding ..
with this philosophy of handlling files you can adapt TAppSettings with: 
[database files|Embeded Fonts|Init Theme Config|Init Language Config|Licence Checking etc ..] 
  

![](20240629_142720.gif) 


 
Use :
  
```
begin
  APP.Initialize;
   
  APP
   .Settings
      .Splash
      .DB
      .EmbedFonts
      .Theme
      .Lang
      .Licence
      .Apply;
	  
  APP.MainFormOnTaskbar := True;   
  APP.CreateForm(TMainForm, MainForm);
  APP.Run;
end. 
```
