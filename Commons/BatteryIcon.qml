import QtQuick

Item {
    id: root

    property color iconColor: "white"
    property real size: 1

    readonly property real borderWidth: size * 0.05
    readonly property real bodyWidth: body.width
    readonly property real bodyHeight: body.height
    readonly property real bodyRadius: body.radius
    width: size
    height: size * 0.6

    Rectangle {
        id: body
        color: "transparent"
        border.color: root.iconColor
        border.width: root.borderWidth
        radius: root.size * 0.1
        width: root.width * 0.9
        height: root.height
        anchors.left: parent.left
        anchors.right: nub.left
        anchors.verticalCenter: parent.verticalCenter
    }

    Rectangle {
        id: nub
        color: root.iconColor
        radius: 0
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: root.size * 0.1
        height: root.size * 0.2
        topRightRadius: root.size * 0.1
        bottomRightRadius: root.size * 0.1
    }
}