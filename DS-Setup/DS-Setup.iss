; Setup for DSBD Files
; /TR 2017-02-04

[Setup]
AppName=DSBD
AppComments=DS-Layout, DS-Schedule
AppVersion=1.0
AppPublisher=Tino Reichardt
AppContact=Tino Reichardt
AppPublisherURL=https://open-digital-signage.org/
AppCopyright=Copyright (C) 2016 - 2017 Tino Reichardt
DefaultDirName={pf}\DSBD
DefaultGroupName=Open Digital Signage
Compression=lzma2/max
SolidCompression=yes
ChangesAssociations = yes
ArchitecturesInstallIn64BitMode=x64
OutputDir=.
OutputBaseFilename=DS-Setup
SetupIconFile="DS-Setup.ico"
UninstallDisplayIcon="{app}\DS-Layout.exe,2"

; name=dssigntool
SignTool=dssigntool
SignedUninstaller=yes

; does show only 1,2MB without it, so I guess only the uninstaller is counted ?!
; we have two prog, each about an MiB ... so then:
#define SpaceNeeded 1048576*2
ExtraDiskSpaceRequired={#SpaceNeeded}

[Files]
; Place all x64 files here
Source: "DS-Layout\DS-Layout_x64.exe"; DestDir: "{app}"; DestName: "DS-Layout.exe"; Check: Is64BitInstallMode; Flags: signonce ignoreversion
Source: "DS-Schedule\DS-Schedule_x64.exe"; DestDir: "{app}"; DestName: "DS-Schedule.exe"; Check: Is64BitInstallMode; Flags: signonce ignoreversion
; Place all x86 files here, first one should be marked 'solidbreak'
Source: "DS-Layout\DS-Layout.exe"; DestDir: "{app}"; Check: not Is64BitInstallMode; Flags: solidbreak signonce ignoreversion
Source: "DS-Schedule\DS-Schedule.exe"; DestDir: "{app}"; Check: not Is64BitInstallMode; Flags: solidbreak signonce ignoreversion
; Place all common files here, first one should be marked 'solidbreak'

[Tasks]
Name: "assoc_dsbd"; Description: "{cm:AssocFileExtension,DS-Layout,.dsbd}"
Name: "assoc_dsbs"; Description: "{cm:AssocFileExtension,DS-Schedule,.dsbs}"
Name: "desktop_dsbd"; Description: "DS-Layout {cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "desktop_dsbs"; Description: "DS-Schedule {cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Registry]
Root: HKCR; Subkey: ".dsbd";                           ValueType: string; ValueName: ""; Tasks: assoc_dsbd; ValueData: "DS-Layout";   Flags: uninsdeletevalue;
Root: HKCR; Subkey: "DS-Layout";                       ValueType: string; ValueName: ""; Tasks: assoc_dsbd; ValueData: "Program DS-Layout";   Flags: uninsdeletekey;
Root: HKCR; Subkey: "DS-Layout\DefaultIcon";           ValueType: string; ValueName: ""; Tasks: assoc_dsbd; ValueData: "{app}\DS-Layout.exe,0";
Root: HKCR; Subkey: "DS-Layout\shell\open\command";    ValueType: string; ValueName: ""; Tasks: assoc_dsbd; ValueData: """{app}\DS-Layout.exe"" ""%1""";
Root: HKCR; Subkey: ".dsbs";                           ValueType: string; ValueName: ""; Tasks: assoc_dsbs; ValueData: "DS-Schedule"; Flags: uninsdeletevalue;
Root: HKCR; Subkey: "DS-Schedule";                     ValueType: string; ValueName: ""; Tasks: assoc_dsbs; ValueData: "Program DS-Schedule"; Flags: uninsdeletekey;
Root: HKCR; Subkey: "DS-Schedule\DefaultIcon";         ValueType: string; ValueName: ""; Tasks: assoc_dsbs; ValueData: "{app}\DS-Schedule.exe,0";
Root: HKCR; Subkey: "DS-Schedule\shell\open\command";  ValueType: string; ValueName: ""; Tasks: assoc_dsbs; ValueData: """{app}\DS-Schedule.exe"" ""%1""";

[Languages]
Name: en; MessagesFile: "compiler:Default.isl"
Name: de; MessagesFile: "compiler:Languages\German.isl"

[Messages]
en.BeveledLabel=English
de.BeveledLabel=Deutsch

[Icons]
Name: "{group}\DS-Layout"; Filename: "{app}\DS-Layout.exe"
Name: "{group}\DS-Schedule"; Filename: "{app}\DS-Schedule.exe"
Name: "{group}\{cm:UninstallProgram,DSBD}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\DS-Layout"; Filename: "{app}\DS-Layout"; Tasks: desktop_dsbd
Name: "{commondesktop}\DS-Schedule"; Filename: "{app}\DS-Schedule"; Tasks: desktop_dsbs
