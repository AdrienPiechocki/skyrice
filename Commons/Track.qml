import QtQuick
import QtQuick.Shapes


Rectangle {
    id: root
    height: 5
    width: 170
    color: "transparent"
    property var progress: 0
    Shape{
        id: shape
        property int _width: root.width
        property int _height: root.height
        property int stroke: 2

        ShapePath {
            strokeColor: "black"
            strokeWidth: Math.pow(shape.stroke, 2)
            fillColor: "black"
            PathLine { x: shape._width + shape._width * 5/100; y: 0 }
            PathLine { x: shape._width; y: shape._height }
            PathLine { x: 0; y: shape._height }
            PathLine { x: -shape._width * 5/100; y: 0 }
            PathLine { x: 0; y: 0 }
        }
        ShapePath {
            strokeColor: "white"
            strokeWidth: shape.stroke/2
            fillColor: '#674a1313'
            PathLine { x: shape._width + shape._width * 5/100; y: 0 }
            PathLine { x: shape._width; y: shape._height }
            PathLine { x: 0; y: shape._height }
            PathLine { x: -shape._width * 5/100; y: 0 }
            PathLine { x: 0; y: 0 }
        }
        ShapePath {
            strokeColor: '#931919'
            strokeWidth: shape.stroke*shape._height/3
            fillColor: "transparent"
            startX: shape._width/2
            startY: shape._height/2
            PathLine { x: shape._width*(root.progress/2)/100; y: shape._height/2 }
        }
        ShapePath {
            strokeColor: '#931919'
            strokeWidth: shape.stroke*shape._height/3
            fillColor: "transparent"
            startX: shape._width/2
            startY: shape._height/2
            PathLine { x: shape._width - shape._width*(root.progress/2)/100; y: shape._height/2 }
        }
    }
}
