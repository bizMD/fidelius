function create(__helpers) {
  var str = __helpers.s,
      empty = __helpers.e,
      notEmpty = __helpers.ne;

  return function render(data, out) {
    out.w('<html><head><meta charset="UTF-8"><title>Fidelius</title><style>.placeholder { display: none; }</style></head><body><h2>Page Changer</h2><section><select id="pages"><option value="false" class="placeholder" selected disabled>Please select</option></select><button id="button" type="button">Change</button></section><script src="/cockpit/js"></script></body></html>');
  };
}
(module.exports = require("marko").c(__filename)).c(create);