import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Niri
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import qs.Commons

Capsule {
    id: root
    property var screen: null
    property var _niri

    Process {
        id: focusColumnLeft
        running: false
        command: ["niri", "msg", "action", "focus-column-left"]
    }
    Process {
        id: focusColumnRight
        running: false
        command: ["niri", "msg", "action", "focus-column-right"]
    }

    Process {
        id: focusWorkspaceUp
        running: false
        command: ["niri", "msg", "action", "focus-workspace-up"]
    }
    Process {
        id: focusWorkspaceDown
        running: false
        command: ["niri", "msg", "action", "focus-workspace-down"]
    }
    width: 500
    _color: "#67000000"
    MouseArea { 
        anchors.fill: parent; 
        onWheel: (event)=> {
            if(event.angleDelta.y > 0) {
                focusWorkspaceUp.running = true;
            }
            else {
                focusWorkspaceDown.running = true;
            }
        }
    }

    FontLoader {
        id: futuraFont
        source: "../../Assets/Fonts/Futura Condensed Medium.ttf"
    }
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 30
        anchors.rightMargin: 30
        spacing: 5

        Repeater {
            // model est directement le tableau filtré — chaque item reçoit modelData
            model: _niri.workspaces

            Rectangle {
                visible: model.output == root.screen
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                color: "transparent"

                // modelData = le workspace de cet item
                property bool isActive: model.isActive
                
                Capsule {
                    id: capsule
                    anchors.centerIn: parent
                    height: 20
                    width: 40
                    color: "#67000000" 
                    active: false
                    Text {
                        id: wsText
                        anchors.centerIn: parent
                        text: index
                        color: isActive ? '#ffffff' : '#cecece'
                        style: Text.Outline
                        font {
                            family: futuraFont.name
                            pixelSize: isActive ? 20 : 14
                            bold: isActive
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onPressed: {niri.focusWorkspace(index); capsule.color = '#b6ffffff'}
                        onReleased: capsule.color = "#67cecece" 
                        hoverEnabled: true
                        onEntered: capsule.color ="#67cecece"
                        onExited: capsule.color ="#67000000"
                        onWheel: (event)=> {
                            if(event.angleDelta.y > 0) {
                                focusColumnLeft.running = true;
                            }
                            else {
                                focusColumnRight.running = true;
                            }
                        }
                    }
                }
            }
        }
    }
    
}