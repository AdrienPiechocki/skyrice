import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import qs.Modules

Item {
    id: root

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