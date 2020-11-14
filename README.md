<h1 align="center">Galactic Emacs</h1>
<p align="center">
  <img src="https://raw.githubusercontent.com/daviderestivo/galactic-emacs/master/logos/galactic-emacs-logo.png" alt="Galactic Emacs Logo">
  <br><br>
  <a href="https://www.gnu.org/licenses/gpl-3.0">
    <img src="https://img.shields.io/badge/License-GPL%20v3-blue.svg" alt="License: GPL v3">
    </a>
  <a href="  https://github.com/daviderestivo/galactic-emacs/actions?query=workflow%3A%22Galactic+Emacs%22">
    <img src="https://github.com/daviderestivo/galactic-emacs/workflows/Galactic%20Emacs/badge.svg" alt="Galactic Emacs CI Status Badge">
  </a>
</p>

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Introduction](#introduction)
- [Screenshots](#screenshots)
    - [Emacs dashboard](#emacs-dashboard)
    - [Emacs scratch buffer](#emacs-scratch-buffer)
    - [Emacs sidebars](#emacs-sidebars)
- [Installation](#installation)
    - [GNU/Emacs installation](#gnuemacs-installation)
    - [Galactic Emacs installation](#galactic-emacs-installation)
    - [Enable pdumper](#enable-pdumper)
- [Key bindings](#key-bindings)
- [Included packages](#included-packages)
- [About the logo](#about-the-logo)
- [License](#license)
- [Contribution](#contribution)

<!-- markdown-toc end -->

# Introduction
This repository contains the Galactic Emacs distribution. You can
clone it as it comes or simply use whatever part you might need/like.
The look and feel of the Emacs frame is based on the
[atom-one-dark](https://github.com/jonathanchu/atom-one-dark-theme)
theme with some minor changes.

# Screenshots
## Emacs dashboard
![Emacs dashboard](https://raw.githubusercontent.com/daviderestivo/galactic-emacs/master/screenshots/emacs_dashboard.png)

## Emacs scratch buffer
![Emacs scratch buffer](https://raw.githubusercontent.com/daviderestivo/galactic-emacs/master/screenshots/emacs_scratch_buffer.png)

## Emacs sidebars
![Emacs sidebars](https://raw.githubusercontent.com/daviderestivo/galactic-emacs/master/screenshots/emacs_sidebars.png)

# Installation
## GNU/Emacs installation
This configuration is mainly tested on the HEAD version of Emacs
(currently 28.x) running on macOS. If your're using brew, as a package
manager on macOS, please install Emacs with the below command:

``` bash
brew tap daviderestivo/emacs-head
brew install emacs-head --HEAD --with-cocoa --with-no-frame-refocus --with-imagemagick --with-jansson --with-pdumper
```

or if you prefer Emacs 26.x:

``` bash
brew tap daviderestivo/emacs-head
brew install emacs-head --with-cocoa --with-no-frame-refocus --with-imagemagick --with-multicolor-fonts
```

## Galactic Emacs installation
Please run the below commands to backup your current Emacs
configuration and clone this repo:

``` bash
cd ~
mv .emacs.d .emacs.d.bak
git clone --depth 1 https://github.com/daviderestivo/galactic-emacs.git .emacs.d
cd .emacs.d
git submodule init
git submodule update
git submodule foreach --recursive git checkout master
```

Before you start emacs please edit `~/.emacs.d/personal.el.example`
adding your personal information and rename it to
`~/.emacs.d/personal.el`.

Please specify in `personal.el` the additional packages you might want
to install. An example is included.

## Enable pdumper
If you're running Emacs >= 27 then you can enable pdumper support. In
order to do so, once you have cloned the Galactic Emacs distribution
as detailed in the previous section, start Emacs and issue: `M-x
galactic-emacs-dump-emacs`. Please run it with the command:

```
emacs --dump-file="$(echo ~/.emacs.d/.cache/dumps/emacs.pdmp)"
```

# Key bindings
Please have a look to the list of the available [key bindings](https://github.com/daviderestivo/galactic-emacs/blob/master/doc/keybindings.md).

# Included packages
Galactic Emacs distribution comes with many packages already included.
[Here](https://github.com/daviderestivo/galactic-emacs/blob/master/doc/included_packages.md)
you can find the complete list.

# About the logo
> The Empire is spread across the Milky Way galaxy and consists of
> almost 25 million planets settled exclusively by humans.
>
> I. Asimov, Galactic Empire

The logo represents the Spaceship and the Sun, emblem of the Galactic
Empire. The three stars on the right part represent Alpha Centauri.
Alpha Centauri is a triple star system, consisting of three stars:
Rigil Kentaurus, Toliman and Proxima Centauri. In Asimov's Foundation
Series, Alpha Centauri is cited by Lord Dorwin as one of the solar
systems where humankind potentially originated.

# License
The license is GPLv3 for all parts:
- the initialization and configuration files
- the documentation

For the license of the packages included in the Galactic Emacs
distribution please refer to the respective file headers.

# Contribution
Feel free to open an issue in case of questions or problems.
Contributions are always welcome.
