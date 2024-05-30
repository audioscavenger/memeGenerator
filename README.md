# meme-Generator
meme Generator batch for Windows, relies on Image Magick and AI to predict ideal point size

<p align="center">
 <img src="/assets/meme-Annoyed-Picard-blank-750sq-Magick.avif" />
</p>

* Outputs any image extension you want
* Background blur / sharpen / radial option
* 2 text positions, many colors, any point size, AI predicted best point sise
* Saves history so you can recall older settings

## Usage Example

![memeGenerator use example](/assets/memeGenerator-full-examplearrows.avif):

Just create a shortcut to it in `shell:sendto` and right-click send your files to it!

## Options example

![memeGenerator prompt example 1](/assets/memeGenerator-example-1.png):

## Installation
### Requirements:

- [ImageMagick](https://www.imagemagick.org/script/download.php#windows) (choose the Q16 static, portable zip version)
- [OptiPNG](http://optipng.sourceforge.net/)
- [pngQuant](https://www.imagemagick.org/script/download.php#windows) (optional)

Just make sure those binaries are accessible to the batch: edit the `%PATH%` part at the top:

```
:start
::replace S:\wintools\multimedia by your path with magick, and add paths where pngquant and optipng are:
set "PATH=%PATH%;%~d0\wintools\PortableApps\Magick;%~d0\wintools\multimedia"
```

## RoadMap
TODO:

- [ ] Start charging for my hard work?

### release 2.0.0

- 2.0.0 Finally, a README!
- 1.9.9 bugfix
- 1.9.8 more colors, betterquestions, better workflow
- 1.9.7 now saves ColorTOP/BOTTOM and Point_SizeTOP/BOTTOM
- 1.9.6 now use Colors by name and convert to rgb
- 1.9.5 fixed memeNum increment
- 1.9.4 now applies different size and colors per gravity
- 1.9.3 protect paths using short names
- 1.9.2 fixed spaces in names
- 1.9.1 fixed PATH
- 1.9.0 cosmetics + :logDEBUG
- 1.8.0 set Point_Size=f(SIZE)
- 1.7.0 added debug mode and text/background colors
- 1.6.0 complete prompt options overhaul with dependent options
- 1.5.0 complete history overhaul
- 1.4.0 complete menu ovrehaul


## :ribbon: Licence
[GPL 3.0](https://choosealicense.com/licenses/gpl-3.0/)


## :beer: Buy me a beer
Like my work? This tool helped you? Want to sponsor more awesomeness like this?

<p align="center">
 <a href="https://www.paypal.com/donate/?hosted_button_id=CD7P7PK3WP8WU"><img src="/assets/paypal-Donate-QR-Code.png" /></a>
</p>
