import QtQuick
import QtQuick.Shapes

Rectangle {
    id: root
    height: 30
    width: 100
    radius: 10
    property var _color: tapHandler.pressed ? '#b6ffffff' : hoverHandler.hovered ? "#67cecece" : "#67000000" 
    color: "transparent"
    TapHandler { id: tapHandler }
    HoverHandler { id: hoverHandler }
    property bool active: true
    Shape{
        id: shape
        property int _width: root.width
        property int _height: root.height
        property int stroke: 2
        property var fill: root._color
        visible: root.active
        
        ShapePath {
            //main box outline
            strokeColor: "black"
            strokeWidth: Math.pow(shape.stroke, 2)
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathLine { x: shape._width; y: 0 }
            PathLine { x: shape._width + shape._height/2; y: shape._height/2 - shape._height/10 }
            PathLine { x: shape._width + shape._height/6; y: shape._height/2 + shape._height/10 }
            PathLine { x: shape._width; y: shape._height/2 + shape._height/10 }
            PathLine { x: shape._width; y: shape._height/2 - shape._height/10 }
            PathLine { x: shape._width + shape._height/6; y: shape._height/2 - shape._height/10 }
            PathLine { x: shape._width + shape._height/2; y: shape._height/2 + shape._height/10 }
            PathLine { x: shape._width; y: shape._height}
            PathLine { x: 0; y: shape._height }
            PathLine { x: -shape._height/2; y: shape._height/2 + shape._height/10}
            PathLine { x: -shape._height/6; y:shape._height/2 - shape._height/10}
            PathLine { x: 0; y:shape._height/2 - shape._height/10}
            PathLine { x: 0; y:shape._height/2 + shape._height/10}
            PathLine { x: -shape._height/6; y:shape._height/2 + shape._height/10}
            PathLine { x: -shape._height/2; y:shape._height/2 - shape._height/10}
            PathLine { x: 0; y: 0}
        }
        ShapePath {
            //main box
            strokeColor: "#cecece"
            strokeWidth: shape.stroke
            fillColor: shape.fill
            capStyle: ShapePath.RoundCap
            PathLine { x: shape._width; y: 0 }
            PathLine { x: shape._width + shape._height/2; y: shape._height/2 - shape._height/10 }
            PathLine { x: shape._width + shape._height/6; y: shape._height/2 + shape._height/10 }
            PathLine { x: shape._width; y: shape._height/2 + shape._height/10 }
            PathLine { x: shape._width; y: shape._height/2 - shape._height/10 }
            PathLine { x: shape._width + shape._height/6; y: shape._height/2 - shape._height/10 }
            PathLine { x: shape._width + shape._height/2; y: shape._height/2 + shape._height/10 }
            PathLine { x: shape._width; y: shape._height}
            PathLine { x: 0; y: shape._height }
            PathLine { x: -shape._height/2; y: shape._height/2 + shape._height/10}
            PathLine { x: -shape._height/6; y:shape._height/2 - shape._height/10}
            PathLine { x: 0; y:shape._height/2 - shape._height/10}
            PathLine { x: 0; y:shape._height/2 + shape._height/10}
            PathLine { x: -shape._height/6; y:shape._height/2 + shape._height/10}
            PathLine { x: -shape._height/2; y:shape._height/2 - shape._height/10}
            PathLine { x: 0; y: 0}
        }

        ShapePath {
            // inner losange left outline
            strokeColor: "black"
            strokeWidth: Math.pow(shape.stroke, 2)
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            startX: -shape._height/6.7
            startY: shape._height/2.1
            PathLine { x: -shape._height/8; y: shape._height/2}
            PathLine { x: -shape._height/2.8; y: shape._height/2 + shape._height * 14/100}
        }
        ShapePath {
            // inner losange left
            strokeColor: "#cecece"
            strokeWidth: shape.stroke
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            startX: -shape._height/6.7
            startY: shape._height/2.1
            PathLine { x: -shape._height/8; y: shape._height/2}
            PathLine { x: -shape._height/2.8; y: shape._height/2 + shape._height * 14/100}
        }


        ShapePath {
            // outer losange left outline
            strokeColor: "black"
            strokeWidth: Math.pow(shape.stroke, 2)
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            startX: -shape._height/3.6
            startY: shape._height/2.6
            PathLine { x: -shape._height/2.1; y: shape._height/3.8}
            PathLine { x: -shape._height/1.25; y: shape._height/2}
            PathLine { x: -shape._height/2.1; y: shape._height/1.4}
            PathLine { x: -shape._height/2.18; y: shape._height/1.42}
        }
        ShapePath {
            // outer losange left
            strokeColor: "#cecece"
            strokeWidth: shape.stroke
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            startX: -shape._height/3.6
            startY: shape._height/2.6
            PathLine { x: -shape._height/2.1; y: shape._height/3.8}
            PathLine { x: -shape._height/1.25; y: shape._height/2}
            PathLine { x: -shape._height/2.1; y: shape._height/1.4}
            PathLine { x: -shape._height/2.18; y: shape._height/1.42}
        }


        ShapePath {
            // inner losange right outline
            strokeColor: "black"
            strokeWidth: Math.pow(shape.stroke, 2)
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            startX: shape._width+shape._height/6.7
            startY: shape._height/2.1
            PathLine { x: shape._width+shape._height/8; y: shape._height/2}
            PathLine { x: shape._width+shape._height/2.8; y: shape._height/2 + shape._height * 14/100}
        }
        ShapePath {
            // inner losange right
            strokeColor: "#cecece"
            strokeWidth: shape.stroke
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            startX: shape._width+shape._height/6.7
            startY: shape._height/2.1
            PathLine { x: shape._width+shape._height/8; y: shape._height/2}
            PathLine { x: shape._width+shape._height/2.8; y: shape._height/2 + shape._height * 14/100}
        }


        ShapePath {
            // outer losange left outline
            strokeColor: "black"
            strokeWidth: Math.pow(shape.stroke, 2)
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            startX: shape._width+shape._height/3.6
            startY: shape._height/2.6
            PathLine { x: shape._width+shape._height/2.1; y: shape._height/3.8}
            PathLine { x: shape._width+shape._height/1.25; y: shape._height/2}
            PathLine { x: shape._width+shape._height/2.1; y: shape._height/1.4}
            PathLine { x: shape._width+shape._height/2.18; y: shape._height/1.42}
        }
        ShapePath {
            // outer losange right
            strokeColor: "#cecece"
            strokeWidth: shape.stroke
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            startX: shape._width+shape._height/3.6
            startY: shape._height/2.6
            PathLine { x: shape._width+shape._height/2.1; y: shape._height/3.8}
            PathLine { x: shape._width+shape._height/1.25; y: shape._height/2}
            PathLine { x: shape._width+shape._height/2.1; y: shape._height/1.4}
            PathLine { x: shape._width+shape._height/2.18; y: shape._height/1.42}
        }
    }

}