function getSingleQuestion(questionId, context, successCallback) {
  $.ajax({
    url: Routes.main_single_question_path({id: questionId}),
  }).done(function(data) {
    successCallback(context, data);
  }).fail(function() {
    alert("Die Anfrage konnte leider nicht bearbeitet werden. Möglicherweise hat der Server ein Problem.");
  });
}

A.Activate = function() {
  // no selection? GONNA SELECT 'EM ALL!
  if($('.inline-chooser .active').length !== 0) {
    this.cats = $('.inline-chooser .active').map(function(i, m) { return $(m).data("id"); }).get();
  }


};

// members
A.Activate.prototype = {
}

// convenience generator
A.activate = function() {
  var h = new H.Hitme();
  window.currentHitme = h;
  h.setupCategoryQuestionMode();
  return h;
}
