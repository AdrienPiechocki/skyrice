import Quickshell
import QtQuick
import QtQuick.Controls
import Quickshell.Wayland
import qs.Commons
import qs.Services

LazyLoader {
    id: root
    active: false
    property bool locked: true
    required property LockContext context

    WlSessionLock {
        id: lock
        locked: root.locked
        WlSessionLockSurface {
            id: surface
            color: "black"
            Image {
                anchors.fill: parent
                source: "../Assets/Wallpaper.jpeg"

                FontLoader {
                    id: futuraFont
                    source: "../Assets/Fonts/Futura Condensed Medium.ttf"
                }

                Label {
                    id: clock
                    property var date: new Date()
                    readonly property list<string> days: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
                    readonly property list<string> months: ["January", "February", "March", "April", "May", "June", "Jully", "August", "September", "October", "November", "December"]
                    color: "#cecece"
                    style: Text.Outline
                    font.family: futuraFont.name
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    // The native font renderer tends to look nicer at large sizes.
                    renderType: Text.NativeRendering
                    font.pointSize: 80

                    // updates the clock every second
                    Timer {
                        running: true
                        repeat: true
                        interval: 1000

                        onTriggered: {
                            clock.date = new Date();
                        }
                    }

                    function getFullDate(date) {
                        if (!date) {
                            date = new Date();
                        }
                        const year = date.getFullYear();

                        // getMonth() is zero-based, so we add 1
                        const month = clock.months[date.getMonth()];
                        const day = String(date.getDate()).padStart(2, '0');
                        const m_day = clock.days[date.getDay()-1];

                        const hours = String(date.getHours()).padStart(2, '0');
                        const minutes = String(date.getMinutes()).padStart(2, '0');
                        const seconds = String(date.getSeconds()).padStart(2, '0');

                        return `${m_day},\n${month} ${day} ${year}\n${hours}:${minutes}:${seconds}\n`;
                    }

                    // updated when the date changes
                    text: clock.getFullDate(date)
                }

                Capsule{ 
                    x: surface.width/2 - surface.width/16
                    y: surface.height/1.5
                    width: surface.width/8
                    _color: '#b0000000'
                    Rectangle {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        color: "transparent"
                        clip: true
                        TextField {
                            id: input
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            placeholderText: "PASSWORD"
                            background: null
                            selectByMouse: true
                            focus: true
                            placeholderTextColor: "#cecece"
                            color: "white"
                            font.family: futuraFont.name
                            font.pixelSize: 24
                            text: ""
                            passwordCharacter: "*"
                            echoMode: TextInput.Password
                            onTextChanged: root.context.currentText = this.text;
                            onAccepted: root.context.tryUnlock();
                        }
                    }
                }
            }
        }
    }
}