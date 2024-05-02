@echo OFF
echo meme Generator 1.3
set PATH=%PATH%;S:\wintools\PortableApps\Magick;S:\wintools\multimedia
::replace S:\wintools\multimedia by your path with magick, pngquant and optipng
pushd %~dp1

set pointSize=50
::JPEG quality 75
set QUALITY=-quality 75
set extension=jpg
set blurLevel=1
set rsigma=10
set OPTIONS=
set defaultGravity=y
set gTOP=north
set gBOTTOM=south
set GRAVITIES=NorthWest North NorthEast West Center East SouthWest South SouthEast

if exist meme-history-extension.log for /f "tokens=*" %%t in ('tail -1 meme-history-extension.log') do set extension=%%t
set /p extension=extension [%extension%]? 
if "x%extension%x" NEQ "xx" (echo %extension%)>>meme-history-extension.log

::You can certainly combine blur with sharpen and any other filter you can think of for crazy results
set /p blurBackground=Blur Background [N/y]? 
:: set the blur level here: 0x1 to 0x6 heavy blur to 0x30 iPhone blur / single digit for soft blur http://www.imagemagick.org/script/command-line-options.php#blur
if /i "x%blurBackground%x" EQU "xyx" set /p blurLevel=Blur Level [1]? 
if /i "x%blurBackground%x" EQU "xyx" set OPTIONS=-blur 0x%blurLevel%

set /p radialBlur=Radial Blur [N/y]? 
:: rsigma: 5-30
if /i "x%radialBlur%x" EQU "xyx" set /p rsigma=rsigma [10]? 
if /i "x%radialBlur%x" EQU "xyx" set OPTIONS=%OPTIONS% -virtual-pixel edge -distort DePolar -1 -morphology Convolve Blur:0x%rsigma%,90 -virtual-pixel HorizontalTile -background black -distort Polar -1

set /p sharpenBackground=Sharpen Background [N/y]? 
:: sharpen level 0x6 gives an old school, badass look to the image http://www.imagemagick.org/script/command-line-options.php#sharpen
:: -adaptive-sharpen 4x6 = Adjust sharpening so that it is restricted to close to image edges as defined by edge detection.
if /i "x%sharpenBackground%x" EQU "xyx" set OPTIONS=%OPTIONS% -sharpen 6

call :GRAVITY

if exist meme-history-top.log for /f "tokens=*" %%t in ('tail -1 meme-history-top.log') do set top=%%t
set /p top=TEXT top [%top%]? 
if "x%top%x" NEQ "xx" (echo %top%)>>meme-history-top.log

if exist meme-history-bottom.log for /f "tokens=*" %%b in ('tail -1 meme-history-bottom.log') do set bottom=%%b
set /p bottom=TEXT bottom [%bottom%]? 
if "x%bottom%x" NEQ "xx" (echo %bottom%)>>meme-history-bottom.log

set /p pointSize=pointSize [%pointSize%]? 

call :IDENTIFY %1
call :CONVERT %1
call :OPTIMIZE %1
goto :END

:GRAVITY
set /p defaultGravity=Use default gravities [Y/n]? 
if /i "x%defaultGravity%x" EQU "xnx" echo -- chose both Gravities among: %GRAVITIES%
if /i "x%defaultGravity%x" EQU "xnx" set /p gtop=gtop [%gtop%]? 
if /i "x%defaultGravity%x" EQU "xnx" set /p gbottom=gbottom [%gbottom%]? 

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
REM %~n1-meme.%extension%
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

:IDENTIFY
:: IT WORKS!!!! but you have to define the size of the layers. Both commands are equivalent:
rem FOR /F "tokens=* USEBACKQ" %%s IN (`magick identify -format "%%[fx:w]x%%[fx:h]" %1`) DO SET SIZE=%%s
FOR /F "tokens=* USEBACKQ" %%s IN (`magick convert  -ping %1 -format "%%wx%%h" info:`) DO SET SIZE=%%s
echo SIZE=%SIZE%
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
rem %QUALITY% %~n1-meme.%extension%

rem Barrel Distortion like old Fallout TV screen
rem magick convert %1 %OPTIONS% ^
rem -virtual-pixel gray -distort Barrel "0.2 0.0 0.0 1.5" ^
rem %QUALITY% %~n1-meme.%extension%
rem %~dpn1-meme.%extension%
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
rem %~dpn1-meme.%extension%
rem %~dpn1-meme.%extension%

rem pause
rem exit
:::::::::::::::::::::::::::::::::::::::::::::::::
set transparency=0.7

:CONVERT
magick convert %1 %OPTIONS% ^
  -gravity %gTOP% ^
  ( -size %SIZE% xc:none -font Impact -pointsize %pointSize% -stroke rgba(0,0,0,1) -strokewidth 7 -annotate 0 "%top%" -blur 0x1  ) -composite ^
  -font Impact -pointsize %pointSize% -fill rgba(255,255,255,1) -stroke none      -annotate 0 "%top%" ^
  -gravity %gBOTTOM% ^
  ( -size %SIZE% xc:none -font Impact -pointsize %pointSize% -stroke rgba(0,0,0,1) -strokewidth 7 -annotate 0 "%bottom%" -blur 0x1  ) ^
  -font Impact -pointsize %pointSize% -fill rgba(255,255,255,1) -stroke none      -annotate 0 "%bottom%" -composite ^
  %QUALITY% ^
  "%~n1-meme.%extension%"
::
goto :EOF

:OPTIMIZE
::quick png optimization of the output
if "%extension%" EQU "png" (
rem   call S:\wintools\multimedia\pngquant-optimizer+ordered-q10.cmd inplace "%~dpn1-meme.png"
  call S:\wintools\multimedia\pngquant-optimizer-quality_v1.cmd inplace "%~dpn1-meme.png"
)
goto :EOF

:END
::launch the file in your default viewer
"%~dpn1-meme.%extension%"
rem pause
