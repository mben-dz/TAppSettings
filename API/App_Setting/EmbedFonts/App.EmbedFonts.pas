unit App.EmbedFonts;

interface

uses
  System.Types
, System.Classes
, System.Generics.Collections
//
, App.Settings.Interfaces
  ;

type

  TFonType = (ft_TTF, ft_OTF);

  TFontInfo = packed record
  strict private
    fFontType: TFonType;
    fFontName: string;
  private
  public
    class function Add(const aFontType: TFonType; const aFontName: string): TFontInfo; static;
    property FontType:TFonType read fFontType write fFontType;
    property FontName:string   read fFontName write fFontName;
  end;

  TApp_EmbedFonts = class(TInterfacedObject, I_EmbedFonts)
    procedure OnExtract_Progress(aFileName: string; aProgress, aTotal: Integer);
  private
    [weak]
    fParent: I_AppSettings;
    fFontResources: TDictionary<string, TFontInfo>;
    fFontDirPath,
    fFontZipPath: string;
    function Create_TempFontsFolder: Boolean;
    function GetWinApi_FontName(const aFontFileName: string): string;

    procedure Extract_EmbedFonts(const aResource_Stream: TResourceStream;
                                 const aOutput_FontsDir: string;
                                 aProgress_Callback: TProgressCallback);
    procedure Remove_FontsFromFolder;
  protected
    function Load_Extracted_EmbedFonts: I_EmbedFonts;
    function &End: I_AppSettings;
  public
    constructor Create(aParent: I_AppSettings); reintroduce; overload;
    destructor Destroy; override;
    class function New(aParent: I_AppSettings): I_EmbedFonts;
  end;

const
  TEMP_FONT_FOLDER          = 'Fonts';
  TEMP_FONT_FILE            = 'Fonts.zip';
  ZIPPED_FONT_RESOURCE_NAME = 'ZIPPEDFONTS';

implementation
uses
  Winapi.Windows
, System.SysUtils
, System.IOUtils
, System.Zip
, System.Threading
, Controls.Hack
;

const
  FR_PRIVATE = $10;
  GFRI_DESCRIPTION = 1;
  GFRI_LOGFONTS = 2;
  GFRI_NUMFACES = 3;

function GetFontResourceInfoW(lpszFilename: PWideChar; var cbBuffer: DWORD;
                              lpBuffer: Pointer; dwQueryType: DWORD): BOOL; stdcall;
                              external gdi32 name 'GetFontResourceInfoW';

{ TFontInfo }

class function TFontInfo.Add(const aFontType: TFonType;
  const aFontName: string): TFontInfo;
begin
  Result.fFontType := aFontType;
  Result.fFontName := aFontName;
end;

{ TApp_EmbedFonts }

function TApp_EmbedFonts.Create_TempFontsFolder: Boolean;
begin
  Result  := False;

  if not DirectoryExists(fFontDirPath) then
     if not CreateDir(fFontDirPath) then begin
       Result := ForceDirectories(fFontDirPath);
     end else Result := True;

end;

{$REGION '  [constructor||destructor] .. '}
constructor TApp_EmbedFonts.Create(aParent: I_AppSettings);
begin inherited Create;
  fParent        := aParent;
  fFontResources := TDictionary<string, TFontInfo>.Create;

{$IFDEF MSWINDOWS}
  fFontDirPath   := TPath.Combine(ExtractFilePath(ParamStr(0)), TEMP_FONT_FOLDER);
{$ELSE}
  fFontDirPath   := TPath.Combine(TPath.GetDocumentsPath, TEMP_FONT_FOLDER);
{$ENDIF}

  if Create_TempFontsFolder then
    App_Logger.Log('Create [Temoporary Fonts Folder] Successfully ..') else
    App_Logger.Log('Failled to Create [Temoporary Fonts Folder] !!');

  fFontZipPath := TPath.Combine(ExtractFilePath(ParamStr(0)), TEMP_FONT_FILE);
end;

class function TApp_EmbedFonts.New(aParent: I_AppSettings): I_EmbedFonts;
begin
  Result := Self.Create(aParent);
end;

destructor TApp_EmbedFonts.Destroy;
begin
  Remove_FontsFromFolder;
  fFontResources.Free;

  inherited;
end;
{$ENDREGION}

function TApp_EmbedFonts.GetWinApi_FontName(const aFontFileName: string): string;
var
  L_FontPath  : PChar;
  L_Buffer    : array[0..255] of Char;
  L_BufferSize: DWORD;
begin
  Result := '';

  L_FontPath := PChar(aFontFileName);

  try
    L_BufferSize := SizeOf(L_Buffer);
    if GetFontResourceInfoW(L_FontPath, L_BufferSize, @L_Buffer, GFRI_DESCRIPTION) then
    begin
      SetString(Result, L_Buffer, L_BufferSize div SizeOf(Char));
    end
    else begin
      App_Logger.Log('Failed to get font resource info');
      Exit('');
    end;
  finally
    App_Logger.Log('Font Name Extracted Successfully ..');
  end;

end;

procedure TApp_EmbedFonts.OnExtract_Progress(aFileName: string; aProgress,
  aTotal: Integer);
begin

  App_Logger.LogProgress(Format('Extracting %s (%d/%d)', [aFileName, aProgress, aTotal]),
                 TControl(fParent.Splash.Progress_Ctrl),
                 TControl(fParent.Splash.Progress_Bar), aProgress, aTotal);

  if aProgress = aTotal then begin
    with fParent.Splash do begin
//      UpdateUI;
      TControl(Progress_Ctrl).Visible := False;
      TControl(Progress_Bar).Visible  := False;
    end;

  end;

end;

procedure TApp_EmbedFonts.Extract_EmbedFonts(const aResource_Stream: TResourceStream;
                                             const aOutput_FontsDir: string;
                                             aProgress_Callback: TProgressCallback);
var
  L_ZipFile     : TZipFile;
  L_MemoryStream: TMemoryStream;
  L_Progress,
  L_Total       : Integer;
  L_ExtractTask : ITask;
begin
  // Create the output directory if it does not exist
  if not TDirectory.Exists(aOutput_FontsDir) then
    TDirectory.CreateDirectory(aOutput_FontsDir);

  App_Logger.Log('Trying to Extract Zip File Contents ..');

  L_MemoryStream := TMemoryStream.Create;
  try
    // Copy resource stream to memory stream
    L_MemoryStream.CopyFrom(aResource_Stream, aResource_Stream.Size);
    L_MemoryStream.Position := 0; // Reset stream position to the beginning

    L_ZipFile := TZipFile.Create;
    try
      L_ZipFile.Open(L_MemoryStream, zmRead);
      L_Total := L_ZipFile.FileCount;
      L_Progress := 0;

      L_ExtractTask := TTask.Create(procedure
      var
//        I: Integer;
        L_FileName: string;
      begin
        for L_FileName in L_ZipFile.FileNames do
        begin
          // Check if the file already exists and delete if necessary
          if TFile.Exists(TPath.Combine(aOutput_FontsDir, L_FileName)) then
            TFile.Delete(TPath.Combine(aOutput_FontsDir, L_FileName));

          // Extract the file to the output directory
          L_ZipFile.Extract(L_FileName, aOutput_FontsDir);
  //         App_Logger.Log('font ['+ L_FileName +'] Extracted Successfully ..');
           Inc(L_Progress);
          TThread.Synchronize(nil, procedure
          begin
            // Call the L_Progress callback
            if Assigned(aProgress_Callback) then
              aProgress_Callback(L_FileName, L_Progress, L_Total);
          end);

          Sleep(50);
        end;
      end);
      L_ExtractTask.Start;
      L_ExtractTask.Wait;

      L_ZipFile.Close;
    finally
      L_ZipFile.Free;
      App_Logger.Log('Zipped fonts Extracted Successfully ..');
    end;
  finally
    L_MemoryStream.Free;

  end;
end;

function Get_FontType(const aResourceName: string): TFonType;
begin
  if LowerCase(aResourceName).Contains('.ttf') then
    Result := ft_TTF else
    Result := ft_OTF;
end;

function TApp_EmbedFonts.Load_Extracted_EmbedFonts: I_EmbedFonts;
var
  L_SearchRec    : TSearchRec;
  L_FontFilePath : string;
  L_FontsPath    : string;
  L_FontCount    : Integer;
  L_FontFileNoExt: string;

  L_Resource_Stream: TResourceStream;
begin
  Result := Self;

  // Extract the ZIP file from the resource
  L_Resource_Stream := TResourceStream.Create(HInstance, ZIPPED_FONT_RESOURCE_NAME, RT_RCDATA);
  try
    // Extract fonts from the resource stream
    Extract_EmbedFonts(L_Resource_Stream, fFontDirPath, OnExtract_Progress);
  finally
    L_Resource_Stream.Free;
  end;

  L_FontsPath := IncludeTrailingPathDelimiter(fFontDirPath);

  if System.SysUtils.FindFirst(L_FontsPath + '*.*', faAnyFile, L_SearchRec) = 0 then
  begin
    repeat
      if (L_SearchRec.Attr and faDirectory = 0) and
         ((ExtractFileExt(L_SearchRec.Name).ToLower = '.ttf') or
         (ExtractFileExt(L_SearchRec.Name).ToLower = '.otf')) then
      begin
        L_FontFilePath  := L_FontsPath +L_SearchRec.Name;

        L_FontFileNoExt := TPath.GetFileNameWithoutExtension(L_SearchRec.Name);

      {$IFDEF MSWINDOWS}
         L_FontCount :=  AddFontResourceEx(PChar(L_FontFilePath), FR_PRIVATE, nil);
         if L_FontCount = 0 then begin
           App_Logger.Log('Failed to add font resource !!');
           Continue;
         end;
         App_Logger.Log(Format('Successfully Added: [ %s ] from resource..', [L_FontFileNoExt]));

         fFontResources.Add(L_FontFileNoExt, TFontInfo.Add(Get_FontType(L_SearchRec.Name), GetWinApi_FontName(L_FontFilePath)));
//         App_Logger.Log('Adding Font: [ ' + L_FontFileNoExt +' ] to the List Successfully ..', True, 50);
      {$ELSE}

      {$ENDIF}
      end;
    until FindNext(L_SearchRec) <> 0;
    System.SysUtils.FindClose(L_SearchRec);
  end;
end;

procedure TApp_EmbedFonts.Remove_FontsFromFolder;
var
  L_ResourceName,
  L_FontFile: string;
begin
  if not TDirectory.Exists(fFontDirPath) then Exit;

  for L_ResourceName in fFontResources.Keys do begin
    case fFontResources.Items[L_ResourceName].FontType of
      ft_TTF: L_FontFile := IncludeTrailingPathDelimiter(fFontDirPath) + L_ResourceName + '.ttf';
      ft_OTF: L_FontFile := IncludeTrailingPathDelimiter(fFontDirPath) + L_ResourceName + '.otf';
    end;
    if FileExists(L_FontFile) then
      if RemoveFontResourceEx(PChar(L_FontFile), FR_PRIVATE, nil) then begin
        TFile.Delete(L_FontFile);
      end;

  end;

  TDirectory.Delete(fFontDirPath, True);
end;

function TApp_EmbedFonts.&End: I_AppSettings;
begin
  Result := fParent;
end;

end.
