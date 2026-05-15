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
    readonly property var weatherScriptPath: Quickshell.shellDir + "/Scripts/weather.py" 
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
            anchors.right: parent.right
            anchors.top: parent.top
            margins.top: 40
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            implicitHeight: 400
            implicitWidth: 400
            color: "transparent"
            
            Process {
                id: weatherProc
                running: false
                command: [ "python3", root.weatherScriptPath ]
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
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: root.active = false
        }
    }
}