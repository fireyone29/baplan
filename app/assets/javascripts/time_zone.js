// from http://stackoverflow.com/a/24103596
function setCookie(name, value, days) {
  var expires = "";
  if (days) {
    var date = new Date();
    date.setTime(date.getTime() + (days*24*60*60*1000));
    expires = "; expires=" + date.toUTCString();
  }
  document.cookie = name + "=" + value + expires + "; path=/";
}

// from http://stackoverflow.com/a/24103596
function getCookie(name) {
  var nameEQ = name + "=";
  var ca = document.cookie.split(';');
  for(var i = 0; i < ca.length; i++) {
    var c = ca[i];
    while (c.charAt(0) == ' ') c = c.substring(1, c.length);
    if (c.indexOf(nameEQ) === 0) return c.substring(nameEQ.length, c.length);
  }
  return null;
}

// Not run in a callback because we sometimes want to stop the page
// load (which obviously doesn't work in an on load or similar
// callback where the page is already loaded).
var cookie_key = "time_zone";
var time_zone_cookie = getCookie(cookie_key);
var current_time_zone = jstz.determine().name();
if (time_zone_cookie === null || time_zone_cookie != current_time_zone) {
  setCookie(cookie_key, current_time_zone, 14);
  // Don't keep loading the page, we want to reload with the proper
  // timezone cookie set
  window.stop(); //works in all browsers but IE
  document.execCommand("Stop"); //works in IE
  location.reload();
}
