$(document).ready(function() {
  //~　var performance = window.performance || window.mozPerformance || window.msPerformance || window.webkitPerformance || null;
  if(typeof performance === "undefined") return;

  var now = new Date().getTime();
  var page_load_time = now - performance.timing.navigationStart;
  if(console) console.log("User-perceived page loading time: " + page_load_time/1000.0);
  $("#load_time").html(page_load_time/1000.0);

  $.post(Routes.perf_path(), {
    perf: {
      agent: navigator.userAgent,
      url: location.href,
      load_time: page_load_time
    }
  });
});
