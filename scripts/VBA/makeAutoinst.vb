Sub makeAutoinst()
    Dim xmlDoc As DOMDocument 'xml�f�[�^�p�ϐ�
    Dim FileValue As Boolean '�ǂݍ��ݏ��ԗp
    Dim SelNode As IXMLDOMNodeList
    Dim node As IXMLDOMNode
    Dim XmlPath As String
    Dim OutName As String
    Dim w As Long, h As Long '�J�E���g�ϐ�
    Dim SetVal As Variant, NodeVal As Variant '�Z���������ǂݍ��ݗp�ϐ�
    Dim OrgXML As String
    
    OrgXML = Cells(1, 2) '��XML�t�@�C�������擾
    
    XmlPath = ThisWorkbook.Path & "\" & OrgXML '�Z��B2�Ŏw�肵��xml���ǂݍ��݂܂�
        
    Set xmlDoc = New DOMDocument
   
    xmlDoc.async = False

        For h = 4 To Cells(Rows.Count, 2).End(xlUp).Row
            OutName = Cells(h, 3) '�o�̓t�@�C�������擾
            
            'XML�Ƃ��Ĉ����Ȃ��Ȃ镶�������폜
            Call ReplaceFromFile(XmlPath, ThisWorkbook.Path & "\tmp_" & OutName & ".xml", "<!DOCTYPE profile>")
                
            If xmlDoc.Load(ThisWorkbook.Path & "\tmp_" & OutName & ".xml") Then
    
                For w = 4 To Cells(4, Columns.Count).End(xlToLeft).Column
                    NodeVal = Cells(3, w) 'XML�̃m�[�h���w�肷�镶����
                    SetVal = Cells(h, w) 'NodeVal�ɑ��������l
        
                    If SetVal <> True Then
                        Set SelNode = xmlDoc.SelectNodes(NodeVal) '�Y�������m�[�h���z���Ɋi�[����
                        
                        '�Ώۃ^�O�Ǎ�
                        If SelNode.Length < 1 Then  '�L�����f
                            '�������^�O�쐬
                            Dim SelNode1 As IXMLDOMElement '
                            Dim NodeBefore As Variant
        
                            NodeBefore = Split(NodeName, "[")
                            
                            Set SelNode1 = xmlDoc.SelectNodes(NodeBefore)(0).CloneNode(True)
                            xmlDoc.DocumentElement(SelNode).InsertAfter SelNode1(0), xmlDoc.DocumentElement.FirstChild
                        End If
                        'MsgBox SelNode.Length
                        'MsgBox SelNode(0).Text
                        
                        '���݁��f�[�^�ݒ�
                        SelNode(0).Text = SetVal '�z�����ڂ�Setval��������
                    
                    End If
    
                Next w
            
                xmlDoc.Save (ThisWorkbook.Path & "\" & OutName & ".xml") '�����ĕۑ�
                Kill (ThisWorkbook.Path & "\tmp_" & OutName & ".xml")
                
            End If
        
     Next h

End Sub
Sub IP_DEC2HEX()
    Dim strHex
    Dim i As Long, tmp As Variant

    For i = 3 To Cells(Rows.Count, 2).End(xlUp).Row
        tmp = Split(Cells(i, 2), ".")
        Cells(i, 3) = Right("0" & Hex(tmp(0)), 2) & Right("0" & Hex(tmp(1)), 2) & Right("0" & Hex(tmp(2)), 2) & Right("0" & Hex(tmp(3)), 2)
        Next i
End Sub
