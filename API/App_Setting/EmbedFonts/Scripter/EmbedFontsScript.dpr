program EmbedFontsScript;

{$APPTYPE CONSOLE}

// Do not run (JUST COMPILE or BUILD) ..!!

uses
  Winapi.Windows
, Winapi.ShellAPI
, System.Generics.Collections
, System.SysUtils
, System.Classes
, System.Zip
, System.IOUtils
  ;

procedure ZipFonts(const aFontFiles: TArray<string>; const Output_ZipFile: string);
var
  L_ZipFile: TZipFile;
  I: Integer;
begin
  L_ZipFile := TZipFile.Create;
  try
    L_ZipFile.Open(Output_ZipFile, zmWrite);
    for I := 0 to Length(aFontFiles) -1 do begin

      L_ZipFile.Add(aFontFiles[I], IntToStr(I + 1) + ExtractFileExt(aFontFiles[I]));
    end;
    L_ZipFile.Close;
  finally
    L_ZipFile.Free;
  end;
end;

procedure Create_ResourceScript(const aZipFont_ResourceName, aZipFilePath, aResource_ScriptPath: string);
var
  L_ResourceScript: TStringList;
begin
  L_ResourceScript := TStringList.Create;
  try
    L_ResourceScript.Add(aZipFont_ResourceName +' RCDATA "' + aZipFilePath + '"');
    L_ResourceScript.SaveToFile(aResource_ScriptPath);
  finally
    L_ResourceScript.Free;
  end;
end;

procedure Compile_ResourceScript(const aResource_ScriptPath: string);
var
  L_ResourceCompiler: string;
begin
  L_ResourceCompiler := 'brcc32.exe'; // Ensure brcc32.exe is in your system PATH
  ShellExecute(0, 'open', PChar(L_ResourceCompiler), PChar(aResource_ScriptPath), nil, SW_HIDE);
end;

procedure LogMessage(const Msg: string);
var
  LogFile: TextFile;
begin
  AssignFile(LogFile, 'ScriptLog.txt');
  if FileExists('ScriptLog.txt') then
    Append(LogFile)
  else
    Rewrite(LogFile);
  try
    Writeln(LogFile, Msg);
  finally
    CloseFile(LogFile);
  end;
end;

procedure Update_DPR_File(const aDPR_FilePathWithExt: string);
var
  L_DPRFile: TStringList;
//  L_DPR_FileNameWithExt,
  L_Resource_Directive: string;
  L_ProgramLine_Index, I: Integer;
begin
  L_Resource_Directive := '{$R Fonts.res}';

  if FileExists('ScriptLog.txt') then
    TFile.Delete('ScriptLog.txt');
//  L_DPR_FileNameWithExt := TPath.GetFileName(aDPR_FilePathWithExt);

  L_DPRFile := TStringList.Create;
  try
    if FileExists(aDPR_FilePathWithExt) then
    begin
      L_DPRFile.LoadFromFile(aDPR_FilePathWithExt);

      L_ProgramLine_Index := -1;
      for I := 0 to L_DPRFile.Count - 1 do
      begin
        if L_DPRFile[I].StartsWith('program ') and (L_DPRFile[I].Trim <> '') then
        begin
          L_ProgramLine_Index := I;
          Break;
        end;
      end;

      if L_ProgramLine_Index <> -1 then
      begin
        // Check if the resource directive already exists after the program line
        for I := L_ProgramLine_Index + 1 to L_DPRFile.Count - 1 do
        begin
          if L_DPRFile[I].Contains(L_Resource_Directive) then
            Exit; // Resource directive already exists, no need to add it again
        end;

        // Add the resource directive after the program line
        Inc(L_ProgramLine_Index);

        if (L_ProgramLine_Index < L_DPRFile.Count) and (L_DPRFile[L_ProgramLine_Index].Trim <> '') then begin
          L_DPRFile.Insert(L_ProgramLine_Index, '');
          L_DPRFile.Insert(L_ProgramLine_Index +1, '');
        end;

        L_DPRFile.Insert(L_ProgramLine_Index, L_Resource_Directive);
        L_DPRFile.SaveToFile(aDPR_FilePathWithExt);
      end
      else
        LogMessage('Program line not found in DPR file: ' + aDPR_FilePathWithExt);
    end
    else
      LogMessage('DPR file not found: ' + aDPR_FilePathWithExt);
  finally
    L_DPRFile.Free;
  end;
end;

procedure Embed_Fonts(const aFontsDir, aOutput_ZipFile, aZipFont_ResourceName, aResource_ScriptPath, aDPR_FilePath: string);
var
  L_FontFiles: TArray<string>;

  procedure Find_FontFiles(const aDir: string);
  var
    L_SearchRec: TSearchRec;
    L_FontPath : string;
  begin
    L_FontPath := IncludeTrailingPathDelimiter(aDir);

    if FindFirst(L_FontPath + '*.*', faAnyFile, L_SearchRec) = 0 then
    try
      repeat
        if (L_SearchRec.Attr and faDirectory <> 0) then
        begin
          if (L_SearchRec.Name <> '.') and (L_SearchRec.Name <> '..') then
            Find_FontFiles(L_FontPath + L_SearchRec.Name);
        end
        else if (ExtractFileExt(L_SearchRec.Name).ToLower = '.ttf') or
                (ExtractFileExt(L_SearchRec.Name).ToLower = '.otf') then
        begin
          L_FontFiles := L_FontFiles + [L_FontPath + L_SearchRec.Name];
        end;
      until FindNext(L_SearchRec) <> 0;
    finally
      FindClose(L_SearchRec);
    end;
  end;
begin
  SetLength(L_FontFiles, 0);
  Find_FontFiles(aFontsDir);

  if Length(L_FontFiles) = 0 then
  begin
    LogMessage('No font files found in the specified directory.');
    Exit;
  end;

  // Create the ZIP file
  ZipFonts(L_FontFiles, aOutput_ZipFile);

  // Create the resource script
  Create_ResourceScript(aZipFont_ResourceName, aOutput_ZipFile, aResource_ScriptPath);

  // Compile the resource script
  Compile_ResourceScript(aResource_ScriptPath);

  // Update the DPR file to include the resource directive
  Update_DPR_File(aDPR_FilePath);

  LogMessage('Fonts have been embedded successfully.');

end;

var
  L_FontsDir,
  L_Output_ZipFile,
  L_ZipFont_ResourceName,
  L_Resource_ScriptPath,
  L_DPR_FilePath: string;
begin
  try
    if ParamCount < 5 then
    begin
      WriteLn('Usage: EmbedFontsScript <FontsDir> <OutputZipFile> <ZipFontResourceName> <ResourceScriptPath> <DPRFilePath>');
      Exit;
    end;

    L_FontsDir            := ParamStr(1);
    L_Output_ZipFile      := ParamStr(2);
    L_ZipFont_ResourceName:= ParamStr(3);
    L_Resource_ScriptPath := ParamStr(4);
    L_DPR_FilePath        := ParamStr(5);

    Embed_Fonts(L_FontsDir, L_Output_ZipFile, L_ZipFont_ResourceName, L_Resource_ScriptPath, L_DPR_FilePath);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
