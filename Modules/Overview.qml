import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland

PanelWindow {
    WlrLayershell.namespace: "quickshell-overview-bg"
    WlrLayershell.layer: WlrLayer.Background
    exclusionMode: ExclusionMode.Ignore  // requis, sinon la layer-rule ne match pas
    anchors { top: true; bottom: true; left: true; right: true }

    // Image background with GPU-based blur
    Image {
        anchors.fill: parent
        source: "../Assets/Wallpaper.jpeg"
        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: 0.8
        }
    }
}