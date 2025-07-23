try {
    $rootDir    = Split-Path -Parent $MyInvocation.MyCommand.Definition
    $outputFile = Join-Path $rootDir "output.sql"
    $dbDir      = Join-Path $rootDir "db"
    $utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False

    $initialSql = @'
CREATE DATABASE IF NOT EXISTS quizzydb;

USE quizzydb;

'@
    [System.IO.File]::WriteAllText($outputFile, $initialSql, $utf8NoBomEncoding)

    Write-Host "[INFO] Starting SQL build...`n" -ForegroundColor Cyan

    $tablesOrder = @(
        "tblRoles",
        "tblUsers",
        "tblTopics",
        "tblQuiz",
        "tblQuestions",
        "tblOptions",
        "tblSubmissions",
        "tblErrorLogs"
    )

    function Append-Files {
        param (
            [Parameter(Mandatory = $true)]
            [string] $subFolder,

            [Parameter(Mandatory = $true)]
            [string[]] $fileNames,

            [string] $suffix = ""
        )

        $folderPath = Join-Path $dbDir $subFolder

        if (-not (Test-Path $folderPath)) {
            Write-Warning "[WARN] Folder '$subFolder' does not exist. Skipping..."
            return
        }

        foreach ($name in $fileNames) {
            $file = Join-Path -Path $folderPath -ChildPath "$name$suffix.sql"

            if (Test-Path $file) {
                Write-Host "[OK]    Adding $subFolder/$name$suffix.sql" -ForegroundColor Green
                Add-Content -Path $outputFile -Value "`n-- File: $subFolder/$name$suffix.sql`n"
                Get-Content $file | Add-Content $outputFile
            } else {
                Write-Warning "[WARN] File not found: $subFolder/$name$suffix.sql"
            }
        }
    }

    Append-Files -subFolder "tables"      -fileNames $tablesOrder
    Append-Files -subFolder "constraints" -fileNames $tablesOrder -suffix ".constraints"
    Append-Files -subFolder "indexes"     -fileNames $tablesOrder -suffix ".indexes"
    # Append-Files -subFolder "seeds"     -fileNames $tablesOrder -suffix ".seeds"

    foreach ($folder in @("functions", "procs", "events")) {
        $folderPath = Join-Path $dbDir $folder

        if (-not (Test-Path $folderPath)) {
            Write-Warning "[WARN] Folder '$folder' does not exist. Skipping..."
            continue
        }

        $files = Get-ChildItem -Path $folderPath -Filter '*.sql' | Sort-Object Name

        foreach ($file in $files) {
            Write-Host "[OK]    Adding $folder/$($file.Name)" -ForegroundColor Green
            Add-Content -Path $outputFile -Value "`n-- File: $folder/$($file.Name)`n"
            Get-Content $file.FullName | Add-Content $outputFile
        }
    }

    Write-Host "`nSQL build completed -> $outputFile`nExecute this file directly in MySQL Workbench." -ForegroundColor Cyan
}
catch {
    Write-Error ('An error occurred during SQL build: ' + $_.Exception.Message)
}
