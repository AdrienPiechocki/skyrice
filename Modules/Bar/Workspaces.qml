import Quickshell
import Quickshell.Wayland
import Quickshell.Niri
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import qs.Commons

Capsule {
    id: root
    property var screen: null

    // Workspaces filtrés pour CET écran uniquement
    property var screenWorkspaces: Niri.workspaces.values.filter(w => w.output === screen)
    property var currentWorkspaceIndex: screenWorkspaces.filter(w => w.active)[0].idx

    function switchToWorkspace(ws) {
        try {
            Niri.dispatch(["focus-workspace", ws]);
        } catch (e) {
            print("Niri Failed to switch workspace:", e);
        }
    }
    width: 500
    _color: "#67000000"
    MouseArea { 
        anchors.fill: parent; 
        onWheel: (event)=> {
            if(event.angleDelta.y > 0) {
                root.switchToWorkspace(root.currentWorkspaceIndex-1)
            }
            else {
                root.switchToWorkspace(root.currentWorkspaceIndex+1)
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
            model: screenWorkspaces

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                color: "transparent"

                // modelData = le workspace de cet item
                property var ws: modelData
                property bool isActive: modelData.active
                
                Capsule {
                    id: capsule
                    anchors.centerIn: parent
                    height: 20
                    width: 40
                    color: tapHandler.pressed ? '#b6ffffff' : hoverHandler.hovered ? "#67cecece" : "#67000000" 
                    active: false
                    TapHandler { id: tapHandler; onTapped: root.switchToWorkspace(index + 1)}
                    HoverHandler { id: hoverHandler }
                    Text {
                        id: wsText
                        anchors.centerIn: parent
                        text: index + 1
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
                        onWheel: (event)=> {
                            if(event.angleDelta.y > 0) {
                                Niri.dispatch(["focus-column-left"]);
                            }
                            else {
                                Niri.dispatch(["focus-column-right"]);
                            }
                        }
                    }
                }
            }
        }
    }
    
}