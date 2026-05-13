import Quickshell
import QtQuick
import qs.Commons
import qs.Modules.Widgets

Capsule {
    id: root
    width: 15
    property int screenX: 0
    Image {
        id: logo
        fillMode: Image.PreserveAspectFit
        anchors.centerIn: parent
        height: 25
        source: "../../Assets/Logo.png"
    }
    TapHandler { 
        id: tapHandler; 
        onTapped: inventory.active = true
    }

    Launcher{ id: inventory; screenX: root.screenX; _width:Screen.width/3; _height:Screen.height}
}