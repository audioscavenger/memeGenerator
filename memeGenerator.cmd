@echo OFF
pushd %~dp1
setlocal enabledelayedexpansion

:top
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set author=ScavengeR
set version=1.9
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: * TODO
:: 1.0 enhancements and bug-fixes:
::     4.  complete menu ovrehaul
::     5.  complete history overhaul
::     6.  complete prompt options overhaul with dependent options
::     7.  added debug mode and text/background colors
::     8.  set Point_Size=f(SIZE)
::     9.  cosmetics + :logDEBUG
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

REM convert original.png -fuzz 10% -transparent white transparent.png
REM where the smaller the fuzz %, the closer to true white or conversely, the larger the %, the more variation from white is allowed to become transparent

REM magick aaa.png -background "rgba(255,255,0,0.5)" -flatten yellowBackTransp.png

:start
::replace S:\wintools\multimedia by your path with magick, pngquant and optipng
set DEBUG=true
set "PATH=%PATH%;S:\wintools\PortableApps\Magick;S:\wintools\multimedia"
set TITLE=meme Generator %version% by @%author%
set filename=%~n1
set history=%~n1.ini
call :set_colors

:defaults
:: guess next output file number
for %%m in ("%~dpn1-meme-*.%output_Extension%") do set /A memeNum+=1

set labelWidth=30
set output_Extension=%~x1
set output_Extension=%output_Extension:.=%
set jpegQuality=50

set Blur_Background=n
set Blur_Level=1

set Radial_Blur=n
set rsigma=10

set Sharpen_Background=n
set sharpen=6

:: set Point_Size=150 is fairly large for 750x750
set Point_Size_Ratio=5
set Point_Size=150
set Color=255,255,255
set Scale=100
set backgroundAlpha=0.5

set GRAVITIES=NorthWest %c%North%END% NorthEast West Center East SouthWest %c%South%END% SouthEast
set Change_Default_Gravities=n
set gTOP=north
set gBOTTOM=south

set OPTIONS=
set keep_Options=y

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:menu
echo.
set backgroundColor=

call :getSIZE %1
call :calculatePoint_Size %width%
call :getHisto && call :promptOption keep_Options
if /i "%keep_Options%" EQU "y" goto :menu_text

call :promptOption output_Extension
::You can certainly combine blur with sharpen and any other filter you can think of for crazy results
call :promptOption Blur_Background
call :promptOption Blur_Level Blur_Background
call :promptOption Radial_Blur
call :promptOption rsigma Radial_Blur
call :promptOption Sharpen_Background

echo -- chose both Gravities among: %GRAVITIES%
call :promptOption Change_Default_Gravities
call :promptOption gTOP Change_Default_Gravities
call :promptOption gBOTTOM Change_Default_Gravities

:menu_text
call :promptOption Scale
call :promptOption Point_Size
call :promptOption Color
call :promptOption annotateTOP noshift
call :promptOption annotateBOTTOM noshift

:main
del /f /q %history%
call :putHisto version output_Extension jpegQuality Blur_Background Blur_Level Radial_Blur rsigma Sharpen_Background sharpen Point_Size Color Scale Change_Default_Gravities gTOP annotateTOP gBOTTOM annotateBOTTOM
:: :setOPTIONS will set memeNum, quality, point size etc
call :setOPTIONS %1
call :CONVERT %1 "%~dpn1-meme-%memeNum%-%Color%.%output_Extension%"
call :OPTIMIZE "%~dpn1-meme-%memeNum%-%Color%.%output_Extension%"

::launch the file in your default viewer
start "" "%~dpn1-meme-%memeNum%-%Color%.%output_Extension%"
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

:calculatePoint_Size
REM 100 for 772 is ok => ratio is 8
set /A Point_Size=width/8
goto :EOF

:setOPTIONS %1
:: set the blur level here: 0x1 to 0x6 heavy blur to 0x30 iPhone blur / single digit for soft blur http://www.imagemagick.org/script/command-line-options.php#blur
if /i "%Blur_Background%" EQU "y"    set OPTIONS=%OPTIONS% -blur 0x%Blur_Level%

:: rsigma: 5-30
if /i "%Radial_Blur%" EQU "y"        set OPTIONS=%OPTIONS% -virtual-pixel edge -distort DePolar -1 -morphology Convolve Blur:0x%rsigma%,90 -virtual-pixel HorizontalTile -background black -distort Polar -1

:: sharpen level 0x6 gives an old school, badass look to the image http://www.imagemagick.org/script/command-line-options.php#sharpen
:: -adaptive-sharpen 4x6 = Adjust sharpening so that it is restricted to close to image edges as defined by edge detection.
if /i "%Sharpen_Background%" EQU "y" set OPTIONS=%OPTIONS% -sharpen %sharpen%

set QUALITY=-quality %jpegQuality%

:: https://imagemagick.org/script/color.php
set backgroundColor=
IF NOT "%Color%"=="255,255,255" set "backgroundColor=-background rgba(%Color%,%backgroundAlpha%) -flatten"

:: https://www.imagemagick.org/Usage/resize/
set resize=
IF %Scale% NEQ 100 set "resize=-resize %Scale%%%"

set /A scaledPoint_Size=Point_Size*Scale/100

set memeNum=1
for /f %%f in ('dir /b %~dpn1-meme-*.*') DO (
  set /A memeNum+=1
)

call :logDEBUG output= %~n1-meme-%memeNum%-%Color%.%output_Extension%
goto :EOF


REM set name=%~dpn1
REM set name=Z:\Dropbox\Dropbox_lolo\Dropbox\Public\img\blog\EnlighterJS

::https://imgflip.com/i/21kiar
::http://www.weasy.net/2015/04/using-image-magick-convert-to-make-meme.html
::http://www.imagemagick.org/Usage/annotating/#anno_on
::http://www.imagemagick.org/Usage/blur/
::https://stackoverflow.com/questions/20858338/how-to-draw-text-and-shadow-it-in-imagemagick
REM magick -version

::blur the background:
REM magick convert %name%.png -font Impact -blur 0x1
::rotation clockwise degrees:-annotate 90

REM magick convert %name%.png -font Impact -pointsize 50 ^
REM -gravity north ^
REM -stroke black -strokewidth 7 -annotate 0 "EnlighterJS" -blur 0x2 ^
REM -fill white -stroke none      -annotate 0 "EnlighterJS" ^
REM -gravity south ^
REM -background none -stroke black -strokewidth 7  -annotate 0 "for WordPress" ^
REM -fill white -stroke none      -annotate 0 "for WordPress" ^
REM %~n1-meme-%memeNum%.%output_Extension%
REM pause

::ATTENTION bug if lines do not start with space!!!
::bug i get only a box shadow:
REM magick convert %name%.png -font Impact -pointsize 50 ^
  REM -fill white -stroke black ^
  REM label:EnlighterJS -trim ^
  REM ^( +clone -background black  -shadow 80x3 ^) +swap +repage ^
  REM -gravity north -composite ^
  REM %name%-meme-test.png
::

::https://stackoverflow.com/questions/20858338/how-to-draw-text-and-shadow-it-in-imagemagick
::http://www.imagemagick.org/Usage/windows/
REM magick convert -size 280x100 pattern:SMALLFISHSCALES ^
  REM ( xc:transparent -font Impact -pointsize 50 -fill black -draw "text 20,60 'EnlighterJS'" -blur 0x1 ) ^
  REM -geometry +2+2 -composite ^
  REM -font Impact -fill white -pointsize 50 -draw "text 20,60 'EnlighterJS'" ^
  REM %name%-meme-test.png
::

:getSIZE
:: IT WORKS!!!! but you have to define the size of the layers. Both commands are equivalent:
rem FOR /F "tokens=* USEBACKQ" %%s IN (`magick getSIZE -format "%%[fx:w]x%%[fx:h]" %1`) DO SET SIZE=%%s
FOR /F "tokens=* USEBACKQ" %%s IN (`magick convert  -ping %1 -format "%%wx%%h" info:`) DO SET SIZE=%%s
echo SIZE=%SIZE%

for /f "tokens=1,2" %%a in ("%SIZE:x= %") DO (
  set width=%%a
  set height=%%b
)
call :logDEBUG SIZE=%SIZE%
goto :EOF

:::::::::::::::::::::::::::::::::::::::::::::::::
::                    TESTS
:: https://www.imagemagick.org/Usage/distorts/
:: https://www.imagemagick.org/Usage/blur/
:: http://www.fmwconcepts.com/imagemagick/polarblur/index.php
:::::::::::::::::::::::::::::::::::::::::::::::::
rem -distort barrel "0 0 -0.5 1.5"
rem -virtual-pixel tile  -mattecolor DodgerBlue -distort BilinearReverse "0,0 20,60  90,0 70,63  0,90 5,83  90,90 85,88"

rem radial blur: takes too long
rem magick convert %1 %OPTIONS% ^
rem -virtual-pixel Black ^
rem -set option:distort:scale 4   -distort DePolar -1 ^
rem -virtual-pixel Edge   -motion-blur 0x28-90 ^
rem -virtual-pixel HorizontalTile -background Black ^
rem -set option:distort:scale .25 -distort Polar -1 ^
rem %QUALITY% %~n1-meme-%memeNum%.%output_Extension%

rem Barrel Distortion like old Fallout TV screen
rem magick convert %1 %OPTIONS% ^
rem -virtual-pixel gray -distort Barrel "0.2 0.0 0.0 1.5" ^
rem %QUALITY% %~n1-meme-%memeNum%.%output_Extension%
rem %~dpn1-meme-%memeNum%.%output_Extension%
rem exit

rem ULTRA blur 1: these are equal:
rem -filter Gaussian -resize 50% -define filter:sigma=2.5 -resize 200%
rem -blur 0x5 ^

rem POLAR BLUR YEAAAHHHH
::http://www.fmwconcepts.com/imagemagick/polarblur/index.php
rem set rsigma=5
rem magick convert %1 %OPTIONS% ^
rem -virtual-pixel edge -distort DePolar -1 ^
rem -morphology Convolve Blur:0x%rsigma%,90 ^
rem -virtual-pixel HorizontalTile -background black -distort Polar -1 ^
rem %~dpn1-meme-%memeNum%.%output_Extension%

rem pause
rem exit
:::::::::::::::::::::::::::::::::::::::::::::::::

:CONVERT input output
call :logDEBUG magick convert %1 %OPTIONS% ^
%resize% ^
-gravity %gTOP% ^( -size %SIZE% xc:none -font Impact -pointsize %scaledPoint_Size% -stroke rgba(0,0,0,1) -strokewidth 7 -annotate 0 "%annotateTOP%" -blur 0x1  ^) ^
-composite -font Impact -pointsize %scaledPoint_Size% -fill rgba^(%Color%,1^) -stroke none      -annotate 0 "%annotateTOP%" ^
-gravity %gBOTTOM% ^( -size %SIZE% xc:none -font Impact -pointsize %scaledPoint_Size% -stroke rgba(0,0,0,1) -strokewidth 7 -annotate 0 "%annotateBOTTOM%" -blur 0x1  ^) ^
-font Impact -pointsize %scaledPoint_Size% -fill rgba(%Color%,1) -stroke none      -annotate 0 "%annotateBOTTOM%" -composite ^
%backgroundColor% ^
%QUALITY% ^
%2

magick convert %1 %OPTIONS% ^
%resize% ^
-gravity %gTOP% ^( -size %SIZE% xc:none -font Impact -pointsize %scaledPoint_Size% -stroke rgba(0,0,0,1) -strokewidth 7 -annotate 0 "%annotateTOP%" -blur 0x1  ^) ^
-composite -font Impact -pointsize %scaledPoint_Size% -fill rgba(%Color%,1) -stroke none      -annotate 0 "%annotateTOP%" ^
-gravity %gBOTTOM% ^( -size %SIZE% xc:none -font Impact -pointsize %scaledPoint_Size% -stroke rgba(0,0,0,1) -strokewidth 7 -annotate 0 "%annotateBOTTOM%" -blur 0x1  ^) ^
-font Impact -pointsize %scaledPoint_Size% -fill rgba(%Color%,1) -stroke none      -annotate 0 "%annotateBOTTOM%" -composite ^
%backgroundColor% ^
%QUALITY% ^
%2

goto :EOF

:OPTIMIZE input
::quick png optimization of the output
REM call S:\wintools\multimedia\pngquant-optimizer+ordered-q10.cmd inplace "%~dpn1-meme-%memeNum%.png"
if /I "%~x1"==".png" (
  echo.%HIGH%%k%
  call pngquant-optimizer-quality_v1.cmd inplace %1 colors256 quality50-70
  echo.%END%
)
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


:logDEBUG
IF DEFINED DEBUG echo %m%DEBUG: %*%END%
goto :EOF

:len
:: https://stackoverflow.com/questions/5837418/how-do-you-get-the-string-length-in-a-batch-file/8566001#8566001
call echo]%%%1%%>%TMP%\%~n0.tmp & FOR %%? IN (%TMP%\%~n0.tmp) DO SET /A strlength=%%~z? - 3
exit /b %strlength%


:end
rem pause
