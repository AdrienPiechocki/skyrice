import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root
    readonly property var weatherScriptPath: Quickshell.shellDir + "/Scripts/weather.py"
    readonly property var configFile: Quickshell.shellDir + "/Config/weather.json"

    FileView {
        id: configFile
        path: Qt.resolvedUrl(root.configFile)
        onLoaded: {
            let data = JSON.parse(configFile.data())
            if(!data["last-update"]) {
                weatherProc.running = true
            }
            else if(Date.parse(new Date()) - Date.parse(data["last-update"]) > 20000) {
                weatherProc.running = true
            }

        }
    }
    Process {
        id: weatherProc
        running: false
        command: [ "python3", root.weatherScriptPath ]
    }
    Timer {
        running: true
        interval: 20000
        repeat: true
        onTriggered: weatherProc.running = true
    }
}