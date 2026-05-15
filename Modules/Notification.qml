import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import Quickshell.Niri
import qs.Commons

Item {
    id: root
    property var notifs: []
    signal changed
    function remove(id) {
        if (id !== -1) {
            root.notifs.splice(id, 1)
            root.changed()
        }
    }
    NotificationServer {
        keepOnReload: false
        imageSupported: true
        actionsSupported: true
        onNotification: notification => {
            const data = createData(notification)
            root.notifs.push(data)
            root.changed()
        }
        function createData(n) {
            const time = Qt.formatDateTime(new Date(), "HH:mm")
            const image = n.image || getIcon(n.appIcon);

            return {
                "id": n.id,
                "summary": n.summary || "",
                "body": n.body || "",
                "appName": n.appName || n.desktopEntry || "",
                "urgency": n.urgency < 0 || n.urgency > 2 ? 1 : n.urgency,
                "timestamp": time,
                "image": image
            };
        }
        function getIcon(icon) {
        if (!icon)
            return "";
        if (icon.startsWith("/") || icon.startsWith("file://"))
            return icon;
        }
    }
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: panel
            property var modelData
            screen: modelData
            anchors.top: true
            margins.top: 45
            anchors.right: true
            margins.right: 25
            implicitWidth: 350
            implicitHeight: 125 * root.notifs.length
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            
            Connections {
                target: root
                function onChanged() {
                    panel.implicitHeight = 125 * root.notifs.length
                    repeater.model = root.notifs
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
                            anchors.left: parent.left
                            anchors.leftMargin: 25
                            anchors.top: parent.top
                            anchors.topMargin: parent.height/2 - height/2
                            height: 50
                            width: 50
                            radius: 20
                            color: "transparent"
                            clip: true
                            Image {
                                fillMode: Image.PreserveAspectFit
                                anchors.fill: parent
                                height: 50
                                source: modelData.image
                            }
                        }
                        Rectangle {
                            anchors.top: parent.top
                            anchors.topMargin: 35
                            anchors.left: parent.left
                            anchors.leftMargin: 75
                            width: 225
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
                                font.pointSize: 14
                                style: Text.Outline
                                wrapMode: Text.WordWrap
                                Component.onCompleted: {
                                    elide = contentHeight > parent.height || contentWidth > parent.width ? Text.ElideRight : Text.ElideNone
                                    popup.textWidth = text.contentWidth
                                    cooldown.interval = 5000 + popup.textWidth
                                    cooldown.start()
                                }
                            }
                        }

                        Timer {
                            id: cooldown
                            running: false
                            onTriggered: {
                                const idx = root.notifs.findIndex(n => n.id === modelData.id)
                                root.remove(idx)
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                const idx = root.notifs.findIndex(n => n.id === modelData.id)
                                root.remove(idx)
                            }
                        }
                    }
                }
            }
        }
    }
}