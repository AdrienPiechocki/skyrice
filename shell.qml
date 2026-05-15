//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import QtQuick
import qs.Modules

ShellRoot {
    id: root
    readonly property var weatherScriptPath: Quickshell.shellDir + "/Scripts/weather.py" 
    Wallpaper{}
    Bar{}
    Notification{}
    Process {
        id: weatherProc
        running: true
        command: [ "python3", root.weatherScriptPath ]
    }
}