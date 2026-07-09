import Quickshell
import QtQuick
import Quickshell.Services.Mpris 
import qs.Commons

Capsule {
    id: root
    width: 200
    active: player?.isPlaying
    _color: hoverHandler.hovered ? "#67cecece" : "#67000000" 
    HoverHandler { id: hoverHandler }
    property list<MprisPlayer> players: Mpris.players.values
    property int playerIndex: {root.players.findIndex(p => p.isPlaying) == -1 ? 0 : root.players.findIndex(p => p.isPlaying)}
    property MprisPlayer player: players.length > 0 ? players[playerIndex % players.length] : null
    property bool changed: false
    property int pos: changed ? 0 : player?.position || 0
    property real trackLength: 100.0
    Timer {
        running: true
        interval: 500
        repeat: true
        onTriggered: {
            let newPlayerIndex = root.players.findIndex(p => p.isPlaying);
            if (newPlayerIndex === -1) {
                newPlayerIndex = 0;
            }
            if (newPlayerIndex != root.playerIndex) {
                root.playerIndex = newPlayerIndex
                player = players[playerIndex % players.length];
                root.pos = player.position;
                player.trackChanged()
            }
            title.text = player?.isPlaying ? player?.trackTitle : ""
            title.speed = title.contentWidth * 30;
            title.horizontalAlignment = title.contentWidth > title.width ? Text.AlignLeft : Text.AlignHCenter
            if (title.contentWidth <= title.width && scrollAnim.running) { scrollAnim.running = false; title.x = 0}
        }
    }
    Timer {
        running: player?.isPlaying
        interval: 1000
        repeat: true
        onTriggered: {
            if (player && player.length > 0) {
                if (player.lengthSupported) {
                    root.trackLength = player.length
                }
                img.progress = root.pos * 100 / root.trackLength;
            } else {
                img.progress = 0;
            }
            if (root.pos < player.position && root.changed) { 
                root.changed = false
                root.pos = 0;
            }
            root.pos ++;
        }
    }
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        clip: true
        
        Loader {
            anchors.fill: parent
            active: true
            asynchronous: true
            sourceComponent: AudioVisualizer{visible: root.active}
        }
        Track{ id: img; visible: root.active; anchors.bottom: parent.bottom; anchors.bottomMargin: 5; anchors.left: parent.left; anchors.leftMargin: 15; }
        FontLoader {
            id: futuraFont
            source: "../../Assets/Fonts/Futura Condensed Medium.ttf"
        }
        Text {
            id: title
            horizontalAlignment: title.contentWidth > title.width ? Text.AlignLeft : Text.AlignHCenter
            property int speed: title.contentWidth * 30
            font.family: futuraFont.name
            font.pointSize: 12
            style: Text.Outline
            color: '#cecece'
            width: parent.width
            x: 0
            SequentialAnimation on x {
                id: scrollAnim
                running: hoverHandler.hovered ? title.contentWidth > title.width : false
                NumberAnimation { 
                    to: -title.contentWidth 
                    duration: title.speed
                }
                onFinished: {title.x = 250; restart()}
            }
        }
        Timer {
            running: true
            interval: 500
            repeat: true
            onTriggered: {
                if (!scrollAnim.running) {
                    title.x = 0
                }
            }
        }
    }
    Connections {
        target: player
        ignoreUnknownSignals: true
        
        function onTrackChanged() {
            title.x = 0;
            root.pos = 0;
            root.changed = true;
            title.text = player?.isPlaying ? player?.trackTitle : ""
        }

        function onPositionChanged() {
            root.pos = root.changed ? 0 : player.position;
        }
    }
    Connections {
        target: title
        ignoreUnknownSignals: true
        function onTextChanged() {
            title.x = 0;
        }
    }
}