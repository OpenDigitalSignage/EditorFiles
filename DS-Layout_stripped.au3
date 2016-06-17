#NoTrayIcon
Global Const $IDC_SIZEALL = 9
Global Const $IDC_SIZENESW = 10
Global Const $IDC_SIZENS = 11
Global Const $IDC_SIZENWSE = 12
Global Const $IDC_SIZEWE = 13
Global Const $UBOUND_DIMENSIONS = 0
Global Const $UBOUND_ROWS = 1
Global Const $UBOUND_COLUMNS = 2
Global Const $HWND_BOTTOM = 1
Global Const $SWP_NOSIZE = 0x0001
Global Const $SWP_NOMOVE = 0x0002
Global Const $SWP_NOCOPYBITS = 0x0100
Global Const $MB_OK = 0
Global Const $MB_YESNO = 4
Global Const $MB_ICONERROR = 16
Global Const $MB_ICONQUESTION = 32
Global Const $MB_ICONINFORMATION = 64
Global Const $IDYES = 6
Global Const $STR_STRIPLEADING = 1
Global Const $STR_STRIPTRAILING = 2
Global Const $STR_ENTIRESPLIT = 1
Global Const $STR_NOCOUNT = 2
Global Const $STR_REGEXPARRAYMATCH = 1
Func _ArrayAdd(ByRef $avArray, $vValue, $iStart = 0, $sDelim_Item = "|", $sDelim_Row = @CRLF, $hDataType = 0)
If $iStart = Default Then $iStart = 0
If $sDelim_Item = Default Then $sDelim_Item = "|"
If $sDelim_Row = Default Then $sDelim_Row = @CRLF
If $hDataType = Default Then $hDataType = 0
If Not IsArray($avArray) Then Return SetError(1, 0, -1)
Local $iDim_1 = UBound($avArray, $UBOUND_ROWS)
Switch UBound($avArray, $UBOUND_DIMENSIONS)
Case 1
If IsArray($vValue) Then
If UBound($vValue, $UBOUND_DIMENSIONS) <> 1 Then Return SetError(5, 0, -1)
$hDataType = 0
Else
Local $aTmp = StringSplit($vValue, $sDelim_Item, $STR_NOCOUNT + $STR_ENTIRESPLIT)
If UBound($aTmp, $UBOUND_ROWS) = 1 Then
$aTmp[0] = $vValue
$hDataType = 0
EndIf
$vValue = $aTmp
EndIf
Local $iAdd = UBound($vValue, $UBOUND_ROWS)
ReDim $avArray[$iDim_1 + $iAdd]
For $i = 0 To $iAdd - 1
If IsFunc($hDataType) Then
$avArray[$iDim_1 + $i] = $hDataType($vValue[$i])
Else
$avArray[$iDim_1 + $i] = $vValue[$i]
EndIf
Next
Return $iDim_1 + $iAdd - 1
Case 2
Local $iDim_2 = UBound($avArray, $UBOUND_COLUMNS)
If $iStart < 0 Or $iStart > $iDim_2 - 1 Then Return SetError(4, 0, -1)
Local $iValDim_1, $iValDim_2
If IsArray($vValue) Then
If UBound($vValue, $UBOUND_DIMENSIONS) <> 2 Then Return SetError(5, 0, -1)
$iValDim_1 = UBound($vValue, $UBOUND_ROWS)
$iValDim_2 = UBound($vValue, $UBOUND_COLUMNS)
$hDataType = 0
Else
Local $aSplit_1 = StringSplit($vValue, $sDelim_Row, $STR_NOCOUNT + $STR_ENTIRESPLIT)
$iValDim_1 = UBound($aSplit_1, $UBOUND_ROWS)
StringReplace($aSplit_1[0], $sDelim_Item, "")
$iValDim_2 = @extended + 1
Local $aTmp[$iValDim_1][$iValDim_2], $aSplit_2
For $i = 0 To $iValDim_1 - 1
$aSplit_2 = StringSplit($aSplit_1[$i], $sDelim_Item, $STR_NOCOUNT + $STR_ENTIRESPLIT)
For $j = 0 To $iValDim_2 - 1
$aTmp[$i][$j] = $aSplit_2[$j]
Next
Next
$vValue = $aTmp
EndIf
If UBound($vValue, $UBOUND_COLUMNS) + $iStart > UBound($avArray, $UBOUND_COLUMNS) Then Return SetError(3, 0, -1)
ReDim $avArray[$iDim_1 + $iValDim_1][$iDim_2]
For $iWriteTo_Index = 0 To $iValDim_1 - 1
For $j = 0 To $iDim_2 - 1
If $j < $iStart Then
$avArray[$iWriteTo_Index + $iDim_1][$j] = ""
ElseIf $j - $iStart > $iValDim_2 - 1 Then
$avArray[$iWriteTo_Index + $iDim_1][$j] = ""
Else
If IsFunc($hDataType) Then
$avArray[$iWriteTo_Index + $iDim_1][$j] = $hDataType($vValue[$iWriteTo_Index][$j - $iStart])
Else
$avArray[$iWriteTo_Index + $iDim_1][$j] = $vValue[$iWriteTo_Index][$j - $iStart]
EndIf
EndIf
Next
Next
Case Else
Return SetError(2, 0, -1)
EndSwitch
Return UBound($avArray, $UBOUND_ROWS) - 1
EndFunc
Func _ArrayDelete(ByRef $avArray, $vRange)
If Not IsArray($avArray) Then Return SetError(1, 0, -1)
Local $iDim_1 = UBound($avArray, $UBOUND_ROWS) - 1
If IsArray($vRange) Then
If UBound($vRange, $UBOUND_DIMENSIONS) <> 1 Or UBound($vRange, $UBOUND_ROWS) < 2 Then Return SetError(4, 0, -1)
Else
Local $iNumber, $aSplit_1, $aSplit_2
$vRange = StringStripWS($vRange, 8)
$aSplit_1 = StringSplit($vRange, ";")
$vRange = ""
For $i = 1 To $aSplit_1[0]
If Not StringRegExp($aSplit_1[$i], "^\d+(-\d+)?$") Then Return SetError(3, 0, -1)
$aSplit_2 = StringSplit($aSplit_1[$i], "-")
Switch $aSplit_2[0]
Case 1
$vRange &= $aSplit_2[1] & ";"
Case 2
If Number($aSplit_2[2]) >= Number($aSplit_2[1]) Then
$iNumber = $aSplit_2[1] - 1
Do
$iNumber += 1
$vRange &= $iNumber & ";"
Until $iNumber = $aSplit_2[2]
EndIf
EndSwitch
Next
$vRange = StringSplit(StringTrimRight($vRange, 1), ";")
EndIf
If $vRange[1] < 0 Or $vRange[$vRange[0]] > $iDim_1 Then Return SetError(5, 0, -1)
Local $iCopyTo_Index = 0
Switch UBound($avArray, $UBOUND_DIMENSIONS)
Case 1
For $i = 1 To $vRange[0]
$avArray[$vRange[$i]] = ChrW(0xFAB1)
Next
For $iReadFrom_Index = 0 To $iDim_1
If $avArray[$iReadFrom_Index] == ChrW(0xFAB1) Then
ContinueLoop
Else
If $iReadFrom_Index <> $iCopyTo_Index Then
$avArray[$iCopyTo_Index] = $avArray[$iReadFrom_Index]
EndIf
$iCopyTo_Index += 1
EndIf
Next
ReDim $avArray[$iDim_1 - $vRange[0] + 1]
Case 2
Local $iDim_2 = UBound($avArray, $UBOUND_COLUMNS) - 1
For $i = 1 To $vRange[0]
$avArray[$vRange[$i]][0] = ChrW(0xFAB1)
Next
For $iReadFrom_Index = 0 To $iDim_1
If $avArray[$iReadFrom_Index][0] == ChrW(0xFAB1) Then
ContinueLoop
Else
If $iReadFrom_Index <> $iCopyTo_Index Then
For $j = 0 To $iDim_2
$avArray[$iCopyTo_Index][$j] = $avArray[$iReadFrom_Index][$j]
Next
EndIf
$iCopyTo_Index += 1
EndIf
Next
ReDim $avArray[$iDim_1 - $vRange[0] + 1][$iDim_2 + 1]
Case Else
Return SetError(2, 0, False)
EndSwitch
Return UBound($avArray, $UBOUND_ROWS)
EndFunc
Global Const $BS_FLAT = 0x8000
Global Const $BCM_FIRST = 0x1600
Global Const $BCM_SETIMAGELIST =($BCM_FIRST + 0x0002)
Global Const $CBS_AUTOHSCROLL = 0x40
Global Const $CBS_DROPDOWN = 0x2
Global Const $ES_CENTER = 1
Global Const $ES_NUMBER = 8192
Global Const $FD_FILEMUSTEXIST = 1
Func _PathSplit($sFilePath, ByRef $sDrive, ByRef $sDir, ByRef $sFileName, ByRef $sExtension)
Local $aArray = StringRegExp($sFilePath, "^\h*((?:\\\\\?\\)*(\\\\[^\?\/\\]+|[A-Za-z]:)?(.*[\/\\]\h*)?((?:[^\.\/\\]|(?(?=\.[^\/\\]*\.)\.))*)?([^\/\\]*))$", $STR_REGEXPARRAYMATCH)
If @error Then
ReDim $aArray[5]
$aArray[0] = $sFilePath
EndIf
$sDrive = $aArray[1]
If StringLeft($aArray[2], 1) == "/" Then
$sDir = StringRegExpReplace($aArray[2], "\h*[\/\\]+\h*", "\/")
Else
$sDir = StringRegExpReplace($aArray[2], "\h*[\/\\]+\h*", "\\")
EndIf
$sFileName = $aArray[3]
$sExtension = $aArray[4]
Return $aArray
EndFunc
Global Const $tagPOINT = "struct;long X;long Y;endstruct"
Global Const $tagRECT = "struct;long Left;long Top;long Right;long Bottom;endstruct"
Global Const $tagGDIPBITMAPDATA = "uint Width;uint Height;int Stride;int Format;ptr Scan0;uint_ptr Reserved"
Global Const $tagGDIPSTARTUPINPUT = "uint Version;ptr Callback;bool NoThread;bool NoCodecs"
Global Const $tagMENUINFO = "dword Size;INT Mask;dword Style;uint YMax;handle hBack;dword ContextHelpID;ulong_ptr MenuData"
Global Const $tagMENUITEMINFO = "uint Size;uint Mask;uint Type;uint State;uint ID;handle SubMenu;handle BmpChecked;handle BmpUnchecked;" & "ulong_ptr ItemData;ptr TypeData;uint CCH;handle BmpItem"
Global Const $tagREBARBANDINFO = "uint cbSize;uint fMask;uint fStyle;dword clrFore;dword clrBack;ptr lpText;uint cch;" & "int iImage;hwnd hwndChild;uint cxMinChild;uint cyMinChild;uint cx;handle hbmBack;uint wID;uint cyChild;uint cyMaxChild;" & "uint cyIntegral;uint cxIdeal;lparam lParam;uint cxHeader" &((@OSVersion = "WIN_XP") ? "" : ";" & $tagRECT & ";uint uChevronState")
Global Const $tagTBBUTTON = "int Bitmap;int Command;byte State;byte Style;dword_ptr Param;int_ptr String"
Global Const $tagSECURITY_ATTRIBUTES = "dword Length;ptr Descriptor;bool InheritHandle"
Func _WinAPI_GetLastError($iError = @error, $iExtended = @extended)
Local $aResult = DllCall("kernel32.dll", "dword", "GetLastError")
Return SetError($iError, $iExtended, $aResult[0])
EndFunc
Func _Singleton($sOccurenceName, $iFlag = 0)
Local Const $ERROR_ALREADY_EXISTS = 183
Local Const $SECURITY_DESCRIPTOR_REVISION = 1
Local $tSecurityAttributes = 0
If BitAND($iFlag, 2) Then
Local $tSecurityDescriptor = DllStructCreate("byte;byte;word;ptr[4]")
Local $aRet = DllCall("advapi32.dll", "bool", "InitializeSecurityDescriptor", "struct*", $tSecurityDescriptor, "dword", $SECURITY_DESCRIPTOR_REVISION)
If @error Then Return SetError(@error, @extended, 0)
If $aRet[0] Then
$aRet = DllCall("advapi32.dll", "bool", "SetSecurityDescriptorDacl", "struct*", $tSecurityDescriptor, "bool", 1, "ptr", 0, "bool", 0)
If @error Then Return SetError(@error, @extended, 0)
If $aRet[0] Then
$tSecurityAttributes = DllStructCreate($tagSECURITY_ATTRIBUTES)
DllStructSetData($tSecurityAttributes, 1, DllStructGetSize($tSecurityAttributes))
DllStructSetData($tSecurityAttributes, 2, DllStructGetPtr($tSecurityDescriptor))
DllStructSetData($tSecurityAttributes, 3, 0)
EndIf
EndIf
EndIf
Local $aHandle = DllCall("kernel32.dll", "handle", "CreateMutexW", "struct*", $tSecurityAttributes, "bool", 1, "wstr", $sOccurenceName)
If @error Then Return SetError(@error, @extended, 0)
Local $aLastError = DllCall("kernel32.dll", "dword", "GetLastError")
If @error Then Return SetError(@error, @extended, 0)
If $aLastError[0] = $ERROR_ALREADY_EXISTS Then
If BitAND($iFlag, 1) Then
DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $aHandle[0])
If @error Then Return SetError(@error, @extended, 0)
Return SetError($aLastError[0], $aLastError[0], 0)
Else
Exit -1
EndIf
EndIf
Return $aHandle[0]
EndFunc
Global Const $GUI_EVENT_CLOSE = -3
Global Const $GUI_EVENT_PRIMARYDOWN = -7
Global Const $GUI_EVENT_PRIMARYUP = -8
Global Const $GUI_EVENT_SECONDARYDOWN = -9
Global Const $GUI_EVENT_SECONDARYUP = -10
Global Const $GUI_EVENT_MOUSEMOVE = -11
Global Const $GUI_RUNDEFMSG = 'GUI_RUNDEFMSG'
Global Const $GUI_ENABLE = 64
Global Const $GUI_DISABLE = 128
Global Const $GUI_DOCKLEFT = 0x0002
Global Const $GUI_DOCKTOP = 0x0020
Global Const $GUI_DOCKWIDTH = 0x0100
Global Const $GUI_DOCKHEIGHT = 0x0200
Global Const $SS_NOTIFY = 0x0100
Global Const $UDS_ARROWKEYS = 0x0020
Global Const $WS_BORDER = 0x00800000
Global Const $WS_EX_APPWINDOW = 0x00040000
Global Const $WS_EX_TOOLWINDOW = 0x00000080
Global Const $WM_COPYDATA = 0x004A
Global Const $WM_NOTIFY = 0x004E
Global Const $WM_CONTEXTMENU = 0x007B
Global Const $WM_COMMAND = 0x0111
Global Const $NM_FIRST = 0
Global Const $NM_CLICK = $NM_FIRST - 2
Global Const $WM_LBUTTONDBLCLK = 0x0203
Global Const $IDB_STD_LARGE_COLOR = 1
Func _SendMessage($hWnd, $iMsg, $wParam = 0, $lParam = 0, $iReturn = 0, $wParamType = "wparam", $lParamType = "lparam", $sReturnType = "lresult")
Local $aResult = DllCall("user32.dll", $sReturnType, "SendMessageW", "hwnd", $hWnd, "uint", $iMsg, $wParamType, $wParam, $lParamType, $lParam)
If @error Then Return SetError(@error, @extended, "")
If $iReturn >= 0 And $iReturn <= 4 Then Return $aResult[$iReturn]
Return $aResult
EndFunc
Global Const $SE_PRIVILEGE_ENABLED = 0x00000002
Global Enum $SECURITYANONYMOUS = 0, $SECURITYIDENTIFICATION, $SECURITYIMPERSONATION, $SECURITYDELEGATION
Global Const $TOKEN_QUERY = 0x00000008
Global Const $TOKEN_ADJUST_PRIVILEGES = 0x00000020
Func _Security__AdjustTokenPrivileges($hToken, $bDisableAll, $pNewState, $iBufferLen, $pPrevState = 0, $pRequired = 0)
Local $aCall = DllCall("advapi32.dll", "bool", "AdjustTokenPrivileges", "handle", $hToken, "bool", $bDisableAll, "struct*", $pNewState, "dword", $iBufferLen, "struct*", $pPrevState, "struct*", $pRequired)
If @error Then Return SetError(@error, @extended, False)
Return Not($aCall[0] = 0)
EndFunc
Func _Security__ImpersonateSelf($iLevel = $SECURITYIMPERSONATION)
Local $aCall = DllCall("advapi32.dll", "bool", "ImpersonateSelf", "int", $iLevel)
If @error Then Return SetError(@error, @extended, False)
Return Not($aCall[0] = 0)
EndFunc
Func _Security__LookupPrivilegeValue($sSystem, $sName)
Local $aCall = DllCall("advapi32.dll", "bool", "LookupPrivilegeValueW", "wstr", $sSystem, "wstr", $sName, "int64*", 0)
If @error Or Not $aCall[0] Then Return SetError(@error, @extended, 0)
Return $aCall[3]
EndFunc
Func _Security__OpenThreadToken($iAccess, $hThread = 0, $bOpenAsSelf = False)
If $hThread = 0 Then
Local $aResult = DllCall("kernel32.dll", "handle", "GetCurrentThread")
If @error Then Return SetError(@error + 10, @extended, 0)
$hThread = $aResult[0]
EndIf
Local $aCall = DllCall("advapi32.dll", "bool", "OpenThreadToken", "handle", $hThread, "dword", $iAccess, "bool", $bOpenAsSelf, "handle*", 0)
If @error Or Not $aCall[0] Then Return SetError(@error, @extended, 0)
Return $aCall[4]
EndFunc
Func _Security__OpenThreadTokenEx($iAccess, $hThread = 0, $bOpenAsSelf = False)
Local $hToken = _Security__OpenThreadToken($iAccess, $hThread, $bOpenAsSelf)
If $hToken = 0 Then
Local Const $ERROR_NO_TOKEN = 1008
If _WinAPI_GetLastError() <> $ERROR_NO_TOKEN Then Return SetError(20, _WinAPI_GetLastError(), 0)
If Not _Security__ImpersonateSelf() Then Return SetError(@error + 10, _WinAPI_GetLastError(), 0)
$hToken = _Security__OpenThreadToken($iAccess, $hThread, $bOpenAsSelf)
If $hToken = 0 Then Return SetError(@error, _WinAPI_GetLastError(), 0)
EndIf
Return $hToken
EndFunc
Func _Security__SetPrivilege($hToken, $sPrivilege, $bEnable)
Local $iLUID = _Security__LookupPrivilegeValue("", $sPrivilege)
If $iLUID = 0 Then Return SetError(@error + 10, @extended, False)
Local Const $tagTOKEN_PRIVILEGES = "dword Count;align 4;int64 LUID;dword Attributes"
Local $tCurrState = DllStructCreate($tagTOKEN_PRIVILEGES)
Local $iCurrState = DllStructGetSize($tCurrState)
Local $tPrevState = DllStructCreate($tagTOKEN_PRIVILEGES)
Local $iPrevState = DllStructGetSize($tPrevState)
Local $tRequired = DllStructCreate("int Data")
DllStructSetData($tCurrState, "Count", 1)
DllStructSetData($tCurrState, "LUID", $iLUID)
If Not _Security__AdjustTokenPrivileges($hToken, False, $tCurrState, $iCurrState, $tPrevState, $tRequired) Then Return SetError(2, @error, False)
DllStructSetData($tPrevState, "Count", 1)
DllStructSetData($tPrevState, "LUID", $iLUID)
Local $iAttributes = DllStructGetData($tPrevState, "Attributes")
If $bEnable Then
$iAttributes = BitOR($iAttributes, $SE_PRIVILEGE_ENABLED)
Else
$iAttributes = BitAND($iAttributes, BitNOT($SE_PRIVILEGE_ENABLED))
EndIf
DllStructSetData($tPrevState, "Attributes", $iAttributes)
If Not _Security__AdjustTokenPrivileges($hToken, False, $tPrevState, $iPrevState, $tCurrState, $tRequired) Then Return SetError(3, @error, False)
Return True
EndFunc
Global Const $HGDI_ERROR = Ptr(-1)
Global Const $INVALID_HANDLE_VALUE = Ptr(-1)
Global Const $KF_EXTENDED = 0x0100
Global Const $KF_ALTDOWN = 0x2000
Global Const $KF_UP = 0x8000
Global Const $LLKHF_EXTENDED = BitShift($KF_EXTENDED, 8)
Global Const $LLKHF_ALTDOWN = BitShift($KF_ALTDOWN, 8)
Global Const $LLKHF_UP = BitShift($KF_UP, 8)
Global Const $STD_FILENEW = 6
Global Const $STD_FILEOPEN = 7
Global Const $STD_FILESAVE = 8
Global $__g_aInProcess_WinAPI[64][2] = [[0, 0]]
Func _WinAPI_CreateWindowEx($iExStyle, $sClass, $sName, $iStyle, $iX, $iY, $iWidth, $iHeight, $hParent, $hMenu = 0, $hInstance = 0, $pParam = 0)
If $hInstance = 0 Then $hInstance = _WinAPI_GetModuleHandle("")
Local $aResult = DllCall("user32.dll", "hwnd", "CreateWindowExW", "dword", $iExStyle, "wstr", $sClass, "wstr", $sName, "dword", $iStyle, "int", $iX, "int", $iY, "int", $iWidth, "int", $iHeight, "hwnd", $hParent, "handle", $hMenu, "handle", $hInstance, "ptr", $pParam)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func _WinAPI_EnableWindow($hWnd, $bEnable = True)
Local $aResult = DllCall("user32.dll", "bool", "EnableWindow", "hwnd", $hWnd, "bool", $bEnable)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func _WinAPI_GetClassName($hWnd)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
Local $aResult = DllCall("user32.dll", "int", "GetClassNameW", "hwnd", $hWnd, "wstr", "", "int", 4096)
If @error Or Not $aResult[0] Then Return SetError(@error, @extended, '')
Return SetExtended($aResult[0], $aResult[2])
EndFunc
Func _WinAPI_GetModuleHandle($sModuleName)
Local $sModuleNameType = "wstr"
If $sModuleName = "" Then
$sModuleName = 0
$sModuleNameType = "ptr"
EndIf
Local $aResult = DllCall("kernel32.dll", "handle", "GetModuleHandleW", $sModuleNameType, $sModuleName)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func _WinAPI_GetMousePos($bToClient = False, $hWnd = 0)
Local $iMode = Opt("MouseCoordMode", 1)
Local $aPos = MouseGetPos()
Opt("MouseCoordMode", $iMode)
Local $tPoint = DllStructCreate($tagPOINT)
DllStructSetData($tPoint, "X", $aPos[0])
DllStructSetData($tPoint, "Y", $aPos[1])
If $bToClient And Not _WinAPI_ScreenToClient($hWnd, $tPoint) Then Return SetError(@error + 20, @extended, 0)
Return $tPoint
EndFunc
Func _WinAPI_GetMousePosX($bToClient = False, $hWnd = 0)
Local $tPoint = _WinAPI_GetMousePos($bToClient, $hWnd)
If @error Then Return SetError(@error, @extended, 0)
Return DllStructGetData($tPoint, "X")
EndFunc
Func _WinAPI_GetMousePosY($bToClient = False, $hWnd = 0)
Local $tPoint = _WinAPI_GetMousePos($bToClient, $hWnd)
If @error Then Return SetError(@error, @extended, 0)
Return DllStructGetData($tPoint, "Y")
EndFunc
Func _WinAPI_GetWindowThreadProcessId($hWnd, ByRef $iPID)
Local $aResult = DllCall("user32.dll", "dword", "GetWindowThreadProcessId", "hwnd", $hWnd, "dword*", 0)
If @error Then Return SetError(@error, @extended, 0)
$iPID = $aResult[2]
Return $aResult[0]
EndFunc
Func _WinAPI_InProcess($hWnd, ByRef $hLastWnd)
If $hWnd = $hLastWnd Then Return True
For $iI = $__g_aInProcess_WinAPI[0][0] To 1 Step -1
If $hWnd = $__g_aInProcess_WinAPI[$iI][0] Then
If $__g_aInProcess_WinAPI[$iI][1] Then
$hLastWnd = $hWnd
Return True
Else
Return False
EndIf
EndIf
Next
Local $iPID
_WinAPI_GetWindowThreadProcessId($hWnd, $iPID)
Local $iCount = $__g_aInProcess_WinAPI[0][0] + 1
If $iCount >= 64 Then $iCount = 1
$__g_aInProcess_WinAPI[0][0] = $iCount
$__g_aInProcess_WinAPI[$iCount][0] = $hWnd
$__g_aInProcess_WinAPI[$iCount][1] =($iPID = @AutoItPID)
Return $__g_aInProcess_WinAPI[$iCount][1]
EndFunc
Func _WinAPI_IsClassName($hWnd, $sClassName)
Local $sSeparator = Opt("GUIDataSeparatorChar")
Local $aClassName = StringSplit($sClassName, $sSeparator)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
Local $sClassCheck = _WinAPI_GetClassName($hWnd)
For $x = 1 To UBound($aClassName) - 1
If StringUpper(StringMid($sClassCheck, 1, StringLen($aClassName[$x]))) = StringUpper($aClassName[$x]) Then Return True
Next
Return False
EndFunc
Func _WinAPI_ScreenToClient($hWnd, ByRef $tPoint)
Local $aResult = DllCall("user32.dll", "bool", "ScreenToClient", "hwnd", $hWnd, "struct*", $tPoint)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func _WinAPI_SetWindowPos($hWnd, $hAfter, $iX, $iY, $iCX, $iCY, $iFlags)
Local $aResult = DllCall("user32.dll", "bool", "SetWindowPos", "hwnd", $hWnd, "hwnd", $hAfter, "int", $iX, "int", $iY, "int", $iCX, "int", $iCY, "uint", $iFlags)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Global Const $_UDF_GlobalIDs_OFFSET = 2
Global Const $_UDF_GlobalID_MAX_WIN = 16
Global Const $_UDF_STARTID = 10000
Global Const $_UDF_GlobalID_MAX_IDS = 55535
Global Const $__UDFGUICONSTANT_WS_VISIBLE = 0x10000000
Global Const $__UDFGUICONSTANT_WS_CHILD = 0x40000000
Global $__g_aUDF_GlobalIDs_Used[$_UDF_GlobalID_MAX_WIN][$_UDF_GlobalID_MAX_IDS + $_UDF_GlobalIDs_OFFSET + 1]
Func __UDF_GetNextGlobalID($hWnd)
Local $nCtrlID, $iUsedIndex = -1, $bAllUsed = True
If Not WinExists($hWnd) Then Return SetError(-1, -1, 0)
For $iIndex = 0 To $_UDF_GlobalID_MAX_WIN - 1
If $__g_aUDF_GlobalIDs_Used[$iIndex][0] <> 0 Then
If Not WinExists($__g_aUDF_GlobalIDs_Used[$iIndex][0]) Then
For $x = 0 To UBound($__g_aUDF_GlobalIDs_Used, $UBOUND_COLUMNS) - 1
$__g_aUDF_GlobalIDs_Used[$iIndex][$x] = 0
Next
$__g_aUDF_GlobalIDs_Used[$iIndex][1] = $_UDF_STARTID
$bAllUsed = False
EndIf
EndIf
Next
For $iIndex = 0 To $_UDF_GlobalID_MAX_WIN - 1
If $__g_aUDF_GlobalIDs_Used[$iIndex][0] = $hWnd Then
$iUsedIndex = $iIndex
ExitLoop
EndIf
Next
If $iUsedIndex = -1 Then
For $iIndex = 0 To $_UDF_GlobalID_MAX_WIN - 1
If $__g_aUDF_GlobalIDs_Used[$iIndex][0] = 0 Then
$__g_aUDF_GlobalIDs_Used[$iIndex][0] = $hWnd
$__g_aUDF_GlobalIDs_Used[$iIndex][1] = $_UDF_STARTID
$bAllUsed = False
$iUsedIndex = $iIndex
ExitLoop
EndIf
Next
EndIf
If $iUsedIndex = -1 And $bAllUsed Then Return SetError(16, 0, 0)
If $__g_aUDF_GlobalIDs_Used[$iUsedIndex][1] = $_UDF_STARTID + $_UDF_GlobalID_MAX_IDS Then
For $iIDIndex = $_UDF_GlobalIDs_OFFSET To UBound($__g_aUDF_GlobalIDs_Used, $UBOUND_COLUMNS) - 1
If $__g_aUDF_GlobalIDs_Used[$iUsedIndex][$iIDIndex] = 0 Then
$nCtrlID =($iIDIndex - $_UDF_GlobalIDs_OFFSET) + 10000
$__g_aUDF_GlobalIDs_Used[$iUsedIndex][$iIDIndex] = $nCtrlID
Return $nCtrlID
EndIf
Next
Return SetError(-1, $_UDF_GlobalID_MAX_IDS, 0)
EndIf
$nCtrlID = $__g_aUDF_GlobalIDs_Used[$iUsedIndex][1]
$__g_aUDF_GlobalIDs_Used[$iUsedIndex][1] += 1
$__g_aUDF_GlobalIDs_Used[$iUsedIndex][($nCtrlID - 10000) + $_UDF_GlobalIDs_OFFSET] = $nCtrlID
Return $nCtrlID
EndFunc
Global Const $MEM_COMMIT = 0x00001000
Global Const $MEM_RESERVE = 0x00002000
Global Const $PAGE_READWRITE = 0x00000004
Global Const $MEM_RELEASE = 0x00008000
Global Const $PROCESS_VM_OPERATION = 0x00000008
Global Const $PROCESS_VM_READ = 0x00000010
Global Const $PROCESS_VM_WRITE = 0x00000020
Global Const $tagMEMMAP = "handle hProc;ulong_ptr Size;ptr Mem"
Func _MemFree(ByRef $tMemMap)
Local $pMemory = DllStructGetData($tMemMap, "Mem")
Local $hProcess = DllStructGetData($tMemMap, "hProc")
Local $bResult = _MemVirtualFreeEx($hProcess, $pMemory, 0, $MEM_RELEASE)
DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $hProcess)
If @error Then Return SetError(@error, @extended, False)
Return $bResult
EndFunc
Func _MemInit($hWnd, $iSize, ByRef $tMemMap)
Local $aResult = DllCall("User32.dll", "dword", "GetWindowThreadProcessId", "hwnd", $hWnd, "dword*", 0)
If @error Then Return SetError(@error + 10, @extended, 0)
Local $iProcessID = $aResult[2]
If $iProcessID = 0 Then Return SetError(1, 0, 0)
Local $iAccess = BitOR($PROCESS_VM_OPERATION, $PROCESS_VM_READ, $PROCESS_VM_WRITE)
Local $hProcess = __Mem_OpenProcess($iAccess, False, $iProcessID, True)
Local $iAlloc = BitOR($MEM_RESERVE, $MEM_COMMIT)
Local $pMemory = _MemVirtualAllocEx($hProcess, 0, $iSize, $iAlloc, $PAGE_READWRITE)
If $pMemory = 0 Then Return SetError(2, 0, 0)
$tMemMap = DllStructCreate($tagMEMMAP)
DllStructSetData($tMemMap, "hProc", $hProcess)
DllStructSetData($tMemMap, "Size", $iSize)
DllStructSetData($tMemMap, "Mem", $pMemory)
Return $pMemory
EndFunc
Func _MemWrite(ByRef $tMemMap, $pSrce, $pDest = 0, $iSize = 0, $sSrce = "struct*")
If $pDest = 0 Then $pDest = DllStructGetData($tMemMap, "Mem")
If $iSize = 0 Then $iSize = DllStructGetData($tMemMap, "Size")
Local $aResult = DllCall("kernel32.dll", "bool", "WriteProcessMemory", "handle", DllStructGetData($tMemMap, "hProc"), "ptr", $pDest, $sSrce, $pSrce, "ulong_ptr", $iSize, "ulong_ptr*", 0)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func _MemVirtualAllocEx($hProcess, $pAddress, $iSize, $iAllocation, $iProtect)
Local $aResult = DllCall("kernel32.dll", "ptr", "VirtualAllocEx", "handle", $hProcess, "ptr", $pAddress, "ulong_ptr", $iSize, "dword", $iAllocation, "dword", $iProtect)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func _MemVirtualFreeEx($hProcess, $pAddress, $iSize, $iFreeType)
Local $aResult = DllCall("kernel32.dll", "bool", "VirtualFreeEx", "handle", $hProcess, "ptr", $pAddress, "ulong_ptr", $iSize, "dword", $iFreeType)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func __Mem_OpenProcess($iAccess, $bInherit, $iProcessID, $bDebugPriv = False)
Local $aResult = DllCall("kernel32.dll", "handle", "OpenProcess", "dword", $iAccess, "bool", $bInherit, "dword", $iProcessID)
If @error Then Return SetError(@error + 10, @extended, 0)
If $aResult[0] Then Return $aResult[0]
If Not $bDebugPriv Then Return 0
Local $hToken = _Security__OpenThreadTokenEx(BitOR($TOKEN_ADJUST_PRIVILEGES, $TOKEN_QUERY))
If @error Then Return SetError(@error + 20, @extended, 0)
_Security__SetPrivilege($hToken, "SeDebugPrivilege", True)
Local $iError = @error
Local $iLastError = @extended
Local $iRet = 0
If Not @error Then
$aResult = DllCall("kernel32.dll", "handle", "OpenProcess", "dword", $iAccess, "bool", $bInherit, "dword", $iProcessID)
$iError = @error
$iLastError = @extended
If $aResult[0] Then $iRet = $aResult[0]
_Security__SetPrivilege($hToken, "SeDebugPrivilege", False)
If @error Then
$iError = @error + 30
$iLastError = @extended
EndIf
Else
$iError = @error + 40
EndIf
DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $hToken)
Return SetError($iError, $iLastError, $iRet)
EndFunc
Global Const $MF_STRING = 0x0
Global Const $MF_SEPARATOR = 0x00000800
Global Const $MFT_STRING = $MF_STRING
Global Const $MFT_SEPARATOR = $MF_SEPARATOR
Global Const $MIIM_ID = 0x00000002
Global Const $MIIM_SUBMENU = 0x00000004
Global Const $MIIM_STRING = 0x00000040
Global Const $MIIM_FTYPE = 0x00000100
Global Const $MIM_STYLE = 0x00000010
Global Const $MNS_CHECKORBMP = 0x04000000
Global Const $TPM_LEFTBUTTON = 0x0
Global Const $TPM_LEFTALIGN = 0x0
Global Const $TPM_TOPALIGN = 0x0
Global Const $TPM_RIGHTBUTTON = 0x00000002
Global Const $TPM_CENTERALIGN = 0x00000004
Global Const $TPM_RIGHTALIGN = 0x00000008
Global Const $TPM_VCENTERALIGN = 0x00000010
Global Const $TPM_BOTTOMALIGN = 0x00000020
Global Const $TPM_NONOTIFY = 0x00000080
Global Const $TPM_RETURNCMD = 0x00000100
Func _GUICtrlMenu_CreatePopup($iStyle = $MNS_CHECKORBMP)
Local $aResult = DllCall("User32.dll", "handle", "CreatePopupMenu")
If @error Then Return SetError(@error, @extended, 0)
If $aResult[0] = 0 Then Return SetError(10, 0, 0)
_GUICtrlMenu_SetMenuStyle($aResult[0], $iStyle)
Return $aResult[0]
EndFunc
Func _GUICtrlMenu_DestroyMenu($hMenu)
Local $aResult = DllCall("User32.dll", "bool", "DestroyMenu", "handle", $hMenu)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func _GUICtrlMenu_InsertMenuItem($hMenu, $iIndex, $sText, $iCmdID = 0, $hSubMenu = 0)
Local $tMenu = DllStructCreate($tagMENUITEMINFO)
DllStructSetData($tMenu, "Size", DllStructGetSize($tMenu))
DllStructSetData($tMenu, "ID", $iCmdID)
DllStructSetData($tMenu, "SubMenu", $hSubMenu)
If $sText = "" Then
DllStructSetData($tMenu, "Mask", $MIIM_FTYPE)
DllStructSetData($tMenu, "Type", $MFT_SEPARATOR)
Else
DllStructSetData($tMenu, "Mask", BitOR($MIIM_ID, $MIIM_STRING, $MIIM_SUBMENU))
DllStructSetData($tMenu, "Type", $MFT_STRING)
Local $tText = DllStructCreate("wchar Text[" & StringLen($sText) + 1 & "]")
DllStructSetData($tText, "Text", $sText)
DllStructSetData($tMenu, "TypeData", DllStructGetPtr($tText))
EndIf
Local $aResult = DllCall("User32.dll", "bool", "InsertMenuItemW", "handle", $hMenu, "uint", $iIndex, "bool", True, "struct*", $tMenu)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func _GUICtrlMenu_SetMenuInfo($hMenu, ByRef $tInfo)
DllStructSetData($tInfo, "Size", DllStructGetSize($tInfo))
Local $aResult = DllCall("User32.dll", "bool", "SetMenuInfo", "handle", $hMenu, "struct*", $tInfo)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func _GUICtrlMenu_SetMenuStyle($hMenu, $iStyle)
Local $tInfo = DllStructCreate($tagMENUINFO)
DllStructSetData($tInfo, "Mask", $MIM_STYLE)
DllStructSetData($tInfo, "Style", $iStyle)
Return _GUICtrlMenu_SetMenuInfo($hMenu, $tInfo)
EndFunc
Func _GUICtrlMenu_TrackPopupMenu($hMenu, $hWnd, $iX = -1, $iY = -1, $iAlignX = 1, $iAlignY = 1, $iNotify = 0, $iButtons = 0)
If $iX = -1 Then $iX = _WinAPI_GetMousePosX()
If $iY = -1 Then $iY = _WinAPI_GetMousePosY()
Local $iFlags = 0
Switch $iAlignX
Case 1
$iFlags = BitOR($iFlags, $TPM_LEFTALIGN)
Case 2
$iFlags = BitOR($iFlags, $TPM_RIGHTALIGN)
Case Else
$iFlags = BitOR($iFlags, $TPM_CENTERALIGN)
EndSwitch
Switch $iAlignY
Case 1
$iFlags = BitOR($iFlags, $TPM_TOPALIGN)
Case 2
$iFlags = BitOR($iFlags, $TPM_VCENTERALIGN)
Case Else
$iFlags = BitOR($iFlags, $TPM_BOTTOMALIGN)
EndSwitch
If BitAND($iNotify, 1) <> 0 Then $iFlags = BitOR($iFlags, $TPM_NONOTIFY)
If BitAND($iNotify, 2) <> 0 Then $iFlags = BitOR($iFlags, $TPM_RETURNCMD)
Switch $iButtons
Case 1
$iFlags = BitOR($iFlags, $TPM_RIGHTBUTTON)
Case Else
$iFlags = BitOR($iFlags, $TPM_LEFTBUTTON)
EndSwitch
Local $aResult = DllCall("User32.dll", "bool", "TrackPopupMenu", "handle", $hMenu, "uint", $iFlags, "int", $iX, "int", $iY, "int", 0, "hwnd", $hWnd, "ptr", 0)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Global Const $__TOOLBARCONSTANTS_WM_USER = 0X400
Global Const $TB_ENABLEBUTTON = $__TOOLBARCONSTANTS_WM_USER + 1
Global Const $TB_ADDBITMAP = $__TOOLBARCONSTANTS_WM_USER + 19
Global Const $TB_ADDBUTTONSA = $__TOOLBARCONSTANTS_WM_USER + 20
Global Const $TB_BUTTONSTRUCTSIZE = $__TOOLBARCONSTANTS_WM_USER + 30
Global Const $TB_AUTOSIZE = $__TOOLBARCONSTANTS_WM_USER + 33
Global Const $TB_ADDBUTTONSW = $__TOOLBARCONSTANTS_WM_USER + 68
Global Const $TB_GETUNICODEFORMAT = 0x2000 + 6
Global Const $BTNS_SEP = 0x00000001
Global Const $BTNS_SHOWTEXT = 0x00000040
Global Const $TBSTYLE_FLAT = 0x00000800
Global $__g_hTBLastWnd
Global Const $__TOOLBARCONSTANT_ClassName = "ToolbarWindow32"
Global Const $__TOOLBARCONSTANT_WS_CLIPSIBLINGS = 0x04000000
Global Const $tagTBADDBITMAP = "handle hInst;uint_ptr ID"
Func _GUICtrlToolbar_AddBitmap($hWnd, $iButtons, $hInst, $iID)
Local $tBitmap = DllStructCreate($tagTBADDBITMAP)
DllStructSetData($tBitmap, "hInst", $hInst)
DllStructSetData($tBitmap, "ID", $iID)
Local $iRet
If _WinAPI_InProcess($hWnd, $__g_hTBLastWnd) Then
$iRet = _SendMessage($hWnd, $TB_ADDBITMAP, $iButtons, $tBitmap, 0, "wparam", "struct*")
Else
Local $iBitmap = DllStructGetSize($tBitmap)
Local $tMemMap
Local $pMemory = _MemInit($hWnd, $iBitmap, $tMemMap)
_MemWrite($tMemMap, $tBitmap, $pMemory, $iBitmap)
$iRet = _SendMessage($hWnd, $TB_ADDBITMAP, $iButtons, $pMemory, 0, "wparam", "ptr")
_MemFree($tMemMap)
EndIf
Return $iRet
EndFunc
Func _GUICtrlToolbar_AddButton($hWnd, $iID, $iImage, $iString = 0, $iStyle = 0, $iState = 4, $iParam = 0)
Local $bUnicode = _GUICtrlToolbar_GetUnicodeFormat($hWnd)
Local $tButton = DllStructCreate($tagTBBUTTON)
DllStructSetData($tButton, "Bitmap", $iImage)
DllStructSetData($tButton, "Command", $iID)
DllStructSetData($tButton, "State", $iState)
DllStructSetData($tButton, "Style", $iStyle)
DllStructSetData($tButton, "Param", $iParam)
DllStructSetData($tButton, "String", $iString)
Local $iRet
If _WinAPI_InProcess($hWnd, $__g_hTBLastWnd) Then
$iRet = _SendMessage($hWnd, $TB_ADDBUTTONSW, 1, $tButton, 0, "wparam", "struct*")
Else
Local $iButton = DllStructGetSize($tButton)
Local $tMemMap
Local $pMemory = _MemInit($hWnd, $iButton, $tMemMap)
_MemWrite($tMemMap, $tButton, $pMemory, $iButton)
If $bUnicode Then
$iRet = _SendMessage($hWnd, $TB_ADDBUTTONSW, 1, $pMemory, 0, "wparam", "ptr")
Else
$iRet = _SendMessage($hWnd, $TB_ADDBUTTONSA, 1, $pMemory, 0, "wparam", "ptr")
EndIf
_MemFree($tMemMap)
EndIf
__GUICtrlToolbar_AutoSize($hWnd)
Return $iRet <> 0
EndFunc
Func _GUICtrlToolbar_AddButtonSep($hWnd, $iWidth = 6)
_GUICtrlToolbar_AddButton($hWnd, 0, $iWidth, 0, $BTNS_SEP)
EndFunc
Func __GUICtrlToolbar_AutoSize($hWnd)
_SendMessage($hWnd, $TB_AUTOSIZE)
EndFunc
Func __GUICtrlToolbar_ButtonStructSize($hWnd)
Local $tButton = DllStructCreate($tagTBBUTTON)
_SendMessage($hWnd, $TB_BUTTONSTRUCTSIZE, DllStructGetSize($tButton), 0, 0, "wparam", "ptr")
EndFunc
Func _GUICtrlToolbar_Create($hWnd, $iStyle = 0x00000800, $iExStyle = 0x00000000)
$iStyle = BitOR($iStyle, $__UDFGUICONSTANT_WS_CHILD, $__TOOLBARCONSTANT_WS_CLIPSIBLINGS, $__UDFGUICONSTANT_WS_VISIBLE)
Local $nCtrlID = __UDF_GetNextGlobalID($hWnd)
If @error Then Return SetError(@error, @extended, 0)
Local $hTool = _WinAPI_CreateWindowEx($iExStyle, $__TOOLBARCONSTANT_ClassName, "", $iStyle, 0, 0, 0, 0, $hWnd, $nCtrlID)
__GUICtrlToolbar_ButtonStructSize($hTool)
Return $hTool
EndFunc
Func _GUICtrlToolbar_EnableButton($hWnd, $iCommandID, $bEnable = True)
Return _SendMessage($hWnd, $TB_ENABLEBUTTON, $iCommandID, $bEnable) <> 0
EndFunc
Func _GUICtrlToolbar_GetUnicodeFormat($hWnd)
Return _SendMessage($hWnd, $TB_GETUNICODEFORMAT) <> 0
EndFunc
Global Const $tagBUTTON_IMAGELIST = "ptr ImageList;" & $tagRECT & ";uint Align"
Global Const $__BUTTONCONSTANT_ClassName = "Button"
Func _GUICtrlButton_Enable($hWnd, $bEnable = True)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
If _WinAPI_IsClassName($hWnd, $__BUTTONCONSTANT_ClassName) Then Return _WinAPI_EnableWindow($hWnd, $bEnable) = $bEnable
EndFunc
Func _GUICtrlButton_SetImageList($hWnd, $hImage, $nAlign = 0, $iLeft = 1, $iTop = 1, $iRight = 1, $iBottom = 1)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
If $nAlign < 0 Or $nAlign > 4 Then $nAlign = 0
Local $tBUTTON_IMAGELIST = DllStructCreate($tagBUTTON_IMAGELIST)
DllStructSetData($tBUTTON_IMAGELIST, "ImageList", $hImage)
DllStructSetData($tBUTTON_IMAGELIST, "Left", $iLeft)
DllStructSetData($tBUTTON_IMAGELIST, "Top", $iTop)
DllStructSetData($tBUTTON_IMAGELIST, "Right", $iRight)
DllStructSetData($tBUTTON_IMAGELIST, "Bottom", $iBottom)
DllStructSetData($tBUTTON_IMAGELIST, "Align", $nAlign)
Local $bEnabled = _GUICtrlButton_Enable($hWnd, False)
Local $iRet = _SendMessage($hWnd, $BCM_SETIMAGELIST, 0, $tBUTTON_IMAGELIST, 0, "wparam", "struct*") <> 0
_GUICtrlButton_Enable($hWnd)
If Not $bEnabled Then _GUICtrlButton_Enable($hWnd, False)
Return $iRet
EndFunc
Global $__g_pGRC_StreamFromFileCallback = DllCallbackRegister("__GCR_StreamFromFileCallback", "dword", "long_ptr;ptr;long;ptr")
Global $__g_pGRC_StreamFromVarCallback = DllCallbackRegister("__GCR_StreamFromVarCallback", "dword", "long_ptr;ptr;long;ptr")
Global $__g_pGRC_StreamToFileCallback = DllCallbackRegister("__GCR_StreamToFileCallback", "dword", "long_ptr;ptr;long;ptr")
Global $__g_pGRC_StreamToVarCallback = DllCallbackRegister("__GCR_StreamToVarCallback", "dword", "long_ptr;ptr;long;ptr")
Global $__g_pGRC_sStreamVar
Global $__g_hLib_RichCom_OLE32 = DllOpen("OLE32.DLL")
Global $__g_pRichCom_Object_QueryInterface = DllCallbackRegister("__RichCom_Object_QueryInterface", "long", "ptr;dword;dword")
Global $__g_pRichCom_Object_AddRef = DllCallbackRegister("__RichCom_Object_AddRef", "long", "ptr")
Global $__g_pRichCom_Object_Release = DllCallbackRegister("__RichCom_Object_Release", "long", "ptr")
Global $__g_pRichCom_Object_GetNewStorage = DllCallbackRegister("__RichCom_Object_GetNewStorage", "long", "ptr;ptr")
Global $__g_pRichCom_Object_GetInPlaceContext = DllCallbackRegister("__RichCom_Object_GetInPlaceContext", "long", "ptr;dword;dword;dword")
Global $__g_pRichCom_Object_ShowContainerUI = DllCallbackRegister("__RichCom_Object_ShowContainerUI", "long", "ptr;long")
Global $__g_pRichCom_Object_QueryInsertObject = DllCallbackRegister("__RichCom_Object_QueryInsertObject", "long", "ptr;dword;ptr;long")
Global $__g_pRichCom_Object_DeleteObject = DllCallbackRegister("__RichCom_Object_DeleteObject", "long", "ptr;ptr")
Global $__g_pRichCom_Object_QueryAcceptData = DllCallbackRegister("__RichCom_Object_QueryAcceptData", "long", "ptr;ptr;dword;dword;dword;ptr")
Global $__g_pRichCom_Object_ContextSensitiveHelp = DllCallbackRegister("__RichCom_Object_ContextSensitiveHelp", "long", "ptr;long")
Global $__g_pRichCom_Object_GetClipboardData = DllCallbackRegister("__RichCom_Object_GetClipboardData", "long", "ptr;ptr;dword;ptr")
Global $__g_pRichCom_Object_GetDragDropEffect = DllCallbackRegister("__RichCom_Object_GetDragDropEffect", "long", "ptr;dword;dword;dword")
Global $__g_pRichCom_Object_GetContextMenu = DllCallbackRegister("__RichCom_Object_GetContextMenu", "long", "ptr;short;ptr;ptr;ptr")
Global Const $_GCR_S_OK = 0
Global Const $_GCR_E_NOTIMPL = 0x80004001
Func __GCR_StreamFromFileCallback($hFile, $pBuf, $iBuflen, $pQbytes)
Local $tQbytes = DllStructCreate("long", $pQbytes)
DllStructSetData($tQbytes, 1, 0)
Local $tBuf = DllStructCreate("char[" & $iBuflen & "]", $pBuf)
Local $sBuf = FileRead($hFile, $iBuflen - 1)
If @error <> 0 Then Return 1
DllStructSetData($tBuf, 1, $sBuf)
DllStructSetData($tQbytes, 1, StringLen($sBuf))
Return 0
EndFunc
Func __GCR_StreamFromVarCallback($iCookie, $pBuf, $iBuflen, $pQbytes)
#forceref $iCookie
Local $tQbytes = DllStructCreate("long", $pQbytes)
DllStructSetData($tQbytes, 1, 0)
Local $tCtl = DllStructCreate("char[" & $iBuflen & "]", $pBuf)
Local $sCtl = StringLeft($__g_pGRC_sStreamVar, $iBuflen - 1)
If $sCtl = "" Then Return 1
DllStructSetData($tCtl, 1, $sCtl)
Local $iLen = StringLen($sCtl)
DllStructSetData($tQbytes, 1, $iLen)
$__g_pGRC_sStreamVar = StringMid($__g_pGRC_sStreamVar, $iLen + 1)
Return 0
EndFunc
Func __GCR_StreamToFileCallback($hFile, $pBuf, $iBuflen, $pQbytes)
Local $tQbytes = DllStructCreate("long", $pQbytes)
DllStructSetData($tQbytes, 1, 0)
Local $tBuf = DllStructCreate("char[" & $iBuflen & "]", $pBuf)
Local $s = DllStructGetData($tBuf, 1)
FileWrite($hFile, $s)
DllStructSetData($tQbytes, 1, StringLen($s))
Return 0
EndFunc
Func __GCR_StreamToVarCallback($iCookie, $pBuf, $iBuflen, $pQbytes)
#forceref $iCookie
Local $tQbytes = DllStructCreate("long", $pQbytes)
DllStructSetData($tQbytes, 1, 0)
Local $tBuf = DllStructCreate("char[" & $iBuflen & "]", $pBuf)
Local $s = DllStructGetData($tBuf, 1)
$__g_pGRC_sStreamVar &= $s
Return 0
EndFunc
Func __RichCom_Object_QueryInterface($pObject, $iREFIID, $pPvObj)
#forceref $pObject, $iREFIID, $pPvObj
Return $_GCR_S_OK
EndFunc
Func __RichCom_Object_AddRef($pObject)
Local $tData = DllStructCreate("ptr;dword", $pObject)
DllStructSetData($tData, 2, DllStructGetData($tData, 2) + 1)
Return DllStructGetData($tData, 2)
EndFunc
Func __RichCom_Object_Release($pObject)
Local $tData = DllStructCreate("ptr;dword", $pObject)
If DllStructGetData($tData, 2) > 0 Then
DllStructSetData($tData, 2, DllStructGetData($tData, 2) - 1)
Return DllStructGetData($tData, 2)
EndIf
EndFunc
Func __RichCom_Object_GetInPlaceContext($pObject, $pPFrame, $pPDoc, $pFrameInfo)
#forceref $pObject, $pPFrame, $pPDoc, $pFrameInfo
Return $_GCR_E_NOTIMPL
EndFunc
Func __RichCom_Object_ShowContainerUI($pObject, $bShow)
#forceref $pObject, $bShow
Return $_GCR_E_NOTIMPL
EndFunc
Func __RichCom_Object_QueryInsertObject($pObject, $pClsid, $tStg, $vCp)
#forceref $pObject, $pClsid, $tStg, $vCp
Return $_GCR_S_OK
EndFunc
Func __RichCom_Object_DeleteObject($pObject, $pOleobj)
#forceref $pObject, $pOleobj
Return $_GCR_E_NOTIMPL
EndFunc
Func __RichCom_Object_QueryAcceptData($pObject, $pDataobj, $pCfFormat, $vReco, $bReally, $hMetaPict)
#forceref $pObject, $pDataobj, $pCfFormat, $vReco, $bReally, $hMetaPict
Return $_GCR_S_OK
EndFunc
Func __RichCom_Object_ContextSensitiveHelp($pObject, $bEnterMode)
#forceref $pObject, $bEnterMode
Return $_GCR_E_NOTIMPL
EndFunc
Func __RichCom_Object_GetClipboardData($pObject, $pChrg, $vReco, $pPdataobj)
#forceref $pObject, $pChrg, $vReco, $pPdataobj
Return $_GCR_E_NOTIMPL
EndFunc
Func __RichCom_Object_GetDragDropEffect($pObject, $bDrag, $iGrfKeyState, $piEffect)
#forceref $pObject, $bDrag, $iGrfKeyState, $piEffect
Return $_GCR_E_NOTIMPL
EndFunc
Func __RichCom_Object_GetContextMenu($pObject, $iSeltype, $pOleobj, $pChrg, $pHmenu)
#forceref $pObject, $iSeltype, $pOleobj, $pChrg, $pHmenu
Return $_GCR_E_NOTIMPL
EndFunc
Func __RichCom_Object_GetNewStorage($pObject, $pPstg)
#forceref $pObject
Local $aSc = DllCall($__g_hLib_RichCom_OLE32, "dword", "CreateILockBytesOnHGlobal", "hwnd", 0, "int", 1, "ptr*", 0)
Local $pLockBytes = $aSc[3]
$aSc = $aSc[0]
If $aSc Then Return $aSc
$aSc = DllCall($__g_hLib_RichCom_OLE32, "dword", "StgCreateDocfileOnILockBytes", "ptr", $pLockBytes, "dword", BitOR(0x10, 2, 0x1000), "dword", 0, "ptr*", 0)
Local $tStg = DllStructCreate("ptr", $pPstg)
DllStructSetData($tStg, 1, $aSc[4])
$aSc = $aSc[0]
If $aSc Then
Local $tObj = DllStructCreate("ptr", $pLockBytes)
Local $tUnknownFuncTable = DllStructCreate("ptr[3]", DllStructGetData($tObj, 1))
Local $pReleaseFunc = DllStructGetData($tUnknownFuncTable, 3)
DllCallAddress("long", $pReleaseFunc, "ptr", $pLockBytes)
EndIf
Return $aSc
EndFunc
Global Const $ILC_MASK = 0x00000001
Global Const $ILC_COLOR = 0x00000000
Global Const $ILC_COLORDDB = 0x000000FE
Global Const $ILC_COLOR4 = 0x00000004
Global Const $ILC_COLOR8 = 0x00000008
Global Const $ILC_COLOR16 = 0x00000010
Global Const $ILC_COLOR24 = 0x00000018
Global Const $ILC_COLOR32 = 0x00000020
Global Const $ILC_MIRROR = 0x00002000
Global Const $ILC_PERITEMMIRROR = 0x00008000
Func _GUIImageList_Add($hWnd, $hImage, $hMask = 0)
Local $aResult = DllCall("comctl32.dll", "int", "ImageList_Add", "handle", $hWnd, "handle", $hImage, "handle", $hMask)
If @error Then Return SetError(@error, @extended, -1)
Return $aResult[0]
EndFunc
Func _GUIImageList_Create($iCX = 16, $iCY = 16, $iColor = 4, $iOptions = 0, $iInitial = 4, $iGrow = 4)
Local Const $aColor[7] = [$ILC_COLOR, $ILC_COLOR4, $ILC_COLOR8, $ILC_COLOR16, $ILC_COLOR24, $ILC_COLOR32, $ILC_COLORDDB]
Local $iFlags = 0
If BitAND($iOptions, 1) <> 0 Then $iFlags = BitOR($iFlags, $ILC_MASK)
If BitAND($iOptions, 2) <> 0 Then $iFlags = BitOR($iFlags, $ILC_MIRROR)
If BitAND($iOptions, 4) <> 0 Then $iFlags = BitOR($iFlags, $ILC_PERITEMMIRROR)
$iFlags = BitOR($iFlags, $aColor[$iColor])
Local $aResult = DllCall("comctl32.dll", "handle", "ImageList_Create", "int", $iCX, "int", $iCY, "uint", $iFlags, "int", $iInitial, "int", $iGrow)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Global Const $tagOSVERSIONINFO = 'struct;dword OSVersionInfoSize;dword MajorVersion;dword MinorVersion;dword BuildNumber;dword PlatformId;wchar CSDVersion[128];endstruct'
Global Const $__WINVER = __WINVER()
Func _WinAPI_GetString($pString, $bUnicode = True)
Local $iLength = _WinAPI_StrLen($pString, $bUnicode)
If @error Or Not $iLength Then Return SetError(@error + 10, @extended, '')
Local $tString = DllStructCreate(__Iif($bUnicode, 'wchar', 'char') & '[' &($iLength + 1) & ']', $pString)
If @error Then Return SetError(@error, @extended, '')
Return SetExtended($iLength, DllStructGetData($tString, 1))
EndFunc
Func _WinAPI_StrLen($pString, $bUnicode = True)
Local $W = ''
If $bUnicode Then $W = 'W'
Local $aRet = DllCall('kernel32.dll', 'int', 'lstrlen' & $W, 'ptr', $pString)
If @error Then Return SetError(@error, @extended, 0)
Return $aRet[0]
EndFunc
Func __Iif($bTest, $vTrue, $vFalse)
Return $bTest ? $vTrue : $vFalse
EndFunc
Func __WINVER()
Local $tOSVI = DllStructCreate($tagOSVERSIONINFO)
DllStructSetData($tOSVI, 1, DllStructGetSize($tOSVI))
Local $aRet = DllCall('kernel32.dll', 'bool', 'GetVersionExW', 'struct*', $tOSVI)
If @error Or Not $aRet[0] Then Return SetError(@error, @extended, 0)
Return BitOR(BitShift(DllStructGetData($tOSVI, 2), -8), DllStructGetData($tOSVI, 3))
EndFunc
Func _WinAPI_CommandLineToArgv($sCmd)
Local $aResult[1] = [0]
$sCmd = StringStripWS($sCmd, $STR_STRIPLEADING + $STR_STRIPTRAILING)
If Not $sCmd Then
Return $aResult
EndIf
Local $aRet = DllCall('shell32.dll', 'ptr', 'CommandLineToArgvW', 'wstr', $sCmd, 'int*', 0)
If @error Or Not $aRet[0] Or(Not $aRet[2]) Then Return SetError(@error + 10, @extended, 0)
Local $tPtr = DllStructCreate('ptr[' & $aRet[2] & ']', $aRet[0])
Dim $aResult[$aRet[2] + 1] = [$aRet[2]]
For $i = 1 To $aRet[2]
$aResult[$i] = _WinAPI_GetString(DllStructGetData($tPtr, 1, $i))
Next
DllCall("kernel32.dll", "handle", "LocalFree", "handle", $aRet[0])
Return $aResult
EndFunc
Global Const $GDIP_ILMREAD = 0x0001
Global Const $GDIP_PXF32RGB = 0x00022009
Global Const $GDIP_PXF32ARGB = 0x0026200A
Func _WinAPI_CreateStreamOnHGlobal($hGlobal = 0, $bDeleteOnRelease = True)
Local $aReturn = DllCall('ole32.dll', 'long', 'CreateStreamOnHGlobal', 'handle', $hGlobal, 'bool', $bDeleteOnRelease, 'ptr*', 0)
If @error Then Return SetError(@error, @extended, 0)
If $aReturn[0] Then Return SetError(10, $aReturn[0], 0)
Return $aReturn[3]
EndFunc
Global Const $tagBITMAPV5HEADER = 'struct;dword bV5Size;long bV5Width;long bV5Height;ushort bV5Planes;ushort bV5BitCount;dword bV5Compression;dword bV5SizeImage;long bV5XPelsPerMeter;long bV5YPelsPerMeter;dword bV5ClrUsed;dword bV5ClrImportant;dword bV5RedMask;dword bV5GreenMask;dword bV5BlueMask;dword bV5AlphaMask;dword bV5CSType;int bV5Endpoints[9];dword bV5GammaRed;dword bV5GammaGreen;dword bV5GammaBlue;dword bV5Intent;dword bV5ProfileData;dword bV5ProfileSize;dword bV5Reserved;endstruct'
Global $__g_hGDIPDll = 0
Global $__g_iGDIPRef = 0
Global $__g_iGDIPToken = 0
Global $__g_bGDIP_V1_0 = True
Func _GDIPlus_BitmapCreateFromMemory($dImage, $bHBITMAP = False)
If Not IsBinary($dImage) Then Return SetError(1, 0, 0)
Local $aResult = 0
Local Const $dMemBitmap = Binary($dImage)
Local Const $iLen = BinaryLen($dMemBitmap)
Local Const $GMEM_MOVEABLE = 0x0002
$aResult = DllCall("kernel32.dll", "handle", "GlobalAlloc", "uint", $GMEM_MOVEABLE, "ulong_ptr", $iLen)
If @error Then Return SetError(4, 0, 0)
Local Const $hData = $aResult[0]
$aResult = DllCall("kernel32.dll", "ptr", "GlobalLock", "handle", $hData)
If @error Then Return SetError(5, 0, 0)
Local $tMem = DllStructCreate("byte[" & $iLen & "]", $aResult[0])
DllStructSetData($tMem, 1, $dMemBitmap)
DllCall("kernel32.dll", "bool", "GlobalUnlock", "handle", $hData)
If @error Then Return SetError(6, 0, 0)
Local Const $hStream = _WinAPI_CreateStreamOnHGlobal($hData)
If @error Then Return SetError(2, 0, 0)
Local Const $hBitmap = _GDIPlus_BitmapCreateFromStream($hStream)
If @error Then Return SetError(3, 0, 0)
DllCall("oleaut32.dll", "long", "DispCallFunc", "ptr", $hStream, "ulong_ptr", 8 *(1 + @AutoItX64), "uint", 4, "ushort", 23, "uint", 0, "ptr", 0, "ptr", 0, "str", "")
If $bHBITMAP Then
Local Const $hHBmp = __GDIPlus_BitmapCreateDIBFromBitmap($hBitmap)
_GDIPlus_BitmapDispose($hBitmap)
Return $hHBmp
EndIf
Return $hBitmap
EndFunc
Func _GDIPlus_BitmapCreateFromStream($pStream)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipCreateBitmapFromStream", "ptr", $pStream, "handle*", 0)
If @error Then Return SetError(@error, @extended, 0)
If $aResult[0] Then Return SetError(10, $aResult[0], 0)
Return $aResult[2]
EndFunc
Func _GDIPlus_BitmapDispose($hBitmap)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipDisposeImage", "handle", $hBitmap)
If @error Then Return SetError(@error, @extended, False)
If $aResult[0] Then Return SetError(10, $aResult[0], False)
Return True
EndFunc
Func _GDIPlus_BitmapLockBits($hBitmap, $iLeft, $iTop, $iWidth, $iHeight, $iFlags = $GDIP_ILMREAD, $iFormat = $GDIP_PXF32RGB)
Local $tData = DllStructCreate($tagGDIPBITMAPDATA)
Local $tRect = DllStructCreate($tagRECT)
DllStructSetData($tRect, "Left", $iLeft)
DllStructSetData($tRect, "Top", $iTop)
DllStructSetData($tRect, "Right", $iWidth)
DllStructSetData($tRect, "Bottom", $iHeight)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipBitmapLockBits", "handle", $hBitmap, "struct*", $tRect, "uint", $iFlags, "int", $iFormat, "struct*", $tData)
If @error Then Return SetError(@error, @extended, 0)
If $aResult[0] Then Return SetError(10, $aResult[0], 0)
Return $tData
EndFunc
Func _GDIPlus_BitmapUnlockBits($hBitmap, $tBitmapData)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdipBitmapUnlockBits", "handle", $hBitmap, "struct*", $tBitmapData)
If @error Then Return SetError(@error, @extended, False)
If $aResult[0] Then Return SetError(10, $aResult[0], False)
Return True
EndFunc
Func _GDIPlus_Shutdown()
If $__g_hGDIPDll = 0 Then Return SetError(-1, -1, False)
$__g_iGDIPRef -= 1
If $__g_iGDIPRef = 0 Then
DllCall($__g_hGDIPDll, "none", "GdiplusShutdown", "ulong_ptr", $__g_iGDIPToken)
DllClose($__g_hGDIPDll)
$__g_hGDIPDll = 0
EndIf
Return True
EndFunc
Func _GDIPlus_Startup($sGDIPDLL = Default, $bRetDllHandle = False)
$__g_iGDIPRef += 1
If $__g_iGDIPRef > 1 Then Return True
If $sGDIPDLL = Default Then
If @OSBuild > 4999 And @OSBuild < 7600 Then
$sGDIPDLL = @WindowsDir & "\winsxs\x86_microsoft.windows.gdiplus_6595b64144ccf1df_1.1.6000.16386_none_8df21b8362744ace\gdiplus.dll"
Else
$sGDIPDLL = "gdiplus.dll"
EndIf
EndIf
$__g_hGDIPDll = DllOpen($sGDIPDLL)
If $__g_hGDIPDll = -1 Then
$__g_iGDIPRef = 0
Return SetError(1, 2, False)
EndIf
Local $sVer = FileGetVersion($sGDIPDLL)
$sVer = StringSplit($sVer, ".")
If $sVer[1] > 5 Then $__g_bGDIP_V1_0 = False
Local $tInput = DllStructCreate($tagGDIPSTARTUPINPUT)
Local $tToken = DllStructCreate("ulong_ptr Data")
DllStructSetData($tInput, "Version", 1)
Local $aResult = DllCall($__g_hGDIPDll, "int", "GdiplusStartup", "struct*", $tToken, "struct*", $tInput, "ptr", 0)
If @error Then Return SetError(@error, @extended, False)
If $aResult[0] Then Return SetError(10, $aResult[0], False)
$__g_iGDIPToken = DllStructGetData($tToken, "Data")
If $bRetDllHandle Then Return $__g_hGDIPDll
Return True
EndFunc
Func __GDIPlus_BitmapCreateDIBFromBitmap($hBitmap)
Local $tBIHDR, $aRet, $tData, $pBits, $hHBitmapv5 = 0
$aRet = DllCall($__g_hGDIPDll, "uint", "GdipGetImageDimension", "handle", $hBitmap, "float*", 0, "float*", 0)
If @error Or $aRet[0] Then Return 0
$tData = _GDIPlus_BitmapLockBits($hBitmap, 0, 0, $aRet[2], $aRet[3], $GDIP_ILMREAD, $GDIP_PXF32ARGB)
$pBits = DllStructGetData($tData, "Scan0")
If Not $pBits Then Return 0
$tBIHDR = DllStructCreate($tagBITMAPV5HEADER)
DllStructSetData($tBIHDR, "bV5Size", DllStructGetSize($tBIHDR))
DllStructSetData($tBIHDR, "bV5Width", $aRet[2])
DllStructSetData($tBIHDR, "bV5Height", $aRet[3])
DllStructSetData($tBIHDR, "bV5Planes", 1)
DllStructSetData($tBIHDR, "bV5BitCount", 32)
DllStructSetData($tBIHDR, "bV5Compression", 0)
DllStructSetData($tBIHDR, "bV5SizeImage", $aRet[3] * DllStructGetData($tData, "Stride"))
DllStructSetData($tBIHDR, "bV5AlphaMask", 0xFF000000)
DllStructSetData($tBIHDR, "bV5RedMask", 0x00FF0000)
DllStructSetData($tBIHDR, "bV5GreenMask", 0x0000FF00)
DllStructSetData($tBIHDR, "bV5BlueMask", 0x000000FF)
DllStructSetData($tBIHDR, "bV5CSType", 2)
DllStructSetData($tBIHDR, "bV5Intent", 4)
$hHBitmapv5 = DllCall("gdi32.dll", "ptr", "CreateDIBSection", "hwnd", 0, "struct*", $tBIHDR, "uint", 0, "ptr*", 0, "ptr", 0, "dword", 0)
If Not @error And $hHBitmapv5[0] Then
DllCall("gdi32.dll", "dword", "SetBitmapBits", "ptr", $hHBitmapv5[0], "dword", $aRet[2] * $aRet[3] * 4, "ptr", DllStructGetData($tData, "Scan0"))
$hHBitmapv5 = $hHBitmapv5[0]
Else
$hHBitmapv5 = 0
EndIf
_GDIPlus_BitmapUnlockBits($hBitmap, $tData)
$tData = 0
$tBIHDR = 0
Return $hHBitmapv5
EndFunc
Global $__BinaryCall_Kernel32dll = DllOpen('kernel32.dll')
Global $__BinaryCall_Msvcrtdll = DllOpen('msvcrt.dll')
Func My01_slideshowico($bSaveBinary = False, $sSavePath = @ScriptDir)
Local $01_slideshowico
$01_slideshowico &= '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'
$01_slideshowico &= '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'
$01_slideshowico &= 'GO9hEODh4W7/bRxtCnj98E4A2cSCqILI0w3A1+dw59DyBv8E8AA//8AMAAAg8MMPAPCB7zgCgP6eJdNI0UrBUAD/wA0MEZDK8ALwXQD+DPAPyAAC8AAf///gDMD/9wE='
$01_slideshowico = _WinAPI_Base64Decode($01_slideshowico)
Local Const $bString = ASM_DecompressLZMAT($01_slideshowico)
If $bSaveBinary Then
Local Const $hFile = FileOpen($sSavePath & "\01_slideshow.ico", 18)
If @error Then Return SetError(1, 0, 0)
FileWrite($hFile, $bString)
FileClose($hFile)
EndIf
Return $bString
EndFunc
Func My02_clockico($bSaveBinary = False, $sSavePath = @ScriptDir)
Local $02_clockico
$02_clockico &= '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'
$02_clockico &= '9I/3wwE27f8Q/VDYUCfM/wCbSv/haif/2g/HzP/2HQLdE/0TAAVQHh7+39rZ+Q8Q6uj4j/z7+w9U34Zwb4//LzkJ1u9MAJ0G8On/1c5uzv0gHRHKDQTtFx0Y9AD09f/Pop7/6wBpFv//oVj/ahQ0E8b9AC39UMs/AB2h/6Zj/+pyACf/z6qp//Hw8P0GDQntFG4Iwfv6+g/wqaj4n8vK+n/H7o8AAJko8J9v3Z/RIAGE7zJA7e7x/8Z+AG7/+oIv//mlA2j/VCQEsU4N0Q8F8EuykHZPGvcPcD9p9J/ct/ZfwM4O/x/PDcjdBQCgjY3/rZyc/w/h3Nz/JfcAAI/Qz+GWEAD38/L/4dvh/yDTcz4M0Hr2H844EPVPIwFQ6GIR/VAAuRAAMd1xTPQA/75+/9x4SP8Aybm+/6WWlv8ApJGR/9LJyf92+B0NAH/RPLDfveAPEOIA3d3/zM7P/82A7g2QHhj0//9rCPA/O4bSnjAAACTkT5CuCgACvzYAHar+xpX/9p0AX/+1cmj/vbgHu//q5OQtIB0Y3gjB37IvAKC9BpzhHRDtEvHtAOz/y8bM/8dxAFL//rd8//u1An3/YC4Jqe0AE6D+CKkqSwGnCAA93QB/X/3/16T/4QCEVf/SsLL/833yHggQZ9AC4aUQHRH9PgPw764gLREc1InBFb0f7RDuAwHoThDs7O7/yY2GCP/wm2PhC6n/wwFzNfAVBQBL/g4NUJoAACA6AAAAwOohMTnPe/kP8E89+j/Nt/W/Jd0wAN/+0BDh3o3QtOHfB+E1EG0tvgrEE90grQrwwL0MzRrr7O//yZsAmv/ijWD//9wAtf/uqHD/UyIrAozZAAj90KL9EAwAtNk1MJuzosyPjUD730/d4SBY9g/wvNr6r52t/f+RfHzctNIm4TcQfR+OAcHeFNELwRDxvgvgvRDg2wDf/8iUkP/gk0BswgXg+69PXPk/sEj0kJsg4NQhAAbaDznKAJ8HAACNAAAAJbVJOtr8AN++///nwv/gAJp6/7t/eP/SB8DC/+znXgvQDdDGQYfuawGeA9ESId848N4O4P6fHk7+T4wKoPov3Pf2z+4KpBjW8Pzf3xz6/0BapXHcTaA1EgDaDy8AFckFhgokcJoDkwwRr+wa6KD9T68MwPqfvUn4f8wIJOiuAaf/2sLE/wHWxMb/va6wzhgAwPxfzev7v+wJsPm/zPj3H04KsPi/n937/08PwP0/z8v43/nkYHHLgeCu8QAA0Q8vIInKBYoMMOgsApobFACS0o12/P7s0oDqEiD+j/+N/K8O5OuxAbCb/9yolQD/26aU/92qlgD/47Od/+3FrhT//eecoO/xAeLBAP/bkFb0djUHHYIQBD4lAvAD/fAKiQwAhMgAjAYAQKs8ACep0Yht8vDSVbcOIbDdCEAuCADmHADKQPjNAO3V//LKQKXdAFjpjUgVnQ1DFwA0/iZv0Q9vsGiBAgCQDwMAkgwAAACWEQAxoy0PaQCyUCqhwGpAzADMflTn0YZZ7gDMf0/iwXA7xgCxWyOYizoHYgdMGAApNXUuAA/RDyXM8OlSFnDw/w+cIgAAAfDn770C/AAAH0L4jiEADwBwwAADX+AMFyC+AQx/wBesxU55Bx0QPRBdEH0Q/8DKBvCD/6BbYA=='
$02_clockico = _WinAPI_Base64Decode($02_clockico)
Local Const $bString = ASM_DecompressLZMAT($02_clockico)
If $bSaveBinary Then
Local Const $hFile = FileOpen($sSavePath & "\02_clock.ico", 18)
If @error Then Return SetError(1, 0, 0)
FileWrite($hFile, $bString)
FileClose($hFile)
EndIf
Return $bString
EndFunc
Func My03_websiteico($bSaveBinary = False, $sSavePath = @ScriptDir)
Local $03_websiteico
$03_websiteico &= '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'
$03_websiteico &= 'l3D/yZgAcf9jxKz/QdJmvx0hDSHKtx0lDRNoAKiM/zm1oP9AAK2W/3uQb/9lA5p9/7mLaA0d/aYAiU0ht7GAW/8QV6KIzSw5rJb/Bkatl/+znQbNFMEkjWPtMJRs3SDKmQBz/8ybdf/NnAB2/7+ifv9SzwG6/0HTwP8+HQMAVMKr/06+qP8AYrKY/z+5pf8BMLqn/zG0ny0vQFx9ALODXv+JTWAj/bo9DZ5oQvSCNKCEzW7tGVYtDsCLaGHNJN0SyO0Ay5p0AP/NnXf/z596CP/QoXwMIom7CfBPqOv5T2ibKfC/y3n3z8sJoTyceD0rDRctHz4D4QhqMPgPqjbU7+4TEIoATyX5wKCC/zQwrJj9MP0NMbyp/wFhsJb/u5RtzSQYyply7SDNENKkfwj/06WBDHI1/YvyH9dRQMwFgbOYA/9Xvqf/PP0EDReg/VA5XQDJpIX/ijBPJv4C3nAzYtvK53HFz9fM0HvRD9HAUQPY45ClO/oPrDkH8+/bJNAtIT369x9QfTr4f61qyCAByKyK/07Uvx0nHj7Ouj0tDVkuAdEPARiQ6vj/6qfF304A7m/g/grldgD2w5+A/xBNrJX9IDi6pv8QVLaeTSxJxbD/RLLdANCge80i1qkEhv/ZrosMcpwKgPifOjv5n/SMsfs/1NLQD930ihnyb9yxkNgkYt8JAeyQ8QYdCZmbYTn2xACtkf9Cspv/rGCQjQytDD3Dr/+LDK2P/8y9CP0QtqdAhf0wrYr/uK2OAP+Zq47/mqiKAP+Zs5X/la+QCP9Owav9IDO/rIANLb6xlv+cZDtg9n0QDhuvIJlEcqAIwCTy/Pq3tX+L4Dr5f+RNAJ2bdyD/tZ0MyJZv/8sIm3T/xf0AMK+bAv+TrZD/0u0E1gCphf+uqYf/zwCkgP9gxK3/bQC7ov9ZvKT/UgC6ov8+vKf/qocdC7GAXftdEH0Q/h7vgLBoNGLROWAeGxjgtY9cy/k/2SYAkAca+C+6ifcP8Bga+N/7mfcPMeSK2VeChEz7XwCXC/rv3FXw3BUAVNx2oKYL+l/FC1H6n9id4Jzr+f8gOwi23wPRBeEQ8hasAaDoRPLcafZjDyDtKvnfGKv5D2CVGvnfddr4b2TGACqwnP0grgDh1LBs+9/cDdDysdz1ALC8afePXav5P0TdD+CJBmTfAdEOr0HYUpnoNKLJD/a5CIxs/dxNDNm2mwj/qKuPzgAg+K8JYIr47+ga+S8LcHr4Dz0a+E8NsNr4r43r+d8dAJz6n+vo1s8d9PzRTC/B8Aq9GYvNC4xRACn3q3tY9MehAYX/1LKa/9yOAgAQbhz7z/2L+g9ATbv5jyxq+I+wupdFzxmLTiN4tp36Cgwv4lgh3gGw6EQCcKvoVNKt2DTyF++hEBzBE1zBF24AL8DwiwDwD//+AAB/8K0OLADsEQKAfifAAAEMuDfAFWzI8BPMBe6uAgwh2AeBDwDww98K8H+q1BLAWRf//w=='
$03_websiteico = _WinAPI_Base64Decode($03_websiteico)
Local Const $bString = ASM_DecompressLZMAT($03_websiteico)
If $bSaveBinary Then
Local Const $hFile = FileOpen($sSavePath & "\03_website.ico", 18)
If @error Then Return SetError(1, 0, 0)
FileWrite($hFile, $bString)
FileClose($hFile)
EndIf
Return $bString
EndFunc
Func My04_newsfeedico($bSaveBinary = False, $sSavePath = @ScriptDir)
Local $04_newsfeedico
$04_newsfeedico &= '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'
$04_newsfeedico &= 'RJNp7wAh/dAX/QBMjgDs/yt86/8rfUDp/QLl/1SV5/8AZKHr/0yW7P8ANIzv/zKO8P9AM/0HMo7q/0uYDOb/tdO9tgARDg/A/1+lmv8/owmw/+9yuf+PIkmh/1/iHAAjHRGK9w3/Q5r3HhLSDz+w2A6Ak6feDsAADQEsfegA/y2A6f8vg+oA/y+G6v8uheYA/1CY5P+myu/gHQWdegD17c7/LwWAiv/PA7r/3wPJAD6fHOC5/88DwKn/n6OZ/3/jcJn/r9R84EIR/dAYAF/O/0uJ6v8qBHfo/yp4DHBHDvBfdDj+n1VJDvDfNmr+D5m7zvA/nD3vBqAAKX1e6LcAqPn/Ob0AOgzAtdMOwMMQ/RAM4NM5yBD6/1Sn+j4W0A9fAHCY/q9Cd/6fAlA3/n8Ch/2PC/bcjw8A0PT5/v+aCMj3/z3uBYCzud/zj9MJ0BDZEdIQ1MMGGFOo+04Y0g8voFSIDvCfImf+nxIHDvBvsib9T7vMDtoNf+CfqyDMjf9PhRAq/1/jDwA2l/gL/zeZ+Q0B+g0xDIDYEC8wlcrfDz+QAfYM8K80iP6PAlcO8I/yFv5/ojYN3A/eyFFNjv+/GVwQ/5/V2e4ZAPAtCQD0/zSR9f81lGv3XQsNAZgNQZwN8QEMACfVD+DGEf3wAkmB5v8CJ23k/ydu/QBrANr/d6Lk/6nFAO//iLDr/2idsH4aoNjV0NbQArj+b/NC6DgQvgOw6FoADQEz9A0hHQMNkR3zAVH98AjMRgR/4v8tcP0AbeMC/yhu4v8nHQMoA3Hh/yp15E0pbRtBLH0NLH7s/y2eAdDxQujeEOOOAA1RNA2RUJodsz9+GOAEKv8P6ggCzv3QGmHQYx0pYtUNIy3+F3DC1hAg81bectBzMGfeEHDe2raT19Ww51cADRGADQFMgw0Bh/ANMS4FMAP53DHQc1BT2RDQy9AQ1U4BsGTK/3+lif6v0GBFHNoPHyDAAP/ADREdE0iC5v9JgxXn/0nODKDkZwBLPgmwtORKAEuL7gDQ6BQArgMQwBTZ/t8k6e59IBBQmPD+CwLFKf8PJOU4AFOh9f9TowD2/1Sk9/9TpQD3/1qm9P9SjwLg/yhpy/+eIoBT7S/yAg1BWC0FuwzQzhAMGGDO7W0LDHLx5dPc7hkADOJ7AAzinQDtqu4L0O7fAO0OENDuIQHtCBNaye0+FtAukQWC3O6lAe0RWMftgn4eQA2BZXznKQIbwM4q3w8g8AAAD+AAGwADwAwf1Qlw4ARQ'
$04_newsfeedico = _WinAPI_Base64Decode($04_newsfeedico)
Local Const $bString = ASM_DecompressLZMAT($04_newsfeedico)
If $bSaveBinary Then
Local Const $hFile = FileOpen($sSavePath & "\04_newsfeed.ico", 18)
If @error Then Return SetError(1, 0, 0)
FileWrite($hFile, $bString)
FileClose($hFile)
EndIf
Return $bString
EndFunc
Func My05_tickerico($bSaveBinary = False, $sSavePath = @ScriptDir)
Local $05_tickerico
$05_tickerico &= 'vhAAAAAkAAECAALiECAAAKgQAAAWAAAAZygGQAIAQAbgEgCiaQMQCwYD8P+CAgW5BQiqBp8lkGn4YwB2BsAHa/BVSWdAAFJRUXEK4Ofn95+YmPgfgIiI+H94eGggEYaGhgZaWFhooBGEhIQGMjg4aGARgoKCBhYYGGhgEICAgCbi5OT0D0oOff5ZUlJSCg4ADv6fn5//fw9wf/9vb2//Xy9SX28g9PT0BjIvMD//Ly8vbyDxIvHxBgIPD28g7wLv7//u7u4G0i7Q3v7Pzs5uIOoA6ur/6enp/+cA5+f/5eXl/+QD5OT/fX19/vEVAehvJCQkpd/f3w3/+Pj4BnIAZX8AxP8AdQD5AOVfBvkAtb5OtO4v5ubm9iIubiD+r6en5/8H5hEOEB7+Pz4+/o/+go7uJ+Z3AH5hEJ8Q/L5xCfIJZBEmdRiRnQ2Q/a+trf1/fQ1w/R8tLf2PjR2HbSemYRt5eXn+PwBsF78QwcHB/7y9QL124vz8/G97C3D7Pzw8/P/7C/TrK9XW1v+yswCz/7W2tv/U1RjV/+GnANcQyMnJIP/CTrDKyvqvCrC6+u/5+fk/OlBa+j9LS3sD4h+PfjE3N+f/B/8QbxBfEmLupxBvAN3e3m8h3+A+cCrhGM/Q0P/RONHR/yD3EP4hPT0N8g9tAs7Ozv/EIMTEBrLM3PwvHCMs/A9mG2lpaf5/8P8/4RmnErcS7xInEQbxL7F/LvEC8T7lHk9S6TcCPxLERxB/EN3d3Q8i3Nxg3BbyBcHLy/sfBhIW9g+/YHx8/K+8srx8H1L9G7BsAbcQoB8Q25bQ6+v7nyygrPxPXFzsIK0Ara3/r6+v/8wwzc39Ik0TzMzM/wCioqL/qqqq/2C+vNBfkZqa+g8pAAn539TU1A+xp8sAB/3YvRL9Fsv8UKxgbPyf3GRgzAHPwC0B7RLT1NT/uLl/uXzSasEXfRc80UjRAAHaK1HcFhAaGvq/CbC5+X95eflPCUJJ2fkiJyf333PR06OfDCDGAP4C1i9VsL+//z/fCUDfTfTfT9VO0dTBEn0V/Zw8wRX/LNFR0S/RVdGq0cLVU9F1IegmAPk0NDSKyQAO/iIU2Q/BGo0QTRKdEv0U1PYc0FPRgNFEodxL0A1hjd6B0E/RiAHcO4CMjPzfB9IP0QrRE9Fx0RTRBNEGARAZGam/tLTU6ODg4NAgYdH9UL0StQi1tf++rQy3uLjfDSX9FK59Bt0WLRxuANFjscsSrO0GHNHTcdwQ0A8F3gHRDtUvYWlpmX8EcHSkKCAgwDDRMzHhgOH9UP0UvgHB3j/w2lDx3qig3gTRqNAt0eGx3wbR4sILXOFIUOu9Av0QjAyhr6/fwtJR4ekJ4qnvbACNCQkJDR4qKir+GT/QD9HoAZD+If7+DNPf/9/PAEf8bQH8/PxtIJ0RfRD+rgXVedUL0dXBGV0d7QD5AERERIoFBQUMMBYWVh0B8AQgICCp/g0WzVcM2ZXBkI0aDOUt7hYADNXosb29zSHNgC0Njo6O+0ZGRkONeQANLy8v3h2/0BfQxdYQYNoxwPAnDgxgylAKHh4epp0GeWkACvbdBM4f/9B04XUAAH0LDD9jN2BnB8DExOTlEL4h/w8hUC0toAAMrP4CgAyPMcAAVQcM8MAAHwzwwwBvfwyQCK/wDw=='
$05_tickerico = _WinAPI_Base64Decode($05_tickerico)
Local Const $bString = ASM_DecompressLZMAT($05_tickerico)
If $bSaveBinary Then
Local Const $hFile = FileOpen($sSavePath & "\05_ticker.ico", 18)
If @error Then Return SetError(1, 0, 0)
FileWrite($hFile, $bString)
FileClose($hFile)
EndIf
Return $bString
EndFunc
Func My06_weatherico($bSaveBinary = False, $sSavePath = @ScriptDir)
Local $06_weatherico
$06_weatherico &= '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'
$06_weatherico &= 'A4vay83N/N0Z/RdA2y0K5Ors/0y31g0FDQmLzQJqHQUtE4WeTQOB6o0CHQUNF10XU+h9Bf0QTRWNvQ0/svwE7DOZ/wXeDm9haAhgOJH4yIiK2Iiy+N4zMN+ioeytDvBvu13/3zXML/Cfa///39gN8HbZbyRn3i4T1o/RD8EAUHdtAaGtAU6+/vYMPrH8Ts4J4RHxJmqZALh2Z7Dg/MjYAOH/lc7y/13CAfv/sPL//689CVqH7QJuHQHtEF/NAnag3QCgbBAK////BOHbf9+m0Kfzin800o0RNPvv3qAAb+HwEACm1u/Md7Ta9AB8kJj6bpuz5QBFtPr2etb9+hSl7v49I76NCbP1QP+NKW7T/fk/syz8780GWL4L4b0Qacr0rQz+D9AO7+EtEYD+DuD/D/Av2yruL1t1C+jvMEa5/wtAr/0AcEG0/MlCs/wE8ECy/PfNAOlAALX8xD2x/GU7AbH/DTuy/yvdElhx7g1g7P8AHhDB44oPZNIPrxE022/4qQ3gL4sIze8aJBuz7+jSEG4PqvqP4RIRwizBEUC1/xh82YPQqi/zww2Fz/w4rqAdAC4W4Y/xF63/HIHdJbT9jkCz/xokAQzgPR5pwP6yYb8A/rJfvPyyPbEg/Xkt8AOs+Sg+sDj9i54f4oUB/fASO636BDg+qvchjK/QwwqQ77LXzM+KvT/gL3u3zM/qsxFN8gsBr/cgP677Of4er7OAZKt/2ndx5O/xPQBvMdAzq0+ml+wv8mWOG/Hub/JtANGGcJdiDwNAMQYMAsL/xwAAA/n4AAEB+HgAAPw4DAAABgDgDwwQAFyrAgOADAAPAwx0wBGsTPDIAP+IwCDgAAQD//4ABhkADH8A/Dg4f/h//D8P+fx/P20wDNAKBQD/'
$06_weatherico = _WinAPI_Base64Decode($06_weatherico)
Local Const $bString = ASM_DecompressLZMAT($06_weatherico)
If $bSaveBinary Then
Local Const $hFile = FileOpen($sSavePath & "\06_weather.ico", 18)
If @error Then Return SetError(1, 0, 0)
FileWrite($hFile, $bString)
FileClose($hFile)
EndIf
Return $bString
EndFunc
Func My07_paypalico($bSaveBinary = False, $sSavePath = @ScriptDir)
Local $07_paypalico
$07_paypalico &= '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'
$07_paypalico &= 'gB0RiWFM56mFbgD8rotz/6yJceMMP8BWHN2qKMfo3G8AkGroxp8ItnTe2y4E49ASDUH+LO/VDgKo9xL/AF/WDgE='
$07_paypalico = _WinAPI_Base64Decode($07_paypalico)
Local Const $bString = ASM_DecompressLZMAT($07_paypalico)
If $bSaveBinary Then
Local Const $hFile = FileOpen($sSavePath & "\07_paypal.ico", 18)
If @error Then Return SetError(1, 0, 0)
FileWrite($hFile, $bString)
FileClose($hFile)
EndIf
Return $bString
EndFunc
Func My08_appexitico($bSaveBinary = False, $sSavePath = @ScriptDir)
Local $08_appexitico
$08_appexitico &= 'vhAAAAAkAAECAALiECAAAKgQAAAWAAAAZygGQAIAQAbgEgCyaQMSCwYD8B0FBqAWWhIGEGHwKYZh4P4ZCaoGoGEAJwbwYgA3ugYgY/AphlETsWEACqD230BgTy42NC7//QavcwlkG8YB8Ab+9eIYALrNw/9frIT/ASqYXf8ol1wGf+JtGaYAcxD0KgHwCl8SHIBm8Xw9/T/NjQ3wn0zt/N9H2gjw38OH9T9j94Rt8Bv+2GFLAD/xwnIE6C/09fX//f39AP/t8O7/y9PPAP+Jp5b/R4BfoP4vEpBPrxHxYPovCXBZ/M/u7v7vLvD+/m9/f/8Awg7w7v7fO/z7zwgAWvn/5Df2L4MQx/QfY/AJJ5Ra4P4F8Bv+oYHB+o8Yg+h8AGIQ5+npDgKhv7/vAO3/sroAtv+Gkov/U3gAYv8zbEr/L2xESAZuEonl/yc5OQDc/x0bsv9nZwDE/+nr7f/m6ADo/93g4P/V2QXY/+Dj4ich7R8BALC2s/93f3v/AVNuX/8sZ0UGCkHSaOX/Jz094f8ANzfe/yEguP8BSUi7/9ze5f4CQI19/c8c/fwPMIxs/A9dPf1P8B4P/79/EsAWR+D2rxIWZKAjimNT/j/gGxUTpwa/4B8AExPb/zg44f8AJSXA/zEvsv8QyMva/qob7PvPIJtr+w8Q/oHCZeRjoCGGUf5/4Bs5YDkGj+ATAADY/wsAC9r/NTXg/yoAKcn/IR+t/7Iitc7+f1BypWOgIDiDT/6/4BsGL1FQkA3w//Ly/f/iAi14MsD6n8lJ7P8DIyJSNgbqAcjk/wdAAkDm/wQE3gZ/UQBQ4P2PgjL+nwOAo/3fwcH6fyeSl+vvIUwzBtoBwqfk/wdGRu//DCIM6ga/YWGx7gbuAP8rKb7/FxWnEf+1vP7rYfRioBEbeEj+f7C0lP87QHRv8BcgIPf2cP8P0MJS/L+jI/sfsQtc/A/OEcRioBAadUb+fwAF9f9P0tFh8AwZGQaTkkLw/8/ExH9AEPwfoKR0+3/M7NxvEp8CwCAA0Q+hwYPCoBMZckP98AtMTAyPwBeI7RAuLv/NAPr/JwAmvP9cW77/0iPV1v2qU1dVDSH9EBMXNiQM6xbUD3/A8A6A/RAzM///SEj3AP8jIrf/cXHGHv/c3/4A2w8FEP0QFSYxIQy79uMv8Cf9EEUARPT/IB6y/4gxh87+BOYP8AoTLB0MCkGBxtMPfzI0BP8fwLHx+n+ZKe2NIIj98BIQJhkMKkGmA9gPf7Kh0fqPqopN7K9g/fASDiEWDBoRZoTTD3/yWYrcDtYPb8EgwiHBoBBeNf3wIy4xLUb+EtIP75Fw8cCgHA5bNP3wI/4W1Q8vEYsLUft/7/IAZmto/xAHEAoMF7HwzwByFdMPvzSre/uPCeDJ+U9NTf2vJeC19U+QcMBgBQIKCP8LUy/98EPLANDO/6itq/+FAIuI/3+Egv+2ALa2/01RT/8BIAQDDCZgQPCfAALV0g//o+zc/O8IEAn5X4d39w8HQCf3v/bW9g8YMCj4H0Qk9G+pAY4MitCk0g+/0nDBUMcAz8v/maCd/1sAX13/UFNS/0oATkz/RUhH/z8AQkH/Oj07/zUxNzU+B8ZQB0cn/fAnwf4k3wPw9/+AAAf+PiOwx58mwBAswQQDXMGQP4AADA/B3Ay/AEA='
$08_appexitico = _WinAPI_Base64Decode($08_appexitico)
Local Const $bString = ASM_DecompressLZMAT($08_appexitico)
If $bSaveBinary Then
Local Const $hFile = FileOpen($sSavePath & "\08_appexit.ico", 18)
If @error Then Return SetError(1, 0, 0)
FileWrite($hFile, $bString)
FileClose($hFile)
EndIf
Return $bString
EndFunc
Func Myopt_portrait_landscapeico($bSaveBinary = False, $sSavePath = @ScriptDir)
Local $opt_portrait_landscapeico
$opt_portrait_landscapeico &= 'fgQAAAAkAAECAAHhECAAAGgEAAAWAAAAfCgGQAIi4DIAbzSWhFPzb/AaoG0S/Pv6f/8Ab0AEBgIQfm8A8BZ+r4DvXAZvABCX8AL+rxE4JvV/Ae7/Gn6vAPASfm9g8ApmYZDhAHUZLwAQgm1dBTbwxUAEDbeQAOFQAOGXgBYAQHhWBfDnZZAEYOnX5iFEQADu9xJWYVB+WUIAyTyzpH7/4BD+fQsA4IeiNeSXAn6vkPbEQ/APiGY14FeAYHxMfnIB5Z8AL2ATnod7dn5m8AF/IZf1Gnz/AHZhCPAKb1tOAh65CfLwaoABBg/gb/AFdgE='
$opt_portrait_landscapeico = _WinAPI_Base64Decode($opt_portrait_landscapeico)
Local Const $bString = ASM_DecompressLZMAT($opt_portrait_landscapeico)
If $bSaveBinary Then
Local Const $hFile = FileOpen($sSavePath & "\opt_portrait_landscape.ico", 18)
If @error Then Return SetError(1, 0, 0)
FileWrite($hFile, $bString)
FileClose($hFile)
EndIf
Return $bString
EndFunc
Func _WinAPI_Base64Decode($sB64String)
Local $aCrypt = DllCall("Crypt32.dll", "bool", "CryptStringToBinaryA", "str", $sB64String, "dword", 0, "dword", 1, "ptr", 0, "dword*", 0, "ptr", 0, "ptr", 0)
If @error Or Not $aCrypt[0] Then Return SetError(1, 0, "")
Local $bBuffer = DllStructCreate("byte[" & $aCrypt[5] & "]")
$aCrypt = DllCall("Crypt32.dll", "bool", "CryptStringToBinaryA", "str", $sB64String, "dword", 0, "dword", 1, "struct*", $bBuffer, "dword*", $aCrypt[5], "ptr", 0, "ptr", 0)
If @error Or Not $aCrypt[0] Then Return SetError(2, 0, "")
Return DllStructGetData($bBuffer, 1)
EndFunc
Func ASM_DecompressLZMAT($Data)
Local Const $MEM_COMMIT = 4096, $PAGE_EXECUTE_READWRITE = 64, $MEM_RELEASE = 32768
If @AutoItX64 Then
Local $Code = "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"
$Code &= "5/o1kEQsAf7ChQJKEWf+KPU06QsjULCtlHGUMyrwiJMbCggKTje0+TgXdGmQGXisYu9BxgKaIwr4HApKAQw/fMgSArJnA8oeSdHJqVNxagiueGUCImaKKhdshPB5iEkCHQnGQAMYF+nk0TdpgoAK8OuH/JE5agKytTp0np6Md2oBNUARWlgo5ukqCBEPM8DqFFEU4sX7H0lHQRVGyjMdg+gB5l6gi9M1J/HokAOWAfx2ZkGJJMMQiQIWuiDb/YIUHMFqySVhq4Q/EoD5Ib0MLCkZJjioUnA8/SgzlwEgZ+l9+kmBIKC0SwEvhHYkd/kuc1LVL4gDxlvdTLhpnpUVrlgn0tgHBqF6VvdwlLTPoJJ25AaLKogBuFfhaNsouwhkkD30gC3PKfdMOUUXg6RCPEWE5GmqAgGJ34M5dDgBRS4MLEkU5osYwO0ICfUwg8MkMfbrGC6J3jNUMPudSzS61JpAOsDuDkQJ1uWIN6HSnU1B2MYJ/ggfdJxF1O1noN92jOjoIHOIFu14FBrh3UCvPDk0dbGeRUnrwDOA0IQkEmvC5TiHZDxswO9VBGiYGv/Q1z2Uv0e3v8aGuFuA7/qDMecDPuoC3f/PO4A1wZASAyFgkAEpOdKgg1TWthyYWinmP54MgPQ1rpzBR+OdCEYCHEO1BcMDOcaC9fR5oBo8GGDxgnnegRnF2iZt6RmJwkbrjn4p8qoMCSAYRQ6cvNeaxiJiGCSvOZAFRYXbkA70MXZ1sTmh0KG2oM9Bt5W+SEs/+hTR6rtEiKKLuvOtooQEl+AwB6Sx8Mb1KK6aJBq4YaVSQDXA6wSRHIq227VjhUtlKx3UBa18GgWXOfkOr+nyMcp0ZSdGEbZc1CMS4wQlSgtC30Omp/KB+1oPKnRQ9EQShmkMl24oN7gEjZ+pwxjrLDDTqDNh1hKn5n9lRwVE6bcp2xQSMVB1sGCmVDoaAtoCuIKBAW5VeSOErdLKzbsNjZ8RTZmcApMQdecB3HP+FAg/JJ+NmvzUTHOjIt7TkJgYBb9/EUQhUO/8PnQEJDQ/sBD4jRJdaLEkJ5wDdiOD7unrB7ILGRdBcdoxdoGIBEeLFBAsbWhG0TzMfyziHYvp8ajvXg6NsmoEqsjRi+nXKl+X0QMJB/nqHkS5Qo10HoCvOfFyf6I9r6rpHxgxHDB1vqaa+0OlDh2qtDIng0TpiGhjPsVSGmVkO6kF9olT69UaI5FKwyILSDvNuBQ4vvLDsAuJAjMxwB+4vj8769/2oQfYYkoFt3Qw+wqswICLAfaIoUIRAx3rvNQQBxe1VwyMzwbQlQD+/POqX2DDAA=="
Else
Local $Code = "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"
$Code &= "/id8kUgoGcQx6d+KOQN0d42I71gbLXDqiaQjkCShGg8y0SwBdmp/IAxNAuyIAxEMjZ1rWqFq5KNJslERd1oWbQJAg8rwiFZAKkYDpA6gQ+m+0DV3jICU8LqooVCJssR4BJCC6UOvryGF5gG/funUP/0JA3VnuSrYwlk7kUyTCc7NZTuRQY/pjfmmZn0gdJowKggWDjLA6hRWhKlwjUclqiIz1Yh3mr816TY1iU36JAPdLd+EZAqzN5cUEPdH9UCZavcmEkP+bTBBCK9U0y2OyBEwBArp7/grkhiJkXCOQLEbRwGbJIJYoJJfEukL+jQ/zCX1IYgGYvT4RXnKmbLed054IOL8uUuTuCXnyU5ilktxoulxgIVVMe1XVr6hUVNskdyszpdIJyPGOOVSiG1pIYbi6yAG0ynROc7MVRS9jx6E21zTO1DWMd0xPhQyLB9UTYjeJPIdMURi0Bf3o+sqwFwnRTMl598XV8HjArXaiBHrRp5N62KZAwh0kNBkGWyJ6UbRRnnpe/EnhnmJS+Acg3HxM7I4FBd4GTXJgIvBhNIpdaZaY+uwS3YcS9KPjYaQLwySxhsUU9mpCbcMMSMxCctzEks9Mly+xH37cTEg2OuYNHP595luKIJo7gwaA8gSnmQBCnPv44nZLFY/nKHzHIjkTgfqgPLOrNVAr5mElhwKIeOpH/vyILUvgcMDOcFwo/TEF40UD9dmgsiNtD4LhgrIgcKDCusBKcrLagESEE+YKO3Rx/uywkNwazfLYRk7QfEQdmjNFjGJEEOga1EAFtt14YvSEyAa6cH+wpPL0euIlaSbvNO61pOm+vWAldmB4f9BB9nBbGdwr6+KhVGBoa+qHkTr26S1KYVLlz/gHY1UMwFKORTcDsSCL1p0gGx0dotUhCQcMsZtpKV3JnvTZSWB+6KvdGeE9BJGhgyVvLgJuASef6p+mI/pgqq1sZ8cCIjBFhTp0v2U99kWQMt/kWCyOIiDoOmbQll20GeGdZlTVCilAoSAobMBjPXP/Ir6OrfRwiViCcEiIZJYdA7SZioLVNR4txuNmhFZIKYCWxBUzhNp1TE/TQsKTDP8dR3hopA4XAUzgRSD4n+O9BEEhxwSf4nQEdU8qF+VJHQw2Ql2LBl9621xUcdEaoNTDVAbxgSj0Z49Fw6LKlL8xkZcC4kpdeUBgOme/FneaKTJKBJUgrBBBAqshOmg/ZknRdMQzx/UFFTVA4MkoEEdRn5FgYwyJwY4j0TpxJeA8aADdEgrY6fF2h6zJKgaDmVUcEoTTBGNFowTQYEw6Tmmi8XkMWVaJl8MLH8xxG/ry4yDt4CBw5E2CenFJCy4jUBF5CjfRDSJAx32vBi4Ajvr4e/ahQfamHtUBzH7geLAiyANDBLpsaFCAxHrvN0QQQe1V71NEoXJF0hFiQxpxhcDsuYJCPfHA5BaCqpSSQoAdfaJysHpAh7886sW0V23xqpfwwA="
EndIf
Local $Opcode = String(_LZMAT_CodeDecompress($Code))
Local $_LZMAT_Decompress =(StringInStr($Opcode, "89DB") + 1) / 2
$Opcode = Binary($Opcode)
Local $_LZMAT_CodeBufferMemory = DllCall("kernel32.dll", "ptr", "VirtualAlloc", "ptr", 0, "ulong_ptr", BinaryLen($Opcode), "dword", $MEM_COMMIT, "dword", $PAGE_EXECUTE_READWRITE)
$_LZMAT_CodeBufferMemory = $_LZMAT_CodeBufferMemory[0]
Local $_LZMAT_CodeBuffer = DllStructCreate("byte[" & BinaryLen($Opcode) & "]", $_LZMAT_CodeBufferMemory)
DllStructSetData($_LZMAT_CodeBuffer, 1, $Opcode)
Local $OutputLen = Int(BinaryMid($Data, 1, 4))
$Data = BinaryMid($Data, 5)
Local $InputLen = BinaryLen($Data)
Local $Input = DllStructCreate("byte[" & $InputLen & "]")
DllStructSetData($Input, 1, $Data)
Local $Output = DllStructCreate("byte[" & $OutputLen & "]")
Local $Ret = DllCallAddress("uint", DllStructGetPtr($_LZMAT_CodeBuffer) + $_LZMAT_Decompress, "struct*", $Input, "uint", $InputLen, "struct*", $Output, "uint*", $OutputLen)
DllCall("kernel32.dll", "bool", "VirtualFree", "ptr", $_LZMAT_CodeBufferMemory, "ulong_ptr", 0, "dword", $MEM_RELEASE)
Return BinaryMid(DllStructGetData($Output, 1), 1, $Ret[4])
EndFunc
Func _LZMAT_CodeDecompress($Code)
Local Const $MEM_COMMIT = 4096, $PAGE_EXECUTE_READWRITE = 64, $MEM_RELEASE = 32768
If @AutoItX64 Then
Local $Opcode = "0x89C04150535657524889CE4889D7FCB28031DBA4B302E87500000073F631C9E86C000000731D31C0E8630000007324B302FFC1B010E85600000010C073F77544AAEBD3E85600000029D97510E84B000000EB2CACD1E8745711C9EB1D91FFC8C1E008ACE8340000003D007D0000730A80FC05730783F87F7704FFC1FFC141904489C0B301564889FE4829C6F3A45EEB8600D275078A1648FFC610D2C331C9FFC1E8EBFFFFFF11C9E8E4FFFFFF72F2C35A4829D7975F5E5B4158C389D24883EC08C70100000000C64104004883C408C389F64156415541544D89CC555756534C89C34883EC20410FB64104418800418B3183FE010F84AB00000073434863D24D89C54889CE488D3C114839FE0F84A50100000FB62E4883C601E8C601000083ED2B4080FD5077E2480FBEED0FB6042884C00FBED078D3C1E20241885500EB7383FE020F841C01000031C083FE03740F4883C4205B5E5F5D415C415D415EC34863D24D89C54889CE488D3C114839FE0F84CA0000000FB62E4883C601E86401000083ED2B4080FD5077E2480FBEED0FB6042884C078D683E03F410845004983C501E964FFFFFF4863D24D89C54889CE488D3C114839FE0F84E00000000FB62E4883C601E81D01000083ED2B4080FD5077E2480FBEED0FB6042884C00FBED078D389D04D8D7501C1E20483E03041885501C1F804410845004839FE747B0FB62E4883C601E8DD00000083ED2B4080FD5077E6480FBEED0FB6042884C00FBED078D789D0C1E2064D8D6E0183E03C41885601C1F8024108064839FE0F8536FFFFFF41C7042403000000410FB6450041884424044489E84883C42029D85B5E5F5D415C415D415EC34863D24889CE4D89C6488D3C114839FE758541C7042402000000410FB60641884424044489F04883C42029D85B5E5F5D415C415D415EC341C7042401000000410FB6450041884424044489E829D8E998FEFFFF41C7042400000000410FB6450041884424044489E829D8E97CFEFFFF56574889CF4889D64C89C1FCF3A45F5EC3E8500000003EFFFFFF3F3435363738393A3B3C3DFFFFFFFEFFFFFF000102030405060708090A0B0C0D0E0F10111213141516171819FFFFFFFFFFFF1A1B1C1D1E1F202122232425262728292A2B2C2D2E2F3031323358C3"
Else
Local $Opcode = "0x89C0608B7424248B7C2428FCB28031DBA4B302E86D00000073F631C9E864000000731C31C0E85B0000007323B30241B010E84F00000010C073F7753FAAEBD4E84D00000029D97510E842000000EB28ACD1E8744D11C9EB1C9148C1E008ACE82C0000003D007D0000730A80FC05730683F87F770241419589E8B3015689FE29C6F3A45EEB8E00D275058A164610D2C331C941E8EEFFFFFF11C9E8E7FFFFFF72F2C32B7C2428897C241C61C389D28B442404C70000000000C6400400C2100089F65557565383EC1C8B6C243C8B5424388B5C24308B7424340FB6450488028B550083FA010F84A1000000733F8B5424388D34338954240C39F30F848B0100000FB63B83C301E8CD0100008D57D580FA5077E50FBED20FB6041084C00FBED078D78B44240CC1E2028810EB6B83FA020F841201000031C083FA03740A83C41C5B5E5F5DC210008B4C24388D3433894C240C39F30F84CD0000000FB63B83C301E8740100008D57D580FA5077E50FBED20FB6041084C078DA8B54240C83E03F080283C2018954240CE96CFFFFFF8B4424388D34338944240C39F30F84D00000000FB63B83C301E82E0100008D57D580FA5077E50FBED20FB6141084D20FBEC278D78B4C240C89C283E230C1FA04C1E004081189CF83C70188410139F374750FB60383C3018844240CE8EC0000000FB654240C83EA2B80FA5077E00FBED20FB6141084D20FBEC278D289C283E23CC1FA02C1E006081739F38D57018954240C8847010F8533FFFFFFC74500030000008B4C240C0FB60188450489C82B44243883C41C5B5E5F5DC210008D34338B7C243839F3758BC74500020000000FB60788450489F82B44243883C41C5B5E5F5DC210008B54240CC74500010000000FB60288450489D02B442438E9B1FEFFFFC7450000000000EB9956578B7C240C8B7424108B4C241485C9742FFC83F9087227F7C7010000007402A449F7C702000000740566A583E90289CAC1E902F3A589D183E103F3A4EB02F3A45F5EC3E8500000003EFFFFFF3F3435363738393A3B3C3DFFFFFFFEFFFFFF000102030405060708090A0B0C0D0E0F10111213141516171819FFFFFFFFFFFF1A1B1C1D1E1F202122232425262728292A2B2C2D2E2F3031323358C3"
EndIf
Local $AP_Decompress =(StringInStr($Opcode, "89C0") - 3) / 2
Local $B64D_Init =(StringInStr($Opcode, "89D2") - 3) / 2
Local $B64D_DecodeData =(StringInStr($Opcode, "89F6") - 3) / 2
$Opcode = Binary($Opcode)
Local $CodeBufferMemory = DllCall("kernel32.dll", "ptr", "VirtualAlloc", "ptr", 0, "ulong_ptr", BinaryLen($Opcode), "dword", $MEM_COMMIT, "dword", $PAGE_EXECUTE_READWRITE)
$CodeBufferMemory = $CodeBufferMemory[0]
Local $CodeBuffer = DllStructCreate("byte[" & BinaryLen($Opcode) & "]", $CodeBufferMemory)
DllStructSetData($CodeBuffer, 1, $Opcode)
Local $B64D_State = DllStructCreate("byte[16]")
Local $Length = StringLen($Code)
Local $Output = DllStructCreate("byte[" & $Length & "]")
DllCallAddress("none", DllStructGetPtr($CodeBuffer) + $B64D_Init, "struct*", $B64D_State, "int", 0, "int", 0, "int", 0)
DllCallAddress("int", DllStructGetPtr($CodeBuffer) + $B64D_DecodeData, "str", $Code, "uint", $Length, "struct*", $Output, "struct*", $B64D_State)
Local $ResultLen = DllStructGetData(DllStructCreate("uint", DllStructGetPtr($Output)), 1)
Local $Result = DllStructCreate("byte[" &($ResultLen + 16) & "]"), $Ret
If @AutoItX64 Then
$Ret = DllCallAddress("uint", DllStructGetPtr($CodeBuffer) + $AP_Decompress, "ptr", DllStructGetPtr($Output) + 4, "struct*", $Result, "int", 0, "int", 0)
Else
$Ret = DllCall("user32.dll", "uint", "CallWindowProc", "ptr", DllStructGetPtr($CodeBuffer) + $AP_Decompress, "ptr", DllStructGetPtr($Output) + 4, "ptr", DllStructGetPtr($Result), "int", 0, "int", 0)
EndIf
DllCall("kernel32.dll", "bool", "VirtualFree", "ptr", $CodeBufferMemory, "ulong_ptr", 0, "dword", $MEM_RELEASE)
Return BinaryMid(DllStructGetData($Result, 1), 1, $Ret[0])
EndFunc
Opt("MustDeclareVars", 1)
Opt("TrayMenuMode", 1 + 2 + 4)
Opt("TrayIconHide", 1)
Opt("TrayAutoPause", 0)
Opt("WinTitleMatchMode", 2)
Global Const $sTitle = " " & "Layout Designer"
Global Const $sVersion = "0.3"
Global Const $sAppName = "DS-Layout"
Global Const $sAppPath = @AppDataDir & "\" & $sAppName & "\"
Global Const $sIniFile = @AppDataDir & "\" & $sAppName & "\" & $sAppName & ".ini"
Global Const $iWindowStyle = BitOR($WS_EX_TOOLWINDOW, 0)
Global $iOptionsRound = 2
Global $iOptionsGap = 10
Global $sMyState = ""
Global Const $aResolution[3][3] = [ ["800x450 (16:9)", 800, 450], ["800x500 (16:10)", 800, 500], ["800x600 (4:3)", 800, 600]]
Global $hGUI
Global $aGUI_Buttons = [0]
Global $iCloseButton
Global $iPaypalButton
Global $iToolBar
Global Enum $eTB_New = 2000, $eTB_Open, $eTB_Save
Global $aLayouts[1][5] = [[0, 0, 0, 0, 0]]
Global Enum $eL_Handle = 0, $eL_Path, $eL_File, $eL_State, $eL_Resolution
Global $hLastLayout = 0
Global $aProperties[1][3] = [[0, 0, 0]]
Global Enum $eP_LHandle = 0, $eP_Handle, $eP_Cid
Global $aGids[1][9] = [[0, 0, 0, 0, 0, 0, 0, 0, 0]]
Global Enum $eG_LHandle = 0, $eG_Cid, $eG_CHandle, $eG_X, $eG_Y, $eG_W, $eG_H, $eG_Name, $eG_Type
Global $aPids[1][4] = [[0, 0, 0, 0]]
Global Enum $eX_Func = 0, $eX_Pid, $eX_Cid, $eX_LHandle
Global $iToolBarClick
Global $iDoubleClickControl
Global $iDoubleClickLayout
Global $iContextMenuOf
Global $iPropertyClick
Global Enum $eCM_Save = 1000, $eCM_SaveAs, $eCM_Properties, $eCM_Close, $eCM_CProperties, $eCM_Delete, $eCM_Info
Global $sLastDirectory = IniRead($sIniFile, "Options", "LastDirectory", @ScriptDir)
Func ToolBox_Init()
Local $iTop = IniRead($sIniFile, "Options", "Top", 100)
Local $iLeft = IniRead($sIniFile, "Options", "Left", 100)
$iOptionsRound = IniRead($sIniFile, "Options", "Round", $iOptionsRound)
$iOptionsGap = IniRead($sIniFile, "Options", "Gap", $iOptionsGap)
$hGUI = GUICreate($sTitle & " - ToolBox", 170, 12 + 50 * 9, $iTop, $iLeft, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_APPWINDOW))
DirCreate($sAppPath)
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
EndFunc
Func ToolBox_AddButton($sName, $fIcon)
Local $iButton = GUICtrlCreateButton($sName, 8, 44 + 50 * $aGUI_Buttons[0], 150, 44, $BS_FLAT)
Local $hImage = _GUIImageList_Create(32, 32, 5, 3, 1)
_GUIImageList_Add($hImage, _GDIPlus_BitmapCreateFromMemory($fIcon, 1))
_GUICtrlButton_SetImageList($iButton, $hImage)
$aGUI_Buttons[0] += 1
_ArrayAdd($aGUI_Buttons, $iButton)
EndFunc
Func ToolBox_DisableButtons()
Local $i
For $i = 1 To 6
GUICtrlSetState($aGUI_Buttons[$i], $GUI_DISABLE)
Next
_GUICtrlToolbar_EnableButton($iToolBar, $eTB_Save, False)
EndFunc
Func ToolBox_EnableButtons()
Local $i
For $i = 1 To 6
GUICtrlSetState($aGUI_Buttons[$i], $GUI_ENABLE)
Next
_GUICtrlToolbar_EnableButton($iToolBar, $eTB_Save, True)
EndFunc
Func ToolBox_Exit()
If $aLayouts[0][0] > 0 Then
If MsgBox(BitOR($MB_YESNO, $MB_ICONQUESTION), $sTitle, "Soll " & $sTitle & " geschlossen werden?") <> $IDYES Then Return
EndIf
Local $aPos = WinGetPos($hGUI)
IniWrite($sIniFile, "Options", "Top", $aPos[0])
IniWrite($sIniFile, "Options", "Left", $aPos[1])
IniWrite($sIniFile, "Options", "Round", $iOptionsRound)
IniWrite($sIniFile, "Options", "Gap", $iOptionsGap)
_GDIPlus_Shutdown()
Exit
EndFunc
Func Layout_CheckCurrent()
If WinActive($hLastLayout) Then Return
For $i = 1 To $aLayouts[0][0]
If WinActive($aLayouts[$i][$eL_Handle]) Then
$hLastLayout = $aLayouts[$i][$eL_Handle]
Return
EndIf
Next
EndFunc
Func Layout_Create($sPath, $sFile, $sState, $pRes = 0, $pLeft = -1, $pTop = -1)
Local $iWidth, $iHeight
Local $iRes = $pRes
$iWidth = $aResolution[$iRes][1]
$iHeight = $aResolution[$iRes][2]
Local $hWin = GUICreate($sTitle & " - " & $sFile, $iWidth, $iHeight, $pLeft, $pTop, -1, $iWindowStyle, $hGUI)
GUISetState(@SW_SHOW, $hWin)
_ArrayAdd($aLayouts, $hWin & "|" & $sPath & "|" & $sFile & "|" & $sState & "|" & $iRes)
$aLayouts[0][0] += 1
ToolBox_EnableButtons()
Return $hWin
EndFunc
Func Layout_New()
Local $sName, $i = 0, $j
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
EndFunc
Func Layout_Open($pFileName = "")
Local $sFile
If Not StringLen($pFileName) = 0 And FileExists($pFileName) Then
$sFile = $pFileName
Else
$sFile = FileOpenDialog($sTitle & " - Layout öffnen", $sLastDirectory, "DSBD Layouts (*.dsbd)", $FD_FILEMUSTEXIST)
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
If $hWnd = -1 Then
MsgBox(BitOR($MB_OK, $MB_ICONERROR), $sTitle, "Layout Datei enthält Fehler!")
Return
EndIf
For $i = 1 To $aLayouts[0][0]
If $aLayouts[$i][$eL_Handle] = $hWnd Then
$aLayouts[$i][$eL_State] = "U"
Return $hWnd
EndIf
Next
Return $hWnd
EndFunc
Func Layout_Save($hLayout, $iForce = 0)
Local $iLayout = -1
For $i = 1 To $aLayouts[0][0]
If $aLayouts[$i][$eL_Handle] = $hLayout Then
$iLayout = $i
ExitLoop
EndIf
Next
If $iLayout = -1 Then Return
Local $sFile
If $iForce = 0 Then
$sFile = FileSaveDialog($sTitle & " - Layout speichern", $aLayouts[$iLayout][$eL_Path], "DSBD Layouts (*.dsbd)", 0, $aLayouts[$iLayout][$eL_File])
If @error Then Return
Else
$aLayouts[$iLayout][$eL_Path] &= "\"
$sFile = $aLayouts[$iLayout][$eL_Path] & $aLayouts[$iLayout][$eL_File]
EndIf
Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
_PathSplit($sFile, $sDrive, $sDir, $sFileName, $sExtension)
$sFileName &= $sExtension
$aLayouts[$iLayout][$eL_Path] = $sDrive & $sDir
If $sFileName <> $aLayouts[$iLayout][$eL_File] Then
$aLayouts[$iLayout][$eL_File] = $sFileName
WinSetTitle($hLayout, "", $sTitle & " - " & $aLayouts[$iLayout][$eL_File])
EndIf
FileDelete($sFile)
Local $iRes = $aLayouts[$iLayout][$eL_Resolution]
Local $iX = $aResolution[$iRes][1]
Local $iY = $aResolution[$iRes][2]
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
$sIniSection &= " " & @LF
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
$sIniSection &= " " & @LF
IniWriteSection($sFile, $aGids[$i][$eG_Name], $sIniSection)
EndIf
Next
If Not FileExists($sFile) Then
MsgBox(BitOR($MB_OK, $MB_ICONERROR), $sTitle, "Fehler bei speichern der Datei " & $sFile & "!")
Return
EndIf
$aLayouts[$iLayout][$eL_State] = "U"
Return
EndFunc
Func Layout_Control_SetTip($iCtrl, $iGid = -1)
If $iGid = -1 Then
For $i = 1 To $aGids[0][0]
If $aGids[$i][$eG_Cid] = $iCtrl Then
$iGid = $i
ExitLoop
EndIf
Next
EndIf
If $iGid = -1 Then Return
Local $sText = ""
$sText &= "Start: " & $aGids[$iGid][$eG_X] & "x" & $aGids[$iGid][$eG_Y] & @LF
$sText &= "Breite: " & $aGids[$iGid][$eG_W] & @LF
$sText &= "Höhe: " & $aGids[$iGid][$eG_H] & @LF & @LF
$sText &= "Typ: " & $aGids[$iGid][$eG_Type] & @LF
GUICtrlSetTip($iCtrl, $sText, $aGids[$iGid][$eG_Name])
EndFunc
Func Layout_Create_Control($hLayout, $sType, $pName = -1, $pLeft = -1, $pTop = -1, $pWidth = -1, $pHeight = -1)
Local $iLayout = -1
For $i = 1 To $aLayouts[0][0]
If $aLayouts[$i][$eL_Handle] = $hLayout Then
$iLayout = $i
ExitLoop
EndIf
Next
If $iLayout = -1 Then Return
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
Local $iCtrl = GUICtrlCreateLabel($sName, $pLeft, $pTop, $iWidth, $iHeight, BitOR($SS_NOTIFY, $WS_BORDER))
Local $hGid = GUICtrlGetHandle($iCtrl)
GUICtrlSetBkColor(-1, $iColor)
GUISetState(@SW_SHOW)
Local $sArray = $hLayout & "|" & $iCtrl & "|" & $hGid & "|" & $pLeft & "|" & $pTop & "|" & $iWidth & "|" & $iHeight & "|" & $sName & "|" & $sType
_ArrayAdd($aGids, $sArray)
$aGids[0][0] += 1
Layout_Control_SetTip($iCtrl)
$aLayouts[$iLayout][$eL_State] = "M"
EndFunc
Func Layout_Delete_Control($iGid)
Local $iCtrl = $aGids[$iGid][$eG_Cid]
Layout_Delete_PControl($iCtrl)
For $i = $aProperties[0][0] To 1 Step -1
If $aProperties[$i][$eP_Cid] = $iCtrl Then CloseSomeWindow($aProperties[$i][$eP_Handle])
Next
GUICtrlDelete($iCtrl)
_ArrayDelete($aGids, $iGid)
$aGids[0][0] -= 1
EndFunc
Func Layout_Delete_PControl($iCtrl)
For $i = $aPids[0][0] To 1 Step -1
If $aPids[$i][$eP_Cid] = $iCtrl Then
_ArrayDelete($aPids, $i)
$aPids[0][0] -= 1
EndIf
Next
EndFunc
Func Layout_Move_Control($hWnd)
Static $iCtrl = -1
Static $iGid, $iLayout, $iRes, $iMaxX, $iMaxY
If $hWnd = $hGUI Then Return
If $iGid > $aGids[0][0] Then $iGid = -1
Local $aCursor = GUIGetCursorInfo($hWnd)
If @error <> 0 Then Return
If $aCursor[4] = 0 Then Return
Local $aCtrlPos = ControlGetPos($hWnd, "", $aCursor[4])
If @error = 1 Then Return
If $aCursor[4] <> $iCtrl Then
$iCtrl = $aCursor[4]
$iLayout = -1
For $i = 1 To $aLayouts[0][0]
If $aLayouts[$i][$eL_Handle] = $hWnd Then
$iLayout = $i
ExitLoop
EndIf
Next
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
Enum $eW_All = 0, $eW_OL, $eW_O, $eW_OR, $eW_L, $eW_R, $eW_UL, $eW_U, $eW_UR
Local $iX = $aCursor[0] - $aCtrlPos[0]
Local $iY = $aCursor[1] - $aCtrlPos[1]
Local $iW = $aCtrlPos[2]
Local $iH = $aCtrlPos[3]
Local $iState = $eW_All
Local $iCursor
Local Const $iGap = $iOptionsGap
If($iX < $iGap) And($iY < $iGap) Then
$iState = $eW_OL
ElseIf($iX < $iGap) And($iY + $iGap > $iH) Then
$iState = $eW_UL
ElseIf($iY < $iGap) And($iX + $iGap > $iW) Then
$iState = $eW_OR
ElseIf($iY + $iGap > $iH) And($iX + $iGap > $iW) Then
$iState = $eW_UR
ElseIf($iX < $iGap) Then
$iState = $eW_L
ElseIf($iY < $iGap) Then
$iState = $eW_O
ElseIf($iX + $iGap > $iW) Then
$iState = $eW_R
ElseIf($iY + $iGap > $iH) Then
$iState = $eW_U
EndIf
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
Local $iPropCtrl = -1
Local $iPropX, $iPropY, $iPropW, $iPropH
Local $iPropXp, $iPropYp, $iPropWp, $iPropHp
For $i = 1 To $aPids[0][0]
If $aPids[$i][$eX_Cid] = $iCtrl Then
$iPropCtrl = $aPids[$i][$eX_Pid]
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
Local $aStart = $aCursor
$iX = $aCtrlPos[0]
$iY = $aCtrlPos[1]
$iW = $aCtrlPos[2]
$iH = $aCtrlPos[3]
While IsArray($aCursor) And $aCursor[2] = 1
Local $iDX = $aCursor[0] - $aStart[0]
Local $iDY = $aCursor[1] - $aStart[1]
Switch $iState
Case $eW_All
$iX = $aCtrlPos[0] + $iDX
$iY = $aCtrlPos[1] + $iDY
If($iX < 0) Then $iX = 0
If($iY < 0) Then $iY = 0
If($iX + $iW > $iMaxX) Then $iX = $iMaxX - $iW
If($iY + $iH > $iMaxY) Then $iY = $iMaxY - $iH
Case $eW_OL
$iX = $aCtrlPos[0] + $iDX
$iW = $aCtrlPos[2] - $iDX
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
$iX = $aCtrlPos[0] + $iDX
$iW = $aCtrlPos[2] - $iDX
Case $eW_R
$iW = $aCtrlPos[2] + $iDX
Case $eW_UL
$iX = $aCtrlPos[0] + $iDX
$iW = $aCtrlPos[2] - $iDX
$iH = $aCtrlPos[3] + $iDY
Case $eW_U
$iH = $aCtrlPos[3] + $iDY
Case $eW_UR
$iH = $aCtrlPos[3] + $iDY
$iW = $aCtrlPos[2] + $iDX
EndSwitch
If($iX < 0) Then Return
If($iY < 0) Then Return
If($iX + $iW > $iMaxX) Then Return
If($iY + $iH > $iMaxY) Then Return
If($iW < $iGap * 2) Then $iW = $iGap * 2
If($iH < $iGap * 2) Then $iH = $iGap * 2
If($iW > $iMaxX) Then
$iW = $iMaxX
$iX = 0
EndIf
If($iH > $iMaxY) Then
$iH = $iMaxY
$iY = 0
EndIf
$aGids[$iGid][$eG_X] = $iX
$aGids[$iGid][$eG_Y] = $iY
$aGids[$iGid][$eG_W] = $iW
$aGids[$iGid][$eG_H] = $iH
GUICtrlSetPos($iCtrl, $iX, $iY, $iW, $iH)
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
$aLayouts[$iLayout][$eL_State] = "M"
Layout_Control_SetTip($iCtrl, $iGid)
Sleep(10)
$aCursor = GUIGetCursorInfo($hWnd)
If @error <> 0 Then Return
WEnd
EndFunc
Func Control_Properties($iCtrl)
Local $hWnd
For $i = 1 To $aProperties[0][0]
If $aProperties[$i][$eP_Cid] = $iCtrl Then
$hWnd = HWnd($aProperties[$i][$eP_Handle])
WinActivate($hWnd)
WinFlash($hWnd, "", 2)
Return
EndIf
Next
Local $iGid = -1
For $i = 1 To $aGids[0][0]
If $aGids[$i][$eG_Cid] = $iCtrl Then
$iGid = $i
ExitLoop
EndIf
Next
If $iGid = -1 Then Return
$hWnd = HWnd($aGids[$iGid][$eG_LHandle])
Local $aPos = ControlGetPos($hWnd, "", Int($iCtrl))
If @error <> 0 Then
Return
EndIf
Local $iLayout = -1
For $i = 1 To $aLayouts[0][0]
If $aLayouts[$i][$eL_Handle] = $hWnd Then
$iLayout = $i
ExitLoop
EndIf
Next
If $iLayout = -1 Then Return
Local $hWin = GUICreate(" Eigenschaften von: " & $aGids[$iGid][$eG_Name], 540, 140, -1, -1, -1, $iWindowStyle, $hWnd)
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
_ArrayAdd($aPids, "S1|" & $S1 & "|" & $iCtrl & "|" & $hWnd)
$aPids[0][0] += 1
_ArrayAdd($aPids, "S2|" & $S2 & "|" & $iCtrl & "|" & $hWnd)
$aPids[0][0] += 1
_ArrayAdd($aPids, "S3|" & $S3 & "|" & $iCtrl & "|" & $hWnd)
$aPids[0][0] += 1
_ArrayAdd($aPids, "S4|" & $S4 & "|" & $iCtrl & "|" & $hWnd)
$aPids[0][0] += 1
EndFunc
Func Control_CheckUpdate($sUpdateTyp, $iPropCtrl, $iCtrl, $hLayout)
Local $iLayout = -1
For $i = 1 To $aLayouts[0][0]
If $aLayouts[$i][$eL_Handle] = $hLayout Then
$iLayout = $i
ExitLoop
EndIf
Next
If $iLayout = -1 Then Return
If $iCtrl = 0 And $sUpdateTyp = "Res" Then
Local $iRes = $aLayouts[$iLayout][$eL_Resolution]
Local $iX = $aResolution[$iRes][1]
Local $iY = $aResolution[$iRes][2]
Local $aPos = WinGetPos(HWnd($hLayout))
If Not IsArray($aPos) Then
MsgBox($MB_ICONERROR, $sTitle, "Layout Fensterposition unbekannt?!")
Exit
EndIf
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
WinMove(HWnd($hLayout), "", $aPos[0], $aPos[1], $iX + $iWDiff, $iY + $iHDiff)
Return
EndIf
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
Local $sName = $aGids[$iGid][$eG_Name]
Local $iX = $aGids[$iGid][$eG_X]
Local $iY = $aGids[$iGid][$eG_Y]
Local $iW = $aGids[$iGid][$eG_W]
Local $iH = $aGids[$iGid][$eG_H]
Local $iForce = 0
Local Const $iGap = $iOptionsGap
Switch $sUpdateTyp
Case "Xp"
$iForce = GUICtrlRead($iPropCtrl)
$iPropCtrl -= 4
$iX = Ceiling($iMaxX * $iForce * 0.01)
ContinueCase
Case "X"
If $iForce = 0 Then $iX = GUICtrlRead($iPropCtrl)
If($iX < 0) Then $iX = 0
If($iX + $iW > $iMaxX) Then $iX = $iMaxX - $iW
GUICtrlSetData($iPropCtrl, $iX)
GUICtrlSetData($iPropCtrl + 4, Int($iX * 100 / $iMaxX))
Case "Yp"
$iForce = GUICtrlRead($iPropCtrl)
$iPropCtrl -= 4
$iY = Ceiling($iMaxY * $iForce * 0.01)
ContinueCase
Case "Y"
If $iForce = 0 Then $iY = GUICtrlRead($iPropCtrl)
If($iY < 0) Then $iY = 0
If($iY + $iH > $iMaxY) Then $iY = $iMaxY - $iH
GUICtrlSetData($iPropCtrl, $iY)
GUICtrlSetData($iPropCtrl + 4, Int($iY * 100 / $iMaxY))
Case "Wp"
$iForce = GUICtrlRead($iPropCtrl)
$iPropCtrl -= 4
$iW = Ceiling($iMaxX * $iForce * 0.01)
ContinueCase
Case "W"
If $iForce = 0 Then $iW = GUICtrlRead($iPropCtrl)
If($iW + $iX > $iMaxX) Then $iW = $iMaxX - $iX
If($iW < $iGap * 2) Then $iW = $iGap * 2
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
If($iH + $iY > $iMaxY) Then $iH = $iMaxY - $iY
If($iH < $iGap * 2) Then $iH = $iGap * 2
$iH = Int($iH)
GUICtrlSetData($iPropCtrl, $iH)
GUICtrlSetData($iPropCtrl + 4, Int($iH * 100 / $iMaxY))
Case "S1"
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
Case "S2"
If $iH > $iW Then
$iW = $iH
$iH = $iW /(16 / 9)
Else
$iH = $iW
$iW = $iH /(16 / 9)
EndIf
GUICtrlSetData($iPropCtrl - 7, Int($iW))
GUICtrlSetData($iPropCtrl - 6, Int($iH))
GUICtrlSetData($iPropCtrl - 3, Int($iW * 100 / $iMaxX))
GUICtrlSetData($iPropCtrl - 2, Int($iH * 100 / $iMaxY))
Case "S3"
If $iH > $iW Then
$iW = $iH
$iH = $iW /(4 / 3)
Else
$iH = $iW
$iW = $iH /(4 / 3)
EndIf
GUICtrlSetData($iPropCtrl - 8, Int($iW))
GUICtrlSetData($iPropCtrl - 7, Int($iH))
GUICtrlSetData($iPropCtrl - 4, Int($iW * 100 / $iMaxX))
GUICtrlSetData($iPropCtrl - 3, Int($iH * 100 / $iMaxY))
Case "S4"
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
$aGids[$iGid][$eG_Name] = $sName
$aGids[$iGid][$eG_X] = $iX
$aGids[$iGid][$eG_Y] = $iY
$aGids[$iGid][$eG_W] = $iW
$aGids[$iGid][$eG_H] = $iH
GUICtrlSetPos($iCtrl, $iX, $iY, $iW, $iH)
$aLayouts[$iLayout][$eL_State] = "M"
Layout_Control_SetTip($iCtrl, $iGid)
EndFunc
Func Layout_Properties($hWnd)
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
_ArrayAdd($aProperties, $hWnd & "|" & $hWin & "|" & 0)
$aProperties[0][0] += 1
GUISetState(@SW_SHOW, $hWin)
Local $idComboBox, $sRes
GUICtrlCreateLabel("Auflösung:", 8, 11, 54, 17)
$idComboBox = GUICtrlCreateCombo("", 64, 8, 220, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
$sRes = $aResolution[0][0] & "|" & $aResolution[1][0] & "|" & $aResolution[2][0]
GUICtrlSetData($idComboBox, $sRes, $aResolution[0][0])
_ArrayAdd($aPids, "Res|" & $idComboBox & "|" & 0 & "|" & HWnd($hWnd))
$aPids[0][0] += 1
EndFunc
Func CloseSomeWindow($hWnd)
Local $i
For $i = 1 To $aProperties[0][0]
If $aProperties[$i][$eP_Handle] = $hWnd Then
Layout_Delete_PControl($aProperties[$i][$eP_Cid])
GUIDelete($aProperties[$i][$eP_Handle])
_ArrayDelete($aProperties, $i)
$aProperties[0][0] -= 1
Return
EndIf
Next
For $i = 1 To $aLayouts[0][0]
If $aLayouts[$i][$eL_Handle] = $hWnd Then
Local $sName = $aLayouts[$i][$eL_File]
If $aLayouts[$i][$eL_State] = "M" Then
If MsgBox(BitOR($MB_YESNO, $MB_ICONQUESTION), $sTitle, 'Soll das geänderte Layout "' & $sName & '" gespeichert werden?') <> $IDYES Then
Layout_Save($hWnd, 1)
EndIf
EndIf
For $j = $aProperties[0][0] To 1 Step -1
If $aProperties[$j][$eP_LHandle] = $hWnd Then
CloseSomeWindow($aProperties[$j][$eP_Handle])
EndIf
Next
For $j = $aGids[0][0] To 1 Step -1
If $aGids[$j][$eG_LHandle] = $hWnd Then
_ArrayDelete($aGids, $j)
$aGids[0][0] -= 1
EndIf
Next
GUIDelete($aLayouts[$i][$eL_Handle])
_ArrayDelete($aLayouts, $i)
$aLayouts[0][0] -= 1
ExitLoop
EndIf
Next
If $aLayouts[0][0] = 0 Then
ToolBox_DisableButtons()
WinActivate($hGUI)
EndIf
EndFunc
Func GuiCtrlSetOnTop($hWnd)
Return _WinAPI_SetWindowPos($hWnd, $HWND_BOTTOM, 0, 0, 0, 0, $SWP_NOMOVE + $SWP_NOSIZE + $SWP_NOCOPYBITS)
EndFunc
Func WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
#forceref $hWnd, $iMsg, $wParam, $lParam
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
EndFunc
Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
#forceref $hWnd, $iMsg, $wParam, $lParam
Local $nID = BitAND($wParam, 0xFFFF)
Local $nNotifyCode = BitShift($wParam, 16)
If $nNotifyCode = 1 Then
GUICtrlSendToDummy($iDoubleClickControl, $nID)
Return $GUI_RUNDEFMSG
EndIf
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
For $i = 1 To $aLayouts[0][0]
If $aLayouts[$i][$eL_Handle] = $hMenu Then
Switch $wParam
Case $eCM_Save
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
EndFunc
Func WM_LBUTTONDBLCLK($hWnd, $iMsg, $wParam, $lParam)
#forceref $hWnd, $iMsg, $wParam, $lParam
GUICtrlSendToDummy($iDoubleClickLayout, $hWnd)
Return $GUI_RUNDEFMSG
EndFunc
Func WM_CONTEXTMENU($hWnd, $iMsg, $wParam, $lParam)
#forceref $hWnd, $iMsg, $wParam, $lParam
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
EndFunc
Func WM_COPYDATA($hWnd, $msg, $wParam, $lParam)
Local $COPYDATA = DllStructCreate('Ptr;DWord;Ptr', $lParam)
Local $sFileLen = DllStructGetData($COPYDATA, 2)
Local $CmdStruct = DllStructCreate('Char[255]', DllStructGetData($COPYDATA, 3))
Local $sFile = StringLeft(DllStructGetData($CmdStruct, 1), $sFileLen)
Layout_Open($sFile)
EndFunc
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
DllCall('User32.dll', 'None', 'SendMessage', 'HWnd', $hMain, 'Int', $WM_COPYDATA, 'HWnd', $hGUI, 'Ptr', DllStructGetPtr($COPYDATA))
Next
Exit
EndIf
ToolBox_Init()
If @Compiled Then
Local $aCmdLine = _WinAPI_CommandLineToArgv($CmdLineRaw)
For $i = 1 To $aCmdLine[0]
If FileExists($aCmdLine[$i]) Then Layout_Open($aCmdLine[$i])
Next
EndIf
While 1
Local $aMsg = GUIGetMsg(1)
Switch $aMsg[0]
Case 0
ContinueLoop
Case $iDoubleClickControl
Control_Properties(GUICtrlRead($iDoubleClickControl))
ContinueLoop
Case $iDoubleClickLayout
Layout_Properties(GUICtrlRead($iDoubleClickLayout))
ContinueLoop
Case $GUI_EVENT_PRIMARYUP
ContinueLoop
Case $GUI_EVENT_SECONDARYDOWN
ContinueLoop
Case $GUI_EVENT_SECONDARYUP
$sMyState = ""
ContinueLoop
Case $GUI_EVENT_MOUSEMOVE
If $sMyState = "Right" Then ContinueLoop
Layout_Move_Control($aMsg[1])
ContinueLoop
Case $GUI_EVENT_PRIMARYDOWN
Switch $sMyState
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
If $aMsg[1] = 6 Then ContinueLoop
For $i = 1 To $aPids[0][0]
If $aPids[$i][$eX_Pid] = $aMsg[0] Then
Control_CheckUpdate($aPids[$i][$eX_Func], $aPids[$i][$eX_Pid], $aPids[$i][$eX_Cid], $aPids[$i][$eX_LHandle])
ExitLoop
EndIf
Next
EndSwitch
WEnd
