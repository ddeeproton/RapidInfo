; Setup RapidInfo
!define /file VERSION version.txt

;--------------------------------
;Include Modern UI

!include "MUI2.nsh"

;--------------------------------

; The name of the installer
Name "RapidInfo ${VERSION}"

; The file to write
OutFile "RapidInfoSetup_${VERSION}.exe"

; The default installation directory
;InstallDir "$PROGRAMFILES\RapidInfo"
InstallDir "C:\RapidInfo"

ShowInstDetails show

; Set to silent mode
;SilentInstall silent

; Request application privileges for Windows Vista
;RequestExecutionLevel admin


BGGradient 000000 000080 FFFFFF 
InstallColors 8080FF 000030 
XPStyle on

;--------------------------------
;Interface Settings

!define MUI_ABORTWARNING

!define MUI_ICON "icones\info.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "NSISBanner.bmp"
!define MUI_HEADERIMAGE_LEFT
;--------------------------------

; Pages

#Page directory
#Page instfiles

;--------------------------------
;Languages

  #!insertmacro MUI_LANGUAGE "English" ;first language is the default language
  !insertmacro MUI_LANGUAGE "French"
  !define MUI_LANGDLL_ALLLANGUAGES
;--------------------------------
;Pages
  #!insertmacro MUI_PAGE_WELCOME
  #!insertmacro MUI_PAGE_LICENSE "${NSISDIR}\Docs\Modern UI\License.txt"
  !insertmacro MUI_PAGE_LICENSE "License.txt"
  #!insertmacro MUI_PAGE_COMPONENTS
  
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  #!insertmacro MUI_PAGE_FINISH

  !insertmacro MUI_UNPAGE_WELCOME
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  #!insertmacro MUI_UNPAGE_FINISH

;--------------------------------

; The stuff to install
Section "" ;No components page, name is not important
  Call IsSilent
  Pop $0
  StrCmp $0 1 goSilent1 goNotSilent1
  goSilent1:
	Sleep 5000
  goNotSilent1:
  
  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
  
  ; Put file there
  File "RapidInfo.exe"
  File "RapidInfo(source).zip"
  
  
  
  CreateDirectory "$SMPROGRAMS\RapidInfo"
  #CreateShortCut "$SMPROGRAMS\RapidInfo\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
  CreateShortCut "$SMPROGRAMS\RapidInfo\RapidInfo.lnk" "$INSTDIR\RapidInfo.exe" "" "$INSTDIR\RapidInfo.exe" 0
  CreateShortCut "$DESKTOP\RapidInfo.lnk" "$INSTDIR\RapidInfo.exe" "" "$INSTDIR\RapidInfo.exe" 0
  CreateShortCut "$SMPROGRAMS\RapidInfo\Uninstall.lnk" "$INSTDIR\uninstall_RapidInfo.exe" "" "$INSTDIR\uninstall_RapidInfo.exe" 0

  WriteRegStr HKLM "SOFTWARE\RapidInfo" "" $INSTDIR
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\RapidInfo" "DisplayName" "RapidInfo (remove only)"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\RapidInfo" "UninstallString" '"$INSTDIR\uninstall_RapidInfo.exe"'
  
  
  
  WriteUninstaller "uninstall_RapidInfo.exe"
  #ExecShell "open"  '"${NSISDIR}\RapidInfo_TestVersion.exe"'
  #ExecWait '"${NSISDIR}\RapidInfo_TestVersion.exe"'
  #Exec '"${NSISDIR}\RapidInfo_TestVersion.exe"'

  StrCmp $0 1 goSilent2 goNotSilent2
  goSilent2:
	  Exec 'RapidInfo.exe /background' # equivaut à IF is silent /S
	  Quit
	  
  goNotSilent2:
  Exec 'RapidInfo.exe /autostart'
  Quit
SectionEnd ; end the section

Function .onInit

  !insertmacro MUI_LANGDLL_DISPLAY

FunctionEnd




 
Section
  # do stuff
SectionEnd
 
Function IsSilent
  Push $0
  Push $CMDLINE
  Push "/S"
  Call StrStr
  Pop $0
  StrCpy $0 $0 3
  StrCmp $0 "/S" silent
  StrCmp $0 "/S " silent
    StrCpy $0 0
    Goto notsilent
  silent: StrCpy $0 1
  notsilent: Exch $0
FunctionEnd
 
Function StrStr
  Exch $R1 ; st=haystack,old$R1, $R1=needle
  Exch    ; st=old$R1,haystack
  Exch $R2 ; st=old$R1,old$R2, $R2=haystack
  Push $R3
  Push $R4
  Push $R5
  StrLen $R3 $R1
  StrCpy $R4 0
  ; $R1=needle
  ; $R2=haystack
  ; $R3=len(needle)
  ; $R4=cnt
  ; $R5=tmp
  loop:
    StrCpy $R5 $R2 $R3 $R4
    StrCmp $R5 $R1 done
    StrCmp $R5 "" done
    IntOp $R4 $R4 + 1
    Goto loop
  done:
  StrCpy $R1 $R2 "" $R4
  Pop $R5
  Pop $R4
  Pop $R3
  Pop $R2
  Exch $R1
FunctionEnd





# Uninstall section.

Section "Uninstall"


	  DeleteRegKey HKLM "SOFTWARE\RapidInfo"
	  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\RapidInfo"

	  RMDir /r "$SMPROGRAMS\RapidInfo"


	  #Delete "$INSTDIR\RapidInfo.exe"
	  #Delete "$INSTDIR\uninstall_RapidInfo.exe"
	  Delete "$DESKTOP\RapidInfo.lnk"


	  RMDir /r $INSTDIR

SectionEnd
