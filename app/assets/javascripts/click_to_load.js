$(document).ready(function() {
  $("a[data-replace-parent-url]").one('click', function() {
    var url = $(this).data('replace-parent-url');
    $(this).parent().load(url);
  });

  $("a[data-ajax='1']").click(function(event) {
    event.preventDefault();

    var url = $(this).attr("href");
    var extract = $(this).data('extract-selector');

    var $target = $($(this).data('target-selector'));
    $target.css('height', $target.height()).addClass('loading');

    // work around jQuery not executing scripts when extracting code
    var tempDiv = $("<div/>").load(url, function() {
      var snippet = extract ? tempDiv.find(extract) : tempDiv;
      $target.html(snippet).removeClass('loading');
      $target.animate({height: snippet.height()});
    });
  });
});
