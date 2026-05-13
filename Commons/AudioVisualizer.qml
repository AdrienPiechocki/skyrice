import QtQuick
import Quickshell.Services.Pipewire

Item {
  id: root
  property color fillColor: '#8bbfc9'
  property var values: []
  property bool mirrored: true

  // Minimum signal properties
  property bool showMinimumSignal: false
  property real minimumSignalValue: 0.01 // Default to 1% of height

  // Pre compute horizontal mirroring
  readonly property int valuesCount: (values && values.length !== undefined) ? values.length : 0
  readonly property int totalBars: mirrored ? valuesCount * 2 : valuesCount
  readonly property real barSlotSize: totalBars > 0 ? width / totalBars : 0
  readonly property bool highQuality: true

  PwAudioSpectrum {
    id: spectrum
    node: Pipewire.defaultAudioSink
    enabled: true
    frameRate: 30
    lowerCutoff: 50
    upperCutoff: 12000
    noiseReduction: 0.77
    smoothing: true

    onValuesChanged: {
      root.values = spectrum.values;
    }
  }


  Repeater {
    model: root.totalBars

    Rectangle {
      property int valueIndex: root.mirrored ? (index < root.valuesCount ? root.valuesCount - 1 - index : index - root.valuesCount) : index

      property real rawAmp: (root.values && root.values[valueIndex] !== undefined) ? root.values[valueIndex] : 0
      property real amp: (root.showMinimumSignal && rawAmp === 0) ? root.minimumSignalValue : rawAmp

      color: root.fillColor
      antialiasing: root.highQuality
      smooth: root.highQuality

      // Only update when value actually changes - reduces GPU load
      width: root.barSlotSize * 0.5
      height: root.height * amp
      x: index * root.barSlotSize + (root.barSlotSize * 0.25)
      y: root.height - height - 14

      // Disable updates when invisible to save GPU
      visible: root.visible
    }
  }
}