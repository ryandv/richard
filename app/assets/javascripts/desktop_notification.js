(function doPoll(data) {
    $.get('queue_transactions/pending_next')
        .done(function (data) {
            if (localStorage.getItem("next_in_line") == 'false' && data["next_in_line"] == true) {
                notifyMe();
            }
            localStorage.setItem("next_in_line", data["next_in_line"])
        })
        .always(function () {
            setTimeout(doPoll, 5000);
        });
})();


function notifyMe() {
    if (!("Notification" in window)) {
        alert("This browser does not support desktop notification");
    }
    else if (Notification.permission === "granted") {
        var notification = new Notification("Hey there. Just swinging by to let you know gorgon is free!\nxoxo, Richard", {icon: "<%= image_path('Richard-Gere.jpg') %>"});
    }
    else if (Notification.permission !== 'denied') {
        Notification.requestPermission(function (permission) {
            if(!('permission' in Notification)) {
                Notification.permission = permission;
            }
            if (permission === "granted") {
                var notification = new Notification("Gorgon is free!", {icon: "<%= image_path('Richard-Gere.jpg') %>"});
            }
        });
    }
}