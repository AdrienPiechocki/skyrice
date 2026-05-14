import Quickshell
import QtQuick
import Quickshell.Wayland

LazyLoader {
    id: root
    active: false
    property bool locked: true
    WlSessionLock {
        id: lock
        locked: root.locked
        WlSessionLockSurface {
            color: "black"
            Image {
                anchors.fill: parent.screen
                source: "../Assets/Wallpaper.jpeg"
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: { root.locked = false }
                }
            }
        }
    }
}