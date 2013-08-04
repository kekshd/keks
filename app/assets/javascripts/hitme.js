// returns a unique ID to be used to identify an element within the
// webpage. Depends on the current state of the page, i.e. if we already
// are in ask-skipped-questions-again mode.
function getUniqId(q, a) {
  var qid = (typeof q === 'object' ? q.id : q);
  if(qid === undefined || qid === null) throw('invalid question id');
  var id = "blockQuest" + qid;

  if(!window.currentHitme.nagAboutSkippedQuestions) id += 'repeat';

  if(a) {
    id += "_answer" + (typeof a === 'object' ? a.id : a);
  }
  return id;
}

function isAnswerSelectionCorrect(answers) {
  var correct = true;
  $.each(answers, function(ind, answ) {
    answ = $(answ);
    // answer correct, but not checked
    if(answ.data('correct') === true && !answ.hasClass("active")) correct = false;
    // answer wrong, but checked
    if(answ.data('correct') === false && answ.hasClass("active")) correct = false;
  });
  return correct;
}

function checkForQuestionPreview() {
  var singleQuestion = getHash("question");
  if(singleQuestion === undefined || !singleQuestion) return;

  var h = new H.Hitme();
  window.currentHitme = h;
  h.setupSingleQuestionMode();
}

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
  c = "";
  c += '<div class="star">';

  if(window.loggedIn) {
    c += question.starred ? '&#9733; ' : '';
    c += '<a onclick="handleStarredClick(this)" '
    c += 'data-id="'+question.id+'" ';
    c += 'data-starred="'+question.starred+'">Frage ';
    c += question.starred ? 'gemerkt' : 'merken';
    c += '</a>';
    c += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
  }

  var xx = Routes.perma_question_path(question.id);
  c += '⚓  <a href="'+xx+'" target="_blank">Link zur Frage</a>';

  c += '</div>';

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

function storeStats(quest_id, selected_answers, skipped, correct) {
  if(typeof selected_answers !== 'object') throw('selected_answers must be an array');
  if(skipped === undefined) throw('skipped not given');
  if(correct === undefined) throw('correct not given');
  $.post(Routes.new_stat_path(quest_id), {
    selected_answers: selected_answers,
    skipped: skipped,
    correct: correct
  });
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
  disableLinks(s);
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
  enableLinks(s);
}

function animateVisibilityHiddenShow(elms) {
  elms.css('visibility','visible').hide().fadeIn('slow');
}

function disableLinks(selector) {
  $(selector).each(function(ind, s) {
    s = $(s);
    s.addClass('disable')
      .data('oldonclick', s.attr('onclick'))
      .attr('onclick', '');
  });
}

function enableLinks(selector) {
  $(selector).each(function(ind, s) {
    s = $(s);
    s.removeClass('disable').attr('onclick', s.data('oldonclick'));
  });
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

function getSingleQuestion(questionId, context, successCallback) {
  $.ajax({
    url: Routes.main_single_question_path({id: questionId}),
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

// sees if there’s a subquestion for the current answer. If there is,
// and the user has activated subquestions it will be inserted next.
// Returns true if a subquestion has been inserted.
function maybeInsertSubquestion(aid) {
  if(!$('#subquestions').is(':checked')) {
    // user doesn’t want subquestions, skip
    return false;
  }

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
  if(!s) return false;
  var c = window.currentHitme;
  var p = c.questPositionPointer;
  c.questions.splice(p+1, 0, s);
  return true;
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
  // no selection? GONNA SELECT 'EM ALL!
  if($('.inline-chooser .active').length === 0)
    $('.inline-chooser .toggleable').addClass('active');

  this.cats = $('.inline-chooser .active').map(function(i, m) { return $(m).data("id"); }).get();

  this._this = this;
  disableOptions();
  ensureValidDifficultySelection();
  hideCategories();
};

// members
H.Hitme.prototype = {
  setupCategoryQuestionMode: function() {
    getRootQuestions(this.cats, this, this.rootQuestionsAvailable);
    this.questPositionPointer = -1;
    this.nagAboutSkippedQuestions = true;
    this.skippedQuestionsData = [];
    this.answersGiven = {correct: [], fail: [], skip: []};
  },

  setupSingleQuestionMode: function() {
    $("#quantity").val(1);
    getSingleQuestion(getHash("question"), this, this.rootQuestionsAvailable);

    this.questPositionPointer = -1;
    this.nagAboutSkippedQuestions = false;
    this.skippedQuestionsData = [];
    this.answersGiven = {correct: [], fail: [], skip: []};
  },


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
    $.each(shuffle(quest.answers), function(ind, a) {
      s += '<div>'
      s += '<a class="button toggleable" id="'+getUniqId(quest, a)+'"';
      s += ' onclick="$(this).toggleClass(\'active\');"';
      s += ' data-correct="'+a.correct+'" data-qid="'+quest.id+'"';
      s += ' data-aid="'+a.id+'">'+a.html+'</a>';
      s += '<span>'+a.correctness+'</span>';
      s += '<span>(das hattest Du angekreuzt)</span>';
      s += '</div>';
    });
    return s;
  },

  _handleQuestionSubmit: function() {
    // gather details
    //~ var question = getQuestionById($(this).data('qid'));
    var quest = window.currentQuestion;
    var answerChooser = $(this).parent().siblings(".answer-chooser, .answer-chooser-matrix").first();
    var action = $(this).data('action');
    var boxSelector = '#' + getUniqId(window.currentQuestion);

    // disable ui
    $(this).parent().children("a").addClass("disable");
    answerChooser.find("a").addClass("disable").removeAttr("onclick");
    answerChooser.find("textarea").attr('disabled', 'disabled');

    // handle action
    if(action === 'skip') {
      window.currentHitme.skippedQuestionsData.push(quest);
      window.currentHitme.answersGiven.skip.push(boxSelector);
      $(this).parent().append("<span>Du hast diese Frage übersprungen</span>");
      storeStats(quest.id, [], true, false);

    } else if(action === 'save') {
      $(boxSelector).addClass('reveal');
      var correct;

      if(quest.matrix) {
        var m = parseMatrix(answerChooser.find("textarea").val());
        correct = window.currentQuestion.matrix_solution === m;
        storeStats(quest.id, [m], false, correct);
      } else {
        var answ = answerChooser.find("a");
        correct = isAnswerSelectionCorrect(answ);


        // insert subquestions for selected answers if any
        var selAnsw = answerChooser.find("a.active");
        $.each(selAnsw, function(ind, answ) {
          maybeInsertSubquestion($(answ).data('aid'));
        });

        // show which questions were selected by the user
        $.each(selAnsw, function(ind, answ) {
          animateVisibilityHiddenShow($(answ).siblings().last());
        });

        var selAnswIds = $.map(selAnsw, function(answ, ind) {
          return $(answ).data('aid');
        });

        storeStats(quest.id, selAnswIds, false, correct);
      }


      if(correct) {
        //~ console.log("q" + quest.id + " answered correctly");
        window.currentHitme.answersGiven.correct.push(boxSelector);
      } else {
        //~ console.log("q" + quest.id + " answered incorrectly");
        window.currentHitme.answersGiven.fail.push(boxSelector);
      }


    } else {
      throw('Unsupported action. This is a coding error.');
    }

    window.currentHitme.showNext();
  },

  _showNextQuestion: function() {
    this.questPositionPointer++;
    var q = window.currentQuestion = this.questions[this.questPositionPointer];
    var code = '<div style="display:none" id="'+getUniqId(q.id)+'" class="hideMeOnMore">'
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

    code += '<div class="answer-chooser'+(q.matrix?"-matrix":"")+'">'
    if(q.matrix) {
      var a = q.answers[0];
      code += 'Trage unten die Lösung ein. Matrizen schreibst Du einfach mittels Leerzeichen und Zeilenumbrüchen. Die Anzahl der Leerzeichen ist dabei egal.<br/><br/>';
      code += '<div style="float:left;width: 45%; overflow-y: show; overflow-x: hidden;">';
      code += '<label for="'+getUniqId(q, a)+'">Deine Lösung</label><br class="clear"/>';
      code += '<textarea id="'+getUniqId(q, a)+'" class="matrixmode"></textarea>';
      code += '<div class="tex previewer" id="'+getUniqId(q, a)+'previewer"></div>';
      code += '<br/>';
      code += '</div>';
      code += '<div style="float:right;width: 45%" class="initiallyHidden">';
      code += '<strong>Unsere Lösung</strong><br class="clear"/>';
      code += a.html+'</div>';
      code += '<br class="clear"/>';
    } else {
      code += this._renderAnswersForQuestion(q);
    }
    code += '</div>'; // answer-chooser

    code += '<br/><div class="answer-submit button-group">';
    code += '<a class="button big" data-qid="'+q.id+'" title="Günther Jauch: Sind Sie sich wirklich sicher?" data-action="save">Antwort übernehmen</a>';
    code += '<a class="button big" data-qid="'+q.id+'" data-action="skip">Frage überspringen</a>';
    code += '</div>';


    code += '</div>'; // box

    $(code).appendTo('body');
    $('.answer-submit:last').one('click', 'a', this._handleQuestionSubmit);
    // render math first, then expand
    var render = function() { $("#"+getUniqId(q.id)).animate(CONST.showAnimation, CONST.stayAtBottom); }
    MathJax.Hub.Queue(["Typeset",MathJax.Hub, render]);

    // add preview for matrix questions
    if(q.matrix) {
      window.matrixModePreview = null;
      var textarea = $('#'+getUniqId(q, a));
      var previewer = $('#'+getUniqId(q, a)+'previewer');
      textarea.keyup(function() {
        if(window.matrixModePreview) clearTimeout(window.matrixModePreview);
        window.matrixModePreview = setTimeout(function() {
          var v = parseMatrix(textarea.val());
          if(v === "") return previewer.html("");
          v = shortMatrixStrToTeX(v);
          previewer.html(v);
          MathJax.Hub.Queue(["Typeset",MathJax.Hub]);
        }, 100);
      });
    }
  },

  _reshowSkippedQuestions: function() {
    var w = window.currentHitme;
    w.answersGiven.skip = [];
    w.questions = $.extend(true, [], w.skippedQuestionsData); // deep copy
    w.questPositionPointer = -1;
    w.showNext();
  },

  _showSkippedQuestionsNagDialog: function() {
    // show only once
    if(!this.nagAboutSkippedQuestions) return false;
    this.nagAboutSkippedQuestions = false;

    if(this.answersGiven.skip.length === 0) return false;

    var code = '<div style="display:none;" class="hideMeOnMore reshowskipped">'
      + '<h3>Übersprungene Fragen</h3>'
      + '<p>Du hast ' + this.answersGiven.skip.length + ' Frage(n) übersprungen. Sollen sie nochmal angezeigt werden, oder möchtest Du abschließen?</p>'
      + '<div class="button-group">'
      + '<a onclick="window.currentHitme._showFinishDialog(); disableLinks(\'.reshowskipped a\');" class="button big">Block abschließen</a>'
      + '<a onclick="window.currentHitme._reshowSkippedQuestions(); disableLinks(\'.reshowskipped a\');" class="button big">nochmal vorlegen</a>'
      + '</div>';

    $(code).appendTo('body').animate(CONST.showAnimation, CONST.stayAtBottom);
    return true;
  },

  _showFinishDialog: function() {
    if(this._showSkippedQuestionsNagDialog()) return;

    var sum = this.answersGiven.correct.length + this.answersGiven.fail.length;

    var code = '<div style="display:none;" class="hideMeOnMore">'
      + '<h3>Fertig!</h3>'
      + '<p>Du hast den aktuellen Block abgeschlossen. Insgesamt hast Du '+sum+' Fragen beantwortet und davon '+this.answersGiven.fail.length+' falsch. Scrolle nach oben um jeweils die Antworten für die Fragen zu sehen.</p>'
      + '<div class="button-group">'
      + '<a onclick="window.currentHitme.giveMore();" class="button big">Gib mir nochmal '+$('#quantity').val()+'!</a>'
      + '<a href="'+Routes.main_hitme_path()+'" class="button big">Einstellungen ändern</a>'
      + '</div>';

    if($('#comiccheckbox').is(':checked')) {
      code = code
        + '<br/><br/>Zur Belohnung ist hier ein zufälliges XKCD-Comic:<br/>'
        + '<div class="xkcd"></div>'
        + '<br/>(eigentlich müsste hier ein Link auf XKCD stehen – zu Deinem Schutz fehlt er aber)'
        + '</div>';
    }

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
H.hitme = function() {
  var h = new H.Hitme();
  window.currentHitme = h;
  h.setupCategoryQuestionMode();
  return h;
}
