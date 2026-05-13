import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Services.UPower
import qs.Commons
import qs.Services

Capsule {
    id: root
    readonly property var chargeState: Battery.chargeState
    readonly property bool isCharging: Battery.isCharging
    readonly property bool isPluggedIn: Battery.isPluggedIn
    readonly property real percentage: Battery.percentage
    readonly property bool isLow: percentage <= 25 / 100
    readonly property bool isCritical: percentage <= 10 / 100
    Component.onCompleted: print(UPowerDeviceState.Charging)
    FontLoader {
        id: futuraFont
        source: "../../Assets/Fonts/Futura Condensed Medium.ttf"
    }
    _color: "#67000000" 
    width: 150
    RowLayout{
        anchors.fill: parent
        spacing: 5
        Capsule{
            id: battery
            active: false
            color: hoverHandler.hovered ? "#67cecece" : "#67000000"
            HoverHandler { id: hoverHandler; }
            Layout.maximumWidth: 35
            Layout.maximumHeight: 22
            Layout.alignment: Qt.AlignRight
            ProgressBarText {
                id: batteryProgress
                anchors {
                    left: icon.left
                    bottom: icon.bottom
                }
                valueBarWidth: icon.bodyWidth
                valueBarHeight: icon.bodyHeight
                value: percentage
                text: Math.round(value * 100)
                shimmer: isCharging
                pulse: isCharging
                highlightColor: (() => {
                    if (isCritical && !isCharging) {
                        return "red";
                    }
                    if (isLow && !isCharging) {
                        return "orange";
                    }
                    return "green";
                })()
                font.family: futuraFont.name
                font.bold: true
                font.pixelSize: 14
                textColor: "white"

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
                anchors.centerIn: parent
                size: 22
                iconColor: "green"
            }
        }
    }
}