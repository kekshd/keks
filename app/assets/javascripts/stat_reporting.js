function StatReporting() {
  var start_time = null;
  var end_time = null;
  var question_id = null;
  var selected_answers = null;
  var skipped = null;
  var correct = null;

  // 0 = not submitted, 1 = running, 2 = success, 3 = failed
  var state = 0;

  function time_taken() {
    if(start_time === null) return -1;
    if(end_time === null) end_time = Date.now();
    return Math.round( (end_time - start_time) / 1000 );
  }

  function report(is_retry) {
    if(state === 1) return; // currently running
    if(state === 2) return; // successfully submitted, no need to report

    is_retry = typeof is_retry !== 'undefined' ? is_retry : false;

    state = 1;

    $.post(Routes.new_stat_path(question_id), {
      selected_answers: selected_answers,
      skipped: skipped,
      correct: correct,
      time_taken: time_taken()
    }, function() {
      state = 2;
    }).fail(function() {
      state = 3;
      if(!is_retry) report(true);
    });
  }

  function finish(corr, skip) {
    if(state > 0) throw_with_alert('Already finished.');
    correct = corr;
    skipped = skip;
    if(selected_answers === null) throw_with_alert('Answers have not been set');
    report();
  }

  // PUBLIC ////////////////////////////////////////////////////////////
  return {
    // starts recording time taken for the given question ID. May only
    // be called once. Returns self.
    record: function(qid) {
      if(typeof qid === 'undefined' || isNaN(qid)) {
        throw_with_alert('question_id must be present and a number');
      }

      if(state > 0) {
        throw_with_alert('Already recording. Create a new stat instead.');
      }

      start_time = Date.now();
      question_id = qid;

      return this;
    },

    set_answers: function(answers) {
      if(typeof answers !== 'object') throw_with_alert('selected_answers must be an array');
      selected_answers = answers;
      return this;
    },

    skipped: function() {
      this.set_answers([]);
      finish(false, true);
      return this;
    },

    success: function() {
      finish(true, false);
      return this;
    },

    failed: function() {
      finish(false, false);
      return this;
    },

    status: function() {
      if(start_time === null) return "not yet started";
      switch(state) {
        case 0: return "recording time";
        case 1: return "currently submitting";
        case 2: return "successfully reported stat";
        case 3: return "reporting failed";
      }
      throw_with_alert("invalid state: "+state + "   time:"+start_time);
    }
  };
}
