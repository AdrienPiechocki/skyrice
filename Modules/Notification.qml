import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import qs.Commons

PanelWindow {
    id: root
    property var notifs: []
    anchors.top: true
    margins.top: 45
    anchors.right: true
    margins.right: 25
    implicitWidth: 350
    implicitHeight: 125 * root.notifs.length
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    NotificationServer {
        keepOnReload: false
        imageSupported: true
        actionsSupported: true
        onNotification: notification => {
            const data = createData(notification)
            root.notifs.push(data)
            root.implicitHeight = 125 * root.notifs.length
            repeater.model = root.notifs
        }
        function createData(n) {
            const time = Qt.formatDateTime(new Date(), "HH:mm")

            return {
            "id": n.id,
            "summary": n.summary || "",
            "body": n.body || "",
            "appName": n.appName || n.desktopEntry || "",
            "urgency": n.urgency < 0 || n.urgency > 2 ? 1 : n.urgency,
            "timestamp": time
            };
        }
    }
    ColumnLayout {
        spacing: 0
        Repeater {
            id: repeater
            model: root.notifs
            Rectangle {
                id: popup
                implicitWidth: 350
                implicitHeight: 125
                y: 45 + 125 * repeater.model.indexOf(modelData)
                color: "transparent"
                property var textWidth: 0
                Background{ width: popup.width; height: popup.height; stroke: 2; fillColor: "black"; borderColor: modelData.urgency > 1 ? "orange" : "#cecece"}
                FontLoader {
                    id: futuraFont
                    source: "../Assets/Fonts/Futura Condensed Medium.ttf"
                }
                Text {
                    x: Math.max(contentWidth, 50)
                    y: contentHeight
                    color: "white"
                    text: modelData.appName
                    font.family: futuraFont.name
                    font.pointSize: 12
                    style: Text.Outline
                }
                Text {
                    x: parent.width - 50 - contentWidth
                    y: contentHeight
                    color: "white"
                    text: modelData.timestamp
                    font.family: futuraFont.name
                    font.pointSize: 12
                    style: Text.Outline
                }
                Text {
                    x: parent.width /2 - contentWidth/2
                    y: contentHeight
                    color: "white"
                    text: modelData.body ? modelData.summary : ""
                    font.family: futuraFont.name
                    font.pointSize: 12
                    style: Text.Outline
                }
                Rectangle {
                    anchors.top: parent.top
                    anchors.topMargin: 35
                    anchors.left: parent.left
                    anchors.leftMargin: 50
                    width: 250
                    height: 62.5
                    color: "transparent"
                    clip: true
                    Text {
                        id: text
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: "white"
                        text: modelData.body ? modelData.body : modelData.summary
                        font.family: futuraFont.name
                        font.pointSize: 18
                        style: Text.Outline
                        wrapMode: Text.WordWrap
                        Component.onCompleted: {
                            elide = contentHeight > parent.height || contentWidth > parent.width ? Text.ElideRight : Text.ElideNone
                            popup.textWidth = text.contentWidth
                            cooldown.interval = 4000 + popup.textWidth
                            cooldown.start()
                        }
                    }
                }

                Timer {
                    id: cooldown
                    running: false
                    onTriggered: {
                        const idx = root.notifs.findIndex(n => n.id === modelData.id)
                        if (idx !== -1) {
                            root.notifs.splice(idx, 1)
                            root.implicitHeight = 125 * root.notifs.length
                            repeater.model = root.notifs
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        const idx = root.notifs.findIndex(n => n.id === modelData.id)
                        if (idx !== -1) {
                            root.notifs.splice(idx, 1)
                            root.implicitHeight = 125 * root.notifs.length
                            repeater.model = root.notifs
                        }
                    }
                }
            }
        }
    }
}

