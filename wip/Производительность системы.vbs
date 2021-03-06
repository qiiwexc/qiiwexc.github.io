' Coded by: Ratiborus
' WSHShell.Run "winsat formal -restart clean",0, True 
' winsat formal — оценка общей производительности системы; 
' winsat formal -v — оценка общей производительности системы, подробный вывод; 
' winsat formal -xml file.xml -  вывод результата проверки в указанный xml-файл; 
' winsat formal -restart never — при повторной проверке, для оценки только новых компонентов; 
' winsat formal -restart clean — при повторной проверке, для сброса истории проверок и полной проверки заново.

x = MsgBox("Выполнить новое определение производительности системы (Да) или показать предыдущее (Нет) ?", _
36, "Определение производительности системы")

if x = 6 then
MsgBox"После нажатия на кнопку это окно закроется" _
& Chr(13) & "и начнётся оценка производительности системы." _
& Chr(13) & "После завершения работы функции будут выведены" _
& Chr(13) & "данные о производительности компьютера." _
& Chr(13) & "Оценка производительности занимает 2~3 минуты." _
,0,"Определение производительности системы"

Set WshShell = WScript.CreateObject("WScript.Shell")
WSHShell.Run "winsat.exe formal -restart clean",2, True

end if

strComputer = "." 
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 
Set colItems = objWMIService.ExecQuery( _
    "SELECT * FROM Win32_WinSAT",,48) 
For Each objItem in colItems 
Wscript.Echo "--------------------------------------" & vbNewLine & _
"   Производительность системы:" & vbNewLine & _
"--------------------------------------" & vbNewLine & _
"Процессор" & vbTab & vbTab & objItem.CPUScore & vbNewLine & _
"Память (RAM)" & vbTab & vbTab & objItem.MemoryScore & vbNewLine & _
"Графика" & vbTab & vbTab & vbTab & objItem.GraphicsScore & vbNewLine & _
"Графика для игр" & vbTab & vbTab & objItem.D3DScore & vbNewLine & _
"Системный жёсткий диск" & vbTab & objItem.DiskScore & vbNewLine & _
"--------------------------------------" & vbNewLine & _
"Общая производительность" & vbTab & objItem.WinSPRLevel
Next
