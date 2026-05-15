import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Commons

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
            implicitHeight: 250
            implicitWidth: 250
            color: "transparent"
            
            
            FontLoader {
                id: futuraFont
                source: "../../Assets/Fonts/Futura Condensed Medium.ttf"
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
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"
                        ColumnLayout {
                            anchors.fill: parent
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "transparent"
                                Text {
                                    anchors.centerIn: parent
                                    text: "GPU - 0%"
                                    color: "white"
                                    font.family: futuraFont.name
                                    font.pointSize: 14
                                    style: Text.Outline
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "transparent"
                                Capsule {
                                    anchors.centerIn: parent
                                    _color: '#67184a13' 
                                    height: 20
                                    Rectangle {
                                        anchors.fill: parent
                                        color: '#166f1a'
                                    }
                                }
                            }
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
                                Layout.fillHeight: true
                                color: "transparent"
                                Text {
                                    anchors.centerIn: parent
                                    text: "CPU - 0%"
                                    color: "white"
                                    font.family: futuraFont.name
                                    font.pointSize: 14
                                    style: Text.Outline
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "transparent"
                                Capsule {
                                    anchors.centerIn: parent
                                    _color: '#674a1313' 
                                    height: 20
                                    Rectangle {
                                        anchors.fill: parent
                                        color: '#6f1616'
                                    }
                                }
                            }
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
                                Layout.fillHeight: true
                                color: "transparent"
                                Text {
                                    anchors.centerIn: parent
                                    text: "RAM - 0%"
                                    color: "white"
                                    font.family: futuraFont.name
                                    font.pointSize: 14
                                    style: Text.Outline
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "transparent"
                                Capsule {
                                    anchors.centerIn: parent
                                    _color: '#6713314a' 
                                    height: 20
                                    Rectangle {
                                        anchors.fill: parent
                                        color: '#16476f'
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