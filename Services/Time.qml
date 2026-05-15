pragma Singleton
import QtQuick

import Quickshell

Singleton {
  id: root

  // Current date
  property var now: new Date()

  // Unix timestamp of the last update
  property real _lastUpdateTs: Date.now()

  // Signal emitted when a significant time jump is detected (e.g. system resume)
  signal resumed

  // Returns a Unix Timestamp (in seconds)
  readonly property int timestamp: {
    return Math.floor(root.now / 1000);
  }
  readonly property list<string> days: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
  readonly property list<string> months: ["January", "February", "March", "April", "May", "June", "Jully", "August", "September", "October", "November", "December"]

  // Timer state (for countdown/stopwatch)
  property bool timerRunning: false
  property bool timerStopwatchMode: false
  property int timerRemainingSeconds: 0
  property int timerTotalSeconds: 0
  property int timerElapsedSeconds: 0
  property bool timerSoundPlaying: false
  property int timerStartTimestamp: 0 // Unix timestamp when timer was started
  property int timerPausedAt: 0 // Value when paused (for resuming)

  Timer {
    id: updateTimer
    interval: 1000
    repeat: true
    running: true
    triggeredOnStart: false
    onTriggered: {
      var newTime = new Date();
      var currentTs = newTime.getTime();

      // Detect time jump (e.g. system resume) - threshold: 5 seconds
      if (currentTs - root._lastUpdateTs > 5000) {
        root.resumed();
      }
      root._lastUpdateTs = currentTs;

      root.now = newTime;

      // Update timer if running
      if (root.timerRunning && root.timerStartTimestamp > 0) {
        const elapsedSinceStart = root.timestamp - root.timerStartTimestamp;

        if (root.timerStopwatchMode) {
          root.timerElapsedSeconds = root.timerPausedAt + elapsedSinceStart;
        } else {
          root.timerRemainingSeconds = root.timerTotalSeconds - elapsedSinceStart;
          if (root.timerRemainingSeconds <= 0) {
            root.timerOnFinished();
          }
        }
      }

      // Adjust next interval to sync with the start of the next second
      var msIntoSecond = newTime.getMilliseconds();
      if (msIntoSecond > 100) {
        // If we're more than 100ms into the second, adjust for next time
        updateTimer.interval = 1000 - msIntoSecond + 10; // +10ms buffer
        updateTimer.restart();
      } else {
        updateTimer.interval = 1000;
      }
    }
  }

  Component.onCompleted: {
    // Start by syncing to the next second boundary
    var now = new Date();
    var msUntilNextSecond = 1000 - now.getMilliseconds();
    updateTimer.interval = msUntilNextSecond + 10; // +10ms buffer
    updateTimer.restart();
  }

  // Formats a Date object into a YYYYMMDD-HHMMSS string.
  function getFullDate(date) {
    if (!date) {
      date = new Date();
    }
    const year = date.getFullYear();

    // getMonth() is zero-based, so we add 1
    const month = root.months[date.getMonth()];
    const day = String(date.getDate()).padStart(2, '0');
    const m_day = root.days[date.getDay()-1];

    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    const seconds = String(date.getSeconds()).padStart(2, '0');

    return `${m_day}, ${month} ${day} ${year}\n${hours}:${minutes}:${seconds}`;
  }

  // Format an easy to read approximate duration ex: 4h 32m
  // Used to display the time remaining on the Battery widget, computer uptime, etc..
  function formatVagueHumanReadableDuration(totalSeconds) {
    if (typeof totalSeconds !== 'number' || totalSeconds < 0) {
      return '0s';
    }

    // Floor the input to handle decimal seconds
    totalSeconds = Math.floor(totalSeconds);

    const days = Math.floor(totalSeconds / 86400);
    const hours = Math.floor((totalSeconds % 86400) / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = totalSeconds % 60;

    const parts = [];
    if (days)
      parts.push(`${days}d`);
    if (hours)
      parts.push(`${hours}h`);
    if (minutes)
      parts.push(`${minutes}m`);

    // Only show seconds if no hours and no minutes
    if (!hours && !minutes) {
      parts.push(`${seconds}s`);
    }

    return parts.join(' ');
  }
}