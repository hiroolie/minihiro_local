Sub writetext(tmp As IXMLDOMNode, itmp As Integer, j As Integer)
  If tmp.HasChildNodes = False Then Exit Sub
  k = tmp.ChildNodes.Length
  
  For m = 0 To k - 1
    Cells(itmp, j + m).Value = tmp.ChildNodes(m).Text
  Next
  
  j = j + k
  Set tmp = tmp.ChildNodes.NextNode
  Call writetext(tmp, itmp, j)
End Sub