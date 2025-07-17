try {
    $rootDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
    $outputFile = Join-Path $rootDir "output.sql"
    $dbDir = Join-Path $rootDir "db"

$utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText($outputFile, @"
CREATE DATABASE IF NOT EXISTS quizzydb;

USE quizzydb;

"@, $utf8NoBomEncoding)

    Write-Host "🔧 Starting SQL build...`n" -ForegroundColor Cyan

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
            [string]$subFolder,
            [string[]]$fileNames,
            [string]$suffix = ""
        )

        $folderPath = Join-Path $dbDir $subFolder
        if (-Not (Test-Path $folderPath)) {
            Write-Warning "⚠ Folder '$subFolder' does not exist. Skipping..."
            return
        }

        foreach ($name in $fileNames) {
            $file = Join-Path -Path $folderPath -ChildPath "$name$suffix.sql"
            if (Test-Path $file) {
                Write-Host "✅ Adding $subFolder/$name$suffix.sql" -ForegroundColor Green
                Add-Content -Path $outputFile -Value "-- File: $subFolder/$name$suffix.sql"
                Get-Content $file | Add-Content $outputFile
                Add-Content -Path $outputFile -Value "`n"
            } else {
                Write-Warning "⚠ File not found: $subFolder/$name$suffix.sql"
            }
        }
    }

    Append-Files -subFolder "tables" -fileNames $tablesOrder
    Append-Files -subFolder "constraints" -fileNames $tablesOrder -suffix ".constraints"
    Append-Files -subFolder "indexes" -fileNames $tablesOrder -suffix ".indexes"
    Append-Files -subFolder "seeds" -fileNames $tablesOrder -suffix ".seeds"

    foreach ($folder in "functions", "procs", "events") {
        $folderPath = Join-Path $dbDir $folder
        if (-Not (Test-Path $folderPath)) {
            Write-Warning "⚠ Folder '$folder' does not exist. Skipping..."
            continue
        }

        $files = Get-ChildItem -Path $folderPath -Filter *.sql | Sort-Object Name
        foreach ($file in $files) {
            Write-Host "✅ Adding $folder/$($file.Name)" -ForegroundColor Green
            Add-Content -Path $outputFile -Value "-- File: $folder/$($file.Name)"
            Get-Content $file.FullName | Add-Content $outputFile
            Add-Content -Path $outputFile -Value "`n"
        }
    }

    Write-Host "`n🎉 SQL build completed -> $outputFile`n🛢️ Execute this file directly in MySQL Workbench" -ForegroundColor Cyan
}
catch {
    Write-Error "❌ An error occurred during SQL build: $_"
}
