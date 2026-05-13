import Quickshell
import Quickshell.Niri
import QtQuick
import qs.Commons

Capsule {
    id: root
    width: 100
    _color: hoverHandler.hovered ? "#67cecece" : "#67000000" 
    HoverHandler { id: hoverHandler }
    Timer {
        running: true
        interval: 250
        repeat: true
        onTriggered: {
            if (window.contentWidth <= window.width && scrollAnim.running) { scrollAnim.running = false; window.x = 0}
            if (!scrollAnim.running) {
                window.x = 0
            }
        }
    }

    Image {
        fillMode: Image.PreserveAspectFit
        height: 20
        y: 5
        x: 1
        opacity: Niri.focusedWindow ? DesktopEntries.applications.values.filter(a => a.name.toLowerCase().match(Niri.focusedWindow ? Niri.focusedWindow?.appId.toLowerCase():""))[0]?.icon ? 1 : 0 : 0
        source: Quickshell.iconPath(DesktopEntries.applications.values.filter(a => a.name.toLowerCase().match(Niri.focusedWindow ? Niri.focusedWindow?.appId.toLowerCase():""))[0]?.icon)
    }
    Rectangle{
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width - 22
        color: "transparent"
        clip: true
        FontLoader {
            id: futuraFont
            source: "../../Assets/Fonts/Futura Condensed Medium.ttf"
        }
        Text {
            id: window
            horizontalAlignment: window.contentWidth > window.width ? Text.AlignLeft : Text.AlignHCenter
            property int speed: window.contentWidth * 30
            font.family: futuraFont.name
            font.pointSize: 14
            style: Text.Outline
            color: '#cecece'
            width: parent.width
            x: 0
            y: 2.5
            text: Niri.focusedWindow?.title || ""
            SequentialAnimation on x {
                id: scrollAnim
                running: hoverHandler.hovered ? window.contentWidth > window.width : false
                NumberAnimation { 
                    to: -window.contentWidth 
                    duration: window.speed
                }
                onFinished: {window.x = 200; restart()}
            }
        }
    }
    Connections {
        target: Niri
        function onWindowsUpdated() {
            window.text = Niri.focusedWindow?.title || ""
        }
    }
    Connections {
        target: window
        ignoreUnknownSignals: true
        function onTextChanged() {
            window.x = 0;
        }
    }
}

