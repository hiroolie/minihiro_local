Sub makeRules()
  'nodelist�ł̏����o��
  'writetext�Ŏq�m�[�h���ċA�I�ɏ����o��
  '
  Dim myxml As New DOMDocument40
  Dim nodelist As IXMLDOMNodeList
  Dim onenode As IXMLDOMNode
  Dim i As Integer

  myxml.Load ("D:\....\link.xml")
  Set nodelist = myxml.DocumentElement.ChildNodes
  i = 1
  For Each onenode In nodelist
    Call writetext(onenode, i, 1)
    i = i + 1
  Next
End Sub