import QtQuick
import QtQuick.Controls

/**
 * A progress bar with optional text centered inside it.
 * Partially based on https://github.com/end-4/dots-hyprland/blob/449df7f161e6435569bc7d9499b2e444dd8aa153/dots/.config/quickshell/ii/modules/common/widgets/ClippedProgressBar.qml
 */

ProgressBar {
    id: root
    property real valueBarWidth: 2
    property real valueBarHeight: 1
    property color highlightColor: "gray"
    property color trackColor: "red"
    property color textColor: "white"
    property string text
    property bool shimmer: false
    property bool pulse: false

    font.weight: text.length > 2 ? Font.Medium : Font.DemiBold
    
    background: Item {
        implicitHeight: valueBarHeight
        implicitWidth: valueBarWidth
    }

    contentItem: Rectangle {
        id: contentItem
        anchors.fill: parent
        color: root.trackColor

        SequentialAnimation on color {
            running: root.pulse
            loops: Animation.Infinite

            ColorAnimation {
                from: root.trackColor
                to: {
                    var c = Qt.color(root.trackColor);
                    var boostedLight = Math.min(1.0, c.hslLightness + 0.2);
                    return Qt.hsla(c.hslHue, c.hslSaturation, boostedLight, c.a);
                }
                duration: 1000
                easing.type: Easing.InOutQuad
            }
            ColorAnimation {
                from: {
                    var c = Qt.color(root.trackColor);
                    var boostedLight = Math.min(1.0, c.hslLightness + 0.2);
                    return Qt.hsla(c.hslHue, c.hslSaturation, boostedLight, c.a);
                }
                to: root.trackColor
                duration: 1000
                easing.type: Easing.InOutQuad
            }
        }

        Rectangle {
            id: progressFill
            color: root.highlightColor
            clip: true  // ensure the shimmer is only visible inside progressFill
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
                right: undefined
            }
            width: parent.width * root.visualPosition
            height: parent.height

            Rectangle {
                id: shimmerOverlay
                visible: root.shimmer
                width: root.valueBarWidth
                height: root.valueBarHeight
                property real shimmerWidth: root.valueBarWidth * 0.2
                x: -progressFill.x
                y: 0
                opacity: 0.5

                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: -0.3; color: "transparent" }
                    GradientStop {
                        position: Math.max(-0.3, shimmerAnimation.position - shimmerOverlay.shimmerWidth / (root.valueBarWidth))
                        color: "transparent"
                    }
                    GradientStop { position: shimmerAnimation.position; color: "white" }
                    GradientStop {
                        position: Math.min(1.3, shimmerAnimation.position + shimmerOverlay.shimmerWidth / (root.valueBarWidth))
                        color: "transparent"
                    }
                    GradientStop { position: 1.3; color: "transparent" }
                }

                SequentialAnimation on x {
                    id: shimmerAnimation
                    property real position: 0.0
                    running: root.shimmer
                    loops: Animation.Infinite

                    NumberAnimation {
                        target: shimmerAnimation
                        property: "position"
                        from: -0.2
                        to: 1.2
                        duration: 3000
                        easing.type: Easing.InOutExpo
                    }
                }
            }
        }
    }

    Text {
        id: overlayText
        font: root.font
        text: root.text
        color: textColor
        width: root.width
        height: root.height
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        style: Text.Outline
    }
}