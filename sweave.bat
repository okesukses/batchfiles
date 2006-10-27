@echo off
setlocal
ver | findstr XP >NUL

if "%1"=="" goto:help
if "%1"=="-h" goto:help
if "%1"=="--help" goto:help
if "%1"=="/?" goto:help
goto:continue
:help
echo Usage: sweave abc.Rnw
echo    or  sweave abc
echo switches:
echo    -t or --tex or     produce tex file and exit
echo    -p or --pdf or     produce pdf file and exit
echo    -n or --nobck.pdf  do not create .bck.pdf file but display pdf directly
echo This command 1. runs sweave producing a .tex file, 2. runs pdflatex
echo producing a pdf file and then 3. copies pdf file to unique file
echo name ending in .bck.pdf (because acrobat won't display two files with
echo same name at same time so if previous version of file were still on screen
echo it would cause program to hang there) and 4. displays file.
echo Switches can start with -- or -. They are case insensitive and only 
echo first letter of switch used:
echo e.g. 
echo    Run sweave, pdflatex, create backup pdf with unique name, display it
echo     sweave mydoc.Rnw
echo
echo    Same
echo     sweave mydoc
echo
echo   Run sweave to create tex file.  Do not run pdflatex or display.
echo    sweave mydoc --tex
echo
echo   Run sweave and pdflatex creating pdf file.  Do not create backup
echo   nor display.
echo    sweave mydoc --pdf
echo
echo   Run sweave and pdflatex, do not create backup but display pdf directly.
echo    sweave mydoc --nobck
goto:eof
:continue

:: argument processing
:: - returns 'file' as file argument and 'switch' as switch argument

    :loop 
    (set arg=%~1) 
    shift 
    if not defined arg goto :cont 
    (set prefix1=%arg:~0,1%) 
    if "%prefix1%"=="-" goto:switch
    set file=%arg%
    goto:loop
    :switch
    :: remove dashes from switch and get first char
    set switch=%arg:-=%
    set switch=%switch:~0,1%
    goto:loop
    :cont

if errorlevel 1 echo Warning: This script has only been tested on Windows XP.
if exist "%file%.Rtex" set infile="%file%.Rtex"
if exist "%file%.Snw" set infile="%file%.Snw"
if exist "%file%.Rnw" set infile="%file%.Rnw"
if exist "%file%" set infile="%file%" 
set infileslash=%infile:\=/%
call Rcmd Sweave %infileslash%
:: echo on
if errorlevel 1 goto:eof
if /i "%switch%"=="t" goto:eof

:: echo %cd%
for %%a in ("%file%") do set base=%%~sdpna
if not exist "%base%.tex" goto:eof
for /f "delims=" %%a in ('dir %infile% "%base%.tex" /od/b ^| more +1'
) do set ext=%%~xa
if "%ext%"==".tex" (pdflatex "%base%.tex") else goto:eof
if errorlevel 1 goto:eof
if /i "%switch%"=="p" goto:eof

if not exist "%base%.pdf" goto:eof
for /f "delims=" %%a in ('dir "%base%.pdf" "%base%.tex" /od/b ^| more +1'
) do set ext=%%~xa
if not "%ext%"==".pdf" goto:eof
set pdffile=%base%.pdf
if /i "%switch%"=="n" start "" "%pdffile%" && goto:eof
set tmpfile=%date%-%time%
set tmpfile=%tmpfile: =-%
set tmpfile=%tmpfile::=.%
set tmpfile=%tmpfile:/=.%
set tmpfile=%base%-%tmpfile%.bck.pdf
copy "%pdffile%" "%tmpfile%"
start "" "%tmpfile%"
echo *** delete *.bck.pdf files when done ***

endlocal



