import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import Quickshell.Networking
import Quickshell.Bluetooth
import qs.Commons
import qs.Services

LazyLoader {
    id: root
    active: false
    property int popupX: 0
    property int popupY: 0
    PanelWindow {
        id: menu

        anchors {
            top: true
            bottom: true
            right: true
            left: true
        }
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        PanelWindow {
            id: window
            anchors.left: parent.left
            anchors.top: parent.top
            margins.left: root.popupX - width/2.3
            margins.top: root.popupY
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            implicitHeight: 225
            implicitWidth: 300
            color: "transparent"       
            FontLoader {
                id: futuraFont
                source: "../../Assets/Fonts/Futura Condensed Medium.ttf"
            }

            Gradient {
                id: gradient
                orientation: Gradient.Horizontal
                GradientStop { position: 0; color: "transparent" }
                GradientStop { position: 0.5; color: "#42cecece" }
                GradientStop { position: 1; color: "transparent" }
            }

            Background{ width: parent.width; height: parent.height; stroke: 2}
            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 25
                anchors.bottomMargin: 25
                anchors.leftMargin: 25
                anchors.rightMargin: 25
                color: "transparent"
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0
                    Rectangle {
                        Layout.fillWidth: true
                        height: 10
                        color: "transparent"
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        height: 50
                        color: "transparent"
                        Text {
                            x: parent.width/2 - contentWidth/2
                            y: -5
                            color: "white"
                            text: "Volume: " + Math.round(Pipewire.defaultAudioSink.audio.volume*100) + "%"
                            font.family: futuraFont.name
                            font.pointSize: 12
                        }
                        Slider {
                            anchors.centerIn: parent
                            from: 0
                            value: 0.5
                            to: 1
                            stepSize: 0.01
                            snapMode: Slider.SnapAlways
                            Component.onCompleted: value = Pipewire.defaultAudioSink.audio.volume
                            onValueChanged: Pipewire.defaultAudioSink.audio.volume = value
                        }
                    }
                    Rectangle {
                        id: brightness
                        Layout.fillWidth: true
                        height: 50
                        color: "transparent"
                        property int brightness: 0
                        property int max: 0
                        property bool flag: false
                        Process {
                            id: getMaxBrightness
                            running: true
                            command: ["brightnessctl", "max"]
                            stdout: StdioCollector {
                                onStreamFinished: {
                                    brightness.max = text
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

                                    brightness.brightness = roundTo(text/brightness.max, 2) * 100
                                    brightnessSlider.value = brightness.brightness
                                    brightness.flag = true
                                }
                            }
                        }

                        Process {
                            id: setBrightness
                            running: false
                            command: ["sh", "-c", `brightnessctl set ${brightness.brightness}%`]
                        }

                        Text {
                            x: parent.width/2 - contentWidth/2
                            y: -5
                            color: "white"
                            text: "Brightness: " + brightness.brightness + "%"
                            font.family: futuraFont.name
                            font.pointSize: 12
                        }
                        Slider {
                            id: brightnessSlider
                            anchors.centerIn: parent
                            from: 0
                            value: 50
                            to: 100
                            stepSize: 1
                            snapMode: Slider.SnapAlways
                            onValueChanged: { 
                                if(brightness.flag) {brightness.brightness = value; setBrightness.running = true} 
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 5
                        color: "transparent"
                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width
                            height: 2
                            gradient: gradient
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"
                        ColumnLayout {
                            anchors.fill: parent
                            Rectangle {
                                Layout.fillWidth: true
                                height: 50
                                color: "transparent"
                                RowLayout {
                                    anchors.fill: parent
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        color: "transparent"
                                        Capsule {
                                            id: network
                                            anchors.centerIn: parent
                                            property bool current: false
                                            color: tapHandler_network.pressed ? '#b6ffffff' : hoverHandler_network.hovered ? "#67cecece" : current ? "#1f1f1f" : "#67181818" 
                                            TapHandler { id: tapHandler_network; onTapped: {
                                                    window.implicitHeight = 300
                                                    Networking.devices.values[0].scannerEnabled = true;
                                                    repeater.model = Networking.devices.values[0].networks
                                                    network.current = true
                                                    bluetooth.current = false
                                                } }
                                            HoverHandler { id: hoverHandler_network }
                                            active: false
                                            Text {
                                                anchors.centerIn: parent
                                                color: "white"
                                                text: "network"
                                                font.family: futuraFont.name
                                                font.pointSize: 12
                                            }
                                        }
                                    }
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        color: "transparent"
                                        Capsule {
                                            id: bluetooth
                                            anchors.centerIn: parent
                                            property bool current: false
                                            color: tapHandler_bluetooth.pressed ? '#b6ffffff' : hoverHandler_bluetooth.hovered ? "#67cecece" : current ? '#1f1f1f' : "#67181818" 
                                            TapHandler { id: tapHandler_bluetooth; onTapped: {
                                                    window.implicitHeight = 300
                                                    repeater.model = Bluetooth.devices.values
                                                    network.current = false
                                                    bluetooth.current = true
                                                } }
                                            HoverHandler { id: hoverHandler_bluetooth }
                                            active: false
                                            Text {
                                                anchors.centerIn: parent
                                                color: "white"
                                                text: "bluetooth"
                                                font.family: futuraFont.name
                                                font.pointSize: 12
                                            }
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "transparent"
                                GridLayout {
                                    anchors.fill: parent
                                    columns: 3
                                    Repeater {
                                        id: repeater
                                        model: 0
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            color: "transparent"
                                            Capsule {
                                                anchors.centerIn: parent
                                                width: 50
                                                color: modelData.connected ? '#67add8e6' : tapHandler.pressed ? '#b6ffffff' : hoverHandler.hovered ? "#67cecece" : '#67181818' 
                                                TapHandler { id: tapHandler }
                                                HoverHandler { id: hoverHandler }
                                                active: false
                                                clip: true
                                                Text {
                                                    id: text
                                                    verticalAlignment: Text.AlignVCenter 
                                                    horizontalAlignment: contentWidth > parent.width ? Text.AlignLeft : Text.AlignHCenter
                                                    property int speed: contentWidth * 30
                                                    color: "white"
                                                    text: modelData.name
                                                    font.family: futuraFont.name
                                                    font.pointSize: 12
                                                    style: Text.Outline
                                                    x: 0
                                                    y: height/2 - contentHeight/4
                                                    SequentialAnimation on x {
                                                        id: scrollAnim
                                                        running: hoverHandler.hovered ? text.contentWidth > 50 : false
                                                        NumberAnimation { 
                                                            to: -text.contentWidth 
                                                            duration: text.speed
                                                        }
                                                        onFinished: {text.x = 50; restart()}
                                                    }
                                                    Timer {
                                                        running: true
                                                        interval: 250
                                                        repeat: true
                                                        onTriggered: {
                                                            if (text.contentWidth <= 50 && scrollAnim.running) { scrollAnim.running = false; text.x = 0 }
                                                            if (!scrollAnim.running) {
                                                                text.x = 0
                                                            }
                                                        }
                                                    }
                                                }
                                                MouseArea {
                                                    anchors.fill: parent
                                                    onClicked: {
                                                        if(modelData.connected) {
                                                            modelData.disconnect()
                                                        }
                                                        else {
                                                            modelData.connect()
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {Networking.devices.values[0].scannerEnabled = false; root.active = false}
        }
    }
}