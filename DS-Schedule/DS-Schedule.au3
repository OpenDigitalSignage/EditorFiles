#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=DS-Schedule.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Comment=Homepage: http://www.mcmilk.de/projects/DS-Schedule/
#AutoIt3Wrapper_Res_Description=Digital Signage Background Daemon - Schedule
#AutoIt3Wrapper_Res_Fileversion=0.4.0.0
#AutoIt3Wrapper_Res_ProductVersion=0.4.0.0
#AutoIt3Wrapper_Res_LegalCopyright=© 2016 Tino Reichardt
#AutoIt3Wrapper_Res_Language=1031
#AutoIt3Wrapper_Res_Field=Productname|DS-Schedule
#AutoIt3Wrapper_Res_Field=CompanyName|Tino Reichardt
#AutoIt3Wrapper_Res_Field=Compile Date|%date% %time%
#AutoIt3Wrapper_Run_After=mpress -q -r -s DS-Schedule.exe
#AutoIt3Wrapper_Run_After=signtool sign /v /tr http://time.certum.pl/ /f DS-Schedule.p12 /p pass DS-Schedule.exe
#AutoIt3Wrapper_Run_Tidy=y
#AutoIt3Wrapper_Tidy_Stop_OnError=n
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/pe /sf /sv /rm /mi 6
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#cs
	Copyright © 2016 Tino Reichardt

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License Version 2, as
	published by the Free Software Foundation.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
#ce

; ctime: /TR 2016-08-05
; mtime: /TR 2016-08-25

#include <Array.au3>
#include <AutoItConstants.au3>
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <Date.au3>
#include <File.au3>
#include <Misc.au3>
#include <GUIConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiComboBox.au3>
#include <GuiDateTimePicker.au3>
#include <GuiListView.au3>
#include <GuiTab.au3>
#include <GuiMenu.au3>
#include <GuiToolbar.au3>
#include <GuiButton.au3>
#include <GuiRichEdit.au3>
#include <GuiImageList.au3>
#include <String.au3>
#include <StaticConstants.au3>
#include <ToolbarConstants.au3>
#include <WindowsConstants.au3>
#include <WinAPIShPath.au3>

; Titel, Name und so weiter definieren...
Global Const $sTitle = "Digital Signage - Zeitplan"
Global Const $sVersion = "0.1"
Global Const $sAppName = "DS-Schedule"
Global Const $sLangPath = @ScriptDir & "\" & $sAppName & "\" & "Lang"
Global $sDSBS_Filename = "DS-Schedule.dsbs"
Global $sLayoutPath = ""

#include "DS-Schedule_Lang.au3"

Opt("MustDeclareVars", 1)
Opt("TrayMenuMode", 1 + 2 + 4)
Opt("TrayIconHide", 1)
Opt("TrayAutoPause", 0)
Opt("WinTitleMatchMode", 2)

; global variables
Global $gGuiStyle = BitOR($WS_CAPTION, 0)
Global $gGuiExStyle = -1
Global $gGuiListStyle = $LVS_REPORT
Global $gGuiListExStyle = BitOR($WS_EX_CLIENTEDGE, $LVS_EX_CHECKBOXES, $LVS_EX_HEADERDRAGDROP, $LVS_EX_FULLROWSELECT) ; $LVS_EX_GRIDLINES

; Context Menü
Global Enum $eCM_Add = 1000, $eCM_Edit, $eCM_Delete, $eCM_Import

Global $hGUI
Global $idButtonInfo
Global $idButtonOkay
Global $idButtonCancel
Global $idButtonSave

; DummyControls
Global $idContextMenuOf
Global $idEditControl

; Checkboxes in ListViews are a bit tricky
Global $idCheckControl
Global $tCheckbox
Global Const $tagCheckbox = "hwnd hWndFrom;uint Item;uint NewState;"

; DateTime Controls
Global $hDateFrom = 0xffffff01, $hDateTo = 0xffffff02
Global $sDateFrom = "", $sDateTo = ""
Global $sTimeFrom = "", $sTimeTo = ""

Global $aWeekplan[0][1 + 4] ; ID|Aktiv|Wochentag|Zeitraum|Layout (Zeitraum HHMM-HHMM)
Global $aOfftimes[0][1 + 3] ; ID|Aktiv|Zeitraum|Beschreibung (Zeitraum YYYYmmdd-YYYYmmdd)
Global $aEvents[0][1 + 5] ; ID|Aktiv|Tag|Zeitraum|Layout|Beschreibung (Tag YYYYmmdd, Zeitraum HHMM-YYYY)
Global $aMACs[0][1 + 3] ; ID|Aktiv|MAC Adresse|Beschreibung

; Tabs
Global $idTab

; ListViews, ID's and their Hwnds
Global Enum $eLV_Weekplan = 0, $eLV_Offtimes, $eLV_Events, $eLV_Macs
Global $idListWeekplan, $idListOfftimes, $idListEvents, $idListMacs
Global $hListWeekplan, $hListOfftimes, $hListEvents, $hListMacs
Global $iInvalid

; #FUNCTION# ====================================================================================================================
; Name ..........: InitMainWindow
; Description ...: init the main gui and it's controls
; Syntax ........: InitMainWindow()
; Author ........: Tino Reichardt
; Modified ......: 12.08.2016
; ===============================================================================================================================
Func InitMainWindow()
	$hGUI = GUICreate($sTitle, 552, 447, 341, 297, $gGuiStyle, $gGuiExStyle)

	; dummy controls
	$idContextMenuOf = GUICtrlCreateDummy()
	$idEditControl = GUICtrlCreateDummy()
	$idCheckControl = GUICtrlCreateDummy()

	GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")
	GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")
	GUIRegisterMsg($WM_CONTEXTMENU, "WM_CONTEXTMENU")

	; MsgBox(0, Msg($mButtons[0]), "lala")
	$idButtonInfo = GUICtrlCreateButton("Info", 6, 415, 100, 25)
	$idButtonOkay = GUICtrlCreateButton("OK", 232, 415, 100, 25)
	$idButtonCancel = GUICtrlCreateButton("Abbrechen", 338, 415, 100, 25)
	$idButtonSave = GUICtrlCreateButton("Übernehmen", 444, 415, 100, 25)

	GUICtrlCreateLabel("Zeitplan für die Anzeigetafeln", 7, 15, 418, 41)
	GUICtrlSetFont(-1, 24, 400, 0, "MS Sans Serif")

	; Tabs erstellen
	$idTab = GUICtrlCreateTab(7, 65, 540, 343)

	GUICtrlCreateTabItem("Wochenplan")
	GUICtrlCreateGroup("Beschreibung", 16, 324, 521, 73)
	GUICtrlCreateLabel("Hier werden die Standard Layouts sowie deren Einschaltzeiten definiert.", 24, 340, 501, 17 * 2)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$idListWeekplan = GUICtrlCreateListView("Aktiv|Wochentag|Layout|Zeitraum", 16, 96, 521, 222, $gGuiListStyle, $gGuiListExStyle)
	$hListWeekplan = GUICtrlGetHandle($idListWeekplan)
	GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 1, 120)
	GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 2, 160)
	GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 3, 160)

	GUICtrlCreateTabItem("Ausschaltzeiten")
	GUICtrlCreateGroup("Beschreibung", 16, 324, 521, 73)
	GUICtrlCreateLabel("Hier definiert man Zeiträume in denen die Anzeige nicht eingeschaltet werden soll. Beispielsweise Ferien an Schulen. Ausnahme: Veranstaltungen!", 24, 340, 501, 17 * 2)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$idListOfftimes = GUICtrlCreateListView("Aktiv|Zeitraum|Beschreibung", 16, 96, 521, 222, $gGuiListStyle, $gGuiListExStyle)
	$hListOfftimes = GUICtrlGetHandle($idListOfftimes)
	GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 1, 160)
	GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 2, 220)

	GUICtrlCreateTabItem("Veranstaltungen")
	GUICtrlCreateGroup("Beschreibung", 16, 324, 521, 73)
	GUICtrlCreateLabel("Hier können Veranstaltungen definiert werden. Diese haben eine höhe Priorität als die Ausschaltzeiten sowie dem Wochenplan.", 24, 340, 501, 17 * 2)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$idListEvents = GUICtrlCreateListView("Aktiv|Layout|Zeitraum|Beschreibung", 16, 96, 521, 222, $gGuiListStyle, $gGuiListExStyle)
	$hListEvents = GUICtrlGetHandle($idListEvents)
	GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 1, 140)
	GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 2, 150)
	GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 3, 160)

	GUICtrlCreateTabItem("MAC Adressen")
	GUICtrlCreateGroup("Beschreibung", 16, 324, 521, 73)
	GUICtrlCreateLabel("Hier werden die MAC Adressen der Geräte eingetragen, welche über diesen Zeitplan gesteuert werden sollen.", 24, 340, 501, 17 * 2)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$idListMacs = GUICtrlCreateListView("Aktiv|MAC Adresse|Beschreibung", 16, 96, 521, 222, $gGuiListStyle, $gGuiListExStyle)
	$hListMacs = GUICtrlGetHandle($idListMacs)
	GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 1, 120)
	GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 2, 240)

	; Tabs fertig...
	GUICtrlCreateTabItem("")
	GUISetState(@SW_SHOW)
EndFunc   ;==>InitMainWindow

; #FUNCTION# ====================================================================================================================
; Name ..........: DayOfWeek
; Syntax ........: DayOfWeek()
; Description ...: in:  1..7
; ...............: out: Montag..Sonntag
; Author ........: Tino Reichardt
; Modified ......: 12.08.2016
; ===============================================================================================================================
Func DayOfWeek($iDay)
	If $iDay = 7 Then Return _DateDayOfWeek(1, $DMW_LOCALE_LONGNAME)
	Return _DateDayOfWeek($iDay + 1, $DMW_LOCALE_LONGNAME)
EndFunc   ;==>DayOfWeek

; #FUNCTION# ====================================================================================================================
; Name ..........: GetTimeValue
; Syntax ........: GetTimeValue($iHHMM, $iDatePrefix = 1)
; Description ...: in:  "HHMM"
; ...............: out: "YYYY/mm/dd HH:MM"
; Author ........: Tino Reichardt
; Modified ......: 16.08.2016
; ===============================================================================================================================
Func GetTimeValue($iHHMM, $iDatePrefix = 1)
	Local $sDate = ""
	If $iDatePrefix = 1 Then $sDate = "2005/01/01 "
	If ($iHHMM = -1) Or (StringLen($iHHMM) <> 4) Then Return $sDate & "10:00"
	Return $sDate & StringLeft($iHHMM, 2) & ":" & StringRight($iHHMM, 2)
EndFunc   ;==>GetTimeValue

; #FUNCTION# ====================================================================================================================
; Name ..........: GetIniTimeValue
; Syntax ........: GetIniTimeValue($iTime1, $iTime2)
; Description ...: in:  "HH:MM", "HH:MM"
; ...............: out: "HHMM-HHMM"
; Author ........: Tino Reichardt
; Modified ......: 16.08.2016
; ===============================================================================================================================
Func GetIniTimeValue($iTime1, $iTime2)
	Local $sReturn = StringLeft($iTime1, 2) & StringRight($iTime1, 2)
	$sReturn &= "-" & StringLeft($iTime2, 2) & StringRight($iTime2, 2)
	; ConsoleWrite("GetIniTimeValue() return=" & $sReturn & @CRLF)
	Return $sReturn
EndFunc   ;==>GetIniTimeValue

; #FUNCTION# ====================================================================================================================
; Name ..........: GetIniDateValue
; Syntax ........: GetIniDateValue($iDate)
; Description ...: in:  "YYYY/mm/dd HH:MM"
; ...............: out: "YYYYmmdd"
; Author ........: Tino Reichardt
; Modified ......: 19.08.2016
; ===============================================================================================================================
Func GetIniDateValue($iDate)
	Local $sReturn = StringLeft($iDate, 4) & StringMid($iDate, 6, 2) & StringMid($iDate, 9, 2)
	; ConsoleWrite("GetIniDateValue() return=" & $sReturn & @CRLF)
	Return $sReturn
EndFunc   ;==>GetIniDateValue

; #FUNCTION# ====================================================================================================================
; Name ..........: GetDateValue
; Syntax ........: GetDateValue($iYYYYmmdd)
; Description ...: in:  "YYYYmmdd"
; ...............: out: "YYYY/mm/dd"
; Author ........: Tino Reichardt
; Modified ......: 16.08.2016
; ===============================================================================================================================
Func GetDateValue($iYYYYmmdd)
	If ($iYYYYmmdd = -1) Or (StringLen($iYYYYmmdd) <> 8) Then Return "2005/01/01"
	Return StringLeft($iYYYYmmdd, 4) & "/" & StringMid($iYYYYmmdd, 5, 2) & "/" & StringRight($iYYYYmmdd, 2)
EndFunc   ;==>GetDateValue

; #FUNCTION# ====================================================================================================================
; Name ..........: GetDateTimeValue
; Syntax ........: GetDateTimeValue($iYYYYmmdd, $iHHMM)
; Description ...: in:  "$iYYYYmmdd", "HHMM"
; ...............: out: "YYYY/mm/dd HH:MM"
; Author ........: Tino Reichardt
; Modified ......: 18.08.2016
; ===============================================================================================================================
Func GetDateTimeValue($iYYYYmmdd, $iHHMM)
	Local $sDate = GetDateValue($iYYYYmmdd)
	Local $sTime = GetTimeValue($iHHMM, 0)
	; ConsoleWrite("GetDateTimeValue = " & $sDate & " " & $sTime & @CRLF)
	Return $sDate & " " & $sTime
EndFunc   ;==>GetDateTimeValue

; #FUNCTION# ====================================================================================================================
; Name ..........: GetHumanDate
; Syntax ........: GetHumanDate($iYYYYmmdd)
; Description ...: in:  "YYYYmmdd"
; ...............: out: "dd.mm.YYYY"
; Author ........: Tino Reichardt
; Modified ......: 16.08.2016
; ===============================================================================================================================
Func GetHumanDate($iYYYYmmdd)
	If ($iYYYYmmdd = -1) Or (StringLen($iYYYYmmdd) <> 8) Then Return "01.01.2005"
	Return StringRight($iYYYYmmdd, 2) & "." & StringMid($iYYYYmmdd, 5, 2) & "." & StringLeft($iYYYYmmdd, 4)
EndFunc   ;==>GetHumanDate

; #FUNCTION# ====================================================================================================================
; Name ..........: GetHumanDateTime
; Description ...: returns a Date Time Value in this format:
; Description ...: in:  "YYYYmmdd", "HHMM-HHMM"
; ...............: out: "dd.mm.YYYY, HH:MM - HH:MM"
; Syntax ........: GetHumanDateTime($iYYYYmmdd, $iHHMM, $iHHMM)
; Author ........: Tino Reichardt
; Modified ......: 16.08.2016
; ===============================================================================================================================
Func GetHumanDateTime($iYYYYmmdd, $iHHMMxHHMM)
	; from: 20170101|1100-1200
	; to:   01.01.2017, 11:00 - 12:00
	Local $sReturn = ""
	$sReturn &= StringRight($iYYYYmmdd, 2) & "." & StringMid($iYYYYmmdd, 5, 2) & "." & StringLeft($iYYYYmmdd, 4)
	$sReturn &= ", " & StringLeft($iHHMMxHHMM, 2) & ":" & StringMid($iHHMMxHHMM, 3, 2)
	$sReturn &= " - " & StringMid($iHHMMxHHMM, 6, 2) & ":" & StringMid($iHHMMxHHMM, 8, 2)
	Return $sReturn
EndFunc   ;==>GetHumanDateTime

; #FUNCTION# ====================================================================================================================
; Name ..........: Schedule_OpenInifile
; Description ...: open schedule configuration and read values to an array
; Syntax ........: Schedule_OpenInifile()
; Author ........: Tino Reichardt
; Modified ......: 12.08.2016
; ===============================================================================================================================
Func Schedule_OpenInifile($sFile, ByRef $aArray, $sSection, $iDelim)
	Local $i = 1
	While 1
		Local $sValue = IniRead($sFile, $sSection, $i, "")
		If $sValue = "" Then ExitLoop
		$i += 1

		; check, if number of columns is okay
		StringReplace($sValue, "|", "x")
		If Not ($iDelim = @extended) Then ContinueLoop

		; add it, seems correct
		_ArrayAdd($aArray, $sValue, 1)
	WEnd

	; create new empty section
	If UBound($aArray) = 0 Then
		IniWriteSection($sFile, $sSection, "")
	EndIf
EndFunc   ;==>Schedule_OpenInifile

; #FUNCTION# ====================================================================================================================
; Name ..........: Schedule_Open
; Description ...: open the schedule $sFile and write it's contents to the 4 main arrays
; Syntax ........: Schedule_Open()
; Author ........: Tino Reichardt
; Modified ......: 12.08.2016
; ===============================================================================================================================
Func Schedule_Open($sFile)
	Local $sInvalid = ""

	If Not FileExists($sFile) Then
		MsgBox(BitOR($MB_OK, $MB_ICONERROR), $sTitle, "Fehler bei öffnen der Datei " & $sFile & "!")
		Exit
	EndIf

	GUICtrlSetState($idListWeekplan, $GUI_HIDE)

	; $aWeekplan[0][1 + 4]
	; ID|Aktiv|Wochentag|Zeitraum|Layout (Zeitraum HHMM-HHMM)
	Schedule_OpenInifile($sFile, $aWeekplan, "Weekplan", 3)
	For $i = 0 To UBound($aWeekplan) - 1
		; check, if entries are valid
		If Not (StringLen($aWeekplan[$i][1]) = 1) Then ContinueLoop
		If Not (StringLen($aWeekplan[$i][2]) = 1) Then ContinueLoop
		If Not (StringLen($aWeekplan[$i][3]) = 9) Then ContinueLoop
		If Not (StringLen($aWeekplan[$i][4]) >= 1) Then ContinueLoop
		If Not (Int($aWeekplan[$i][2]) >= 1 And Int($aWeekplan[$i][2] <= 7)) Then ContinueLoop
		Local $iT1 = Int(StringMid($aWeekplan[$i][3], 1, 4))
		Local $iT2 = Int(StringMid($aWeekplan[$i][3], 6, 4))
		If Not ($iT1 <= 2359) Then ContinueLoop
		If Not ($iT2 <= 2359) Then ContinueLoop
		If Not ($iT1 < $iT2) Then ContinueLoop
		$aWeekplan[$i][0] = "0"
	Next
	; _PrintFromArray($aWeekplan)

	; remove bad entries
	$iInvalid = 0
	$sInvalid = ""
	For $i = 0 To UBound($aWeekplan) - 1
		If Not ($aWeekplan[$i][0] = "") Then ContinueLoop
		If Not ($sInvalid = "") Then $sInvalid &= ";"
		$sInvalid &= $i
		$iInvalid += 1
	Next
	ShowWeekplan()

	; $aOfftimes[0][1 + 3]
	; ID|Aktiv|Zeitraum|Beschreibung (Zeitraum YYYYmmdd-YYYYmmdd)
	; [0] 38|1|20170101-20170201|Winterferien
	Schedule_OpenInifile($sFile, $aOfftimes, "Offtimes", 2)
	For $i = 0 To UBound($aOfftimes) - 1
		; check, if entries are valid
		If Not (StringLen($aOfftimes[$i][1]) = 1) Then ContinueLoop
		If Not (StringLen($aOfftimes[$i][2]) = 8 + 1 + 8) Then ContinueLoop
		If Not (StringLen($aOfftimes[$i][3]) >= 1) Then ContinueLoop
		Local $iToday = Int(@YEAR & @MON & @MDAY)
		Local $iT1 = Int(StringMid($aOfftimes[$i][2], 1, 8))
		Local $iT2 = Int(StringMid($aOfftimes[$i][2], 10, 8))
		If Not ($iT1 < $iT2) Then ContinueLoop
		If Not ($iToday < $iT2) Then ContinueLoop
		$aOfftimes[$i][0] = GUICtrlCreateListViewItem("", $idListOfftimes)
	Next
	; _PrintFromArray($aOfftimes)

	; remove bad entries
	$sInvalid = ""
	For $i = 0 To UBound($aOfftimes) - 1
		If Not ($aOfftimes[$i][0] = "") Then ContinueLoop
		If Not ($sInvalid = "") Then $sInvalid &= ";"
		$sInvalid &= $i
		$iInvalid += 1
	Next
	ShowOfftimes()
	; ConsoleWrite("$sInvalid =" & $sInvalid & @CRLF)

	; $aEvents[0][1 + 5]
	; ID|Aktiv|Tag|Zeitraum|Layout|Beschreibung (Tag YYYYmmdd, Zeitraum HHMM-YYYY)
	; [0] 42|1|20170101|1100-1200|Layoutname|Admin Day
	Schedule_OpenInifile($sFile, $aEvents, "Events", 4)
	For $i = 0 To UBound($aEvents) - 1
		; check, if entries are valid
		If Not (StringLen($aEvents[$i][1]) = 1) Then ContinueLoop
		If Not (StringLen($aEvents[$i][2]) = 8) Then ContinueLoop
		If Not (StringLen($aEvents[$i][3]) = 9) Then ContinueLoop
		If Not (StringLen($aEvents[$i][4]) >= 1) Then ContinueLoop
		If Not (StringLen($aEvents[$i][5]) >= 1) Then ContinueLoop

		Local $iToday = Int(@YEAR & @MON & @MDAY)
		Local $iDate = Int($aEvents[$i][2])
		If ($iToday > $iDate) Then ContinueLoop
		Local $iT1 = Int(StringMid($aEvents[$i][3], 1, 4))
		Local $iT2 = Int(StringMid($aEvents[$i][3], 6, 4))
		If ($iT1 > 2359) Then ContinueLoop
		If ($iT2 > 2359) Then ContinueLoop
		If ($iT1 >= $iT2) Then ContinueLoop
		$aEvents[$i][0] = GUICtrlCreateListViewItem("", $idListEvents)
	Next
	; _PrintFromArray($aEvents)
	ShowEvents()

	; remove bad entries
	$sInvalid = ""
	For $i = 0 To UBound($aEvents) - 1
		If Not ($aEvents[$i][0] = "") Then ContinueLoop
		If Not ($sInvalid = "") Then $sInvalid &= ";"
		$sInvalid &= $i
		$iInvalid += 1
	Next

	; $aMACs[0][1 + 2]
	; ID|Aktiv|Mac|Beschreibung
	; [0] 45|1|12:34:56:78:90:ab|Beschreibung
	Schedule_OpenInifile($sFile, $aMACs, "Macs", 2)
	For $i = 0 To UBound($aMACs) - 1
		; check, if entries are valid
		If Not (StringLen($aMACs[$i][1]) = 1) Then ContinueLoop
		If Not (StringLen($aMACs[$i][2]) = 17) Then ContinueLoop
		If Not (StringLen($aMACs[$i][3]) > 1) Then ContinueLoop
		If Not (Hex(StringMid($aMACs[$i][2], 1, 2), 2) < 255) Then ContinueLoop
		If Not (Hex(StringMid($aMACs[$i][2], 4, 2), 2) < 255) Then ContinueLoop
		If Not (Hex(StringMid($aMACs[$i][2], 7, 2), 2) < 255) Then ContinueLoop
		If Not (Hex(StringMid($aMACs[$i][2], 10, 2), 2) < 255) Then ContinueLoop
		If Not (Hex(StringMid($aMACs[$i][2], 13, 2), 2) < 255) Then ContinueLoop
		If Not (Hex(StringMid($aMACs[$i][2], 16, 2), 2) < 255) Then ContinueLoop
		$aMACs[$i][0] = GUICtrlCreateListViewItem("", $idListMacs)
	Next
	; _PrintFromArray($aMACs)
	ShowMacs()

	; remove bad entries
	$sInvalid = ""
	For $i = 0 To UBound($aMACs) - 1
		If Not ($aMACs[$i][0] = "") Then ContinueLoop
		If Not ($sInvalid = "") Then $sInvalid &= ";"
		$sInvalid &= $i
		$iInvalid += 1
	Next

	GUICtrlSetState($idListWeekplan, $GUI_SHOW)
EndFunc   ;==>Schedule_Open

; #FUNCTION# ====================================================================================================================
; Name ..........: ShowWeekplan
; Description ...: format the contents of the ListView for the Weekplan
; Syntax ........: ShowWeekplan()
; Author ........: Tino Reichardt
; Modified ......: 14.08.2016
; ===============================================================================================================================
Func ShowWeekplan()
	Local $sDelete = ""
	For $i = 0 To UBound($aWeekplan) - 1
		Local $sListView = ""
		$sListView &= "|" & DayOfWeek($aWeekplan[$i][2])
		$sListView &= "|" & $aWeekplan[$i][4]
		$sListView &= "|" & GetTimeValue(StringMid($aWeekplan[$i][3], 1, 4), 0)
		$sListView &= " - " & GetTimeValue(StringMid($aWeekplan[$i][3], 6, 4), 0)

		; add new entry...
		If $aWeekplan[$i][0] = "0" Then
			$aWeekplan[$i][0] = GUICtrlCreateListViewItem($sListView, $idListWeekplan)
		Else
			GUICtrlSetData($aWeekplan[$i][0], $sListView)
		EndIf

		; check, if entry is still there...
		If GUICtrlGetState($aWeekplan[$i][0]) = -1 Then
			If Not $sDelete = "" Then $sDelete &= ";"
			$sDelete &= $i
			ContinueLoop
		EndIf

		If $aWeekplan[$i][1] = "1" Then
			_GUICtrlListView_SetItemChecked($idListWeekplan, $i, True)
		Else
			_GUICtrlListView_SetItemChecked($idListWeekplan, $i, False)
		EndIf
	Next

	; delete entries
	If Not $sDelete = "" Then _ArrayDelete($aWeekplan, $sDelete)

	; every time, when we update the view, we also have changed sth.
	GUICtrlSetState($idButtonSave, $GUI_ENABLE)
EndFunc   ;==>ShowWeekplan

; #FUNCTION# ====================================================================================================================
; Name ..........: ShowOfftimes
; Description ...: format the contents of the ListView for the ShowOfftimes
; Syntax ........: ShowOfftimes()
; Author ........: Tino Reichardt
; Modified ......: 14.08.2016
; ===============================================================================================================================
Func ShowOfftimes()
	Local $sDelete = ""
	For $i = 0 To UBound($aOfftimes) - 1
		; von:  [0] 38|1|20170101-20170201|Winterferien
		; nach: 01.01.2017 - 01.02.2017 | Winterferien
		Local $sListView = ""
		Local $sVon = StringMid($aOfftimes[$i][2], 1, 8)
		Local $sBis = StringMid($aOfftimes[$i][2], 10, 8)
		$sListView &= "|" & GetHumanDate($sVon)
		$sListView &= " - " & GetHumanDate($sBis)
		$sListView &= "|" & $aOfftimes[$i][3]

		; add new entry...
		If $aOfftimes[$i][0] = "0" Then
			$aOfftimes[$i][0] = GUICtrlCreateListViewItem($sListView, $idListOfftimes)
		Else
			GUICtrlSetData($aOfftimes[$i][0], $sListView)
		EndIf

		; check, if entry is still there...
		If GUICtrlGetState($aOfftimes[$i][0]) = -1 Then
			If Not $sDelete = "" Then $sDelete &= ";"
			$sDelete &= $i
			ContinueLoop
		EndIf

		If $aOfftimes[$i][1] = "1" Then
			_GUICtrlListView_SetItemChecked($idListOfftimes, $i, True)
		Else
			_GUICtrlListView_SetItemChecked($idListOfftimes, $i, False)
		EndIf
	Next

	; delete entries
	If Not $sDelete = "" Then _ArrayDelete($aOfftimes, $sDelete)

	; every time, when we update the view, we also have changed sth.
	GUICtrlSetState($idButtonSave, $GUI_ENABLE)
EndFunc   ;==>ShowOfftimes

; #FUNCTION# ====================================================================================================================
; Name ..........: ShowEvents
; Description ...: format the contents of the ListView for the ShowEvents
; Syntax ........: ShowEvents()
; Author ........: Tino Reichardt
; Modified ......: 16.08.2016
; ===============================================================================================================================
Func ShowEvents()
	Local $sDelete = ""
	For $i = 0 To UBound($aEvents) - 1
		; von:  [0] 44|1|20170101|1100-1200|Layout|Admin Day
		; nach: Aktiv|Layout|Zeitraum|Beschreibung
		Local $sListView = ""
		$sListView &= "|" & $aEvents[$i][4]
		$sListView &= "|" & GetHumanDateTime($aEvents[$i][2], $aEvents[$i][3])
		$sListView &= "|" & $aEvents[$i][5]

		; add new entry...
		If $aEvents[$i][0] = "0" Then
			$aEvents[$i][0] = GUICtrlCreateListViewItem($sListView, $idListEvents)
		Else
			GUICtrlSetData($aEvents[$i][0], $sListView)
		EndIf

		; check, if entry is still there...
		If GUICtrlGetState($aEvents[$i][0]) = -1 Then
			If Not $sDelete = "" Then $sDelete &= ";"
			$sDelete &= $i
			ContinueLoop
		EndIf

		If $aEvents[$i][1] = "1" Then
			_GUICtrlListView_SetItemChecked($idListEvents, $i, True)
		Else
			_GUICtrlListView_SetItemChecked($idListEvents, $i, False)
		EndIf
	Next

	; delete entries
	If Not $sDelete = "" Then _ArrayDelete($aEvents, $sDelete)

	; every time, when we update the view, we also have changed sth.
	GUICtrlSetState($idButtonSave, $GUI_ENABLE)
EndFunc   ;==>ShowEvents

; #FUNCTION# ====================================================================================================================
; Name ..........: ShowMacs
; Description ...: format the contents of the ListView for the ShowMacs
; Syntax ........: ShowMacs()
; Author ........: Tino Reichardt
; Modified ......: 16.08.2016
; ===============================================================================================================================
Func ShowMacs()
	Local $sDelete = ""
	For $i = 0 To UBound($aMACs) - 1
		; von:  [0] 47|1|12:34:56:78:90:ab|Beschreibung
		; nach: Aktiv|Mac|Beschreibung
		Local $sListView = ""
		$sListView &= "|" & $aMACs[$i][2]
		$sListView &= "|" & $aMACs[$i][3]

		; add new entry...
		If $aMACs[$i][0] = "0" Then
			$aMACs[$i][0] = GUICtrlCreateListViewItem($sListView, $idListMacs)
		Else
			GUICtrlSetData($aMACs[$i][0], $sListView)
		EndIf

		; check, if entry is still there...
		If GUICtrlGetState($aMACs[$i][0]) = -1 Then
			If Not $sDelete = "" Then $sDelete &= ";"
			$sDelete &= $i
			ContinueLoop
		EndIf

		If $aMACs[$i][1] = "1" Then
			_GUICtrlListView_SetItemChecked($idListMacs, $i, True)
		Else
			_GUICtrlListView_SetItemChecked($idListMacs, $i, False)
		EndIf
	Next

	; delete entries
	If Not $sDelete = "" Then _ArrayDelete($aMACs, $sDelete)

	; every time, when we update the view, we also have changed sth.
	GUICtrlSetState($idButtonSave, $GUI_ENABLE)
EndFunc   ;==>ShowMacs

; #FUNCTION# ====================================================================================================================
; Name ..........: SortListView
; Description ...: array umsortieren und listview entsprechend aktualisieren...
; Syntax ........: SortListView(spalte)
; Author ........: Tino Reichardt
; Modified ......: 16.08.2016
; ===============================================================================================================================
Func SortListView(ByRef $aListArray, $iType)
	Static $iOrder[4] = [0, 0, 0, 0] ; down / up
	Local $aArray, $iCol, $hHeader

	Switch $iType
		Case $eLV_Weekplan
			$aArray = $aWeekplan
			$iCol = GUICtrlGetState($idListWeekplan)
			; weekplan @gui:   Aktiv|Day|Layout|Time
			; weekplan @array: ID|Aktiv|Day|Time1Time2|Layout
			Local $aSortCol[4] = [1, 2, 4, 3]
			$hHeader = _GUICtrlListView_GetHeader($idListWeekplan)
		Case $eLV_Offtimes
			$aArray = $aOfftimes
			$iCol = GUICtrlGetState($idListOfftimes)
			; offtimes @gui:   Aktiv|Time|Description
			; offtimes @array: ID|Aktiv|Time|Description
			Local $aSortCol[3] = [1, 2, 3]
			$hHeader = _GUICtrlListView_GetHeader($idListOfftimes)
		Case $eLV_Events
			$aArray = $aEvents
			$iCol = GUICtrlGetState($idListEvents)
			; events @gui:   Aktiv|Layout|DateTime|Description
			; events @array: ID|Aktiv|Date|Time|Layout|Description
			Local $aSortCol[5] = [1, 4, 2, 5, 0]
			$hHeader = _GUICtrlListView_GetHeader($idListEvents)
		Case $eLV_Macs
			$aArray = $aMACs
			$iCol = GUICtrlGetState($idListMacs)
			; macs @gui:   Aktiv|Mac|Description
			; macs @array: ID|Aktiv|Mac|Description
			Local $aSortCol[3] = [1, 2, 3]
			$hHeader = _GUICtrlListView_GetHeader($idListMacs)
		Case Default
			; can not happen!
			Return
	EndSwitch

	#cs
		ConsoleWrite("copy:" & @CRLF)
		_PrintFromArray($aArray)
		ConsoleWrite("week:" & @CRLF)
		_PrintFromArray($aWeekplan)
		ConsoleWrite("$iCol=" & $iCol & " realCol=" & $aSortCol[$iCol] & " $aSortCol=" & UBound($aSortCol) & @CRLF)
	#ce
	_ArraySort($aArray, $iOrder[$iType], 0, 0, $aSortCol[$iCol])
	For $i = 0 To UBound($aArray) - 1
		For $j = 1 To UBound($aSortCol)
			$aListArray[$i][$j] = $aArray[$i][$j]
		Next
	Next

	; next time, the other way
	$iOrder[$iType] = $iOrder[$iType] ? 0 : 1
	For $i = 0 To _GUICtrlHeader_GetItemCount($hHeader) - 1
		Local $iFormat = _GUICtrlHeader_GetItemFormat($hHeader, $i)
		If BitAND($iFormat, $HDF_SORTDOWN) Then
			_GUICtrlHeader_SetItemFormat($hHeader, $i, BitXOR($iFormat, $HDF_SORTDOWN))
		ElseIf BitAND($iFormat, $HDF_SORTUP) Then
			_GUICtrlHeader_SetItemFormat($hHeader, $i, BitXOR($iFormat, $HDF_SORTUP))
		EndIf
	Next
	If $iCol > 0 Then
		$iFormat = _GUICtrlHeader_GetItemFormat($hHeader, $iCol)
		If $iOrder[$iType] = 1 Then
			_GUICtrlHeader_SetItemFormat($hHeader, $iCol, BitOR($iFormat, $HDF_SORTUP))
		Else
			_GUICtrlHeader_SetItemFormat($hHeader, $iCol, BitOR($iFormat, $HDF_SORTDOWN))
		EndIf
	EndIf

	; show result
	Switch $iType
		Case $eLV_Weekplan
			ShowWeekplan()
		Case $eLV_Offtimes
			ShowOfftimes()
		Case $eLV_Events
			ShowEvents()
		Case $eLV_Macs
			ShowMacs()
	EndSwitch
EndFunc   ;==>SortListView

; #FUNCTION# ====================================================================================================================
; Name ..........: Schedule_SaveInifile
; Description ...: write content of an data array to ini file
; Syntax ........: Schedule_SaveInifile()
; Author ........: Tino Reichardt
; Modified ......: 12.08.2016
; ===============================================================================================================================
Func Schedule_SaveInifile($sFile, $aArray, $sSection, $sColumns)
	Local $aColumns = _StringExplode($sColumns, "|")
	Local $sIniSection = ""

	; write empty section
	If UBound($aArray) = 0 Then
		IniWriteSection($sFile, $sSection, "")
		Return
	EndIf

	For $i = 0 To UBound($aArray) - 1
		Local $sEntry = ""
		For $j = 0 To UBound($aColumns) - 1
			Local $sCol = $aArray[$i][$aColumns[$j]]
			If $j = 0 Then
				$sIniSection &= $i + 1 & "="
			Else
				$sIniSection &= "|"
			EndIf
			$sIniSection &= $sCol
		Next
		$sIniSection &= @LF
	Next

	; ConsoleWrite("$sIniSection=(" & $sIniSection & ")!" & @CRLF)
	Local $iError = IniWriteSection($sFile, $sSection, $sIniSection)
	If $iError = 0 Then
		MsgBox(BitOR($MB_OK, $MB_ICONERROR), $sTitle, "Fehler bei speichern der Datei " & $sFile & "!")
	EndIf
EndFunc   ;==>Schedule_SaveInifile

; #FUNCTION# ====================================================================================================================
; Name ..........: Schedule_Save
; Description ...: write the current content of the 4 arrays to schedule plan
; Syntax ........: Schedule_Save()
; Author ........: Tino Reichardt
; Modified ......: 12.08.2016
; ===============================================================================================================================
Func Schedule_Save($sFile)
	; ConsoleWrite("Schedule_Save()")

	; write sections
	Schedule_SaveInifile($sFile, $aWeekplan, "Weekplan", "1|2|3|4")
	Schedule_SaveInifile($sFile, $aOfftimes, "Offtimes", "1|2|3")
	Schedule_SaveInifile($sFile, $aEvents, "Events", "1|2|3|4|5")
	Schedule_SaveInifile($sFile, $aMACs, "Macs", "1|2|3")

	If Not FileExists($sFile) Then
		MsgBox(BitOR($MB_OK, $MB_ICONERROR), $sTitle, "Fehler bei speichern der Datei " & $sFile & "!")
		Return
	EndIf

	; we just saved
	GUICtrlSetState($idButtonSave, $GUI_DISABLE)
EndFunc   ;==>Schedule_Save

; #FUNCTION# ====================================================================================================================
; Name ..........: FindLayoutFiles
; Description ...: return string array of all *.dsbd files
; Syntax ........: FindLayoutFiles()
; Author ........: Tino Reichardt
; Modified ......: 12.08.2016
; ===============================================================================================================================
Func FindLayoutFiles()
	Local $sReturn = ""
	Local $hSearch = FileFindFirstFile("*.dsbd")
	If $hSearch = -1 Then Return ""

	While 1
		Local $sFile = FileFindNextFile($hSearch)
		If @error Then ExitLoop
		If StringLen($sReturn) Then $sReturn &= "|"
		$sReturn &= StringTrimRight($sFile, 5)
	WEnd

	FileClose($hSearch)
	Return $sReturn
EndFunc   ;==>FindLayoutFiles

; #FUNCTION# ====================================================================================================================
; Name ..........: EditWeekplan
; Description ...: add or change weekplan
; Syntax ........: EditWeekplan()
; Author ........: Tino Reichardt
; Modified ......: 12.08.2016
; ===============================================================================================================================
Func EditWeekplan()
	Local $iCurrent = -1
	Local $sHeadline = "Neuer Eintrag im Wochenplan"
	If _GUICtrlListView_GetSelectedCount($hListWeekplan) = 1 Then
		$sHeadline = "Wochenplan bearbeiten"
		$iCurrent = _GUICtrlListView_GetSelectedIndices($hListWeekplan, False)
	EndIf
	Local $hChild = GUICreate($sHeadline, 305, 193, 130, 100, $gGuiStyle, $WS_EX_MDICHILD, $hGUI)
	Local $idComboL, $idComboWD, $idTime1, $idTime2

	; setup data
	Local $sLayouts = FindLayoutFiles()
	Local $sWeekDays = ""
	For $i = 1 To 7
		$sWeekDays &= DayOfWeek($i) & "|"
	Next
	Local $iTime1 = GetTimeValue($iCurrent == -1 ? "" : StringLeft($aWeekplan[$iCurrent][3], 4))
	Local $iTime2 = GetTimeValue($iCurrent == -1 ? "" : StringRight($aWeekplan[$iCurrent][3], 4))

	; create gui
	GUICtrlCreateGroup("", 8, 8, 289, 145)
	GUICtrlCreateLabel("Wochentag:", 16, 24, 63, 17)
	GUICtrlCreateLabel("Layout:", 16, 56, 39, 17)
	GUICtrlCreateLabel("Von:", 16, 88, 26, 17)
	GUICtrlCreateLabel("Bis:", 16, 120, 21, 17)
	$idComboWD = GUICtrlCreateCombo("", 88, 24, 201, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
	$idComboL = GUICtrlCreateCombo("", 88, 56, 201, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
	$idTime1 = GUICtrlCreateDate($iTime1, 87, 88, 202, 21, $DTS_TIMEFORMAT)
	$idTime2 = GUICtrlCreateDate($iTime1, 87, 120, 202, 21, $DTS_TIMEFORMAT)

	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Local $idOkay = GUICtrlCreateButton("OK", 6, 160, 100, 25, 0)
	Local $idCancel = GUICtrlCreateButton("Abbrechen", 113, 160, 100, 25)

	; fill gui
	GUICtrlSendMsg($idTime1, $DTM_SETFORMATW, 0, "HH:mm")
	GUICtrlSendMsg($idTime2, $DTM_SETFORMATW, 0, "HH:mm")
	GUICtrlSetData($idTime1, $iTime1)
	GUICtrlSetData($idTime2, $iTime2)
	GUICtrlSetData($idComboL, $sLayouts, $iCurrent == -1 ? "" : $aWeekplan[$iCurrent][4])
	GUICtrlSetData($idComboWD, $sWeekDays, $iCurrent == -1 ? "" : DayOfWeek($aWeekplan[$iCurrent][2]))

	; switch gui
	GUISetState(@SW_DISABLE, $hGUI)
	Local $aAccelKeys[1][2] = [["{ENTER}", $idOkay]]
	GUISetAccelerators($aAccelKeys, $hChild)
	GUISetState(@SW_SHOW, $hChild)

	While 1
		Local $iMsg = GUIGetMsg()
		Switch $iMsg
			Case $GUI_EVENT_CLOSE
				ExitLoop

			Case $idOkay
				$iTime1 = GUICtrlRead($idTime1)
				$iTime2 = GUICtrlRead($idTime2)
				If $iTime1 >= $iTime2 Or Not StringLen(GUICtrlRead($idComboL)) Then
					MsgBox($MB_SYSTEMMODAL + $MB_ICONINFORMATION, $sTitle, "Bitte die Angaben überprüfen.")
					ContinueLoop
				EndIf
				If $iCurrent = -1 Then
					; new entry
					Local $sValue = "0|1"
					$sValue &= "|" & _GUICtrlComboBox_GetCurSel($idComboWD) + 1
					$sValue &= "|" & GetIniTimeValue(GUICtrlRead($idTime1), GUICtrlRead($idTime2))
					$sValue &= "|" & GUICtrlRead($idComboL)
					_ArrayAdd($aWeekplan, $sValue)
				Else
					; modify some entry
					$aWeekplan[$iCurrent][1] = 1
					$aWeekplan[$iCurrent][2] = _GUICtrlComboBox_GetCurSel($idComboWD) + 1
					$aWeekplan[$iCurrent][3] = GetIniTimeValue(GUICtrlRead($idTime1), GUICtrlRead($idTime2))
					$aWeekplan[$iCurrent][4] = GUICtrlRead($idComboL)
				EndIf
				; update listview
				ShowWeekplan()
				ExitLoop

			Case $idCancel
				ExitLoop
		EndSwitch
	WEnd
	GUISetState(@SW_ENABLE, $hGUI)
	GUIDelete($hChild)
EndFunc   ;==>EditWeekplan

; #FUNCTION# ====================================================================================================================
; Name ..........: EditOfftimes
; Description ...: add or change offtimes
; Syntax ........: EditOfftimes()
; Author ........: Tino Reichardt
; Modified ......: 12.08.2016
; ===============================================================================================================================
Func EditOfftimes()
	Local $iCurrent = -1
	Local $sHeadline = "Neue Ausschaltzeit"
	If _GUICtrlListView_GetSelectedCount($hListOfftimes) = 1 Then
		$sHeadline = "Ausschaltzeiten bearbeiten"
		$iCurrent = _GUICtrlListView_GetSelectedIndices($hListOfftimes, False)
	EndIf
	Local $hChild = GUICreate($sHeadline, 305, 185, 130, 100, $gGuiStyle, $WS_EX_MDICHILD, $hGUI)
	Local $idInput, $idDate1, $idDate2, $idOkay, $idCancel

	; setup data
	$sDateFrom = ($iCurrent == -1 ? @YEAR & @MON & @MDAY : StringLeft($aOfftimes[$iCurrent][2], 8))
	$sDateTo = ($iCurrent == -1 ? @YEAR & @MON & @MDAY : StringRight($aOfftimes[$iCurrent][2], 8))
	Local $sDesc = $iCurrent == -1 ? "" : $aOfftimes[$iCurrent][3]

	; create gui
	GUICtrlCreateGroup("", 8, 8, 289, 133)
	GUICtrlCreateLabel("Beschreibung:", 16, 93, 72, 17)
	GUICtrlCreateLabel("Von:", 16, 24, 26, 17)
	GUICtrlCreateLabel("Bis:", 16, 56, 21, 17)
	$idDate1 = GUICtrlCreateDate("", 71, 24, 218, 21)
	$idDate2 = GUICtrlCreateDate("", 71, 56, 218, 21)
	$idInput = GUICtrlCreateInput("", 16, 112, 273, 21)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$idOkay = GUICtrlCreateButton("OK", 6, 151, 100, 25, 0)
	$idCancel = GUICtrlCreateButton("Abbrechen", 113, 151, 100, 25)

	; fill gui
	GUICtrlSendMsg($idDate1, $DTM_SETFORMATW, 0, "dddd, dd.MM.yyyy")
	GUICtrlSendMsg($idDate2, $DTM_SETFORMATW, 0, "dddd, dd.MM.yyyy")
	GUICtrlSetData($idInput, $iCurrent == -1 ? "" : $sDesc)
	GUICtrlSetData($idDate1, $iCurrent == -1 ? "" : GetDateValue($sDateFrom))
	GUICtrlSetData($idDate2, $iCurrent == -1 ? "" : GetDateValue($sDateTo))

	; global, for WM_NOTIFY
	$hDateFrom = GUICtrlGetHandle($idDate1)
	$hDateTo = GUICtrlGetHandle($idDate2)

	; switch gui
	GUISetState(@SW_DISABLE, $hGUI)
	Local $aAccelKeys[1][2] = [["{ENTER}", $idOkay]]
	GUISetAccelerators($aAccelKeys, $hChild)
	GUISetState(@SW_SHOW, $hChild)

	While 1
		Local $iMsg = GUIGetMsg()
		Switch $iMsg
			Case $GUI_EVENT_CLOSE
				ExitLoop

			Case $idOkay
				$sDesc = GUICtrlRead($idInput)
				If Not StringLen($sDesc) Then
					MsgBox($MB_SYSTEMMODAL + $MB_ICONINFORMATION, $sTitle, "Bitte die Angaben überprüfen.")
					ContinueLoop
				EndIf

				If $iCurrent = -1 Then
					; new entry
					Local $sValue = "0|1"
					$sValue &= "|" & $sDateFrom & "-" & $sDateTo
					$sValue &= "|" & $sDesc
					_ArrayAdd($aOfftimes, $sValue)
				Else
					; modify some entry
					$aOfftimes[$iCurrent][1] = 1
					$aOfftimes[$iCurrent][2] = $sDateFrom & "-" & $sDateTo
					$aOfftimes[$iCurrent][3] = $sDesc
				EndIf
				; update listview
				ShowOfftimes()
				ExitLoop

			Case $idCancel
				ExitLoop
		EndSwitch
	WEnd
	GUISetState(@SW_ENABLE, $hGUI)
	GUIDelete($hChild)
EndFunc   ;==>EditOfftimes

; #FUNCTION# ====================================================================================================================
; Name ..........: EditEvents
; Description ...: add or change events
; Syntax ........: EditEvents()
; Author ........: Tino Reichardt
; Modified ......: 12.08.2016
; ===============================================================================================================================
Func EditEvents()
	Local $iCurrent = -1
	Local $sHeadline = "Neue Veranstaltung"
	If _GUICtrlListView_GetSelectedCount($hListEvents) = 1 Then
		$sHeadline = "Veranstaltung bearbeiten"
		$iCurrent = _GUICtrlListView_GetSelectedIndices($hListEvents, False)
	EndIf
	Local $hChild = GUICreate($sHeadline, 305, 208, 130, 100, $gGuiStyle, $WS_EX_MDICHILD, $hGUI)
	Local $idInput, $idDate1, $idDate2, $idCombo, $idOkay, $idCancel

	; setup data
	Local $sLayouts = FindLayoutFiles()
	Local $sDesc = $iCurrent == -1 ? "" : $aEvents[$iCurrent][4]
	Local $sLayout = $iCurrent == -1 ? "" : $aEvents[$iCurrent][5]

	; setup globals
	$sDateFrom = ($iCurrent == -1 ? @YEAR & @MON & @MDAY : $aEvents[$iCurrent][2])
	$sDateTo = ($iCurrent == -1 ? @YEAR & @MON & @MDAY : $aEvents[$iCurrent][2])
	$sTimeFrom = ($iCurrent == -1 ? @HOUR & @MIN : StringLeft($aEvents[$iCurrent][3], 4))
	$sTimeTo = ($iCurrent == -1 ? @HOUR & @MIN & @MDAY : StringRight($aEvents[$iCurrent][3], 4))

	; create gui
	GUICtrlCreateGroup("", 8, 8, 289, 161)
	GUICtrlCreateLabel("Layout:", 16, 24, 39, 17)
	GUICtrlCreateLabel("Von:", 16, 56, 26, 17)
	GUICtrlCreateLabel("Bis:", 16, 88, 21, 17)
	GUICtrlCreateLabel("Beschreibung:", 16, 120, 72, 17)
	$idCombo = GUICtrlCreateCombo("", 64, 24, 225, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
	$idDate1 = GUICtrlCreateDate("2016/08/08 15:15:41", 63, 56, 226, 21)
	$idDate2 = GUICtrlCreateDate("2016/08/08 15:15:47", 63, 88, 226, 21)
	$idInput = GUICtrlCreateInput("", 16, 139, 273, 21)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$idOkay = GUICtrlCreateButton("OK", 6, 176, 100, 25, 0)
	$idCancel = GUICtrlCreateButton("Abbrechen", 113, 176, 100, 25)

	; fill gui
	GUICtrlSendMsg($idDate1, $DTM_SETFORMATW, 0, "dddd, dd.MM.yyyy,    HH:mm")
	GUICtrlSendMsg($idDate2, $DTM_SETFORMATW, 0, "dddd, dd.MM.yyyy,    HH:mm")
	GUICtrlSetData($idCombo, $sLayouts, $iCurrent == -1 ? "" : $aEvents[$iCurrent][4])
	GUICtrlSetData($idInput, $iCurrent == -1 ? "" : $aEvents[$iCurrent][5])
	GUICtrlSetData($idDate1, $iCurrent == -1 ? "" : GetDateTimeValue($sDateFrom, $sTimeFrom))
	GUICtrlSetData($idDate2, $iCurrent == -1 ? "" : GetDateTimeValue($sDateTo, $sTimeTo))

	; global, for WM_NOTIFY
	$hDateFrom = GUICtrlGetHandle($idDate1)
	$hDateTo = GUICtrlGetHandle($idDate2)

	; switch gui
	GUISetState(@SW_DISABLE, $hGUI)
	Local $aAccelKeys[1][2] = [["{ENTER}", $idOkay]]
	GUISetAccelerators($aAccelKeys, $hChild)
	GUISetState(@SW_SHOW, $hChild)

	While 1
		Local $iMsg = GUIGetMsg()
		Switch $iMsg
			Case $GUI_EVENT_CLOSE
				ExitLoop

			Case $idOkay
				Local $sDesc = GUICtrlRead($idInput)
				Local $sLayout = GUICtrlRead($idCombo)
				Local $iToday = Int(@YEAR & @MON & @MDAY)
				Local $iDayDiff = _DateDiff("D", GetDateTimeValue($sDateFrom, $sTimeFrom), GetDateTimeValue($sDateTo, $sTimeTo))

				ConsoleWrite("$sTimeFrom=" & $sTimeFrom & "$sTimeTo=" & $sTimeTo & @CRLF)
				If (Not StringLen($sDesc)) Or (Not StringLen($sLayout)) Or ($iDayDiff > 40) Or (Int($sTimeFrom) >= Int($sTimeTo)) Or (Int($sDateFrom) > Int($sDateTo)) Or ($iToday > Int($sDateFrom)) Then
					MsgBox($MB_SYSTEMMODAL + $MB_ICONINFORMATION, $sTitle, "Bitte die Angaben überprüfen.")
					ContinueLoop
				EndIf

				If $iCurrent = -1 Then
					; first new entry
					Local $sValue = "0|1"
					$sValue &= "|" & $sDateFrom
					$sValue &= "|" & $sTimeFrom & "-" & $sTimeTo
					$sValue &= "|" & $sLayout
					$sValue &= "|" & $sDesc
					_ArrayAdd($aEvents, $sValue)
				Else
					; modify some entry
					$aEvents[$iCurrent][1] = 1
					$aEvents[$iCurrent][2] = $sDateFrom
					$aEvents[$iCurrent][3] = $sTimeFrom & "-" & $sTimeTo
					$aEvents[$iCurrent][4] = $sLayout
					$aEvents[$iCurrent][5] = $sDesc
				EndIf

				; check for multiple days
				If $sDateFrom <> $sDateTo Then
					; start with next day, since one entry is done allready
					Local $iDVstart = _DateAdd("d", 1, GetDateValue($sDateFrom))
					Local $iDVend = GetDateValue($sDateTo)
					; we limit to 40, no endless things, when some calculation is wrong...
					For $i = 0 To 40
						Local $DVcurrent = _DateAdd("d", $i, $iDVstart)
						Local $sValue = "0|1"
						$sValue &= "|" & GetIniDateValue($DVcurrent)
						$sValue &= "|" & $sTimeFrom & "-" & $sTimeTo
						$sValue &= "|" & $sLayout
						$sValue &= "|" & $sDesc & " (" & $i + 2 & ")"
						_ArrayAdd($aEvents, $sValue)
						If $iDVend = $DVcurrent Then ExitLoop
					Next
				EndIf

				; update listview
				ShowEvents()
				; _PrintFromArray($aEvents)
				ExitLoop

			Case $idCancel
				ExitLoop
		EndSwitch
	WEnd
	GUISetState(@SW_ENABLE, $hGUI)
	GUIDelete($hChild)
EndFunc   ;==>EditEvents

; #FUNCTION# ====================================================================================================================
; Name ..........: EditMacs
; Description ...: add or change mac adresses
; Syntax ........: EditMacs()
; Author ........: Tino Reichardt
; Modified ......: 12.08.2016
; ===============================================================================================================================
Func EditMacs()
	Local $iCurrent = -1
	Local $sHeadline = "Neue MAC Adresse"
	If _GUICtrlListView_GetSelectedCount($hListMacs) = 1 Then
		$sHeadline = "MAC Adresse bearbeiten"
		$iCurrent = _GUICtrlListView_GetSelectedIndices($hListMacs, False)
	EndIf
	Local $hChild = GUICreate($sHeadline, 305, 168, 130, 100, $gGuiStyle, $WS_EX_MDICHILD, $hGUI)
	Local $idMac, $idInput, $idOkay, $idCancel

	; create gui
	GUICtrlCreateGroup("", 8, 8, 233, 121)
	GUICtrlCreateLabel("MAC Adresse:", 16, 24, 71, 17)
	GUICtrlCreateLabel("Beschreibung:", 16, 77, 72, 17)
	$idMac = GUICtrlCreateInput("", 16, 44, 217, 21)
	$idInput = GUICtrlCreateInput("", 16, 96, 217, 21)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$idOkay = GUICtrlCreateButton("OK", 6, 135, 100, 25, 0)
	$idCancel = GUICtrlCreateButton("Abbrechen", 113, 135, 100, 25)

	GUICtrlSetTip($idMac, "MAC Adresse wie zum Beispiel 11:22:33:44:55:66 eingeben.")

	; fill gui
	GUICtrlSetData($idMac, $iCurrent == -1 ? "" : $aMACs[$iCurrent][2])
	GUICtrlSetData($idInput, $iCurrent == -1 ? "" : $aMACs[$iCurrent][3])

	; switch gui
	GUISetState(@SW_DISABLE, $hGUI)
	Local $aAccelKeys[1][2] = [["{ENTER}", $idOkay]]
	GUISetAccelerators($aAccelKeys, $hChild)
	GUISetState(@SW_SHOW, $hChild)

	While 1
		Local $iMsg = GUIGetMsg()
		Switch $iMsg
			Case $GUI_EVENT_CLOSE
				ExitLoop

			Case $idOkay
				Local $sMac = GUICtrlRead($idMac)
				Local $sDesc = GUICtrlRead($idInput)
				If ((StringLen($sMac) <> 17) Or (StringLen($sDesc) < 2)) Then
					MsgBox($MB_SYSTEMMODAL + $MB_ICONINFORMATION, $sTitle, "Bitte die Angaben überprüfen.")
					ContinueLoop
				EndIf
				If $iCurrent = -1 Then
					; new entry
					Local $sValue = ""
					$sValue &= "0|1|" & $sMac
					$sValue &= "|" & $sDesc
					_ArrayAdd($aMACs, $sValue)
				Else
					; modify some entry
					$aMACs[$iCurrent][1] = 1
					$aMACs[$iCurrent][2] = $sMac
					$aMACs[$iCurrent][3] = $sDesc
				EndIf
				; update listview
				ShowMacs()
				ExitLoop

			Case $idCancel
				ExitLoop
		EndSwitch
	WEnd
	GUISetState(@SW_ENABLE, $hGUI)
	GUIDelete($hChild)
EndFunc   ;==>EditMacs

; #FUNCTION# ====================================================================================================================
; Name ..........: ImportEvent_WrongFormat
; Description ...: error message for ImportEvent()
; Syntax ........: ImportEvent_WrongFormat()
; Author ........: Tino Reichardt
; Modified ......: 12.08.2016
; ===============================================================================================================================
Func ImportEvent_WrongFormat()
	MsgBox($MB_SYSTEMMODAL + $MB_ICONERROR, $sTitle, "Diese Datei entspricht nicht dem iCalender Format!")
EndFunc   ;==>ImportEvent_WrongFormat

; #FUNCTION# ====================================================================================================================
; Name ..........: ImportEvent_Offtimes
; Description ...: Import some Offtime
; Syntax ........: ImportEvent_Offtimes($aArray, ...)
; Author ........: Tino Reichardt
; Modified ......: 19.08.2016
; ===============================================================================================================================
Func ImportEvent_Offtimes(ByRef $aArray, $sStart, $sEnd, $sSummary, $iRepeatYear)
	; $sStart      = YYYYmmd
	; $sEnd        = YYYYmmd
	; $sSummary    = lalala
	; $iRepeatYear = 1 or 0
	$sDateFrom = $sStart
	If StringLen($sEnd) = 8 Then
		$sDateTo = $sEnd
	Else
		$sDateTo = $sDateFrom
	EndIf

	If $iRepeatYear = 0 Then
		; 1=1|YYYYmmdd-YYYYmmdd|Description
		Local $sValue = "0|1"
		$sValue &= "|" & $sDateFrom & "-" & $sDateTo
		$sValue &= "|" & $sSummary
		_ArrayAdd($aArray, $sValue)
		Return
	EndIf

	; $iRepeatYear=1
	; repeating, just add the dates for next 3 years
	Local $iToday = Int(@YEAR & @MON & @MDAY)
	Local $sMDstart = @YEAR & StringRight($sDateFrom, 4)
	Local $sMDend = @YEAR & StringRight($sDateTo, 4)
	If (Int($sMDend) < Int($sMDstart)) Then $sMDend = @YEAR + 1 & StringRight($sDateTo, 4)
	For $iYear = 0 To 2
		$sDateFrom = GetIniDateValue(_DateAdd("Y", $iYear, GetDateValue($sMDstart)))
		$sDateTo = GetIniDateValue(_DateAdd("Y", $iYear, GetDateValue($sMDend)))
		Local $sValue = "0|1"
		$sValue &= "|" & $sDateFrom & "-" & $sDateTo
		$sValue &= "|" & $sSummary
		;ConsoleWrite(" todo: $sDateFrom=" & $sDateFrom & " $sDateTo=" & $sDateTo & @CRLF)
		_ArrayAdd($aArray, $sValue)
	Next
EndFunc   ;==>ImportEvent_Offtimes

; #FUNCTION# ====================================================================================================================
; Name ..........: ImportEvent_Events
; Description ...: Import some Event
; Syntax ........: ImportEvent_Events($aArray, ...)
; Author ........: Tino Reichardt
; Modified ......: 19.08.2016
; ===============================================================================================================================
Func ImportEvent_Events($aArray, $sStart, $sEnd, $sSummary, $iRepeatYear)
EndFunc   ;==>ImportEvent_Events

; #FUNCTION# ====================================================================================================================
; Name ..........: ImportEvent
; Description ...: import schedule settings from iCalendar Format Files
; Syntax ........: ImportEvent()
; Author ........: Tino Reichardt
; Modified ......: 12.08.2016
; ===============================================================================================================================
Func ImportEvent(ByRef $aArray, $iType)
	Local $sFile = FileOpenDialog($sTitle & " - Kalander öffnen", "", "iCalender Format (*.ics)", $FD_FILEMUSTEXIST)
	If @error Then Return
	Local $hFile = FileOpen($sFile, BitOR($FO_READ, $FO_FULLFILE_DETECT))

	Local $sLine, $sStart, $sEnd, $sSummary, $iRepeatYear
	Local $sTimeStart, $sTimeEnd

	$sLine = FileReadLine($hFile, 1)
	If $sLine <> "BEGIN:VCALENDAR" Then Return ImportEvent_WrongFormat()
	$sLine = FileReadLine($hFile, 2)
	If $sLine <> "VERSION:2.0" Then Return ImportEvent_WrongFormat()
	Local $iError, $iLine = 3
	Do
		Local $sLine = FileReadLine($hFile, $iLine)
		$iError = @error
		$iLine += 1

		If $sLine = "BEGIN:VEVENT" Then
			$sStart = ""
			$sEnd = ""
			$sSummary = ""
			$sTimeStart = ""
			$sTimeEnd = ""
			$iRepeatYear = 0
			ContinueLoop
		EndIf

		; DTSTART;VALUE=DATE:19980118
		If StringLeft($sLine, 19) = "DTSTART;VALUE=DATE:" Then
			$sStart = StringMid($sLine, 20)
			ContinueLoop
		EndIf

		; DTSTART:19980118T230000
		; DTSTART:19980118T230000Z
		If StringLeft($sLine, 8) = "DTSTART:" Then
			$sStart = StringMid($sLine, 9)
			$sTimeStart = StringMid($sLine, 18, 6)
			ContinueLoop
		EndIf

		; DTEND;VALUE=DATE:19980118
		If StringLeft($sLine, 17) = "DTEND;VALUE=DATE:" Then
			$sEnd = StringMid($sLine, 18)
			ContinueLoop
		EndIf

		; DTEND:19980118T230000
		; DTEND:19980118T230000Z
		If StringLeft($sLine, 6) = "DTEND:" Then
			$sEnd = StringMid($sLine, 7)
			$sTimeEnd = StringMid($sLine, 16, 6)
			ContinueLoop
		EndIf

		If StringLeft($sLine, 8) = "SUMMARY:" Then
			$sSummary = StringMid($sLine, 9)
			ContinueLoop
		EndIf

		If $sLine = "RRULE:FREQ=YEARLY;INTERVAL=1" Then
			$iRepeatYear = 1
			ContinueLoop
		EndIf

		; [4] 20001003|20001004|Tag der Deutschen Einheit|1
		; [8] 20150514|20150515|Christi Himmelfahrt|0
		If $sLine = "END:VEVENT" Then
			If StringLen($sStart) = 0 Then ContinueLoop
			If StringLen($sSummary) = 0 Then ContinueLoop
			Switch $iType
				Case $eLV_Offtimes
					; 1=1|YYYYmmdd-YYYYmmdd|Description
					ImportEvent_Offtimes($aArray, $sStart, $sEnd, $sSummary, $iRepeatYear)
				Case $eLV_Events
					; 1=1|YYYYmmdd|HHMM-HHMM|Layout|Description
					ImportEvent_Events($aArray, $sStart, $sEnd, $sSummary, $iRepeatYear)
			EndSwitch
		EndIf
	Until $iError <> 0
	FileClose($hFile)

	; to check...
	Switch $iType
		Case $eLV_Offtimes
			; 1=1|YYYYmmdd-YYYYmmdd|Description
			ShowOfftimes()
		Case $eLV_Events
			; 1=1|YYYYmmdd|HHMM-HHMM|Layout|Description
			ShowEvents()
	EndSwitch

EndFunc   ;==>ImportEvent

; #FUNCTION# ====================================================================================================================
; Name ..........: SetCurrentTab
; Description ...: Tabwechsel machen, also setzen + Focus
; Syntax ........: SetCurrentTab($id - 0..3)
; Author ........: Tino Reichardt
; Modified ......: 19.08.2016
; ===============================================================================================================================
Func SetCurrentTab($id)
	Switch $id
		Case 0
			_GUICtrlTab_ActivateTab($idTab, 0)
			ControlFocus("", "", $hListWeekplan)
		Case 1
			_GUICtrlTab_ActivateTab($idTab, 1)
			ControlFocus("", "", $hListOfftimes)
		Case 2
			_GUICtrlTab_ActivateTab($idTab, 2)
			ControlFocus("", "", $hListEvents)
		Case 3
			_GUICtrlTab_ActivateTab($idTab, 3)
			ControlFocus("", "", $hListMacs)
	EndSwitch
EndFunc   ;==>SetCurrentTab

; #FUNCTION# ====================================================================================================================
; Name ..........: WM_CONTEXTMENU
; Description ...: catch right click on some area
; Syntax ........: WM_CONTEXTMENU()
; Author ........: Tino Reichardt
; Modified ......: 12.08.2016
; ===============================================================================================================================
Func WM_CONTEXTMENU($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam, $lParam
	; ConsoleWrite("WM_CONTEXTMENU $hWnd=" & $hWnd & " $iMsg=" & $iMsg & " $wParam=" & $wParam & " $lParam=" & $lParam & @CRLF)

	If $wParam = $hListWeekplan Or $wParam = $hListOfftimes Or $wParam = $hListEvents Or $wParam = $hListMacs Then
		Local $hMenu = _GUICtrlMenu_CreatePopup()
		_GUICtrlMenu_InsertMenuItem($hMenu, 0, "Hinzufügen", $eCM_Add)
		If _GUICtrlListView_GetSelectedCount($wParam) = 1 Then _GUICtrlMenu_InsertMenuItem($hMenu, 1, "Bearbeiten", $eCM_Edit)
		If _GUICtrlListView_GetSelectedCount($wParam) >= 1 Then _GUICtrlMenu_InsertMenuItem($hMenu, 2, "Löschen", $eCM_Delete)

		; If $wParam = $hListOfftimes Or $wParam = $hListEvents Then
		If $wParam = $hListOfftimes Then
			; import offtimes or events
			_GUICtrlMenu_InsertMenuItem($hMenu, 3, "")
			_GUICtrlMenu_InsertMenuItem($hMenu, 4, "Importieren", $eCM_Import)
		EndIf

		GUICtrlSendToDummy($idContextMenuOf, $wParam)
		_GUICtrlMenu_TrackPopupMenu($hMenu, $hGUI)
		_GUICtrlMenu_DestroyMenu($hMenu)
	EndIf

	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_CONTEXTMENU

; #FUNCTION# ====================================================================================================================
; Name ..........: WM_COMMAND
; Description ...: what has do be done, when clicking on some area
; Syntax ........: WM_COMMAND()
; Author ........: Tino Reichardt
; Modified ......: 12.08.2016
; ===============================================================================================================================
Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam, $lParam
	; ConsoleWrite("WM_COMMAND $hWnd=" & $hWnd & " $iMsg=" & $iMsg & " $wParam=" & $wParam & " $lParam=" & $lParam & @CRLF)

	; run command of centext menu
	If $iMsg = 273 Then
		Local $hMenu = HWnd(GUICtrlRead($idContextMenuOf))
		GUICtrlSendToDummy($idContextMenuOf, 0)

		If $hMenu = $hListWeekplan Then
			Switch $wParam
				Case $eCM_Add
					_GUICtrlListView_SetItemSelected($hMenu, -1, False)
					EditWeekplan()
				Case $eCM_Edit
					EditWeekplan()
				Case $eCM_Delete
					_GUICtrlListView_DeleteItemsSelected($hMenu)
					ShowWeekplan()
			EndSwitch
		ElseIf $hMenu = $hListOfftimes Then
			Switch $wParam
				Case $eCM_Add
					_GUICtrlListView_SetItemSelected($hMenu, -1, False)
					EditOfftimes()
				Case $eCM_Edit
					EditOfftimes()
				Case $eCM_Delete
					_GUICtrlListView_DeleteItemsSelected($hMenu)
					ShowOfftimes()
				Case $eCM_Import
					ImportEvent($aOfftimes, $eLV_Offtimes)
			EndSwitch
		ElseIf $hMenu = $hListEvents Then
			Switch $wParam
				Case $eCM_Add
					_GUICtrlListView_SetItemSelected($hMenu, -1, False)
					EditEvents()
				Case $eCM_Edit
					EditEvents()
				Case $eCM_Delete
					_GUICtrlListView_DeleteItemsSelected($hMenu)
					ShowEvents()
				Case $eCM_Import
					ImportEvent($aEvents, $eLV_Events)
			EndSwitch
		ElseIf $hMenu = $hListMacs Then
			Switch $wParam
				Case $eCM_Add
					_GUICtrlListView_SetItemSelected($hMenu, -1, False)
					EditMacs()
				Case $eCM_Edit
					EditMacs()
				Case $eCM_Delete
					_GUICtrlListView_DeleteItemsSelected($hMenu)
					ShowMacs()
			EndSwitch
		EndIf
	EndIf

	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_COMMAND

; #FUNCTION# ====================================================================================================================
; Name ..........: WM_NOTIFY
; Description ...: catch clicks, double clicks or right click
; Syntax ........: WM_NOTIFY()
; Author ........: Tino Reichardt
; Modified ......: 17.08.2016
; ===============================================================================================================================
Func WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam, $lParam
	; ConsoleWrite("WM_NOTIFY $hWnd=" & $hWnd & " $iMsg=" & $iMsg & " $wParam=" & $wParam & " $lParam=" & $lParam & @CRLF)

	Local $tNMHDR = DllStructCreate($tagNMHDR, $lParam)
	Local $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
	Local $iCode = DllStructGetData($tNMHDR, "Code")

	If $iCode = $LVN_ITEMCHANGED Then
		Local $tInfo = DllStructCreate($tagNMLISTVIEW, $lParam)
		Local $iItem = DllStructGetData($tInfo, "Item")
		Local $iNewState = DllStructGetData($tInfo, "NewState")
		Local $tData = DllStructCreate($tagCheckbox)
		DllStructSetData($tData, 'hWndFrom', $hWndFrom)
		DllStructSetData($tData, 'Item', $iItem)
		DllStructSetData($tData, 'NewState', $iNewState)
		$tCheckbox = $tData
		GUICtrlSendToDummy($idCheckControl)
		Return $GUI_RUNDEFMSG
	EndIf

	If $hWndFrom = $hListWeekplan Or $hWndFrom = $hListOfftimes Or $hWndFrom = $hListEvents Or $hWndFrom = $hListMacs Then
		If $iCode = $NM_DBLCLK Then GUICtrlSendToDummy($idEditControl, $hWndFrom)
	EndIf

	Switch $hWndFrom
		Case $hDateFrom
			Switch $iCode
				Case $DTN_DATETIMECHANGE
					Local $tInfo = DllStructCreate($tagNMDATETIMECHANGE, $lParam)
					$sDateFrom = StringFormat("%02d", DllStructGetData($tInfo, "Year"))
					$sDateFrom &= StringFormat("%02d", DllStructGetData($tInfo, "Month"))
					$sDateFrom &= StringFormat("%02d", DllStructGetData($tInfo, "Day"))
					$sTimeFrom = StringFormat("%02d", DllStructGetData($tInfo, "Hour"))
					$sTimeFrom &= StringFormat("%02d", DllStructGetData($tInfo, "Minute"))
			EndSwitch
		Case $hDateTo
			Switch $iCode
				Case $DTN_DATETIMECHANGE
					Local $tInfo = DllStructCreate($tagNMDATETIMECHANGE, $lParam)
					$sDateTo = StringFormat("%02d", DllStructGetData($tInfo, "Year"))
					$sDateTo &= StringFormat("%02d", DllStructGetData($tInfo, "Month"))
					$sDateTo &= StringFormat("%02d", DllStructGetData($tInfo, "Day"))
					$sTimeTo = StringFormat("%02d", DllStructGetData($tInfo, "Hour"))
					$sTimeTo &= StringFormat("%02d", DllStructGetData($tInfo, "Minute"))
			EndSwitch
	EndSwitch

	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY

; we should get started with some filename
If $CmdLine[0] = 1 Then
	$sDSBS_Filename = $CmdLine[1]
	Local $sDrive, $sDir, $sFile, $sExtension
	_PathSplit($sDSBS_Filename, $sDrive, $sDir, $sFile, $sExtension)
	$sLayoutPath = $sDrive & $sDir
EndIf

If Not FileExists($sDSBS_Filename) Then
	Local $iError = FileWrite($sDSBS_Filename, "# DSBS Schedule Version 1.0" & @CRLF)
	If $iError <> 1 Then
		MsgBox($MB_SYSTEMMODAL + $MB_ICONERROR, $sTitle, "Kann Zeitplan '" & $sDSBS_Filename & "' nicht öffnen!")
		Exit
	EndIf
EndIf

; Main entry point
InitMainWindow()
Schedule_Open($sDSBS_Filename)

; Shortcuts for CTRL+1 .. CTRL+4
Local $idTabWeekplan = GUICtrlCreateDummy()
Local $idTabOfftimes = GUICtrlCreateDummy()
Local $idTabEvents = GUICtrlCreateDummy()
Local $idTabMacs = GUICtrlCreateDummy()
Local $idTabNext = GUICtrlCreateDummy()
Local $idTabPrev = GUICtrlCreateDummy()
Local $idEditEntry = GUICtrlCreateDummy()
Local $idDelete = GUICtrlCreateDummy()
Local $aAccelKeys[9][2] = [ _
		["{F2}", $idEditEntry], _ ; edit on tables, most mapps
		["{DEL}", $idDelete], _ ; delete entry, msgbox before that
		["{i}", $idButtonInfo], _ ; info
		["^{PGDN}", $idTabNext], _ ; next tab
		["^{PGUP}", $idTabPrev], _ ; previous tab
		["^1", $idTabWeekplan], _
		["^2", $idTabOfftimes], _
		["^3", $idTabEvents], _
		["^4", $idTabMacs]]
GUISetAccelerators($aAccelKeys, $hGUI)

; get all gui messages, until noop
; this is needed, for setting the $idButtonSave button to disabled
While 1
	Local $iMsg = GUIGetMsg()
	If $iMsg = $GUI_EVENT_NONE Then ExitLoop
WEnd

If $iInvalid > 0 Then
	MsgBox(BitOR($MB_OK, $MB_ICONINFORMATION), $sTitle, "Einige Einträge waren ungültig!")
	GUICtrlSetState($idButtonSave, $GUI_ENABLE)
Else
	GUICtrlSetState($idButtonSave, $GUI_DISABLE)
EndIf

; Mainloop
While 1
	Local $iMsg = GUIGetMsg()

	; ignore some messages
	If $iMsg = $GUI_EVENT_NONE Then ContinueLoop
	If $iMsg = $GUI_EVENT_MOUSEMOVE Then ContinueLoop
	If $iMsg = $GUI_EVENT_PRIMARYUP Then ContinueLoop
	If $iMsg = $GUI_EVENT_PRIMARYDOWN Then ContinueLoop
	If $iMsg = $GUI_EVENT_SECONDARYUP Then ContinueLoop
	If $iMsg = $GUI_EVENT_SECONDARYDOWN Then ContinueLoop
	; ConsoleWrite("$iMsg =" & $iMsg & @CRLF)

	Switch $iMsg
		Case $idButtonInfo
			Local $sText = ""
			$sText &= "Copyright 2016, Tino Reichardt" & @CRLF & @CRLF
			$sText &= "Version: " & $sVersion & " (" & FileGetVersion(@ScriptFullPath) & ") " & @CRLF
			MsgBox(BitOR($MB_OK, $MB_ICONINFORMATION), $sTitle, $sText)

		Case $idButtonSave
			Schedule_Save($sDSBS_Filename)

		Case $idButtonOkay
			Schedule_Save($sDSBS_Filename)
			Exit

		Case $idButtonCancel, $GUI_EVENT_CLOSE
			; nothing saved...
			Exit

		Case $idDelete
			; edit entries via ENTER or double click
			Local $tData = $tCheckbox
			Local $hWndFrom = DllStructGetData($tData, "hWndFrom")
			If _GUICtrlListView_GetSelectedCount($hWndFrom) > 1 Then
				Local $sMessage = "Einträge löschen?"
			Else
				Local $sMessage = "Eintrag löschen?"
			EndIf
			If MsgBox($MB_YESNO, $sTitle, $sMessage) = $IDYES Then
				_GUICtrlListView_DeleteItemsSelected($hWndFrom)
				Switch $hWndFrom
					Case $hListWeekplan
						ShowWeekplan()
					Case $hListOfftimes
						ShowOfftimes()
					Case $hListEvents
						ShowEvents()
					Case $hListMacs
						ShowMacs()
				EndSwitch
			EndIf

		Case $idEditEntry, $idEditControl
			; edit entries via F2 or double click
			If $iMsg = $idEditControl Then
				Local $hWndFrom = GUICtrlRead($idEditControl)
			Else
				Local $tData = $tCheckbox
				Local $hWndFrom = DllStructGetData($tData, "hWndFrom")
			EndIf
			Switch $hWndFrom
				Case $hListWeekplan
					EditWeekplan()
				Case $hListOfftimes
					EditOfftimes()
				Case $hListEvents
					EditEvents()
				Case $hListMacs
					EditMacs()
			EndSwitch

		Case $idTabWeekplan
			SetCurrentTab(0)
		Case $idTabOfftimes
			SetCurrentTab(1)
		Case $idTabEvents
			SetCurrentTab(2)
		Case $idTabMacs
			SetCurrentTab(3)

		Case $idTabNext
			Local $iCur = _GUICtrlTab_GetCurSel($idTab)
			If $iCur = 3 Then
				$iCur = 0
			Else
				$iCur += 1
			EndIf
			SetCurrentTab($iCur)

		Case $idTabPrev
			Local $iCur = _GUICtrlTab_GetCurSel($idTab)
			If $iCur = 0 Then
				$iCur = 3
			Else
				$iCur -= 1
			EndIf
			SetCurrentTab($iCur)

		Case $idCheckControl
			Local $tData = $tCheckbox
			Local $iNewState = DllStructGetData($tData, "NewState")
			If Not (($iNewState = 4096) Or ($iNewState = 8192)) Then ContinueLoop
			Local $hWndFrom = DllStructGetData($tData, "hWndFrom")
			Local $iItem = DllStructGetData($tData, "Item")
			Switch $hWndFrom
				Case $hListWeekplan
					If $iNewState = 4096 Then $aWeekplan[$iItem][1] = "0"
					If $iNewState = 8192 Then $aWeekplan[$iItem][1] = "1"
				Case $hListOfftimes
					If $iNewState = 4096 Then $aOfftimes[$iItem][1] = "0"
					If $iNewState = 8192 Then $aOfftimes[$iItem][1] = "1"
				Case $hListEvents
					If $iNewState = 4096 Then $aEvents[$iItem][1] = "0"
					If $iNewState = 8192 Then $aEvents[$iItem][1] = "1"
				Case $hListMacs
					If $iNewState = 4096 Then $aMACs[$iItem][1] = "0"
					If $iNewState = 8192 Then $aMACs[$iItem][1] = "1"
			EndSwitch
			GUICtrlSetState($idButtonSave, $GUI_ENABLE)

		Case $idListWeekplan
			SortListView($aWeekplan, $eLV_Weekplan)
		Case $idListOfftimes
			SortListView($aOfftimes, $eLV_Offtimes)
		Case $idListEvents
			SortListView($aEvents, $eLV_Events)
		Case $idListMacs
			SortListView($aMACs, $eLV_Macs)
	EndSwitch
WEnd
