import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import qs.Commons
import qs.Modules.Widgets

Capsule {
    id: root
    property var items: SystemTray.items
    property int posX: 0
    property int posY: 0
    property int screenX: 0

    function updatePos(x, y) {
        posX = x
        posY = y
    }

    FontLoader {
        id: futuraFont
        source: "../../Assets/Fonts/Futura Condensed Medium.ttf"
    }
    _color: "#67000000"
    active: items.values.length > 0
    RowLayout {
        anchors.fill: parent
        spacing: 5
        Repeater {
            model: root.items
            Capsule {
                id: item
                color: tapHandler_left.pressed || tapHandler_right.pressed ? '#b6ffffff' : hoverHandler.hovered ? "#67cecece" : "#67000000" 
                active: false
                z: -index
                TapHandler { id: tapHandler_left; onTapped: root.items.values[index].activate() }
                TapHandler { id: tapHandler_right; acceptedButtons: Qt.RightButton; onTapped: {
                        var screenPos = item.mapToGlobal(0, 0);
                        root.updatePos(screenPos.x - root.screenX, screenPos.y + root.height);
                        menu.data = root.items.values[index].menu;
                        menu.active = !menu.active;
                    }
                }
                HoverHandler { id: hoverHandler; }
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: 22
                Layout.maximumHeight: 22
                Image {
                    id: logo
                    fillMode: Image.PreserveAspectFit
                    anchors.centerIn: item
                    height: 20
                    source: root.items.values[index]?.icon || ""
                }
            }
        }
    }
    TrayMenu{ id: menu; popupX: root.posX; popupY: root.posY; }
}