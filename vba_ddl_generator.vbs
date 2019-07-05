Option Explicit

Const ownerName = "postgres"

'ignoreCasesは大文字小文字区別するかどうか　global_は複数回マッチングするかどうか
Public Function getRegexp(target, matchPattern, Optional ignoreCases = True, Optional global_ = True)
    Dim rm As Object
    Set re = CreateObject("VBScript.RegExp")

    With re
        .Pattern = matchPattern
        .ignoreCases = ignoreCases
        .Global = global_
    End With

    Dim result = re.Execute(target)

    If result.Count > 0 Then
        getRegexp = result(0)
    Else
        getRegexp = ""
    End If

End Function

Function CreateTable(saveName, cellTableName, lineNoFirstCol, rowNotNull, rowDType, rowLen, rowPkey, rowConstr, rowColName, rowCommentCol, rowCommentTbl)
    Dim Str As String
    Str = ""
    Dim tableName As String
    tableName = Range(cellTableName).Value
    Dim fields As String
    fields = ""
    Dim alters As String
    alters = ""
    Dim lineNo As Integer: lineNo = lineNoFirstCol
    Dim pkey: pkey = ""
    Do
        Dim nn As String
        If StrComp("NOT NULL", Range(rowNotNull & lineNo).Value) = 0 Then
            nn = " NOT NULL"
        ElseIf StrComp("", Range(rowNotNull & lineNo).Value) <> 0 Then
            MsgBox "セル(" & rowNotNull & lineNo & ")に想定外の文字が指定されています：" & Range(rowNotNull & lineNo).Value
        Else
            nn = ""
        End If
        
        Dim dtype As String
        Dim tVal As String
        tVal = Range(rowDType & lineNo).Value
        If StrComp("varchar", tVal) = 0 Then
            Dim dlen As String: dlen = Range(rowLen & lineNo).Value
            If dlen = "" Then
                MsgBox "varchar(n)に長さが指定されていません"
                Exit Function
            End If
            dtype = "character varying(" & dlen & ")"
        ElseIf StrComp("serial", tVal) = 0 Then
            dtype = tVal
        ElseIf StrComp("boolean", tVal) = 0 Then
            dtype = tVal
        ElseIf StrComp("int", tVal) = 0 Then
            dtype = "integer"
        ElseIf StrComp("timestamp", tVal) = 0 Then
            dtype = "timestamp with time zone"
        ElseIf StrComp("smallint", tVal) = 0 Then
            dtype = tVal
        ElseIf StrComp("time", tVal) = 0 Then
            dtype = "time with time zone"
        ElseIf StrComp("date", tVal) = 0 Then
            dtype = tVal
        ElseIf StrComp("text", tVal) = 0 Then
            dtype = tVal
        ElseIf StrComp("bytea", tVal) = 0 Then
            dtype = tVal
        Else
            MsgBox "Unknown Data Type:" & tVal
            Exit Function
        End If
        
        If Len(fields) <> 0 Then
            fields = fields & ","
        End If
        
        Dim ColumnName As String: ColumnName = Range(rowColName & lineNo).Value
        fields = fields & " " & ColumnName & " " & dtype & nn & vbNewLine
        
        ' Primary Key
        If StrComp("○", Range(rowPkey & lineNo).Value) = 0 Then
            If Len(pkey) <> 0 Then
                pkey = pkey & ","
            End If
            pkey = pkey & ColumnName
        ElseIf StrComp("", Range(rowPkey & lineNo).Value) <> 0 Then
            MsgBox "セル(" & rowPkey & lineNo & ")に想定外の文字が指定されています：" & Range(rowPkey & lineNo).Value
            Exit Function
        End If
    
        Dim fkWork: fkWork = Range(rowConstr & lineNo).Value

        ' Unique
        If fkWork Like "*UNIQUE*" Then
        
            Dim unique: unique = ""
            unique = getRegexp(fkWork, "UNIQUE\(.*?)\)")

            If unique <> "" Then
                unique = Replace(fkWork, "UNIQUE", "")
                alters = alters & "ALTER TABLE ONLY " & tableName & " ADD CONSTRAINT m_" & tableName & "_" & ColumnName & "_uq UNIQUE (" & unique & ");" & vbNewLine
            Else
                alters = alters & "ALTER TABLE ONLY " & tableName & " ADD CONSTRAINT m_" & tableName & "_" & ColumnName & "_uq UNIQUE (" & ColumnName & ");" & vbNewLine
            End If
        End If

        ' References
        If fkWork Like "*REFERENCES*" Then
        
            Dim references: references = ""
            references = getRegexp(fkWork, "REFERENCES\(.*?)\)")

            If references <> "" Then
                Dim tblName: tblName = Replace(references, "REFERENCES(", "" )
                tblName = Replace(tblName, ")", ")
                Dim colName: colName = "id"

                ' FKの設定
                alters = alters & "ALTER TABLE ONLY " & tableName & " ADD CONSTRAINT fk_" & tableName & "_" & ColumnName & " FOREIGN KEY (" & ColumnName & ") REFERENCES " & tblName & "(" & colName & ");" & vbNewLine

            End If
        End If
    
        ' カラムのコメント
        alters = alters & "COMMENT ON COLUMN " & tableName & "." & ColumnName & " IS '" & Range(rowCommentCol & lineNo).Value & "';" & vbNewLine

        lineNo = lineNo + 1
    Loop While Range(rowCommentCol & lineNo).Value <> ""
    
    ' テーブルのコメント
    If Len(pkey) <> 0 Then
        alters = alters & "ALTER TABLE ONLY " & tableName & " ADD CONSTRAINT m_" & tableName & "_pkey PRIMARY KEY (" & pkey & ");" & vbNewLine
    End If
    alters = alters & "COMMENT ON TABLE " & tableName & " IS '" & Range(rowCommentTbl).Value & "';" & vbNewLine
    alters = alters & "ALTER TABLE public." & tableName & " OWNER TO " & ownerName & ";" & vbNewLine
    
    ' くっつける
    Str = Str & "--- テーブル「" & tableName & "」" & vbNewLine
    Str = Str & "CREATE TABLE " & tableName & " (" & vbNewLine
    Str = Str & fields
    Str = Str & ");" & vbNewLine
    Str = Str & alters & vbNewLine
    '戻す
    CreateTable = Str
End Function

Function SetSaveDir()
    '*** 保存するパスの設定
    Dim myPath As String            'フォルダパス
    Dim ShellApp As Object
    Dim oFolder As Object
    Set ShellApp = CreateObject("Shell.Application")
    Set oFolder = ShellApp.BrowseForFolder(0, "フォルダ選択", 1)
    If oFolder Is Nothing Then Exit Function
    On Error Resume Next
        myPath = oFolder.Items.Item.Path
        If Err.Number = 91 Then
            'デスクトップが選択された場合は、直接取得する
            myPath = CreateObject("WScript.Shell").SpecialFolders("Desktop")
            Err.Clear
        End If
        If Dir(myPath, vbDirectory) = "" Then
            MsgBox "保存するフォルダがありません。保存フォルダ： " & myPath
            Exit Function
        End If
    On Error GoTo 0
    SetSaveDir = myPath
End Function

Sub FileWrite(saveName, data)
    Const adTypeText = 2            '出力するためのConst
    Const adSaveCreateOverWrite = 2 '出力するためのConst
    Const adWriteLine = 1
    
    Dim mySrm As Object
    Set mySrm = CreateObject("ADODB.Stream")
    With mySrm
        '*** UTF-8で出力するためのADOを読み込み　start
        .Open
        .Type = adTypeText
        .Charset = "UTF-8"
        '*** UTF-8で出力するためのADOを読み込み　End
        
        'オブジェクトの内容をファイルに保存
        .WriteText data, adWriteLine
        .SaveToFile (saveName), adSaveCreateOverWrite

        'オブジェクトを閉じる
        .Close
    End With
    
    'メモリからオブジェクトを削除する
    Set mySrm = Nothing

End Sub

Sub DDL作成_Click()
    Dim saveName
    Dim saveDir
    saveDir = SetSaveDir()
    If Len(saveDir) = 0 Then
        Exit Sub
    End If
    saveName = saveDir & "\hoge.sql"
    
    Dim sqlStr As String
    sqlStr = ""
    Sheets("テーブル一覧").Select
    ' 描画停止
    Application.ScreenUpdating = False
    Do
        ActiveSheet.Next.Activate
        
        Dim cellTableName: cellTableName   = "V2"  'テーブル名のセル
        Dim lineNoFirstCol: lineNoFirstCol = 5     'フィールドの開始行番号
        Dim rowNotNull: rowNotNull         = "X"   'NNの列名
        Dim rowDType:rowDType              = "R"   'データ型の列名
        Dim rowLen: rowLen                 = "U"   '長さの列名
        Dim rowPkey: rowPkey               = "W"   'PKの列名
        Dim rowConstr: rowConstr           = "Y"   '制約(UQ,FK)の列名
        Dim rowColName: rowColName         = "J"   '物理名の列名
        Dim rowCommentCol: rowCommentCol   = "C"   'カラムコメントの列名
        Dim rowCommentTbl: rowCommentTbl   = "V"   'テーブルコメントの列名 

        sqlStr = sqlStr & CreateTable(saveName, cellTableName, lineNoFirstCol, rowNotNull, rowDType, rowLen, rowPkey, rowConstr, rowColName, rowCommentCol, rowCommentTbl)
    Loop While ActiveSheet.Name <> Sheets(Sheets.Count).Name ' 最後のシートまで
    
    'ファイルに出力する
    Call FileWrite(saveName, sqlStr)
    ' 描画開始
    Application.ScreenUpdating = True
    MsgBox "処理が終了しました"
End Sub