import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import qs.Commons
import qs.Modules.Widgets
import qs.Services

Capsule {
    id: root
    readonly property var chargeState: Battery.chargeState
    readonly property bool isCharging: Battery.isCharging
    readonly property bool isPluggedIn: Battery.isPluggedIn
    readonly property real percentage: Battery.percentage
    readonly property bool isLow: percentage <= 25 / 100
    readonly property bool isCritical: percentage <= 10 / 100
    readonly property var updateCountPath: Quickshell.shellDir + "/Scripts/update-count.sh" 
    readonly property var updatePath: Quickshell.shellDir + "/Scripts/update.sh" 

    property int posX: 0
    property int posY: 0
    property int screenX: 0

    function updatePos(x, y) {
        posX = x
        posY = y
    }

    FontLoader {
        id: futuraFont
        source: "../../Assets/Fonts/Futura Condensed Medium.ttf"
    }
    _color: "#67000000" 
    width: 150
    RowLayout{
        anchors.fill: parent
        spacing: 0

        Capsule {
            id: resources
            active: false
            color: resourcesHoverHandler.hovered ? "#67cecece" : "#67000000"
            HoverHandler { id: resourcesHoverHandler; }
            Layout.maximumWidth: 35
            Layout.maximumHeight: 22
            Layout.alignment: Qt.AlignHCenter
            Text {
                anchors.centerIn: parent
                color: "#cecece"
                text: ""
                font.family: futuraFont.name
                font.pointSize: 12
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    var screenPos = parent.mapToGlobal(0, 0);
                    root.updatePos(screenPos.x - root.screenX, screenPos.y + root.height);
                    resourcesMenu.active = !resourcesMenu.active;
                }
            }
        }
        Capsule {
            id: update
            active: false
            color: updateHoverHandler.hovered ? "#67cecece" : "#67000000"
            HoverHandler { id: updateHoverHandler; }
            Layout.maximumWidth: 35
            Layout.maximumHeight: 22
            Layout.alignment: Qt.AlignHCenter
            Process {
                id: updateCount
                running: true
                command: [ "sh", "-c", root.updateCountPath]
                stdout: StdioCollector {
                    onStreamFinished: countText.text = text
                }
            }
            Process {
                id: updateInstall
                running: false
                command: [ "kitty", "-e", root.updatePath]
                stdout: StdioCollector {
                    onStreamFinished: {
                        updateCount.running = true
                        count.visible = countText.text > 0
                    }
                }
            }
            Timer {
                running: true
                interval: 300000
                repeat: true
                onTriggered: updateCount.running = true
            }
            RowLayout {
                anchors.fill: parent
                spacing: 0
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"
                    Text {
                        anchors.centerIn: parent
                        color: "#cecece"
                        text: ""
                        font.family: futuraFont.name
                        font.pointSize: 12
                    }
                }
                Rectangle {
                    id: count
                    visible: countText.text > 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"
                    Text {
                        id: countText
                        anchors.centerIn: parent
                        color: "#cecece"
                        text: ""
                        font.family: futuraFont.name
                        font.pointSize: 12
                    }
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: updateInstall.running = true
                hoverEnabled: true
                onEntered: count.visible = true
                onExited: count.visible = countText.text > 0
            }
        }
        Capsule {
            id: settings
            active: false
            color: settingsHoverHandler.hovered ? "#67cecece" : "#67000000"
            HoverHandler { id: settingsHoverHandler; }
            Layout.maximumWidth: 35
            Layout.maximumHeight: 22
            Layout.alignment: Qt.AlignHCenter
            Text {
                anchors.centerIn: parent
                color: "#cecece"
                text: ""
                font.family: futuraFont.name
                font.pointSize: 12
            }
        }
        Capsule{
            id: battery
            active: false
            color: batteryHoverHandler.hovered ? "#67cecece" : "#67000000"
            HoverHandler { id: batteryHoverHandler; }
            Layout.maximumWidth: 35
            Layout.maximumHeight: 22
            Layout.alignment: Qt.AlignHCenter
            ProgressBarText {
                id: batteryProgress
                anchors {
                    left: icon.left
                    bottom: icon.bottom
                }
                valueBarWidth: icon.bodyWidth
                valueBarHeight: icon.bodyHeight
                value: percentage
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
                    return '#9eb1b8';
                })()
                font.family: futuraFont.name
                font.bold: true
                font.pixelSize: 14
                textColor: batteryHoverHandler.hovered ? "white" : "transparent"
                textOutline: batteryHoverHandler.hovered ? Text.Outline : Text.Normal

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
                size: 24
                iconColor: '#9d9d9d'
            }
        }
    }
    Resources{ id: resourcesMenu; popupX: root.posX; popupY: root.posY; }
}