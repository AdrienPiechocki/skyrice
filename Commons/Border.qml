import QtQuick
import QtQuick.Shapes

Rectangle {
    id: root
    height: 0
    width: 0
    color: "transparent"
    property int size: 100
    property int stroke: 1
    property color borderColor: "#cecece"
    Shape{
        ShapePath {
            strokeColor: root.borderColor
            strokeWidth: root.stroke
            fillColor: "transparent"
            startX: 11
            startY: root.size-32
            PathLine{ x:11; y:21}
            PathLine{ x:14; y:21}
        }

        ShapePath {
            strokeColor: root.borderColor
            strokeWidth: root.stroke
            fillColor: "transparent"
            startX: 24
            startY: 21
            PathLine{ x:41; y:21}
            PathArc { x:19; y: 43; radiusX: 35; radiusY: 35}
            PathLine{ x:19; y:31}
        }

        ShapePath {
            strokeColor: root.borderColor
            strokeWidth: root.stroke
            fillColor: "transparent"
            startX: 19
            startY: 23
            PathLine{ x:19; y:11}
            PathLine{ x:23; y:11}
        }

        ShapePath {
            strokeColor: root.borderColor
            strokeWidth: root.stroke
            fillColor: "transparent"
            startX: 27
            startY: 25
            PathLine{ x:27; y:27}
            PathLine{ x:15; y:27}
        }

        ShapePath {
            strokeColor: root.borderColor
            strokeWidth: root.stroke
            fillColor: "transparent"
            startX: 7
            startY: 27
            PathLine{ x:6; y:27}
            PathLine{ x:6; y:6}
            PathLine{ x:27; y:6}
            PathLine{ x:27; y:16}
        }
    }
}