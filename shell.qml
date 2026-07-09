//@ pragma UseQApplication
import Quickshell
import QtQuick
import qs.Modules
import qs.Services

ShellRoot {
    Overview{}
    Wallpaper{}
    Bar{ notification: notification}
    Notification{ id: notification; }
    WeatherBackend{}
    Idle{}
    IPC{}
    OSD{}
}