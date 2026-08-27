[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{E61A0DF4-8B8B-4C59-AE0F-4DF2328BB55F}
AppName=Aadhiguru
AppVersion=1.0.3
AppPublisher=Aadhiguru
AppPublisherURL=https://www.aadhiguru.com/
AppSupportURL=https://www.aadhiguru.com/
AppUpdatesURL=https://www.aadhiguru.com/
DefaultDirName={autopf}\Aadhiguru
DisableProgramGroupPage=yes
; Uncomment the following line to run in non administrative install mode (install for current user only.)
;PrivilegesRequired=lowest
OutputDir=Output
OutputBaseFilename=Aadhiguru_Windows_v1.0.3_Setup
SetupIconFile=windows\runner\resources\app_icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "build\windows\x64\runner\Release\astrology_flutter.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\Aadhiguru"; Filename: "{app}\astrology_flutter.exe"
Name: "{autodesktop}\Aadhiguru"; Filename: "{app}\astrology_flutter.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\astrology_flutter.exe"; Description: "{cm:LaunchProgram,Aadhiguru}"; Flags: nowait postinstall skipifsilent
