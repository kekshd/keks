$(document).ready(function() {
  $(".tablesorter").addClass('tablesorter-dropbox').tablesorter();
});

$(document).ajaxComplete(function() {
  $(".tablesorter").addClass('tablesorter-dropbox').tablesorter();
});
