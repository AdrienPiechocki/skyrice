import Quickshell
import Quickshell.Io
import QtQuick
import qs.Commons
import qs.Modules.Widgets

Capsule {
    id: root
    width: 15
    property int screenX: 0
    _color: tapHandler.pressed ? '#b6ffffff' : hoverHandler.hovered ? "#67cecece" : "#67000000" 
    Image {
        id: logo
        fillMode: Image.PreserveAspectFit
        anchors.centerIn: parent
        height: 25
        source: "../../Assets/Logo.png"
    }
    TapHandler { 
        id: tapHandler; 
        onTapped: tween.active = true
    }
    
    HoverHandler { id: hoverHandler }

    IpcHandler {
        target: "inventory"
        function toggle() { logout.active = false; inventory.active = !inventory.active }
    }
    IpcHandler {
        target: "logout"
        function toggle() { inventory.active = false; logout.active = !logout.active }
    }

    Launcher{ id: inventory; screenX: root.screenX; _width:Screen.width/3; _height:Screen.height}
    Logout{ id: logout; }

    TweenMenu{ id: tween; width:Screen.width/2; height:Screen.height/2; screenX: root.screenX; inventory:inventory; logout:logout }
}