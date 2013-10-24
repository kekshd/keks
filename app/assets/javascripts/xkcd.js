
var XkcdLoader = (function() {
  var insertImmediately = false;
  var preloaded = false;
  var comic = null;

  // inserts comic into last .xkcd element to be found. Will load comic
  // automatically if it is missing.
  function insert() {
    if(!preloaded) {
      insertImmediately = true;
      preload();
      return;
    }

    $(".xkcd:last").html(comic);
    reset();
  }

  // loads a comic into storage
  function preload() {
    if(preloaded) return;

    var path = Routes.random_xkcd_path();
    var tempDiv = $("<div/>").load(path, function(responseText) {
      preloaded = true;
      // get comic innerHTML
      comic = tempDiv.find("#comic").html();
      if(insertImmediately) insert();
    });
  }

  // returns comic as html-string
  function retrieve() {
    if(!preloaded) {
      insert();
      return '<div class="xkcd">Laden…</div>';
    }
    var html = '<div class="xkcd">' + comic + '</div>';
    reset();
    return html;
  }

  function reset() {
    comic = null;
    preloaded = false;
    insertImmediately = false;
  }

  // PUBLIC ////////////////////////////////////////////////////////////
  return {
    // preloads a random xkcd comic into storage. Doesn’t return
    // anything.
    preload: function() {
      return preload();
    },

    // returns the xkcd comic string suitable for DOM insertion.
    // If comic is not yet preloaded, it will return a stub and fill
    // it with the comic automatically.
    retrieve: function() {
      return retrieve();
    },

    // like retrieve(), but additionally has some surrounding text
    // explaining the comic-idea. Doesn’t include wrapper-element.
    retrieveWithText: function() {
      return '<br/><br/>Zur Belohnung ist hier ein zufälliges XKCD-Comic:<br/>'
        + retrieve()
        + '<br/>(eigentlich müsste hier ein Link auf XKCD stehen – zu Deinem Schutz fehlt er aber)';
    }
  };
})();
