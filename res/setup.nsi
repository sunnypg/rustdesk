﻿Unicode true

####################################################################
# Includes

!include nsDialogs.nsh
!include MUI2.nsh
!include x64.nsh
!include LogicLib.nsh

####################################################################
# File Info

!define PRODUCT_NAME "社牛Desk"
!define PRODUCT_DESCRIPTION "Installer for ${PRODUCT_NAME}"
!define COPYRIGHT "Copyright © 2024"
!define VERSION "1.0.0"

VIProductVersion "${VERSION}.0"
VIAddVersionKey "ProductName" "${PRODUCT_NAME}"
VIAddVersionKey "ProductVersion" "${VERSION}"
VIAddVersionKey "FileDescription" "${PRODUCT_DESCRIPTION}"
VIAddVersionKey "LegalCopyright" "${COPYRIGHT}"
VIAddVersionKey "FileVersion" "${VERSION}.0"

####################################################################
# Installer Attributes

Name "${PRODUCT_NAME}"
Outfile "社牛Desk-${VERSION}-setup.exe"
Caption "Setup - ${PRODUCT_NAME}"
BrandingText "${PRODUCT_NAME}"

ShowInstDetails show
RequestExecutionLevel admin
SetOverwrite on
 
InstallDir "$PROGRAMFILES64\${PRODUCT_NAME}"

####################################################################
# Pages

!define MUI_ICON "icon.ico"
!define MUI_ABORTWARNING
!define MUI_LANGDLL_ALLLANGUAGES
!define MUI_FINISHPAGE_RUN "$INSTDIR\${PRODUCT_NAME}.exe"

!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

####################################################################
# Language

!insertmacro MUI_LANGUAGE "SimpChinese"


####################################################################
# Sections

Section "Install"
  SetOutPath $INSTDIR

  # Regkeys
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "DisplayIcon" "$INSTDIR\${PRODUCT_NAME}.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "DisplayName" "${PRODUCT_NAME} (x64)"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "DisplayVersion" "${VERSION}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "UninstallString" '"$INSTDIR\${PRODUCT_NAME}.exe" --uninstall'
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "Publisher" "SheNiu."

  nsExec::Exec "taskkill /F /IM ${PRODUCT_NAME}.exe"
  Sleep 500 ; Give time for process to be completely killed
  #File "${PRODUCT_NAME}.exe"
  File "C:\Users\Administrator\Desktop\workspace\rustdesk\target\release\社牛Desk.exe"
  File "C:\Users\Administrator\Desktop\workspace\rustdesk\target\release\sciter.dll"

  SetShellVarContext all
  CreateShortCut "$INSTDIR\Uninstall ${PRODUCT_NAME}.lnk" "$INSTDIR\${PRODUCT_NAME}.exe" "--uninstall" "msiexec.exe"
  CreateDirectory "$SMPROGRAMS\${PRODUCT_NAME}"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\${PRODUCT_NAME}.lnk" "$INSTDIR\${PRODUCT_NAME}.exe"
  CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Uninstall ${PRODUCT_NAME}.lnk" "$INSTDIR\${PRODUCT_NAME}.exe" "--uninstall" "msiexec.exe"
  CreateShortCut "$SMSTARTUP\${PRODUCT_NAME} Tray.lnk" "$INSTDIR\${PRODUCT_NAME}.exe" "--tray"
  
  nsExec::Exec 'sc create ${PRODUCT_NAME} start=auto DisplayName="${PRODUCT_NAME} Service" binPath= "\"$INSTDIR\${PRODUCT_NAME}.exe\" --service"'
  nsExec::Exec 'netsh advfirewall firewall add rule name="${PRODUCT_NAME} Service" dir=in action=allow program="$INSTDIR\${PRODUCT_NAME}.exe" enable=yes'
  nsExec::Exec 'sc start ${PRODUCT_NAME}'
SectionEnd

Section "Auto Run"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "${PRODUCT_NAME}""$INSTDIR\${PRODUCT_NAME}.exe"
  CreateShortCut "$DESKTOP\${PRODUCT_NAME}.lnk" "$INSTDIR\${PRODUCT_NAME}.exe"
SectionEnd

####################################################################
# Functions

Function .onInit
  # RustDesk is 64-bit only
  ${IfNot} ${RunningX64}
    MessageBox MB_ICONSTOP "${PRODUCT_NAME} is 64-bit only!"
    Quit
  ${EndIf}
  ${DisableX64FSRedirection}
  SetRegView 64

  !insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd
