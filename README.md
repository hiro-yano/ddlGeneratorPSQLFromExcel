ddlGeneratorPSQLFromExcel
====

## Description
This VBA generates DDL for Postgresql from excel sheets.
You can execute this program as Excel macro.

## Requirement

## Usage
1. modify TableHeader class

```vbs
Private Sub Class_Initialize()
    cellTableName = "B1"         'Cell of table name
    rowCommentTbl = "E1"         'row name of comment on a table
    lineNoFirstCol = 4           'First column number of filelds
    rowColName = "A"             'row name of physical column name
    rowDType = "B"               'row name of data type
    rowLen = "C"                 'row name of length
    rowPkey = "D"                'row name of PK which is specified or not
    rowNotNull = "E"             'row name of NN which is specified or not
    rowConstr = "F"              'row name of Constrains(FK,UNIQUE)
    rowCommentCol = "G"          'row name of comment on each column
End Sub
```

## Install

## Contribution

## Licence

[MIT](https://github.com/tcnksm/tool/blob/master/LICENCE)

# Thanks
c0metssd @ ウィキ - excelからDDLを作成するマクロ例
https://www62.atwiki.jp/c0metssd/pages/81.html