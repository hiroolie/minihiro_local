Sub LearnAboutNodes()
    Dim xmlDoc As DOMDocument
    Dim xmlNode As IXMLDOMNode

    Set xmlDoc = New MSXML2.DOMDocument
    xmlDoc.async = False

    xmlDoc.Load ("C:\autoinst.xml")
    
  '  If xmldoc.HasChildNodes Then
        Debug.Print "Number of child Nodes: " & xmlDoc.ChildNodes.Length
        For Each xmlNode In xmlDoc.ChildNodes
            Debug.Print "Node name:" & xmlNode.NodeName
            Debug.Print "Type:" & xmlNode.nodeTypeString & "(" & xmlNode.NodeType & ")"
            Debug.Print "Text: " & xmlNode.Text
        Next xmlNode
  '  End If
    
    Set xmlDoc = Nothing
    
End Sub