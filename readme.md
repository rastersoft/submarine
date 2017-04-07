RASTERSUBMARINE
===============

Current version: 0.1.5

Rastersubmarine is a program that searchs subtitles for a file in several subtitle pages. It is a fork of Submarine, from Blaž Tomažič.

Currently it searchs in:

  * bierdopje
  * divx subtitles
  * open subtitles
  * podnapisi
  * the subtitle db
  * subtitulos es

Building and installing Rastersubmarine
=================================

Rastersubmarine is writen in Vala, so you need the vala compiler (valac) and its libraries (vapi). You also need CMake.

To compile and install it, just follow these instructions:

    mkdir install
    cd install
    cmake ..
    make
    sudo make install
    sudo ldconfig


Using Rastersubmarine
=====================

    submarine [-h|--help] -l CODE [-s CODESERVER] [-f|--force] [-V|--version] [-v,--verbose] [-q,--quiet] file_path

-l CODE: CODE is the 2 or 3-letter language code (like 'es', 'en', 'pt', 'spa', 'eng'...). Specifies which language to search and download.

-s CODESERVER: specifies to search only in the specified server, by using the two-letter code. Use 'submarine -s help' to list the codes.

-f,--force: downloads the subtitles even if there is already a subtitles file in the current folder.

-h,--help: shows the help.

-V,--version: shows the current version.

-v,--verbose: makes the output more verbose

-q,--quiet: makes the output less verbose


Examples
========

    submarine -l en myFavouriteSeriesS01E04.mkv

Searchs in all servers for subtitles in english for the chapter 4, Season 1, of *My Favourite Series*.

    submarine -l en -s bd myFavouriteSeriesS01E04.mkv

Searchs only in BiedDopje server for subtitles in english for the chapter 4, Season 1, of *My Favourite Series*.


Contacting Author
=================

Rastersubmarine is maintained by Sergio Costas Rodriguez

rastersoft@gmail.com  
http://www.rastersoft.com  
https://github.com/rastersoft/submarine
