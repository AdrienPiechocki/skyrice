import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Services

LazyLoader {
    id: root
    active: false
    property int popupX: 0
    property int popupY: 0
    readonly property var gpuUsagePath: Quickshell.shellDir + "/Scripts/gpu_usage.sh" 
    property int gpuUsage: 0
    property int diskUsage: 0
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
            implicitHeight: 300
            implicitWidth: 225
            color: "transparent"
            
            Process {
                id: gpuUsage
                running: true
                command: [ "sh", "-c", root.gpuUsagePath ]
                stdout: StdioCollector {
                    onStreamFinished: {
                        gpuText.usage = text
                        root.gpuUsage = text
                    }
                }
            }
            Process {
                id: diskUsage
                running: true
                command: [ "sh", "-c", "df -h | grep '/$' | awk '{print $5}' | tr -d '%'" ]
                stdout: StdioCollector {
                    onStreamFinished: {
                        diskText.usage = text
                        root.diskUsage = text
                    }
                }
            }
            Timer {
                running: true
                interval: 2500
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    gpuUsage.running = true
                    diskUsage.running = true
                }
            }
            
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
                    spacing: 0
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: -5
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "transparent"
                                Text {
                                    id: gpuText
                                    property int usage: 0
                                    anchors.centerIn: parent
                                    text: `GPU - ${usage}%`
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
                                    height: 16
                                    Rectangle {
                                        anchors.centerIn: parent
                                        height: parent.height
                                        width: parent.width - gpuText.usage
                                        color: '#166f1a'
                                        border.width: 2
                                        border.color: "#67184a13"
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
                            spacing: -5
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "transparent"
                                Text {
                                    id: cpuText
                                    anchors.centerIn: parent
                                    text: `CPU - ${Math.round(CPU.overallUsage * 100)}%`
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
                                    height: 16
                                    Rectangle {
                                        anchors.centerIn: parent
                                        height: parent.height
                                        width: parent.width - Math.round(CPU.overallUsage * 100)
                                        color: '#6f1616'
                                        border.width: 2
                                        border.color: "#674a1313"
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
                            spacing: -5
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "transparent"
                                Text {
                                    id: ramText
                                    anchors.centerIn: parent
                                    text: `RAM - ${Math.round(RAM.used / RAM.total * 100) || 0}%`
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
                                    height: 16
                                    Rectangle {
                                        anchors.centerIn: parent
                                        height: parent.height
                                        width: parent.width - (Math.round(RAM.used / RAM.total * 100)||0)
                                        color: '#16476f'
                                        border.width: 2
                                        border.color: "#6713314a"
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
                            spacing: -5
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "transparent"
                                Text {
                                    id: diskText
                                    anchors.centerIn: parent
                                    property int usage: 0
                                    text: `Disk - ${diskText.usage}%`
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
                                    _color: '#67474a13' 
                                    height: 16
                                    Rectangle {
                                        anchors.centerIn: parent
                                        height: parent.height
                                        width: parent.width - diskText.usage
                                        color: '#6f6c16'
                                        border.width: 2
                                        border.color: '#67484a13'
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