$(document).ready(function() {
  $('.toggle').each(function(ind, elm) {
    elm = $(elm);
    var head = $(elm).prev();
    if(['H2', 'H3', 'H4', 'H5'].indexOf(head.prop("tagName")) === -1) {
      console.error("found toggle element, but previous element is not a heading. Details have been written to the debug log.");
      console.debug(elm);
      console.debug(head);
      console.debug(head.prop("tagName"));
      return;
    }

    head.addClass("toggle-head toggle-" + (elm.is(":visible") ? "opened" : "closed"));
    head.attr("title", "Klicken, um die Kategorie ein- bzw. auszublenden.");

    head.click(function() {
      elm.toggle('slide fade');
      head.toggleClass('toggle-opened toggle-closed');
    });
  });
});
