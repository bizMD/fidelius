function create(__helpers) {
  var str = __helpers.s,
      empty = __helpers.e,
      notEmpty = __helpers.ne;

  return function render(data, out) {
    out.w('<html><head><meta charset="UTF-8"><title>Done!</title><script src="/socket.io/socket.io.js"></script><script>\n\t\t\tvar socket = io();\n\t\t</script></head><body><section class="upload wsdl"><h2>Upload WSDL</h2><form id="uploadForm"><input name="wsdl" type="file"></form></section><section class="add filter"><h2>Add Filter</h2><form id="addFilter"><input name="filter" class="filterName" type="text"><div class="filter items list"><div class="filter item"><input name="key[]" type="text"><input name="value[]" type="text"><button type="button" class="add more">+</button></div></div><button type="button" id="filter">Register</button></form></section><section class="add query"><h2>Add Query</h2><form id="addQuery"><div class="query item"></div><button id="query">Query</button></form></section><script src="/js"></script></body></html>');
  };
}
(module.exports = require("marko").c(__filename)).c(create);