# almost-steamOS

## Disclaimer
This project does not affiliated with Steam.<br>
I only provides installation script.<br>
The whole gaming experience, packages and games belongs to Steam.

## Idea
Using a minimal [DebianOS](https://www.debian.org/distrib/) as a
base, and then install steam together with associated software
that commonly used alongside steam.<br>
Steam client full-screen mode is also quite good. It includes
basic `logout-reboot-shutdown` operation and a `web-browser`.<br>
It's almost-steamOS. I've tried it on my desktop for quite a
while. It works and I'm satisfied.

## Installation
### 0. Pre-requisites
- Debian usb stick or iso file. [Download](https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/)
> Please use the DVD type. This is required to use as
offline repository.
- Empty USB stick to transer git files.
### 1. Install these to your system
- Minimal [Debian Buster](https://www.debian.org/distrib/)
- Graphic card driver
### 2. Copy files to your target system
- Do git clone
```
git clone --depth 1 https://github.com/akirasy/almost-steamOS.git
```
- Copy all files to your target system.
> Yes, it's troublesome to get this into the target PC. I'm
still thinking how to get around this.
### 3. Run install script
- Use sudo command below.
```
sudo bash install.sh
```
- Wait the install and agree to the respective prompt.

## Tips & Tricks
### Change wallpaper
This build uses `feh` as desktop wallpaper.<br>
To change wallpaper, follow these steps:
1. Download and put your desired wallpaper to `~/.config/feh/` folder.
2. Open `~/.config/feh/autostart` using text editor and edit your wallpaper path.

You might want to explore more at [feh documentation](https://manpages.debian.org/buster/feh/feh.1.en.html).