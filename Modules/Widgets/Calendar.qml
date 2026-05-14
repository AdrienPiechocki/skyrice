import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.Commons
import qs.Modules
import qs.Services

LazyLoader {
    id: root
    active: false
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
            id: window
            anchors.right: parent.left
            anchors.top: parent.top
            margins.top: 40
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            implicitHeight: 500
            implicitWidth: 400
            color: "transparent"
            Item {
                anchors.fill: parent
                focus: true
                Keys.onEscapePressed: root.active = false
            }
            Background{ width: parent.width; height: parent.height; stroke: 2}
            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 30
                anchors.bottomMargin: 30
                anchors.leftMargin: 30
                anchors.rightMargin: 30
                color: "transparent"

                FontLoader {
                    id: futuraFont
                    source: "../../Assets/Fonts/Futura Condensed Medium.ttf"
                }
                Gradient {
                    id: gradient
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0; color: "transparent" }
                    GradientStop { position: 0.5; color: "#67cecece" }
                    GradientStop { position: 1; color: "transparent" }
                }
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        color: "transparent"
                        Text{
                            anchors.centerIn: parent
                            horizontalAlignment: Text.AlignHCenter
                            text: Time.getFullDate(Time.now)
                            color: "white"
                            font.family: futuraFont.name
                            font.pointSize: 18
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20
                        color: "transparent"
                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width
                            height: 2
                            gradient: gradient
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20
                        color: "transparent"
                        RowLayout {
                            anchors.fill: parent
                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                width: 60
                                height: 30
                                color: "#42cecece"
                                radius: 10
                                Text {
                                    anchors.centerIn: parent
                                    text: "prev"
                                    color: "white"
                                    font.pointSize: 11
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: list.navigateToPreviousMonth()
                                    hoverEnabled: true
                                    onEntered: parent.color = "#67cecece"
                                    onExited: parent.color = "#42cecece"
                                }
                            }
                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                width: 60
                                height: 30
                                color: "#42cecece"
                                radius: 10
                                Text {
                                    anchors.centerIn: parent
                                    text: "now"
                                    color: "white"
                                    font.pointSize: 11
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        list.calendarMonth = list.now.getMonth();
                                        list.calendarYear = list.now.getFullYear();
                                        CalendarService.loadEvents();
                                    }
                                    hoverEnabled: true
                                    onEntered: parent.color = "#67cecece"
                                    onExited: parent.color = "#42cecece"
                                }
                            }
                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                width: 60
                                height: 30
                                color: "#42cecece"
                                radius: 10
                                Text {
                                    anchors.centerIn: parent
                                    text: "next"
                                    color: "white"
                                    font.pointSize: 11
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: list.navigateToNextMonth()
                                    hoverEnabled: true
                                    onEntered: parent.color = "#67cecece"
                                    onExited: parent.color = "#42cecece"
                                }
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20
                        color: "transparent"
                    }
                    Rectangle {
                        id: list
                        Layout.fillWidth: true
                        Layout.preferredHeight: 250
                        color: "transparent"
                        Component.onCompleted: {
                            CalendarService.loadEvents()
                            CalendarService.loadCachedEvents()
                        }
                        readonly property var now: Time.now
                        property int calendarMonth: now.getMonth()
                        property int calendarYear: now.getFullYear()
                        readonly property int firstDayOfWeek: 1

                        // Helper function to calculate ISO week number
                        function getISOWeekNumber(date) {
                            const target = new Date(date.valueOf());
                            const dayNr = (date.getDay() + 6) % 7;
                            target.setDate(target.getDate() - dayNr + 3);
                            const firstThursday = new Date(target.getFullYear(), 0, 4);
                            const diff = target - firstThursday;
                            const oneWeek = 1000 * 60 * 60 * 24 * 7;
                            const weekNumber = 1 + Math.round(diff / oneWeek);
                            return weekNumber;
                        }

                        // Helper function to check if an event is all-day
                        function isAllDayEvent(event) {
                            const duration = event.end - event.start;
                            const startDate = new Date(event.start * 1000);
                            const isAtMidnight = startDate.getHours() === 0 && startDate.getMinutes() === 0;
                            return duration === 86400 && isAtMidnight;
                        }

                        // Navigation functions
                        function navigateToPreviousMonth() {
                            let newDate = new Date(list.calendarYear, list.calendarMonth - 1, 1);
                            list.calendarYear = newDate.getFullYear();
                            list.calendarMonth = newDate.getMonth();
                            const now = new Date();
                            const monthStart = new Date(list.calendarYear, list.calendarMonth, 1);
                            const monthEnd = new Date(list.calendarYear, list.calendarMonth + 1, 0);
                            const daysBehind = Math.max(0, Math.ceil((now - monthStart) / (24 * 60 * 60 * 1000)));
                            const daysAhead = Math.max(0, Math.ceil((monthEnd - now) / (24 * 60 * 60 * 1000)));
                            CalendarService.loadEvents(daysAhead + 30, daysBehind + 30);
                        }

                        function navigateToNextMonth() {
                            let newDate = new Date(list.calendarYear, list.calendarMonth + 1, 1);
                            list.calendarYear = newDate.getFullYear();
                            list.calendarMonth = newDate.getMonth();
                            const now = new Date();
                            const monthStart = new Date(list.calendarYear, list.calendarMonth, 1);
                            const monthEnd = new Date(list.calendarYear, list.calendarMonth + 1, 0);
                            const daysBehind = Math.max(0, Math.ceil((now - monthStart) / (24 * 60 * 60 * 1000)));
                            const daysAhead = Math.max(0, Math.ceil((monthEnd - now) / (24 * 60 * 60 * 1000)));
                            CalendarService.loadEvents(daysAhead + 30, daysBehind + 30);
                        }

                        // Helper functions
                        function hasEventsOnDate(year, month, day) {
                            if (!CalendarService.available || CalendarService.events.length === 0)
                            return false;
                            const targetDate = new Date(year, month, day);
                            const targetStart = new Date(targetDate.getFullYear(), targetDate.getMonth(), targetDate.getDate()).getTime() / 1000;
                            const targetEnd = targetStart + 86400;
                            return CalendarService.events.some(event => {
                                                                return (event.start >= targetStart && event.start < targetEnd) || (event.end > targetStart && event.end <= targetEnd) || (event.start < targetStart && event.end > targetEnd);
                                                            });
                        }

                        function getEventsForDate(year, month, day) {
                            if (!CalendarService.available || CalendarService.events.length === 0)
                            return [];
                            const targetDate = new Date(year, month, day);
                            const targetStart = Math.floor(new Date(targetDate.getFullYear(), targetDate.getMonth(), targetDate.getDate()).getTime() / 1000);
                            const targetEnd = targetStart + 86400;
                            return CalendarService.events.filter(event => {
                                                                return (event.start >= targetStart && event.start < targetEnd) || (event.end > targetStart && event.end <= targetEnd) || (event.start < targetStart && event.end > targetEnd);
                                                                });
                        }

                        function isMultiDayEvent(event) {
                            if (list.isAllDayEvent(event)) {
                            return false;
                            }
                            const startDate = new Date(event.start * 1000);
                            const endDate = new Date(event.end * 1000);
                            const startDateOnly = new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate());
                            const endDateOnly = new Date(endDate.getFullYear(), endDate.getMonth(), endDate.getDate());
                            return startDateOnly.getTime() !== endDateOnly.getTime();
                        }

                        function getEventColor(event, isToday) {
                            if (isMultiDayEvent(event)) {
                            return isToday ? "cyan" : "lightblue";
                            } else if (list.isAllDayEvent(event)) {
                            return isToday ? "cyan" : "lightblue";
                            } else {
                            return isToday ? "cyan" : "lightblue";
                            }
                        }

                        GridLayout {
                            id: grid
                            anchors.fill: parent
                            columns: 7
                            rowSpacing: 10 + rows


                            property int month: list.calendarMonth
                            property int year: list.calendarYear

                            property var daysModel: {
                                const firstOfMonth = new Date(year, month, 1);
                                const lastOfMonth = new Date(year, month + 1, 0);
                                const daysInMonth = lastOfMonth.getDate();
                                const firstDayOfWeek = list.firstDayOfWeek;
                                const firstOfMonthDayOfWeek = firstOfMonth.getDay();
                                let daysBefore = (firstOfMonthDayOfWeek - firstDayOfWeek + 7) % 7;
                                const lastOfMonthDayOfWeek = lastOfMonth.getDay();
                                const daysAfter = (firstDayOfWeek - lastOfMonthDayOfWeek - 1 + 7) % 7;
                                const days = [];
                                const today = new Date();

                                // Previous month days
                                const prevMonth = new Date(year, month, 0);
                                const prevMonthDays = prevMonth.getDate();
                                for (var i = daysBefore - 1; i >= 0; i--) {
                                    const day = prevMonthDays - i;
                                    days.push({
                                                "day": day,
                                                "month": month - 1,
                                                "year": month === 0 ? year - 1 : year,
                                                "today": false,
                                                "currentMonth": false
                                            });
                                }

                                // Current month days
                                for (var day = 1; day <= daysInMonth; day++) {
                                    const date = new Date(year, month, day);
                                    const isToday = date.getFullYear() === today.getFullYear() && date.getMonth() === today.getMonth() && date.getDate() === today.getDate();
                                    days.push({
                                                "day": day,
                                                "month": month,
                                                "year": year,
                                                "today": isToday,
                                                "currentMonth": true
                                            });
                                }

                                // Next month days
                                for (var i = 1; i <= daysAfter; i++) {
                                    days.push({
                                                "day": i,
                                                "month": month + 1,
                                                "year": month === 11 ? year + 1 : year,
                                                "today": false,
                                                "currentMonth": false
                                            });
                                }

                                return days;
                            }

                            Repeater {
                                model: grid.daysModel

                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    Rectangle {
                                        width: 40
                                        height: 40
                                        anchors.centerIn: parent
                                        radius: 10
                                        color: modelData.today ? "#67cecece" : "#42cecece"

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.day
                                            color: {
                                            if (modelData.today)
                                                return "#ffffff";
                                            if (modelData.currentMonth)
                                                return '#cecece';
                                            return "#cecece";
                                            }
                                            opacity: modelData.currentMonth ? 1.0 : 0.4
                                            font.pointSize: 12
                                        }

                                        // Event indicator dots
                                        Row {
                                            visible: list.hasEventsOnDate(modelData.year, modelData.month, modelData.day)
                                            spacing: 2
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            anchors.bottom: parent.bottom
                                            anchors.bottomMargin: 5

                                            Repeater {
                                                model: list.getEventsForDate(modelData.year, modelData.month, modelData.day)

                                                Rectangle {
                                                    width: 4
                                                    height: width
                                                    radius: 2
                                                    color: list.getEventColor(modelData, modelData.today)
                                                }
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                                            onClicked: (mouse)=> {
                                                const dateWithSlashes = `${modelData.day.toString().padStart(2, '0')}/${(modelData.month + 1).toString().padStart(2, '0')}/${modelData.year.toString().substring(2)}`;
                                                info.dateWithSlashes = dateWithSlashes
                                                let events = list.getEventsForDate(modelData.year, modelData.month, modelData.day)
                                                description.model = events
                                            }
                                            hoverEnabled: true
                                            onEntered: parent.color = "#cececece"
                                            onExited: parent.color = modelData.today ? "#67cecece" : "#42cecece"
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20
                        color: "transparent"
                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width
                            height: 2
                            gradient: gradient
                        }
                    }
                    Rectangle {
                        id: info
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"
                        clip: true
                        property var dateWithSlashes
                        GridLayout {
                            anchors.fill: parent
                            columns: 3
                            rowSpacing: 0
                            Repeater {
                                id: description
                                model: 0
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: parent.width/3
                                    Layout.preferredHeight: parent.height/3
                                    Layout.alignment: Qt.AlignHCenter
                                    clip: true
                                    color: "transparent"
                                    Text {
                                        anchors.fill: parent
                                        anchors.centerIn: parent
                                        horizontalAlignment: Text.AlignHCenter
                                        color: "white"
                                        font.family: futuraFont.name
                                        font.pointSize: 14
                                        text: modelData.summary
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                Quickshell.execDetached(["gnome-calendar", "--date", info.dateWithSlashes]);
                            }
                            hoverEnabled: true
                            onEntered: parent.gradient = description.model.length > 0 ? gradient : Gradient.Transparent
                            onExited: parent.gradient = Gradient.Transparent
                        }
                    }
                }
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: root.active = false
        }
    }
}