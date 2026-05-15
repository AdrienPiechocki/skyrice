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
            implicitHeight: 200
            implicitWidth: 300
            color: "transparent"
            Background{ width: parent.width; height: parent.height; stroke: 2}
        }
        MouseArea {
            anchors.fill: parent
            onClicked: root.active = false
        }
    }
}