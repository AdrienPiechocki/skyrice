import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.Modules.Bar
import Niri

Item {
    id: root
    property var notification
    Niri {
        id: niri
        Component.onCompleted: connect()

        onConnected: console.log("Connected to niri")
        onErrorOccurred: function(error) {
            console.error("Connection error:", error)
        }
    }
    Variants {
        model: Quickshell.screens
        PanelWindow {
            property var modelData
            screen: modelData
            anchors {
                top: true
                left: true
                right: true
            }
            implicitHeight: 35
            color: "transparent"
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.25; color: "black" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
            RowLayout {
                anchors.fill: parent
                spacing: 30
                Item{}
                Menu{ screenX:modelData.x }
                Item{}
                FocusedWindow{_niri: niri}
                Item{}
                Audio{}
                Item{ Layout.fillWidth: true }
                Tray{ Layout.maximumWidth: items?.values.length * 40 || 40; screenX:modelData.x }
                Item{}
                System{ screenX:modelData.x; notification: root.notification}
                Item{}
                Clock{}
                Item{}
            }
            Workspaces{_niri: niri; anchors.centerIn: parent; screen: modelData.name }

        }
    }
}

