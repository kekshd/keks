(function() {

  function loadToSnippet(element, url) {
    var $el = $(element);
    if(!url) url = $el.attr("href");

    var extract = $el.data('extract-selector');
    var $target = $($el.data('target-selector'));

    if($target.data('current-url') === url) return;
    $target.data('current-url', url);

    $target.css('height', $target.height()).addClass('loading');

    // work around jQuery not executing scripts when extracting code
    var tempDiv = $("<div/>").load(url, function() {
      var snippet = extract ? tempDiv.find(extract) : tempDiv;
      $target.html(snippet).removeClass('loading');
      $target.animate({height: snippet.height()});
    });

    if($el.data('update-url') == 1) {
      window.history.replaceState("", window.title, url);
    }
  }

  function submitFormAjaxy(form) {
    var $form = $(form);
    var url = $form.attr("action") + "?" + $form.serialize();
    clearTimeout($form.data("submit-timer"));
    loadToSnippet($form, url);
  }


  $(document).ready(function() {
    // "replace me" links
    $("a[data-replace-parent-url]").one('click', function() {
      var url = $(this).data('replace-parent-url');
      $(this).parent().load(url);
    });

    // customizeable links that load anywhere, with JS execution
    $("a[data-ajax='1']").click(function(event) {
      event.preventDefault();
      loadToSnippet(this);
    });

    // forms and their inputs
    $("form[data-ajax='1']").submit(function(event) {
      event.preventDefault();
      submitFormAjaxy(this);
    });

    $("form[data-ajax='1'] input").keyup(function(event) {
      if(event.keyCode === 13) return; // ignore enter

      var $form = $(this).parents("form");
      clearTimeout($form.data("submit-timer"));
      var submit = function() { submitFormAjaxy($form); };
      $form.data("submit-timer", setTimeout(submit, 400));
    });

    // pagination links. Assumes some #results > #wrapper structure
    $("#results").on("click", ".pagination a", function(event) {
      event.preventDefault();
      var $el = $(this);
      $el.data('extract-selector', '#wrapper');
      $el.data('target-selector', '#results');
      $el.data('update-url', '1');
      loadToSnippet($el);
    });
  });
})();
