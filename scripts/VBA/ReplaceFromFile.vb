'�y���������z
'FileName   �F�Ώۃt�@�C���̃t���p�X
'TargetText �F�u���E�폜�Ώە�����
'NewText    �F�u�����镶����B�ȗ������ꍇ�͍폜�ɂȂ�
Public Function ReplaceFromFile(FileName As String, _
                                OutName As String, _
                                TargetText As String, _
                       Optional NewText As String = "")

 Dim FSO As New FileSystemObject '�t�@�C���V�X�e���I�u�W�F�N�g
 Dim Txt As TextStream '�e�L�X�g�X�g���[���I�u�W�F�N�g
 Dim buf_strTxt As String '�ǂݍ��݃o�b�t�@

 On Error GoTo Func_Err:

 '�I�u�W�F�N�g�쐬
 Set FSO = CreateObject("Scripting.FileSystemObject")
 Set Txt = FSO.OpenTextFile(FileName, ForReading)

 '�S���ǂݍ���
  buf_strTxt = Txt.ReadAll
  Txt.Close

  '���t�@�C�������l�[�����āA�e���|�����t�@�C���쐬
  Name FileName As OutName

  '�u������
   buf_strTxt = Replace(buf_strTxt, TargetText, NewText, , , vbBinaryCompare)

  '�����ݗp�e�L�X�g�t�@�C���쐬
   Set Txt = FSO.CreateTextFile(FileName, True)
  '������
  Txt.Write buf_strTxt
  Txt.Close

  '�e���|�����t�@�C�����폜
  'FSO.DeleteFile OutName

'�I������
Func_Exit:
    Set Txt = Nothing
    Set FSO = Nothing
    Exit Function

Func_Err:
    MsgBox "Error Number : " & Err.Number & vbCrLf & Err.Description
    GoTo Func_Exit:
End Function