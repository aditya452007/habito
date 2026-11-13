#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif

[Setup]
AppId={{EB1BEEEF-EC84-4267-A9E7-078FE4863579}
AppName=Habito
AppVersion={#AppVersion}
AppVerName=Habito {#AppVersion}
AppPublisher=Aaditya Thakur
AppPublisherURL=https://github.com/aditya452007/habito
AppSupportURL=https://github.com/aditya452007/habito/issues
AppUpdatesURL=https://github.com/aditya452007/habito/releases
DefaultDirName={autopf}\Habito
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir=..\build\installer
OutputBaseFilename=Habito-windows-x64-setup
SetupIconFile=runner\resources\app_icon.ico
UninstallDisplayIcon={app}\Habito.exe
UninstallDisplayName=Habito
WizardStyle=modern
Compression=lzma2
SolidCompression=yes
CloseApplications=yes
RestartApplications=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "dutch"; MessagesFile: "compiler:Languages\Dutch.isl"
Name: "korean"; MessagesFile: "compiler:Languages\Korean.isl"
Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"
Name: "ukrainian"; MessagesFile: "compiler:Languages\Ukrainian.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Habito"; Filename: "{app}\Habito.exe"; AppUserModelID: "com.habito.app"
Name: "{autodesktop}\Habito"; Filename: "{app}\Habito.exe"; Tasks: desktopicon; AppUserModelID: "com.habito.app"

[Registry]
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "Habito"; ValueData: """{app}\Habito.exe"" --background"; Flags: uninsdeletevalue

[Run]
Filename: "{app}\Habito.exe"; Description: "{cm:LaunchProgram,Habito}"; Flags: nowait postinstall skipifsilent
