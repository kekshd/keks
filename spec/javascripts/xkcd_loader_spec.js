
describe("XkcdLoader", function() {
  it("gives a stub if comic not yet loaded", function() {
    expect(XkcdLoader.retrieve()).toMatch("Laden");
  });

  it("includes class xkcd", function() {
    expect(XkcdLoader.retrieve()).toMatch('class="xkcd"');
  });

  it("preloads the comic", function() {
    runs(function() {
      mine = XkcdLoader;
      mine.preload();
    });

    waits(5000);

    runs(function () {
      expect(mine.retrieve()).toMatch("xkcd.com");
    });
  });

  it("inserts the comic automatically after a while", function() {
    runs(function() {
      mine = XkcdLoader;
      $(mine.retrieve()).appendTo('body');
    });

    waits(5000);

    runs(function () {
      expect($('.xkcd').html()).toMatch("xkcd.com");
    });
  });
});
