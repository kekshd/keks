function validateNumberOnly(self) {
  self = $(self);
  self.val(self.val().replace(/[^0-9]/g, "") || 10);
}

function parseMatrix(orig) {
  var s = $.trim(orig);
  var rows = s.split(/[\r\n]+/);
  rows = $.map(rows, function(r) {
    return $.trim(r).split(/\s+/).join(" ");
  });
  return rows.join("  ");
}

function showNextHint(elm) {
  var hidden = $(elm).siblings(":hidden");
  hidden.first().animate(H.Constants.showAnimation);
  if(hidden.length === 1) $(elm).animate(H.Constants.hideAnimation);
}


H = {};
window.H = H;

window.currentHitme = null;

Array.prototype.diff = function(a) {
    return this.filter(function(i) {return !(a.indexOf(i) > -1);});
};


H.Constants = {
  hideAnimation: {opacity: 'hide', height: 'hide', marginTop: 'hide',
    marginBottom: 'hide', paddingTop: 'hide', paddingBottom: 'hide'},
  showAnimation: {opacity: 'show', height: 'show', marginTop: 'show',
    marginBottom: 'show', paddingTop: 'show', paddingBottom: 'show'},
  stayAtBottom: { duration: 'slow',
    step: function(now, fx) {
      $('html, body').scrollTop(99999999);
    }
  }
}

H.Util = {
  // example: http://localhost:3000/category/5/questions?count=10&difficulty=10_20_30&study_path=3
  getURLForRootQuestions: function(self) {
    var catId = self.data('id');
    var diff = this.getDifficulties();
    var count = $('#quantity').val();
    var studyPath = $('#study_path').val();

    var h = {count: count, difficulty: diff, study_path: studyPath}

    return Routes.category_question_path(catId, h);
  },

  getRootQuestions: function(self, context, successCallback) {
    $.ajax({
      url: this.getURLForRootQuestions(self),
    }).done(function(data) {
      successCallback(context, data);
    }).fail(function() {
      alert("Die Anfrage konnte leider nicht bearbeitet werden. Möglicherweise hat der Server ein Problem.");
    });
  },

  getDifficulties: function() {
    var diff = [];
    $('input[type=checkbox][name^=difficulty]').each(function() {
      if(this.checked) {
        diff.push($(this).val());
      }
    });
    return diff.join("_");
  },

  getStudyPath: function() {
    var diff = [];
    $('input[type=checkbox][name^=difficulty]').each(function() {
      if(this.checked) {
        diff.push($(this).val());
      }
    });
    return diff.join("_");
  },

  ensureValidDifficultySelection: function() {
    var any = false;
    $('input[type=checkbox][name^=difficulty]').each(function() {
      if($(this).is('checked')) {
        any = true;
        return false;
      }
    });
    if(!any) $('input[type=checkbox][name^=difficulty]:first').prop('checked', true);
  },

  disableOptions: function() {
    $('#options input').attr("disabled", "disabled");
    $('#options').animate(H.Constants.hideAnimation);
  },

  enableOptions: function() {
    $('#options input').removeAttr("disabled");
  },

  hideOtherCategories: function(self) {
    self.parents('li').siblings().animate(H.Constants.hideAnimation);
    self.data('oldonclick', self.attr('onclick'));
    self.attr('onclick', '').addClass('disable');
  },

  showAllCategories: function() {
    $('#categories li').animate(H.Constants.showAnimation);
    var s = $('a.disable');
    s.removeClass('disable').attr('onclick', s.data('oldonclick'));
  },

  animateVisibilityHiddenShow: function(elms) {
    elms.css('visibility','visible').hide().fadeIn('slow');
  }
}



// constructor
H.Hitme = function(categoryElement) {
  this._this = this;
  this.cat = $(categoryElement);
  H.Util.disableOptions();
  H.Util.ensureValidDifficultySelection();
  H.Util.hideOtherCategories(this.cat);
  H.Util.getRootQuestions(this.cat, this, this.rootQuestionsAvailable);
  this.currentRootQuestionId = -1;
  this.answersGiven = {correct: [], fail: [], skip: []};
};

// members
H.Hitme.prototype = {
  giveMore: function() {
    $('.hideMeOnMore').remove();
    H.hitme(this.cat);
  },

  rootQuestionsAvailable: function(_this, data) {
    _this.questions = data;
    _this.showNext();
  },

  _renderAnswersForQuestion: function(quest) {
    var s = "";
    $.each(quest.answers, function(ind, a) {
      s += '<div>'
      s += '<a class="button" id="a'+a.id+'" data-correct="'+a.correct+'">'+a.html+'</a>';
      s += '<span>'+a.correctness+'</span>';
      s += '<span>Deine Antwort</span>';
      s += '</div>';
    });
    return s;
  },

  _handleAnswerClick: function() {
    var answ = $(this);
    var linkBox = answ.parents('.answer-chooser, .answer-chooser-matrix').first();
    var box = answ.parents('div[id^="block"]');
    var boxSelector = '#' + box.attr('id');

    var isMatrix = linkBox.hasClass('answer-chooser-matrix');
    if(isMatrix && answ.is(':first-child')) {
      var txt = box.find("textarea");
      var m = parseMatrix(txt.val());
      txt.attr('disabled', 'disabled');
      answ.data('correct', window.currentRootQuestion.matrix_solution === m);
    }

    var c = answ.data('correct');
    switch(c) {
      case "true":
      case true:
      window.currentHitme.answersGiven.correct.push(boxSelector);
      box.addClass('reveal');
      break;

      case "false":
      case false:
      window.currentHitme.answersGiven.fail.push(boxSelector);
      box.addClass('reveal');
      break;

      default:
      window.currentHitme.answersGiven.skip.push(boxSelector);
    }

    linkBox.find('a').addClass('disable');
    H.Util.animateVisibilityHiddenShow(answ.siblings().last());
    window.currentHitme.showNext();
  },

  _showNextRootQuestion: function() {
    this.currentRootQuestionId++;
    var q = window.currentRootQuestion = this.questions[this.currentRootQuestionId];

    var code = '<div style="display:none" id="blockQ'+q.id+'" class="hideMeOnMore">'
      + q.html
      + '<br/>';

    if(q.hints.length >= 1) {
      code += '<div>'
      $.each(q.hints, function(ind, hint) {
        code += '<div style="display: none;margin: 5px 0">'+hint+'</div>';
      });
      code += '<a onclick="showNextHint(this);">Hinweis anzeigen</a>';
      code += '</div>';
    }


    var cls;

    if(q.matrix) {
      cls = 'answer-chooser-matrix';

      code += 'Trage unten die Lösung ein. Matrizen schreibst Du einfach mittels Leerzeichen und Zeilenumbrüchen. Die Anzahl der Leerzeichen ist dabei egal.<br/><br/>'
      var a = q.answers[0];
      code += '<div style="float:left;width: 45%">';
      code += '<label for="a'+a.id+'" style="float:none">Deine Lösung</label>';
      code += '<textarea id="a'+a.id+'" class="matrixmode"></textarea><br/>';
      code += '</div>';
      code += '<div style="float:right;width: 45%" class="initiallyHidden">';
      code += '<strong>Unsere Lösung</strong><br/>';
      code += a.html+'</div>';
      code += '<br class="clear"/>';
      code += '<div class="answer-chooser-matrix button-group">';
      code += '<a class="button">Antwort übernehmen</a>';
      code += '<a class="button">Frage überspringen</a>';
      code += '</div>';
    } else {
      cls = 'answer-chooser';
      code += '<div class="answer-chooser">'
        + this._renderAnswersForQuestion(q)
        +'<div><a class="button">Frage überspringen</a><span></span><span>Du hast diese Frage übersprungen</span></div>'
        + '</div>';
    }

    code += '</div>';

    $(code).appendTo('body').animate(H.Constants.showAnimation, H.Constants.stayAtBottom);
    $('.'+cls+':last').one('click', 'a', this._handleAnswerClick);
  },

  _showFinishDialog: function() {
    var sum = this.answersGiven.correct.length + this.answersGiven.fail.length;

    var code = '<div style="display:none;" class="hideMeOnMore">'
      + '<h3>Fertig!</h3>'
      + '<p>Du hast den aktuellen Block abgeschlossen. Insgesamt hast Du '+sum+' Fragen beantwortet und davon '+this.answersGiven.fail.length+' falsch. Scrolle nach oben um jeweils die Antworten für die Fragen zu sehen.</p>'
      + '<div class="button-group">'
      + '<a onclick="window.currentHitme.giveMore();" class="button big">Gib mir nochmal '+$('#quantity').val()+'!</a>'
      + '<a href="'+Routes.main_hitme_path()+'" class="button big">Einstellungen ändern</a>'
      + '</div>';
      + '</div>';

    $(code).appendTo('body').animate(H.Constants.showAnimation, H.Constants.stayAtBottom);

    H.Util.animateVisibilityHiddenShow($('.reveal > div > span:nth-child(2), .reveal .initiallyHidden'));

    var allCorr = this.answersGiven.correct.diff(this.answersGiven.fail).join(',');
    var anyFail = this.answersGiven.fail.join(',');
    $(allCorr).addClass('correct');
    $(anyFail).addClass('wrong');
  },

  showNext: function() {
    if(this.questions.length === 0) {
      alert("Keine Fragen für die aktuellen Einstellungen gefunden.\n\nVersuche es mit anderen Einstellungen nochmal.");
      H.Util.enableOptions();
      H.Util.showAllCategories();
    } else if(this.questions.length-1 === this.currentRootQuestionId)  {
      this._showFinishDialog();
    } else {
      this._showNextRootQuestion();
    }
  },

  skipCurrentQuestion: function(self) {
    $(self).animate(H.Constants.hideAnimation);
    this.showNext();
  }
}


// convenience generator
H.hitme = function (categoryElement) {
  var h = new H.Hitme(categoryElement);
  window.currentHitme = h;
  return h;
}
