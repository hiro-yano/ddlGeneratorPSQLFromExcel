ddlGeneratorPSQLFromExcel
====

## Description
This VBA generates DDL sequence in SQL for Postgresql from excel sheets.
You can execute this program as Excel macro.

## Requirement
* Visual Basic For Applications
* Microsoft VBScript Regular Expressions 5.5
* Microsoft Excel 16.0 Object Library
* Microsoft Forms 2.0 Object Library

## Usage
1. Write table definition in Excel like sample.xlsm.

NOTE: * You must define a PRIMARY KEY on the "id" column.
Then, this VBA generates correct sql syntax.*

2. Create new macro in Excel.
3. Import vba_ddl_generator.bas and TableHeader.cls into Code window for editing macros.
4. Open TableHeader class file and edit code below, depending on table definition written in spreadsheets.

```vbs
Private Sub Class_Initialize()
    cellTableName = "B1"         'Cell of table name
    rowCommentTbl = "E1"         'Row name of comment on a table
    lineNoFirstCol = 4           'First column number of filelds
    rowColName = "A"             'Row name of physical column name
    rowDType = "B"               'Row name of data type
    rowLen = "C"                 'Row name of length
    rowPkey = "D"                'Row name of PK which is specified or not
    rowNotNull = "E"             'Row name of NN which is specified or not
    rowConstr = "F"              'Row name of Constrains(FK,UNIQUE)
    rowCommentCol = "G"          'Row name of comment on each column
End Sub
```
## Sample 
Please refer to sample.xlsm in this repository.
The below diagram shows the ER diagram of data model written in sample.xlsm.
![ER diagram](https://github.com/yappynoppy/ddlGeneratorPSQLFromExcel/blob/master/er_diagram.png)

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
