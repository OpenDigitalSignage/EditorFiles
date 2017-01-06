#NoTrayIcon
Global Enum $0, $1, $2, $3, $4, $5, $6
Func _0(ByRef $7, $8, $9 = 0, $a = "|", $b = @CRLF, $c = $0)
If $9 = Default Then $9 = 0
If $a = Default Then $a = "|"
If $b = Default Then $b = @CRLF
If $c = Default Then $c = $0
If Not IsArray($7) Then Return SetError(1, 0, -1)
Local $d = UBound($7, 1)
Local $e = 0
Switch $c
Case $2
$e = Int
Case $3
$e = Number
Case $4
$e = Ptr
Case $5
$e = Hwnd
Case $6
$e = String
EndSwitch
Switch UBound($7, 0)
Case 1
If $c = $1 Then
ReDim $7[$d + 1]
$7[$d] = $8
Return $d
EndIf
If IsArray($8) Then
If UBound($8, 0) <> 1 Then Return SetError(5, 0, -1)
$e = 0
Else
Local $f = StringSplit($8, $a, 2 + 1)
If UBound($f, 1) = 1 Then
$f[0] = $8
EndIf
$8 = $f
EndIf
Local $g = UBound($8, 1)
ReDim $7[$d + $g]
For $h = 0 To $g - 1
If IsFunc($e) Then
$7[$d + $h] = $e($8[$h])
Else
$7[$d + $h] = $8[$h]
EndIf
Next
Return $d + $g - 1
Case 2
Local $i = UBound($7, 2)
If $9 < 0 Or $9 > $i - 1 Then Return SetError(4, 0, -1)
Local $j, $k = 0, $l
If IsArray($8) Then
If UBound($8, 0) <> 2 Then Return SetError(5, 0, -1)
$j = UBound($8, 1)
$k = UBound($8, 2)
$e = 0
Else
Local $m = StringSplit($8, $b, 2 + 1)
$j = UBound($m, 1)
Local $f[$j][0], $n
For $h = 0 To $j - 1
$n = StringSplit($m[$h], $a, 2 + 1)
$l = UBound($n)
If $l > $k Then
$k = $l
ReDim $f[$j][$k]
EndIf
For $o = 0 To $l - 1
$f[$h][$o] = $n[$o]
Next
Next
$8 = $f
EndIf
If UBound($8, 2) + $9 > UBound($7, 2) Then Return SetError(3, 0, -1)
ReDim $7[$d + $j][$i]
For $p = 0 To $j - 1
For $o = 0 To $i - 1
If $o < $9 Then
$7[$p + $d][$o] = ""
ElseIf $o - $9 > $k - 1 Then
$7[$p + $d][$o] = ""
Else
If IsFunc($e) Then
$7[$p + $d][$o] = $e($8[$p][$o - $9])
Else
$7[$p + $d][$o] = $8[$p][$o - $9]
EndIf
EndIf
Next
Next
Case Else
Return SetError(2, 0, -1)
EndSwitch
Return UBound($7, 1) - 1
EndFunc
Func _6(ByRef $7, $q)
If Not IsArray($7) Then Return SetError(1, 0, -1)
Local $d = UBound($7, 1) - 1
If IsArray($q) Then
If UBound($q, 0) <> 1 Or UBound($q, 1) < 2 Then Return SetError(4, 0, -1)
Else
Local $r, $m, $n
$q = StringStripWS($q, 8)
$m = StringSplit($q, ";")
$q = ""
For $h = 1 To $m[0]
If Not StringRegExp($m[$h], "^\d+(-\d+)?$") Then Return SetError(3, 0, -1)
$n = StringSplit($m[$h], "-")
Switch $n[0]
Case 1
$q &= $n[1] & ";"
Case 2
If Number($n[2]) >= Number($n[1]) Then
$r = $n[1] - 1
Do
$r += 1
$q &= $r & ";"
Until $r = $n[2]
EndIf
EndSwitch
Next
$q = StringSplit(StringTrimRight($q, 1), ";")
EndIf
If $q[1] < 0 Or $q[$q[0]] > $d Then Return SetError(5, 0, -1)
Local $s = 0
Switch UBound($7, 0)
Case 1
For $h = 1 To $q[0]
$7[$q[$h]] = ChrW(0xFAB1)
Next
For $t = 0 To $d
If $7[$t] == ChrW(0xFAB1) Then
ContinueLoop
Else
If $t <> $s Then
$7[$s] = $7[$t]
EndIf
$s += 1
EndIf
Next
ReDim $7[$d - $q[0] + 1]
Case 2
Local $i = UBound($7, 2) - 1
For $h = 1 To $q[0]
$7[$q[$h]][0] = ChrW(0xFAB1)
Next
For $t = 0 To $d
If $7[$t][0] == ChrW(0xFAB1) Then
ContinueLoop
Else
If $t <> $s Then
For $o = 0 To $i
$7[$s][$o] = $7[$t][$o]
Next
EndIf
$s += 1
EndIf
Next
ReDim $7[$d - $q[0] + 1][$i + 1]
Case Else
Return SetError(2, 0, False)
EndSwitch
Return UBound($7, 1)
EndFunc
Func _i(ByRef $7, $9 = 0, $u = 0)
If $9 = Default Then $9 = 0
If $u = Default Then $u = 0
If Not IsArray($7) Then Return SetError(1, 0, 0)
If UBound($7, 0) <> 1 Then Return SetError(3, 0, 0)
If Not UBound($7) Then Return SetError(4, 0, 0)
Local $v, $w = UBound($7) - 1
If $u < 1 Or $u > $w Then $u = $w
If $9 < 0 Then $9 = 0
If $9 > $u Then Return SetError(2, 0, 0)
For $h = $9 To Int(($9 + $u - 1) / 2)
$v = $7[$h]
$7[$h] = $7[$u]
$7[$u] = $v
$u -= 1
Next
Return 1
EndFunc
Func _l(ByRef $7, $x = 0, $9 = 0, $u = 0, $y = 0, $0z = 0)
If $x = Default Then $x = 0
If $9 = Default Then $9 = 0
If $u = Default Then $u = 0
If $y = Default Then $y = 0
If $0z = Default Then $0z = 0
If Not IsArray($7) Then Return SetError(1, 0, 0)
Local $w = UBound($7) - 1
If $w = -1 Then Return SetError(5, 0, 0)
If $u = Default Then $u = 0
If $u < 1 Or $u > $w Or $u = Default Then $u = $w
If $9 < 0 Or $9 = Default Then $9 = 0
If $9 > $u Then Return SetError(2, 0, 0)
If $x = Default Then $x = 0
If $0z = Default Then $0z = 0
If $y = Default Then $y = 0
Switch UBound($7, 0)
Case 1
If $0z Then
_o($7, $9, $u)
Else
_m($7, $9, $u)
EndIf
If $x Then _i($7, $9, $u)
Case 2
If $0z Then Return SetError(6, 0, 0)
Local $10 = UBound($7, 2) - 1
If $y > $10 Then Return SetError(3, 0, 0)
If $x Then
$x = -1
Else
$x = 1
EndIf
_n($7, $x, $9, $u, $y, $10)
Case Else
Return SetError(4, 0, 0)
EndSwitch
Return 1
EndFunc
Func _m(ByRef $7, Const ByRef $9, Const ByRef $u)
If $u <= $9 Then Return
Local $v
If($u - $9) < 15 Then
Local $11
For $h = $9 + 1 To $u
$v = $7[$h]
If IsNumber($v) Then
For $o = $h - 1 To $9 Step -1
$11 = $7[$o]
If($v >= $11 And IsNumber($11)) Or(Not IsNumber($11) And StringCompare($v, $11) >= 0) Then ExitLoop
$7[$o + 1] = $11
Next
Else
For $o = $h - 1 To $9 Step -1
If(StringCompare($v, $7[$o]) >= 0) Then ExitLoop
$7[$o + 1] = $7[$o]
Next
EndIf
$7[$o + 1] = $v
Next
Return
EndIf
Local $12 = $9, $13 = $u, $14 = $7[Int(($9 + $u) / 2)], $15 = IsNumber($14)
Do
If $15 Then
While($7[$12] < $14 And IsNumber($7[$12])) Or(Not IsNumber($7[$12]) And StringCompare($7[$12], $14) < 0)
$12 += 1
WEnd
While($7[$13] > $14 And IsNumber($7[$13])) Or(Not IsNumber($7[$13]) And StringCompare($7[$13], $14) > 0)
$13 -= 1
WEnd
Else
While(StringCompare($7[$12], $14) < 0)
$12 += 1
WEnd
While(StringCompare($7[$13], $14) > 0)
$13 -= 1
WEnd
EndIf
If $12 <= $13 Then
$v = $7[$12]
$7[$12] = $7[$13]
$7[$13] = $v
$12 += 1
$13 -= 1
EndIf
Until $12 > $13
_m($7, $9, $13)
_m($7, $12, $u)
EndFunc
Func _n(ByRef $7, Const ByRef $16, Const ByRef $9, Const ByRef $u, Const ByRef $y, Const ByRef $10)
If $u <= $9 Then Return
Local $v, $12 = $9, $13 = $u, $14 = $7[Int(($9 + $u) / 2)][$y], $15 = IsNumber($14)
Do
If $15 Then
While($16 *($7[$12][$y] - $14) < 0 And IsNumber($7[$12][$y])) Or(Not IsNumber($7[$12][$y]) And $16 * StringCompare($7[$12][$y], $14) < 0)
$12 += 1
WEnd
While($16 *($7[$13][$y] - $14) > 0 And IsNumber($7[$13][$y])) Or(Not IsNumber($7[$13][$y]) And $16 * StringCompare($7[$13][$y], $14) > 0)
$13 -= 1
WEnd
Else
While($16 * StringCompare($7[$12][$y], $14) < 0)
$12 += 1
WEnd
While($16 * StringCompare($7[$13][$y], $14) > 0)
$13 -= 1
WEnd
EndIf
If $12 <= $13 Then
For $h = 0 To $10
$v = $7[$12][$h]
$7[$12][$h] = $7[$13][$h]
$7[$13][$h] = $v
Next
$12 += 1
$13 -= 1
EndIf
Until $12 > $13
_n($7, $16, $9, $13, $y, $10)
_n($7, $16, $12, $u, $y, $10)
EndFunc
Func _o(ByRef $7, $17, $18, $19 = True)
If $17 > $18 Then Return
Local $1a = $18 - $17 + 1
Local $h, $o, $1b, $1c, $1d, $1e, $1f, $1g
If $1a < 45 Then
If $19 Then
$h = $17
While $h < $18
$o = $h
$1c = $7[$h + 1]
While $1c < $7[$o]
$7[$o + 1] = $7[$o]
$o -= 1
If $o + 1 = $17 Then ExitLoop
WEnd
$7[$o + 1] = $1c
$h += 1
WEnd
Else
While 1
If $17 >= $18 Then Return 1
$17 += 1
If $7[$17] < $7[$17 - 1] Then ExitLoop
WEnd
While 1
$1b = $17
$17 += 1
If $17 > $18 Then ExitLoop
$1e = $7[$1b]
$1f = $7[$17]
If $1e < $1f Then
$1f = $1e
$1e = $7[$17]
EndIf
$1b -= 1
While $1e < $7[$1b]
$7[$1b + 2] = $7[$1b]
$1b -= 1
WEnd
$7[$1b + 2] = $1e
While $1f < $7[$1b]
$7[$1b + 1] = $7[$1b]
$1b -= 1
WEnd
$7[$1b + 1] = $1f
$17 += 1
WEnd
$1g = $7[$18]
$18 -= 1
While $1g < $7[$18]
$7[$18 + 1] = $7[$18]
$18 -= 1
WEnd
$7[$18 + 1] = $1g
EndIf
Return 1
EndIf
Local $1h = BitShift($1a, 3) + BitShift($1a, 6) + 1
Local $1i, $1j, $1k, $1l, $1m, $1n
$1k = Ceiling(($17 + $18) / 2)
$1j = $1k - $1h
$1i = $1j - $1h
$1l = $1k + $1h
$1m = $1l + $1h
If $7[$1j] < $7[$1i] Then
$1n = $7[$1j]
$7[$1j] = $7[$1i]
$7[$1i] = $1n
EndIf
If $7[$1k] < $7[$1j] Then
$1n = $7[$1k]
$7[$1k] = $7[$1j]
$7[$1j] = $1n
If $1n < $7[$1i] Then
$7[$1j] = $7[$1i]
$7[$1i] = $1n
EndIf
EndIf
If $7[$1l] < $7[$1k] Then
$1n = $7[$1l]
$7[$1l] = $7[$1k]
$7[$1k] = $1n
If $1n < $7[$1j] Then
$7[$1k] = $7[$1j]
$7[$1j] = $1n
If $1n < $7[$1i] Then
$7[$1j] = $7[$1i]
$7[$1i] = $1n
EndIf
EndIf
EndIf
If $7[$1m] < $7[$1l] Then
$1n = $7[$1m]
$7[$1m] = $7[$1l]
$7[$1l] = $1n
If $1n < $7[$1k] Then
$7[$1l] = $7[$1k]
$7[$1k] = $1n
If $1n < $7[$1j] Then
$7[$1k] = $7[$1j]
$7[$1j] = $1n
If $1n < $7[$1i] Then
$7[$1j] = $7[$1i]
$7[$1i] = $1n
EndIf
EndIf
EndIf
EndIf
Local $1o = $17
Local $1p = $18
If(($7[$1i] <> $7[$1j]) And($7[$1j] <> $7[$1k]) And($7[$1k] <> $7[$1l]) And($7[$1l] <> $7[$1m])) Then
Local $1q = $7[$1j]
Local $1r = $7[$1l]
$7[$1j] = $7[$17]
$7[$1l] = $7[$18]
Do
$1o += 1
Until $7[$1o] >= $1q
Do
$1p -= 1
Until $7[$1p] <= $1r
$1b = $1o
While $1b <= $1p
$1d = $7[$1b]
If $1d < $1q Then
$7[$1b] = $7[$1o]
$7[$1o] = $1d
$1o += 1
ElseIf $1d > $1r Then
While $7[$1p] > $1r
$1p -= 1
If $1p + 1 = $1b Then ExitLoop 2
WEnd
If $7[$1p] < $1q Then
$7[$1b] = $7[$1o]
$7[$1o] = $7[$1p]
$1o += 1
Else
$7[$1b] = $7[$1p]
EndIf
$7[$1p] = $1d
$1p -= 1
EndIf
$1b += 1
WEnd
$7[$17] = $7[$1o - 1]
$7[$1o - 1] = $1q
$7[$18] = $7[$1p + 1]
$7[$1p + 1] = $1r
_o($7, $17, $1o - 2, True)
_o($7, $1p + 2, $18, False)
If($1o < $1i) And($1m < $1p) Then
While $7[$1o] = $1q
$1o += 1
WEnd
While $7[$1p] = $1r
$1p -= 1
WEnd
$1b = $1o
While $1b <= $1p
$1d = $7[$1b]
If $1d = $1q Then
$7[$1b] = $7[$1o]
$7[$1o] = $1d
$1o += 1
ElseIf $1d = $1r Then
While $7[$1p] = $1r
$1p -= 1
If $1p + 1 = $1b Then ExitLoop 2
WEnd
If $7[$1p] = $1q Then
$7[$1b] = $7[$1o]
$7[$1o] = $1q
$1o += 1
Else
$7[$1b] = $7[$1p]
EndIf
$7[$1p] = $1d
$1p -= 1
EndIf
$1b += 1
WEnd
EndIf
_o($7, $1o, $1p, False)
Else
Local $0z = $7[$1k]
$1b = $1o
While $1b <= $1p
If $7[$1b] = $0z Then
$1b += 1
ContinueLoop
EndIf
$1d = $7[$1b]
If $1d < $0z Then
$7[$1b] = $7[$1o]
$7[$1o] = $1d
$1o += 1
Else
While $7[$1p] > $0z
$1p -= 1
WEnd
If $7[$1p] < $0z Then
$7[$1b] = $7[$1o]
$7[$1o] = $7[$1p]
$1o += 1
Else
$7[$1b] = $0z
EndIf
$7[$1p] = $1d
$1p -= 1
EndIf
$1b += 1
WEnd
_o($7, $17, $1o - 1, True)
_o($7, $1p + 1, $18, False)
EndIf
EndFunc
Global Const $1s = 0x1000 + 50
Global Const $1t = -753
Global Const $1u = $1t - 6
Global Enum $1v = 0, $1w, $1x, $1y
Func _14(Const $1z = @error, Const $20 = @extended)
Local $21 = DllCall("kernel32.dll", "dword", "GetLastError")
Return SetError($1z, $20, $21[0])
EndFunc
Func _17($22, $23, $24, $25, $26 = 0, $27 = 0)
Local $28 = DllCall("advapi32.dll", "bool", "AdjustTokenPrivileges", "handle", $22, "bool", $23, "struct*", $24, "dword", $25, "struct*", $26, "struct*", $27)
If @error Then Return SetError(@error, @extended, False)
Return Not($28[0] = 0)
EndFunc
Func _1d($29 = $1x)
Local $28 = DllCall("advapi32.dll", "bool", "ImpersonateSelf", "int", $29)
If @error Then Return SetError(@error, @extended, False)
Return Not($28[0] = 0)
EndFunc
Func _1h($2a, $2b)
Local $28 = DllCall("advapi32.dll", "bool", "LookupPrivilegeValueW", "wstr", $2a, "wstr", $2b, "int64*", 0)
If @error Or Not $28[0] Then Return SetError(@error, @extended, 0)
Return $28[3]
EndFunc
Func _1j($2c, $2d = 0, $2e = False)
If $2d = 0 Then
Local $21 = DllCall("kernel32.dll", "handle", "GetCurrentThread")
If @error Then Return SetError(@error + 10, @extended, 0)
$2d = $21[0]
EndIf
Local $28 = DllCall("advapi32.dll", "bool", "OpenThreadToken", "handle", $2d, "dword", $2c, "bool", $2e, "handle*", 0)
If @error Or Not $28[0] Then Return SetError(@error, @extended, 0)
Return $28[4]
EndFunc
Func _1k($2c, $2d = 0, $2e = False)
Local $22 = _1j($2c, $2d, $2e)
If $22 = 0 Then
Local Const $2f = 1008
If _14() <> $2f Then Return SetError(20, _14(), 0)
If Not _1d() Then Return SetError(@error + 10, _14(), 0)
$22 = _1j($2c, $2d, $2e)
If $22 = 0 Then Return SetError(@error, _14(), 0)
EndIf
Return $22
EndFunc
Func _1l($22, $2g, $2h)
Local $2i = _1h("", $2g)
If $2i = 0 Then Return SetError(@error + 10, @extended, False)
Local Const $2j = "dword Count;align 4;int64 LUID;dword Attributes"
Local $2k = DllStructCreate($2j)
Local $2l = DllStructGetSize($2k)
Local $26 = DllStructCreate($2j)
Local $2m = DllStructGetSize($26)
Local $2n = DllStructCreate("int Data")
DllStructSetData($2k, "Count", 1)
DllStructSetData($2k, "LUID", $2i)
If Not _17($22, False, $2k, $2l, $26, $2n) Then Return SetError(2, @error, False)
DllStructSetData($26, "Count", 1)
DllStructSetData($26, "LUID", $2i)
Local $2o = DllStructGetData($26, "Attributes")
If $2h Then
$2o = BitOR($2o, 0x00000002)
Else
$2o = BitAND($2o, BitNOT(0x00000002))
EndIf
DllStructSetData($26, "Attributes", $2o)
If Not _17($22, False, $26, $2m, $2k, $2n) Then Return SetError(3, @error, False)
Return True
EndFunc
Global Const $2p = "struct;long X;long Y;endstruct"
Global Const $2q = "struct;long Left;long Top;long Right;long Bottom;endstruct"
Global Const $2r = "struct;word Year;word Month;word Dow;word Day;word Hour;word Minute;word Second;word MSeconds;endstruct"
Global Const $2s = "struct;hwnd hWndFrom;uint_ptr IDFrom;INT Code;endstruct"
Global Const $2t = $2s & ";dword Flag;" & $2r
Global Const $2u = "uint Mask;int XY;ptr Text;handle hBMP;int TextMax;int Fmt;lparam Param;int Image;int Order;uint Type;ptr pFilter;uint State"
Global Const $2v = "struct;uint Mask;int Item;int SubItem;uint State;uint StateMask;ptr Text;int TextMax;int Image;lparam Param;" & "int Indent;int GroupID;uint Columns;ptr pColumns;ptr piColFmt;int iGroup;endstruct"
Global Const $2w = $2s & ";int Item;int SubItem;uint NewState;uint OldState;uint Changed;" & "struct;long ActionX;long ActionY;endstruct;lparam Param"
Global Const $2x = "dword Size;INT Mask;dword Style;uint YMax;handle hBack;dword ContextHelpID;ulong_ptr MenuData"
Global Const $2y = "uint Size;uint Mask;uint Type;uint State;uint ID;handle SubMenu;handle BmpChecked;handle BmpUnchecked;" & "ulong_ptr ItemData;ptr TypeData;uint CCH;handle BmpItem"
Global Const $2z = "uint cbSize;uint fMask;uint fStyle;dword clrFore;dword clrBack;ptr lpText;uint cch;" & "int iImage;hwnd hwndChild;uint cxMinChild;uint cyMinChild;uint cx;handle hbmBack;uint wID;uint cyChild;uint cyMaxChild;" & "uint cyIntegral;uint cxIdeal;lparam lParam;uint cxHeader" &((@OSVersion = "WIN_XP") ? "" : ";" & $2q & ";uint uChevronState")
Global Const $30 = "handle hProc;ulong_ptr Size;ptr Mem"
Func _1q(ByRef $31)
Local $32 = DllStructGetData($31, "Mem")
Local $33 = DllStructGetData($31, "hProc")
Local $34 = _23($33, $32, 0, 0x00008000)
DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $33)
If @error Then Return SetError(@error, @extended, False)
Return $34
EndFunc
Func _1w($35, $36, ByRef $31)
Local $21 = DllCall("user32.dll", "dword", "GetWindowThreadProcessId", "hwnd", $35, "dword*", 0)
If @error Then Return SetError(@error + 10, @extended, 0)
Local $37 = $21[2]
If $37 = 0 Then Return SetError(1, 0, 0)
Local $2c = BitOR(0x00000008, 0x00000010, 0x00000020)
Local $33 = _24($2c, False, $37, True)
Local $38 = BitOR(0x00002000, 0x00001000)
Local $32 = _21($33, 0, $36, $38, 0x00000004)
If $32 = 0 Then Return SetError(2, 0, 0)
$31 = DllStructCreate($30)
DllStructSetData($31, "hProc", $33)
DllStructSetData($31, "Size", $36)
DllStructSetData($31, "Mem", $32)
Return $32
EndFunc
Func _1y(ByRef $31, $39, $3a, $36)
Local $21 = DllCall("kernel32.dll", "bool", "ReadProcessMemory", "handle", DllStructGetData($31, "hProc"), "ptr", $39, "struct*", $3a, "ulong_ptr", $36, "ulong_ptr*", 0)
If @error Then Return SetError(@error, @extended, False)
Return $21[0]
EndFunc
Func _1z(ByRef $31, $39, $3a = 0, $36 = 0, $3b = "struct*")
If $3a = 0 Then $3a = DllStructGetData($31, "Mem")
If $36 = 0 Then $36 = DllStructGetData($31, "Size")
Local $21 = DllCall("kernel32.dll", "bool", "WriteProcessMemory", "handle", DllStructGetData($31, "hProc"), "ptr", $3a, $3b, $39, "ulong_ptr", $36, "ulong_ptr*", 0)
If @error Then Return SetError(@error, @extended, False)
Return $21[0]
EndFunc
Func _21($33, $3c, $36, $3d, $3e)
Local $21 = DllCall("kernel32.dll", "ptr", "VirtualAllocEx", "handle", $33, "ptr", $3c, "ulong_ptr", $36, "dword", $3d, "dword", $3e)
If @error Then Return SetError(@error, @extended, 0)
Return $21[0]
EndFunc
Func _23($33, $3c, $36, $3f)
Local $21 = DllCall("kernel32.dll", "bool", "VirtualFreeEx", "handle", $33, "ptr", $3c, "ulong_ptr", $36, "dword", $3f)
If @error Then Return SetError(@error, @extended, False)
Return $21[0]
EndFunc
Func _24($2c, $3g, $37, $3h = False)
Local $21 = DllCall("kernel32.dll", "handle", "OpenProcess", "dword", $2c, "bool", $3g, "dword", $37)
If @error Then Return SetError(@error + 10, @extended, 0)
If $21[0] Then Return $21[0]
If Not $3h Then Return 0
Local $22 = _1k(BitOR(0x00000020, 0x00000008))
If @error Then Return SetError(@error + 20, @extended, 0)
_1l($22, "SeDebugPrivilege", True)
Local $3i = @error
Local $3j = @extended
Local $3k = 0
If Not @error Then
$21 = DllCall("kernel32.dll", "handle", "OpenProcess", "dword", $2c, "bool", $3g, "dword", $37)
$3i = @error
$3j = @extended
If $21[0] Then $3k = $21[0]
_1l($22, "SeDebugPrivilege", False)
If @error Then
$3i = @error + 30
$3j = @extended
EndIf
Else
$3i = @error + 40
EndIf
DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $22)
Return SetError($3i, $3j, $3k)
EndFunc
Func _25($35, $3l, $3m = 0, $3n = 0, $3o = 0, $3p = "wparam", $3q = "lparam", $3r = "lresult")
Local $21 = DllCall("user32.dll", $3r, "SendMessageW", "hwnd", $35, "uint", $3l, $3p, $3m, $3q, $3n)
If @error Then Return SetError(@error, @extended, "")
If $3o >= 0 And $3o <= 4 Then Return $21[$3o]
Return $21
EndFunc
Global Const $3s = Ptr(-1)
Global Const $3t = Ptr(-1)
Global Const $3u = BitShift(0x0100, 8)
Global Const $3v = BitShift(0x2000, 8)
Global Const $3w = BitShift(0x8000, 8)
Global $3x[64][2] = [[0, 0]]
Func _49($35)
Local $21 = DllCall("user32.dll", "int", "GetDlgCtrlID", "hwnd", $35)
If @error Then Return SetError(@error, @extended, 0)
Return $21[0]
EndFunc
Func _4j($3y = False, $35 = 0)
Local $3z = Opt("MouseCoordMode", 1)
Local $40 = MouseGetPos()
Opt("MouseCoordMode", $3z)
Local $41 = DllStructCreate($2p)
DllStructSetData($41, "X", $40[0])
DllStructSetData($41, "Y", $40[1])
If $3y And Not _6k($35, $41) Then Return SetError(@error + 20, @extended, 0)
Return $41
EndFunc
Func _4k($3y = False, $35 = 0)
Local $41 = _4j($3y, $35)
If @error Then Return SetError(@error, @extended, 0)
Return DllStructGetData($41, "X")
EndFunc
Func _4l($3y = False, $35 = 0)
Local $41 = _4j($3y, $35)
If @error Then Return SetError(@error, @extended, 0)
Return DllStructGetData($41, "Y")
EndFunc
Func _4p($35)
Local $21 = DllCall("user32.dll", "hwnd", "GetParent", "hwnd", $35)
If @error Then Return SetError(@error, @extended, 0)
Return $21[0]
EndFunc
Func _58($35, ByRef $42)
Local $21 = DllCall("user32.dll", "dword", "GetWindowThreadProcessId", "hwnd", $35, "dword*", 0)
If @error Then Return SetError(@error, @extended, 0)
$42 = $21[2]
Return $21[0]
EndFunc
Func _5f($35, ByRef $43)
If $35 = $43 Then Return True
For $44 = $3x[0][0] To 1 Step -1
If $35 = $3x[$44][0] Then
If $3x[$44][1] Then
$43 = $35
Return True
Else
Return False
EndIf
EndIf
Next
Local $42
_58($35, $42)
Local $45 = $3x[0][0] + 1
If $45 >= 64 Then $45 = 1
$3x[0][0] = $45
$3x[$45][0] = $35
$3x[$45][1] =($42 = @AutoItPID)
Return $3x[$45][1]
EndFunc
Func _6k($35, ByRef $41)
Local $21 = DllCall("user32.dll", "bool", "ScreenToClient", "hwnd", $35, "struct*", $41)
If @error Then Return SetError(@error, @extended, False)
Return $21[0]
EndFunc
Global Const $46 = 0x007F
Global Const $47 = 'struct;dword OSVersionInfoSize;dword MajorVersion;dword MinorVersion;dword BuildNumber;dword PlatformId;wchar CSDVersion[128];endstruct'
Global Const $48 = _8u()
Func _8u()
Local $49 = DllStructCreate($47)
DllStructSetData($49, 1, DllStructGetSize($49))
Local $4a = DllCall('kernel32.dll', 'bool', 'GetVersionExW', 'struct*', $49)
If @error Or Not $4a[0] Then Return SetError(@error, @extended, 0)
Return BitOR(BitShift(DllStructGetData($49, 2), -8), DllStructGetData($49, 3))
EndFunc
Func _90($4b = 0, $4c = 0, $4d = 0, $4e = '')
If Not $4b Then $4b = 0x0400
Local $4f = 'wstr'
If Not StringStripWS($4e, 1 + 2) Then
$4f = 'ptr'
$4e = 0
EndIf
Local $4a = DllCall('kernel32.dll', 'int', 'GetDateFormatW', 'dword', $4b, 'dword', $4d, 'struct*', $4c, $4f, $4e, 'wstr', '', 'int', 2048)
If @error Or Not $4a[0] Then Return SetError(@error, @extended, '')
Return $4a[5]
EndFunc
Func _9n($4g, $r, $4h)
Local $4i[4]
Local $4j[4]
Local $4k
$4g = StringLeft($4g, 1)
If StringInStr("D,M,Y,w,h,n,s", $4g) = 0 Or $4g = "" Then
Return SetError(1, 0, 0)
EndIf
If Not StringIsInt($r) Then
Return SetError(2, 0, 0)
EndIf
If Not _9t($4h) Then
Return SetError(3, 0, 0)
EndIf
_a2($4h, $4j, $4i)
If $4g = "d" Or $4g = "w" Then
If $4g = "w" Then $r = $r * 7
$4k = _a5($4j[1], $4j[2], $4j[3]) + $r
_a7($4k, $4j[1], $4j[2], $4j[3])
EndIf
If $4g = "m" Then
$4j[2] = $4j[2] + $r
While $4j[2] > 12
$4j[2] = $4j[2] - 12
$4j[1] = $4j[1] + 1
WEnd
While $4j[2] < 1
$4j[2] = $4j[2] + 12
$4j[1] = $4j[1] - 1
WEnd
EndIf
If $4g = "y" Then
$4j[1] = $4j[1] + $r
EndIf
If $4g = "h" Or $4g = "n" Or $4g = "s" Then
Local $4l = _ai($4i[1], $4i[2], $4i[3]) / 1000
If $4g = "h" Then $4l = $4l + $r * 3600
If $4g = "n" Then $4l = $4l + $r * 60
If $4g = "s" Then $4l = $4l + $r
Local $4m = Int($4l /(24 * 60 * 60))
$4l = $4l - $4m * 24 * 60 * 60
If $4l < 0 Then
$4m = $4m - 1
$4l = $4l + 24 * 60 * 60
EndIf
$4k = _a5($4j[1], $4j[2], $4j[3]) + $4m
_a7($4k, $4j[1], $4j[2], $4j[3])
_ah($4l * 1000, $4i[1], $4i[2], $4i[3])
EndIf
Local $4n = _al($4j[1])
If $4n[$4j[2]] < $4j[3] Then $4j[3] = $4n[$4j[2]]
$4h = $4j[1] & '/' & StringRight("0" & $4j[2], 2) & '/' & StringRight("0" & $4j[3], 2)
If $4i[0] > 0 Then
If $4i[0] > 2 Then
$4h = $4h & " " & StringRight("0" & $4i[1], 2) & ':' & StringRight("0" & $4i[2], 2) & ':' & StringRight("0" & $4i[3], 2)
Else
$4h = $4h & " " & StringRight("0" & $4i[1], 2) & ':' & StringRight("0" & $4i[2], 2)
EndIf
EndIf
Return $4h
EndFunc
Func _9o($4o, $4p = Default)
Local Const $4q = 128
If $4p = Default Then $4p = 0
$4o = Int($4o)
If $4o < 1 Or $4o > 7 Then Return SetError(1, 0, "")
Local $4c = DllStructCreate($2r)
DllStructSetData($4c, "Year", BitAND($4p, $4q) ? 2007 : 2006)
DllStructSetData($4c, "Month", 1)
DllStructSetData($4c, "Day", $4o)
Return _90(BitAND($4p, 2) ? 0x0400 : $46, $4c, 0, BitAND($4p, 1) ? "ddd" : "dddd")
EndFunc
Func _9q($4g, $4r, $4s)
$4g = StringLeft($4g, 1)
If StringInStr("d,m,y,w,h,n,s", $4g) = 0 Or $4g = "" Then
Return SetError(1, 0, 0)
EndIf
If Not _9t($4r) Then
Return SetError(2, 0, 0)
EndIf
If Not _9t($4s) Then
Return SetError(3, 0, 0)
EndIf
Local $4t[4], $4u[4], $4v[4], $4w[4]
_a2($4r, $4t, $4u)
_a2($4s, $4v, $4w)
Local $4x = _a5($4v[1], $4v[2], $4v[3]) - _a5($4t[1], $4t[2], $4t[3])
Local $4y, $4z, $50, $51
If $4u[0] > 1 And $4w[0] > 1 Then
$50 = $4u[1] * 3600 + $4u[2] * 60 + $4u[3]
$51 = $4w[1] * 3600 + $4w[2] * 60 + $4w[3]
$4y = $51 - $50
If $4y < 0 Then
$4x = $4x - 1
$4y = $4y + 24 * 60 * 60
EndIf
Else
$4y = 0
EndIf
Select
Case $4g = "d"
Return $4x
Case $4g = "m"
$4z = $4v[1] - $4t[1]
Local $52 = $4v[2] - $4t[2] + $4z * 12
If $4v[3] < $4t[3] Then $52 = $52 - 1
$50 = $4u[1] * 3600 + $4u[2] * 60 + $4u[3]
$51 = $4w[1] * 3600 + $4w[2] * 60 + $4w[3]
$4y = $51 - $50
If $4v[3] = $4t[3] And $4y < 0 Then $52 = $52 - 1
Return $52
Case $4g = "y"
$4z = $4v[1] - $4t[1]
If $4v[2] < $4t[2] Then $4z = $4z - 1
If $4v[2] = $4t[2] And $4v[3] < $4t[3] Then $4z = $4z - 1
$50 = $4u[1] * 3600 + $4u[2] * 60 + $4u[3]
$51 = $4w[1] * 3600 + $4w[2] * 60 + $4w[3]
$4y = $51 - $50
If $4v[2] = $4t[2] And $4v[3] = $4t[3] And $4y < 0 Then $4z = $4z - 1
Return $4z
Case $4g = "w"
Return Int($4x / 7)
Case $4g = "h"
Return $4x * 24 + Int($4y / 3600)
Case $4g = "n"
Return $4x * 24 * 60 + Int($4y / 60)
Case $4g = "s"
Return $4x * 24 * 60 * 60 + $4y
EndSelect
EndFunc
Func _9r($53)
If StringIsInt($53) Then
Select
Case Mod($53, 4) = 0 And Mod($53, 100) <> 0
Return 1
Case Mod($53, 400) = 0
Return 1
Case Else
Return 0
EndSelect
EndIf
Return SetError(1, 0, 0)
EndFunc
Func _9t($4h)
Local $4j[4], $4i[4]
_a2($4h, $4j, $4i)
If Not StringIsInt($4j[1]) Then Return 0
If Not StringIsInt($4j[2]) Then Return 0
If Not StringIsInt($4j[3]) Then Return 0
$4j[1] = Int($4j[1])
$4j[2] = Int($4j[2])
$4j[3] = Int($4j[3])
Local $4n = _al($4j[1])
If $4j[1] < 1000 Or $4j[1] > 2999 Then Return 0
If $4j[2] < 1 Or $4j[2] > 12 Then Return 0
If $4j[3] < 1 Or $4j[3] > $4n[$4j[2]] Then Return 0
If $4i[0] < 1 Then Return 1
If $4i[0] < 2 Then Return 0
If $4i[0] = 2 Then $4i[3] = "00"
If Not StringIsInt($4i[1]) Then Return 0
If Not StringIsInt($4i[2]) Then Return 0
If Not StringIsInt($4i[3]) Then Return 0
$4i[1] = Int($4i[1])
$4i[2] = Int($4i[2])
$4i[3] = Int($4i[3])
If $4i[1] < 0 Or $4i[1] > 23 Then Return 0
If $4i[2] < 0 Or $4i[2] > 59 Then Return 0
If $4i[3] < 0 Or $4i[3] > 59 Then Return 0
Return 1
EndFunc
Func _a2($4h, ByRef $54, ByRef $55)
Local $56 = StringSplit($4h, " T")
If $56[0] > 0 Then $54 = StringSplit($56[1], "/-.")
If $56[0] > 1 Then
$55 = StringSplit($56[2], ":")
If UBound($55) < 4 Then ReDim $55[4]
Else
Dim $55[4]
EndIf
If UBound($54) < 4 Then ReDim $54[4]
For $57 = 1 To 3
If StringIsInt($54[$57]) Then
$54[$57] = Int($54[$57])
Else
$54[$57] = -1
EndIf
If StringIsInt($55[$57]) Then
$55[$57] = Int($55[$57])
Else
$55[$57] = 0
EndIf
Next
Return 1
EndFunc
Func _a5($53, $58, $59)
If Not _9t(StringFormat("%04d/%02d/%02d", $53, $58, $59)) Then
Return SetError(1, 0, "")
EndIf
If $58 < 3 Then
$58 = $58 + 12
$53 = $53 - 1
EndIf
Local $5a = Int($53 / 100)
Local $5b = Int($5a / 4)
Local $5c = 2 - $5a + $5b
Local $5d = Int(1461 *($53 + 4716) / 4)
Local $5e = Int(153 *($58 + 1) / 5)
Local $4k = $5c + $59 + $5d + $5e - 1524.5
Return $4k
EndFunc
Func _a7($4k, ByRef $53, ByRef $58, ByRef $59)
If $4k < 0 Or Not IsNumber($4k) Then
Return SetError(1, 0, 0)
EndIf
Local $5f = Int($4k + 0.5)
Local $5g = Int(($5f - 1867216.25) / 36524.25)
Local $5h = Int($5g / 4)
Local $5a = $5f + 1 + $5g - $5h
Local $5b = $5a + 1524
Local $5c = Int(($5b - 122.1) / 365.25)
Local $5i = Int(365.25 * $5c)
Local $5d = Int(($5b - $5i) / 30.6001)
Local $5e = Int(30.6001 * $5d)
$59 = $5b - $5i - $5e
If $5d - 1 < 13 Then
$58 = $5d - 1
Else
$58 = $5d - 13
EndIf
If $58 < 3 Then
$53 = $5c - 4715
Else
$53 = $5c - 4716
EndIf
$53 = StringFormat("%04d", $53)
$58 = StringFormat("%02d", $58)
$59 = StringFormat("%02d", $59)
Return $53 & "/" & $58 & "/" & $59
EndFunc
Func _ah($5j, ByRef $5k, ByRef $5l, ByRef $5m)
If Number($5j) > 0 Then
$5j = Int($5j / 1000)
$5k = Int($5j / 3600)
$5j = Mod($5j, 3600)
$5l = Int($5j / 60)
$5m = Mod($5j, 60)
Return 1
ElseIf Number($5j) = 0 Then
$5k = 0
$5j = 0
$5l = 0
$5m = 0
Return 1
Else
Return SetError(1, 0, 0)
EndIf
EndFunc
Func _ai($5k = @HOUR, $5l = @MIN, $5m = @SEC)
If StringIsInt($5k) And StringIsInt($5l) And StringIsInt($5m) Then
Local $5j = 1000 *((3600 * $5k) +(60 * $5l) + $5m)
Return $5j
Else
Return SetError(1, 0, 0)
EndIf
EndFunc
Func _al($53)
Local $5n = [12, 31,(_9r($53) ? 29 : 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
Return $5n
EndFunc
Func _c2($5o, ByRef $5p, ByRef $5q, ByRef $5r, ByRef $5s)
Local $7 = StringRegExp($5o, "^\h*((?:\\\\\?\\)*(\\\\[^\?\/\\]+|[A-Za-z]:)?(.*[\/\\]\h*)?((?:[^\.\/\\]|(?(?=\.[^\/\\]*\.)\.))*)?([^\/\\]*))$", 1)
If @error Then
ReDim $7[5]
$7[0] = $5o
EndIf
$5p = $7[1]
If StringLeft($7[2], 1) == "/" Then
$5q = StringRegExpReplace($7[2], "\h*[\/\\]+\h*", "\/")
Else
$5q = StringRegExpReplace($7[2], "\h*[\/\\]+\h*", "\\")
EndIf
$7[2] = $5q
$5r = $7[3]
$5s = $7[4]
Return $7
EndFunc
Global Const $5t = -3
Global Const $5u = -7
Global Const $5v = -8
Global Const $5w = -9
Global Const $5x = -10
Global Const $5y = -11
Global Const $5z = -1
Global Const $60 =(0x1000 + 9)
Global Const $61 =(0x1000 + 8)
Global Const $62 =(0x1000 + 31)
Global Const $63 =(0x1000 + 5)
Global Const $64 =(0x1000 + 75)
Global Const $65 =(0x1000 + 4)
Global Const $66 =(0x1000 + 44)
Global Const $67 =(0x1000 + 50)
Global Const $68 = 0x2000 + 6
Global Const $69 =(0x1000 + 30)
Global Const $6a =(0x1000 + 6)
Global Const $6b =(0x1000 + 76)
Global Const $6c =(0x1000 + 43)
Global Const $6d = -100
Global Const $6e =($6d - 1)
Global Const $6f =(0x1300 + 11)
Global Const $6g =(0x1300 + 12)
Global Const $6h = -550
Global Const $6i =($6h - 1)
Global Const $6j =($6h - 2)
Global Const $6k = 0x00C00000
Global Const $6l = 0x004E
Global Const $6m = 0x007B
Global Const $6n = 0 - 3
Func _cu($35)
If Not IsHWnd($35) Then $35 = GUICtrlGetHandle($35)
Return _25($35, 0x147)
EndFunc
Global Const $6o = 0x1200 + 3
Global Const $6p = 0x1200 + 11
Global Const $6q = 0x1200 + 0
Global Const $6r = 0x2000 + 6
Global Const $6s = 0x1200 + 4
Global Const $6t = 0x1200 + 12
Global $6u
Func _eo($35, $6v, ByRef $6w)
Local $6x = _f3($35)
Local $3k
If _5f($35, $6u) Then
$3k = _25($35, $6p, $6v, $6w, 0, "wparam", "struct*")
Else
Local $6y = DllStructGetSize($6w)
Local $31
Local $32 = _1w($35, $6y, $31)
_1z($31, $6w)
If $6x Then
$3k = _25($35, $6p, $6v, $32, 0, "wparam", "ptr")
Else
$3k = _25($35, $6o, $6v, $32, 0, "wparam", "ptr")
EndIf
_1y($31, $32, $6w, $6y)
_1q($31)
EndIf
Return $3k <> 0
EndFunc
Func _er($35)
Return _25($35, $6q)
EndFunc
Func _eu($35, $6v)
Local $6w = DllStructCreate($2u)
DllStructSetData($6w, "Mask", 0x00000004)
_eo($35, $6v, $6w)
Return DllStructGetData($6w, "Fmt")
EndFunc
Func _f3($35)
Return _25($35, $6r) <> 0
EndFunc
Func _fc($35, $6v, ByRef $6w)
Local $6x = _f3($35)
Local $3k
If _5f($35, $6u) Then
$3k = _25($35, $6t, $6v, $6w, 0, "wparam", "struct*")
Else
Local $6y = DllStructGetSize($6w)
Local $31
Local $32 = _1w($35, $6y, $31)
_1z($31, $6w)
If $6x Then
$3k = _25($35, $6t, $6v, $32, 0, "wparam", "ptr")
Else
$3k = _25($35, $6s, $6v, $32, 0, "wparam", "ptr")
EndIf
_1q($31)
EndIf
Return $3k <> 0
EndFunc
Func _fh($35, $6v, $4p)
Local $6w = DllStructCreate($2u)
DllStructSetData($6w, "Mask", 0x00000004)
DllStructSetData($6w, "Fmt", $4p)
Return _fc($35, $6v, $6w)
EndFunc
Global $6z
Func _g5($35)
If _hg($35) = 0 Then Return True
Local $70 = 0
If IsHWnd($35) Then
$70 = _49($35)
Else
$70 = $35
$35 = GUICtrlGetHandle($35)
EndIf
If $70 < 10000 Then
Local $71 = 0
For $6v = _hg($35) - 1 To 0 Step -1
$71 = _hp($35, $6v)
If GUICtrlGetState($71) > 0 And GUICtrlGetHandle($71) = 0 Then
GUICtrlDelete($71)
EndIf
Next
If _hg($35) = 0 Then Return True
EndIf
Return _25($35, $60) <> 0
EndFunc
Func _g8($35)
Local $72 = _hg($35)
If _ib($35) = $72 Then
Return _g5($35)
Else
Local $73 = _id($35, True)
If Not IsArray($73) Then Return SetError($5z, $5z, 0)
_k8($35, -1, False)
Local $70 = 0, $74, $75
If IsHWnd($35) Then
$70 = _49($35)
Else
$70 = $35
$35 = GUICtrlGetHandle($35)
EndIf
For $6v = $73[0] To 1 Step -1
If $70 < 10000 Then
Local $71 = _hp($35, $73[$6v])
If GUICtrlGetState($71) > 0 And GUICtrlGetHandle($71) = 0 Then
$74 = GUICtrlDelete($71)
If $74 Then ContinueLoop
EndIf
EndIf
$75 = _25($35, $61, $73[$6v])
If $74 + $75 = 0 Then
ExitLoop
EndIf
Next
Return Not $6v
EndIf
EndFunc
Func _h5($35)
If IsHWnd($35) Then
Return HWnd(_25($35, $62))
Else
Return HWnd(GUICtrlSendMsg($35, $62, 0, 0))
EndIf
EndFunc
Func _hg($35)
If IsHWnd($35) Then
Return _25($35, $65)
Else
Return GUICtrlSendMsg($35, $65, 0, 0)
EndIf
EndFunc
Func _hj($35, ByRef $6w)
Local $6x = _il($35)
Local $3k
If IsHWnd($35) Then
If _5f($35, $6z) Then
$3k = _25($35, $64, 0, $6w, 0, "wparam", "struct*")
Else
Local $6y = DllStructGetSize($6w)
Local $31
Local $32 = _1w($35, $6y, $31)
_1z($31, $6w)
If $6x Then
_25($35, $64, 0, $32, 0, "wparam", "ptr")
Else
_25($35, $63, 0, $32, 0, "wparam", "ptr")
EndIf
_1y($31, $32, $6w, $6y)
_1q($31)
EndIf
Else
Local $76 = DllStructGetPtr($6w)
If $6x Then
$3k = GUICtrlSendMsg($35, $64, 0, $76)
Else
$3k = GUICtrlSendMsg($35, $63, 0, $76)
EndIf
EndIf
Return $3k <> 0
EndFunc
Func _hp($35, $6v)
Local $6w = DllStructCreate($2v)
DllStructSetData($6w, "Mask", 0x00000004)
DllStructSetData($6w, "Item", $6v)
_hj($35, $6w)
Return DllStructGetData($6w, "Param")
EndFunc
Func _ib($35)
If IsHWnd($35) Then
Return _25($35, $67)
Else
Return GUICtrlSendMsg($35, $67, 0, 0)
EndIf
EndFunc
Func _id($35, $77 = False)
Local $78, $79[1] = [0]
Local $3k, $45 = _hg($35)
For $6y = 0 To $45
If IsHWnd($35) Then
$3k = _25($35, $66, $6y, 0x0002)
Else
$3k = GUICtrlSendMsg($35, $66, $6y, 0x0002)
EndIf
If $3k Then
If(Not $77) Then
If StringLen($78) Then
$78 &= "|" & $6y
Else
$78 = $6y
EndIf
Else
ReDim $79[UBound($79) + 1]
$79[0] = UBound($79) - 1
$79[UBound($79) - 1] = $6y
EndIf
EndIf
Next
If(Not $77) Then
Return String($78)
Else
Return $79
EndIf
EndFunc
Func _il($35)
If IsHWnd($35) Then
Return _25($35, $68) <> 0
Else
Return GUICtrlSendMsg($35, $68, 0, 0) <> 0
EndIf
EndFunc
Func _jv($35, $6v, $7a = True)
Local $6x = _il($35)
Local $32, $31, $3k
Local $6w = DllStructCreate($2v)
Local $76 = DllStructGetPtr($6w)
Local $6y = DllStructGetSize($6w)
If @error Then Return SetError($5z, $5z, $5z)
If $6v <> -1 Then
DllStructSetData($6w, "Mask", 0x00000008)
DllStructSetData($6w, "Item", $6v)
If($7a) Then
DllStructSetData($6w, "State", 0x2000)
Else
DllStructSetData($6w, "State", 0x1000)
EndIf
DllStructSetData($6w, "StateMask", 0xf000)
If IsHWnd($35) Then
If _5f($35, $6z) Then
Return _25($35, $6b, 0, $6w, 0, "wparam", "struct*") <> 0
Else
$32 = _1w($35, $6y, $31)
_1z($31, $6w)
If $6x Then
$3k = _25($35, $6b, 0, $32, 0, "wparam", "ptr")
Else
$3k = _25($35, $6a, 0, $32, 0, "wparam", "ptr")
EndIf
_1q($31)
Return $3k <> 0
EndIf
Else
If $6x Then
Return GUICtrlSendMsg($35, $6b, 0, $76) <> 0
Else
Return GUICtrlSendMsg($35, $6a, 0, $76) <> 0
EndIf
EndIf
Else
For $57 = 0 To _hg($35) - 1
DllStructSetData($6w, "Mask", 0x00000008)
DllStructSetData($6w, "Item", $57)
If($7a) Then
DllStructSetData($6w, "State", 0x2000)
Else
DllStructSetData($6w, "State", 0x1000)
EndIf
DllStructSetData($6w, "StateMask", 0xf000)
If IsHWnd($35) Then
If _5f($35, $6z) Then
If Not _25($35, $6b, 0, $6w, 0, "wparam", "struct*") <> 0 Then Return SetError($5z, $5z, $5z)
Else
$32 = _1w($35, $6y, $31)
_1z($31, $6w)
If $6x Then
$3k = _25($35, $6b, 0, $32, 0, "wparam", "ptr")
Else
$3k = _25($35, $6a, 0, $32, 0, "wparam", "ptr")
EndIf
_1q($31)
If Not $3k <> 0 Then Return SetError($5z, $5z, $5z)
EndIf
Else
If $6x Then
If Not GUICtrlSendMsg($35, $6b, 0, $76) <> 0 Then Return SetError($5z, $5z, $5z)
Else
If Not GUICtrlSendMsg($35, $6a, 0, $76) <> 0 Then Return SetError($5z, $5z, $5z)
EndIf
EndIf
Next
Return True
EndIf
Return False
EndFunc
Func _k8($35, $6v, $7b = True, $7c = False)
Local $7d = DllStructCreate($2v)
Local $3k, $7e = 0, $7f = 0, $36, $31, $32
If($7b = True) Then $7e = 0x0002
If($7c = True And $6v <> -1) Then $7f = 0x0001
DllStructSetData($7d, "Mask", 0x00000008)
DllStructSetData($7d, "Item", $6v)
DllStructSetData($7d, "State", BitOR($7e, $7f))
DllStructSetData($7d, "StateMask", BitOR(0x0002, $7f))
$36 = DllStructGetSize($7d)
If IsHWnd($35) Then
$32 = _1w($35, $36, $31)
_1z($31, $7d, $32, $36)
$3k = _25($35, $6c, $6v, $32)
_1q($31)
Else
$3k = GUICtrlSendMsg($35, $6c, $6v, DllStructGetPtr($7d))
EndIf
Return $3k <> 0
EndFunc
Global Const $7g = 0x004E
Func _ks($35, $6v)
Local $7h
If $35 = -1 Then $35 = GUICtrlGetHandle(-1)
If IsHWnd($35) Then
$7h = _49($35)
Else
$7h = $35
$35 = GUICtrlGetHandle($35)
EndIf
Local $7i = _4p($35)
If @error Then Return SetError(1, 0, -1)
Local $7j = DllStructCreate($2s)
DllStructSetData($7j, 1, $35)
DllStructSetData($7j, 2, $7h)
DllStructSetData($7j, 3, $6j)
_25($7i, $7g, $7h, $7j, 0, "wparam", "struct*")
Local $3k = _lm($35, $6v)
DllStructSetData($7j, 3, $6i)
_25($7i, $7g, $7h, $7j, 0, "wparam", "struct*")
Return $3k
EndFunc
Func _l1($35)
If IsHWnd($35) Then
Return _25($35, $6f)
Else
Return GUICtrlSendMsg($35, $6f, 0, 0)
EndIf
EndFunc
Func _lm($35, $6v)
If IsHWnd($35) Then
Return _25($35, $6g, $6v)
Else
Return GUICtrlSendMsg($35, $6g, $6v, 0)
EndIf
EndFunc
Func _m5($7k = 0x04000000)
Local $21 = DllCall("user32.dll", "handle", "CreatePopupMenu")
If @error Then Return SetError(@error, @extended, 0)
If $21[0] = 0 Then Return SetError(10, 0, 0)
_o2($21[0], $7k)
Return $21[0]
EndFunc
Func _m7($7l)
Local $21 = DllCall("user32.dll", "bool", "DestroyMenu", "handle", $7l)
If @error Then Return SetError(@error, @extended, False)
Return $21[0]
EndFunc
Func _n7($7l, $6v, $7m, $7n = 0, $7o = 0)
Local $7p = DllStructCreate($2y)
DllStructSetData($7p, "Size", DllStructGetSize($7p))
DllStructSetData($7p, "ID", $7n)
DllStructSetData($7p, "SubMenu", $7o)
If $7m = "" Then
DllStructSetData($7p, "Mask", 0x00000100)
DllStructSetData($7p, "Type", 0x00000800)
Else
DllStructSetData($7p, "Mask", BitOR(0x00000002, 0x00000040, 0x00000004))
DllStructSetData($7p, "Type", 0x0)
Local $7q = DllStructCreate("wchar Text[" & StringLen($7m) + 1 & "]")
DllStructSetData($7q, "Text", $7m)
DllStructSetData($7p, "TypeData", DllStructGetPtr($7q))
EndIf
Local $21 = DllCall("user32.dll", "bool", "InsertMenuItemW", "handle", $7l, "uint", $6v, "bool", True, "struct*", $7p)
If @error Then Return SetError(@error, @extended, False)
Return $21[0]
EndFunc
Func _o1($7l, ByRef $7r)
DllStructSetData($7r, "Size", DllStructGetSize($7r))
Local $21 = DllCall("user32.dll", "bool", "SetMenuInfo", "handle", $7l, "struct*", $7r)
If @error Then Return SetError(@error, @extended, False)
Return $21[0]
EndFunc
Func _o2($7l, $7k)
Local $7r = DllStructCreate($2x)
DllStructSetData($7r, "Mask", 0x00000010)
DllStructSetData($7r, "Style", $7k)
Return _o1($7l, $7r)
EndFunc
Func _o3($7l, $35, $7s = -1, $7t = -1, $7u = 1, $7v = 1, $7w = 0, $7x = 0)
If $7s = -1 Then $7s = _4k()
If $7t = -1 Then $7t = _4l()
Local $4d = 0
Switch $7u
Case 1
$4d = BitOR($4d, 0x0)
Case 2
$4d = BitOR($4d, 0x00000008)
Case Else
$4d = BitOR($4d, 0x00000004)
EndSwitch
Switch $7v
Case 1
$4d = BitOR($4d, 0x0)
Case 2
$4d = BitOR($4d, 0x00000010)
Case Else
$4d = BitOR($4d, 0x00000020)
EndSwitch
If BitAND($7w, 1) <> 0 Then $4d = BitOR($4d, 0x00000080)
If BitAND($7w, 2) <> 0 Then $4d = BitOR($4d, 0x00000100)
Switch $7x
Case 1
$4d = BitOR($4d, 0x00000002)
Case Else
$4d = BitOR($4d, 0x0)
EndSwitch
Local $21 = DllCall("user32.dll", "bool", "TrackPopupMenu", "handle", $7l, "uint", $4d, "int", $7s, "int", $7t, "int", 0, "hwnd", $35, "ptr", 0)
If @error Then Return SetError(@error, @extended, 0)
Return $21[0]
EndFunc
Global $7y = DllCallbackRegister("_ve", "dword", "long_ptr;ptr;long;ptr")
Global $7z = DllCallbackRegister("_vf", "dword", "long_ptr;ptr;long;ptr")
Global $80 = DllCallbackRegister("_vg", "dword", "long_ptr;ptr;long;ptr")
Global $81 = DllCallbackRegister("_vh", "dword", "long_ptr;ptr;long;ptr")
Global $82
Global $83 = DllOpen("OLE32.DLL")
Global $84 = DllCallbackRegister("_vq", "long", "ptr;dword;dword")
Global $85 = DllCallbackRegister("_vr", "long", "ptr")
Global $86 = DllCallbackRegister("_vs", "long", "ptr")
Global $87 = DllCallbackRegister("_w2", "long", "ptr;ptr")
Global $88 = DllCallbackRegister("_vt", "long", "ptr;dword;dword;dword")
Global $89 = DllCallbackRegister("_vu", "long", "ptr;long")
Global $8a = DllCallbackRegister("_vv", "long", "ptr;dword;ptr;long")
Global $8b = DllCallbackRegister("_vw", "long", "ptr;ptr")
Global $8c = DllCallbackRegister("_vx", "long", "ptr;ptr;dword;dword;dword;ptr")
Global $8d = DllCallbackRegister("_vy", "long", "ptr;long")
Global $8e = DllCallbackRegister("_vz", "long", "ptr;ptr;dword;ptr")
Global $8f = DllCallbackRegister("_w0", "long", "ptr;dword;dword;dword")
Global $8g = DllCallbackRegister("_w1", "long", "ptr;short;ptr;ptr;ptr")
Func _ve($8h, $8i, $8j, $8k)
Local $8l = DllStructCreate("long", $8k)
DllStructSetData($8l, 1, 0)
Local $8m = DllStructCreate("char[" & $8j & "]", $8i)
Local $8n = FileRead($8h, $8j - 1)
If @error Then Return 1
DllStructSetData($8m, 1, $8n)
DllStructSetData($8l, 1, StringLen($8n))
Return 0
EndFunc
Func _vf($8o, $8i, $8j, $8k)
#forceref $8o
Local $8l = DllStructCreate("long", $8k)
DllStructSetData($8l, 1, 0)
Local $8p = DllStructCreate("char[" & $8j & "]", $8i)
Local $8q = StringLeft($82, $8j - 1)
If $8q = "" Then Return 1
DllStructSetData($8p, 1, $8q)
Local $8r = StringLen($8q)
DllStructSetData($8l, 1, $8r)
$82 = StringMid($82, $8r + 1)
Return 0
EndFunc
Func _vg($8h, $8i, $8j, $8k)
Local $8l = DllStructCreate("long", $8k)
DllStructSetData($8l, 1, 0)
Local $8m = DllStructCreate("char[" & $8j & "]", $8i)
Local $8s = DllStructGetData($8m, 1)
FileWrite($8h, $8s)
DllStructSetData($8l, 1, StringLen($8s))
Return 0
EndFunc
Func _vh($8o, $8i, $8j, $8k)
#forceref $8o
Local $8l = DllStructCreate("long", $8k)
DllStructSetData($8l, 1, 0)
Local $8m = DllStructCreate("char[" & $8j & "]", $8i)
Local $8s = DllStructGetData($8m, 1)
$82 &= $8s
Return 0
EndFunc
Func _vq($8t, $8u, $8v)
#forceref $8t, $8u, $8v
Return 0
EndFunc
Func _vr($8t)
Local $8w = DllStructCreate("ptr;dword", $8t)
DllStructSetData($8w, 2, DllStructGetData($8w, 2) + 1)
Return DllStructGetData($8w, 2)
EndFunc
Func _vs($8t)
Local $8w = DllStructCreate("ptr;dword", $8t)
If DllStructGetData($8w, 2) > 0 Then
DllStructSetData($8w, 2, DllStructGetData($8w, 2) - 1)
Return DllStructGetData($8w, 2)
EndIf
EndFunc
Func _vt($8t, $8x, $8y, $8z)
#forceref $8t, $8x, $8y, $8z
Return 0x80004001
EndFunc
Func _vu($8t, $90)
#forceref $8t, $90
Return 0x80004001
EndFunc
Func _vv($8t, $91, $92, $93)
#forceref $8t, $91, $92, $93
Return 0
EndFunc
Func _vw($8t, $94)
#forceref $8t, $94
Return 0x80004001
EndFunc
Func _vx($8t, $95, $96, $97, $98, $99)
#forceref $8t, $95, $96, $97, $98, $99
Return 0
EndFunc
Func _vy($8t, $9a)
#forceref $8t, $9a
Return 0x80004001
EndFunc
Func _vz($8t, $9b, $97, $9c)
#forceref $8t, $9b, $97, $9c
Return 0x80004001
EndFunc
Func _w0($8t, $9d, $9e, $9f)
#forceref $8t, $9d, $9e, $9f
Return 0x80004001
EndFunc
Func _w1($8t, $9g, $94, $9b, $9h)
#forceref $8t, $9g, $94, $9b, $9h
Return 0x80004001
EndFunc
Func _w2($8t, $9i)
#forceref $8t
Local $9j = DllCall($83, "dword", "CreateILockBytesOnHGlobal", "hwnd", 0, "int", 1, "ptr*", 0)
Local $9k = $9j[3]
$9j = $9j[0]
If $9j Then Return $9j
$9j = DllCall($83, "dword", "StgCreateDocfileOnILockBytes", "ptr", $9k, "dword", BitOR(0x10, 2, 0x1000), "dword", 0, "ptr*", 0)
Local $92 = DllStructCreate("ptr", $9i)
DllStructSetData($92, 1, $9j[4])
$9j = $9j[0]
If $9j Then
Local $9l = DllStructCreate("ptr", $9k)
Local $9m = DllStructCreate("ptr[3]", DllStructGetData($9l, 1))
Local $9n = DllStructGetData($9m, 3)
DllCallAddress("long", $9n, "ptr", $9k)
EndIf
Return $9j
EndFunc
Func _x4($9o, $9p, $9q = 0)
If $9q = Default Then $9q = 0
If $9q > 0 Then
Local Const $9r = Chr(0)
$9o = StringReplace($9o, $9p, $9r, $9q)
$9p = $9r
ElseIf $9q < 0 Then
Local $6v = StringInStr($9o, $9p, 0, $9q)
If $6v Then
$9o = StringLeft($9o, $6v - 1)
EndIf
EndIf
Return StringSplit($9o, $9p, 1 + 2)
EndFunc
Global Const $9s = "Digital Signage - Zeitplan"
Global $9t = "DS-Schedule.dsbs"
Global $9u = ""
Local $9v = 226
Local $9w[$9v][4] = [ ["0004", "zh-CHS", "Chinese - Simplified"], ["0401", "ar-SA", "Arabic - Saudi Arabia"], ["0402", "bg-BG", "Bulgarian - Bulgaria"], ["0403", "ca-ES", "Catalan - Spain"], ["0404", "zh-TW", "Chinese (Traditional) - Taiwan"], ["0405", "cs-CZ", "Czech - Czech Republic"], ["0406", "da-DK", "Danish - Denmark"], ["0407", "de-DE", "Deutsch - Deutsch", "de-DE"], ["0408", "el-GR", "Greek - Greece"], ["0409", "en-US", "English - United States", "en-EN"], ["040A", "es-ES", "tradnl Spanish - Spain"], ["040B", "fi-FI", "Finnish - Finland"], ["040C", "fr-FR", "French - France"], ["040D", "he-IL", "Hebrew - Israel"], ["040E", "hu-HU", "Hungarian - Hungary"], ["040F", "is-IS", "Icelandic - Iceland"], ["0410", "it-IT", "Italian - Italy"], ["0411", "ja-JP", "Japanese - Japan"], ["0412", "ko-KR", "Korean - Korea"], ["0413", "nl-NL", "Dutch - Netherlands"], ["0414", "nb-NO", "Norwegian (Bokmål) - Norway"], ["0415", "pl-PL", "Polish - Poland"], ["0416", "pt-BR", "Portuguese - Brazil"], ["0417", "rm-CH", "Romansh - Switzerland"], ["0418", "ro-RO", "Romanian - Romania"], ["0419", "ru-RU", "Russian - Russia"], ["041A", "hr-HR", "Croatian - Croatia"], ["041B", "sk-SK", "Slovak - Slovakia"], ["041C", "sq-AL", "Albanian - Albania"], ["041D", "sv-SE", "Swedish - Sweden"], ["041E", "th-TH", "Thai - Thailand"], ["041F", "tr-TR", "Turkish - Turkey"], ["0420", "ur-PK", "Urdu - Pakistan"], ["0421", "id-ID", "Indonesian - Indonesia"], ["0422", "uk-UA", "Ukrainian - Ukraine"], ["0423", "be-BY", "Belarusian - Belarus"], ["0424", "sl-SI", "Slovenian - Slovenia"], ["0425", "et-EE", "Estonian - Estonia"], ["0426", "lv-LV", "Latvian - Latvia"], ["0427", "lt-LT", "Lithuanian - Lithuanian"], ["0428", "tg-Cyrl-TJ", "Tajik (Cyrillic) - Tajikistan"], ["0429", "fa-IR", "Persian - Iran"], ["042A", "vi-VN", "Vietnamese - Vietnam"], ["042B", "hy-AM", "Armenian - Armenia"], ["042C", "az-Latn-A", "Azeri (Latin) - Azerbaijan"], ["042D", "eu-ES", "Basque - Basque"], ["042E", "hsb-DE", "Upper Sorbian - Germany"], ["042F", "mk-MK", "Macedonian - Macedonia"], ["0432", "tn-ZA", "Setswana / Tswana - South Africa"], ["0434", "xh-ZA", "isiXhosa - South Africa"], ["0435", "zu-ZA", "isiZulu - South Africa"], ["0436", "af-ZA", "Afrikaans - South Africa"], ["0437", "ka-GE", "Georgian - Georgia"], ["0438", "fo-FO", "Faroese - Faroe Islands"], ["0439", "hi-IN", "Hindi - India"], ["043A", "mt-MT", "Maltese - Malta"], ["043B", "se-NO", "Sami (Northern) - Norway"], ["043e", "ms-MY", "Malay - Malaysia"], ["043F", "kk-KZ", "Kazakh - Kazakhstan"], ["0440", "ky-KG", "Kyrgyz - Kyrgyzstan"], ["0441", "sw-KE", "Swahili - Kenya"], ["0442", "tk-TM", "Turkmen - Turkmenistan"], ["0443", "uz-Latn-UZ", "Uzbek (Latin) - Uzbekistan"], ["0444", "tt-RU", "Tatar - Russia"], ["0445", "bn-IN", "Bangla - Bangladesh"], ["0446", "pa-IN", "Punjabi - India"], ["0447", "gu-IN", "Gujarati - India"], ["0448", "or-IN", "Oriya - India"], ["0449", "ta-IN", "Tamil - India"], ["044A", "te-IN", "Telugu - India"], ["044B", "kn-IN", "Kannada - India"], ["044C", "ml-IN", "Malayalam - India"], ["044D", "as-IN", "Assamese - India"], ["044E", "mr-IN", "Marathi - India"], ["044F", "sa-IN", "Sanskrit - India"], ["0450", "mn-MN", "Mongolian (Cyrillic) - Mongolia"], ["0451", "bo-CN", "Tibetan - China"], ["0452", "cy-GB", "Welsh - United Kingdom"], ["0453", "km-KH", "Khmer - Cambodia"], ["0454", "lo-LA", "Lao - Lao PDR"], ["0456", "gl-ES", "Galician - Spain"], ["0457", "kok-IN", "Konkani - India"], ["045A", "syr-SY", "Syriac - Syria"], ["045B", "si-LK", "Sinhala - Sri Lanka"], ["045C", "chr-Cher-US", "Cherokee - Cherokee"], ["045D", "iu-Cans-CA", "Inuktitut (Canadian_Syllabics) - Canada"], ["045E", "am-ET", "Amharic - Ethiopia"], ["0461", "ne-NP", "Nepali - Nepal"], ["0462", "fy-NL", "Frisian - Netherlands"], ["0463", "ps-AF", "Pashto - Afghanistan"], ["0464", "fil-PH", "Filipino - Philippines"], ["0465", "dv-MV", "Divehi - Maldives"], ["0468", "ha-Latn-NG", "Hausa - Nigeria"], _
["046A", "yo-NG", "Yoruba - Nigeria"], ["046B", "quz-BO", "Quechua - Bolivia"], ["046C", "nso-ZA", "Sesotho sa Leboa - South Africa"], ["046D", "ba-RU", "Bashkir - Russia"], ["046E", "lb-LU", "Luxembourgish - Luxembourg"], ["046F", "kl-GL", "Greenlandic - Greenland"], ["0470", "ig-NG", "Igbo - Nigeria"], ["0473", "ti-ET", "Tigrinya - Ethiopia"], ["0475", "haw-US", "Hawiian - United States"], ["0478", "ii-CN", "Yi - China"], ["047A", "arn-CL", "Mapudungun - Chile"], ["047C", "moh-CA", "Mohawk - Canada"], ["047E", "br-FR", "Breton - France"], ["0480", "ug-CN", "Uyghur - China"], ["0481", "mi-NZ", "Maori - New Zealand"], ["0482", "oc-FR", "Occitan - France"], ["0483", "co-FR", "Corsican - France"], ["0484", "gsw-FR", "Alsatian - France"], ["0485", "sah-RU", "Sakha - Russia"], ["0486", "qut-GT", "K'iche - Guatemala"], ["0487", "rw-RW", "Kinyarwanda - Rwanda"], ["0488", "wo-SN", "Wolof - Senegal"], ["048C", "prs-AF", "Dari - Afghanistan"], ["0491", "gd-GB", "Scottish Gaelic - United Kingdom"], ["0492", "ku-Arab-IQ", "Central Kurdish - Iraq"], ["0801", "ar-IQ", "Arabic - Iraq"], ["0803", "ca-ES-valencia", "Valencian - Valencia"], ["0804", "zh-CN", "Chinese (Simplified) - China"], ["0807", "de-CH", "German - Switzerland"], ["0809", "en-GB", "English - United Kingdom", "en-EN"], ["080A", "es-MX", "Spanish - Mexico"], ["080C", "fr-BE", "French - Belgium"], ["0810", "it-CH", "Italian - Switzerland"], ["0813", "nl-BE", "Dutch - Belgium"], ["0814", "nn-NO", "Norwegian (Nynorsk) - Norway"], ["0816", "pt-PT", "Portuguese - Portugal"], ["081A", "sr-Latn-CS", "Serbian (Latin) - Serbia and Montenegro"], ["081D", "sv-FI", "Swedish - Finland"], ["0820", "ur-IN", "Urdu - (reserved)"], ["082C", "az-Cyrl-AZ", "Azeri (Cyrillic) - Azerbaijan"], ["082E", "dsb-DE", "Lower Sorbian - Germany"], ["0832", "tn-BW", "Setswana / Tswana - Botswana"], ["083B", "se-SE", "Sami (Northern) - Sweden"], ["083C", "ga-IE", "Irish - Ireland"], ["083E", "ms-BN", "Malay - Brunei Darassalam"], ["0843", "uz-Cyrl-UZ", "Uzbek (Cyrillic) - Uzbekistan"], ["0845", "bn-BD", "Bangla - Bangladesh"], ["0846", "pa-Arab-PK", "Punjabi - Pakistan"], ["0849", "ta-LK", "Tamil - Sri Lanka"], ["0850", "mn-Mong-CN", "Mongolian (Mong) - Mongolia"], ["0859", "sd-Arab-PK", "Sindhi - Pakistan"], ["085D", "iu-Latn-CA", "Inuktitut (Latin) - Canada"], ["085F", "tzm-Latn-DZ", "Tamazight (Latin) - Algeria"], ["0867", "ff-Latn-SN", "Pular - Senegal"], ["086B", "quz-EC", "Quechua - Ecuador"], ["0873", "ti-ER", "Tigrinya - Eritrea"], ["0C01", "ar-EG", "Arabic - Egypt"], ["0C04", "zh-HK", "Chinese - Hong Kong SAR"], ["0C07", "de-AT", "German - Austria"], ["0C09", "en-AU", "English - Australia"], ["0C0A", "es-ES", "Spanish - Spain"], ["0C0C", "fr-CA", "French - Canada"], ["0C1A", "sr-Cyrl-CS", "Serbian (Cyrillic) - Serbia and Montenegro"], ["0C3B", "se-FI", "Sami (Northern) - Finland"], ["0C6B", "quz-PE", "Quechua - Peru"], ["1001", "ar-LY", "Arabic - Libya"], ["1004", "zh-SG", "Chinese - Singapore"], ["1007", "de-LU", "German - Luxembourg"], ["1009", "en-CA", "English - Canada"], ["100A", "es-GT", "Spanish - Guatemala"], ["100C", "fr-CH", "French - Switzerland"], ["101A", "hr-BA", "Croatian (Latin) - Bosnia and Herzegovina"], ["103B", "smj-NO", "Sami (Lule) - Norway"], ["105F", "tzm-Tfng-MA", "Central Atlas Tamazight (Tifinagh) - Morocco"], ["1401", "ar-DZ", "Arabic - Algeria"], ["1404", "zh-MO", "Chinese - Macao SAR"], ["1407", "de-LI", "German - Liechtenstein"], ["1409", "en-NZ", "English - New Zealand"], ["140A", "es-CR", "Spanish - Costa Rica"], ["140C", "fr-LU", "French - Luxembourg"], ["141A", "bs-Latn-BA", "Bosnian (Latin) - Bosnia and Herzegovina"], ["143B", "smj-SE", "Sami (Lule) - Sweden"], ["1801", "ar-MA", "Arabic - Morocco"], ["1809", "en-IE", "English - Ireland"], ["180A", "es-PA", "Spanish - Panama"], ["180C", "fr-MC", "French - Monaco"], ["181A", "sr-Latn-BA", "Serbian (Latin) - Bosnia and Herzegovina"], ["183B", "sma-NO", "Sami (Southern) - Norway"], ["1C01", "ar-TN", "Arabic - Tunisia"], _
["1c09", "en-ZA", "English - South Africa"], ["1C0A", "es-DO", "Spanish - Dominican Republic"], ["1C1A", "sr-Cyrl-BA", "Serbian (Cyrillic) - Bosnia and Herzegovina"], ["1C3B", "sma-SE", "Sami (Southern) - Sweden"], ["2001", "ar-OM", "Arabic - Oman"], ["2009", "en-JM", "English - Jamaica"], ["200A", "es-VE", "Spanish - Venezuela"], ["201A", "bs-Cyrl-BA", "Bosnian (Cyrillic) - Bosnia and Herzegovina"], ["203B", "sms-FI", "Sami (Skolt) - Finland"], ["2401", "ar-YE", "Arabic - Yemen"], ["2409", "en-029", "English - Caribbean"], ["240A", "es-CO", "Spanish - Colombia"], ["241A", "sr-Latn-RS", "Serbian (Latin) - Serbia"], ["243B", "smn-FI", "Sami (Inari) - Finland"], ["2801", "ar-SY", "Arabic - Syria"], ["2809", "en-BZ", "English - Belize"], ["280A", "es-PE", "Spanish - Peru"], ["281A", "sr-Cyrl-RS", "Serbian (Cyrillic) - Serbia"], ["2C01", "ar-JO", "Arabic - Jordan"], ["2C09", "en-TT", "English - Trinidad and Tobago"], ["2C0A", "es-AR", "Spanish - Argentina"], ["2C1A", "sr-Latn-ME", "Serbian (Latin) - Montenegro"], ["3001", "ar-LB", "Arabic - Lebanon"], ["3009", "en-ZW", "English - Zimbabwe"], ["300A", "es-EC", "Spanish - Ecuador"], ["301A", "sr-Cyrl-ME", "Serbian (Cyrillic) - Montenegro"], ["3401", "ar-KW", "Arabic - Kuwait"], ["3409", "en-PH", "English - Philippines"], ["340A", "es-CL", "Spanish - Chile"], ["3801", "ar-AE", "Arabic - U.A.E."], ["380A", "es-UY", "Spanish - Uruguay"], ["3C01", "ar-BH", "Arabic - Bahrain"], ["3C0A", "es-PY", "Spanish - Paraguay"], ["4001", "ar-QA", "Arabic - Qatar"], ["4009", "en-IN", "English - India"], ["400A", "es-BO", "Spanish - Bolivia"], ["4409", "en-MY", "English - Malaysia"], ["440A", "es-SV", "Spanish - El Salvador"], ["4809", "en-SG", "English - Singapore"], ["480A", "es-HN", "Spanish - Honduras"], ["4C0A", "es-NI", "Spanish - Nicaragua"], ["500A", "es-PR", "Spanish - Puerto Rico"], ["540A", "es-US", "Spanish - United States"], ["7C04", "zh-CHT", "Chinese - Traditional"]]
Opt("MustDeclareVars", 1)
Opt("TrayMenuMode", 1 + 2 + 4)
Opt("TrayIconHide", 1)
Opt("TrayAutoPause", 0)
Opt("WinTitleMatchMode", 2)
Global $9x = BitOR($6k, 0)
Global $9y = -1
Global $9z = 0x0001
Global $a0 = BitOR(0x00000200, 0x00000004, 0x00000010, 0x00000020)
Global Enum $a1 = 1000, $a2, $a3, $a4
Global $a5
Global $a6
Global $a7
Global $a8
Global $a9
Global $aa
Global $ab
Global $ac
Global $ad
Global Const $ae = "hwnd hWndFrom;uint Item;uint NewState;"
Global $af = 0xffffff01, $ag = 0xffffff02
Global $ah = "", $ai = ""
Global $aj = "", $ak = ""
Global $al[0][1 + 4]
Global $am[0][1 + 3]
Global $an[0][1 + 5]
Global $ao[0][1 + 3]
Global $ap
Global Enum $aq = 0, $ar, $as, $at
Global $au, $av, $aw, $ax
Global $ay, $az, $b0, $b1
Global $b2
Func _z1()
$a5 = GUICreate($9s, 552, 447, 341, 297, $9x, $9y)
$aa = GUICtrlCreateDummy()
$ab = GUICtrlCreateDummy()
$ac = GUICtrlCreateDummy()
GUIRegisterMsg($6l, "_zv")
GUIRegisterMsg(0x0111, "_zu")
GUIRegisterMsg($6m, "_zt")
$a6 = GUICtrlCreateButton("Info", 6, 415, 100, 25)
$a7 = GUICtrlCreateButton("OK", 232, 415, 100, 25)
$a8 = GUICtrlCreateButton("Abbrechen", 338, 415, 100, 25)
$a9 = GUICtrlCreateButton("Übernehmen", 444, 415, 100, 25)
GUICtrlCreateLabel("Zeitplan für die Anzeigetafeln", 7, 15, 418, 41)
GUICtrlSetFont(-1, 24, 400, 0, "MS Sans Serif")
$ap = GUICtrlCreateTab(7, 65, 540, 343)
GUICtrlCreateTabItem("Wochenplan")
GUICtrlCreateGroup("Beschreibung", 16, 324, 521, 73)
GUICtrlCreateLabel("Hier werden die Standard Layouts sowie deren Einschaltzeiten definiert.", 24, 340, 501, 17 * 2)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$au = GUICtrlCreateListView("Aktiv|Wochentag|Layout|Zeitraum", 16, 96, 521, 222, $9z, $a0)
$ay = GUICtrlGetHandle($au)
GUICtrlSendMsg(-1, $69, 1, 120)
GUICtrlSendMsg(-1, $69, 2, 160)
GUICtrlSendMsg(-1, $69, 3, 160)
GUICtrlCreateTabItem("Ausschaltzeiten")
GUICtrlCreateGroup("Beschreibung", 16, 324, 521, 73)
GUICtrlCreateLabel("Hier definiert man Zeiträume in denen die Anzeige nicht eingeschaltet werden soll. Beispielsweise Ferien an Schulen. Ausnahme: Veranstaltungen!", 24, 340, 501, 17 * 2)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$av = GUICtrlCreateListView("Aktiv|Zeitraum|Beschreibung", 16, 96, 521, 222, $9z, $a0)
$az = GUICtrlGetHandle($av)
GUICtrlSendMsg(-1, $69, 1, 160)
GUICtrlSendMsg(-1, $69, 2, 220)
GUICtrlCreateTabItem("Veranstaltungen")
GUICtrlCreateGroup("Beschreibung", 16, 324, 521, 73)
GUICtrlCreateLabel("Hier können Veranstaltungen definiert werden. Diese haben eine höhe Priorität als die Ausschaltzeiten sowie dem Wochenplan.", 24, 340, 501, 17 * 2)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$aw = GUICtrlCreateListView("Aktiv|Layout|Zeitraum|Beschreibung", 16, 96, 521, 222, $9z, $a0)
$b0 = GUICtrlGetHandle($aw)
GUICtrlSendMsg(-1, $69, 1, 140)
GUICtrlSendMsg(-1, $69, 2, 150)
GUICtrlSendMsg(-1, $69, 3, 160)
GUICtrlCreateTabItem("MAC Adressen")
GUICtrlCreateGroup("Beschreibung", 16, 324, 521, 73)
GUICtrlCreateLabel("Hier werden die MAC Adressen der Geräte eingetragen, welche über diesen Zeitplan gesteuert werden sollen.", 24, 340, 501, 17 * 2)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$ax = GUICtrlCreateListView("Aktiv|MAC Adresse|Beschreibung", 16, 96, 521, 222, $9z, $a0)
$b1 = GUICtrlGetHandle($ax)
GUICtrlSendMsg(-1, $69, 1, 120)
GUICtrlSendMsg(-1, $69, 2, 240)
GUICtrlCreateTabItem("")
GUISetState(@SW_SHOW)
EndFunc
Func _z2($59)
If $59 = 7 Then Return _9o(1, 2)
Return _9o($59 + 1, 2)
EndFunc
Func _z3($b3, $b4 = 1)
Local $4h = ""
If $b4 = 1 Then $4h = "2005/01/01 "
If($b3 = -1) Or(StringLen($b3) <> 4) Then Return $4h & "10:00"
Return $4h & StringLeft($b3, 2) & ":" & StringRight($b3, 2)
EndFunc
Func _z4($b5, $b6)
Local $b7 = StringLeft($b5, 2) & StringRight($b5, 2)
$b7 &= "-" & StringLeft($b6, 2) & StringRight($b6, 2)
Return $b7
EndFunc
Func _z5($b8)
Local $b7 = StringLeft($b8, 4) & StringMid($b8, 6, 2) & StringMid($b8, 9, 2)
Return $b7
EndFunc
Func _z6($b9)
If($b9 = -1) Or(StringLen($b9) <> 8) Then Return "2005/01/01"
Return StringLeft($b9, 4) & "/" & StringMid($b9, 5, 2) & "/" & StringRight($b9, 2)
EndFunc
Func _z7($b9, $b3)
Local $4h = _z6($b9)
Local $ba = _z3($b3, 0)
Return $4h & " " & $ba
EndFunc
Func _z8($b9)
If($b9 = -1) Or(StringLen($b9) <> 8) Then Return "01.01.2005"
Return StringRight($b9, 2) & "." & StringMid($b9, 5, 2) & "." & StringLeft($b9, 4)
EndFunc
Func _z9($b9, $bb)
Local $b7 = ""
$b7 &= StringRight($b9, 2) & "." & StringMid($b9, 5, 2) & "." & StringLeft($b9, 4)
$b7 &= ", " & StringLeft($bb, 2) & ":" & StringMid($bb, 3, 2)
$b7 &= " - " & StringMid($bb, 6, 2) & ":" & StringMid($bb, 8, 2)
Return $b7
EndFunc
Func _za($bc, ByRef $7, $bd, $be)
Local $h = 1
While 1
Local $bf = IniRead($bc, $bd, $h, "")
If $bf = "" Then ExitLoop
$h += 1
StringReplace($bf, "|", "x")
If Not($be = @extended) Then ContinueLoop
_0($7, $bf, 1)
WEnd
If UBound($7) = 0 Then
IniWriteSection($bc, $bd, "")
EndIf
EndFunc
Func _zb($bc)
Local $bg = ""
If Not FileExists($bc) Then
MsgBox(BitOR(0, 16), $9s, "Fehler bei öffnen der Datei " & $bc & "!")
Exit
EndIf
GUICtrlSetState($au, 32)
_za($bc, $al, "Weekplan", 3)
For $h = 0 To UBound($al) - 1
If Not(StringLen($al[$h][1]) = 1) Then ContinueLoop
If Not(StringLen($al[$h][2]) = 1) Then ContinueLoop
If Not(StringLen($al[$h][3]) = 9) Then ContinueLoop
If Not(StringLen($al[$h][4]) >= 1) Then ContinueLoop
If Not(Int($al[$h][2]) >= 1 And Int($al[$h][2] <= 7)) Then ContinueLoop
Local $bh = Int(StringMid($al[$h][3], 1, 4))
Local $bi = Int(StringMid($al[$h][3], 6, 4))
If Not($bh <= 2359) Then ContinueLoop
If Not($bi <= 2359) Then ContinueLoop
If Not($bh < $bi) Then ContinueLoop
$al[$h][0] = "0"
Next
$b2 = 0
$bg = ""
For $h = 0 To UBound($al) - 1
If Not($al[$h][0] = "") Then ContinueLoop
If Not($bg = "") Then $bg &= ";"
$bg &= $h
$b2 += 1
Next
_zc()
_za($bc, $am, "Offtimes", 2)
For $h = 0 To UBound($am) - 1
If Not(StringLen($am[$h][1]) = 1) Then ContinueLoop
If Not(StringLen($am[$h][2]) = 8 + 1 + 8) Then ContinueLoop
If Not(StringLen($am[$h][3]) >= 1) Then ContinueLoop
Local $bj = Int(@YEAR & @MON & @MDAY)
Local $bh = Int(StringMid($am[$h][2], 1, 8))
Local $bi = Int(StringMid($am[$h][2], 10, 8))
If Not($bh < $bi) Then ContinueLoop
If Not($bj < $bi) Then ContinueLoop
$am[$h][0] = GUICtrlCreateListViewItem("", $av)
Next
$bg = ""
For $h = 0 To UBound($am) - 1
If Not($am[$h][0] = "") Then ContinueLoop
If Not($bg = "") Then $bg &= ";"
$bg &= $h
$b2 += 1
Next
_zd()
_za($bc, $an, "Events", 4)
For $h = 0 To UBound($an) - 1
If Not(StringLen($an[$h][1]) = 1) Then ContinueLoop
If Not(StringLen($an[$h][2]) = 8) Then ContinueLoop
If Not(StringLen($an[$h][3]) = 9) Then ContinueLoop
If Not(StringLen($an[$h][4]) >= 1) Then ContinueLoop
If Not(StringLen($an[$h][5]) >= 1) Then ContinueLoop
Local $bj = Int(@YEAR & @MON & @MDAY)
Local $b8 = Int($an[$h][2])
If($bj > $b8) Then ContinueLoop
Local $bh = Int(StringMid($an[$h][3], 1, 4))
Local $bi = Int(StringMid($an[$h][3], 6, 4))
If($bh > 2359) Then ContinueLoop
If($bi > 2359) Then ContinueLoop
If($bh >= $bi) Then ContinueLoop
$an[$h][0] = GUICtrlCreateListViewItem("", $aw)
Next
_ze()
$bg = ""
For $h = 0 To UBound($an) - 1
If Not($an[$h][0] = "") Then ContinueLoop
If Not($bg = "") Then $bg &= ";"
$bg &= $h
$b2 += 1
Next
_za($bc, $ao, "Macs", 2)
For $h = 0 To UBound($ao) - 1
If Not(StringLen($ao[$h][1]) = 1) Then ContinueLoop
If Not(StringLen($ao[$h][2]) = 17) Then ContinueLoop
If Not(StringLen($ao[$h][3]) > 1) Then ContinueLoop
If Not(Hex(StringMid($ao[$h][2], 1, 2), 2) < 255) Then ContinueLoop
If Not(Hex(StringMid($ao[$h][2], 4, 2), 2) < 255) Then ContinueLoop
If Not(Hex(StringMid($ao[$h][2], 7, 2), 2) < 255) Then ContinueLoop
If Not(Hex(StringMid($ao[$h][2], 10, 2), 2) < 255) Then ContinueLoop
If Not(Hex(StringMid($ao[$h][2], 13, 2), 2) < 255) Then ContinueLoop
If Not(Hex(StringMid($ao[$h][2], 16, 2), 2) < 255) Then ContinueLoop
$ao[$h][0] = GUICtrlCreateListViewItem("", $ax)
Next
_zf()
$bg = ""
For $h = 0 To UBound($ao) - 1
If Not($ao[$h][0] = "") Then ContinueLoop
If Not($bg = "") Then $bg &= ";"
$bg &= $h
$b2 += 1
Next
GUICtrlSetState($au, 16)
EndFunc
Func _zc()
Local $bk = ""
For $h = 0 To UBound($al) - 1
Local $bl = ""
$bl &= "|" & _z2($al[$h][2])
$bl &= "|" & $al[$h][4]
$bl &= "|" & _z3(StringMid($al[$h][3], 1, 4), 0)
$bl &= " - " & _z3(StringMid($al[$h][3], 6, 4), 0)
If $al[$h][0] = "0" Then
$al[$h][0] = GUICtrlCreateListViewItem($bl, $au)
Else
GUICtrlSetData($al[$h][0], $bl)
EndIf
If GUICtrlGetState($al[$h][0]) = -1 Then
If Not $bk = "" Then $bk &= ";"
$bk &= $h
ContinueLoop
EndIf
If $al[$h][1] = "1" Then
_jv($au, $h, True)
Else
_jv($au, $h, False)
EndIf
Next
If Not $bk = "" Then _6($al, $bk)
GUICtrlSetState($a9, 64)
EndFunc
Func _zd()
Local $bk = ""
For $h = 0 To UBound($am) - 1
Local $bl = ""
Local $bm = StringMid($am[$h][2], 1, 8)
Local $bn = StringMid($am[$h][2], 10, 8)
$bl &= "|" & _z8($bm)
$bl &= " - " & _z8($bn)
$bl &= "|" & $am[$h][3]
If $am[$h][0] = "0" Then
$am[$h][0] = GUICtrlCreateListViewItem($bl, $av)
Else
GUICtrlSetData($am[$h][0], $bl)
EndIf
If GUICtrlGetState($am[$h][0]) = -1 Then
If Not $bk = "" Then $bk &= ";"
$bk &= $h
ContinueLoop
EndIf
If $am[$h][1] = "1" Then
_jv($av, $h, True)
Else
_jv($av, $h, False)
EndIf
Next
If Not $bk = "" Then _6($am, $bk)
GUICtrlSetState($a9, 64)
EndFunc
Func _ze()
Local $bk = ""
For $h = 0 To UBound($an) - 1
Local $bl = ""
$bl &= "|" & $an[$h][4]
$bl &= "|" & _z9($an[$h][2], $an[$h][3])
$bl &= "|" & $an[$h][5]
If $an[$h][0] = "0" Then
$an[$h][0] = GUICtrlCreateListViewItem($bl, $aw)
Else
GUICtrlSetData($an[$h][0], $bl)
EndIf
If GUICtrlGetState($an[$h][0]) = -1 Then
If Not $bk = "" Then $bk &= ";"
$bk &= $h
ContinueLoop
EndIf
If $an[$h][1] = "1" Then
_jv($aw, $h, True)
Else
_jv($aw, $h, False)
EndIf
Next
If Not $bk = "" Then _6($an, $bk)
GUICtrlSetState($a9, 64)
EndFunc
Func _zf()
Local $bk = ""
For $h = 0 To UBound($ao) - 1
Local $bl = ""
$bl &= "|" & $ao[$h][2]
$bl &= "|" & $ao[$h][3]
If $ao[$h][0] = "0" Then
$ao[$h][0] = GUICtrlCreateListViewItem($bl, $ax)
Else
GUICtrlSetData($ao[$h][0], $bl)
EndIf
If GUICtrlGetState($ao[$h][0]) = -1 Then
If Not $bk = "" Then $bk &= ";"
$bk &= $h
ContinueLoop
EndIf
If $ao[$h][1] = "1" Then
_jv($ax, $h, True)
Else
_jv($ax, $h, False)
EndIf
Next
If Not $bk = "" Then _6($ao, $bk)
GUICtrlSetState($a9, 64)
EndFunc
Func _zg(ByRef $bo, $bp)
Static $bq[4] = [0, 0, 0, 0]
Local $7, $br, $bs
Switch $bp
Case $aq
$7 = $al
$br = GUICtrlGetState($au)
Local $bt[4] = [1, 2, 4, 3]
$bs = _h5($au)
Case $ar
$7 = $am
$br = GUICtrlGetState($av)
Local $bt[3] = [1, 2, 3]
$bs = _h5($av)
Case $as
$7 = $an
$br = GUICtrlGetState($aw)
Local $bt[5] = [1, 4, 2, 5, 0]
$bs = _h5($aw)
Case $at
$7 = $ao
$br = GUICtrlGetState($ax)
Local $bt[3] = [1, 2, 3]
$bs = _h5($ax)
Case Default
Return
EndSwitch
_l($7, $bq[$bp], 0, 0, $bt[$br])
For $h = 0 To UBound($7) - 1
For $o = 1 To UBound($bt)
$bo[$h][$o] = $7[$h][$o]
Next
Next
$bq[$bp] = $bq[$bp] ? 0 : 1
For $h = 0 To _er($bs) - 1
Local $4p = _eu($bs, $h)
If BitAND($4p, 0x00000200) Then
_fh($bs, $h, BitXOR($4p, 0x00000200))
ElseIf BitAND($4p, 0x00000400) Then
_fh($bs, $h, BitXOR($4p, 0x00000400))
EndIf
Next
If $br > 0 Then
$4p = _eu($bs, $br)
If $bq[$bp] = 1 Then
_fh($bs, $br, BitOR($4p, 0x00000400))
Else
_fh($bs, $br, BitOR($4p, 0x00000200))
EndIf
EndIf
Switch $bp
Case $aq
_zc()
Case $ar
_zd()
Case $as
_ze()
Case $at
_zf()
EndSwitch
EndFunc
Func _zh($bc, $7, $bd, $bu)
Local $bv = _x4($bu, "|")
Local $bw = ""
If UBound($7) = 0 Then
IniWriteSection($bc, $bd, "")
Return
EndIf
For $h = 0 To UBound($7) - 1
For $o = 0 To UBound($bv) - 1
Local $bx = $7[$h][$bv[$o]]
If $o = 0 Then
$bw &= $h + 1 & "="
Else
$bw &= "|"
EndIf
$bw &= $bx
Next
$bw &= @LF
Next
Local $3i = IniWriteSection($bc, $bd, $bw)
If $3i = 0 Then
MsgBox(BitOR(0, 16), $9s, "Fehler bei speichern der Datei " & $bc & "!")
EndIf
EndFunc
Func _zi($bc)
_zh($bc, $al, "Weekplan", "1|2|3|4")
_zh($bc, $am, "Offtimes", "1|2|3")
_zh($bc, $an, "Events", "1|2|3|4|5")
_zh($bc, $ao, "Macs", "1|2|3")
If Not FileExists($bc) Then
MsgBox(BitOR(0, 16), $9s, "Fehler bei speichern der Datei " & $bc & "!")
Return
EndIf
GUICtrlSetState($a9, 128)
EndFunc
Func _zj()
Local $b7 = ""
Local $by = FileFindFirstFile("*.dsbd")
If $by = -1 Then Return ""
While 1
Local $bc = FileFindNextFile($by)
If @error Then ExitLoop
If StringLen($b7) Then $b7 &= "|"
$b7 &= StringTrimRight($bc, 5)
WEnd
FileClose($by)
Return $b7
EndFunc
Func _zk()
Local $bz = -1
Local $c0 = "Neuer Eintrag im Wochenplan"
If _ib($ay) = 1 Then
$c0 = "Wochenplan bearbeiten"
$bz = _id($ay, False)
EndIf
Local $c1 = GUICreate($c0, 305, 193, 130, 100, $9x, 0x00000040, $a5)
Local $c2, $c3, $c4, $c5
Local $c6 = _zj()
Local $c7 = ""
For $h = 1 To 7
$c7 &= _z2($h) & "|"
Next
Local $b5 = _z3($bz == -1 ? "" : StringLeft($al[$bz][3], 4))
Local $b6 = _z3($bz == -1 ? "" : StringRight($al[$bz][3], 4))
GUICtrlCreateGroup("", 8, 8, 289, 145)
GUICtrlCreateLabel("Wochentag:", 16, 24, 63, 17)
GUICtrlCreateLabel("Layout:", 16, 56, 39, 17)
GUICtrlCreateLabel("Von:", 16, 88, 26, 17)
GUICtrlCreateLabel("Bis:", 16, 120, 21, 17)
$c3 = GUICtrlCreateCombo("", 88, 24, 201, 25, BitOR(0x2, 0x40))
$c2 = GUICtrlCreateCombo("", 88, 56, 201, 25, BitOR(0x2, 0x40))
$c4 = GUICtrlCreateDate($b5, 87, 88, 202, 21, 9)
$c5 = GUICtrlCreateDate($b5, 87, 120, 202, 21, 9)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Local $c8 = GUICtrlCreateButton("OK", 6, 160, 100, 25, 0)
Local $c9 = GUICtrlCreateButton("Abbrechen", 113, 160, 100, 25)
GUICtrlSendMsg($c4, $1s, 0, "HH:mm")
GUICtrlSendMsg($c5, $1s, 0, "HH:mm")
GUICtrlSetData($c4, $b5)
GUICtrlSetData($c5, $b6)
GUICtrlSetData($c2, $c6, $bz == -1 ? "" : $al[$bz][4])
GUICtrlSetData($c3, $c7, $bz == -1 ? "" : _z2($al[$bz][2]))
GUISetState(@SW_DISABLE, $a5)
Local $ca[1][2] = [["{ENTER}", $c8]]
GUISetAccelerators($ca, $c1)
GUISetState(@SW_SHOW, $c1)
While 1
Local $3l = GUIGetMsg()
Switch $3l
Case $5t
ExitLoop
Case $c8
$b5 = GUICtrlRead($c4)
$b6 = GUICtrlRead($c5)
If $b5 >= $b6 Or Not StringLen(GUICtrlRead($c2)) Then
MsgBox(4096 + 64, $9s, "Bitte die Angaben überprüfen.")
ContinueLoop
EndIf
If $bz = -1 Then
Local $bf = "0|1"
$bf &= "|" & _cu($c3) + 1
$bf &= "|" & _z4(GUICtrlRead($c4), GUICtrlRead($c5))
$bf &= "|" & GUICtrlRead($c2)
_0($al, $bf)
Else
$al[$bz][1] = 1
$al[$bz][2] = _cu($c3) + 1
$al[$bz][3] = _z4(GUICtrlRead($c4), GUICtrlRead($c5))
$al[$bz][4] = GUICtrlRead($c2)
EndIf
_zc()
ExitLoop
Case $c9
ExitLoop
EndSwitch
WEnd
GUISetState(@SW_ENABLE, $a5)
GUIDelete($c1)
EndFunc
Func _zl()
Local $bz = -1
Local $c0 = "Neue Ausschaltzeit"
If _ib($az) = 1 Then
$c0 = "Ausschaltzeiten bearbeiten"
$bz = _id($az, False)
EndIf
Local $c1 = GUICreate($c0, 305, 185, 130, 100, $9x, 0x00000040, $a5)
Local $cb, $cc, $cd, $c8, $c9
$ah =($bz == -1 ? @YEAR & @MON & @MDAY : StringLeft($am[$bz][2], 8))
$ai =($bz == -1 ? @YEAR & @MON & @MDAY : StringRight($am[$bz][2], 8))
Local $ce = $bz == -1 ? "" : $am[$bz][3]
GUICtrlCreateGroup("", 8, 8, 289, 133)
GUICtrlCreateLabel("Beschreibung:", 16, 93, 72, 17)
GUICtrlCreateLabel("Von:", 16, 24, 26, 17)
GUICtrlCreateLabel("Bis:", 16, 56, 21, 17)
$cc = GUICtrlCreateDate("", 71, 24, 218, 21)
$cd = GUICtrlCreateDate("", 71, 56, 218, 21)
$cb = GUICtrlCreateInput("", 16, 112, 273, 21)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$c8 = GUICtrlCreateButton("OK", 6, 151, 100, 25, 0)
$c9 = GUICtrlCreateButton("Abbrechen", 113, 151, 100, 25)
GUICtrlSendMsg($cc, $1s, 0, "dddd, dd.MM.yyyy")
GUICtrlSendMsg($cd, $1s, 0, "dddd, dd.MM.yyyy")
GUICtrlSetData($cb, $bz == -1 ? "" : $ce)
GUICtrlSetData($cc, $bz == -1 ? "" : _z6($ah))
GUICtrlSetData($cd, $bz == -1 ? "" : _z6($ai))
$af = GUICtrlGetHandle($cc)
$ag = GUICtrlGetHandle($cd)
GUISetState(@SW_DISABLE, $a5)
Local $ca[1][2] = [["{ENTER}", $c8]]
GUISetAccelerators($ca, $c1)
GUISetState(@SW_SHOW, $c1)
While 1
Local $3l = GUIGetMsg()
Switch $3l
Case $5t
ExitLoop
Case $c8
$ce = GUICtrlRead($cb)
If Not StringLen($ce) Then
MsgBox(4096 + 64, $9s, "Bitte die Angaben überprüfen.")
ContinueLoop
EndIf
If $bz = -1 Then
Local $bf = "0|1"
$bf &= "|" & $ah & "-" & $ai
$bf &= "|" & $ce
_0($am, $bf)
Else
$am[$bz][1] = 1
$am[$bz][2] = $ah & "-" & $ai
$am[$bz][3] = $ce
EndIf
_zd()
ExitLoop
Case $c9
ExitLoop
EndSwitch
WEnd
GUISetState(@SW_ENABLE, $a5)
GUIDelete($c1)
EndFunc
Func _zm()
Local $bz = -1
Local $c0 = "Neue Veranstaltung"
If _ib($b0) = 1 Then
$c0 = "Veranstaltung bearbeiten"
$bz = _id($b0, False)
EndIf
Local $c1 = GUICreate($c0, 305, 208, 130, 100, $9x, 0x00000040, $a5)
Local $cb, $cc, $cd, $cf, $c8, $c9
Local $c6 = _zj()
Local $ce = $bz == -1 ? "" : $an[$bz][4]
Local $cg = $bz == -1 ? "" : $an[$bz][5]
$ah =($bz == -1 ? @YEAR & @MON & @MDAY : $an[$bz][2])
$ai =($bz == -1 ? @YEAR & @MON & @MDAY : $an[$bz][2])
$aj =($bz == -1 ? @HOUR & @MIN : StringLeft($an[$bz][3], 4))
$ak =($bz == -1 ? @HOUR & @MIN & @MDAY : StringRight($an[$bz][3], 4))
GUICtrlCreateGroup("", 8, 8, 289, 161)
GUICtrlCreateLabel("Layout:", 16, 24, 39, 17)
GUICtrlCreateLabel("Von:", 16, 56, 26, 17)
GUICtrlCreateLabel("Bis:", 16, 88, 21, 17)
GUICtrlCreateLabel("Beschreibung:", 16, 120, 72, 17)
$cf = GUICtrlCreateCombo("", 64, 24, 225, 25, BitOR(0x2, 0x40))
$cc = GUICtrlCreateDate("2016/08/08 15:15:41", 63, 56, 226, 21)
$cd = GUICtrlCreateDate("2016/08/08 15:15:47", 63, 88, 226, 21)
$cb = GUICtrlCreateInput("", 16, 139, 273, 21)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$c8 = GUICtrlCreateButton("OK", 6, 176, 100, 25, 0)
$c9 = GUICtrlCreateButton("Abbrechen", 113, 176, 100, 25)
GUICtrlSendMsg($cc, $1s, 0, "dddd, dd.MM.yyyy,    HH:mm")
GUICtrlSendMsg($cd, $1s, 0, "dddd, dd.MM.yyyy,    HH:mm")
GUICtrlSetData($cf, $c6, $bz == -1 ? "" : $an[$bz][4])
GUICtrlSetData($cb, $bz == -1 ? "" : $an[$bz][5])
GUICtrlSetData($cc, $bz == -1 ? "" : _z7($ah, $aj))
GUICtrlSetData($cd, $bz == -1 ? "" : _z7($ai, $ak))
$af = GUICtrlGetHandle($cc)
$ag = GUICtrlGetHandle($cd)
GUISetState(@SW_DISABLE, $a5)
Local $ca[1][2] = [["{ENTER}", $c8]]
GUISetAccelerators($ca, $c1)
GUISetState(@SW_SHOW, $c1)
While 1
Local $3l = GUIGetMsg()
Switch $3l
Case $5t
ExitLoop
Case $c8
Local $ce = GUICtrlRead($cb)
Local $cg = GUICtrlRead($cf)
Local $bj = Int(@YEAR & @MON & @MDAY)
Local $ch = _9q("D", _z7($ah, $aj), _z7($ai, $ak))
ConsoleWrite("$sTimeFrom=" & $aj & "$sTimeTo=" & $ak & @CRLF)
If(Not StringLen($ce)) Or(Not StringLen($cg)) Or($ch > 40) Or(Int($aj) >= Int($ak)) Or(Int($ah) > Int($ai)) Or($bj > Int($ah)) Then
MsgBox(4096 + 64, $9s, "Bitte die Angaben überprüfen.")
ContinueLoop
EndIf
If $bz = -1 Then
Local $bf = "0|1"
$bf &= "|" & $ah
$bf &= "|" & $aj & "-" & $ak
$bf &= "|" & $cg
$bf &= "|" & $ce
_0($an, $bf)
Else
$an[$bz][1] = 1
$an[$bz][2] = $ah
$an[$bz][3] = $aj & "-" & $ak
$an[$bz][4] = $cg
$an[$bz][5] = $ce
EndIf
If $ah <> $ai Then
Local $ci = _9n("d", 1, _z6($ah))
Local $cj = _z6($ai)
For $h = 0 To 40
Local $ck = _9n("d", $h, $ci)
Local $bf = "0|1"
$bf &= "|" & _z5($ck)
$bf &= "|" & $aj & "-" & $ak
$bf &= "|" & $cg
$bf &= "|" & $ce & " (" & $h + 2 & ")"
_0($an, $bf)
If $cj = $ck Then ExitLoop
Next
EndIf
_ze()
ExitLoop
Case $c9
ExitLoop
EndSwitch
WEnd
GUISetState(@SW_ENABLE, $a5)
GUIDelete($c1)
EndFunc
Func _zn()
Local $bz = -1
Local $c0 = "Neue MAC Adresse"
If _ib($b1) = 1 Then
$c0 = "MAC Adresse bearbeiten"
$bz = _id($b1, False)
EndIf
Local $c1 = GUICreate($c0, 305, 168, 130, 100, $9x, 0x00000040, $a5)
Local $cl, $cb, $c8, $c9
GUICtrlCreateGroup("", 8, 8, 233, 121)
GUICtrlCreateLabel("MAC Adresse:", 16, 24, 71, 17)
GUICtrlCreateLabel("Beschreibung:", 16, 77, 72, 17)
$cl = GUICtrlCreateInput("", 16, 44, 217, 21)
$cb = GUICtrlCreateInput("", 16, 96, 217, 21)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$c8 = GUICtrlCreateButton("OK", 6, 135, 100, 25, 0)
$c9 = GUICtrlCreateButton("Abbrechen", 113, 135, 100, 25)
GUICtrlSetTip($cl, "MAC Adresse wie zum Beispiel 11:22:33:44:55:66 eingeben.")
GUICtrlSetData($cl, $bz == -1 ? "" : $ao[$bz][2])
GUICtrlSetData($cb, $bz == -1 ? "" : $ao[$bz][3])
GUISetState(@SW_DISABLE, $a5)
Local $ca[1][2] = [["{ENTER}", $c8]]
GUISetAccelerators($ca, $c1)
GUISetState(@SW_SHOW, $c1)
While 1
Local $3l = GUIGetMsg()
Switch $3l
Case $5t
ExitLoop
Case $c8
Local $cm = GUICtrlRead($cl)
Local $ce = GUICtrlRead($cb)
If((StringLen($cm) <> 17) Or(StringLen($ce) < 2)) Then
MsgBox(4096 + 64, $9s, "Bitte die Angaben überprüfen.")
ContinueLoop
EndIf
If $bz = -1 Then
Local $bf = ""
$bf &= "0|1|" & $cm
$bf &= "|" & $ce
_0($ao, $bf)
Else
$ao[$bz][1] = 1
$ao[$bz][2] = $cm
$ao[$bz][3] = $ce
EndIf
_zf()
ExitLoop
Case $c9
ExitLoop
EndSwitch
WEnd
GUISetState(@SW_ENABLE, $a5)
GUIDelete($c1)
EndFunc
Func _zo()
MsgBox(4096 + 16, $9s, "Diese Datei entspricht nicht dem iCalender Format!")
EndFunc
Func _zp(ByRef $7, $cn, $co, $cp, $cq)
$ah = $cn
If StringLen($co) = 8 Then
$ai = $co
Else
$ai = $ah
EndIf
If $cq = 0 Then
Local $bf = "0|1"
$bf &= "|" & $ah & "-" & $ai
$bf &= "|" & $cp
_0($7, $bf)
Return
EndIf
Local $bj = Int(@YEAR & @MON & @MDAY)
Local $cr = @YEAR & StringRight($ah, 4)
Local $cs = @YEAR & StringRight($ai, 4)
If(Int($cs) < Int($cr)) Then $cs = @YEAR + 1 & StringRight($ai, 4)
For $53 = 0 To 2
$ah = _z5(_9n("Y", $53, _z6($cr)))
$ai = _z5(_9n("Y", $53, _z6($cs)))
Local $bf = "0|1"
$bf &= "|" & $ah & "-" & $ai
$bf &= "|" & $cp
_0($7, $bf)
Next
EndFunc
Func _zq($7, $cn, $co, $cp, $cq)
EndFunc
Func _zr(ByRef $7, $bp)
Local $bc = FileOpenDialog($9s & " - Kalander öffnen", "", "iCalender Format (*.ics)", 1)
If @error Then Return
Local $8h = FileOpen($bc, BitOR(0, 16384))
Local $ct, $cn, $co, $cp, $cq
Local $cu, $cv
$ct = FileReadLine($8h, 1)
If $ct <> "BEGIN:VCALENDAR" Then Return _zo()
$ct = FileReadLine($8h, 2)
If $ct <> "VERSION:2.0" Then Return _zo()
Local $3i, $cw = 3
Do
Local $ct = FileReadLine($8h, $cw)
$3i = @error
$cw += 1
If $ct = "BEGIN:VEVENT" Then
$cn = ""
$co = ""
$cp = ""
$cu = ""
$cv = ""
$cq = 0
ContinueLoop
EndIf
If StringLeft($ct, 19) = "DTSTART;VALUE=DATE:" Then
$cn = StringMid($ct, 20)
ContinueLoop
EndIf
If StringLeft($ct, 8) = "DTSTART:" Then
$cn = StringMid($ct, 9)
$cu = StringMid($ct, 18, 6)
ContinueLoop
EndIf
If StringLeft($ct, 17) = "DTEND;VALUE=DATE:" Then
$co = StringMid($ct, 18)
ContinueLoop
EndIf
If StringLeft($ct, 6) = "DTEND:" Then
$co = StringMid($ct, 7)
$cv = StringMid($ct, 16, 6)
ContinueLoop
EndIf
If StringLeft($ct, 8) = "SUMMARY:" Then
$cp = StringMid($ct, 9)
ContinueLoop
EndIf
If $ct = "RRULE:FREQ=YEARLY;INTERVAL=1" Then
$cq = 1
ContinueLoop
EndIf
If $ct = "END:VEVENT" Then
If StringLen($cn) = 0 Then ContinueLoop
If StringLen($cp) = 0 Then ContinueLoop
Switch $bp
Case $ar
_zp($7, $cn, $co, $cp, $cq)
Case $as
_zq($7, $cn, $co, $cp, $cq)
EndSwitch
EndIf
Until $3i <> 0
FileClose($8h)
Switch $bp
Case $ar
_zd()
Case $as
_ze()
EndSwitch
EndFunc
Func _zs($cx)
Switch $cx
Case 0
_ks($ap, 0)
ControlFocus("", "", $ay)
Case 1
_ks($ap, 1)
ControlFocus("", "", $az)
Case 2
_ks($ap, 2)
ControlFocus("", "", $b0)
Case 3
_ks($ap, 3)
ControlFocus("", "", $b1)
EndSwitch
EndFunc
Func _zt($35, $3l, $3m, $3n)
#forceref $35, $3l, $3m, $3n
If $3m = $ay Or $3m = $az Or $3m = $b0 Or $3m = $b1 Then
Local $7l = _m5()
_n7($7l, 0, "Hinzufügen", $a1)
If _ib($3m) = 1 Then _n7($7l, 1, "Bearbeiten", $a2)
If _ib($3m) >= 1 Then _n7($7l, 2, "Löschen", $a3)
If $3m = $az Then
_n7($7l, 3, "")
_n7($7l, 4, "Importieren", $a4)
EndIf
GUICtrlSendToDummy($aa, $3m)
_o3($7l, $a5)
_m7($7l)
EndIf
Return 'GUI_RUNDEFMSG'
EndFunc
Func _zu($35, $3l, $3m, $3n)
#forceref $35, $3l, $3m, $3n
If $3l = 273 Then
Local $7l = HWnd(GUICtrlRead($aa))
GUICtrlSendToDummy($aa, 0)
If $7l = $ay Then
Switch $3m
Case $a1
_k8($7l, -1, False)
_zk()
Case $a2
_zk()
Case $a3
_g8($7l)
_zc()
EndSwitch
ElseIf $7l = $az Then
Switch $3m
Case $a1
_k8($7l, -1, False)
_zl()
Case $a2
_zl()
Case $a3
_g8($7l)
_zd()
Case $a4
_zr($am, $ar)
EndSwitch
ElseIf $7l = $b0 Then
Switch $3m
Case $a1
_k8($7l, -1, False)
_zm()
Case $a2
_zm()
Case $a3
_g8($7l)
_ze()
Case $a4
_zr($an, $as)
EndSwitch
ElseIf $7l = $b1 Then
Switch $3m
Case $a1
_k8($7l, -1, False)
_zn()
Case $a2
_zn()
Case $a3
_g8($7l)
_zf()
EndSwitch
EndIf
EndIf
Return 'GUI_RUNDEFMSG'
EndFunc
Func _zv($35, $3l, $3m, $3n)
#forceref $35, $3l, $3m, $3n
Local $7j = DllStructCreate($2s, $3n)
Local $cy = HWnd(DllStructGetData($7j, "hWndFrom"))
Local $cz = DllStructGetData($7j, "Code")
If $cz = $6e Then
Local $7r = DllStructCreate($2w, $3n)
Local $6y = DllStructGetData($7r, "Item")
Local $d0 = DllStructGetData($7r, "NewState")
Local $8w = DllStructCreate($ae)
DllStructSetData($8w, 'hWndFrom', $cy)
DllStructSetData($8w, 'Item', $6y)
DllStructSetData($8w, 'NewState', $d0)
$ad = $8w
GUICtrlSendToDummy($ac)
Return 'GUI_RUNDEFMSG'
EndIf
If $cy = $ay Or $cy = $az Or $cy = $b0 Or $cy = $b1 Then
If $cz = $6n Then GUICtrlSendToDummy($ab, $cy)
EndIf
Switch $cy
Case $af
Switch $cz
Case $1u
Local $7r = DllStructCreate($2t, $3n)
$ah = StringFormat("%02d", DllStructGetData($7r, "Year"))
$ah &= StringFormat("%02d", DllStructGetData($7r, "Month"))
$ah &= StringFormat("%02d", DllStructGetData($7r, "Day"))
$aj = StringFormat("%02d", DllStructGetData($7r, "Hour"))
$aj &= StringFormat("%02d", DllStructGetData($7r, "Minute"))
EndSwitch
Case $ag
Switch $cz
Case $1u
Local $7r = DllStructCreate($2t, $3n)
$ai = StringFormat("%02d", DllStructGetData($7r, "Year"))
$ai &= StringFormat("%02d", DllStructGetData($7r, "Month"))
$ai &= StringFormat("%02d", DllStructGetData($7r, "Day"))
$ak = StringFormat("%02d", DllStructGetData($7r, "Hour"))
$ak &= StringFormat("%02d", DllStructGetData($7r, "Minute"))
EndSwitch
EndSwitch
Return 'GUI_RUNDEFMSG'
EndFunc
If $CmdLine[0] = 1 Then
$9t = $CmdLine[1]
Local $5p, $5q, $bc, $5s
_c2($9t, $5p, $5q, $bc, $5s)
$9u = $5p & $5q
EndIf
If Not FileExists($9t) Then
Local $3i = FileWrite($9t, "# DSBS Schedule Version 1.0" & @CRLF)
If $3i <> 1 Then
MsgBox(4096 + 16, $9s, "Kann Zeitplan '" & $9t & "' nicht öffnen!")
Exit
EndIf
EndIf
_z1()
_zb($9t)
Local $d1 = GUICtrlCreateDummy()
Local $d2 = GUICtrlCreateDummy()
Local $d3 = GUICtrlCreateDummy()
Local $d4 = GUICtrlCreateDummy()
Local $d5 = GUICtrlCreateDummy()
Local $d6 = GUICtrlCreateDummy()
Local $d7 = GUICtrlCreateDummy()
Local $d8 = GUICtrlCreateDummy()
Local $ca[9][2] = [ ["{F2}", $d7], ["{DEL}", $d8], ["{i}", $a6], ["^{PGDN}", $d5], ["^{PGUP}", $d6], ["^1", $d1], ["^2", $d2], ["^3", $d3], ["^4", $d4]]
GUISetAccelerators($ca, $a5)
While 1
Local $3l = GUIGetMsg()
If $3l = 0 Then ExitLoop
WEnd
If $b2 > 0 Then
MsgBox(BitOR(0, 64), $9s, "Einige Einträge waren ungültig!")
GUICtrlSetState($a9, 64)
Else
GUICtrlSetState($a9, 128)
EndIf
While 1
Local $3l = GUIGetMsg()
If $3l = 0 Then ContinueLoop
If $3l = $5y Then ContinueLoop
If $3l = $5v Then ContinueLoop
If $3l = $5u Then ContinueLoop
If $3l = $5x Then ContinueLoop
If $3l = $5w Then ContinueLoop
Switch $3l
Case $a6
Local $7m = ""
$7m &= "Copyright Tino Reichardt" & @CRLF & @CRLF
$7m &= "Version: " & "0.1" & " (" & FileGetVersion(@ScriptFullPath) & ") " & @CRLF
MsgBox(BitOR(0, 64), $9s, $7m)
Case $a9
_zi($9t)
Case $a7
_zi($9t)
Exit
Case $a8, $5t
Exit
Case $d8
Local $8w = $ad
Local $cy = DllStructGetData($8w, "hWndFrom")
If _ib($cy) > 1 Then
Local $d9 = "Einträge löschen?"
Else
Local $d9 = "Eintrag löschen?"
EndIf
If MsgBox(4, $9s, $d9) = 6 Then
_g8($cy)
Switch $cy
Case $ay
_zc()
Case $az
_zd()
Case $b0
_ze()
Case $b1
_zf()
EndSwitch
EndIf
Case $d7, $ab
If $3l = $ab Then
Local $cy = GUICtrlRead($ab)
Else
Local $8w = $ad
Local $cy = DllStructGetData($8w, "hWndFrom")
EndIf
Switch $cy
Case $ay
_zk()
Case $az
_zl()
Case $b0
_zm()
Case $b1
_zn()
EndSwitch
Case $d1
_zs(0)
Case $d2
_zs(1)
Case $d3
_zs(2)
Case $d4
_zs(3)
Case $d5
Local $da = _l1($ap)
If $da = 3 Then
$da = 0
Else
$da += 1
EndIf
_zs($da)
Case $d6
Local $da = _l1($ap)
If $da = 0 Then
$da = 3
Else
$da -= 1
EndIf
_zs($da)
Case $ac
Local $8w = $ad
Local $d0 = DllStructGetData($8w, "NewState")
If Not(($d0 = 4096) Or($d0 = 8192)) Then ContinueLoop
Local $cy = DllStructGetData($8w, "hWndFrom")
Local $6y = DllStructGetData($8w, "Item")
Switch $cy
Case $ay
If $d0 = 4096 Then $al[$6y][1] = "0"
If $d0 = 8192 Then $al[$6y][1] = "1"
Case $az
If $d0 = 4096 Then $am[$6y][1] = "0"
If $d0 = 8192 Then $am[$6y][1] = "1"
Case $b0
If $d0 = 4096 Then $an[$6y][1] = "0"
If $d0 = 8192 Then $an[$6y][1] = "1"
Case $b1
If $d0 = 4096 Then $ao[$6y][1] = "0"
If $d0 = 8192 Then $ao[$6y][1] = "1"
EndSwitch
GUICtrlSetState($a9, 64)
Case $au
_zg($al, $aq)
Case $av
_zg($am, $ar)
Case $aw
_zg($an, $as)
Case $ax
_zg($ao, $at)
EndSwitch
WEnd
