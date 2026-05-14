import QtQuick
import QtQuick.Shapes
import qs.Commons

Rectangle {
    id: root
    height: 200
    width: 400
    color: "transparent"
    property int stroke: 2
    property color fillColor: "#67000000"
    property color borderColor: "#cecece"
    Shape {
        id: background
        ShapePath {
            strokeColor: root.fillColor
            strokeWidth: root.stroke
            fillColor: root.fillColor
            startX: 3
            startY: 3
            PathLine{ x:30; y:3}
            PathLine{ x:30; y:30}
            PathLine{ x:3; y:30}
            PathLine{ x:3; y:3}
        }
        ShapePath {
            strokeColor: root.fillColor
            strokeWidth: root.stroke
            fillColor: root.fillColor
            startX: root.width-30
            startY: 3
            PathLine{ x:root.width-3; y:3}
            PathLine{ x:root.width-3; y:30}
            PathLine{ x:root.width-30; y:30}
            PathLine{ x:root.width-30; y:3}
        }
        ShapePath {
            strokeColor: root.fillColor
            strokeWidth: root.stroke
            fillColor: root.fillColor
            startX: root.width-30
            startY: root.height-30
            PathLine{ x:root.width-3; y:root.height-30}
            PathLine{ x:root.width-3; y:root.height-3}
            PathLine{ x:root.width-30; y:root.height-3}
            PathLine{ x:root.width-30; y:root.height-30}
        }
        ShapePath {
            strokeColor: root.fillColor
            strokeWidth: root.stroke
            fillColor: root.fillColor
            startX: 3
            startY: root.height-30
            PathLine{ x:30; y:root.height-30}
            PathLine{ x:30; y:root.height-3}
            PathLine{ x:3; y:root.height-3}
            PathLine{ x:3; y:root.height-30}
        }
        ShapePath {
            strokeColor: root.fillColor
            strokeWidth: Math.pow(root.stroke, 2)
            fillColor: root.fillColor
            startX: 10
            startY: 10
            PathLine{ x:root.width-10; y:10}
            PathLine{ x:root.width-10; y:root.height-10}
            PathLine{ x:10; y:root.height-10}
            PathLine{ x:10; y:10}
        }
    }
    Border{ size: root.height; stroke: root.stroke; borderColor:root.borderColor; }
    Border{ size: root.width; rotation: 90; x: root.width; stroke: root.stroke; borderColor:root.borderColor; }
    Border{ size: root.height; rotation: 180; x: root.width; y:root.height; stroke: root.stroke; borderColor:root.borderColor; }
    Border{ size: root.width; rotation: 270; y:root.height; stroke: root.stroke; borderColor:root.borderColor; }
}