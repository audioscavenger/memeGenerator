@echo OFF
pushd %~dp1
setlocal enabledelayedexpansion

:top
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set author=ScavengeR
set version=2.0.1
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: * TODO
::     1.  set Point_Size=f(SIZE)
:: 2.0 enhancements and bug-fixes:
::     1.  pngquant integration
:: 1.0 enhancements and bug-fixes:
::     4.  complete menu ovrehaul
::     5.  complete history overhaul
::     6.  complete prompt options overhaul with dependent options
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:init
::replace S:\wintools\multimedia by your path with magick, pngquant and optipng
set "PATH=%PATH%;S:\wintools\PortableApps\Magick;S:\wintools\multimedia"
set TITLE=meme Generator %version% by @%author%
set filename=%~n1
set history=%~n1.ini
set memeNum=1

:start
where magick >NUL || (echo ERROR: magick not found in your PATH. Download 
where pngquant >NUL || (echo ERROR: pngquant not found in your PATH."
call :set_colors

:defaults
set labelWidth=30
set output_Extension=jpg
set jpegQuality=75

set Blur_Background=n
set Blur_Level=1

set Radial_Blur=n
set rsigma=10

set Sharpen_Background=n
set sharpen=6

set Point_Size=50

set GRAVITIES=NorthWest %c%North%END% NorthEast West Center East SouthWest %c%South%END% SouthEast
set Change_Default_Gravities=n
set gTOP=north
set gBOTTOM=south

set OPTIONS=
set keep_Options=y
for %%m in ("%~dpn1-meme-*.%output_Extension%") do set /A memeNum+=1

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:menu
echo.

call :getSIZE %1
call :getHisto && call :promptOption keep_Options
if /i "%keep_Options%" EQU "y" goto :menu_text

call :promptOption output_Extension
::You can certainly combine blur with sharpen and any other filter you can think of for crazy results
call :promptOption Blur_Background
call :promptOption Blur_Level Blur_Background
call :promptOption Radial_Blur
call :promptOption rsigma Radial_Blur
call :promptOption Sharpen_Background

REM call :calculatePoint_Size
call :promptOption Point_Size

echo -- chose both Gravities among: %GRAVITIES%
call :promptOption Change_Default_Gravities
call :promptOption gTOP Change_Default_Gravities
call :promptOption gBOTTOM Change_Default_Gravities

:menu_text
call :promptOption annotateTOP noshift
call :promptOption annotateBOTTOM noshift

:main
del /f /q %history%
call :putHisto version output_Extension Blur_Background Blur_Level Radial_Blur rsigma Sharpen_Background sharpen Point_Size Change_Default_Gravities gTOP annotateTOP gBOTTOM annotateBOTTOM
call :setOPTIONS
call :CONVERT %1 "%~n1-meme-%memeNum%.%output_Extension%"
call :OPTIMIZE "%~n1-meme-%memeNum%.%output_Extension%"

::launch the file in your default viewer
start "" "%~dpn1-meme-%memeNum%.%output_Extension%"
set /A memeNum+=1
goto :menu
goto :end
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:promptOption option [dependent|noshift]
IF NOT "%2"=="" (call set dependent=%%%2%%) ELSE set dependent=y
IF /I "%dependent%"=="n" exit /b 0

call set label=%1? 
set label=%label:_= %                                     
call set labelOption=%%%1%%
call :len labelOption || set /A labelLeft=labelWidth-!ERRORLEVEL!-2
IF /I "%2"=="noshift" set /A labelLeft=labelWidth-2

set label=!label:~0,%labelLeft%!
set /p %1=%label% [%y%%labelOption%%END%] 
goto :EOF

:setOPTIONS
:: set the blur level here: 0x1 to 0x6 heavy blur to 0x30 iPhone blur / single digit for soft blur http://www.imagemagick.org/script/command-line-options.php#blur
if /i "%Blur_Background%" EQU "y"    set OPTIONS=%OPTIONS% -blur 0x%Blur_Level%

:: rsigma: 5-30
if /i "%Radial_Blur%" EQU "y"        set OPTIONS=%OPTIONS% -virtual-pixel edge -distort DePolar -1 -morphology Convolve Blur:0x%rsigma%,90 -virtual-pixel HorizontalTile -background black -distort Polar -1

:: sharpen level 0x6 gives an old school, badass look to the image http://www.imagemagick.org/script/command-line-options.php#sharpen
:: -adaptive-sharpen 4x6 = Adjust sharpening so that it is restricted to close to image edges as defined by edge detection.
if /i "%Sharpen_Background%" EQU "y" set OPTIONS=%OPTIONS% -sharpen %sharpen%

set QUALITY=-quality %jpegQuality%

goto :EOF


:getSIZE
:: IT WORKS!!!! but you have to define the size of the layers. Both commands are equivalent:
rem FOR /F "tokens=* USEBACKQ" %%s IN (`magick getSIZE -format "%%[fx:w]x%%[fx:h]" %1`) DO SET SIZE=%%s
FOR /F "tokens=* USEBACKQ" %%s IN (`magick convert  -ping %1 -format "%%wx%%h" info:`) DO SET SIZE=%%s
echo SIZE=%SIZE%
goto :EOF

:CONVERT input output
magick convert %1 %OPTIONS% ^
-gravity %gTOP% ^
( -size %SIZE% xc:none -font Impact -pointsize %Point_Size% -stroke rgba(0,0,0,1) -strokewidth 7 -annotate 0 "%annotateTOP%" -blur 0x1  ) -composite ^
-font Impact -pointsize %Point_Size% -fill rgba(255,255,255,1) -stroke none      -annotate 0 "%annotateTOP%" ^
-gravity %gBOTTOM% ^
( -size %SIZE% xc:none -font Impact -pointsize %Point_Size% -stroke rgba(0,0,0,1) -strokewidth 7 -annotate 0 "%annotateBOTTOM%" -blur 0x1  ) ^
-font Impact -pointsize %Point_Size% -fill rgba(255,255,255,1) -stroke none      -annotate 0 "%annotateBOTTOM%" -composite ^
%QUALITY% ^
%2

goto :EOF

:OPTIMIZE input
::quick png optimization of the output
if /I "%~x1"=="png" call :PNGQUANT %1 inplace
goto :EOF

:PNGQUANT
pngquant.exe --verbose --force --quality 10-60 --ext png -- %1 >NUL && optipng.exe -v "%~dpn1.png" >NUL
goto :EOF


:getHisto [tag]
IF EXIST %history% (
  IF "%1"=="" (for /f "tokens=*" %%t in (%history%) do set "%%t") ELSE for /f "tokens=*" %%t in ('findstr /I /B %1 %history%') do set "%%t"
) ELSE exit /b 1
goto :EOF

:putHisto tag[s]
for %%t in (%*) DO (call echo %%t=%%%%t%%)>>%history%
goto :EOF

:set_colors
set colorCompatibleVersions=-8-8.1-10-2016-2019-
IF DEFINED WindowsVersion IF "%colorCompatibleVersions:-!WindowsVersion!-=_%"=="%colorCompatibleVersions%" exit /b 1

set END=[0m
set HIGH=[1m
set Underline=[4m
set REVERSE=[7m

REM echo [101;93m NORMAL FOREGROUND COLORS [0m
set k=[30m
set r=[31m
set g=[32m
set y=[33m
set b=[34m
set m=[35m
set c=[36m
set w=[37m

REM echo [101;93m NORMAL BACKGROUND COLORS [0m
set RK=[40m
set RR=[41m
set RG=[42m
set RY=[43m
set RB=[44m
set RM=[45m
set RC=[46m
set RW=[47m

goto :EOF
:: BUG: some space are needed after :set_colors


:error function msg
echo.%r%
echo ==============================================================
echo %HIGH%%r%  ERROR:%END%%r% %*
IF /I [%2]==[magick] echo %y%Download %2 from https://imagemagick.org/download/binaries/ImageMagick-7.0.9-21-portable-Q16-x64.zip %r% 1>&2
IF /I [%2]==[optipng] echo %y%Download %2 from http://prdownloads.sourceforge.net/optipng/optipng-0.7.7-win32.zip?download %r% 1>&2
IF /I [%2]==[pngquant] echo %y%Download %2 from https://pngquant.org/pngquant-windows.zip %r% 1>&2
IF /I [%2]==[powershell] echo %y%Consider installing Management Framework at http://aka.ms/wmf5download %r% 1>&2
echo ==============================================================
echo.%END%
IF NOT DEFINED AUTOMATED pause
exit
goto :EOF

REM :len var
:len
:: https://stackoverflow.com/questions/5837418/how-do-you-get-the-string-length-in-a-batch-file/8566001#8566001
call echo]%%%1%%>%TMP%\%~n0.tmp & FOR %%? IN (%TMP%\%~n0.tmp) DO SET /A strlength=%%~z? - 3
exit /b %strlength%


:end
rem pause
