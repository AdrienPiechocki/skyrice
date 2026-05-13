import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Commons

LazyLoader {
    id: root
    active: false
    property int popupX: 0
    property int popupY: 0
    property var data: null
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
            margins.left: root.popupX - width/2.3
            margins.top: root.popupY
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            implicitHeight: 0
            implicitWidth: 0
            color: "transparent"
            Background{ width: parent.width; height: parent.height; stroke: 2}
            QsMenuOpener{ id: opener; menu: root.data; }
            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 30
                anchors.bottomMargin: 30
                anchors.leftMargin: 25
                anchors.rightMargin: 25
                color: "transparent"
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0
                    Repeater {
                        id: repeater
                        model: opener.children ? [...opener.children.values] : []

                        Rectangle {
                            id: entry
                            required property var modelData
                            Layout.preferredWidth: parent.width
                            Layout.preferredHeight: modelData?.isSeparator ? 18 : 24
                            color: "transparent"
                            Rectangle {
                                id: separator
                                anchors.centerIn: parent
                                width: parent.width
                                height: 2
                                color: "transparent"
                                gradient: gradient
                                visible: modelData?.isSeparator
                            }
                            FontLoader {
                                id: futuraFont
                                source: "../../Assets/Fonts/Futura Condensed Medium.ttf"
                            }
                            Text {
                                id: text
                                anchors.centerIn: parent
                                color: "white"
                                text: modelData?.text
                                font.pointSize: 14
                                font.family: futuraFont.name
                            }
                            Component.onCompleted: {
                                window.implicitHeight = repeater.model.filter(x => !x.isSeparator).length * 24 + repeater.model.filter(x => x.isSeparator).length * 18 + 60
                                if(text.contentWidth > window.implicitWidth) {
                                    window.implicitWidth =  Math.max(150, text.contentWidth*2)
                                }
                            }
                            Gradient {
                                id: gradient
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0; color: "transparent" }
                                GradientStop { position: 0.5; color: "#67cecece" }
                                GradientStop { position: 1; color: "transparent" }
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if(!modelData?.isSeparator){
                                        modelData.triggered();
                                        root.active = false;
                                    }
                                }
                                hoverEnabled: true
                                onEntered: { if(!modelData?.isSeparator){entry.gradient = gradient} }
                                onExited: { if(!modelData?.isSeparator){entry.gradient = Gradient.Transparent} }
                            }
                        }
                    }
                }
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: root.active = false
        }
    }
}