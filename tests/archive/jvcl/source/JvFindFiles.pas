{-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JvFindFiles.PAS, released on 2002-05-26.

The Initial Developer of the Original Code is Peter Th�rnqvist [peter3@peter3.com]
Portions created by Peter Th�rnqvist are Copyright (C) 2002 Peter Th�rnqvist.
All Rights Reserved.

Contributor(s):            

Last Modified: 2002-05-26

You may retrieve the latest version of this file at the Project JEDI's JVCL home page,
located at http://jvcl.sourceforge.net

Known Issues:
-----------------------------------------------------------------------------}

{$I JVCL.INC}

{A function and a component to wrap access to the FindFiles Dialog
(accessible from the Explorer by hitting F3) }

unit JvFindFiles;

interface

uses
  SysUtils, Classes, ShlObj, ShellAPI, ActiveX, Dialogs,
  JvBaseDlg;

type
  TJvSpecialFolder =
    (sfRecycleBin, sfControlPanel, sfDesktop, sfDesktopDirectory,
     sfMyComputer, sfFonts, sfNetHood, sfNetwork, sfPersonal, sfPrinters,
     sfPrograms, sfRecent, sfSendTo, sfStartMenu, stStartUp, sfTemplates);

  TJvFindFilesDialog = class(TJvCommonDialog)
  private
    FUse: Boolean;
    FDir: string;
    FSpecial: TJvSpecialFolder;
  public
    function Execute: Boolean; override;
  published
    // the directory to start the search in
    property Directory: string read FDir write FDir;
    // ... or a special folder to start in
    property SpecialFolder: TJvSpecialFolder read FSpecial write FSpecial;
    // set to True to sue SpecialFolder instead of Directory
    property UseSpecialFolder: Boolean read FUse write FUse;
  end;

function FindFilesDlg(StartIn: string; SpecialFolder: TJvSpecialFolder; UseFolder: Boolean): Boolean;

implementation

const
  FFolder: array [TJvSpecialFolder] of Integer =
    (CSIDL_BITBUCKET, CSIDL_CONTROLS, CSIDL_DESKTOP, CSIDL_DESKTOPDIRECTORY,
     CSIDL_DRIVES, CSIDL_FONTS, CSIDL_NETHOOD, CSIDL_NETWORK, CSIDL_PERSONAL,
     CSIDL_PRINTERS, CSIDL_PROGRAMS, CSIDL_RECENT, CSIDL_SENDTO, CSIDL_STARTMENU,
     CSIDL_STARTUP, CSIDL_TEMPLATES);

function TJvFindFilesDialog.Execute: Boolean;
begin
  Result := FindFilesDlg(FDir, FSpecial, FUse);
end;

function FindFilesDlg(StartIn: string; SpecialFolder: TJvSpecialFolder; UseFolder: Boolean): Boolean;
var
  Pidl: PITEMIDLIST;
  PMalloc: IMalloc;
  Sei: TShellExecuteInfo;
begin
  try
    SHGetMalloc(PMalloc);
    FillChar(Sei, SizeOf(TShellExecuteInfo), 0);
    Sei.lpVerb := 'find';
    Sei.cbSize := SizeOf(Sei);
    if UseFolder then
    begin
      SHGetSpecialFolderLocation(0, FFolder[SpecialFolder], Pidl);
      with Sei do
      begin
        fMask := SEE_MASK_INVOKEIDLIST;
        lpIDList := Pidl;
      end;
    end
    else
      Sei.lpFile := PChar(StartIn);
    Result := ShellExecuteEx(@Sei);
  finally
    pMalloc._Release;
    pMalloc := nil;
  end;
end;

end.

