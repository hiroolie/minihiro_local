Sub testloadxml()
    Dim XDoc As DOMDocument

    Set XDoc = New DOMDocument

    If XDoc.Load(ThisWorkbook.Path & "\sample01.xml") = False Then
    ' �ǂݍ��ݎ��s��
        With XDoc.parseError
            Debug.Print .ErrorCode & " / " & Replace(.reason, vbCrLf, "")
            Debug.Print "�s :" & .Line & " , �J���� :" & .linepos
            Debug.Print "���e :" & .srcText
            Debug.Print ""
            Debug.Print "�t�@�C��(URL) :" & .URL
            Debug.Print "�t�@�C���擪����̈ʒu :" & .filepos
        End With
    
        Exit Sub
    End If
    
    Debug.Print "�ǂݍ��ݐ���"

    Set XDoc = Nothing
End Sub