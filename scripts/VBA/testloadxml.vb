Sub testloadxml()
    Dim XDoc As DOMDocument

    Set XDoc = New DOMDocument

    If XDoc.Load(ThisWorkbook.Path & "\sample01.xml") = False Then
    ' 読み込み失敗時
        With XDoc.parseError
            Debug.Print .ErrorCode & " / " & Replace(.reason, vbCrLf, "")
            Debug.Print "行 :" & .Line & " , カラム :" & .linepos
            Debug.Print "内容 :" & .srcText
            Debug.Print ""
            Debug.Print "ファイル(URL) :" & .URL
            Debug.Print "ファイル先頭からの位置 :" & .filepos
        End With
    
        Exit Sub
    End If
    
    Debug.Print "読み込み成功"

    Set XDoc = Nothing
End Sub