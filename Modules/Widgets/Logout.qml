import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.Commons
import qs.Modules
import qs.Services

LazyLoader {
    id: root
    active: false
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
            margins.left: Screen.width/2 - width/2
            margins.top: Screen.height/2 - height/2
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            implicitHeight: 400
            implicitWidth: 250
            color: "transparent"
            property int time: 5
            property string text: ""
            property int focusedIndex: -1
            property list<string> options: ["lock", "logout", "reboot", "shutdown"]
            Item {
                anchors.fill: parent
                focus: true
                Keys.onEscapePressed: {
                    if(logoutTimer.running || rebootTimer.running || shutdownTimer.running) {
                        logoutTimer.stop()
                        rebootTimer.stop()
                        shutdownTimer.stop()
                        timer.stop()
                        info.text = "Chose an option"
                        info.canCancel = false
                    }
                    else {
                        root.active = false
                    }
                }
                Keys.onDownPressed: {
                    if (window.focusedIndex < 0) {
                        window.focusedIndex = 0
                    }
                    else {
                        if (window.focusedIndex+1 > 3) {
                            window.focusedIndex = 0
                        }
                        else {
                            window.focusedIndex ++
                        }
                    }
                    for (let i = 0; i < window.options.length; i++) {
                        layout.children.filter(c => c.objectName == window.options[i])[0].focused = false
                        layout.children.filter(c => c.objectName == window.options[i])[0].gradient = Gradient.Transparent
                    }
                    layout.children.filter(c => c.objectName == window.options[window.focusedIndex])[0].focused = true
                    layout.children.filter(c => c.objectName == window.options[window.focusedIndex])[0].gradient = gradient
                }
                Keys.onUpPressed: {
                    if (window.focusedIndex < 0) {
                        window.focusedIndex = 3
                    }
                    else {
                        if (window.focusedIndex-1 < 0) {
                            window.focusedIndex = 3
                        }
                        else {
                            window.focusedIndex --
                        }
                    }
                    for (let i = 0; i < window.options.length; i++) {
                        layout.children.filter(c => c.objectName == window.options[i])[0].focused = false
                        layout.children.filter(c => c.objectName == window.options[i])[0].gradient = Gradient.Transparent
                    }
                    layout.children.filter(c => c.objectName == window.options[window.focusedIndex])[0].focused = true
                    layout.children.filter(c => c.objectName == window.options[window.focusedIndex])[0].gradient = gradient
                }
                Keys.onReturnPressed: {
                    if (window.focusedIndex >= 0) {
                        layout.children.filter(c => c.objectName == window.options[window.focusedIndex])[0].execute()
                    }
                }
            }
            Background{ width: parent.width; height: parent.height; stroke: 2}
            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 40
                anchors.bottomMargin: 40
                anchors.leftMargin: 25
                anchors.rightMargin: 25
                color: "transparent"

                FontLoader {
                    id: futuraFont
                    source: "../../Assets/Fonts/Futura Condensed Medium.ttf"
                }

                Gradient {
                    id: gradient
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0; color: "transparent" }
                    GradientStop { position: 0.5; color: "#67cecece" }
                    GradientStop { position: 1; color: "transparent" }
                }

                Timer {
                    id: timer
                    running: false
                    interval: 1000
                    onTriggered: {
                        if (window.time > 0) {
                            window.time --
                            info.text = `${window.text} in ${window.time}`
                            timer.start()
                        }
                        else {
                            window.time = 0
                        }
                    }
                }

                ColumnLayout {
                    id: layout
                    anchors.fill: parent
                    spacing: 0

                    Rectangle {
                        id: info
                        property string text: "Chose an option"
                        property bool canCancel: false
                        Layout.preferredWidth: parent.width
                        Layout.preferredHeight: parent.height/8
                        color: "transparent"
                        RowLayout {
                            anchors.fill: parent
                            spacing: 10
                            Text {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                color: "white"
                                text: info.text
                                font.pointSize: 18
                                font.family: futuraFont.name
                                style: Text.Outline
                            }
                            Rectangle {
                                visible: info.canCancel
                                Layout.preferredWidth: 35
                                Layout.preferredHeight: 35
                                radius: 25
                                color: "#42cecece"
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 12
                                    height: 12
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        logoutTimer.stop()
                                        rebootTimer.stop()
                                        shutdownTimer.stop()
                                        timer.stop()
                                        info.text = "Chose an option"
                                        info.canCancel = false
                                    }
                                    hoverEnabled: true
                                    onEntered: parent.color = "#67cecece"
                                    onExited: parent.color = "#42cecece"
                                }
                            }
                        }
                    }
                    Rectangle {
                        id: lock
                        objectName: "lock"
                        property bool focused: false
                        Layout.preferredWidth: parent.width
                        Layout.preferredHeight: parent.height/5
                        color: "transparent"
                        gradient: focused ? gradient : Gradient.Transparent
                        function execute() {
                            lockscreen.active = true
                            window.visible = false
                        }
                        Text {
                            anchors.centerIn: parent
                            color: "white"
                            text: "Lock"
                            font.pointSize: 24
                            font.family: futuraFont.name
                            style: Text.Outline
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: lock.execute()
                            hoverEnabled: true
                            onEntered: parent.gradient = gradient
                            onExited: parent.gradient = parent.focused ? gradient : Gradient.Transparent
                        }
                    }
                    Rectangle {
                        id: logout
                        objectName: "logout"
                        property bool focused: false
                        Layout.preferredWidth: parent.width
                        Layout.preferredHeight: parent.height/5
                        color: "transparent"
                        gradient: focused ? gradient : Gradient.Transparent
                        function execute() {
                            rebootTimer.stop()
                            shutdownTimer.stop()
                            if (logoutTimer.running) {
                                logoutTimer.stop()
                                logoutProcess.running = true
                            }
                            else {
                                logoutTimer.stop()
                                logoutTimer.start()
                                window.time = 5
                                window.text = "Logging out"
                                info.text = `${window.text} in ${window.time}`
                                timer.start()
                                info.canCancel = true
                            }
                        }
                        Text {
                            anchors.centerIn: parent
                            color: "white"
                            text: "Logout"
                            font.pointSize: 24
                            font.family: futuraFont.name
                            style: Text.Outline
                        }
                        Process {
                            id: logoutProcess
                            running: false
                            command: [ "sh", "-c", "niri msg action quit -s" ]
                        }
                        Timer {
                            id: logoutTimer
                            running: false
                            interval: 5000
                            onTriggered: {
                                logoutProcess.running = true
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: logout.execute()
                            hoverEnabled: true
                            onEntered: parent.gradient = gradient
                            onExited: parent.gradient = parent.focused ? gradient : Gradient.Transparent
                        }
                    }
                    Rectangle {
                        id: reboot
                        objectName: "reboot"
                        property bool focused: false
                        Layout.preferredWidth: parent.width
                        Layout.preferredHeight: parent.height/5
                        color: "transparent"
                        gradient: focused ? gradient : Gradient.Transparent
                        function execute() {
                            logoutTimer.stop()
                            shutdownTimer.stop()
                            if (rebootTimer.running) {
                                rebootTimer.stop()
                                rebootProcess.running = true
                            }
                            else {
                                rebootTimer.stop()
                                rebootTimer.start()
                                window.time = 5
                                window.text = "Rebooting"
                                info.text = `${window.text} in ${window.time}`
                                timer.start()
                                info.canCancel = true
                            }
                        }
                        Text {
                            anchors.centerIn: parent
                            color: "white"
                            text: "Reboot"
                            font.pointSize: 24
                            font.family: futuraFont.name
                            style: Text.Outline
                        }
                        Process {
                            id: rebootProcess
                            running: false
                            command: [ "sh", "-c", "reboot" ]
                        }
                        Timer {
                            id: rebootTimer
                            running: false
                            interval: 5000
                            onTriggered: {
                                rebootProcess.running = true
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: reboot.execute()
                            hoverEnabled: true
                            onEntered: parent.gradient = gradient
                            onExited: parent.gradient = parent.focused ? gradient : Gradient.Transparent
                        }
                    }
                    Rectangle {
                        id: shutdown
                        objectName: "shutdown"
                        property bool focused: false
                        Layout.preferredWidth: parent.width
                        Layout.preferredHeight: parent.height/5
                        color: "transparent"
                        gradient: focused ? gradient : Gradient.Transparent
                        function execute() {
                            logoutTimer.stop()
                            rebootTimer.stop()
                            if (shutdownTimer.running) {
                                shutdownTimer.stop()
                                shutdownProcess.running = true
                            }
                            else {
                                shutdownTimer.stop()
                                shutdownTimer.start()
                                window.time = 5
                                window.text = "Shutting down"
                                info.text = `${window.text} in ${window.time}`
                                timer.start()
                                info.canCancel = true
                            }
                        }
                        Text {
                            anchors.centerIn: parent
                            color: "white"
                            text: "Shutdown"
                            font.pointSize: 24
                            font.family: futuraFont.name
                            style: Text.Outline
                        }
                        Process {
                            id: shutdownProcess
                            running: false
                            command: [ "sh", "-c", "systemctl poweroff" ]
                        }
                        Timer {
                            id: shutdownTimer
                            running: false
                            interval: 5000
                            onTriggered: {
                                shutdownProcess.running = true
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: shutdown.execute()
                            hoverEnabled: true
                            onEntered: parent.gradient = gradient
                            onExited: parent.gradient = parent.focused ? gradient : Gradient.Transparent
                        }
                    }
                }
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: root.active = false
        }

        LockContext {
            id: lockContext
            onUnlocked: {
                lockscreen.locked = false;
            }
        }

        LockScreen{ id: lockscreen; context: lockContext; onLockedChanged: root.active = false }
    }
}