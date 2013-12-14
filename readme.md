SUBMARINE
=========

Current version: 0.1.5

Submarine is a program that searchs subtitles for a file in several subtitle pages.

Currently it searchs in:

  * bierdopje
  * divx subtitles
  * open subtitles
  * podnapisi
  * the subtitle db
  * subtitulos es

Building and installing Submarine
=================================

Submarine is writen in Vala, so you need the vala compiler (valac) and its libraries (vapi). You also need CMake.

To compile and install it, just follow these instructions:

    mkdir install
    cd install
    cmake ..
    make
    sudo make install
    sudo ldconfig

