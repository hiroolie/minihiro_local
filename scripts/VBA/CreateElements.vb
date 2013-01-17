Public Function CreateElements(xmlDoc As DOMDocument, _
                                NodeName As String, _
                                ElementVal As String)
    '【引数説明】
    'FileName   ：対象ファイルのフルパス
    'TargetText ：置換・削除対象文字列
    'NewText    ：置換する文字列。省略した場合は削除になる
    '無い→タグ作成
    Dim NodeBefore As Variant
    Dim SelNode1 As IXMLDOMElement
    Dim SelNode2 As IXMLDOMElement
    Dim Clone As IXMLDOMElement
    Dim NodeCount As Long
    
    NodeBefore = Split(NodeName, "[")
    MsgBox NodeBefore(0)
    MsgBox NodeBefore(1)
    '親ノードまでをクローンする
    Set SelNode1 = xmlDoc.SelectNodes(NodeBefore)
    NodeCount = SelNode1.Length
    
    Set Clone = SelNode1.CloneNode(True)
    
    '追加するタグ群の親タグに対してInsertAfterを実施する
    'SelNode(0)なのでkeroタグの1番目の前に挿入
    Set SelNode1 = xmlDoc.SelectNodes(NodeBefore).CloneNode(True)
    xmlDoc.DocumentElement.InsertAfter SelNode1, xmlDoc.DocumentElement.FirstChild
    
    '.lengthでタグ数チェックは省略（実使用時は必要！）
    
End Function