import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.UPower
import qs.Commons
import qs.Services

LazyLoader {
    id: root
    active: false
    property int popupX: 0
    property int popupY: 0
    readonly property var gpuUsagePath: Quickshell.shellDir + "/Scripts/gpu_usage.sh" 
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
            implicitHeight: 100
            implicitWidth: 250
            color: "transparent"
            
            FontLoader {
                id: futuraFont
                source: "../../Assets/Fonts/Futura Condensed Medium.ttf"
            }

            Background{ width: parent.width; height: parent.height; stroke: 2}
            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 30
                anchors.bottomMargin: 20
                anchors.leftMargin: 25
                anchors.rightMargin: 25
                color: "transparent"
                property list<string> profiles: ["power-saver", "balanced", "performance"]
                Text {
                    x: parent.width/2 - contentWidth/2
                    y: 0
                    color: "white"
                    text: "Profile: " + parent.profiles[PowerProfiles.profile]
                }
                Slider {
                    anchors.centerIn: parent
                    from: 0
                    value: 1
                    to: 2
                    stepSize: 1
                    snapMode: Slider.SnapAlways
                    Component.onCompleted: value = PowerProfiles.profile
                    onValueChanged: PowerProfiles.profile = value
                }
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: root.active = false
        }
    }
}