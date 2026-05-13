import QtQuick
import QtQuick.Shapes


Rectangle {
    id: root
    x: 0
    y: 0
    height: 0
    width: 0
    color: '#aa000000'
    property int pointer: width/2
    property int arrowSize: 50
    Shape{
        id: shape
        property int stroke: 3

        ShapePath {
            // line left
            strokeColor: "#aacecece"
            strokeWidth: shape.stroke
            fillColor: "transparent"
            startX: 10
            startY: 10
            PathLine { x: 10; y: root.height-10}
        }

        ShapePath {
            // line right
            strokeColor: "#aacecece"
            strokeWidth: shape.stroke
            fillColor: "transparent"
            startX: root.width-10
            startY: 10
            PathLine { x: root.width-10; y: root.height-10}
        }
        ShapePath {
            // line up 1
            strokeColor: "#aacecece"
            strokeWidth: shape.stroke
            fillColor: "transparent"
            startX: 10+shape.stroke
            startY: 150
            PathLine { x: arrow.startX+10; y: 150}
        }
        ShapePath {
            // line up 2
            strokeColor: "#aacecece"
            strokeWidth: shape.stroke
            fillColor: "transparent"
            startX: arrow.startX+40
            startY: 150
            PathLine { x: root.width-10-shape.stroke; y: 150}
        }
        ShapePath {
            // line down 1
            strokeColor: "#aacecece"
            strokeWidth: shape.stroke
            fillColor: "transparent"
            startX: 10+shape.stroke
            startY: 160
            PathLine { x: arrow.startX; y: 160}
        }
        ShapePath {
            // line down 2
            strokeColor: "#aacecece"
            strokeWidth: shape.stroke
            fillColor: "transparent"
            startX: arrow.startX+50
            startY: 160
            PathLine { x: root.width-10-shape.stroke; y: 160}
        }
        ShapePath {
            id: arrow
            strokeColor: "#cecece"
            strokeWidth: shape.stroke
            fillColor: "transparent"
            startX: root.pointer-root.arrowSize
            startY: 160
            PathLine { x: arrow.startX+root.arrowSize/2; y: 135}
            PathLine { x: arrow.startX+root.arrowSize; y: 160}
        }
    }
}
