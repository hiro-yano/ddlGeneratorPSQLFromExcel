ddlGeneratorPSQLFromExcel
====

## Description
This VBA generates DDL for Postgresql from excel sheets.
You can execute this program as Excel macro.

## Requirement
require below library
* Visual Basic For Applications
* Microsoft VBScript Regular Expressions 5.5
* Microsoft Excel 16.0 Object Library
* Microsoft Forms 2.0 Object Library

## Sample 
Please refer to sample.xlsm in this repository.

## Usage
1. create new macro in Excel.
2. import vba_ddl_generator.bas and TableHeader.cls into Code window for editing macros.
3. open TableHeader class file and edit code below, depending on table definition written in spreadsheets.

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
4. 

## Contribution

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -m 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`

*Remember that we have a pre-push hook with steps that analyzes and prevents mistakes.*

**After your pull request is merged**, you can safely delete your branch.

## Licence

MIT

# Thanks
c0metssd @ ウィキ - excelからDDLを作成するマクロ例
https://www62.atwiki.jp/c0metssd/pages/81.html