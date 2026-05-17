import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Networking
import Quickshell.Bluetooth
import QtQuick

Item {
    id: root
    property int brightness: 0
    property int maxBrightness: 0
    property int modifier: 0
    property real volume: 0.0
    Component.onCompleted: print(Bluetooth.devices.values, Networking.devices.values[0].networks)

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

                root.brightness = roundTo(text/root.maxBrightness, 2) * 100
                root.brightness += root.modifier
                setBrightness.running = true
            }
        }
    }
    Process {
        id: setBrightness
        running: false
        command: ["sh", "-c", `brightnessctl set ${root.brightness}%`]
    }

    IpcHandler {
        target: "brightness"
        function add(x: int) { root.modifier = x; getMaxBrightness.running = true }
        function dim(x: int) { root.modifier = -x; getMaxBrightness.running = true }
        function set(x: int) { root.brightness = x; setBrightness.running = true }
    }

    IpcHandler {
        target: "volume"
        function up(x: int) { Pipewire.defaultAudioSink.audio.volume += x/100 }
        function down(x: int) { Pipewire.defaultAudioSink.audio.volume -= x/100 }
        function set(x: int) { Pipewire.defaultAudioSink.audio.volume = x/100 }
        function toggle() { if(Pipewire.defaultAudioSink.audio.volume > 0) {
                                root.volume = Pipewire.defaultAudioSink.audio.volume
                                Pipewire.defaultAudioSink.audio.volume = 0
                            } 
                            else {
                                Pipewire.defaultAudioSink.audio.volume = root.volume
                            }
                        }
    }
}