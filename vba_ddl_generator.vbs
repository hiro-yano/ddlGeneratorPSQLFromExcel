Option Explicit

Const ownerName = "postgres"

Function getRegexp(target, matchPattern, Optional ignoreCase_ = True, Optional global_ = True) As String

    'ignoreCase_: ingnore upper or lower cases, global_: one pattern string is matched multiple times

    'NOTE
    'add the following reference to your VBA : Tools -> References -> Microfoft VBScript Regular Expressions
    Dim regex As Object
    Set regex = CreateObject("VBScript.RegExp")

    With regex
        .Pattern = matchPattern
        .ignoreCase = ignoreCase_
        .Global = global_
    End With
    
    Dim matches As MatchCollection
    
    Set matches = regex.Execute(target)

    getRegexp = ""
    
    If matches Is Not Nothing Then
        getRegexp = matches(0)
    End If

End Function

Private Function CreateTable(saveName, tableHeader As tableHeader)
    Dim Str As String
    Str = ""
    Dim tableName As String
    tableName = Range(tableHeader.cellTableName).Value
    Dim fields As String
    fields = ""
    Dim alters As String
    alters = ""
    Dim lineNo As Integer: lineNo = tableHeader.lineNoFirstCol
    Dim pkey: pkey = ""
    Do
        Dim nn As String
        If StrComp("y", Range(tableHeader.rowNotNull & lineNo).Value) = 0 Then
            nn = " NOT NULL"
        ElseIf StrComp("", Range(tableHeader.rowNotNull & lineNo).Value) <> 0 Then
            MsgBox "Unexpected string in Cell(" & tableHeader.rowNotNull & lineNo & ")：" & Range(tableHeader.rowNotNull & lineNo).Value
        Else
            nn = ""
        End If
        
        Dim dtype As String
        Dim tVal As String
        tVal = Range(tableHeader.rowDType & lineNo).Value
        If StrComp("varchar", tVal) = 0 Then
            Dim dlen As String: dlen = Range(tableHeader.rowLen & lineNo).Value
            If dlen = "" Then
                MsgBox "length n of varchar(n) is not specified."
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
        
        Dim ColumnName As String: ColumnName = Range(tableHeader.rowColName & lineNo).Value
        fields = fields & " " & ColumnName & " " & dtype & nn & vbNewLine
        
        ' Primary Key
        If StrComp("y", Range(tableHeader.rowPkey & lineNo).Value) = 0 Then
            If Len(pkey) <> 0 Then
                pkey = pkey & ","
            End If
            pkey = pkey & ColumnName
        ElseIf StrComp("", Range(tableHeader.rowPkey & lineNo).Value) <> 0 Then
            MsgBox "Unexpected string in Cell (" & tableHeader.rowPkey & lineNo & ")：" & Range(tableHeader.rowPkey & lineNo).Value
            Exit Function
        End If
    
        Dim fkWork: fkWork = Range(tableHeader.rowConstr & lineNo).Value

        ' Unique
        If fkWork Like "*UNIQUE*" Then
        
            Dim unique: unique = ""
            unique = getRegexp(fkWork, "UNIQUE(.*?))")

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
            references = getRegexp(fkWork, "REFERENCES(.*?))")

            If references <> "" Then
                Dim tblName: tblName = Replace(references, "REFERENCES(", "")
                tblName = Replace(tblName, ")", "")
                Dim colName: colName = "id"

                'Set Foreign Key
                alters = alters & "ALTER TABLE ONLY " & tableName & " ADD CONSTRAINT fk_" & tableName & "_" & ColumnName & " FOREIGN KEY (" & ColumnName & ") REFERENCES " & tblName & "(" & colName & ");" & vbNewLine

            End If
        End If
    
        ' Comment on each column
        alters = alters & "COMMENT ON COLUMN " & tableName & "." & ColumnName & " IS '" & Range(tableHeader.rowCommentCol & lineNo).Value & "';" & vbNewLine

        lineNo = lineNo + 1
    Loop While Range(tableHeader.rowCommentCol & lineNo).Value <> ""
    
    ' Comment on table
    If Len(pkey) <> 0 Then
        alters = alters & "ALTER TABLE ONLY " & tableName & " ADD CONSTRAINT m_" & tableName & "_pkey PRIMARY KEY (" & pkey & ");" & vbNewLine
    End If
    alters = alters & "COMMENT ON TABLE " & tableName & " IS '" & Range(tableHeader.rowCommentTbl).Value & "';" & vbNewLine
    alters = alters & "ALTER TABLE public." & tableName & " OWNER TO " & ownerName & ";" & vbNewLine
    
    '
    Str = Str & "--- Table「" & tableName & "」" & vbNewLine
    Str = Str & "CREATE TABLE " & tableName & " (" & vbNewLine
    Str = Str & fields
    Str = Str & ");" & vbNewLine
    Str = Str & alters & vbNewLine
    
    CreateTable = Str
End Function

Private Function SetSaveDir()
    '*** Set saving path
    Dim myPath As String            'path_dir
    Dim ShellApp As Object
    Dim oFolder As Object
    Set ShellApp = CreateObject("Shell.Application")
    Set oFolder = ShellApp.BrowseForFolder(0, "Please choose a directory", 1)
    If oFolder Is Nothing Then Exit Function
    On Error Resume Next
        myPath = oFolder.Items.Item.Path
        If Err.Number = 91 Then
            'If "Desktop" is chosen, get its path directory
            myPath = CreateObject("WScript.Shell").SpecialFolders("Desktop")
            Err.Clear
        End If
        If Dir(myPath, vbDirectory) = "" Then
            MsgBox "Saving directory doesn't exist. saving directory： " & myPath
            Exit Function
        End If
    On Error GoTo 0
    SetSaveDir = myPath
End Function

Private Function FileWrite(saveName, data)
    Const adTypeText = 2            'Const value to output
    Const adSaveCreateOverWrite = 2 'Const value to output
    Const adWriteLine = 1
    
    Dim mySrm As Object
    Set mySrm = CreateObject("ADODB.Stream")
    With mySrm
        '*** read ADO in UTF-8 to output
        .Open
        .Type = adTypeText
        .Charset = "UTF-8"
        
        'write an object to a file
        .WriteText data, adWriteLine
        .SaveToFile (saveName), adSaveCreateOverWrite

        'close an object
        .Close
    End With
    
    'delete an object from memory
    Set mySrm = Nothing

End Function

Sub generateDDL()
    Dim saveName
    Dim saveDir
    saveDir = SetSaveDir()
    If Len(saveDir) = 0 Then
        Exit Sub
    End If
    
    Dim n As Date
    n = now
    
    saveName = saveDir & "ddl_" & Format(n, "yyyy-mm-dd-hh-mm-ss") & ".sql"
    
    Dim sqlStr As String
    sqlStr = ""
    Sheets("table list").Select
    ' Stop painting
    Application.ScreenUpdating = False
    Do
        ActiveSheet.Next.Activate
        
        Dim tableHeader As tableHeader
        
        Set tableHeader = New tableHeader

        sqlStr = sqlStr & CreateTable(saveName, tableHeader)

    Loop While ActiveSheet.Name <> Sheets(Sheets.Count).Name ' Loop until last worksheets
    
    ' Write to a file
    Call FileWrite(saveName, sqlStr)
    ' Start painting
    Application.ScreenUpdating = True
    MsgBox "done"
End Sub

