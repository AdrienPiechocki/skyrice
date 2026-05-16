import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import qs.Modules

Item {
    id: root

    property int brightness: 80

    IdleMonitor {
        id: fader
        timeout: 220
        onIsIdleChanged: {
            if (isIdle) {
                root.brightness = 10
            }
            else {
                root.brightness = 80
            }
            fade.running = true
        }
    }

    Process {
        id: fade
        running: false
        command: ["sh", "-c", `brightnessctl set ${root.brightness}%`]
    }


    IdleMonitor {
        id: locker
        timeout: 240
        onIsIdleChanged: lockscreen.active = true
    }

    IdleMonitor {
        id: suspender
        timeout: 300
        onIsIdleChanged: suspend.running = true
    }

    Process {
        id: suspend
        running: false
        command: ["sh", "-c", "systemctl suspend"]
    }

    LockContext {
        id: lockContext
        onUnlocked: {
            lockscreen.locked = false;
        }
    }

    LockScreen{ id: lockscreen; context: lockContext; onLockedChanged: lockscreen.active = false }

}