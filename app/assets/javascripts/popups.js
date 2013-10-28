$(document).ready(function() {
  $('.ajax-popup-link').magnificPopup({
    type: 'ajax',
    overflowY: "auto",
    midClick: true,
    removalDelay: 300,
    mainClass: 'mfp-fade',
    closeOnBgClick: false,
    key: 'standard_popup'
  });

  $(document).on('click', '.mfp-content a[data-action="close-popup"]', function(ev) {
    ev.preventDefault();
    $.magnificPopup.close();
  });
});
