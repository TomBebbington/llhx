(function () { "use strict";
var Testy = function() { }
Testy.asm = function() {
	return (function(std, foreign, heap) {"use asm";var _c = std.Math.sqrt;var _d = std.Math.pow;function _a(n) {n = +n;{return n*n;}};function _b(x, y) {x = +x;y = +y;{return _c(++_d(+x, (2)|0)++_d(+y, (2)|0));}};return {square: _a, diag: _b};})(window);
}
var Test = function() { }
Test.main = function() {
	var comp = Testy.asm();
	console.log(comp.square(56));
}
Test.main();
})();
