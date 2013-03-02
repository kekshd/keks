$(document).ready(function() {
  $("textarea[data-preview]").each(function(ind, txt) {
    txt = $(txt);
    var p = $(txt.data('preview'));
    var t;


    var render = function() {
      p.load(Routes.render_preview_path(),
        {text: txt.val()}
      );
    };

    txt.keyup(function() {
      if(t) clearTimeout(t);
      t = setTimeout(render, 1000);
    }).keyup();
  });
});
