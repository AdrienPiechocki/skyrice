import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs.Commons
Scope {
	id: root
	property var brightness: 0
	property var maxBrightness: 0
	property bool flag: false
	Timer {
		running: true
		interval: 250
		repeat: true
		onTriggered: {getMaxBrightness.running = true}
	}

	Process {
        id: getMaxBrightness
        running: false
        command: ["brightnessctl", "max"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.maxBrightness = text
                getBrightness.running = true
            }
        }
    }
    Process {
        id: getBrightness
        running: false
        command: ["brightnessctl", "get"]

        stdout: StdioCollector {
            onStreamFinished: {
                function roundTo(n, digits) {
                    var negative = false;
                    if (digits === undefined) {
                        digits = 0;
                    }
                    if (n < 0) {
                        negative = true;
                        n = n * -1;
                    }
                    var multiplicator = Math.pow(10, digits);
                    n = parseFloat((n * multiplicator).toFixed(11));
                    n = (Math.round(n) / multiplicator).toFixed(digits);
                    if (negative) {
                        n = (n * -1).toFixed(digits);
                    }
                    return n;
                }

                root.brightness = roundTo(text/root.maxBrightness, 2) * 100
				root.flag = true
            }
        }
    }

	// Bind the pipewire node so its volume will be tracked
	PwObjectTracker {
		objects: [ Pipewire.defaultAudioSink ]
	}

	Connections {
		target: Pipewire.defaultAudioSink?.audio

		function onVolumeChanged() {
			if (root.flag)
				root.shouldShowOsdVolume = true;
				hideTimer.restart();
		}
	}

	onBrightnessChanged: {
		if(flag) {
			root.shouldShowOsdBrightness = true;
			hideTimer.restart();
		}
	}
	property bool shouldShowOsdVolume: false
	property bool shouldShowOsdBrightness: false


	Timer {
		id: hideTimer
		interval: 1000
		onTriggered: {root.shouldShowOsdVolume = false; shouldShowOsdBrightness = false}
	}

	// The OSD window will be created and destroyed based on shouldShowOsd.
	// PanelWindow.visible could be set instead of using a loader, but using
	// a loader will reduce the memory overhead when the window isn't open.
	LazyLoader {
		active: root.shouldShowOsdVolume

		PanelWindow {
			// Since the panel's screen is unset, it will be picked by the compositor
			// when the window is created. Most compositors pick the current active monitor.

			anchors.bottom: true
			margins.bottom: 100
			exclusiveZone: 0

			implicitWidth: 400
			implicitHeight: 50
			color: "transparent"

			// An empty click mask prevents the window from blocking mouse events.
			mask: Region {}

			Capsule {
				anchors.fill: parent
				anchors.leftMargin: 50
				anchors.rightMargin: 50
				anchors.topMargin: 5
				anchors.bottomMargin: 5

				RowLayout {
					anchors {
						fill: parent
						leftMargin: 10
						rightMargin: 15
					}

					Text {
						font.pointSize: 24
						text: ""
						color: "white"
					}

					Rectangle {
						// Stretches to fill all left-over space
						Layout.fillWidth: true

						implicitHeight: 10
						radius: 20
						color: "#50ffffff"

						Rectangle {
							anchors {
								left: parent.left
								top: parent.top
								bottom: parent.bottom
							}

							implicitWidth: parent.width * (Pipewire.defaultAudioSink?.audio.volume ?? 0)
							radius: parent.radius
						}
					}
				}
			}
		}
	}
	LazyLoader {
		active: root.shouldShowOsdBrightness

		PanelWindow {
			// Since the panel's screen is unset, it will be picked by the compositor
			// when the window is created. Most compositors pick the current active monitor.

			anchors.bottom: true
			margins.bottom: 50
			exclusiveZone: 0

			implicitWidth: 400
			implicitHeight: 50
			color: "transparent"

			// An empty click mask prevents the window from blocking mouse events.
			mask: Region {}

			Capsule {
				anchors.fill: parent
				anchors.leftMargin: 50
				anchors.rightMargin: 50
				anchors.topMargin: 5
				anchors.bottomMargin: 5

				RowLayout {
					anchors {
						fill: parent
						leftMargin: 10
						rightMargin: 15
					}

					Text {
						font.pointSize: 24
						text: ""
						color: "white"
					}

					Rectangle {
						// Stretches to fill all left-over space
						Layout.fillWidth: true

						implicitHeight: 10
						radius: 20
						color: "#50ffffff"

						Rectangle {
							anchors {
								left: parent.left
								top: parent.top
								bottom: parent.bottom
							}

							implicitWidth: parent.width * (root.brightness/100 ?? 0)
							radius: parent.radius
						}
					}
				}
			}
		}
	}
}
