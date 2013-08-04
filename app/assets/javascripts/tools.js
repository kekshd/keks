function hasHash(hash) {
  hash = hash.replace(/^#/, "");
  return window.location.hash.indexOf("#" + hash) >= 0;
}

function getHash(hash) {
  if(!hasHash(hash)) return null;
  var m = window.location.hash.match(new RegExp("#"+hash+"=([^#]+)"));
  return m[1];
}
