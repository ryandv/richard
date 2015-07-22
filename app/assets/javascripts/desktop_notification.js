(function doPoll(data) {

  var poller = function () {
    $.get('/queue/status')
    .done(function (data) {
      if (localStorage.getItem("is_next_in_line") == 'false' && data["is_next_in_line"] == true) {
        notifyMe();
      }
      localStorage.setItem("is_next_in_line", data["is_next_in_line"])
    })
  }

  function createNotification() {
    return new Notification("Hey there. Just swinging by to let you know gorgon is free!\nxoxo, Richard", {icon: "/assets/Richard-Gere.jpg"});
  }

  function notifyMe() {
    if (!("Notification" in window)) {
      alert("This browser does not support desktop notification");
    }
    else if (Notification.permission === "granted") {
      createNotification();
    }

    // Otherwise, we need to ask the user for permission
    // Note, Chrome does not implement the permission static property
    // So we have to check for NOT 'denied' instead of 'default'
    else if (Notification.permission !== 'denied') {
      Notification.requestPermission(function (permission) {
        // Whatever the user answers, we make sure we store the information
        if(!('permission' in Notification)) {
          Notification.permission = permission;
        }

        // If the user is okay, let's create a notification
        if (permission === "granted") {
          createNotification();
        }
      });
    }
  }


  setInterval(poller, 5000);
})();
