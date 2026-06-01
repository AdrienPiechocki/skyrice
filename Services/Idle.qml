import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import qs.Modules

Item {
    id: root

    property int brightness: 0
    property int maxBrightness: 0
    property int brightnessOrigin: 0

    IdleMonitor {
        id: fader
        timeout: 220
        onIsIdleChanged: {
            if (isIdle) {
                getMaxBrightness.running = true
                root.brightness = 10
            }
            else {
                root.brightness = root.brightnessOrigin
            }
            fade.running = true
        }
    }

    Process {
        id: getMaxBrightness
        running: false
        command: ["brightnessctl", "max"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.maxBrightness = text
                getBrightness.running = true
            }
        }
    }
    Process {
        id: getBrightness
        running: false
        command: ["brightnessctl", "get"]

        stdout: StdioCollector {
            onStreamFinished: {
                function roundTo(n, digits) {
                    var negative = false;
                    if (digits === undefined) {
                        digits = 0;
                    }
                    if (n < 0) {
                        negative = true;
                        n = n * -1;
                    }
                    var multiplicator = Math.pow(10, digits);
                    n = parseFloat((n * multiplicator).toFixed(11));
                    n = (Math.round(n) / multiplicator).toFixed(digits);
                    if (negative) {
                        n = (n * -1).toFixed(digits);
                    }
                    return n;
                }

                root.brightnessOrigin = roundTo(text/root.maxBrightness, 2) * 100
            }
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
        onIsIdleChanged: if(isIdle) { lockscreen.active = true }
    }

    IdleMonitor {
        id: suspender
        timeout: 300
        onIsIdleChanged: if(isIdle) { suspend.running = true }
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
    
    LockScreen{ id: lockscreen; context: lockContext; onLockedChanged: root.active = false }
}