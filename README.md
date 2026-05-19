# The Elder Rice: Skyrim

This is a Rice I made in about a week. Inspired by Skyrim's UI.\
I also borrowed code from [noctalia-shell](https://github.com/noctalia-dev/noctalia-shell) and [quickshell-niri](https://github.com/imiric/quickshell-niri). 
(please support them !)

## DEMO

[![The Elder Rice : Skyrim](https://img.youtube.com/vi/LBdIwXNmpPI/0.jpg)](https://www.youtube.com/watch?v=LBdIwXNmpPI)

## REQUIREMENTS

This Rice was made with Niri and Arch Linux in mind. It probably won't work on something else.

You might also need: 
- quickshell (noctalia-qs, specifically)
- brightnessctl (for brightness managment)
- lm_sensors (for cpu temperature)
- multiple python packages (requests, geopandas, numpy, PyGObject)
- kitty (to launch the update script)
- An AMD GPU (if you want GPU resource monitoring)
- skyrim-cursor-theme (if you want your cursor to fit the theme)

## INSTALLATION

```
git clone https://github.com/AdrienPiechocki/skyrice.git ~/.config/quickshell/skyrice
```

Change `./Config/weather.json` to match your current location

## IPC calls

- `qs -c skyrice ipc call inventory toggle` toggles the app launcher
- `qs -c skyrice ipc call lockscreen lock` locks the screen
- `qs -c skyrice ipc call logout toggle` toggles session managment
- `qs -c skyrice ipc call update run` launches the update script
- `qs -c skyrice ipc call resources toggle` toggles the resources monitor
- `qs -c skyrice ipc call settings toggle` toggles the settings manager
- `qs -c skyrice ipc call notifications toggle` toggles the notifications history
- `qs -c skyrice ipc call notifications dnd` toggles "do not disturb" mode
- `qs -c skyrice ipc call battery toggle` toggles the battery monitor / power profile manager
- `qs -c skyrice ipc call weather toggle` toggles the weather monitor
- `qs -c skyrice ipc call calendar toggle` toggles the calendar
- `qs -c skyrice ipc call volume up X` increases volume by X
- `qs -c skyrice ipc call volume down X` decreases volume by X
- `qs -c skyrice ipc call volume set X` sets volume to X
- `qs -c skyrice ipc call volume toggle` toggles volume output
- `qs -c skyrice ipc call brightness add X` increases brightness by X
- `qs -c skyrice ipc call brightness dim X` decreases brightness by X
- `qs -c skyrice ipc call brightness set X` sets brightness to X

### Example Niri configuration 

```
cursor {
    xcursor-theme "Skyrim"
    xcursor-size 32
}

window-rule {
    geometry-corner-radius 10
    clip-to-geometry true
}

layout {
    gaps 8
    focus-ring {
        active-color   "#cecece"
    }
    border {
    	on
    	width 2
        active-color   "#000000"
        inactive-color "#000000"
    }
}

binds {
    Mod+R repeat=false { spawn-sh "qs -c skyrice ipc call inventory toggle"; }
    Mod+L repeat=false { spawn-sh "qs -c skyrice ipc call lockscreen lock"; }
    Mod+Shift+L repeat=false { spawn-sh "qs -c skyrice ipc call logout toggle"; }
    Mod+U repeat=false { spawn-sh "qs -c skyrice ipc call update run"; }
    Mod+I repeat=false { spawn-sh "qs -c skyrice ipc call resources toggle"; }
    Mod+O repeat=false { spawn-sh "qs -c skyrice ipc call settings toggle"; }
    Mod+N repeat=false { spawn-sh "qs -c skyrice ipc call notifications toggle"; }
    Mod+Shift+N repeat=false { spawn-sh "qs -c skyrice ipc call notifications dnd"; } 
    Mod+P repeat=false { spawn-sh "qs -c skyrice ipc call battery toggle"; }
    Mod+W repeat=false { spawn-sh "qs -c skyrice ipc call weather toggle"; }
    Mod+A repeat=false { spawn-sh "qs -c skyrice ipc call calendar toggle"; }
    XF86AudioRaiseVolume { spawn-sh "qs -c skyrice ipc call volume up 5"; }
    XF86AudioLowerVolume { spawn-sh "qs -c skyrice ipc call volume down 5"; }
    XF86AudioMute { spawn-sh "qs -c skyrice ipc call volume toggle"; }
    XF86MonBrightnessUp { spawn-sh "qs -c skyrice ipc call brightness add 5";  }
    XF86MonBrightnessDown { spawn-sh "qs -c skyrice ipc call brightness dim 5";  }
}
```
