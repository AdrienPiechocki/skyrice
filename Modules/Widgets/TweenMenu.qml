import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland

LazyLoader {
    id: root
    active: false

    property int width
    property int height
    property int screenX
    property var inventory
    property var logout
    property bool hover: false
    PanelWindow {
        id: menu
        anchors {
            top: true
            bottom: true
            right: true
            left: true
        }
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        color: "transparent"
        Rectangle {
            anchors.fill: parent
            color: '#42424242'
            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blur: 1
            }
        }
        FontLoader {
            id: futuraFont
            source: "../../Assets/Fonts/Futura Condensed Medium.ttf"
        }

        Item {
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: {
                root.active = false
            }
            Keys.onLeftPressed: {
                logout.active = true
                root.active = false
            }
            Keys.onRightPressed: {
                inventory.active = true
                root.active = false
            }
        }

        Image {
            anchors.centerIn: parent
            width: root.width
            height: root.height
            source: "../../Assets/Tween Menu.png"
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowBlur: 1
                shadowScale: 1
            }
        }

        Shape {
            id: rightArrow
            containsMode: Shape.FillContains
            visible: false
            ShapePath {
                fillColor: "#cecece"
                strokeColor: "#cecece"
                startX: Screen.width/2 + 45; startY: Screen.height/2
                PathLine { x: Screen.width/2 + 55; y: Screen.height/2 - 40 }
                PathLine { x: Screen.width/2 + 74; y: Screen.height/2 - 20 }
                PathLine { x: Screen.width/2 + 400; y: Screen.height/2 - 1 }
                PathLine { x: Screen.width/2 + 74; y: Screen.height/2 + 17 }
                PathLine { x: Screen.width/2 + 55; y: Screen.height/2 + 37 }
            }
            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blur: 1
            }
        }

        Shape {
            id: leftArrow
            containsMode: Shape.FillContains
            visible: false
            ShapePath {
                fillColor: "#cecece"
                strokeColor: "#cecece"
                startX: Screen.width/2 - 45; startY: Screen.height/2
                PathLine { x: Screen.width/2 - 55; y: Screen.height/2 - 40 }
                PathLine { x: Screen.width/2 - 74; y: Screen.height/2 - 20 }
                PathLine { x: Screen.width/2 - 400; y: Screen.height/2 - 1 }
                PathLine { x: Screen.width/2 - 74; y: Screen.height/2 + 17 }
                PathLine { x: Screen.width/2 - 55; y: Screen.height/2 + 37 }
            }
            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blur: 1
            }
        }

        Shape {
            id: downArrow
            containsMode: Shape.FillContains
            visible: false
            ShapePath {
                fillColor: "#cecece"
                strokeColor: "#cecece"
                startX: Screen.width/2; startY: Screen.height/2 + 45
                PathLine { x: Screen.width/2 - 30; y: Screen.height/2 + 70 }
                PathLine { x: Screen.width/2 - 15; y: Screen.height/2 + 89 }
                PathLine { x: Screen.width/2; y: Screen.height/2 + 220 }
                PathLine { x: Screen.width/2 + 15; y: Screen.height/2 + 89 }
                PathLine { x: Screen.width/2 + 30; y: Screen.height/2 + 70 }
            }
            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blur: 1
            }
        }

        Shape {
            id: upArrow
            containsMode: Shape.FillContains
            visible: false
            ShapePath {
                fillColor: "#cecece"
                strokeColor: "#cecece"
                startX: Screen.width/2; startY: Screen.height/2 - 45
                PathLine { x: Screen.width/2 - 30; y: Screen.height/2 - 70 }
                PathLine { x: Screen.width/2 - 15; y: Screen.height/2 - 89 }
                PathLine { x: Screen.width/2; y: Screen.height/2 - 220 }
                PathLine { x: Screen.width/2 + 15; y: Screen.height/2 - 89 }
                PathLine { x: Screen.width/2 + 30; y: Screen.height/2 - 70 }
            }
            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blur: 1
            }
        }
        Text {
            id: launcher
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: Screen.width/6
            text: "Launcher"
            color: "white"
            font.family: futuraFont.name
            style: Text.Outline
            font.pixelSize: 42
            layer.enabled: false
            layer.effect: MultiEffect {
                brightness: 0.5
            }
        }

        Text {
            id: session
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: Screen.width/5
            text: "Session"
            color: "white"
            font.family: futuraFont.name
            style: Text.Outline
            font.pixelSize: 42
            layer.enabled: false
            layer.effect: MultiEffect {
                brightness: 0.5
            }
        }

        Text {
            id: aichat
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Screen.width/10
            text: "Paarthurnax"
            color: "white"
            font.family: futuraFont.name
            style: Text.Outline
            font.pixelSize: 42
            layer.enabled: false
            layer.effect: MultiEffect {
                brightness: 0.5
            }
        }

        Text {
            id: settings
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: Screen.width/10
            text: "Settings"
            color: "white"
            font.family: futuraFont.name
            style: Text.Outline
            font.pixelSize: 42
            layer.enabled: false
            layer.effect: MultiEffect {
                brightness: 0.5
            }
        }

        MouseArea {
            id: closeArea
            anchors.fill: parent
            onClicked: { if (root.hover == false) { root.active = false} }
        }
        Shape {
            id: right
            containsMode: Shape.FillContains
            ShapePath {
                fillColor: "transparent"
                strokeColor: "transparent"
                startX: Screen.width/2 + 50; startY: Screen.height/2
                PathLine { x: Screen.width - Screen.width/8; y: Screen.height - Screen.height/4 }
                PathLine { x: Screen.width - Screen.width/8; y: Screen.height/4 }
                PathLine { x: Screen.width/2 + 50; y: Screen.height/2 }
            }
        }
        MouseArea {
            anchors.fill: parent
            containmentMask: right
            hoverEnabled: true
            onEntered: { root.hover = true; rightArrow.visible = true; launcher.layer.enabled = true}
            onExited: { root.hover = false; rightArrow.visible = false; launcher.layer.enabled = false }
            onClicked: { inventory.active = true; root.active = false }
        }
        Shape {
            id: left
            containsMode: Shape.FillContains
            ShapePath {
                fillColor: "transparent"
                strokeColor: "transparent"
                startX: Screen.width/2 - 50; startY: Screen.height/2
                PathLine { x: Screen.width/8; y: Screen.height - Screen.height/4 }
                PathLine { x: Screen.width/8; y: Screen.height/4 }
                PathLine { x: Screen.width/2 - 50; y: Screen.height/2 }
            }
        }
        MouseArea {
            anchors.fill: parent
            containmentMask: left
            hoverEnabled: true
            onEntered: { root.hover = true; leftArrow.visible = true; session.layer.enabled = true }
            onExited: { root.hover = false; leftArrow.visible = false; session.layer.enabled = false }
            onClicked: { logout.active = true; root.active = false }
        }
        Shape {
            id: down
            containsMode: Shape.FillContains
            ShapePath {
                fillColor: "transparent"
                strokeColor: "transparent"
                startX: Screen.width/2; startY: Screen.height/2 + 50
                PathLine { x: Screen.width/2 - Screen.width/6; y: Screen.height - Screen.height/12 }
                PathLine { x: Screen.width/2 + Screen.width/6; y: Screen.height - Screen.height/12 }
                PathLine { x: Screen.width/2; y: Screen.height/2 + 50 }
            }
        }
        MouseArea {
            anchors.fill: parent
            containmentMask: down
            hoverEnabled: true
            onEntered: { root.hover = true; downArrow.visible = true; aichat.layer.enabled = true }
            onExited: { root.hover = false; downArrow.visible = false; aichat.layer.enabled = false }
            onClicked: { root.active = false }
        }
        Shape {
            id: up
            containsMode: Shape.FillContains
            ShapePath {
                fillColor: "transparent"
                strokeColor: "transparent"
                startX: Screen.width/2; startY: Screen.height/2 - 50
                PathLine { x: Screen.width/2 - Screen.width/6; y: Screen.height/12 }
                PathLine { x: Screen.width/2 + Screen.width/6; y: Screen.height/12 }
                PathLine { x: Screen.width/2; y: Screen.height/2 - 50 }
            }
        }
        MouseArea {
            anchors.fill: parent
            containmentMask: up
            hoverEnabled: true
            onEntered: { root.hover = true; upArrow.visible = true; settings.layer.enabled = true }
            onExited: { root.hover = false; upArrow.visible = false; settings.layer.enabled = false }
            onClicked: { root.active = false }
        }
    }
}