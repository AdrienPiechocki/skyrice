import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.Commons
import qs.Modules.Widgets

Variants {
  model: Quickshell.screens
  PanelWindow {
    property var modelData
    screen: modelData

    anchors {
      top: true
      left: true
      right: true
      bottom: true
    }
    
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Background

    Image {
      anchors.fill: parent
      source: "../Assets/Wallpaper.jpeg"
    }
  }
}