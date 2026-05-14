import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.Commons

LazyLoader {
    id: root
    active: false
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
            margins.left: Screen.width/2 - width/2
            margins.top: Screen.height/2 - height/2
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            implicitHeight: 400
            implicitWidth: 200
            color: "transparent"
            Background{ width: parent.width; height: parent.height; stroke: 2}
            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 40
                anchors.bottomMargin: 40
                anchors.leftMargin: 25
                anchors.rightMargin: 25
                color: "transparent"

                FontLoader {
                    id: futuraFont
                    source: "../../Assets/Fonts/Futura Condensed Medium.ttf"
                }

                Gradient {
                    id: gradient
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0; color: "transparent" }
                    GradientStop { position: 0.5; color: "#67cecece" }
                    GradientStop { position: 1; color: "transparent" }
                }
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    Rectangle {
                        id: lock
                        Layout.preferredWidth: parent.width
                        Layout.preferredHeight: parent.height/4
                        color: "transparent"
                        Text {
                            anchors.centerIn: parent
                            color: "white"
                            text: "Lock"
                            font.pointSize: 24
                            font.family: futuraFont.name
                            style: Text.Outline
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                print("lock")
                            }
                            hoverEnabled: true
                            onEntered: parent.gradient = gradient
                            onExited: parent.gradient = Gradient.Transparent
                        }
                    }
                    Rectangle {
                        id: logout
                        Layout.preferredWidth: parent.width
                        Layout.preferredHeight: parent.height/4
                        color: "transparent"
                        Text {
                            anchors.centerIn: parent
                            color: "white"
                            text: "Logout"
                            font.pointSize: 24
                            font.family: futuraFont.name
                            style: Text.Outline
                        }
                        Process {
                            id: logoutProcess
                            running: false
                            command: [ "sh", "-c", "niri msg action quit" ]
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                logoutProcess.running = true
                            }
                            hoverEnabled: true
                            onEntered: parent.gradient = gradient
                            onExited: parent.gradient = Gradient.Transparent
                        }
                    }
                    Rectangle {
                        id: reboot
                        Layout.preferredWidth: parent.width
                        Layout.preferredHeight: parent.height/4
                        color: "transparent"
                        Text {
                            anchors.centerIn: parent
                            color: "white"
                            text: "Reboot"
                            font.pointSize: 24
                            font.family: futuraFont.name
                            style: Text.Outline
                        }
                        Process {
                            id: rebootProcess
                            running: false
                            command: [ "sh", "-c", "reboot now" ]
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                rebootProcess.running = true
                            }
                            hoverEnabled: true
                            onEntered: parent.gradient = gradient
                            onExited: parent.gradient = Gradient.Transparent
                        }
                    }
                    Rectangle {
                        id: shutdown
                        Layout.preferredWidth: parent.width
                        Layout.preferredHeight: parent.height/4
                        color: "transparent"
                        Text {
                            anchors.centerIn: parent
                            color: "white"
                            text: "Shutdown"
                            font.pointSize: 24
                            font.family: futuraFont.name
                            style: Text.Outline
                        }
                        Process {
                            id: shutdownProcess
                            running: false
                            command: [ "sh", "-c", "systemctl poweroff" ]
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                shutdownProcess.running = true
                            }
                            hoverEnabled: true
                            onEntered: parent.gradient = gradient
                            onExited: parent.gradient = Gradient.Transparent
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