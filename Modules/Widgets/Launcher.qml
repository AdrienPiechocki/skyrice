import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.Commons

LazyLoader {
    id: root
    active: false
    property int _height: 0
    property int _width: 0
    property int offset: 50
    property int screenX: 0

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
            id: inventory
            anchors.left: parent.left
            anchors.top: parent.top
            margins.left: root.offset
            implicitHeight: root._height
            implicitWidth: root._width
            color: "transparent"
            visible: true
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            property list<string> categories: ["Favorites", "All", "Office", "Game", "Development"]
            property string currentCategory: "All"
            property int currentPointer: 0
            property list<string> favorites: []
            property var usage: {}
            property var apps: DesktopEntries.applications.values
            property int focusedAppIndex: -1
            Component.onCompleted: { currentPointer = all.mapToGlobal(0, 0).x + all.width }
            onCurrentCategoryChanged: { focusedAppIndex = -1 }

            FileView {
                id: configFile
                path: Qt.resolvedUrl(Quickshell.shellDir+"/Config/inventory.json")
                watchChanges: true
                onFileChanged: reload()
                onLoaded: {
                    inventory.favorites = JSON.parse(configFile.text()).favorites
                    inventory.usage = JSON.parse(configFile.text()).usage
                }
                onAdapterUpdated: {
                    writeAdapter()
                    inventory.sortApps(inventory.currentCategory)
                }

                JsonAdapter {
                    property list<string> favorites: inventory.favorites
                    property var usage: inventory.usage
                }

            }

            //////////////
            //Background//
            //////////////
            Inventory { width: root._width; height: root._height; pointer:inventory.currentPointer }

            FontLoader {
                id: futuraFont
                source: "../../Assets/Fonts/Futura Condensed Medium.ttf"
            }
            
            //////////
            //Filter//
            //////////
            Rectangle {
                width: 250
                height: 30
                x: root._width - width - 12
                y: 20
                color: "transparent"
                clip: true

                Capsule {
                    id: filter
                    width: 201
                    anchors.left: parent.left
                    anchors.leftMargin: 50

                    Rectangle {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        color: "transparent"
                        clip: true

                        TextField {
                            id: input
                            anchors.fill: parent
                            placeholderText: "FILTER"
                            background: null
                            selectByMouse: true
                            focus: true
                            placeholderTextColor: "#cecece"
                            color: "white"
                            font.family: futuraFont.name
                            font.pixelSize: 18
                            text: ""
                            onTextChanged: {
                                inventory.focusedAppIndex = -1
                                inventory.sortApps(inventory.currentCategory)
                            }
                            Keys.onEscapePressed: root.active = false
                            Keys.onTabPressed: {
                                let index = inventory.categories.indexOf(inventory.currentCategory) + 1
                                if (index > inventory.categories.length - 1) {
                                    index = 0
                                }
                                inventory.currentCategory = inventory.categories[index]
                                label.text = inventory.currentCategory.toUpperCase()
                                inventory.currentPointer = eval(`${inventory.currentCategory.toLowerCase()}`).mapToGlobal(0, 0).x + eval(`${inventory.currentCategory.toLowerCase()}`).width - root.screenX
                                inventory.sortApps(inventory.currentCategory)
                            }
                            Keys.onBacktabPressed: {
                                let index = inventory.categories.indexOf(inventory.currentCategory) - 1
                                if (index < 0) {
                                    index = inventory.categories.length - 1
                                }
                                inventory.currentCategory = inventory.categories[index]
                                label.text = inventory.currentCategory.toUpperCase()
                                inventory.currentPointer = eval(`${inventory.currentCategory.toLowerCase()}`).mapToGlobal(0, 0).x + eval(`${inventory.currentCategory.toLowerCase()}`).width - root.screenX
                                inventory.sortApps(inventory.currentCategory)
                            }
                            Keys.onDownPressed: {
                                if (inventory.focusedAppIndex < 0) {
                                    inventory.focusedAppIndex = 0
                                }
                                else {
                                    if (inventory.focusedAppIndex+1 > appList.count-1) {
                                        inventory.focusedAppIndex = 0
                                    }
                                    else {
                                        inventory.focusedAppIndex ++
                                    }
                                }
                                appList.positionViewAtIndex(inventory.focusedAppIndex, ListView.Contain)
                            }
                            Keys.onUpPressed: {
                                if (inventory.focusedAppIndex < 0) {
                                    inventory.focusedAppIndex = appList.count-1
                                }
                                else {
                                    if (inventory.focusedAppIndex-1 < 0) {
                                        inventory.focusedAppIndex = appList.count-1
                                    }
                                    else {
                                        inventory.focusedAppIndex --
                                    }
                                }
                                appList.positionViewAtIndex(inventory.focusedAppIndex, ListView.Contain)
                            }
                            Keys.onReturnPressed: {
                                if (inventory.focusedAppIndex >= 0) {
                                    appList.model[inventory.focusedAppIndex].execute()
                                    let newUsage = JSON.parse(JSON.stringify(inventory.usage))
                                    if (newUsage.hasOwnProperty(appList.model[inventory.focusedAppIndex].name.toLowerCase())) {
                                        newUsage[appList.model[inventory.focusedAppIndex].name.toLowerCase()] += 1
                                    } else {
                                        newUsage[appList.model[inventory.focusedAppIndex].name.toLowerCase()] = 1
                                    }
                                    inventory.usage = newUsage
                                    root.active = false
                                }
                            }
                        }
                    }
                }
            }


            /////////
            //Label//
            /////////
            Rectangle {
                width: 250
                height: 50
                x: 40
                y: 20
                color: "transparent"
                Text {
                    id: label
                    text: "ALL"
                    color: "white"
                    font.family: futuraFont.name
                    style: Text.Outline
                    font.pixelSize: 32
                }
            }

            //////////////
            //Categories//
            //////////////
            Rectangle {
                width: 620
                height: 50
                x: 10
                y: 80
                color: "transparent"
                clip: true
                RowLayout {
                    anchors.fill: parent
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"
                        Rectangle {
                            id: favorites
                            width: 50
                            height: 50
                            anchors.centerIn: parent
                            color: "transparent"
                            Image {
                                fillMode: Image.PreserveAspectFit
                                anchors.centerIn: parent
                                height: 50
                                source: "../../Assets/Inventory/round-star.png"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    inventory.currentPointer = parent.mapToGlobal(0, 0).x + parent.width - root.screenX
                                    label.text = "FAVORITES"
                                    inventory.currentCategory = "Favorites"
                                    inventory.sortApps(inventory.currentCategory)
                                }
                            }
                        }   
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"
                        Rectangle {
                            id: all
                            width: 50
                            height: 50
                            anchors.centerIn: parent
                            color: "transparent"
                            Image {
                                fillMode: Image.PreserveAspectFit
                                anchors.centerIn: parent
                                height: 50
                                source: "../../Assets/Inventory/backpack.png"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    inventory.currentPointer = parent.mapToGlobal(0, 0).x + parent.width - root.screenX
                                    label.text = "ALL"
                                    inventory.currentCategory = "All"
                                    inventory.sortApps(inventory.currentCategory)
                                }
                            }
                        }   
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"
                        Rectangle {
                            id: office
                            width: 50
                            height: 50
                            anchors.centerIn: parent
                            color: "transparent"
                            Image {
                                fillMode: Image.PreserveAspectFit
                                anchors.centerIn: parent
                                height: 50
                                source: "../../Assets/Inventory/files.png"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    inventory.currentPointer = parent.mapToGlobal(0, 0).x + parent.width - root.screenX
                                    label.text = "OFFICE"
                                    inventory.currentCategory = "Office"
                                    inventory.sortApps(inventory.currentCategory)
                                }
                            }
                        }   
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"
                        Rectangle {
                            id: game
                            width: 50
                            height: 50
                            anchors.centerIn: parent
                            color: "transparent"
                            Image {
                                fillMode: Image.PreserveAspectFit
                                anchors.centerIn: parent
                                height: 50
                                source: "../../Assets/Inventory/console-controller.png"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    inventory.currentPointer = parent.mapToGlobal(0, 0).x + parent.width - root.screenX
                                    label.text = "GAME"
                                    inventory.currentCategory = "Game"
                                    inventory.sortApps(inventory.currentCategory)
                                }
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"
                        Rectangle {
                            id: development
                            width: 50
                            height: 50
                            anchors.centerIn: parent
                            color: "transparent"
                            Image {
                                fillMode: Image.PreserveAspectFit
                                anchors.centerIn: parent
                                height: 50
                                source: "../../Assets/Inventory/computing.png"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    inventory.currentPointer = parent.mapToGlobal(0, 0).x + parent.width - root.screenX
                                    label.text = "DEVELOPMENT"
                                    inventory.currentCategory = "Development"
                                    inventory.sortApps(inventory.currentCategory)
                                }
                            }
                        }   
                    }
                }
            }

            //////////
            //Sorter//
            //////////
            Rectangle {
                width: 610
                height: 30
                x: 15
                y: 160
                color: "transparent"
                Gradient {
                    id: categoryGradient
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.5; color: "#cecece" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
                RowLayout {
                    anchors.fill: parent
                    Rectangle {
                        id: sortName
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"
                        property bool reverse: false
                        property bool active: false
                        Text {
                            anchors.centerIn: parent
                            text: "Name"
                            color: "white"
                            font.family: futuraFont.name
                            style: Text.Outline
                            font.pixelSize: 28
                        }
                        Image {
                            anchors.right: parent.right
                            anchors.rightMargin: 100
                            y: 3
                            opacity: parent.active ? 1 : 0
                            fillMode: Image.PreserveAspectFit
                            height: 25
                            mirrorVertically: parent.reverse
                            source: "../../Assets/Inventory/Sort.png"
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: parent.gradient = categoryGradient
                            onExited: parent.gradient = Gradient.Transparent
                            onClicked: {
                                if (parent.active) {parent.reverse = !parent.reverse}
                                parent.active = true
                                sortUsed.active = false
                                sortUsed.reverse = false
                                inventory.sortApps(inventory.currentCategory)
                            }
                        }
                    }
                    Rectangle {
                        id: sortUsed
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"
                        property bool reverse: false
                        property bool active: true
                        Text {
                            anchors.centerIn: parent
                            text: "Most Used"
                            color: "white"
                            font.family: futuraFont.name
                            style: Text.Outline
                            font.pixelSize: 28
                        }
                        Image {
                            anchors.right: parent.right
                            anchors.rightMargin: 85
                            y: 3
                            opacity: parent.active ? 1 : 0
                            fillMode: Image.PreserveAspectFit
                            height: 25
                            mirrorVertically: parent.reverse
                            source: "../../Assets/Inventory/Sort.png"
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: parent.gradient = categoryGradient
                            onExited: parent.gradient = Gradient.Transparent
                            onClicked: {
                                if (parent.active) {parent.reverse = !parent.reverse}
                                parent.active = true
                                sortName.active = false
                                sortName.reverse = false
                                inventory.sortApps(inventory.currentCategory)
                            }
                        }
                    }
                }
            }

            ////////
            //Apps//
            ////////
            Rectangle {
                width: 20
                height: 20
                x: 607.5
                y: 180
                color: "transparent"
                Image {
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    height: 25
                    source: "../../Assets/Inventory/Scroll Bar Top.png"
                    opacity: (appList.model.length > 21) ? 1 : 0
                }
            }
            Rectangle {
                width: 20
                height: 20
                x: 607.5
                y: root._height-16.5
                color: "transparent"
                Image {
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    height: 25
                    source: "../../Assets/Inventory/Scroll Bar Bottom.png"
                    opacity: (appList.model.length > 21) ? 1 : 0
                }
            }
            ListView {
                id: appList
                width: 610
                height: root._height - 220
                x: 15
                y: 200
                clip: true
                model: inventory.apps.sort((a, b) => a.name.localeCompare(b.name))
                spacing: 1

                ScrollBar.vertical: ScrollBar {
                    background: Rectangle {
                        color: '#67676767'
                        border.width: 1
                        border.color: "#cecece"
                        opacity: (appList.count > 21) ? 1 : 0
                    }
                    contentItem: Rectangle {
                        implicitWidth: 12
                        color: "#cecece"
                        border.width: 1
                        border.color: "white"
                        opacity: (appList.count > 21) ? 1 : 0
                    }
                }

                delegate: Rectangle {
                    id: app
                    property bool focused: inventory.focusedAppIndex == index
                    width: 590
                    height: 40
                    color: "transparent"
                    gradient: focused || itemHover.hovered ? gradient : Gradient.Transparent

                    Gradient {
                        id: gradient
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 1.0; color: "#cecece" }
                    }
                    HoverHandler { id: itemHover }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            modelData.execute()
                            let newUsage = JSON.parse(JSON.stringify(inventory.usage))
                            if (newUsage.hasOwnProperty(modelData.name.toLowerCase())) {
                                newUsage[modelData.name.toLowerCase()] += 1
                            } else {
                                newUsage[modelData.name.toLowerCase()] = 1
                            }
                            inventory.usage = newUsage
                            root.active = false
                        }
                    }
                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 40
                        text: modelData.name
                        color: "white"
                        font.family: futuraFont.name
                        style: Text.Outline
                        font.pixelSize: 24
                    }
                    Image {
                        fillMode: Image.PreserveAspectFit
                        height: 25
                        source: Quickshell.iconPath(modelData.icon, 32)
                    }
                    Rectangle {
                        width: 40
                        height: 40
                        radius: 10
                        anchors.right: parent.right
                        anchors.rightMargin: 20
                        color: starHover.hovered ? '#be4c4c4c' :"transparent"
                        Image {
                            fillMode: Image.PreserveAspectFit
                            anchors.centerIn: parent
                            height: 30
                            opacity: source == "../../Assets/Inventory/round-star.png" ? 0.75 : starHover.hovered ? 1 : itemHover.hovered ? 0.5 : 0
                            source: inventory.favorites.includes(modelData.name.toLowerCase()) ? "../../Assets/Inventory/round-star.png" : "../../Assets/Inventory/round-star-empty.png"
                        }
                        HoverHandler { id: starHover }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (inventory.favorites.includes(modelData.name.toLowerCase())) {
                                    let i = inventory.favorites.indexOf(modelData.name.toLowerCase())
                                    inventory.favorites.splice(i, 1)
                                } else {
                                    inventory.favorites.push(modelData.name.toLowerCase())
                                }
                            }
                        }
                    }
                }
            }
            function sortApps(category: string) {
                if (category == "All") {
                    if (input.text != ""){
                        if (sortName.active) {
                            appList.model = inventory.apps
                                .filter(a => a.name.toLowerCase().match(input.text.toLowerCase()))
                                .sort((a, b) => {
                                    return sortName.reverse ? b.name.localeCompare(a.name) : a.name.localeCompare(b.name)
                                }
                            )
                        } 
                        if (sortUsed.active) {
                            appList.model = inventory.apps
                                .filter(a => a.name.toLowerCase().match(input.text.toLowerCase()))
                                .sort((a, b) => {
                                    let ua = inventory.usage[a.name.toLowerCase()] ?? 0
                                    let ub = inventory.usage[b.name.toLowerCase()] ?? 0
                                    if (ua !== ub) return sortUsed.reverse ? ua - ub : ub - ua
                                    return sortUsed.reverse ? b.name.localeCompare(a.name) : a.name.localeCompare(b.name)
                                }
                            )
                        }
                    }
                    else {
                        if (sortName.active) {
                            appList.model = inventory.apps
                                .filter(a => a.name.toLowerCase())
                                .sort((a, b) => {
                                    return sortName.reverse ? b.name.localeCompare(a.name) : a.name.localeCompare(b.name)
                                }
                            )
                        } 
                        if (sortUsed.active) {
                            appList.model = inventory.apps
                                .filter(a => a.name.toLowerCase())
                                .sort((a, b) => {
                                    let ua = inventory.usage[a.name.toLowerCase()] ?? 0
                                    let ub = inventory.usage[b.name.toLowerCase()] ?? 0
                                    if (ua !== ub) return sortUsed.reverse ? ua - ub : ub - ua
                                    return sortUsed.reverse ? b.name.localeCompare(a.name) : a.name.localeCompare(b.name)
                                }
                            )
                        }
                    }
                }
                else if (category == "Favorites") {
                    if (input.text != ""){
                        if (sortName.active) {
                            appList.model = inventory.apps
                                .filter(a => a.name.toLowerCase().match(input.text.toLowerCase()) && inventory.favorites.includes(a.name.toLowerCase()))
                                .sort((a, b) => {
                                    return sortName.reverse ? b.name.localeCompare(a.name) : a.name.localeCompare(b.name)
                                }
                            )
                        } 
                        if (sortUsed.active) {
                            appList.model = inventory.apps
                                .filter(a => a.name.toLowerCase().match(input.text.toLowerCase()) && inventory.favorites.includes(a.name.toLowerCase()))
                                .sort((a, b) => {
                                    let ua = inventory.usage[a.name.toLowerCase()] ?? 0
                                    let ub = inventory.usage[b.name.toLowerCase()] ?? 0
                                    if (ua !== ub) return sortUsed.reverse ? ua - ub : ub - ua
                                    return sortUsed.reverse ? b.name.localeCompare(a.name) : a.name.localeCompare(b.name)
                                }
                            )
                        }
                    }
                    else {
                        if (sortName.active) {
                            appList.model = inventory.apps
                                .filter(a => a.name.toLowerCase() && inventory.favorites.includes(a.name.toLowerCase()))
                                .sort((a, b) => {
                                    return sortName.reverse ? b.name.localeCompare(a.name) : a.name.localeCompare(b.name)
                                }
                            )
                        } 
                        if (sortUsed.active) {
                            appList.model = inventory.apps
                                .filter(a => a.name.toLowerCase() && inventory.favorites.includes(a.name.toLowerCase()))
                                .sort((a, b) => {
                                    let ua = inventory.usage[a.name.toLowerCase()] ?? 0
                                    let ub = inventory.usage[b.name.toLowerCase()] ?? 0
                                    if (ua !== ub) return sortUsed.reverse ? ua - ub : ub - ua
                                    return sortUsed.reverse ? b.name.localeCompare(a.name) : a.name.localeCompare(b.name)
                                }
                            )
                        }
                    }
                }
                else {
                    if (input.text != ""){
                        if (sortName.active) {
                            appList.model = inventory.apps
                                .filter(a => a.name.toLowerCase().match(input.text.toLowerCase()) && a.categories.includes(category))
                                .sort((a, b) => {
                                    return sortName.reverse ? b.name.localeCompare(a.name) : a.name.localeCompare(b.name)
                                }
                            )
                        } 
                        if (sortUsed.active) {
                            appList.model = inventory.apps
                                .filter(a => a.name.toLowerCase().match(input.text.toLowerCase()) && a.categories.includes(category))
                                .sort((a, b) => {
                                    let ua = inventory.usage[a.name.toLowerCase()] ?? 0
                                    let ub = inventory.usage[b.name.toLowerCase()] ?? 0
                                    if (ua !== ub) return sortUsed.reverse ? ua - ub : ub - ua
                                    return sortUsed.reverse ? b.name.localeCompare(a.name) : a.name.localeCompare(b.name)
                                }
                            )
                        }
                    }
                    else {
                        if (sortName.active) {
                            appList.model = inventory.apps
                                .filter(a => a.name.toLowerCase() && a.categories.includes(category))
                                .sort((a, b) => {
                                    return sortName.reverse ? b.name.localeCompare(a.name) : a.name.localeCompare(b.name)
                                }
                            )
                        } 
                        if (sortUsed.active) {
                            appList.model = inventory.apps
                                .filter(a => a.name.toLowerCase() && a.categories.includes(category))
                                .sort((a, b) => {
                                    let ua = inventory.usage[a.name.toLowerCase()] ?? 0
                                    let ub = inventory.usage[b.name.toLowerCase()] ?? 0
                                    if (ua !== ub) return sortUsed.reverse ? ua - ub : ub - ua
                                    return sortUsed.reverse ? b.name.localeCompare(a.name) : a.name.localeCompare(b.name)
                                }
                            )
                        }
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.active = false  // clic sur le fond = fermer
        }
    }
}