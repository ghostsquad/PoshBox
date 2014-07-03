function New-ConsoleTable {
    param(
            [int]$columns = 0,
            [int]$rows = 0,
            [int]$defaultCellWidth = 10,
            [int]$defaultCellVerticalPadding = 0,
            [switch]$NoSave = $false,
            [switch]$NoBorders = $false,
            [switch]$NoHeader = $false
        )

        if($rows -lt 0){
            throw("rows must be a positive number")
        }
        if($columns -lt 0){
            throw("columns must be a positive number")
        }
        if($defaultCellWidth -lt 1){
            throw("max cell width must be greater than 0")
        }
        if($defaultCellVerticalPadding -lt 0){
            throw("cell height padding must be greater than or equal to 0")
        }

        #theobject this function will return
        $tableObj = New-Object System.Management.Automation.PSObject

        ###### START PROPERTIES #######

        $rowsObj = New-Object System.Collections.ArrayList
        $tableObj | Add-Member -MemberType NoteProperty -Name Rows -Value $rowsObj

        $columnsObj = New-Object System.Collections.ArrayList
        $tableObj | Add-Member -MemberType NoteProperty -Name Columns -Value $columnsObj

        $tableObj | Add-Member -MemberType NoteProperty -Name defaultCellWidth -Value $defaultCellWidth
        $tableObj | Add-Member -MemberType NoteProperty -Name defaultCellVerticalPadding -Value $defaultCellVerticalPadding
        $tableObj | Add-Member -MemberType NoteProperty -Name SaveData -Value (!($NoSave))
        $tableObj | Add-Member -MemberType NoteProperty -Name Borders -Value (!($NoBorders))
        $tableObj | Add-Member -MemberType NoteProperty -Name Header -Value (!($NoHeader))

        #we only want 1 table for each table object
        #this will increment when create() method is called
        #an exception will be thrown on subsequent calls to create()
        $tableObj | Add-Member -MemberType NoteProperty -Name Instances -Value 0

        $cellsObj = New-Object System.Collections.ArrayList
        $tableObj | Add-Member -MemberType NoteProperty -Name Cells -Value $cellsObj

        #create Position object. This is the position of the table when it is created
        #This is used to remember the cursor position when the table is updated
        $positionObj = New-Object System.Management.Automation.PSObject
        $positionObj | Add-Member -MemberType NoteProperty -Name X -Value $null
        $positionObj | Add-Member -MemberType NoteProperty -Name Y -Value $null

        $tableObj | Add-Member -MemberType NoteProperty -Name Position -Value $positionObj

        $tableObj | Add-Member -MemberType NoteProperty -Name BottomOfTable -Value $null

        #create cursorPosition object.
        #This is used to remember the last cursor position when the table is updated
        $cursorPosition = New-Object System.Management.Automation.PSObject
        $cursorPosition | Add-Member -MemberType NoteProperty -Name X -Value $null
        $cursorPosition | Add-Member -MemberType NoteProperty -Name Y -Value $null

        $tableObj | Add-Member -MemberType NoteProperty -Name CursorPosition -Value $cursorPosition

        ###### END PROPERTIES #######

        ###### START METHODS #######

        $tableObj | Add-Member -MemberType ScriptMethod -Name AddRow -Value {
            param ($verticalpadding = $null)

            if($Host.Version.ToString() -match "^1"){
                $verticalpadding = $args[0]
            }

            #msgbox "DEBUG" "validating..."

            #validation
            if($this.Instances -gt 0){
                #throw "cannot add rows after the table is written"
            }
            if($verticalpadding -eq $null){
                [int]$verticalpadding = $this.defaultCellVerticalPadding
            }
            elseif([int]$verticalpadding -lt 0){
                throw "verticalpadding must be a positive number (including 0)"
            }

            #msgbox "DEBUG" "creating row obj..."

            [int]$verticalpadding = $verticalpadding

            $singleRowObj = New-Object System.Management.Automation.PSObject
            $singleRowObj | Add-Member -MemberType NoteProperty -Name VerticalPadding -Value $verticalpadding

            $rowNum = $this.rows.Add($singleRowObj)

            $userFriendRowNum = $rowNum + 1
            #msgBox "DEBUG" "adding array list row num: $rowNum"
            #msgBox "DEBUG" "real row number should be: $userFriendRowNum"

            #if the table was already written, we need to write the row to the console
            if($this.Instances -gt 0){
                #throw "cannot add rows after the table is written"

                #msgbox "DEBUG" "adding row after table written"

                #msgbox "DEBUG" "getting bottom of table..."

                $BottomOfTable = $this.BottomOfTable

                #msgbox "DEBUG" ("curbottomOfTable: $BottomOfTable")

                $NewBottomOfTable = $this.position.y + $this.get_Height()

                #msgbox "DEBUG" ("newbottomOfTable: $NewBottomOfTable")

                #get Empty Cell Text
                $emptyCellText = $this.CreateEmptyCellText()

                #get Row Break Text
                $rowBreakObj = $this.CreateRowBreakText()
                $headerRowBreak = $rowBreakObj.HeaderRowBreak
                $rowBreak = $rowBreakObj.rowBreak

                #msgbox "DEBUG" "creating cell objects..."

                #create cell objects
                for($j = 1; $j -le $this.columns.count; $j++){
                    $this.CreateCellObj($j,$userFriendRowNum)
                }

                #set cell positions
                #msgBox "DEBUG" "settings cellpositions for row: $userFriendRowNum"
                $this.SetCellPositionsByRow($userFriendRowNum)

                #msgbox "DEBUG" "getting buffer info..."

                $bufferHeight = $host.ui.rawui.CursorPosition.Y
                $bufferWidth = $host.ui.rawui.BufferSize.Width
                #msgBox "DEBUG" "bufferHeight: $bufferHeight`nbufferWidth: $bufferWidth"
                #rectangle args = left , top , right , bottom
                #$rec = new-object System.Management.Automation.Host.Rectangle 0,0,($bufferWidth - 1),$bufferHeight

                $recLeft = 0
                $recTop = $bottomOfTable
                $recRight = $bufferWidth - 1
                $recBottom = $bufferHeight

                $rec = new-object System.Management.Automation.Host.Rectangle $recLeft,$recTop,$recRight,$recBottom
                $buffer = $host.ui.rawui.GetBufferContents($rec)

                #msgBox "DEBUG" ("rec: $recLeft , $recTop, $recRight , $recBottom")

                $heightOfRec = $recBottom - $recTop

                #msgbox "DEBUG" "creating text builders..."
                #create TextBuilder object of text that was grabbed from the console
                # Iterate through the lines in the console buffer.
                # Initialize string builder.
                $eraser = new-object system.text.stringbuilder
                $textBuilder = new-object system.text.stringbuilder
                for($i = 0; $i -lt $heightOfRec; $i++)
                {
                    for($j = 0; $j -lt $bufferWidth; $j++)
                    {
                        $BufferCell = $buffer[$i,$j]
                        $textBuilder.Append($BufferCell.Character) | Out-Null
                        $eraser.Append(" ") | Out-Null
                    }
                    $textBuilder.Append("`r`n") | Out-Null
                    $eraser.Append("`r`n") | Out-Null
                }

                #msgbox "DEBUG" ("contents:`n`""+$textBuilder.toString()+"`"")

                #msgbox "DEBUG" "erasing buffer after table..."

                #erase buffer after table
                # Initialize string builder.

                [Console]::SetCursorPosition(0,$bottomOfTable)

                #msgBox "DEBUG" $erasor.length

                if($eraser.length -gt 0){
                    $bufferSize = $Host.UI.RawUI.BufferSize
                    $bufferSize.width++
                    $Host.UI.RawUI.BufferSize = $bufferSize
                    #msgBox "DEBUG" ("eraserstring: `""+$eraser.toString()+"`"")
                    [Console]::Write($eraser.toString())
                    $bufferSize = $Host.UI.RawUI.BufferSize
                    $bufferSize.width--
                    $Host.UI.RawUI.BufferSize = $bufferSize

                    [Console]::SetCursorPosition(0,$bottomOfTable)
                }

                #msgbox "DEBUG" "Adding Table row..."
#                Write-Host "|                    |                    |" -ForegroundColor Magenta
#                Write-Host "+--------------------+--------------------+" -ForegroundColor Magenta

                $row = $this.rows[$rowNum]
                #the height of the row is 2x padding + 1
                #example - padding 0
                #----
                #<content>
                #----
                #as you can see, rowheight = (0*2)+1 = 1
                #example 2 - padding 1
                #----
                #
                #<content>
                #
                #----
                #as you can see rowheight = (1*2)+1 = 3
                $rowHeight = ($row.VerticalPadding * 2) + 1

                $this.cells | where { $_.row -eq $rowNum } | %{

                    $YOffset = $this.position.y
                    #we start calculating the Y position after the border (if there is one)
                    if($this.borders -eq $true){
                         $YOffset++
                    }

                    #loop through  all rows before this one, and get the row height of each
                    #add these values to $topMostPositionOfCell
                    for($i = 0; $i -lt ($rowNum - 1); $i++){
                        $YOffset += ($this.rows[$i].verticalpadding * 2) + 1
                        #the following only applies to rows after the 1st row
                        if($rowNum -gt 1){
                            #if borders are enabled, each row will have a top border
                            #add 1 X <Number of Rows before this one> to $topMostPositionOfCell
                            if($this.borders -eq $true){
                                $YOffset++
                            }
                        }
                    }

                    #the "if borders eq $true" above will take care of borders on every row
                    #but if the "header" switch is enabled,
                    #we will have 1 "border" below row 1 (above row 2), and no additional borders
                    #so we must offset each row after the first by 1
                    if($rowNum -gt 1 -and $this.borders -eq $false -and $this.header -eq $true){
                        $YOffset++
                    }

                    #once we know where the very top of the cell is, we need to know the write position
                    #the write position (in this version) is the vertically aligned to the middle of the cell
                    #thus, we need to determine the row height, divide by 2, and floor it
                    #note: writepos 0 = the top of the cell
                    #eg. rowheight 3 (padding1) - writePos = 3/2 rounded down = 1
                    if($rowHeight -gt 1){
                        $writePos = [Math]::Floor($rowHeight / 2)
                    }else{
                        $writePos = 0
                    }

                    $yPosOfCell = $YOffset + $writePos

                    $_.position.y = $yPosOfCell
                }

                for($i = 0; $i -lt $rowHeight; $i++){

                    [Console]::Write($emptyCellText+"`n")

                }

                if($rowNum -eq 1 -and $this.header -eq $true -and $this.borders -eq $false){
                    [Console]::Write($headerRowBreak+"`n")
                }elseif($this.borders -eq $true){
                    [Console]::Write($rowBreak+"`n")
                }

                #msgbox "DEBUG" "setting cursor to new bottom: $NewBottomOfTable"

                [Console]::SetCursorPosition(0,$NewBottomOfTable)

                #msgbox "DEBUG" "Writing saved console contents..."

                #Write what was grabbed back to the console
                $bufferSize = $Host.UI.RawUI.BufferSize
                $bufferSize.width++
                $Host.UI.RawUI.BufferSize = $bufferSize
                [Console]::Write($textBuilder.toString())
                $bufferSize = $Host.UI.RawUI.BufferSize
                $bufferSize.width--
                $Host.UI.RawUI.BufferSize = $bufferSize

                #updateBottomOfTable
                $this.BottomOfTable = $NewBottomOfTable

                [Console]::SetCursorPosition(0,$host.ui.rawui.CursorPosition.Y)

                #msgBox "DEBUG" "endof dynamic addRow"

            }
        }

        $tableObj | Add-Member -MemberType ScriptMethod -Name RemoveRow -Value {
            #this function always removes the last row in the table (it is the opposite of the "addrow" function)

            $rowToRemove = $this.rows.count-1

            $row = $this.rows[$rowToRemove]
            #the height of the row is 2x padding + 1
            #example - padding 0
            #----
            #<content>
            #----
            #as you can see, rowheight = (0*2)+1 = 1
            #example 2 - padding 1
            #----
            #
            #<content>
            #
            #----
            #as you can see rowheight = (1*2)+1 = 3
            $rowHeight = ($row.VerticalPadding * 2) + 1

            #removeCells
            $cellsToRemove = @()
            for($i = 0; $i -lt $this.cells.count; $i++){
                if($this.cells[$i].row -eq $rowToRemove){
                    $cellsToRemove += $i
                }
            }
            foreach($cell in $cellsToRemove){
                $this.cells.removeAt($cell)
            }

            #removeRow
            $this.rows.RemoveAt($rowToRemove)

            #if the table was already written, we need to remove the row text from the console
            if($this.Instances -gt 0){
                #msgbox "DEBUG" "removing row after table written"

                #msgbox "DEBUG" "getting bottom of table..."

                $BottomOfTable = $this.BottomOfTable

                #msgbox "DEBUG" ("curbottomOfTable: $BottomOfTable")

                #new bottom of table position = Top of Table position + Height of Table
                #we already removed the backend rows/cells that are used in the get_Height() calculations
                $NewBottomOfTable = $this.position.y + $this.get_Height()

                #msgbox "DEBUG" ("newbottomOfTable: $NewBottomOfTable")

                #msgbox "DEBUG" "getting buffer info..."

                $bufferHeight = $host.ui.rawui.CursorPosition.Y
                $bufferWidth = $host.ui.rawui.BufferSize.Width
                #msgBox "DEBUG" "bufferHeight: $bufferHeight`nbufferWidth: $bufferWidth"
                #rectangle args = left , top , right , bottom
                #$rec = new-object System.Management.Automation.Host.Rectangle 0,0,($bufferWidth - 1),$bufferHeight

                $recLeft = 0
                $recTop = $bottomOfTable
                $recRight = $bufferWidth - 1
                $recBottom = $bufferHeight

                $rec = new-object System.Management.Automation.Host.Rectangle $recLeft,$recTop,$recRight,$recBottom
                $buffer = $host.ui.rawui.GetBufferContents($rec)

                #msgBox "DEBUG" ("rec: $recLeft , $recTop, $recRight , $recBottom")

                $heightOfRec = $recBottom - $recTop

                #msgbox "DEBUG" "creating text builders..."
                #create TextBuilder object of text that was grabbed from the console
                # Iterate through the lines in the console buffer.
                # Initialize string builder.
                $eraser = new-object system.text.stringbuilder
                $textBuilder = new-object system.text.stringbuilder

                #calculate the height of what we will be erasing from the table
                $heightToEraseFromTable = $BottomOfTable - $NewBottomOfTable

                for($i = 0; $i -lt ($heightOfRec + $heightToEraseFromTable); $i++)
                {
                    for($j = 0; $j -lt $bufferWidth; $j++)
                    {
                        $BufferCell = $buffer[$i,$j]
                        $textBuilder.Append($BufferCell.Character) | Out-Null
                        $eraser.Append(" ") | Out-Null
                    }
                    $textBuilder.Append("`r`n") | Out-Null
                    $eraser.Append("`r`n") | Out-Null
                }

                #msgbox "DEBUG" ("contents:`n`""+$textBuilder.toString()+"`"")

                #msgbox "DEBUG" "erasing buffer after table..."

                #erase buffer after table
                # Initialize string builder.

                [Console]::SetCursorPosition(0,$NewBottomOfTable)

                #msgBox "DEBUG" $erasor.length

                if($eraser.length -gt 0){
                    $bufferSize = $Host.UI.RawUI.BufferSize
                    $bufferSize.width++
                    $Host.UI.RawUI.BufferSize = $bufferSize
                    #msgBox "DEBUG" ("eraserstring: `""+$eraser.toString()+"`"")
                    [Console]::Write($eraser.toString())
                    $bufferSize = $Host.UI.RawUI.BufferSize
                    $bufferSize.width--
                    $Host.UI.RawUI.BufferSize = $bufferSize

                    [Console]::SetCursorPosition(0,$NewBottomOfTable)
                }

                #msgbox "DEBUG" "Writing saved console contents..."

                #Write what was grabbed back to the console
                $bufferSize = $Host.UI.RawUI.BufferSize
                $bufferSize.width++
                $Host.UI.RawUI.BufferSize = $bufferSize
                [Console]::Write($textBuilder.toString())
                $bufferSize = $Host.UI.RawUI.BufferSize
                $bufferSize.width--
                $Host.UI.RawUI.BufferSize = $bufferSize

                #updateBottomOfTable
                $this.BottomOfTable = $NewBottomOfTable

                [Console]::SetCursorPosition(0,$host.ui.rawui.CursorPosition.Y - $heightToEraseFromTable)

                #msgBox "DEBUG" "endof dynamic removeRow"

            }
        }

        $tableObj | Add-Member -MemberType ScriptMethod -Name AddColumn -Value {
            param ($width = $null)

            if($Host.Version.ToString() -match "^1"){
                $width = $args[0]
            }

            #validation
            if($this.Instances -gt 0){
                #throw "cannot add columns after the table is written"
            }

            if($width -eq $null){
                [int]$width = $this.defaultCellWidth
            }
            elseif([int]$width -lt 1){
                throw "width must be greater than 0"
            }

            [int]$width = $width

            $singleColumnObj = New-Object System.Management.Automation.PSObject
            $singleColumnObj | Add-Member -MemberType NoteProperty -Name Width -Value $width

            $this.columns.add($singleColumnObj) | Out-Null

            #if the table was already written, we need to write the column to the console
            if($this.Instances -gt 0){
                #NEEDS TO BE COMPLETED.
            }
        }

        $tableObj | Add-Member -MemberType ScriptMethod -Name UpdateCell -Value {
            param([int]$column,[int]$row,[string]$value = "")

            if($Host.Version.ToString() -match "^1"){
                [int]$column = $args[0]
                [int]$row = $args[1]
                [string]$value = $args[2]
            }

            if($this.Instances -lt 1){
                throw "can't update cell contents until table is written"
            }

            #general validation
            if($row -lt 1){ throw "row must be greater than 0"}
            if($column -lt 1){ throw "column must be greater than 0"}

            #verify cell doesn't fall outside of the scope of the table
            if($row -gt $this.rows.count -or $column -gt $this.columns.count){
                throw "requested position is outside the scope of the table"
            }

            $MaxCellWidth = $this.columns[$column - 1].width

            if($this.SaveData -eq $true){
                $this.cells | where { $_.row -eq $row -and $_.column -eq $column } | %{$_.value = $value}
            }

            $theCell = $this.cells | where { $_.row -eq $row -and $_.column -eq $column }

            $CursorX = $theCell.position.x
            $CursorY = $theCell.position.y

            if(isNumeric $value){
                #"int"
                #If the value is a number.. pad left
                #example output:
                #|   12.01|
                #msgBox "debug" ("value length: "+$value.toString().length+"`nCellWidth: "+$MaxCellWidth)
                if($value.toString().length -gt $MaxCellWidth){
                    #msgbox "debug - number bigger than cell width" ($value+"`nLength: "+$value.toString().length+"`nCellWidth: "+$MaxCellWidth)
                    if(([Int64]$value).toString().length -gt $MaxCellWidth){
                        #msgBox "debug - int is bigger than cell width" (([Int64]$value).toString()+"`nLength: "+([Int64]$value).toString().length+"`nCellWidth: "+$MaxCellWidth)
                        $EPrecision = $MaxCellWidth - 7
                        if($EPrecision -lt 0){$EPrecision = 0}
                        #msgBox "eprecision" $EPrecision
                        $formatString = "{0:E$EPrecision}"
                        [string]$value = [string]::Format($formatString,[double]$value)
                    }
                }
                $writeValue = ((truncate-string $value $MaxCellWidth).padLeft($MaxCellWidth," "))
            }else{
                #"not an integer"
                #If the value is text.. pad right
                #example output:
                #|asdf   |
                $writeValue = ((truncate-string $value $MaxCellWidth).padRight($MaxCellWidth," "))
            }

            $this.RememberCursorPosition()

            #msgBox "DEBUG" "X: $CursorX, Y: $CursorY"
            [Console]::SetCursorPosition($CursorX,$CursorY)
            #msgBox "DEBUG" "About to Write: `n`"$writeValue`""
            [Console]::Write($writeValue)

            $this.ReturnCursor()
        }

        $tableObj | Add-Member -MemberType ScriptMethod -Name GetCellValue -Value {
            param([int]$column,[int]$row)

            if($Host.Version.ToString() -match "^1"){
                [int]$column = $args[0]
                [int]$row = $args[1]
            }

            if($this.saveData -eq $false){
                throw "noSave switch was used for this table, data is not saved"
            }

            if($this.Instances -lt 1){
                throw "cells won't have content until table is written"
            }

            #general validation
            if($row -lt 1){ throw "row must be greater than 0"}
            if($column -lt 1){ throw "column must be greater than 0"}

            #verify cell doesn't fall outside of the scope of the table
            if($row -gt $this.rows.count -or $column -gt $this.columns.count){
                throw "requested position is outside the scope of the table"
            }


            return $this.cells | where { $_.row -eq $row -and $_.column -eq $column } | %{$_.value}

        }

        $tableObj | Add-Member -MemberType ScriptMethod -Name CreateCellObj -Value {
            param ([int]$column,[int]$row)

            if($Host.Version.ToString() -match "^1"){
                [int]$column = $args[0]
                [int]$row = $args[1]
            }

            #general validation
            if($row -lt 1){ throw "row must be greater than 0"}
            if($column -lt 1){ throw "column must be greater than 0"}

            #verify cell doesn't fall outside of the scope of the table
            if($row -gt $this.rows.count -or $column -gt $this.columns.count){
                throw "requested position is outside the scope of the table"
            }

            $cell = New-Object System.Management.Automation.PSObject
            $cell | Add-Member -MemberType NoteProperty -Name Row -Value $row
            $cell | Add-Member -MemberType NoteProperty -Name Column -Value $column

            $cellPosObj = New-Object System.Management.Automation.PSObject
            $cellPosObj | Add-Member -MemberType NoteProperty -Name X -Value 0
            $cellPosObj | Add-Member -MemberType NoteProperty -Name Y -Value 0

            $cell | Add-Member -MemberType NoteProperty -Name position -Value $cellPosObj
            $cell | Add-Member -MemberType NoteProperty -Name value -Value ""

            $this.cells.add($cell) | Out-Null
        }

        $tableObj | Add-Member -MemberType ScriptMethod -Name RememberCursorPosition -Value {
            $this.CursorPosition.X = $host.UI.RawUI.CursorPosition.X
            $this.CursorPosition.Y = $host.UI.RawUI.CursorPosition.Y
        }

        $tableObj | Add-Member -MemberType ScriptMethod -Name ReturnCursor -Value {
            [Console]::SetCursorPosition(0,$this.CursorPosition.Y)
        }

        $tableObj | Add-Member -MemberType ScriptMethod -Name Clear -Value {
            $this.cells | %{$this.updateCell($_.column,$_.row),$null}
        }

        $tableObj | Add-Member -MemberType ScriptMethod -Name get_Height -Value {

            if($this.Instances -lt 1){
                throw "can't get table height until it is written"
            }

            $tableHeight = 0

            #msgBox "DEBUG" "getHeightCalled"

            #add row heights
            $i = 0
            foreach($row in $this.rows){
                $rowHeight = ($row.verticalPadding * 2) + 1
                $tableHeight += $rowHeight
                $i++
                #msgbox "DEBUG" ("Adding row $i`nRowHeight: "+$rowHeight+"`nNewTableHeight: "+$tableHeight)
            }
            #add height created from borders
            if($this.borders -eq $true){
                #msgBox "DEBUG" "borders TRUE"
                #msgBox "DEBUG" ("rowCount"+$this.rows.count)
                #msgBox "DEBUG" ("rowcount + 1 = "+($this.rows.count + 1))
                $tableHeight += $this.rows.count + 1
                #msgBox "DEBUG" "newTableHeight: $tableHeight"
            #add height created from the header row lower border
            }elseif($this.header -eq $true){
                #msgBox "DEBUG" "header TRUE"
                $tableHeight++
                #msgBox "DEBUG" "newTableHeight: $tableHeight"
            }

            #msgBox "DEBUG" "finalTableHeight: $tableHeight"

            return $tableHeight

        }

        $tableObj | Add-Member -MemberType ScriptMethod -Name get_Width -Value {

            if($this.Instances -lt 1){
                throw "can't get table width until it is written"
            }

            $tableWidth = 0

            foreach($column in $this.columns){
                $tableWidth += $column.width
            }

            if($this.borders -eq $true){
                $tableWidth++
                foreach($column in $this.columns){
                    $tableWidth++
                }
            }
        }

        $tableObj | Add-Member -MemberType ScriptMethod -Name CreateRowBreakText -Value {
            #create rowBreak text
            #eg
            # +------+--+
            #note: there is no rowBreaktext if -noBorders is enabled

            #we will create a "header row break" in the case the -noBorders is enabled and -noHeaders is disabled
            $headerRowBreak = ""
            $headerRowColIntersect = " "
            $headerHorizontalBorder = "-"

            $rowColIntersect = "+"
            $horizontalBorder = "-"
            if($this.borders -eq $true){
                $rowBreak = $rowColIntersect
            }else{
                $rowBreak = ""
            }
            foreach($column in $this.columns){

                $Cellwidth = $column.width

                for($i = 0; $i -lt $Cellwidth; $i++){
                    $headerRowBreak += $headerHorizontalBorder
                    $rowBreak += $horizontalBorder
                }
                $headerRowBreak += $headerRowColIntersect
                $rowBreak += $rowColIntersect
            }

            $rowBreakTextObj = New-Object System.Management.Automation.PSObject
            $rowBreakTextObj | Add-Member -MemberType NoteProperty -Name HeaderRowBreak -Value $headerRowBreak
            $rowBreakTextObj | Add-Member -MemberType NoteProperty -Name RowBreak -Value $rowBreak

            return $rowBreakTextObj
        }

        $tableObj | Add-Member -MemberType ScriptMethod -Name CreateEmptyCellText -Value {

            #create single line emptyCell text
            #while we are in this loop and figuring out widths and all that, we can assign the POS X value for each cell in each column
            #eg
            # |      |  |

            if($this.borders -eq $true){
                $verticalBorder = "|"
                #we start our string with the vertical border
                $emptyCellText = $verticalBorder
            }else{
                $verticalBorder = " "
                #we start our string with the vertical border. in this case, there is no border
                $emptyCellText = ""
            }
            $colNum = 1

            foreach($column in $this.columns){

                $Cellwidth = $column.width

                for($i = 0; $i -lt $Cellwidth; $i++){
                    $emptyCellText += " "
                }

                $emptyCellText += $verticalBorder

                $colNum++
            }

            return $emptyCellText
        }

        $tableObj | Add-Member -MemberType ScriptMethod -Name SetCellPositionsByRow -Value {
            param([int]$rowNum)

            if($Host.Version.ToString() -match "^1"){
                [int]$rowNum = $args[0]
            }

            #msgBox "DEBUG" "setCellPositionsByRow called for rowNum $rowNum"

            #calculate and set cell positions
            $this.cells | where { $_.row -eq $rowNum } | %{

                ############
                # SET X POSITION
                ############
                $colNum = $_.column

                $xPosOfCell = $this.position.x
                if($this.borders -eq $true){
                    $xPosOfCell++
                }

                for($i = 0; $i -lt ($colNum - 1); $i++){

                    $xPosOfCell += $this.columns[$i].width
                    $xPosOfCell += 1

                }

                $_.position.x = $xPosOfCell

                ############
                # / SET X POSITION
                ############

                ############
                # SET Y POSITION
                ############
                $YOffset = $this.position.y
                #msgBox "DEBUG" "starting y position: $YOffset"
                #we start calculating the Y position after the border (if there is one)
                if($this.borders -eq $true){
                     $YOffset++
                     #msgBox "DEBUG" "borders true, new y: $YOffset"
                }

                #loop through  all rows before this one, and get the row height of each
                #add these values to $topMostPositionOfCell
                for($i = 0; $i -lt ($rowNum - 1); $i++){
                    $YOffset += ($this.rows[$i].verticalpadding * 2) + 1
                    #the following only applies to rows after the 1st row
                    if($rowNum -gt 1){
                        #if borders are enabled, each row will have a top border
                        #add 1 X <Number of Rows before this one> to $topMostPositionOfCell
                        if($this.borders -eq $true){
                            $YOffset++
                        }
                    }
                }

                #the "if borders eq $true" above will take care of borders on every row
                #but if the "header" switch is enabled,
                #we will have 1 "border" below row 1 (above row 2), and no additional borders
                #so we must offset each row after the first by 1
                if($rowNum -gt 1 -and $this.borders -eq $false -and $this.header -eq $true){
                    $YOffset++
                }

                #once we know where the very top of the cell is, we need to know the write position
                #the write position (in this version) is the vertically aligned to the middle of the cell
                #thus, we need to determine the row height, divide by 2, and floor it
                #note: writepos 0 = the top of the cell
                #eg. rowheight 3 (padding1) - writePos = 3/2 rounded down = 1
                if($rowHeight -gt 1){
                    $writePos = [Math]::Floor($rowHeight / 2)
                }else{
                    $writePos = 0
                }

                $yPosOfCell = $YOffset + $writePos

                $_.position.y = $yPosOfCell

                ############
                # / SET Y POSITION
                ############

                #msgBox "DEBUG" ("Y: "+$_.position.y+",X: "+$_.position.x)
            }
        }

        $tableObj | Add-Member -MemberType ScriptMethod -Name Write -Value {

            $rows = $this.rows.count
            $columns = $this.columns.count
            $MaxCellWidth = $this.defaultCellWidth
            $cellHeightPadding = $this.defaultCellVerticalPadding

            if($this.Instances -lt 1){
                if($rows -lt 1){
                    throw "cannot write a table without rows"
                }
                if($columns -lt 1){
                    throw "cannot write a table without columns"
                }
                $this.Instances = 1
            }else{
                throw "only 1 table allowed per object"
            }

            #capture position of the cursor. This is where the table will write to
            $this.position.X = $host.UI.RawUI.CursorPosition.X
            $this.position.Y = $host.UI.RawUI.CursorPosition.Y

            $maxWidth = $columns + ($columns * $maxCellwidth) + 1

            #adjust buffer size if it's too small to display the table
            $bufferSize = $Host.UI.RawUI.BufferSize
            if($bufferSize.Width -le $maxWidth){
                $bufferSize.Width = $maxWidth + 1
                $Host.UI.RawUI.BufferSize = $bufferSize
            }

            #create cell objects
            for($i = 1; $i -le $rows; $i++){

                for($j = 1; $j -le $columns; $j++){

                    $this.CreateCellObj($j,$i)
                }
            }

            #get Empty Cell Text (full table)
            $emptyCellText = $this.CreateEmptyCellText()

            #get Row Break Text (full table)
            $rowBreakObj = $this.CreateRowBreakText()
            $headerRowBreak = $rowBreakObj.HeaderRowBreak
            $rowBreak = $rowBreakObj.rowBreak

            #write out the table
            if($this.borders -eq $true){
                [Console]::Write($rowBreak+"`n")
            }
            $rowNum = 1
            foreach($row in $this.rows){

                #the height of the row is 2x padding + 1
                #example - padding 0
                #----
                #<content>
                #----
                #as you can see, rowheight = (0*2)+1 = 1
                #example 2 - padding 1
                #----
                #
                #<content>
                #
                #----
                #as you can see rowheight = (1*2)+1 = 3
                $rowHeight = ($row.VerticalPadding * 2) + 1

                #setCellPositions for this row
                $this.SetCellPositionsByRow($rowNum)

                for($i = 0; $i -lt $rowHeight; $i++){

                    [Console]::Write($emptyCellText+"`n")

                }
                if($rowNum -eq 1 -and $this.header -eq $true -and $this.borders -eq $false){
                    [Console]::Write($headerRowBreak+"`n")
                }elseif($this.borders -eq $true){
                    [Console]::Write($rowBreak+"`n")
                }
                $rowNum++
            }

            #setting bottom of table
            $this.BottomOfTable = $this.position.y + $this.get_Height()
            #msgBox "DEBUG" ("bottomOfTableSet: "+$this.BottomOfTable)
        }

        ###### END METHODS #######

        ###### Other Initializations #####

        for($i = 0; $i -lt $rows; $i++){
            $tableObj.AddRow()
        }

        for($i = 0; $i -lt $columns; $i++){
            $tableObj.AddColumn()
        }

        ###### End Other Initializations #####

        return $tableObj
}

function isNumeric {
    param([string]$value)
    [reflection.assembly]::LoadWithPartialName("'Microsoft.VisualBasic") | out-null
    return [Microsoft.VisualBasic.Information]::isNumeric($value)
}

function truncate-string([string]$value, [int]$length)
{
    if ($value.Length -gt $length) { $value.Substring(0, $length) }
    else { $value }
}
