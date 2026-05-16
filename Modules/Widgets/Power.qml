import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Bluetooth
import Quickshell.Services.UPower
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
            implicitHeight: 200
            implicitWidth: 250
            color: "transparent"
            
            FontLoader {
                id: futuraFont
                source: "../../Assets/Fonts/Futura Condensed Medium.ttf"
            }

            Background{ width: parent.width; height: parent.height; stroke: 2}
            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 30
                anchors.bottomMargin: 20
                anchors.leftMargin: 25
                anchors.rightMargin: 25
                color: "transparent"
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "transparent"
                        property list<string> profiles: ["power-saver", "balanced", "performance"]
                        Text {
                            x: parent.width/2 - contentWidth/2
                            y: 0
                            color: "white"
                            text: "Profile: " + parent.profiles[PowerProfiles.profile]
                        }
                        Slider {
                            anchors.centerIn: parent
                            from: 0
                            value: 1
                            to: 2
                            stepSize: 1
                            snapMode: Slider.SnapAlways
                            Component.onCompleted: value = PowerProfiles.profile
                            onValueChanged: PowerProfiles.profile = value
                        }
                    }
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "transparent"
                        GridLayout {
                            anchors.fill: parent
                            columns: 2
                            Repeater {
                                model: Bluetooth.devices.values.filter(b => b.connected)
                                Rectangle {
                                    height: 40
                                    width: 50
                                    Layout.alignment: Qt.AlignHCenter
                                    color: "transparent"
                                    clip: true
                                    TapHandler { id: tapHandler }
                                    HoverHandler { id: hoverHandler }
                                    Capsule{
                                        anchors.centerIn: parent
                                        width: 50
                                        height: 40
                                        color: hoverHandler.hovered ? "#67cecece" : "#67000000"
                                        active: false
                                        ProgressBarText {
                                            id: batteryProgress
                                            anchors {
                                                left: icon.left
                                                bottom: icon.bottom
                                            }
                                            valueBarWidth: icon.bodyWidth
                                            valueBarHeight: icon.bodyHeight
                                            value: modelData.battery * 100
                                            text: `${Math.round(value * 100)}`
                                            shimmer: isCharging
                                            pulse: isCharging
                                            highlightColor: (() => {
                                                if (isCritical && !isCharging) {
                                                    return "red";
                                                }
                                                if (isLow && !isCharging) {
                                                    return "orange";
                                                }
                                                return 'lightblue';
                                            })()
                                            font.family: futuraFont.name
                                            font.bold: true
                                            font.pixelSize: 14
                                            textColor: hoverHandler.hovered ? "white" : "transparent"
                                            textOutline: hoverHandler.hovered ? Text.Outline : Text.Normal

                                            // Clip the progress bar within the borders of the battery icon body
                                            layer.enabled: true
                                            layer.effect: OpacityMask {
                                                maskSource: Item {
                                                    width: batteryProgress.width
                                                    height: batteryProgress.height

                                                    Rectangle {
                                                        x: icon.borderWidth
                                                        y: icon.borderWidth
                                                        width: icon.bodyWidth - icon.borderWidth * 2
                                                        height: icon.bodyHeight - icon.borderWidth * 2
                                                        radius: icon.bodyRadius / 2
                                                    }
                                                }
                                            }
                                        }
                                        BatteryIcon {
                                            id: icon
                                            anchors.bottom: parent.bottom
                                            anchors.bottomMargin: 5
                                            anchors.left: parent.left
                                            anchors.leftMargin: parent.width/2 - 12
                                            size: 26
                                            iconColor: 'gray'
                                        }
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
            onClicked: root.active = false
        }
    }
}