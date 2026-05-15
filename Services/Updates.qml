pragma Singleton
import QtQuick

import Quickshell
import Quickshell.Io

Singleton {
    id: root
    readonly property var updateCountPath: Quickshell.shellDir + "/Scripts/update-count.sh" 
    readonly property var updatePath: Quickshell.shellDir + "/Scripts/update.sh" 
    property int count: 0
    property bool run: false
    Process {
        id: updateCount
        running: false
        command: [ "sh", "-c", root.updateCountPath]
        stdout: StdioCollector {
            onStreamFinished: {
                root.count = parseInt(text)
            }
        }
    }
    Process {
        id: updateInstall
        running: root.run
        command: [ "kitty", "-e", root.updatePath]
        stdout: StdioCollector {
            onStreamFinished: {
                updateCount.running = true
                root.run = false
            }
        }
    }
    Timer {
        running: true
        interval: 300000
        repeat: true
        triggeredOnStart: true
        onTriggered: updateCount.running = true
    }
}