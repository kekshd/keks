function validateNumberOnly(self) {
  self = $(self);
  var val = parseInt(self.val().replace(/[^0-9]/g, "") || 10);
  var max = parseInt(self.attr('max') || 999999);
  var min = parseInt(self.attr('min') ||-999999);
  self.val(Math.max(min, Math.min(max, val)));
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
  hidden.first().animate(CONST.showAnimation);
  if(hidden.length === 1) $(elm).animate(CONST.hideAnimation);
}

function renderStarred(question) {
  if(!window.loggedIn) return '';
  c = "";
  c += '<div class="star">';

  c += question.starred ? '&#9733; ' : '';
  c += '<a onclick="handleStarredClick(this)" '
  c += 'data-id="'+question.id+'" ';
  c += 'data-starred="'+question.starred+'">Frage ';
  c += question.starred ? 'gemerkt' : 'merken';
  c += '</a></div>';

  return c;
}

function handleStarredClick(link) {
  var l = $(link);
  var s = l.data('starred');
  var id = l.data('id');
  var r = s ? Routes.unstar_question_path(id) : Routes.star_question_path(id);

  $.ajax({
    url: r,
  }).done(function(data) {
    var fakeQ = {id: id, starred: data};
    l.parent().replaceWith(renderStarred(fakeQ));
  }).fail(function() {
    l.text('irgendwas ist kaputt…').addClass('disable');
  });
}

function getQuestionById(id) {
  var quest = null;
  $.each(window.currentHitme.questions, function(ind, q) {
    if(q.id === id) {
      quest = q;
      return false;
    }
  });
  return quest;
}

function storeStats(quest_id, answ_id) {
  $.post(Routes.new_stat_path(quest_id, answ_id), {a: "b"});
}


function ensureValidDifficultySelection() {
  var any = false;
  $('input[type=checkbox][name^=difficulty]').each(function() {
    if($(this).is('checked')) {
      any = true;
      return false;
    }
  });
  if(!any) $('input[type=checkbox][name^=difficulty]:first').prop('checked', true);
}


function disableOptions()  {
  $('#options input').attr("disabled", "disabled");
  $('#options').animate(CONST.hideAnimation);
}

function enableOptions() {
  $('#options input').removeAttr("disabled");
}


function hideCategories() {
  $('h3 + .toggle:visible').each(function(i, cat) {
    $(cat).prev().click();
  });
  var s = $('#categories a.button, #start-button');
  s.addClass('disable').attr('oldonclick', s.data('onclick'));
}

function getDifficulties() {
  var diff = [];
  $('input[type=checkbox][name^=difficulty]').each(function() {
    if(this.checked) {
      diff.push($(this).val());
    }
  });
  return diff.join("_");
}

function showAllCategories() {
  $('#categories .toggle').animate(CONST.showAnimation);
  var s = $('a.disable, #start-button');
  s.removeClass('disable').attr('onclick', s.data('oldonclick'));
}

function animateVisibilityHiddenShow(elms) {
  elms.css('visibility','visible').hide().fadeIn('slow');
}

function getURLForRootQuestions(categoryIds) {
  var diff = this.getDifficulties();
  var count = $('#quantity').val();
  var studyPath = $('#study_path').val();

  var h = {categories: categoryIds.join("_"), count: count, difficulty: diff, study_path: studyPath}

  return Routes.main_question_path(h);
}

function getRootQuestions(categoryIds, context, successCallback) {
  // example: http://0.0.0.0:3000/main/questions?categories=6_8&count=10&difficulty=10_20_30&study_path=3
  $.ajax({
    url: getURLForRootQuestions(categoryIds),
  }).done(function(data) {
    successCallback(context, data);
  }).fail(function() {
    alert("Die Anfrage konnte leider nicht bearbeitet werden. Möglicherweise hat der Server ein Problem.");
  });
}

function answersGivenCount() {
  var a = window.H.answersGiven;
  return a.fail.length + a.correct.length + a.skip.length;
}

function maybeInsertSubquestion(aid) {
  // only try to show subquestion half of the time
  //~ if(Math.random() < 0.5) return; // fix as per #5
  var q = window.currentQuestion;
  var s;
  $.each(q.answers, function(ind, answ) {
    if(answ.id === parseInt(aid)) {
      s = answ.subquestion;
      return false;
    }
  });
  // this answer doesn’t have a subquestion
  if(!s) return;
  var c = window.currentHitme;
  var p = c.questPositionPointer;
  c.questions.splice(p+1, 0, s);
}

H = {};
window.H = H;

window.currentHitme = null;

Array.prototype.diff = function(a) {
    return this.filter(function(i) {return !(a.indexOf(i) > -1);});
};


window.CONST = {
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


// constructor
H.Hitme = function() {
  this.cats = $('.inline-chooser .active').map(function(i, m) { return $(m).data("id"); }).get();
  if(this.cats.length === 0) {
    alert("Wähle bitte eine Kategorie aus.");
    return;
  }

  this._this = this;
  disableOptions();
  ensureValidDifficultySelection();
  hideCategories();
  getRootQuestions(this.cats, this, this.rootQuestionsAvailable);
  this.questPositionPointer = -1;
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
      s += '<a class="button" id="a'+a.id+'"';
      s += ' data-correct="'+a.correct+'" data-qid="'+quest.id+'"';
      s += ' data-aid="'+a.id+'">'+a.html+'</a>';
      s += '<span>'+a.correctness+'</span>';
      s += '<span>Deine Antwort</span>';
      s += '</div>';
    });
    return s;
  },

  _handleAnswerClick: function() {
    var answ = $(this);
    var linkBox = answ.parents('.answer-chooser, .answer-chooser-matrix').first();
    var boxSelector = '#blockQ' + answ.data('qid');
    var box = $(boxSelector);

    var isMatrix = getQuestionById(answ.data('qid')).matrix;
    if(isMatrix && answ.data('aid') === 1) {
      var txt = box.find("textarea");
      var m = parseMatrix(txt.val());
      txt.attr('disabled', 'disabled');
      var isCorr = window.currentQuestion.matrix_solution === m;
      answ.data('correct', isCorr);
      if(!isCorr) answ.data('aid', 0);
    }

    storeStats(answ.data('qid'), answ.data('aid'));

    var c = answ.data('correct');
    switch(c) {
      case "true":
      case true:
      window.currentHitme.answersGiven.correct.push(boxSelector);
      box.addClass('reveal');
      maybeInsertSubquestion(answ.data('aid'));
      break;

      case "false":
      case false:
      window.currentHitme.answersGiven.fail.push(boxSelector);
      box.addClass('reveal');
      maybeInsertSubquestion(answ.data('aid'));
      break;

      default:
      window.currentHitme.answersGiven.skip.push(boxSelector);
    }

    linkBox.find('a').addClass('disable');
    animateVisibilityHiddenShow(answ.siblings().last());
    window.currentHitme.showNext();
  },

  _showNextQuestion: function() {
    this.questPositionPointer++;
    var q = window.currentQuestion = this.questions[this.questPositionPointer];

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

    code += renderStarred(q);


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
      code += '<a class="button" data-qid="'+q.id+'" data-aid="1">Antwort übernehmen</a>';
      code += '<a class="button" data-qid="'+q.id+'" data-aid="-1">Frage überspringen</a>';
      code += '</div>';
    } else {
      cls = 'answer-chooser';
      code += '<div class="answer-chooser">'
        + this._renderAnswersForQuestion(q)
        +'<div><a class="button" data-qid="'+q.id+'" data-aid="-1">Frage überspringen</a><span></span><span>Du hast diese Frage übersprungen</span></div>'
        + '</div>';
    }

    code += '</div>';

    $(code).appendTo('body').animate(CONST.showAnimation, CONST.stayAtBottom);
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
      + '</div>'
      + '<br/><br/>Zur Belohnung ist hier ein zufälliges XKCD-Comic:<br/>'
      + '<div class="xkcd"></div>'
      + '<br/>(eigentlich müsste hier ein Link auf XKCD stehen – zu Deinem Schutz fehlt er aber)'
      + '</div>';

    $(code).appendTo('body').animate(CONST.showAnimation, CONST.stayAtBottom);

    animateVisibilityHiddenShow($('.reveal .answer-chooser > div > span:nth-child(2), .reveal .initiallyHidden'));

    var allCorr = this.answersGiven.correct.diff(this.answersGiven.fail).join(',');
    var anyFail = this.answersGiven.fail.join(',');
    $(allCorr).addClass('correct');
    $(anyFail).addClass('wrong');

    $('.xkcd:last').load(Routes.random_xkcd_path() + ' #comic');
  },

  showNext: function() {
    if(this.questions.length === 0) {
      alert("Keine Fragen für die aktuellen Einstellungen gefunden.\n\nVersuche es mit anderen Einstellungen nochmal.");
      enableOptions();
      showAllCategories();
    // no more available questions?
    } else if(this.questions.length-1 === this.questPositionPointer) {
      this._showFinishDialog();
    // reached user defined question limit
    } else if(answersGivenCount >= parseInt($('#quantity').val())) {
      this._showFinishDialog();
    } else {
      this._showNextQuestion();
    }
  },

  skipCurrentQuestion: function(self) {
    $(self).animate(CONST.hideAnimation);
    this.showNext();
  }
}


// convenience generator
H.hitme = function (categoryElement) {
  var h = new H.Hitme(categoryElement);
  window.currentHitme = h;
  return h;
}
