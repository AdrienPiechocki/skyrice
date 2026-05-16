import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.Modules

Item {
    id: root

    IdleMonitor {
        id: monitor
        timeout: 1200
        onIsIdleChanged: lockscreen.active = true
    }

    LockContext {
        id: lockContext
        onUnlocked: {
            lockscreen.locked = false;
        }
    }

    LockScreen{ id: lockscreen; context: lockContext; onLockedChanged: lockscreen.active = false }

}