Public Function CreateElements(xmlDoc As DOMDocument, _
                                NodeName As String, _
                                ElementVal As String)
    '�y���������z
    'FileName   �F�Ώۃt�@�C���̃t���p�X
    'TargetText �F�u���E�폜�Ώە�����
    'NewText    �F�u�����镶����B�ȗ������ꍇ�͍폜�ɂȂ�
    '�������^�O�쐬
    Dim NodeBefore As Variant
    Dim SelNode1 As IXMLDOMElement
    Dim SelNode2 As IXMLDOMElement
    Dim Clone As IXMLDOMElement
    Dim NodeCount As Long
    
    NodeBefore = Split(NodeName, "[")
    MsgBox NodeBefore(0)
    MsgBox NodeBefore(1)
    '�e�m�[�h�܂ł��N���[������
    Set SelNode1 = xmlDoc.SelectNodes(NodeBefore)
    NodeCount = SelNode1.Length
    
    Set Clone = SelNode1.CloneNode(True)
    
    '�ǉ�����^�O�Q�̐e�^�O�ɑ΂���InsertAfter�����{����
    'SelNode(0)�Ȃ̂�kero�^�O��1�Ԗڂ̑O�ɑ}��
    Set SelNode1 = xmlDoc.SelectNodes(NodeBefore).CloneNode(True)
    xmlDoc.DocumentElement.InsertAfter SelNode1, xmlDoc.DocumentElement.FirstChild
    
    '.length�Ń^�O���`�F�b�N�͏ȗ��i���g�p���͕K�v�I�j
    
End Function