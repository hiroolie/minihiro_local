Sub makeAutoinst()
    Dim xmlDoc As DOMDocument 'xmlデータ用変数
    Dim FileValue As Boolean '読み込み状態用
    Dim SelNode As IXMLDOMNodeList
    Dim node As IXMLDOMNode
    Dim XmlPath As String
    Dim OutName As String
    Dim w As Long, h As Long 'カウント変数
    Dim SetVal As Variant, NodeVal As Variant 'セル文字列読み込み用変数
    Dim OrgXML As String
    
    OrgXML = Cells(1, 2) '元XMLファイル名を取得
    
    XmlPath = ThisWorkbook.Path & "\" & OrgXML 'セルB2で指定したxmlを読み込みます
        
    Set xmlDoc = New DOMDocument
   
    xmlDoc.async = False

        For h = 4 To Cells(Rows.Count, 2).End(xlUp).Row
            OutName = Cells(h, 3) '出力ファイル名を取得
            
            'XMLとして扱えなくなる文字列を削除
            Call ReplaceFromFile(XmlPath, ThisWorkbook.Path & "\tmp_" & OutName & ".xml", "<!DOCTYPE profile>")
                
            If xmlDoc.Load(ThisWorkbook.Path & "\tmp_" & OutName & ".xml") Then
    
                For w = 4 To Cells(4, Columns.Count).End(xlToLeft).Column
                    NodeVal = Cells(3, w) 'XMLのノードを指定する文字列
                    SetVal = Cells(h, w) 'NodeValに代入する値
        
                    If SetVal <> True Then
                        Set SelNode = xmlDoc.SelectNodes(NodeVal) '該当するノードを配列に格納する
                        
                        '対象タグ読込
                        If SelNode.Length < 1 Then  '有無判断
                            '無い→タグ作成
                            Dim SelNode1 As IXMLDOMElement '
                            Dim NodeBefore As Variant
        
                            NodeBefore = Split(NodeName, "[")
                            
                            Set SelNode1 = xmlDoc.SelectNodes(NodeBefore)(0).CloneNode(True)
                            xmlDoc.DocumentElement(SelNode).InsertAfter SelNode1(0), xmlDoc.DocumentElement.FirstChild
                        End If
                        'MsgBox SelNode.Length
                        'MsgBox SelNode(0).Text
                        
                        '存在→データ設定
                        SelNode(0).Text = SetVal '配列一つ目にSetvalを入れる
                    
                    End If
    
                Next w
            
                xmlDoc.Save (ThisWorkbook.Path & "\" & OutName & ".xml") 'そして保存
                Kill (ThisWorkbook.Path & "\tmp_" & OutName & ".xml")
                
            End If
        
     Next h

End Sub
