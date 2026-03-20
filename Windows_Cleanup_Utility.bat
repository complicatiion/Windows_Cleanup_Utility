@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Windows Junk Data and Temp Cleanup Utility

color 0B
chcp 65001 >nul

:: Check for administrator rights
net session >nul 2>&1
if %errorlevel%==0 (
  set "ISADMIN=1"
) else (
  set "ISADMIN=0"
)

:: Report folder on desktop
set "REPORTROOT=%USERPROFILE%\Desktop\CleanupReports"
if not exist "%REPORTROOT%" md "%REPORTROOT%" >nul 2>&1

:MAIN
cls
echo ============================================================
echo Windows Junk Data and Temp Cleanup Utility by complicatiion
echo ============================================================
echo.
if "%ISADMIN%"=="1" (
  echo Admin status: YES
) else (
  echo Admin status: NO
)
echo Report folder: %REPORTROOT%
echo.
echo [1] Quick scan of common junk locations
echo [2] Detailed scan with sizes
echo [3] Clean user temp
echo [4] Clean Windows temp                    [Admin]
echo [5] Clean Prefetch                        [Admin]
echo [6] Empty recycle bin
echo [7] Clean Windows Update cache            [Admin]
echo [8] Flush DNS cache
echo [9] Clean thumbnail cache
echo [A] Run all standard cleanups
echo [B] Generate report
echo [C] Report folder oeffnen
echo [0] Exit
echo.
set /p CHO="Selection: "

if "%CHO%"=="1" goto :QUICKSCAN
if "%CHO%"=="2" goto :DETAILSCAN
if "%CHO%"=="3" goto :CLEANTEMPUSER
if "%CHO%"=="4" goto :CLEANTEMPWIN
if "%CHO%"=="5" goto :CLEANPREFETCH
if "%CHO%"=="6" goto :CLEANRECYCLE
if "%CHO%"=="7" goto :CLEANWU
if "%CHO%"=="8" goto :CLEANDNS
if "%CHO%"=="9" goto :CLEANTHUMBS
if /I "%CHO%"=="A" goto :CLEANALL
if /I "%CHO%"=="B" goto :REPORT
if /I "%CHO%"=="C" goto :OPENFOLDER
if "%CHO%"=="0" goto :END
goto :MAIN

:QUICKSCAN
cls
echo ============================================================
echo Quick scan of common junk locations
echo ============================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$paths=@(); $paths += [pscustomobject]@{Name='User Temp';Path=$env:TEMP}; $paths += [pscustomobject]@{Name='Windows Temp';Path=$env:windir + '\Temp'}; $paths += [pscustomobject]@{Name='Prefetch';Path=$env:windir + '\Prefetch'}; $paths += [pscustomobject]@{Name='SoftwareDistribution Download';Path=$env:windir + '\SoftwareDistribution\Download'}; $paths += [pscustomobject]@{Name='Thumbnail Cache';Path=$env:LOCALAPPDATA + '\Microsoft\Windows\Explorer'}; foreach($p in $paths){ $size=0; $count=0; if(Test-Path $p.Path){ try { $items=Get-ChildItem $p.Path -Force -Recurse -ErrorAction SilentlyContinue; $count=@($items).Count; $size=($items | Measure-Object Length -Sum).Sum } catch {} }; [pscustomobject]@{Area=$p.Name; Pfad=$p.Path; Files=$count; SizeGB=[math]::Round(($size/1GB),2)} } | Format-Table -AutoSize"
echo.
pause
goto :MAIN

:DETAILSCAN
cls
echo ============================================================
echo Detailed scan
echo ============================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$areas=@(); $areas += [pscustomobject]@{Name='User Temp';Path=$env:TEMP}; $areas += [pscustomobject]@{Name='Windows Temp';Path=$env:windir + '\Temp'}; $areas += [pscustomobject]@{Name='Prefetch';Path=$env:windir + '\Prefetch'}; $areas += [pscustomobject]@{Name='SoftwareDistribution Download';Path=$env:windir + '\SoftwareDistribution\Download'}; $areas += [pscustomobject]@{Name='Thumbnail Cache';Path=$env:LOCALAPPDATA + '\Microsoft\Windows\Explorer'}; $areas += [pscustomobject]@{Name='CrashDumps';Path=$env:LOCALAPPDATA + '\CrashDumps'}; $areas += [pscustomobject]@{Name='Windows Error Reporting';Path=$env:PROGRAMDATA + '\Microsoft\Windows\WER'}; foreach($a in $areas){ $size=0; $count=0; $latest=$null; if(Test-Path $a.Path){ try { $items=Get-ChildItem $a.Path -Force -Recurse -ErrorAction SilentlyContinue; $count=@($items).Count; $size=($items | Measure-Object Length -Sum).Sum; $latest=($items | Sort-Object LastWriteTime -Descending | Select-Object -First 1 -ExpandProperty LastWriteTime) } catch {} }; [pscustomobject]@{Area=$a.Name; Pfad=$a.Path; Files=$count; SizeGB=[math]::Round(($size/1GB),2); LastChange=$latest} } | Sort-Object SizeGB -Descending | Format-Table -AutoSize"
echo.
pause
goto :MAIN

:CLEANTEMPUSER
cls
echo ============================================================
echo Clean user temp
echo ============================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$p=$env:TEMP; if(Test-Path $p){ Get-ChildItem $p -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue; Write-Host ('Cleaned: ' + $p) } else { Write-Host 'Path not found.' }"
echo.
pause
goto :MAIN

:CLEANTEMPWIN
if not "%ISADMIN%"=="1" goto :NEEDADMIN
cls
echo ============================================================
echo Clean Windows temp
echo ============================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$p=$env:windir + '\Temp'; if(Test-Path $p){ Get-ChildItem $p -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue; Write-Host ('Cleaned: ' + $p) } else { Write-Host 'Path not found.' }"
echo.
pause
goto :MAIN

:CLEANPREFETCH
if not "%ISADMIN%"=="1" goto :NEEDADMIN
cls
echo ============================================================
echo Clean Prefetch
echo ============================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$p=$env:windir + '\Prefetch'; if(Test-Path $p){ Get-ChildItem $p -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue; Write-Host ('Cleaned: ' + $p) } else { Write-Host 'Path not found.' }"
echo.
pause
goto :MAIN

:CLEANRECYCLE
cls
echo ============================================================
echo Empty recycle bin
echo ============================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { Clear-RecycleBin -Force -ErrorAction Stop; Write-Host 'Recycle bin was emptied.' } catch { Write-Host 'Recycle bin could not be fully emptied or is already empty.' }"
echo.
pause
goto :MAIN

:CLEANWU
if not "%ISADMIN%"=="1" goto :NEEDADMIN
cls
echo ============================================================
echo Clean Windows Update cache
echo ============================================================
echo.
echo Stopping Windows Update service briefly...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
powershell -NoProfile -ExecutionPolicy Bypass -Command "$p=$env:windir + '\SoftwareDistribution\Download'; if(Test-Path $p){ Get-ChildItem $p -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue; Write-Host ('Cleaned: ' + $p) } else { Write-Host 'Path not found.' }"
echo Starting services again...
net start bits >nul 2>&1
net start wuauserv >nul 2>&1
echo.
pause
goto :MAIN

:CLEANDNS
cls
echo ============================================================
echo Flush DNS cache
echo ============================================================
echo.
ipconfig /flushdns
echo.
pause
goto :MAIN

:CLEANTHUMBS
cls
echo ============================================================
echo Clean thumbnail cache
echo ============================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$p=$env:LOCALAPPDATA + '\Microsoft\Windows\Explorer'; if(Test-Path $p){ Get-ChildItem $p -Filter 'thumbcache*' -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue; Write-Host ('Cleaned: ' + $p) } else { Write-Host 'Path not found.' }"
echo.
pause
goto :MAIN

:CLEANALL
cls
echo ============================================================
echo All standard cleanups
echo ============================================================
echo.
echo [1/6] Benutzer-Temp
powershell -NoProfile -ExecutionPolicy Bypass -Command "$p=$env:TEMP; if(Test-Path $p){ Get-ChildItem $p -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue; Write-Host ('Cleaned: ' + $p) }"
echo.
echo [2/6] Windows-Temp
if "%ISADMIN%"=="1" (
  powershell -NoProfile -ExecutionPolicy Bypass -Command "$p=$env:windir + '\Temp'; if(Test-Path $p){ Get-ChildItem $p -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue; Write-Host ('Cleaned: ' + $p) }"
) else (
  echo Skipped - admin rights missing.
)
echo.
echo [3/6] Prefetch
if "%ISADMIN%"=="1" (
  powershell -NoProfile -ExecutionPolicy Bypass -Command "$p=$env:windir + '\Prefetch'; if(Test-Path $p){ Get-ChildItem $p -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue; Write-Host ('Cleaned: ' + $p) }"
) else (
  echo Skipped - admin rights missing.
)
echo.
echo [4/6] Papierkorb
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { Clear-RecycleBin -Force -ErrorAction Stop; Write-Host 'Recycle bin was emptied.' } catch { Write-Host 'Recycle bin could not be fully emptied or is already empty.' }"
echo.
echo [5/6] DNS-Cache
ipconfig /flushdns
echo.
echo [6/6] Thumbnail-Cache
powershell -NoProfile -ExecutionPolicy Bypass -Command "$p=$env:LOCALAPPDATA + '\Microsoft\Windows\Explorer'; if(Test-Path $p){ Get-ChildItem $p -Filter 'thumbcache*' -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue; Write-Host ('Cleaned: ' + $p) }"
echo.
if "%ISADMIN%"=="1" (
  echo Extra: Windows Update cache
  net stop wuauserv >nul 2>&1
  net stop bits >nul 2>&1
  powershell -NoProfile -ExecutionPolicy Bypass -Command "$p=$env:windir + '\SoftwareDistribution\Download'; if(Test-Path $p){ Get-ChildItem $p -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue; Write-Host ('Cleaned: ' + $p) }"
  net start bits >nul 2>&1
  net start wuauserv >nul 2>&1
)
echo.
pause
goto :MAIN

:REPORT
cls
echo [*] Creating report...
echo.
for /f %%I in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HH-mm-ss"') do set STAMP=%%I
set "OUTFILE=%REPORTROOT%\Cleanup_Report_%STAMP%.txt"

(
echo ============================================================
echo Windows Junk Data and Temp Cleanup Report
echo ============================================================
echo Date: %DATE% %TIME%
echo Computer: %COMPUTERNAME%
echo User: %USERNAME%
echo ============================================================
echo.

echo [1] Quick scan
powershell -NoProfile -ExecutionPolicy Bypass -Command "$paths=@(); $paths += [pscustomobject]@{Name='User Temp';Path=$env:TEMP}; $paths += [pscustomobject]@{Name='Windows Temp';Path=$env:windir + '\Temp'}; $paths += [pscustomobject]@{Name='Prefetch';Path=$env:windir + '\Prefetch'}; $paths += [pscustomobject]@{Name='SoftwareDistribution Download';Path=$env:windir + '\SoftwareDistribution\Download'}; $paths += [pscustomobject]@{Name='Thumbnail Cache';Path=$env:LOCALAPPDATA + '\Microsoft\Windows\Explorer'}; foreach($p in $paths){ $size=0; $count=0; if(Test-Path $p.Path){ try { $items=Get-ChildItem $p.Path -Force -Recurse -ErrorAction SilentlyContinue; $count=@($items).Count; $size=($items | Measure-Object Length -Sum).Sum } catch {} }; [pscustomobject]@{Area=$p.Name; Pfad=$p.Path; Files=$count; SizeGB=[math]::Round(($size/1GB),2)} } | Format-Table -AutoSize"
echo.

echo [2] Detailed scan
powershell -NoProfile -ExecutionPolicy Bypass -Command "$areas=@(); $areas += [pscustomobject]@{Name='User Temp';Path=$env:TEMP}; $areas += [pscustomobject]@{Name='Windows Temp';Path=$env:windir + '\Temp'}; $areas += [pscustomobject]@{Name='Prefetch';Path=$env:windir + '\Prefetch'}; $areas += [pscustomobject]@{Name='SoftwareDistribution Download';Path=$env:windir + '\SoftwareDistribution\Download'}; $areas += [pscustomobject]@{Name='Thumbnail Cache';Path=$env:LOCALAPPDATA + '\Microsoft\Windows\Explorer'}; $areas += [pscustomobject]@{Name='CrashDumps';Path=$env:LOCALAPPDATA + '\CrashDumps'}; $areas += [pscustomobject]@{Name='Windows Error Reporting';Path=$env:PROGRAMDATA + '\Microsoft\Windows\WER'}; foreach($a in $areas){ $size=0; $count=0; $latest=$null; if(Test-Path $a.Path){ try { $items=Get-ChildItem $a.Path -Force -Recurse -ErrorAction SilentlyContinue; $count=@($items).Count; $size=($items | Measure-Object Length -Sum).Sum; $latest=($items | Sort-Object LastWriteTime -Descending | Select-Object -First 1 -ExpandProperty LastWriteTime) } catch {} }; [pscustomobject]@{Area=$a.Name; Pfad=$a.Path; Files=$count; SizeGB=[math]::Round(($size/1GB),2); LastChange=$latest} } | Sort-Object SizeGB -Descending | Format-Table -AutoSize"
echo.

echo [3] Disk status
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | ForEach-Object { $size=[math]::Round($_.Size/1GB,2); $free=[math]::Round($_.FreeSpace/1GB,2); $used=[math]::Round($size-$free,2); $pct=if($_.Size -gt 0){[math]::Round((($_.Size-$_.FreeSpace)/$_.Size)*100,1)}else{0}; [pscustomobject]@{Drive=$_.DeviceID; Label=$_.VolumeName; SizeGB=$size; UsedGB=$used; FreeGB=$free; UsedPercent=$pct} } | Format-Table -AutoSize"
echo.
) > "%OUTFILE%" 2>&1

echo Report created:
echo %OUTFILE%
echo.
pause
goto :MAIN

:OPENFOLDER
start "" explorer.exe "%REPORTROOT%"
goto :MAIN

:NEEDADMIN
cls
echo Administrator rights are required for this action.
echo.
pause
goto :MAIN

:END
endlocal
exit /b
