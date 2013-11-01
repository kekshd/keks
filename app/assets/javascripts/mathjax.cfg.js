function configureMathJax() {
  if(typeof MathJax === 'undefined') {
    return setTimeout('configureMathJax()', 50);
  }

  MathJax.Hub.Config({
    showProcessingMessages: false,
    messageStyle: "none",

    showMathMenu: false,

    TeX: {
      Macros: {
        emph: ['\\style{font-style:italic}{\\text{#1}}', 1]
      }
    },

    tex2jax: {
      inlineMath: [['$','$'], ['\\(','\\)']],
      skipTags: ["script","noscript","style","textarea","pre","code","img"],
      processClass: "tex",
    },

    "HTML-CSS": {
      scale: 90,
      mtextFontInherit: true
    }

  });

  MathJax.Hub.Configured();
}

$(document).ready(function() {
  configureMathJax();
});
