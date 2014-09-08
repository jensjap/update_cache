:: update_cache.cmd			02/10/2014
:: Jens Jap

:: change log
:: 02/17/2014 - jj - look for anything with pattern 'project*'
::

@ECHO OFF
cls

REM Parameter1 specifies the hostname of the target FTP server
REM Parameter2 specifies the ftp username
REM Parameter3 specifies the ftp password

setlocal enableextensions
setlocal enabledelayedexpansion


:: ======================================== Main
call :Initialize %1 %2 %3
call :ParameterVerification
if not "%error_list%"=="" (
  goto :Error
)
call :TabulaRasa
call :GetRemoteFileList
call :MarkFilesForArchivingOnRemote
call :GetMarkedFilesAndList
call :ArchiveMarkedFiles
call :TabulaRasa
if not "%error_list%"=="" (
  goto :Error
)
goto :End


:: ======================================== Initialize
:Initialize
set FTP_SERVER=%1
set USER=%2
set PWD=%3
set CWD=%CD%
set PAT=project*
set FILE_LIST=%CWD%\file.list
set ARCHIVE_FILE_LIST=%CWD%\archive_file.list
set ERROR_LOG=%CWD%\log\update_cache.err
set LOG=%CWD%\log\update_cache.log
set FTP_LOG=%CWD%\log\ftp.log
:: Gets directory listing
set SCRIPT1=%CWD%\script1.ftp
:: Move files into 'prep' folder. This will ensure
:: files are not locked by other process
set SCRIPT2=%CWD%\script2.ftp
:: Gets marked files
set SCRIPT3=%CWD%\script3.ftp
:: Archives marked files
set SCRIPT4=%CWD%\script4.ftp
set SIMPLE_DATE=%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%
set error_list=
echo "=== Program Start: %DATE% %TIME% ===">> "%LOG%"
echo "=== FTP Start: %DATE% %TIME% ===">> "%FTP_LOG%"
goto :EOF


:: ======================================== Subroutines
:ParameterVerification
if "%FTP_SERVER%"=="" (
  set error_list=%error_list% 1
) else (
  echo "FTP Server: %FTP_SERVER%"
  echo "FTP Server: %FTP_SERVER%">> "%LOG%"
)
if "%USER%"=="" (
  set error_list=%error_list% 2
) else (
  echo "FTP user name: %USER%"
  echo "FTP user name: %USER%">> "%LOG%"
)
if "%PWD%"=="" (
  set error_list=%error_list% 3
) else (
  echo "FTP password: *********"
  echo "FTP password: *********">> "%LOG%"
)
goto :EOF

:TabulaRasa
if exist "%FILE_LIST%" (
  echo "Deleting old file at %FILE_LIST%"
  echo "Deleting old file at %FILE_LIST%">> "%LOG%"
  del "%FILE_LIST%">> "%LOG%"
)
if exist "%ARCHIVE_FILE_LIST%" (
  echo "Deleting old file at %ARCHIVE_FILE_LIST%"
  echo "Deleting old file at %ARCHIVE_FILE_LIST%">> "%LOG%"
  del "%ARCHIVE_FILE_LIST%">> "%LOG%"
)
if exist "%SCRIPT1%" (
  echo "Deleting old file at %SCRIPT1%"
  echo "Deleting old file at %SCRIPT1%">> "%LOG%"
  del "%SCRIPT1%">> "%LOG%"
)
if exist "%SCRIPT2%" (
  echo "Deleting old file at %SCRIPT2%"
  echo "Deleting old file at %SCRIPT2%">> "%LOG%"
  del "%SCRIPT2%">> "%LOG%"
)
if exist "%SCRIPT3%" (
  echo "Deleting old file at %SCRIPT3%"
  echo "Deleting old file at %SCRIPT3%">> "%LOG%"
  del "%SCRIPT3%">> "%LOG%"
)
if exist "%SCRIPT4%" (
  echo "Deleting old file at %SCRIPT4%"
  echo "Deleting old file at %SCRIPT4%">> "%LOG%"
  del "%SCRIPT4%">> "%LOG%"
)
if exist "%FILE_LIST%" (
  set error_list=%error_list% 10
)
if exist "%SCRIPT1%" (
  set error_list=%error_list% 11
)
if exist "%SCRIPT2%" (
  set error_list=%error_list% 12
)
if exist "%SCRIPT3%" (
  set error_list=%error_list% 13
)
if exist "%SCRIPT4%" (
  set error_list=%error_list% 14
)
goto :EOF

:GetRemoteFileList
call :BuildFTPScriptOne
echo "Execute first FTP script"
echo "Execute first FTP script">> "%LOG%"
ftp -s:"%SCRIPT1%">> "%FTP_LOG%"
goto :EOF

:MarkFilesForArchivingOnRemote
call :BuildFTPScriptTwo
echo "Execute second FTP script"
echo "Execute second FTP script">> "%LOG%"
ftp -s:"%SCRIPT2%">> "%FTP_LOG%"
goto :EOF

:GetMarkedFilesAndList
call :BuildFTPScriptThree
echo "Execute third FTP script"
echo "Execute third FTP script">> "%LOG%"
ftp -s:"%SCRIPT3%">> "%FTP_LOG%"
goto :EOF

:ArchiveMarkedFiles
call :BuildFTPScriptFour
echo "Execute fourth FTP script"
echo "Execute fourth FTP script">> "%LOG%"
ftp -s:"%SCRIPT4%">> "%FTP_LOG%"
goto :EOF

:BuildFTPScriptOne
echo "Building first FTP script. Gets remote directory listing"
echo "Building first FTP script. Gets remote directory listing">> "%LOG%"
echo debug> "%SCRIPT1%"
echo prompt>> "%SCRIPT1%"
echo open %FTP_SERVER%>> "%SCRIPT1%"
echo %USER%>> "%SCRIPT1%"
echo %PWD%>> "%SCRIPT1%"
echo ls "%PAT%" "%FILE_LIST%">> "%SCRIPT1%"
echo bye>> "%SCRIPT1%"
goto :EOF

:BuildFTPScriptTwo
echo "Building second FTP script. Move files into 'prep' folder on remote"
echo "Building second FTP script. Move files into 'prep' folder on remote">> "%LOG%"
echo debug> "%SCRIPT2%"
echo prompt>> "%SCRIPT2%"
echo open %FTP_SERVER%>> "%SCRIPT2%"
echo %USER%>> "%SCRIPT2%"
echo %PWD%>> "%SCRIPT2%"
echo mkdir prep>> "%SCRIPT2%"
for /f "tokens=*" %%a in (%FILE_LIST%) do (
  echo rename "%%a" prep/"%%a">> "%SCRIPT2%"
)
echo bye>> "%SCRIPT2%"
goto :EOF

:BuildFTPScriptThree
echo "Building third FTP script. Generate list of marked files and download"
echo "Building third FTP script. Generate list of marked files and download">> "%LOG%"
echo debug> "%SCRIPT3%"
echo prompt>> "%SCRIPT3%"
echo open %FTP_SERVER%>> "%SCRIPT3%"
echo %USER%>> "%SCRIPT3%"
echo %PWD%>> "%SCRIPT3%"
echo ls prep\* "%ARCHIVE_FILE_LIST%">> "%SCRIPT3%"
echo mget prep\*>> "%SCRIPT3%"
echo bye>> "%SCRIPT3%"
goto :EOF

:BuildFTPScriptFour
echo "Building fourth FTP script. Move files into 'archive' folder and timestamp"
echo "Building fourth FTP script. Move files into 'archive' folder and timestamp">> "%LOG%"
echo debug> "%SCRIPT4%"
echo prompt>> "%SCRIPT4%"
echo open %FTP_SERVER%>> "%SCRIPT4%"
echo %USER%>> "%SCRIPT4%"
echo %PWD%>> "%SCRIPT4%"
echo mkdir archive>> "%SCRIPT4%"
for /f "delims=/ tokens=2" %%a in (%ARCHIVE_FILE_LIST%) do (
  echo rename prep/"%%a" archive/"%SIMPLE_DATE%_%%a">> "%SCRIPT4%"
)
echo bye>> "%SCRIPT4%"
goto :EOF


:: ======================================== Error Handling
:Error
echo "=== Begin Error Report %DATE% %TIME% ==="
echo "=== Begin Error Report %DATE% %TIME% ===">> "%ERROR_LOG%"
for %%a in (%error_list%) do (
  call :Error_Message %%a
)
echo "=== Error Report END: %DATE% %TIME% ===">> "%ERROR_LOG%"
goto :End

:Error_Message
set error_number=%1
if "%error_number%"=="1" (
  echo "No FTP server address provided"
  echo "No FTP server address provided">> "%ERROR_LOG%"
)
if "%error_number%"=="2" (
  echo "No FTP user name provided"
  echo "No FTP user name provided">> "%ERROR_LOG%"
)
if "%error_number%"=="3" (
  echo "No FTP password provided"
  echo "No FTP password provided">> "%ERROR_LOG%"
)
if "%error_number%"=="10" (
  echo "Unable to delete file.list"
  echo "Unable to delete file.list">> "%ERROR_LOG%"
)
if "%error_number%"=="11" (
  echo "Unable to delete script1.ftp"
  echo "Unable to delete script1.ftp">> "%ERROR_LOG%"
)
if "%error_number%"=="12" (
  echo "Unable to delete script2.ftp"
  echo "Unable to delete script2.ftp">> "%ERROR_LOG%"
)
if "%error_number%"=="13" (
  echo "Unable to delete script3.ftp"
  echo "Unable to delete script3.ftp">> "%ERROR_LOG%"
)
if "%error_number%"=="14" (
  echo "Unable to delete script4.ftp"
  echo "Unable to delete script4.ftp">> "%ERROR_LOG%"
)
goto :EOF


:: ======================================== END
:End
echo "=== Program END: %DATE% %TIME% ===">> "%LOG%"
echo "=== FTP END: %DATE% %TIME% ===">> "%FTP_LOG%"
endlocal
