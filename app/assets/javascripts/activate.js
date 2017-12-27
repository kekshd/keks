A = {};
window.A = A;

window.currentHitme = null;

function activateCategoriesURL(categoryIds) {
  var h = {categories: categoryIds.join("_")}

  return Routes.categories_activate_path(h);
}

function deactivateCategoriesURL(categoryIds) {
  var h = {categories: categoryIds.join("_")}

  return Routes.categories_deactivate_path(h);
}



function activateCategories(categoryIds, context, successCallback) {
  $.ajax({
    url: activateCategoriesURL(categoryIds),
  }).done(function(data) {
    successCallback(context, data);
  }).fail(function() {
    alert("Die Anfrage konnte leider nicht bearbeitet werden. Möglicherweise hat der Server ein Problem.");
  });
}

function deactivateCategories(categoryIds, context, successCallback) {
  $.ajax({
    url: deactivateCategoriesURL(categoryIds),
  }).done(function(data) {
    successCallback(context, data);
  }).fail(function() {
    alert("Die Anfrage konnte leider nicht bearbeitet werden. Möglicherweise hat der Server ein Problem.");
  });
}

A.Activate = function() {
  if($('.inline-chooser .active').length !== 0) {
    this.cats = $('.inline-chooser .active').map(function(i, m) { return $(m).data("id"); }).get();
  } else {
    this.cats = nil;
  }
};

// members
A.Activate.prototype = {
  activateCategoryMode: function() {
    activateCategories(this.cats, this, this.end)
  },

  deactivateCategoryMode: function() {
    deactivateCategories(this.cats, this, this.end)
  },

  end: function(_this, data) {
  }
}

// convenience generator
A.activate = function() {
  var a = new A.Activate();
  window.currentHitme = a;
  a.activateCategoryMode();
  return a;
}

A.deactivate = function() {
  var a = new A.Activate();
  window.currentHitme = a;
  a.deactivateCategoryMode();
  return a;
}
