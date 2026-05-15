import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.Modules.Bar

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
            Window{}
            Item{}
            Audio{}
            Item{ Layout.fillWidth: true }
            Tray{ Layout.maximumWidth: items?.values.length * 30 || 30; screenX:modelData.x }
            Item{}
            System{ screenX:modelData.x }
            Item{}
            Clock{}
            Item{}
        }
        Workspaces{ anchors.centerIn: parent; screen: modelData.name }

    }
}
