import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Services

LazyLoader {
    id: root
    active: false
    readonly property var configFile: Quickshell.shellDir + "/Config/weather.json" 
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
            anchors.right: parent.right
            anchors.top: parent.top
            margins.top: 40
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            implicitHeight: 425
            implicitWidth: 400
            color: "transparent"
            
            FontLoader {
                id: futuraFont
                source: "../../Assets/Fonts/Futura Condensed Medium.ttf"
            }
            FontLoader {
                id: weatherIcons
                source: "../../Assets/Fonts/fontello.ttf"
            }

            property list<string> icons: ["\ue800", "\ue801", "\ue802", "\ue803", "\ue804", "\ue805", "\ue806", "\ue807", "\ue808", "\ue809", "\ue80a", "\ue80b", "\ue80c"]
            property string city: ""
            property string country: ""
            property real currentTemperature: 0.0
            property int currentConditions: 0
            property bool is_day: true
            property var forecasts: []
            FileView {
                id: configFile
                path: Qt.resolvedUrl(root.configFile)
                onLoaded: {
                    let data = JSON.parse(configFile.data())
                    window.city = data.city
                    window.country = data.country
                    window.currentTemperature = data.current.temperature
                    window.currentConditions = data.current.contitions
                    window.is_day = data.current.is_day
                    for(let i = 0; i < data.forecast.length; i++) {
                        let date = data.forecast[i].date.slice(5, -9)
                        let temp_max = data.forecast[i].temp_max
                        let temp_min = data.forecast[i].temp_min
                        let precipitation_sum = data.forecast[i].precipitation_sum
                        let wind_speed_max = data.forecast[i].wind_speed_max
                        let weathercode = data.forecast[i].weathercode
                        window.forecasts.push({
                            "date": date,
                            "temp_max": temp_max,
                            "temp_min": temp_min,
                            "precipitation_sum": precipitation_sum,
                            "wind_speed_max": wind_speed_max,
                            "weathercode": weathercode
                        })
                        repeater.model = window.forecasts.slice(0, 5)
                    }
                }
            }
            Gradient {
                id: gradient
                orientation: Gradient.Horizontal
                GradientStop { position: 0; color: "transparent" }
                GradientStop { position: 0.5; color: "#42cecece" }
                GradientStop { position: 1; color: "transparent" }
            }
            Background{ width: parent.width; height: parent.height; stroke: 2}
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
                        Layout.preferredHeight: 40
                        color: "transparent"
                        Text{
                            anchors.centerIn: parent
                            horizontalAlignment: Text.AlignHCenter
                            text: Time.getFullDate(Time.now)
                            color: "white"
                            font.family: futuraFont.name
                            font.pointSize: 18
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
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"
                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            Text {
                                x: parent.width/2 - contentWidth/2
                                anchors.top: parent.top
                                font.family: futuraFont.name
                                font.pointSize: 18
                                color: "white"
                                text: window.city
                            }
                            Text {
                                x: parent.width/2 - contentWidth/2
                                anchors.bottom: parent.bottom
                                font.family: futuraFont.name
                                font.pointSize: 18
                                color: "white"
                                text: ` ${window.currentTemperature}°C`
                            }
                            Text {
                                anchors.centerIn: parent
                                font.family: weatherIcons.name
                                font.pointSize: 64
                                color: "white"
                                text: {
                                    if (window.currentConditions == 0 && !window.is_day) {
                                        return window.icons[1]
                                    }
                                    if (window.currentConditions == 4 && !window.is_day) {
                                        return window.icons[3]
                                    }
                                    if (window.currentConditions == 10 && !window.is_day) {
                                        return window.icons[11]
                                    }
                                    return window.icons[window.currentConditions]
                                }
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumHeight: 140
                        color: "transparent"
                        RowLayout {
                            anchors.fill: parent
                            Repeater {
                                id: repeater
                                model: window.forecasts.slice(0, 5)
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    color: "transparent"
                                    clip: true
                                    Text {
                                        anchors.top: parent.top
                                        anchors.topMargin: 40
                                        x: parent.width/2 - contentWidth/2
                                        font.family: futuraFont.name
                                        font.pointSize: 11
                                        color: "white"
                                        text: modelData.date
                                        style: Text.Outline
                                    }
                                    Text {
                                        anchors.bottom: parent.bottom
                                        anchors.bottomMargin: 20
                                        x: parent.width/2 - contentWidth/2
                                        horizontalAlignment: Text.AlignHCenter
                                        font.family: futuraFont.name
                                        font.pointSize: 12
                                        color: "white"
                                        text: `${modelData.temp_min}°C\n${modelData.temp_max}°C`
                                        style: Text.Outline
                                    }
                                    Text {
                                        anchors.centerIn: parent
                                        x: parent.width/2 - contentWidth/2
                                        font.family: weatherIcons.name
                                        font.pointSize: 18
                                        color: "white"
                                        text: window.icons[modelData.weathercode]
                                        style: Text.Outline
                                    }
                                }
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