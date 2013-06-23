(function () { "use strict";
var Std = function() { }
Std.parseFloat = function(x) {
	return parseFloat(x);
}
var Testy = function() { }
Testy.asm = function() {
	return (function(std, ext, heap) {"use asm";var _c = std.Math.sqrt;var _d = std.Math.pow;function _a(n) {n = +n;return +(n*n);}function _b(x, y) {x = +x;y = +y;return +_c(+(_d(+x, +2.0)+_d(+y, +2.0)));}return {square: _a, diag: _b};})(window);
}
var Test = function() { }
Test.main = function() {
	var comp = Testy.asm();
	while(true) {
		var a = Std.parseFloat(js.Browser.window.prompt("X","3"));
		var b = Std.parseFloat(js.Browser.window.prompt("Y","4"));
		js.Browser.window.alert("Diagonal: " + comp.diag(a,b));
	}
}
var js = {}
js.Browser = function() { }
js.Browser.window = typeof window != "undefined" ? window : null;
Test.main();
})();
