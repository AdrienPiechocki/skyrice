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
            "text": n.summary || "",
            "appName": n.appName || n.desktopEntry || "",
            "urgency": n.urgency < 0 || n.urgency > 2 ? 1 : n.urgency,
            "timestamp": time,
            "actionsJson": JSON.stringify((n.actions || []).map(a => ({
                "text": (a.text || "").trim() || "Action",
                "identifier": a.identifier || ""
                })))
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
                y: 45 + 125 * repeater.model.indexOf(popup.modelData)
                color: "transparent"
                Background{ width: popup.width; height: popup.height; stroke: 2}
                FontLoader {
                    id: futuraFont
                    source: "../Assets/Fonts/Futura Condensed Medium.ttf"
                }
                Text {
                    x: contentWidth
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
                        text: modelData.text
                        font.family: futuraFont.name
                        font.pointSize: 18
                        style: Text.Outline
                        wrapMode: Text.WordWrap
                        Component.onCompleted: elide = contentHeight > parent.height || contentWidth > parent.width ? Text.ElideRight : Text.ElideNone
                    }
                }

                Timer {
                    running: true
                    interval: 1000 + text.contentWidth * 20
                    onTriggered: {
                        root.notifs.splice(modelData.idx, 1)
                        root.implicitHeight = 125 * root.notifs.length
                        repeater.model = root.notifs
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.notifs.splice(root.notifs.indexOf(modelData), 1)
                        root.implicitHeight = 125 * root.notifs.length
                        repeater.model = root.notifs
                    }
                }
            }
        }
    }
}

