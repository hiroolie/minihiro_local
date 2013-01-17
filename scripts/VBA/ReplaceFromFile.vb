'【引数説明】
'FileName   ：対象ファイルのフルパス
'TargetText ：置換・削除対象文字列
'NewText    ：置換する文字列。省略した場合は削除になる
Public Function ReplaceFromFile(FileName As String, _
                                OutName As String, _
                                TargetText As String, _
                       Optional NewText As String = "")

 Dim FSO As New FileSystemObject 'ファイルシステムオブジェクト
 Dim Txt As TextStream 'テキストストリームオブジェクト
 Dim buf_strTxt As String '読み込みバッファ

 On Error GoTo Func_Err:

 'オブジェクト作成
 Set FSO = CreateObject("Scripting.FileSystemObject")
 Set Txt = FSO.OpenTextFile(FileName, ForReading)

 '全文読み込み
  buf_strTxt = Txt.ReadAll
  Txt.Close

  '元ファイルをリネームして、テンポラリファイル作成
  Name FileName As OutName

  '置換処理
   buf_strTxt = Replace(buf_strTxt, TargetText, NewText, , , vbBinaryCompare)

  '書込み用テキストファイル作成
   Set Txt = FSO.CreateTextFile(FileName, True)
  '書込み
  Txt.Write buf_strTxt
  Txt.Close

  'テンポラリファイルを削除
  'FSO.DeleteFile OutName

'終了処理
Func_Exit:
    Set Txt = Nothing
    Set FSO = Nothing
    Exit Function

Func_Err:
    MsgBox "Error Number : " & Err.Number & vbCrLf & Err.Description
    GoTo Func_Exit:
End Function