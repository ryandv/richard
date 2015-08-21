(function doPoll(data) {
  var NAG_TIMER = 15 * 60; // 15 minutes

  // Request permission
  Notification.requestPermission(function (permission) {
    // Whatever the user answers, we make sure we store the information
    if(!('permission' in Notification)) {
      Notification.permission = permission;
    }
  });

  localStorage.setItem("lastNotificationTime", moment());

  function checkIsNextInLine(statusObject) {
    if (statusObject.isNextInLine() && statusObject.statusChange()) {
      sendNotification("Hey there. Just swinging by to let you know gorgon is free!\nxoxo, Richard", {icon: "/assets/Richard-Gere.jpg"});
      statusObject.sendNotification();
    }
  }

  var nagTimer = (function (nagCallback) {
    var running = false;
    var timer = 60 * 15; // 15 minutes
    var interval;

    return {
      start: function () {
        running = true;
        interval = setInterval(timer, nagCallback)
      },

      stop: function () {
        running = false;
        clearInterval(interval);
      }
    }
  })();

  var statusObject = (function (runningCallback) {
    var lastStatus;
    var statusChange = false;
    var lastNotificationTime;

    return {
      updateStatus: function (newStatus) {
        statusChange = (lastStatus == newStatus);
        lastStatus = newStatus;

        if(newStatus == "running" && statusChange) {
          runningCallback();
          nagtimer.start()
        }

        if(newStatus != "running") {
          nagTimer.stop();
        }
      },

      isNextInLine: function () {
        return lastStatus == "running";
      },

      statusChange: function () {
        return statusChange;
      },

      sendNotification: function () {

      }

    };
  })();

  function checkIsHogging(status) {
    var lastNotificationTime = localStorage.getItem("lastNotificationTime");
    var minutesSinceLastNotification = moment().diff(lastNotificationTime, 'seconds')

    if(status === 'running' && minutesSinceLastNotification > NAG_TIMER) {
      sendNotification("Hey there. Do you still need the Richard?\nxoxo, Richard", {icon: "/assets/Richard-Gere.jpg"});
      localStorage.setItem("lastNotificationTime", moment());
    }
  }

  var poller = function () {
    $.get('/queue/status')
    .done(function (data) {
      var transaction = data["content"]["queue_transaction"];
      var status = (transaction != undefined) ? transaction["status"] : null;

      checkIsNextInLine(status);
      checkIsHogging(status);
    });
  }

  function sendNotification(text, options) {
    if (!("Notification" in window)) {
      alert("This browser does not support desktop notification");
    } else if (Notification.permission === "granted") {
      return new Notification(text, options);
    }
  }

  setInterval(poller, 5000);
})();
