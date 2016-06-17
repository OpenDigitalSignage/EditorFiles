#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=DS-Layout.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Comment=Homepage: http://www.mcmilk.de/projects/DS-Layout/
#AutoIt3Wrapper_Res_Description=Layout Designer for Digital Signage Background Daemon
#AutoIt3Wrapper_Res_Fileversion=0.3.0.0
#AutoIt3Wrapper_Res_ProductVersion=0.3.0.0
#AutoIt3Wrapper_Res_LegalCopyright=© 2015 - 2016 Tino Reichardt
#AutoIt3Wrapper_Res_Language=1031
#AutoIt3Wrapper_Res_Field=Productname|DS-Layout
#AutoIt3Wrapper_Res_Field=CompanyName|Tino Reichardt
#AutoIt3Wrapper_Res_Field=Compile Date|%date% %time%
#AutoIt3Wrapper_Run_After=echo %fileversion% > prog.txt
#AutoIt3Wrapper_Run_After=rem mpress -q -r -s DS-Layout.exe
#AutoIt3Wrapper_Run_After=rem mpress -q -r -s DS-Layout_x64.exe
#AutoIt3Wrapper_Run_After=rem signtool sign /v /tr http://time.certum.pl/ /f DS-Layout.p12 /p pass DS-Layout.exe
#AutoIt3Wrapper_Run_After=rem signtool sign /v /tr http://time.certum.pl/ /f DS-Layout.p12 /p pass DS-Layout_x64.exe
#AutoIt3Wrapper_Run_Tidy=y
#AutoIt3Wrapper_Tidy_Stop_OnError=n
#AutoIt3Wrapper_Run_Au3Stripper=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#cs
	Copyright © 2015 - 2016 Tino Reichardt

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License Version 2, as
	published by the Free Software Foundation.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
#ce

; ctime: /TR 2015-08-14
; mtime: /TR 2016-03-17

#include <Array.au3>
#include <AutoItConstants.au3>
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <File.au3>
#include <Misc.au3>
#include <GUIConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiComboBox.au3>
#include <GuiStatusBar.au3>
#include <GuiMenu.au3>
#include <GuiToolbar.au3>
#include <GuiButton.au3>
#include <GuiRichEdit.au3>
#include <GuiImageList.au3>
#include <StaticConstants.au3>
#include <ToolbarConstants.au3>
#include <WindowsConstants.au3>
#include <WinAPIShPath.au3>
#include <GDIPlus.au3>

#include "BinaryCall.au3"
#include "DS-Layout_Icons.au3"
#include "DS-Layout_Tools.au3"

Opt("MustDeclareVars", 1)
Opt("TrayMenuMode", 1 + 2 + 4)
Opt("TrayIconHide", 1)
Opt("TrayAutoPause", 0)
Opt("WinTitleMatchMode", 2)

; Titel, Name und so weiter definieren...
Global Const $sAppName = "Layout Designer"
Global Const $sTitle = " " & $sAppName
Global Const $sVersion = "0.3"
Global Const $sIniFile = @ScriptDir & "\DS-Layout.ini"

Global Const $iWindowStyle = BitOR($WS_EX_TOOLWINDOW, 0)
Global $iOptionsRound = 2
Global $iOptionsGap = 10

Global $sMyState = ""

#cs
	16:9  -> 800 x 450  (1.777)
	16:10 -> 800 x 500  (1.6)
	4:3   -> 800 x 600  (1.333)
#ce
Global Const $aResolution[3][3] = [ _
		["800x450 (16:9)", 800, 450], _
		["800x500 (16:10)", 800, 500], _
		["800x600 (4:3)", 800, 600]]
;_ArrayDisplay($aResolution)

; ToolBox
Global $hGUI ; Handle of ToolBox Gui
Global $aGUI_Buttons = [0] ; 0=counter, all other are gid's
Global $iCloseButton ; Close Button
Global $iPaypalButton ; Spenden
Global $iToolBar ; ToolBar

; Static ID's of Toolbar in ToolBox
Global Enum $eTB_New = 2000, $eTB_Open, $eTB_Save

; Layout UI's
; [0][0] -> Count
; [0][1] -> X
; [0][2] -> Y
; [0][3] -> W
; [0][4] -> H
; $eL_Handle      Handle zum Layout
; $eL_File        Datei des Layouts
; $eL_Path        Pfad zur Layout Datei
; $eL_State       M = Modified, U = Unchanged
; $eL_Resolution  0(19:9) 1(16:10) 2(4:3) -> wie im Array $aResolution definiert
Global $aLayouts[1][5] = [[0, 0, 0, 0, 0]]
Global Enum $eL_Handle = 0, $eL_Path, $eL_File, $eL_State, $eL_Resolution
Global $hLastLayout = 0

; Eigenschaften von "Control oder Layout #X"
; $eP_LHandle   Handle des Layouts
; $eP_Handle    Handle des Eigenschaften Fensters
; $eP_Cid       ID des Controls, wobei "0" ist das Layout als solches
Global $aProperties[1][3] = [[0, 0, 0]]
Global Enum $eP_LHandle = 0, $eP_Handle, $eP_Cid

; GID's (GUI ID - verteilt auf alle Layouts)
; [0][0] -> Count
; $eG_LHandle  Handle zum Layout
; $eG_Cid      Control ID
; $eG_CHandle  Handle zum Control
; $eG_X        X Left
; $eG_Y        Y Top
; $eG_W        W Width
; $eG_H        H Height
; $eG_Name     Name
; $eG_Type     SlideShow
Global $aGids[1][9] = [[0, 0, 0, 0, 0, 0, 0, 0, 0]]
Global Enum $eG_LHandle = 0, $eG_Cid, $eG_CHandle, $eG_X, $eG_Y, $eG_W, $eG_H, $eG_Name, $eG_Type

; PID's (Property ID)
; [0][0] -> Count
; 0 = Funktion (X, Y, W, H, Name, ...)
; 1 = ID im Eigenschaften Fenster
; 2 = ID im Layout Fenster
; 3 = Hwnd des Layout Fensters
Global $aPids[1][4] = [[0, 0, 0, 0]]
Global Enum $eX_Func = 0, $eX_Pid, $eX_Cid, $eX_LHandle

; DummyControls
Global $iToolBarClick
Global $iDoubleClickControl
Global $iDoubleClickLayout
Global $iContextMenuOf
Global $iPropertyClick

; Context Menü für Layout oder Control
Global Enum $eCM_Save = 1000, $eCM_SaveAs, $eCM_Properties, $eCM_Close, $eCM_CProperties, $eCM_Delete, $eCM_Info
Global $sLastDirectory = IniRead($sIniFile, "Options", "LastDirectory", @ScriptDir)

; #FUNCTION# ====================================================================================================================
; Name ..........: ToolBox_Init
; Description ...: Init für das gesamte Programm, alles wichtige wird hier angeschubst
; Syntax ........: ToolBox_Init()
; Parameters ....: -
; Return values .: -
; Author ........: Tino Reichardt
; Modified ......: 13.08.2015
; ===============================================================================================================================
Func ToolBox_Init()
	Local $iTop = IniRead($sIniFile, "Options", "Top", 100)
	Local $iLeft = IniRead($sIniFile, "Options", "Left", 100)
	$iOptionsRound = IniRead($sIniFile, "Options", "Round", $iOptionsRound)
	$iOptionsGap = IniRead($sIniFile, "Options", "Gap", $iOptionsGap)
	$hGUI = GUICreate($sTitle & " - ToolBox", 170, 12 + 50 * 9, $iTop, $iLeft, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_APPWINDOW))

	_GDIPlus_Startup()
	$iToolBar = _GUICtrlToolbar_Create($hGUI, BitOR($BTNS_SHOWTEXT, $TBSTYLE_FLAT))
	_GUICtrlToolbar_AddBitmap($iToolBar, 1, -1, $IDB_STD_LARGE_COLOR)
	_GUICtrlToolbar_AddButton($iToolBar, $eTB_New, $STD_FILENEW, 0)
	_GUICtrlToolbar_AddButton($iToolBar, $eTB_Open, $STD_FILEOPEN, 0)
	_GUICtrlToolbar_AddButtonSep($iToolBar)
	_GUICtrlToolbar_AddButton($iToolBar, $eTB_Save, $STD_FILESAVE, 1)
	$iToolBarClick = GUICtrlCreateDummy()
	$iDoubleClickLayout = GUICtrlCreateDummy()
	$iDoubleClickControl = GUICtrlCreateDummy()
	$iContextMenuOf = GUICtrlCreateDummy()
	$iPropertyClick = GUICtrlCreateDummy()
	GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")
	GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")
	GUIRegisterMsg($WM_COPYDATA, "WM_COPYDATA")
	GUIRegisterMsg($WM_CONTEXTMENU, "WM_CONTEXTMENU")
	GUIRegisterMsg($WM_LBUTTONDBLCLK, "WM_LBUTTONDBLCLK")

	ToolBox_AddButton("SlideShow", My01_slideshowico())
	ToolBox_AddButton("Uhr", My02_clockico())
	ToolBox_AddButton("Webseite", My03_websiteico())
	ToolBox_AddButton("Newsfeed", My04_newsfeedico())
	ToolBox_AddButton("Ticker", My05_tickerico())
	ToolBox_AddButton("Wetter", My06_weatherico())
	ToolBox_DisableButtons()

	$iPaypalButton = GUICtrlCreateButton("Spenden", 8, 60 + 50 * $aGUI_Buttons[0], 150, 44, $BS_FLAT)
	Local $hImage = _GUIImageList_Create(32, 32, 5, 3, 1)
	_GUIImageList_Add($hImage, _GDIPlus_BitmapCreateFromMemory(My07_paypalico(), 1))
	_GUICtrlButton_SetImageList($iPaypalButton, $hImage)

	$iCloseButton = GUICtrlCreateButton("Beeenden", 8, 110 + 50 * $aGUI_Buttons[0], 150, 44, $BS_FLAT)
	Local $hImage = _GUIImageList_Create(32, 32, 5, 3, 1)
	_GUIImageList_Add($hImage, _GDIPlus_BitmapCreateFromMemory(My08_appexitico(), 1))
	_GUICtrlButton_SetImageList($iCloseButton, $hImage)
	GUISetState(@SW_SHOW)

	AdlibRegister("Layout_CheckCurrent", 150)
EndFunc   ;==>ToolBox_Init

; #FUNCTION# ====================================================================================================================
; Name ..........: ToolBox_AddButton
; Description ...: Erstellt einen Button in der HauptToolBox
; Syntax ........: ToolBox_AddButton(Name, Symbol)
; Parameters ....: Name, Symbol
; Return values .: -
; Author ........: Tino Reichardt
; Modified ......: 13.08.2015
; ===============================================================================================================================
Func ToolBox_AddButton($sName, $fIcon)
	Local $iButton = GUICtrlCreateButton($sName, 8, 44 + 50 * $aGUI_Buttons[0], 150, 44, $BS_FLAT)
	Local $hImage = _GUIImageList_Create(32, 32, 5, 3, 1)
	_GUIImageList_Add($hImage, _GDIPlus_BitmapCreateFromMemory($fIcon, 1))
	_GUICtrlButton_SetImageList($iButton, $hImage)
	$aGUI_Buttons[0] += 1
	_ArrayAdd($aGUI_Buttons, $iButton)
EndFunc   ;==>ToolBox_AddButton

; #FUNCTION# ====================================================================================================================
; Name ..........: ToolBox_DisableButtons
; Description ...: Alle Buttons ausgrauen... da kein Layout geöffnet ist
; Syntax ........: ToolBox_DisableButtons()
; Parameters ....: -
; Return values .: -
; Author ........: Tino Reichardt
; Modified ......: 13.08.2015
; ===============================================================================================================================
Func ToolBox_DisableButtons()
	Local $i
	For $i = 1 To 6
		GUICtrlSetState($aGUI_Buttons[$i], $GUI_DISABLE)
	Next
	_GUICtrlToolbar_EnableButton($iToolBar, $eTB_Save, False)
EndFunc   ;==>ToolBox_DisableButtons

; #FUNCTION# ====================================================================================================================
; Name ..........: ToolBox_EnableButtons
; Description ...: Aktivieren der Buttons und des speichern Symbols der ToolBar
; Syntax ........: ToolBox_EnableButtons()
; Parameters ....: -
; Return values .: -
; Author ........: Tino Reichardt
; Modified ......: 13.08.2015
; ===============================================================================================================================
Func ToolBox_EnableButtons()
	Local $i
	For $i = 1 To 6
		GUICtrlSetState($aGUI_Buttons[$i], $GUI_ENABLE)
	Next
	_GUICtrlToolbar_EnableButton($iToolBar, $eTB_Save, True)
EndFunc   ;==>ToolBox_EnableButtons

; #FUNCTION# ====================================================================================================================
; Name ..........: ToolBox_Exit
; Description ...: Beenden des Programmes, sofern vom benutzer bestätigt
; Syntax ........: ToolBox_Exit()
; Parameters ....: -
; Return values .: -
; Author ........: Tino Reichardt
; Modified ......: 13.08.2015
; ===============================================================================================================================
Func ToolBox_Exit()
	If $aLayouts[0][0] > 0 Then
		; wenn noch layouts offen sind, fragen wir, ob der nutzer wirklich beenden will
		If MsgBox(BitOR($MB_YESNO, $MB_ICONQUESTION), $sTitle, "Soll " & $sAppName & " geschlossen werden?") <> $IDYES Then Return
	EndIf
	Local $aPos = WinGetPos($hGUI)
	IniWrite($sIniFile, "Options", "Top", $aPos[0])
	IniWrite($sIniFile, "Options", "Left", $aPos[1])
	IniWrite($sIniFile, "Options", "Round", $iOptionsRound)
	IniWrite($sIniFile, "Options", "Gap", $iOptionsGap)
	_GDIPlus_Shutdown()
	Exit
EndFunc   ;==>ToolBox_Exit

; #FUNCTION# ====================================================================================================================
; Name ..........: Layout_CheckCurrent
; Description ...: Prüft, welche LayoutFenster gerde aktiv ist (hab erstmal keine bessere Lösung)
; Syntax ........: Layout_CheckCurrent()
; Author ........: Tino Reichardt
; Modified ......: 24.08.2015
; ===============================================================================================================================
Func Layout_CheckCurrent()
	If WinActive($hLastLayout) Then Return
	For $i = 1 To $aLayouts[0][0]
		If WinActive($aLayouts[$i][$eL_Handle]) Then
			$hLastLayout = $aLayouts[$i][$eL_Handle]
			Return
		EndIf
	Next
EndFunc   ;==>Layout_CheckCurrent

; #FUNCTION# ====================================================================================================================
; Name ..........: Layout_Create
; Description ...: Erstellt ein neues Layout Fenster inkl. Layout ToolBox
; Syntax ........: Layout_Create(Pfad, Datei, Status, Auflösung, Links, Top)
; Parameters ....: Pfad, Datei, Status[M|U]
; Return values .: Handle to created Layout Window
; Author ........: Tino Reichardt
; Modified ......: 13.08.2015
; ===============================================================================================================================
Func Layout_Create($sPath, $sFile, $sState, $pRes = 0, $pLeft = -1, $pTop = -1)

	Local $iWidth, $iHeight
	Local $iRes = $pRes ; 19:9
	$iWidth = $aResolution[$iRes][1]
	$iHeight = $aResolution[$iRes][2]

	; create new empty layout (defaults to 16:9)
	Local $hWin = GUICreate($sTitle & " - " & $sFile, $iWidth, $iHeight, $pLeft, $pTop, -1, $iWindowStyle, $hGUI)
	GUISetState(@SW_SHOW, $hWin)

	_ArrayAdd($aLayouts, $hWin & "|" & $sPath & "|" & $sFile & "|" & $sState & "|" & $iRes)
	$aLayouts[0][0] += 1

	; ab nun darf der User loslegen...
	ToolBox_EnableButtons()

	Return $hWin
EndFunc   ;==>Layout_Create

; #FUNCTION# ====================================================================================================================
; Name ..........: Layout_New
; Description ...: Erstellt ein neues / leeres Layout und ruft dann Layout_Create auf...
; Syntax ........: Layout_New()
; Parameters ....: Pfad, Datei
; Return values .: Handle to created Layout Window
; Author ........: Tino Reichardt
; Modified ......: 13.08.2015
; ===============================================================================================================================
Func Layout_New()
	Local $sName, $i = 0, $j

	; search new unused layout
	While True
		$i += 1
		$sName = "Layout #" & $i & ".dsbd"
		Local $iFound = 0
		For $j = 1 To $aLayouts[0][0]
			If $aLayouts[$j][$eL_File] = $sName Then $iFound = 1
		Next
		If FileExists($sLastDirectory & "\" & $sName) Then $iFound = 1
		If $iFound = 0 Then ExitLoop
	WEnd

	Return Layout_Create($sLastDirectory, $sName, "U")
EndFunc   ;==>Layout_New

; #FUNCTION# ====================================================================================================================
; Name ..........: Layout_Open
; Description ...: Öffnet ein bestehendes Layout und ruft dann Layout_Create auf...
; Syntax ........: Layout_Open()
; Parameters ....: -
; Return values .: Handle to created Layout Window
; Author ........: Tino Reichardt
; Modified ......: 13.08.2015
; ===============================================================================================================================
Func Layout_Open($pFileName = "")
	Local $sFile

	; wenn Datei übergeben wurde, diese öffnen, ansonsten Abfrage Dialog
	If Not StringLen($pFileName) = 0 And FileExists($pFileName) Then
		$sFile = $pFileName
	Else
		$sFile = FileOpenDialog($sTitle & " - Layout öffnen", $sLastDirectory, "DS Layouts (*.dsbd)", $FD_FILEMUSTEXIST)
		If @error Then Return
	EndIf

	Local $iRes, $hWnd = -1
	Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
	_PathSplit($sFile, $sDrive, $sDir, $sFileName, $sExtension)
	IniWrite($sIniFile, "Options", "LastDirectory", $sDrive & $sDir)

	Local $aSections = IniReadSectionNames($sFile)
	For $i = 1 To $aSections[0]
		Local $sName = $aSections[$i]
		Local $sFirst = StringLeft($sName, 1)
		If $sFirst = "#" Then ContinueLoop
		Local $sType = IniRead($sFile, $sName, "Type", "SlideShow")
		If $sType = "Background" Then
			Local $pRes = IniRead($sFile, $sName, "Resolution", 0)
			Local $pLeft = IniRead($sFile, $sName, "Left", -1)
			Local $pTop = IniRead($sFile, $sName, "Top", -1)
			$hWnd = Layout_Create($sDrive & $sDir, $sFileName & $sExtension, "U", $pRes, $pLeft, $pTop)
			ContinueLoop
		EndIf
		Local $pLeft = IniRead($sFile, $sName, "left", "10")
		Local $pTop = IniRead($sFile, $sName, "top", "10")
		Local $pHeight = IniRead($sFile, $sName, "height", "50")
		Local $pWidth = IniRead($sFile, $sName, "width", "50")
		Layout_Create_Control($hWnd, $sType, $sName, $pLeft, $pTop, $pWidth, $pHeight)
	Next

	; da passt was nicht...
	If $hWnd = -1 Then
		MsgBox(BitOR($MB_OK, $MB_ICONERROR), $sTitle, "Layout Datei enthält Fehler!")
		Return
	EndIf

	; just open, did not change sth.
	For $i = 1 To $aLayouts[0][0]
		If $aLayouts[$i][$eL_Handle] = $hWnd Then
			$aLayouts[$i][$eL_State] = "U"
			Return $hWnd
		EndIf
	Next

	;_PrintFromArray($aLayouts)
	Return $hWnd
EndFunc   ;==>Layout_Open

; #FUNCTION# ====================================================================================================================
; Name ..........: Layout_Save
; Description ...: speichert ein Layout ab
; Syntax ........: Layout_Save(Handle)
; Parameters ....: Handle - Handle des Layouts, welches gespeichert werden soll
; Return values .: True when erfolgreich, ansonsten False
; Author ........: Tino Reichardt
; Modified ......: 13.08.2015
; ===============================================================================================================================
Func Layout_Save($hLayout, $iForce = 0)
	Local $iLayout = -1
	For $i = 1 To $aLayouts[0][0]
		If $aLayouts[$i][$eL_Handle] = $hLayout Then
			$iLayout = $i
			ExitLoop
		EndIf
	Next

	; Fehler, Layout nicht gefunden...
	If $iLayout = -1 Then Return

	Local $sFile
	If $iForce = 0 Then
		$sFile = FileSaveDialog($sTitle & " - Layout speichern", $aLayouts[$iLayout][$eL_Path], "DS Layouts (*.dsbd)", 0, $aLayouts[$iLayout][$eL_File])
		; Fehler beim speichern unter Dialog bzw. Nutzer bricht ab...
		If @error Then Return
	Else
		$aLayouts[$iLayout][$eL_Path] &= "\"
		$sFile = $aLayouts[$iLayout][$eL_Path] & $aLayouts[$iLayout][$eL_File]
	EndIf

	;ConsoleWrite("path=" & $aLayouts[$iLayout][$eL_Path] & @CRLF)
	;ConsoleWrite("file=" & $aLayouts[$iLayout][$eL_File] & @CRLF)

	Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
	_PathSplit($sFile, $sDrive, $sDir, $sFileName, $sExtension)
	$sFileName &= $sExtension
	$aLayouts[$iLayout][$eL_Path] = $sDrive & $sDir

	; FileName des Layouts ändern, wenn Benutzer das geändert hat...
	If $sFileName <> $aLayouts[$iLayout][$eL_File] Then
		$aLayouts[$iLayout][$eL_File] = $sFileName
		WinSetTitle($hLayout, "", $sTitle & " - " & $aLayouts[$iLayout][$eL_File])
	EndIf

	; altes Layout löschen, wenn vorhanden
	FileDelete($sFile)

	Local $iRes = $aLayouts[$iLayout][$eL_Resolution]
	Local $iX = $aResolution[$iRes][1]
	Local $iY = $aResolution[$iRes][2]

	; abspeichern der Layout Werte
	; Layout Fensterposition wird auch gespeichert!
	; [1] $aLayouts: 0x004D05AA|z:\autoit\DS-Layout|Layout #1.dsbd|M|0|
	Local $aPos = WinGetPos($hLayout)
	If Not IsArray($aPos) Then
		MsgBox($MB_ICONERROR, $sTitle, "Layout Fensterposition unbekannt?!")
		Exit
	EndIf
	Local $sIniSection = ""
	$sIniSection &= "Left=" & $aPos[0] & @LF
	$sIniSection &= "Top=" & $aPos[1] & @LF
	$sIniSection &= "Resolution=" & $iRes & @LF
	$sIniSection &= "Type=" & "Background" & @LF
	$sIniSection &= " " & @LF ; Ini File is better read-able then...
	IniWriteSection($sFile, "Layout", $sIniSection)

	For $i = 1 To $aGids[0][0]
		If $aGids[$i][$eG_LHandle] = $hLayout Then
			$sIniSection = ""
			$sIniSection &= "left=" & $aGids[$i][$eG_X] & @LF
			$sIniSection &= "top=" & $aGids[$i][$eG_Y] & @LF
			$sIniSection &= "width=" & $aGids[$i][$eG_W] & @LF
			$sIniSection &= "height=" & $aGids[$i][$eG_H] & @LF
			$sIniSection &= "Type=" & $aGids[$i][$eG_Type] & @LF
			$sIniSection &= "Left=" & Round($aGids[$i][$eG_X] * 100 / $iX, $iOptionsRound) & "%" & @LF
			$sIniSection &= "Top=" & Round($aGids[$i][$eG_Y] * 100 / $iY, $iOptionsRound) & "%" & @LF
			$sIniSection &= "Width=" & Round($aGids[$i][$eG_W] * 100 / $iX, $iOptionsRound) & "%" & @LF
			$sIniSection &= "Height=" & Round($aGids[$i][$eG_H] * 100 / $iY, $iOptionsRound) & "%" & @LF
			$sIniSection &= " " & @LF ; Ini File is better read-able then...
			IniWriteSection($sFile, $aGids[$i][$eG_Name], $sIniSection)
		EndIf
	Next

	If Not FileExists($sFile) Then
		MsgBox(BitOR($MB_OK, $MB_ICONERROR), $sTitle, "Fehler bei speichern der Datei " & $sFile & "!")
		Return
	EndIf

	; Layout wurde gespeicht, ist im moment quasi "unverändert"
	$aLayouts[$iLayout][$eL_State] = "U"
	Return
EndFunc   ;==>Layout_Save

; #FUNCTION# ====================================================================================================================
; Name ..........: Layout_Control_SetTip
; Description ...: Control mit neuem ToolTip ausstatten
; Syntax ........: Layout_Control_SetTip($iCtrl)
; Parameters ....: $iCtrl = Control ID
; Return values .: -
; Author ........: Tino Reichardt
; Modified ......: 26.08.2015
; ===============================================================================================================================
Func Layout_Control_SetTip($iCtrl, $iGid = -1)

	; wir suchen die ID, da wir keine bekommen haben...
	If $iGid = -1 Then
		For $i = 1 To $aGids[0][0]
			If $aGids[$i][$eG_Cid] = $iCtrl Then
				$iGid = $i
				ExitLoop
			EndIf
		Next
	EndIf

	; nicht gefunden
	If $iGid = -1 Then Return

	Local $sText = ""
	$sText &= "Start: " & $aGids[$iGid][$eG_X] & "x" & $aGids[$iGid][$eG_Y] & @LF
	$sText &= "Breite: " & $aGids[$iGid][$eG_W] & @LF
	$sText &= "Höhe: " & $aGids[$iGid][$eG_H] & @LF & @LF
	$sText &= "Typ: " & $aGids[$iGid][$eG_Type] & @LF
	; $sText &= "LHwnd: " & $aGids[$iGid][$eG_LHandle] & @LF
	; $sText &= "Hwnd: " & $aGids[$iGid][$eG_CHandle] & @LF
	; $sText &= "Gid: " & $aGids[$iGid][$eG_Cid] & @LF
	GUICtrlSetTip($iCtrl, $sText, $aGids[$iGid][$eG_Name])
EndFunc   ;==>Layout_Control_SetTip

; #FUNCTION# ====================================================================================================================
; Name ..........: Layout_Create_Control
; Description ...: Neues Control in das Layout einfügen
; Syntax ........: Layout_Create_Control(Handle, Type)
; Parameters ....: Handle: Handle des Layouts, welches das Control bekommt
;                  Type: SlideShow oder Ticker usw.
; Return values .: -
; Author ........: Tino Reichardt
; Modified ......: 14.08.2015
; ===============================================================================================================================
Func Layout_Create_Control($hLayout, $sType, $pName = -1, $pLeft = -1, $pTop = -1, $pWidth = -1, $pHeight = -1)
	Local $iLayout = -1
	;ConsoleWrite("Layout_Create_Control(" & $hLayout & "," & $sType & "," & $pLeft & "," & $pTop & "," & $pWidth & "," & $pHeight & ")" & @CRLF)

	; wohin wurde denn geklickt?
	For $i = 1 To $aLayouts[0][0]
		If $aLayouts[$i][$eL_Handle] = $hLayout Then
			$iLayout = $i
			ExitLoop
		EndIf
	Next
	If $iLayout = -1 Then Return

	; Name suchen, damit keine Dopplungen vorkommen...
	If $pName <> -1 Then
		Local $sName = $pName
	Else
		Local $sName
		Local $i = 0
		While True
			$i += 1
			$sName = $sType & " #" & $i
			Local $iFound = 0
			For $j = 1 To $aGids[0][0]
				If $aGids[$j][$eG_Name] = $sName And $aGids[$j][$eG_LHandle] = $hLayout Then $iFound = 1
			Next
			If $iFound = 0 Then ExitLoop
		WEnd
	EndIf

	Local $iWidth = $pWidth
	Local $iHeight = $pHeight

	Local $iColor
	Switch $sType
		Case "SlideShow"
			If $iWidth = -1 Then $iWidth = 273
			If $iHeight = -1 Then $iHeight = 387
			$iColor = 0xffb266
		Case "Uhr"
			If $iWidth = -1 Then $iWidth = 120
			If $iHeight = -1 Then $iHeight = 120
			$iColor = 0xccff99
		Case "Webseite"
			If $iWidth = -1 Then $iWidth = 333
			If $iHeight = -1 Then $iHeight = 187
			$iColor = 0x99ff66
		Case "Newsfeed"
			If $iWidth = -1 Then $iWidth = 333
			If $iHeight = -1 Then $iHeight = 187
			$iColor = 0x99ccdd
		Case "Ticker"
			If $iWidth = -1 Then $iWidth = 784
			If $iHeight = -1 Then $iHeight = 40
			$iColor = 0xff99cc
		Case "Wetter"
			If $iWidth = -1 Then $iWidth = 120
			If $iHeight = -1 Then $iHeight = 237
			$iColor = 0x9999ff
	EndSwitch

	If $pTop = -1 Then
		Local $aCursor = GUIGetCursorInfo($hLayout)
		$pLeft = $aCursor[0]
		$pTop = $aCursor[1]
	EndIf

	#cs
		a five-element array that containing the mouse cursor information:
		$aArray[0] = X coord (horizontal)
		$aArray[1] = Y coord (vertical)
		$aArray[2] = Primary down (1 if pressed, 0 if not pressed)
		$aArray[3] = Secondary down (1 if pressed, 0 if not pressed)
		$aArray[4] = ID of the control that the mouse cursor is hovering over (or 0 if none)
	#ce
	Local $iCtrl = GUICtrlCreateLabel($sName, $pLeft, $pTop, $iWidth, $iHeight, BitOR($SS_NOTIFY, $WS_BORDER))
	Local $hGid = GUICtrlGetHandle($iCtrl)
	GUICtrlSetBkColor(-1, $iColor)
	GUISetState(@SW_SHOW)

	; Global Enum $eG_LHandle = 0, $eG_Cid, $eG_CHandle, $eG_X, $eG_Y, $eG_W, $eG_H, $eG_Name, $eG_Type
	Local $sArray = $hLayout & "|" & $iCtrl & "|" & $hGid & "|" & $pLeft & "|" & $pTop & "|" & $iWidth & "|" & $iHeight & "|" & $sName & "|" & $sType
	_ArrayAdd($aGids, $sArray)
	$aGids[0][0] += 1
	Layout_Control_SetTip($iCtrl)

	; wir haben was geändert
	$aLayouts[$iLayout][$eL_State] = "M"
EndFunc   ;==>Layout_Create_Control

; #FUNCTION# ====================================================================================================================
; Name ..........: Layout_Delete_Control
; Description ...: Control eines Layouts löschen
; Syntax ........: Layout_Delete_Control(iGID)
; Parameters ....: Handle: Handle des Controls
; Return values .: -
; Author ........: Tino Reichardt
; Modified ......: 12.09.2015
; ===============================================================================================================================
Func Layout_Delete_Control($iGid)
	Local $iCtrl = $aGids[$iGid][$eG_Cid]

	; passende Eigenschaften Controls suchen und löschen...
	Layout_Delete_PControl($iCtrl)

	; Eigenschaften Fenster suchen und Schließen, wenn vorhanden
	For $i = $aProperties[0][0] To 1 Step -1
		If $aProperties[$i][$eP_Cid] = $iCtrl Then CloseSomeWindow($aProperties[$i][$eP_Handle])
	Next

	GUICtrlDelete($iCtrl)
	_ArrayDelete($aGids, $iGid)
	$aGids[0][0] -= 1
EndFunc   ;==>Layout_Delete_Control

; #FUNCTION# ====================================================================================================================
; Name ..........: Layout_Delete_PControl
; Description ...: Control eines Eigenschaften Fensters löschen
; Syntax ........: Layout_Delete_PControl(Control ID)
; Return values .: -
; Author ........: Tino Reichardt
; Modified ......: 20.10.2015
; ===============================================================================================================================
Func Layout_Delete_PControl($iCtrl)

	; Eigenschaften Controls suchen und löschen...
	For $i = $aPids[0][0] To 1 Step -1
		If $aPids[$i][$eP_Cid] = $iCtrl Then
			;ConsoleWrite("delete from $aPids " & $i & @CRLF)
			_ArrayDelete($aPids, $i)
			$aPids[0][0] -= 1
		EndIf
	Next
EndFunc   ;==>Layout_Delete_PControl

; #FUNCTION# ====================================================================================================================
; Name ..........: Layout_Move_Control
; Description ...: Control im Layout schieben usw...
; Syntax ........: Layout_Move_Control(Handle, Control)
; Parameters ....: Handle: Handle des Layouts, wo das Control ist
; Return values .: -
; Author ........: Tino Reichardt
; Modified ......: 25.08.2015
; ===============================================================================================================================
Func Layout_Move_Control($hWnd)
	; wir merken uns das letzte Control und die dazu gehörige Layout ID und Gid ID
	Static $iCtrl = -1
	Static $iGid, $iLayout, $iRes, $iMaxX, $iMaxY

	; da spielen wir nicht rum...
	If $hWnd = $hGUI Then Return

	; kann passieren, wenn wir Controls löschen und dabei auf ein gecachtes zurückgreifen wollen
	If $iGid > $aGids[0][0] Then $iGid = -1

	; Wo ist die Maus, wird ein Button geklickt...
	Local $aCursor = GUIGetCursorInfo($hWnd)
	If @error <> 0 Then Return

	; wenn Maus nicht über irgendwas drüber ist, nichts weiter machen...
	If $aCursor[4] = 0 Then Return

	Local $aCtrlPos = ControlGetPos($hWnd, "", $aCursor[4])
	If @error = 1 Then Return

	; wenn die Gid nicht identisch ist, dann Layout raus suchen...
	If $aCursor[4] <> $iCtrl Then
		; wohin wurde denn geklickt?
		$iCtrl = $aCursor[4]
		$iLayout = -1
		For $i = 1 To $aLayouts[0][0]
			If $aLayouts[$i][$eL_Handle] = $hWnd Then
				$iLayout = $i
				ExitLoop
			EndIf
		Next

		; nun aber weg, wir wollen die anderen controls nicht verschieben!
		If $iLayout = -1 Then
			$iCtrl = -1
			Return
		EndIf

		$iRes = $aLayouts[$iLayout][$eL_Resolution]
		$iMaxX = $aResolution[$iRes][1]
		$iMaxY = $aResolution[$iRes][2]
		$iGid = -1
		For $i = 1 To $aGids[0][0]
			If $aGids[$i][$eG_LHandle] = $hWnd And $aGids[$i][$eG_Cid] = $iCtrl Then
				$iGid = $i
				GuiCtrlSetOnTop($aGids[$i][$eG_CHandle])
				ExitLoop
			EndIf
		Next
		If $iGid = -1 Then Return
	EndIf

	#cs
		$aCtrlPos:
		[0] 210   X
		[1] 90    Y
		[2] 120   Width
		[3] 120   Height

		$aCursor:
		[0] 210   X -> genau oben links (quasi 0,0)
		[1] 90    Y -> siehe X
		[4] 13    Gid
	#ce
	Enum $eW_All = 0, $eW_OL, $eW_O, $eW_OR, $eW_L, $eW_R, $eW_UL, $eW_U, $eW_UR
	Local $iX = $aCursor[0] - $aCtrlPos[0]
	Local $iY = $aCursor[1] - $aCtrlPos[1]
	Local $iW = $aCtrlPos[2]
	Local $iH = $aCtrlPos[3]
	Local $iState = $eW_All
	Local $iCursor

	Local Const $iGap = $iOptionsGap
	If ($iX < $iGap) And ($iY < $iGap) Then
		; oben links
		$iState = $eW_OL
	ElseIf ($iX < $iGap) And ($iY + $iGap > $iH) Then
		; unten links
		$iState = $eW_UL
	ElseIf ($iY < $iGap) And ($iX + $iGap > $iW) Then
		; oben rechts
		$iState = $eW_OR
	ElseIf ($iY + $iGap > $iH) And ($iX + $iGap > $iW) Then
		; unten rechts
		$iState = $eW_UR
	ElseIf ($iX < $iGap) Then
		; links
		$iState = $eW_L
	ElseIf ($iY < $iGap) Then
		; oben
		$iState = $eW_O
	ElseIf ($iX + $iGap > $iW) Then
		; rechts
		$iState = $eW_R
	ElseIf ($iY + $iGap > $iH) Then
		; unten
		$iState = $eW_U
	EndIf

	#cs
		2 = $IDC_ARROW 9 = $IDC_SIZEALL 10 = $IDC_SIZENESW 11 = $IDC_SIZENS 12 = $IDC_SIZENWSE 13 = $IDC_SIZEWE 16 = $IDC_HAND

		NWSE     NS      NESW		OL        O        OR (Oben Rechts)
		+-------------------+		+-------------------+
		|WE               WE|		|L                 R|
		+-------------------+		+-------------------+
		NESW     NS      NWSE		UL        U        UR
	#ce
	; Cursor aussuchen und setzen...
	Switch $iState
		Case $eW_All
			$iCursor = $IDC_SIZEALL
		Case $eW_OL
			$iCursor = $IDC_SIZENWSE
		Case $eW_O
			$iCursor = $IDC_SIZENS
		Case $eW_OR
			$iCursor = $IDC_SIZENESW
		Case $eW_L
			$iCursor = $IDC_SIZEWE
		Case $eW_R
			$iCursor = $IDC_SIZEWE
		Case $eW_UL
			$iCursor = $IDC_SIZENESW
		Case $eW_U
			$iCursor = $IDC_SIZENS
		Case $eW_UR
			$iCursor = $IDC_SIZENWSE
	EndSwitch
	GUICtrlSetCursor($iCtrl, $iCursor)

	; Schauen, ob wir ein passendes Eigenschaften Control haben...
	Local $iPropCtrl = -1
	Local $iPropX, $iPropY, $iPropW, $iPropH
	Local $iPropXp, $iPropYp, $iPropWp, $iPropHp
	For $i = 1 To $aPids[0][0]
		If $aPids[$i][$eX_Cid] = $iCtrl Then
			$iPropCtrl = $aPids[$i][$eX_Pid] ; Name
			; die Reihenfolge im Enum darf nicht geändert werden!
			$iPropX = $aPids[$i + 1][$eX_Pid]
			$iPropY = $aPids[$i + 2][$eX_Pid]
			$iPropW = $aPids[$i + 3][$eX_Pid]
			$iPropH = $aPids[$i + 4][$eX_Pid]
			$iPropXp = $aPids[$i + 5][$eX_Pid]
			$iPropYp = $aPids[$i + 6][$eX_Pid]
			$iPropWp = $aPids[$i + 7][$eX_Pid]
			$iPropHp = $aPids[$i + 8][$eX_Pid]
			ExitLoop
		EndIf
	Next

	; wenn Mauszeiger gedrückt, dann ändern / verschieben...
	Local $aStart = $aCursor
	$iX = $aCtrlPos[0]
	$iY = $aCtrlPos[1]
	$iW = $aCtrlPos[2]
	$iH = $aCtrlPos[3]
	While IsArray($aCursor) And $aCursor[2] = 1
		#cs
			ConsoleWrite("$aStart:   " & $aStart[0] & "x" & $aStart[1] & @CRLF)
			ConsoleWrite("$aCursor:  " & $aCursor[0] & "x" & $aCursor[1] & @CRLF)
			ConsoleWrite("$aCtrlPos: " & $aCtrlPos[0] & "x" & $aCtrlPos[1] & " W=" & $aCtrlPos[2] & " H=" & $aCtrlPos[3] & @CRLF)
		#ce
		Local $iDX = $aCursor[0] - $aStart[0]
		Local $iDY = $aCursor[1] - $aStart[1]
		Switch $iState
			Case $eW_All
				$iX = $aCtrlPos[0] + $iDX
				$iY = $aCtrlPos[1] + $iDY
				If ($iX < 0) Then $iX = 0
				If ($iY < 0) Then $iY = 0
				If ($iX + $iW > $iMaxX) Then $iX = $iMaxX - $iW
				If ($iY + $iH > $iMaxY) Then $iY = $iMaxY - $iH
			Case $eW_OL
				; X ändern und W anpassen
				$iX = $aCtrlPos[0] + $iDX
				$iW = $aCtrlPos[2] - $iDX
				; nun noch Y und H
				$iY = $aCtrlPos[1] + $iDY
				$iH = $aCtrlPos[3] - $iDY
			Case $eW_O
				$iY = $aCtrlPos[1] + $iDY
				$iH = $aCtrlPos[3] - $iDY
			Case $eW_OR
				$iY = $aCtrlPos[1] + $iDY
				$iH = $aCtrlPos[3] - $iDY
				$iW = $aCtrlPos[2] + $iDX
			Case $eW_L
				; X ändern und W anpassen
				$iX = $aCtrlPos[0] + $iDX
				$iW = $aCtrlPos[2] - $iDX
			Case $eW_R
				; nur breite ändern
				$iW = $aCtrlPos[2] + $iDX
			Case $eW_UL
				; X ändern und W anpassen
				$iX = $aCtrlPos[0] + $iDX
				$iW = $aCtrlPos[2] - $iDX
				; höhe
				$iH = $aCtrlPos[3] + $iDY
			Case $eW_U
				; nur höhe ändern
				$iH = $aCtrlPos[3] + $iDY
			Case $eW_UR
				; nur breite und höhe ändern
				$iH = $aCtrlPos[3] + $iDY
				$iW = $aCtrlPos[2] + $iDX
		EndSwitch

		; wir lassen uns nicht aus dem fenster schieben!
		If ($iX < 0) Then Return
		If ($iY < 0) Then Return
		If ($iX + $iW > $iMaxX) Then Return
		If ($iY + $iH > $iMaxY) Then Return

		; nicht kleiner als...
		If ($iW < $iGap * 2) Then $iW = $iGap * 2
		If ($iH < $iGap * 2) Then $iH = $iGap * 2

		; wenn breite/höhe zu hoch, auf max setzen und gut
		If ($iW > $iMaxX) Then
			$iW = $iMaxX
			$iX = 0
		EndIf
		If ($iH > $iMaxY) Then
			$iH = $iMaxY
			$iY = 0
		EndIf

		; Änderungen übernehmen
		$aGids[$iGid][$eG_X] = $iX
		$aGids[$iGid][$eG_Y] = $iY
		$aGids[$iGid][$eG_W] = $iW
		$aGids[$iGid][$eG_H] = $iH
		GUICtrlSetPos($iCtrl, $iX, $iY, $iW, $iH)

		; Eigenschaften Fenster updaten, sofern es da ist
		;ConsoleWrite("$iPropCtrl=" & $iPropCtrl & @CRLF)
		If $iPropCtrl <> -1 Then
			GUICtrlSetData($iPropX, $iX)
			GUICtrlSetData($iPropY, $iY)
			GUICtrlSetData($iPropW, $iW)
			GUICtrlSetData($iPropH, $iH)
			GUICtrlSetData($iPropXp, Int($iX * 100 / $iMaxX))
			GUICtrlSetData($iPropYp, Int($iY * 100 / $iMaxY))
			GUICtrlSetData($iPropWp, Int($iW * 100 / $iMaxX))
			GUICtrlSetData($iPropHp, Int($iH * 100 / $iMaxY))
		EndIf

		; wir haben was geändert
		$aLayouts[$iLayout][$eL_State] = "M"
		Layout_Control_SetTip($iCtrl, $iGid)

		Sleep(10)
		$aCursor = GUIGetCursorInfo($hWnd)
		If @error <> 0 Then Return
	WEnd
EndFunc   ;==>Layout_Move_Control

; #FUNCTION# ====================================================================================================================
; Name ..........: Control_Properties
; Description ...: Fenster für Eigenschaften eines Controls erstellen
; Syntax ........: Control_Properties(Control ID)
; Parameters ....: Handle: Handle des Layouts wo das Control ist, iGid=0 meint Layout Eigenschaften
; Return values .: -
; Author ........: Tino Reichardt
; Modified ......: 14.08.2015
; ===============================================================================================================================
Func Control_Properties($iCtrl)
	Local $hWnd

	; Eigenschaften schon da?
	For $i = 1 To $aProperties[0][0]
		If $aProperties[$i][$eP_Cid] = $iCtrl Then
			$hWnd = HWnd($aProperties[$i][$eP_Handle])
			WinActivate($hWnd)
			WinFlash($hWnd, "", 2)
			Return
		EndIf
	Next

	; Gid heraussuchen
	Local $iGid = -1
	For $i = 1 To $aGids[0][0]
		If $aGids[$i][$eG_Cid] = $iCtrl Then
			$iGid = $i
			ExitLoop
		EndIf
	Next
	If $iGid = -1 Then Return

	; Koordinaten des Controls ermitteln
	$hWnd = HWnd($aGids[$iGid][$eG_LHandle])
	Local $aPos = ControlGetPos($hWnd, "", Int($iCtrl))
	If @error <> 0 Then
		; ControlGetPos() can fail...
		Return
	EndIf

	; Layout ID heraussuchen
	Local $iLayout = -1
	For $i = 1 To $aLayouts[0][0]
		If $aLayouts[$i][$eL_Handle] = $hWnd Then
			$iLayout = $i
			ExitLoop
		EndIf
	Next
	If $iLayout = -1 Then Return

	Local $hWin = GUICreate(" Eigenschaften von: " & $aGids[$iGid][$eG_Name], 540, 140, -1, -1, -1, $iWindowStyle, $hWnd)
	; Layout Handle, Property Handle, Layout Control ID
	_ArrayAdd($aProperties, $hWnd & "|" & $hWin & "|" & $iCtrl)
	$aProperties[0][0] += 1
	GUISetState(@SW_SHOW, $hWin)

	Local $iStyle = BitOR($GUI_DOCKTOP, $GUI_DOCKLEFT, $GUI_DOCKWIDTH, $GUI_DOCKHEIGHT)
	GUICtrlCreateLabel("Name:", 8, 10, 34, 17)
	GUICtrlSetResizing(-1, $iStyle)
	GUICtrlCreateLabel("Start:", 8, 44, 34, 17)
	GUICtrlSetResizing(-1, $iStyle)
	GUICtrlCreateLabel("x", 108, 44, 9, 17)
	GUICtrlSetResizing(-1, $iStyle)
	GUICtrlCreateLabel("Breite:", 184, 44, 34, 17)
	GUICtrlSetResizing(-1, $iStyle)
	GUICtrlCreateLabel("Höhe:", 281, 44, 34, 17)
	GUICtrlSetResizing(-1, $iStyle)
	GUICtrlCreateLabel("in Pixel", 380, 44, 55, 17)
	GUICtrlSetResizing(-1, $iStyle)
	GUICtrlCreateLabel("in Prozent", 380, 44 + 32, 55, 17)
	GUICtrlSetResizing(-1, $iStyle)

	Local $iRes = $aLayouts[$iLayout][$eL_Resolution]
	Local $iMaxX = $aResolution[$iRes][1]
	Local $iMaxY = $aResolution[$iRes][2]

	Local $Name, $X1, $Y1, $W1, $H1, $Xp, $Yp, $Wp, $Hp, $S1, $S2, $S3, $S4
	$Name = GUICtrlCreateInput($aGids[$iGid][$eG_Name], 48, 8, 323, 21)
	$X1 = GUICtrlCreateInput($aPos[0], 48, 42, 56, 21, BitOR($ES_CENTER, $ES_NUMBER))
	$Y1 = GUICtrlCreateInput($aPos[1], 119, 42, 56, 21, BitOR($ES_CENTER, $ES_NUMBER))
	$W1 = GUICtrlCreateInput($aPos[2], 219, 42, 56, 21, BitOR($ES_CENTER, $ES_NUMBER))
	$H1 = GUICtrlCreateInput($aPos[3], 314, 42, 56, 21, BitOR($ES_CENTER, $ES_NUMBER))
	$Xp = GUICtrlCreateInput(Int($aPos[0] * 100 / $iMaxX), 48, 42 + 32, 56, 21, BitOR($ES_CENTER, $ES_NUMBER))
	$Yp = GUICtrlCreateInput(Int($aPos[1] * 100 / $iMaxY), 119, 42 + 32, 56, 21, BitOR($ES_CENTER, $ES_NUMBER))
	$Wp = GUICtrlCreateInput(Int($aPos[2] * 100 / $iMaxX), 219, 42 + 32, 56, 21, BitOR($ES_CENTER, $ES_NUMBER))
	$Hp = GUICtrlCreateInput(Int($aPos[3] * 100 / $iMaxY), 314, 42 + 32, 56, 21, BitOR($ES_CENTER, $ES_NUMBER))
	$S1 = GUICtrlCreateButton("A4", 456, 8, 75, 25, $BS_FLAT)
	$S2 = GUICtrlCreateButton("16:9", 456, 40, 75, 25, $BS_FLAT)
	$S3 = GUICtrlCreateButton("4:3", 456, 72, 75, 25, $BS_FLAT)
	$S4 = GUICtrlCreateButton("1:1", 456, 104, 75, 25, $BS_FLAT)
	Local $hImage = _GUIImageList_Create(16, 16, 5, 3, 1)
	_GUIImageList_Add($hImage, _GDIPlus_BitmapCreateFromMemory(Myopt_portrait_landscapeico(), 1))
	_GUICtrlButton_SetImageList($S1, $hImage, 1)
	_GUICtrlButton_SetImageList($S2, $hImage, 1)
	_GUICtrlButton_SetImageList($S3, $hImage, 1)
	_GUICtrlButton_SetImageList($S4, $hImage, 1)

	GUICtrlSetResizing($Name, $iStyle)
	GUICtrlSetResizing($X1, $iStyle)
	GUICtrlSetResizing($Y1, $iStyle)
	GUICtrlSetResizing($W1, $iStyle)
	GUICtrlSetResizing($H1, $iStyle)
	GUICtrlSetResizing($Xp, $iStyle)
	GUICtrlSetResizing($Yp, $iStyle)
	GUICtrlSetResizing($Wp, $iStyle)
	GUICtrlSetResizing($Hp, $iStyle)
	GUICtrlSetResizing($S1, $iStyle)
	GUICtrlSetResizing($S2, $iStyle)
	GUICtrlSetResizing($S3, $iStyle)
	GUICtrlSetResizing($S4, $iStyle)

	GUICtrlSetLimit($X1, 3, 1)
	GUICtrlCreateUpdown($X1, $UDS_ARROWKEYS)
	GUICtrlSetLimit($Y1, 3, 1)
	GUICtrlCreateUpdown($Y1, $UDS_ARROWKEYS)
	GUICtrlSetLimit($W1, 3, 1)
	GUICtrlCreateUpdown($W1, $UDS_ARROWKEYS)
	GUICtrlSetLimit($H1, 3, 1)
	GUICtrlCreateUpdown($H1, $UDS_ARROWKEYS)
	GUICtrlSetLimit($Xp, 3, 1)
	GUICtrlCreateUpdown($Xp, $UDS_ARROWKEYS)
	GUICtrlSetLimit($Yp, 3, 1)
	GUICtrlCreateUpdown($Yp, $UDS_ARROWKEYS)
	GUICtrlSetLimit($Wp, 3, 1)
	GUICtrlCreateUpdown($Wp, $UDS_ARROWKEYS)
	GUICtrlSetLimit($Hp, 3, 1)
	GUICtrlCreateUpdown($Hp, $UDS_ARROWKEYS)

	; 0 = Funktion (X, Y, W, H, Name)
	; 1 = ID im Eigenschaften Fenster
	; 2 = ID im Layout Fenster
	; 3 = Hwnd des Layout Fensters
	_ArrayAdd($aPids, "Name|" & $Name & "|" & $iCtrl & "|" & $hWnd)
	$aPids[0][0] += 1
	_ArrayAdd($aPids, "X|" & $X1 & "|" & $iCtrl & "|" & $hWnd)
	$aPids[0][0] += 1
	_ArrayAdd($aPids, "Y|" & $Y1 & "|" & $iCtrl & "|" & $hWnd)
	$aPids[0][0] += 1
	_ArrayAdd($aPids, "W|" & $W1 & "|" & $iCtrl & "|" & $hWnd)
	$aPids[0][0] += 1
	_ArrayAdd($aPids, "H|" & $H1 & "|" & $iCtrl & "|" & $hWnd)
	$aPids[0][0] += 1
	_ArrayAdd($aPids, "Xp|" & $Xp & "|" & $iCtrl & "|" & $hWnd)
	$aPids[0][0] += 1
	_ArrayAdd($aPids, "Yp|" & $Yp & "|" & $iCtrl & "|" & $hWnd)
	$aPids[0][0] += 1
	_ArrayAdd($aPids, "Wp|" & $Wp & "|" & $iCtrl & "|" & $hWnd)
	$aPids[0][0] += 1
	_ArrayAdd($aPids, "Hp|" & $Hp & "|" & $iCtrl & "|" & $hWnd)
	$aPids[0][0] += 1

	; Size Buttons: A4, 16:9, 4:3, 1:1
	_ArrayAdd($aPids, "S1|" & $S1 & "|" & $iCtrl & "|" & $hWnd)
	$aPids[0][0] += 1
	_ArrayAdd($aPids, "S2|" & $S2 & "|" & $iCtrl & "|" & $hWnd)
	$aPids[0][0] += 1
	_ArrayAdd($aPids, "S3|" & $S3 & "|" & $iCtrl & "|" & $hWnd)
	$aPids[0][0] += 1
	_ArrayAdd($aPids, "S4|" & $S4 & "|" & $iCtrl & "|" & $hWnd)
	$aPids[0][0] += 1

	; _PrintFromArray($aPids)
EndFunc   ;==>Control_Properties

; 0 = Funktion (X, Y, W, H, Name)
; 1 = ID im Eigenschaften Fenster
; 2 = ID innerhalb von $aGids
; 3 = Handle vom Layout Fenster
; Control_CheckUpdate("X", 12, 21, 0x12345)
Func Control_CheckUpdate($sUpdateTyp, $iPropCtrl, $iCtrl, $hLayout)
	; ConsoleWrite("Control_CheckUpdate(" & $sUpdateTyp & ", " & $iPropCtrl & ", " & $iCtrl & ", " & $hLayout & ")" & @CRLF)

	; Layout ID heraussuchen
	Local $iLayout = -1
	For $i = 1 To $aLayouts[0][0]
		If $aLayouts[$i][$eL_Handle] = $hLayout Then
			$iLayout = $i
			ExitLoop
		EndIf
	Next
	If $iLayout = -1 Then Return

	; wenn iCtrl=0 und $sUpdateTyp=Res, dann nur Layout Resolution ändern und return
	If $iCtrl = 0 And $sUpdateTyp = "Res" Then
		Local $iRes = $aLayouts[$iLayout][$eL_Resolution]
		Local $iX = $aResolution[$iRes][1]
		Local $iY = $aResolution[$iRes][2]
		Local $aPos = WinGetPos(HWnd($hLayout))
		If Not IsArray($aPos) Then
			MsgBox($MB_ICONERROR, $sTitle, "Layout Fensterposition unbekannt?!")
			Exit
		EndIf

		; ClientArea != WinSize
		Local $iWDiff = $aPos[2] - $iX
		Local $iHDiff = $aPos[3] - $iY

		Switch GUICtrlRead($iPropCtrl)
			Case $aResolution[0][0]
				$iRes = 0
			Case $aResolution[1][0]
				$iRes = 1
			Case $aResolution[2][0]
				$iRes = 2
		EndSwitch
		$aLayouts[$iLayout][$eL_Resolution] = $iRes
		Local $iX = $aResolution[$iRes][1]
		Local $iY = $aResolution[$iRes][2]

		; update layout window
		WinMove(HWnd($hLayout), "", $aPos[0], $aPos[1], $iX + $iWDiff, $iY + $iHDiff)
		Return
	EndIf

	; Gid heraussuchen
	Local $iGid = -1
	For $i = 1 To $aGids[0][0]
		If $aGids[$i][$eG_Cid] = $iCtrl Then
			$iGid = $i
			ExitLoop
		EndIf
	Next
	If $iGid = -1 Then Return

	Local $iRes = $aLayouts[$iLayout][$eL_Resolution]
	Local $iMaxX = $aResolution[$iRes][1]
	Local $iMaxY = $aResolution[$iRes][2]

	; erstmal alte Werte annehmen...
	Local $sName = $aGids[$iGid][$eG_Name]
	Local $iX = $aGids[$iGid][$eG_X]
	Local $iY = $aGids[$iGid][$eG_Y]
	Local $iW = $aGids[$iGid][$eG_W]
	Local $iH = $aGids[$iGid][$eG_H]
	Local $iForce = 0

	#cs
		[1] Name|25|16|0x001F04A2
		[2] X|26|16|0x001F04A2
		[3] Y|27|16|0x001F04A2
		[4] W|28|16|0x001F04A2
		[5] H|29|16|0x001F04A2

		[6] Xp|30|16|0x001F04A2
		[7] Yp|31|16|0x001F04A2
		[8] Wp|32|16|0x001F04A2
		[9] Hp|33|16|0x001F04A2

		[10] S1|34|16|0x001F04A2
		[11] S2|35|16|0x001F04A2
		[12] S3|36|16|0x001F04A2
		[13] S4|37|16|0x001F04A2

		[14] Edit|46|16|0x001F04A2
		[15] Res|46|16|0x001F04A2
	#ce

	; nun einen bestimmten Wert anpassen und auch prüfen
	Local Const $iGap = $iOptionsGap
	Switch $sUpdateTyp
		Case "Xp"
			$iForce = GUICtrlRead($iPropCtrl)
			$iPropCtrl -= 4
			$iX = Ceiling($iMaxX * $iForce * 0.01)
			ContinueCase
		Case "X"
			If $iForce = 0 Then $iX = GUICtrlRead($iPropCtrl)
			If ($iX < 0) Then $iX = 0
			If ($iX + $iW > $iMaxX) Then $iX = $iMaxX - $iW
			GUICtrlSetData($iPropCtrl, $iX)
			GUICtrlSetData($iPropCtrl + 4, Int($iX * 100 / $iMaxX))
		Case "Yp"
			$iForce = GUICtrlRead($iPropCtrl)
			$iPropCtrl -= 4
			$iY = Ceiling($iMaxY * $iForce * 0.01)
			ContinueCase
		Case "Y"
			If $iForce = 0 Then $iY = GUICtrlRead($iPropCtrl)
			If ($iY < 0) Then $iY = 0
			If ($iY + $iH > $iMaxY) Then $iY = $iMaxY - $iH
			GUICtrlSetData($iPropCtrl, $iY)
			GUICtrlSetData($iPropCtrl + 4, Int($iY * 100 / $iMaxY))
		Case "Wp"
			$iForce = GUICtrlRead($iPropCtrl)
			$iPropCtrl -= 4
			$iW = Ceiling($iMaxX * $iForce * 0.01)
			ContinueCase
		Case "W"
			If $iForce = 0 Then $iW = GUICtrlRead($iPropCtrl)
			If ($iW + $iX > $iMaxX) Then $iW = $iMaxX - $iX
			If ($iW < $iGap * 2) Then $iW = $iGap * 2
			$iW = Int($iW)
			GUICtrlSetData($iPropCtrl, $iW)
			GUICtrlSetData($iPropCtrl + 4, Int($iW * 100 / $iMaxX))
		Case "Hp"
			$iForce = GUICtrlRead($iPropCtrl)
			$iPropCtrl -= 4
			$iH = Ceiling($iMaxY * $iForce * 0.01)
			ContinueCase
		Case "H"
			If $iForce = 0 Then $iH = GUICtrlRead($iPropCtrl)
			If ($iH + $iY > $iMaxY) Then $iH = $iMaxY - $iY
			If ($iH < $iGap * 2) Then $iH = $iGap * 2
			$iH = Int($iH)
			GUICtrlSetData($iPropCtrl, $iH)
			GUICtrlSetData($iPropCtrl + 4, Int($iH * 100 / $iMaxY))
		Case "S1" ; A4 bzw A4 quer
			If $iH > $iW Then
				$iW = $iH
				$iH = $iW / Sqrt(2)
			Else
				$iH = $iW
				$iW = $iH / Sqrt(2)
			EndIf
			GUICtrlSetData($iPropCtrl - 6, Int($iW))
			GUICtrlSetData($iPropCtrl - 5, Int($iH))
			GUICtrlSetData($iPropCtrl - 2, Int($iW * 100 / $iMaxX))
			GUICtrlSetData($iPropCtrl - 1, Int($iH * 100 / $iMaxY))
		Case "S2" ; 16:9 bzw 9:16
			If $iH > $iW Then
				$iW = $iH
				$iH = $iW / (16 / 9)
			Else
				$iH = $iW
				$iW = $iH / (16 / 9)
			EndIf
			GUICtrlSetData($iPropCtrl - 7, Int($iW))
			GUICtrlSetData($iPropCtrl - 6, Int($iH))
			GUICtrlSetData($iPropCtrl - 3, Int($iW * 100 / $iMaxX))
			GUICtrlSetData($iPropCtrl - 2, Int($iH * 100 / $iMaxY))
		Case "S3" ; 4:3 / 3:4
			If $iH > $iW Then
				$iW = $iH
				$iH = $iW / (4 / 3)
			Else
				$iH = $iW
				$iW = $iH / (4 / 3)
			EndIf
			GUICtrlSetData($iPropCtrl - 8, Int($iW))
			GUICtrlSetData($iPropCtrl - 7, Int($iH))
			GUICtrlSetData($iPropCtrl - 4, Int($iW * 100 / $iMaxX))
			GUICtrlSetData($iPropCtrl - 3, Int($iH * 100 / $iMaxY))
		Case "S4" ; 1:1
			Local $iTemp = $iH + $iW
			$iH = $iTemp / 2
			$iW = $iTemp / 2
			GUICtrlSetData($iPropCtrl - 9, Int($iW))
			GUICtrlSetData($iPropCtrl - 8, Int($iH))
			GUICtrlSetData($iPropCtrl - 5, Int($iW * 100 / $iMaxX))
			GUICtrlSetData($iPropCtrl - 4, Int($iH * 100 / $iMaxY))
		Case "Name"
			$sName = GUICtrlRead($iPropCtrl)
			GUICtrlSetData($iCtrl, $sName)
	EndSwitch

	; Änderungen übernehmen
	$aGids[$iGid][$eG_Name] = $sName
	$aGids[$iGid][$eG_X] = $iX
	$aGids[$iGid][$eG_Y] = $iY
	$aGids[$iGid][$eG_W] = $iW
	$aGids[$iGid][$eG_H] = $iH
	GUICtrlSetPos($iCtrl, $iX, $iY, $iW, $iH)

	; wir haben was geändert
	$aLayouts[$iLayout][$eL_State] = "M"
	Layout_Control_SetTip($iCtrl, $iGid)
EndFunc   ;==>Control_CheckUpdate


; #FUNCTION# ====================================================================================================================
; Name ..........: Layout_Properties
; Description ...: Fenster für Eigenschaften eines Layouts erstellen/anzeigen
; Syntax ........: Layout_Properties(Layout ID)
; Parameters ....: Handle: Handle des Layouts wo das Control ist, iGid=0 meint Layout Eigenschaften
; Return values .: -
; Author ........: Tino Reichardt
; Modified ......: 14.08.2015
; ===============================================================================================================================
Func Layout_Properties($hWnd)

	; Eigenschaften schon da?
	For $i = 1 To $aProperties[0][0]
		If $aProperties[$i][$eP_LHandle] = $hWnd And $aProperties[$i][$eP_Cid] = 0 Then
			Local $hProp = HWnd($aProperties[$i][$eP_Handle])
			WinActivate($hProp)
			WinFlash($hProp, "", 2)
			Return
		EndIf
	Next

	Local $iLayout = -1
	For $i = 1 To $aLayouts[0][0]
		If $aLayouts[$i][$eL_Handle] = $hWnd Then
			$iLayout = $i
			ExitLoop
		EndIf
	Next
	If $iLayout = -1 Then Return

	Local $hWin = GUICreate(" Eigenschaften von: " & $aLayouts[$iLayout][$eL_File], 300, 55, -1, -1, -1, $iWindowStyle, $hGUI)

	; LHandle, Handle, Gid
	_ArrayAdd($aProperties, $hWnd & "|" & $hWin & "|" & 0)
	$aProperties[0][0] += 1
	GUISetState(@SW_SHOW, $hWin)

	Local $idComboBox, $sRes
	GUICtrlCreateLabel("Auflösung:", 8, 11, 54, 17)
	$idComboBox = GUICtrlCreateCombo("", 64, 8, 220, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
	$sRes = $aResolution[0][0] & "|" & $aResolution[1][0] & "|" & $aResolution[2][0]
	GUICtrlSetData($idComboBox, $sRes, $aResolution[0][0])

	; 0 = Funktion (X, Y, W, H, Name)
	; 1 = ID im Eigenschaften Fenster
	; 2 = ID im Layout Fenster
	; 3 = Hwnd des Layout Fensters
	_ArrayAdd($aPids, "Res|" & $idComboBox & "|" & 0 & "|" & HWnd($hWnd))
	$aPids[0][0] += 1

EndFunc   ;==>Layout_Properties

; #FUNCTION# ====================================================================================================================
; Name ..........: CloseSomeWindow
; Description ...: Prüfen ob Fenster existiert und wenn ja, dann schließen
; Syntax ........: CloseSomeWindow(Handle)
; Parameters ....: Handle: Handle des zu schließenden Fensters
; Return values .: -
; Author ........: Tino Reichardt
; Modified ......: 18.08.2015
; ===============================================================================================================================
Func CloseSomeWindow($hWnd)
	Local $i

	; ein Eigenschaften Fenster?
	For $i = 1 To $aProperties[0][0]
		If $aProperties[$i][$eP_Handle] = $hWnd Then
			Layout_Delete_PControl($aProperties[$i][$eP_Cid])
			GUIDelete($aProperties[$i][$eP_Handle])
			_ArrayDelete($aProperties, $i)
			$aProperties[0][0] -= 1
			Return
		EndIf
	Next

	; ein Layout Fenster
	For $i = 1 To $aLayouts[0][0]
		If $aLayouts[$i][$eL_Handle] = $hWnd Then
			Local $sName = $aLayouts[$i][$eL_File]
			If $aLayouts[$i][$eL_State] = "M" Then
				If MsgBox(BitOR($MB_YESNO, $MB_ICONQUESTION), $sTitle, 'Soll das geänderte Layout "' & $sName & '" gespeichert werden?') <> $IDYES Then
					Layout_Save($hWnd, 1)
				EndIf
			EndIf

			; Eigenschaften zu einem Control und/oder Layout schließen
			For $j = $aProperties[0][0] To 1 Step -1
				If $aProperties[$j][$eP_LHandle] = $hWnd Then
					CloseSomeWindow($aProperties[$j][$eP_Handle])
				EndIf
			Next

			; Gid's des Layouts löschen...
			For $j = $aGids[0][0] To 1 Step -1
				If $aGids[$j][$eG_LHandle] = $hWnd Then
					_ArrayDelete($aGids, $j)
					$aGids[0][0] -= 1
				EndIf
			Next

			; am Ende nun auch das Layout...
			GUIDelete($aLayouts[$i][$eL_Handle])
			_ArrayDelete($aLayouts, $i)
			$aLayouts[0][0] -= 1
			ExitLoop
		EndIf
	Next

	; keine offenen Layouts mehr da, also Buttons aus
	If $aLayouts[0][0] = 0 Then
		ToolBox_DisableButtons()
		WinActivate($hGUI)
	EndIf
EndFunc   ;==>CloseSomeWindow

; #FUNCTION# ====================================================================================================================
; Name ..........: GuiCtrlSetOnTop
; Syntax ........: GuiCtrlSetOnTop(Control hWnd)
; Modified ......: 26.08.2015
Func GuiCtrlSetOnTop($hWnd)
	Return _WinAPI_SetWindowPos($hWnd, $HWND_BOTTOM, 0, 0, 0, 0, $SWP_NOMOVE + $SWP_NOSIZE + $SWP_NOCOPYBITS)
	;ConsoleWrite("r=" & $r & " $hWnd=" & $hWnd & " msg=" & _WinAPI_GetLastErrorMessage() & @CRLF)
EndFunc   ;==>GuiCtrlSetOnTop

; #FUNCTION# ====================================================================================================================
; Name ..........: GuiCtrlIsChecked
; Syntax ........: GuiCtrlIsChecked(Control ID)
; Modified ......: 21.10.2015
Func GuiCtrlIsChecked($idControlID)
	Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc   ;==>GuiCtrlIsChecked

; #FUNCTION# ====================================================================================================================
; Name ..........: WM_NOTIFY
; Description ...: catch ToolBarClicks
; Syntax ........: WM_NOTIFY()
; Author ........: Tino Reichardt
; Modified ......: 17.08.2015
; ===============================================================================================================================
Func WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam, $lParam
	;ConsoleWrite("WM_NOTIFY $hWnd=" & $hWnd & " $iMsg=" & $iMsg & " $wParam=" & $wParam & " $lParam=" & $lParam & @CRLF)

	Local Const $tagNMMOUSE = "HWND hwndFrom; UINT_PTR idFrom; INT code; ULONG_PTR dwItemSpec; ULONG_PTR dwItemData; int pt[2]; LONG_PTR dwHitInfo;"
	Local $NMHDR = DllStructCreate($tagNMMOUSE, $lParam)
	Local $nID = DllStructGetData($NMHDR, "hwndFrom")
	Switch $nID
		Case $iToolBar
			Switch DllStructGetData($NMHDR, "code")
				Case $NM_CLICK
					GUICtrlSendToDummy($iToolBarClick, DllStructGetData($NMHDR, "dwItemSpec"))
			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY

; #FUNCTION# ====================================================================================================================
; Name ..........: WM_COMMAND
; Description ...: catch double click on gui controls and save it via global variable
; Syntax ........: WM_COMMAND()
; Author ........: Tino Reichardt
; Modified ......: 17.08.2015
; ===============================================================================================================================
Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam, $lParam
	;ConsoleWrite("WM_COMMAND $hWnd=" & $hWnd & " $iMsg=" & $iMsg & " $wParam=" & $wParam & " $lParam=" & $lParam & @CRLF)

	Local $nID = BitAND($wParam, 0xFFFF)
	Local $nNotifyCode = BitShift($wParam, 16)

	; double click
	If $nNotifyCode = 1 Then
		GUICtrlSendToDummy($iDoubleClickControl, $nID)
		Return $GUI_RUNDEFMSG
	EndIf

	; WM_COMMAND $hWnd=0x00B403A0(control) $iMsg=273(id) $wParam=0x000003E9(enum)
	If $iMsg = 273 Then
		Local $hMenu = HWnd(GUICtrlRead($iContextMenuOf))
		GUICtrlSendToDummy($iContextMenuOf, 0)
		If $hMenu = $hGUI Then
			Switch $wParam
				Case $eCM_Info
					Local $sText = ""
					$sText &= "Copyright 2015 - 2016, Tino Reichardt" & @CRLF & @CRLF
					$sText &= "Version: " & $sVersion & " (" & FileGetVersion(@ScriptFullPath) & ") " & @CRLF
					MsgBox(BitOR($MB_OK, $MB_ICONINFORMATION), $sTitle, $sText)
				Case $eCM_Close
					ToolBox_Exit()
			EndSwitch
			Return $GUI_RUNDEFMSG
		EndIf
		;ConsoleWrite("$hMenu =" & $hMenu & @CRLF)
		For $i = 1 To $aLayouts[0][0]
			If $aLayouts[$i][$eL_Handle] = $hMenu Then
				Switch $wParam
					Case $eCM_Save
						;ConsoleWrite("save $hWnd=" & $hWnd & " $iMsg=" & $iMsg & " $wParam=" & $wParam & " $lParam=" & $lParam & @CRLF)
						Layout_Save($hMenu, 1)
						Return $GUI_RUNDEFMSG
					Case $eCM_SaveAs
						Layout_Save($hMenu)
						Return $GUI_RUNDEFMSG
					Case $eCM_Properties
						Layout_Properties($hMenu)
						Return $GUI_RUNDEFMSG
					Case $eCM_Close
						CloseSomeWindow($hMenu)
						Return $GUI_RUNDEFMSG
				EndSwitch
			EndIf
		Next
		For $i = 1 To $aGids[0][0]
			If $aGids[$i][$eG_CHandle] = $hMenu Then
				Switch $wParam
					Case $eCM_CProperties
						Control_Properties($aGids[$i][$eG_Cid])
						$sMyState = ""
						Return $GUI_RUNDEFMSG
					Case $eCM_Delete
						Layout_Delete_Control($i)
						$sMyState = ""
						Return $GUI_RUNDEFMSG
				EndSwitch
			EndIf
		Next
	EndIf

	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_COMMAND

; #FUNCTION# ====================================================================================================================
; Name ..........: WM_LBUTTONDBLCLK
; Description ...: catch double click on the client area of layout window
; Syntax ........: WM_LBUTTONDBLCLK()
; Author ........: Tino Reichardt
; Modified ......: 17.08.2015
; ===============================================================================================================================
Func WM_LBUTTONDBLCLK($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam, $lParam
	GUICtrlSendToDummy($iDoubleClickLayout, $hWnd)
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_LBUTTONDBLCLK

; #FUNCTION# ====================================================================================================================
; Name ..........: WM_CONTEXTMENU
; Description ...: catch right click on some area
; Syntax ........: WM_CONTEXTMENU()
; Author ........: Tino Reichardt
; Modified ......: 11.09.2015
; ===============================================================================================================================
Func WM_CONTEXTMENU($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam, $lParam
	;ConsoleWrite("WM_CONTEXTMENU $hWnd=" & $hWnd & " $iMsg=" & $iMsg & " $wParam=" & $wParam & " $lParam=" & $lParam & @CRLF)

	If $wParam = $hGUI Then
		Local $hMenu = _GUICtrlMenu_CreatePopup()
		_GUICtrlMenu_InsertMenuItem($hMenu, 0, "Info", $eCM_Info)
		_GUICtrlMenu_InsertMenuItem($hMenu, 1, "")
		_GUICtrlMenu_InsertMenuItem($hMenu, 2, "Schließen", $eCM_Close)
		_GUICtrlMenu_TrackPopupMenu($hMenu, $hGUI)
		_GUICtrlMenu_DestroyMenu($hMenu)
		GUICtrlSendToDummy($iContextMenuOf, $wParam)
		Return $GUI_RUNDEFMSG
	EndIf

	; Rechte Maus auf Layout Fenster?
	Local $iLayout = -1
	For $i = 1 To $aLayouts[0][0]
		If $aLayouts[$i][$eL_Handle] = $wParam Then
			$iLayout = $i
			ExitLoop
		EndIf
	Next
	If $iLayout > 0 Then
		Local $hMenu = _GUICtrlMenu_CreatePopup()
		_GUICtrlMenu_InsertMenuItem($hMenu, 0, "Speichern", $eCM_Save)
		_GUICtrlMenu_InsertMenuItem($hMenu, 1, "Speichern unter", $eCM_SaveAs)
		_GUICtrlMenu_InsertMenuItem($hMenu, 2, "Eigenschaften", $eCM_Properties)
		_GUICtrlMenu_InsertMenuItem($hMenu, 3, "")
		_GUICtrlMenu_InsertMenuItem($hMenu, 4, "Schließen", $eCM_Close)
		_GUICtrlMenu_TrackPopupMenu($hMenu, $hGUI)
		_GUICtrlMenu_DestroyMenu($hMenu)
		GUICtrlSendToDummy($iContextMenuOf, $wParam)
		Return $GUI_RUNDEFMSG
	EndIf

	; Rechte Maus auf Control?
	Local $iGid = -1
	For $i = 1 To $aGids[0][0]
		If $aGids[$i][$eG_CHandle] = $wParam Then
			$iGid = $i
			ExitLoop
		EndIf
	Next
	If $iGid > 0 Then
		$sMyState = "Right"
		GUISetCursor(2)
		Local $hMenu = _GUICtrlMenu_CreatePopup()
		_GUICtrlMenu_InsertMenuItem($hMenu, 0, "Eigenschaften", $eCM_CProperties)
		_GUICtrlMenu_InsertMenuItem($hMenu, 1, "Löschen", $eCM_Delete)
		_GUICtrlMenu_TrackPopupMenu($hMenu, $hGUI)
		_GUICtrlMenu_DestroyMenu($hMenu)
		GUICtrlSendToDummy($iContextMenuOf, $aGids[$i][$eG_CHandle])
		Return $GUI_RUNDEFMSG
	EndIf

	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_CONTEXTMENU

; Received New Files to Open...
Func WM_COPYDATA($hWnd, $msg, $wParam, $lParam)
	Local $COPYDATA = DllStructCreate('Ptr;DWord;Ptr', $lParam)
	Local $sFileLen = DllStructGetData($COPYDATA, 2)
	Local $CmdStruct = DllStructCreate('Char[255]', DllStructGetData($COPYDATA, 3))
	Local $sFile = StringLeft(DllStructGetData($CmdStruct, 1), $sFileLen)
	Layout_Open($sFile)
EndFunc   ;==>WM_COPYDATA

; #FUNCTION# ====================================================================================================================
; Name ..........: Msg
; Description ...: Gibt gewählten Text für die aktuelle Sprache zurück
; Syntax ........: Msg()
; Author ........: Tino Reichardt
; Modified ......: 12.04.2015
; ===============================================================================================================================
Func Msg($sMsg, $p1 = "", $p2 = "", $p3 = "")
	; \n -> @crlf
	$sMsg = StringReplace($sMsg, "\n", @CRLF, 0, 1)

	If StringLen($p1) > 0 Then
		$sMsg = StringReplace($sMsg, "%1", $p1, 0, 1)
	Else
		Return $sMsg
	EndIf

	If StringLen($p2) > 0 Then
		$sMsg = StringReplace($sMsg, "%2", $p2, 0, 1)
	Else
		Return $sMsg
	EndIf

	If StringLen($p3) > 0 Then
		$sMsg = StringReplace($sMsg, "%3", $p3, 0, 1)
	Else
		Return $sMsg
	EndIf
EndFunc   ;==>Msg

; wenn es schon läuft, Dateien an die vorhandene ToolBox übergeben...
If _Singleton($sTitle & " - ToolBox", 1) = 0 Then
	Local $hGUI = GUICreate("No New One!")
	Local $hMain = WinGetHandle($sTitle & " - ToolBox")
	Local $aCmdLine = _WinAPI_CommandLineToArgv($CmdLineRaw)
	For $i = 1 To $aCmdLine[0]
		Local $sFile = $aCmdLine[$i]
		If Not FileExists($sFile) Then ContinueLoop
		Local $CmdStruct = DllStructCreate('Char[' & StringLen($sFile) + 1 & ']')
		DllStructSetData($CmdStruct, 1, $sFile)
		Local $COPYDATA = DllStructCreate('Ptr;DWord;Ptr')
		DllStructSetData($COPYDATA, 1, 1)
		DllStructSetData($COPYDATA, 2, StringLen($sFile) + 1)
		DllStructSetData($COPYDATA, 3, DllStructGetPtr($CmdStruct))
		DllCall('User32.dll', 'None', 'SendMessage', 'HWnd', $hMain, _
				'Int', $WM_COPYDATA, 'HWnd', $hGUI, _
				'Ptr', DllStructGetPtr($COPYDATA))
	Next
	Exit
EndIf

; Main()
ToolBox_Init()

If @Compiled Then
	; Parameter werden als zu öffnende DS Layouts interpretiert
	Local $aCmdLine = _WinAPI_CommandLineToArgv($CmdLineRaw)
	For $i = 1 To $aCmdLine[0]
		If FileExists($aCmdLine[$i]) Then Layout_Open($aCmdLine[$i])
	Next
EndIf

Local $iLoop = 0
While 1
	Local $aMsg = GUIGetMsg(1)
	#cs
		If $aMsg[0] > 0 Then
		$iLoop += 1
		ConsoleWrite("LOOP: " & $iLoop & @CRLF)
		_PrintFromArray($aMsg)
		EndIf
		$aArray[0] = 0 or Event ID or Control ID
		$aArray[1] = The window handle the event is from
		$aArray[2] = The control handle the event is from (if applicable)
		$aArray[3] = The current X position of the mouse cursor (relative to the GUI window)
		$aArray[4] = The current Y position of the mouse cursor (relative to the GUI window)
	#ce

	Switch $aMsg[0]
		Case 0
			ContinueLoop
		Case $iDoubleClickControl
			; Eigenschaften des Controls
			Control_Properties(GUICtrlRead($iDoubleClickControl))
			ContinueLoop
		Case $iDoubleClickLayout
			; Eigenschaften des Layouts
			Layout_Properties(GUICtrlRead($iDoubleClickLayout))
			ContinueLoop
		Case $GUI_EVENT_PRIMARYUP ; -8
			ContinueLoop
		Case $GUI_EVENT_SECONDARYDOWN ; -9
			ContinueLoop
		Case $GUI_EVENT_SECONDARYUP ; -10
			$sMyState = ""
			ContinueLoop
		Case $GUI_EVENT_MOUSEMOVE ; -11
			; wenn im Context Menü, dann erstmal warten, was der Nutzer da klickert...
			If $sMyState = "Right" Then ContinueLoop

			; Maus wird bewegt, kann sein, das das verarbeitet werden muss...
			Layout_Move_Control($aMsg[1])
			; ConsoleWrite("Layout_Move_Control() ende ..." & @CRLF)
			ContinueLoop
		Case $GUI_EVENT_PRIMARYDOWN ; -7
			Switch $sMyState
				; neues Control erstellen...
				Case "SlideShow", "Uhr", "Webseite", "Ticker", "Newsfeed", "Wetter"
					$hLastLayout = $aMsg[1]
					GUISwitch($hLastLayout)
					Layout_Create_Control($aMsg[1], $sMyState)
					$sMyState = ""
			EndSwitch
			ContinueLoop
		Case $iPaypalButton
			ShellExecute("https://www.paypal.me/TinoReichardt")
		Case $GUI_EVENT_CLOSE, $iCloseButton
			If $aMsg[1] = $hGUI Then
				ToolBox_Exit()
				ContinueLoop
			EndIf
			CloseSomeWindow($aMsg[1])
		Case $aGUI_Buttons[1]
			$sMyState = "SlideShow"
		Case $aGUI_Buttons[2]
			$sMyState = "Uhr"
		Case $aGUI_Buttons[3]
			$sMyState = "Webseite"
		Case $aGUI_Buttons[4]
			$sMyState = "Newsfeed"
		Case $aGUI_Buttons[5]
			$sMyState = "Ticker"
		Case $aGUI_Buttons[6]
			$sMyState = "Wetter"
		Case $iToolBarClick
			Switch GUICtrlRead($iToolBarClick)
				Case $eTB_New
					$hLastLayout = Layout_New()
					GUISwitch($hLastLayout)
				Case $eTB_Open
					$hLastLayout = Layout_Open()
					GUISwitch($hLastLayout)
				Case $eTB_Save
					Layout_Save($hLastLayout)
			EndSwitch
		Case Else
			; da gibts zu viele von ... (6 = focus oder so...)
			If $aMsg[1] = 6 Then ContinueLoop

			; prüfen, on ein Wert in einem Eigenschaften Fenster geändert wurde
			For $i = 1 To $aPids[0][0]
				If $aPids[$i][$eX_Pid] = $aMsg[0] Then
					Control_CheckUpdate($aPids[$i][$eX_Func], $aPids[$i][$eX_Pid], $aPids[$i][$eX_Cid], $aPids[$i][$eX_LHandle])
					ExitLoop
				EndIf
			Next
			;ConsoleWrite("Big Loop:" & @CRLF)
			;_PrintFromArray($aMsg)
	EndSwitch
WEnd
