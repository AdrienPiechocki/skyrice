import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Services

LazyLoader {
    id: root
    active: false
    property int popupX: 0
    property int popupY: 0
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
            margins.left: root.popupX - width/1.8
            margins.top: root.popupY
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            implicitHeight: history.length > 4 ? 600 : 100 + history.length * 125
            implicitWidth: 425
            color: "transparent"
            property var history: []
            property var textWidth: 0
            signal changed
            function remove(id) {
                if (id !== -1) {
                    window.history = window.history.filter((_, i) => i !== id)
                    window.changed()
                }
            }
            FileView {
                id: configFile
                path: Qt.resolvedUrl(Quickshell.shellDir + "/Config/history.json")
                watchChanges: true

                property bool loading: false

                onFileChanged: {
                    if (!loading) reload()
                }
                onLoaded: {
                    loading = true
                    window.history = JSON.parse(configFile.text()).notifications ?? []
                    window.changed()
                    loading = false
                }
                onAdapterUpdated: {
                    if (!loading) writeAdapter()
                }

                JsonAdapter {
                    property var notifications: window.history.slice()
                }
            }

            FontLoader {
                id: futuraFont
                source: "../../Assets/Fonts/Futura Condensed Medium.ttf"
            }
            Gradient {
                id: gradient
                orientation: Gradient.Horizontal
                GradientStop { position: 0; color: "transparent" }
                GradientStop { position: 0.5; color: "#42cecece" }
                GradientStop { position: 1; color: "transparent" }
            }

            Connections {
                target: window
                function onChanged() {
                    window.implicitHeight = window.history.length > 4 ? 650 : 150 + window.history.length * 125
                    list.model = window.history
                }
            }


            Background{ width: parent.width; height: parent.height; stroke: 2}

            Rectangle {
                width: 20
                height: 20
                x: window.width - 42.5
                y: 53.5
                color: "transparent"
                Image {
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    height: 25
                    source: "../../Assets/Inventory/Scroll Bar Top.png"
                    opacity: (list.count > 4) ? 1 : 0
                }
            }
            Rectangle {
                width: 20
                height: 20
                x: window.width - 42.5
                y: window.height - 63
                color: "transparent"
                Image {
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    height: 25
                    source: "../../Assets/Inventory/Scroll Bar Bottom.png"
                    opacity: (list.count > 4) ? 1 : 0
                }
            }
            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 25
                anchors.bottomMargin: 25
                anchors.leftMargin: 25
                anchors.rightMargin: 25
                color: "transparent"
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        color: "transparent"
                        RowLayout {
                            anchors.fill: parent
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "transparent"
                                Text{
                                    anchors.right: parent.right
                                    horizontalAlignment: Text.AlignHCenter
                                    text: "Notifications History"
                                    color: "white"
                                    font.family: futuraFont.name
                                    font.pointSize: 18
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.maximumWidth: 150
                                color: "transparent"
                                Capsule {
                                    anchors.centerIn: parent
                                    height: 30
                                    width: 40
                                    color: '#67676767'
                                    active: false
                                    Text {
                                        anchors.centerIn: parent
                                        text: ""
                                        color: "white"
                                        font.family: futuraFont.name
                                        font.pointSize: 14
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            window.history = []
                                            window.changed()
                                        }
                                        onPressed: parent.color = "#86ffffff"
                                        onReleased: parent.color = containsMouse ? "#67ffffff" : "#67676767"
                                        hoverEnabled: true
                                        onEntered: parent.color = "#67ffffff"
                                        onExited: parent.color = "#67676767"
                                    }
                                }
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20
                        color: "transparent"
                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width
                            height: 2
                            gradient: gradient
                        }
                    }
                    ListView{
                        id: list
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumHeight: 600
                        clip: true
                        model: window.history
                        ScrollBar.vertical: ScrollBar {
                            background: Rectangle {
                                color: '#67676767'
                                border.width: 1
                                border.color: "#cecece"
                                opacity: (list.count > 4) ? 1 : 0
                            }
                            contentItem: Rectangle {
                                id: scroll
                                implicitWidth: 12
                                color: "#cecece"
                                border.width: 1
                                border.color: "white"
                                opacity: (list.count > 4) ? 1 : 0
                            }
                        }
                        delegate: Rectangle {
                            width: list.width - 24 * scroll.opacity
                            height: list.count > 4 ? list.height / 4 : list.height / list.count
                            color: "transparent"
                            Background{ width: parent.width; height: parent.height; stroke: 2; borderColor: modelData.urgency > 1 ? "orange" : "#cecece"}
                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 0
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.topMargin: 15
                                    height: 30
                                    color: "transparent"
                                    RowLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            width: 60
                                            Layout.leftMargin: 40
                                            Layout.fillHeight: true
                                            color: "transparent"
                                            Text {
                                                anchors.fill: parent
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                                color: "white"
                                                text: modelData.appName
                                                font.family: futuraFont.name
                                                font.pointSize: 12
                                                style: Text.Outline
                                                Component.onCompleted: {
                                                    elide = contentHeight > parent.height || contentWidth > parent.width ? Text.ElideRight : Text.ElideNone
                                                }
                                            }
                                        }
                                        Rectangle {
                                            Layout.alignment: Qt.AlignHCenter
                                            width: 150
                                            Layout.fillHeight: true
                                            color: "transparent"
                                            Text {
                                                anchors.fill: parent
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                                color: "white"
                                                text: modelData.body ? modelData.summary : ""
                                                font.family: futuraFont.name
                                                font.pointSize: 12
                                                style: Text.Outline
                                                Component.onCompleted: {
                                                    elide = contentHeight > parent.height || contentWidth > parent.width ? Text.ElideRight : Text.ElideNone
                                                }
                                            }
                                        }
                                        Rectangle {
                                            width: 60
                                            Layout.rightMargin: 40
                                            Layout.fillHeight: true
                                            color: "transparent"
                                            Text {
                                                anchors.fill: parent
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                                color: "white"
                                                text: modelData.timestamp
                                                font.family: futuraFont.name
                                                font.pointSize: 12
                                                style: Text.Outline
                                                Component.onCompleted: {
                                                    elide = contentHeight > parent.height || contentWidth > parent.width ? Text.ElideRight : Text.ElideNone
                                                }
                                            }
                                        }
                                    }
                                }
                                Rectangle {
                                    width: 220
                                    height: 60
                                    Layout.bottomMargin: 20
                                    Layout.leftMargin: 75
                                    color: "transparent"
                                    clip: true
                                    Text {
                                        id: text
                                        anchors.fill: parent
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        color: "white"
                                        text: modelData.body ? modelData.body : modelData.summary
                                        font.family: futuraFont.name
                                        font.pointSize: 14
                                        style: Text.Outline
                                        wrapMode: Text.WordWrap
                                        Component.onCompleted: {
                                            elide = contentHeight > parent.height || contentWidth > parent.width ? Text.ElideRight : Text.ElideNone
                                            window.textWidth = text.contentWidth
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                anchors.left: parent.left
                                anchors.leftMargin: 25
                                anchors.top: parent.top
                                anchors.topMargin: parent.height/2 - height/2
                                height: 50
                                width: 50
                                radius: 20
                                color: "transparent"
                                clip: true
                                Image {
                                    fillMode: Image.PreserveAspectFit
                                    anchors.fill: parent
                                    source: modelData.image
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    const idx = window.history.findIndex(n => n.id === modelData.id)
                                    window.remove(idx)
                                }
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        color: "transparent"
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