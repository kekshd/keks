$(document).ready(function() {
  $("a[data-replace-parent-url]").one('click', function() {
    var url = $(this).data('replace-parent-url');
    $(this).parent().load(url);
  });
});
