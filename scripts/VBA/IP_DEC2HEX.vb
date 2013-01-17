Sub IP_DEC2HEX()
    Dim strHex
    Dim i As Long, tmp As Variant

    For i = 3 To Cells(Rows.Count, 2).End(xlUp).Row
        tmp = Split(Cells(i, 2), ".")
        Cells(i, 3) = Right("0" & Hex(tmp(0)), 2) & Right("0" & Hex(tmp(1)), 2) & Right("0" & Hex(tmp(2)), 2) & Right("0" & Hex(tmp(3)), 2)
        Next i
End Sub