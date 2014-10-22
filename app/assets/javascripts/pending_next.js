(function doPoll(data) {
  $.get('queue_transactions/pending_next')
    .done(function (data) {
      if (localStorage.getItem("next_in_line") == 'false' && data["next_in_line"] == true) {
        notifyMe();
      }
      localStorage.setItem("next_in_line", data["next_in_line"])
    })
    .always(function () {
      setTimeout(doPoll, 3000);
    });
})();

function notifyMe() {
  // Let's check if the browser supports notifications
  if (!("Notification" in window)) {
    alert("This browser does not support desktop notification");
  }
  // Let's check if the user is okay to get some notification
  else if (Notification.permission === "granted") {
    // If it's okay let's create a notification
    var notification = new Notification("Hey there. Just swinging by to let you know gorgon is free!\nxoxo, Richard", {icon: "<%= image_path('Richard-Gere.jpg') %>"});
  }
  // Otherwise, we need to ask the user for permission
  // Note, Chrome does not implement the permission static property
  // So we have to check for NOT 'denied' instead of 'default'
  else if (Notification.permission !== 'denied') {
    Notification.requestPermission(function (permission) {
      // Whatever the user answers, we make sure we store the information
      if (!('permission' in Notification)) {
        Notification.permission = permission;
      }
      // If the user is okay, let's create a notification
      if (permission === "granted") {
        var notification = new Notification("Gorgon is free!", {icon: "<%= image_path('Richard-Gere.jpg') %>"});
      }
    });
  }
  // At last, if the user already denied any notification, and you
  // want to be respectful there is no need to bother him any more.
}