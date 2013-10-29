
describe("XkcdLoader", function() {
  it("gives a stub if comic not yet loaded", function() {
    expect(XkcdLoader.retrieve()).toMatch("Laden");
  });
});
