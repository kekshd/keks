function throw_with_alert(msg, extra) {
  var strace = Error().stack;
  alert("Es ist ein Fehler aufgetreten. Das ist vermutlich unsere Schuld.\n\nWenn Du magst, kannst Du uns helfen den Fehler zu beheben. Kopiere dazu die nachfolgenden Details und maile sie an keks@uni-hd.de oder nutze das Feedback Formular. Danke!\n\n" + msg + "\n\n" + strace + "\n\nExtra-Info: " + extra);
  throw(msg);
}

// deprecated
function throwWithAlert(msg, extra) {
  return throw_with_alert(msg, extra);
}
