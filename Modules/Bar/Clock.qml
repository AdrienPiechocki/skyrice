import Quickshell
import QtQuick
import qs.Commons

Capsule {
    id: root
    width: 50
    _color: hoverHandler.hovered ? "#67cecece" : "#67000000" 
    HoverHandler { id: hoverHandler }
    FontLoader {
        id: futuraFont
        source: "../../Assets/Fonts/Futura Condensed Medium.ttf"
    }
    Text {
        anchors.centerIn: parent
        id: clock
        color: "white"
        font { family: futuraFont.name; pixelSize: 16; bold: true }
        style: Text.Outline
        text: Qt.formatDateTime(new Date(), "HH:mm")
        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clock.text = Qt.formatDateTime(new Date(), "HH:mm")
        }
    }
}