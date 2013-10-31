describe("StatReporting", function() {
  var s;
  beforeEach(function() {
    s = new StatReporting();
  });

  function lastAjax() {
    return $.ajax.mostRecentCall.args[0];
  }


  it("can be in pre-recording state", function() {
    expect(s.status()).toMatch("not yet");
  });

  it("can be put into recording mode", function() {
    expect(s.record(1).status()).toMatch('recording');
  });

  it("doesn’t affect other stat reportings", function() {
    s.record(1);
    var other = new StatReporting();
    expect(s.status()).toMatch('recording');
    expect(other.status()).toMatch('not yet');
  });

  it("reports skipped correctly", function() {
    mock_ajax_success('true');
    s.record(123);
    s.skipped();
    expect(lastAjax()["url"]).toMatch("/stats/123");
    expect(lastAjax()["data"]["skipped"]).toEqual(true);
    expect(lastAjax()["data"]["correct"]).toEqual(false);
    expect(lastAjax()["data"]["selected_answers"]).toEqual([]);
  });

  it("reports success correctly", function() {
    mock_ajax_success('true');
    s.record(123).set_answers([1]).success();
    expect(lastAjax()["url"]).toMatch("/stats/123");
    expect(lastAjax()["data"]["skipped"]).toEqual(false);
    expect(lastAjax()["data"]["correct"]).toEqual(true);
    expect(lastAjax()["data"]["selected_answers"]).toEqual([1]);
  });

  it("reports failure correctly", function() {
    mock_ajax_success('true');
    s.record(123).set_answers([1]).failed();
    expect(lastAjax()["url"]).toMatch("/stats/123");
    expect(lastAjax()["data"]["skipped"]).toEqual(false);
    expect(lastAjax()["data"]["correct"]).toEqual(false);
    expect(lastAjax()["data"]["selected_answers"]).toEqual([1]);
  });

  it("complains about missing answers", function() {
    mock_ajax_success('true');
    s.record(123);
    expect(function() { s.success() }).toThrow();
  });

  it("can only be submitted once", function() {
    mock_ajax_success('true');
    s.record(123).skipped();
    expect(function() { s.success() }).toThrow();
  });
});
