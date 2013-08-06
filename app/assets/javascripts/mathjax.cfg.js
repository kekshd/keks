$(document).ready(function() {
  MathJax.Hub.Config({
    showProcessingMessages: false,
    messageStyle: "none",

    showMathMenu: false,

    TeX: {
      Macros: {
        emph: '' // no idea how this works, but it makes \emph in math possible
      }
    },

    tex2jax: {
      inlineMath: [['$','$'], ['\\(','\\)']],
      skipTags: ["script","noscript","style","textarea","pre","code","td","img"],
      processClass: "tex",
    },

    "HTML-CSS": { scale: 90 }

  });

  MathJax.Hub.Configured();
});
