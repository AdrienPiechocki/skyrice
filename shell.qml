//@ pragma UseQApplication
import Quickshell
import QtQuick
import qs.Modules
import qs.Services

ShellRoot {
    Wallpaper{}
    Bar{ notification: notification}
    Notification{ id: notification; }
    WeatherBackend{}
    Idle{}
    IPC{}
    OSD{}
}