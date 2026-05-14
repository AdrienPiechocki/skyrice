pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services

Singleton {
  id: root

  // Core state
  property var events: ([])
  property bool loading: false
  property bool available: false
  property string lastError: ""
  property var calendars: ([])

  property var dataProvider: null

  // Persistent cache
  property string configFile: Quickshell.shellDir + "/Config/calendar.json"

  // Cache file handling
  FileView {
    id: configFileView
    path: root.configFile
    printErrors: false

    JsonAdapter {
      id: cacheAdapter
      property var cachedEvents: ([])
      property var cachedCalendars: ([])
      property string lastUpdate: ""
    }

    onLoadFailed: {
      cacheAdapter.cachedEvents = ([]);
      cacheAdapter.cachedCalendars = ([]);
      cacheAdapter.lastUpdate = "";
    }

    onLoaded: {
      loadFromCache();
    }
  }

  Component.onCompleted: {
    loadFromCache();
    checkAvailability();
  }

  // Save cache with debounce
  Timer {
    id: saveDebounce
    interval: 1000
    onTriggered: configFileView.writeAdapter()
  }

  function setEvents(newEvents) {
    root.events = newEvents;
    cacheAdapter.cachedEvents = newEvents;
    cacheAdapter.lastUpdate = new Date().toISOString();
    saveCache();
  }

  function setCalendars(newCalendars) {
    root.calendars = newCalendars;
    cacheAdapter.cachedCalendars = newCalendars;
    saveCache();
  }

  function loadCachedEvents() {
    if (cacheAdapter.cachedEvents.length > 0) {
      root.events = cacheAdapter.cachedEvents;
    }
  }

  function saveCache() {
    saveDebounce.restart();
  }

  // Load events and calendars from cache
  function loadFromCache() {
    if (cacheAdapter.cachedEvents && cacheAdapter.cachedEvents.length > 0) {
      root.events = cacheAdapter.cachedEvents;
    //   print(`Loaded ${cacheAdapter.cachedEvents.length} cached event(s)`);
    }

    if (cacheAdapter.cachedCalendars && cacheAdapter.cachedCalendars.length > 0) {
      root.calendars = cacheAdapter.cachedCalendars;
    //   print(`Loaded ${cacheAdapter.cachedCalendars.length} cached calendar(s)`);
    }

    if (cacheAdapter.lastUpdate) {
    //   print(`Cache last updated: ${cacheAdapter.lastUpdate}`);
    }
  }

  // Auto-refresh timer (every 5 minutes)
  Timer {
    id: refreshTimer
    interval: 300000
    running: true
    repeat: true
    onTriggered: loadEvents()
  }

  // Core functions
  function checkAvailability() {
    CalendarData.init();
  }

  function loadCalendars() {
    if (!root.available || !dataProvider) {
      return;
    }

    dataProvider.loadCalendars();
  }
  function loadEvents(daysAhead = 31, daysBehind = 14) {
    if (!root.available || !dataProvider) {
      return;
    }

    dataProvider.loadEvents(daysAhead, daysBehind);
  }
}
