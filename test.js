(function () { "use strict";
var Std = function() { }
Std.parseFloat = function(x) {
	return parseFloat(x);
}
var Testy = function() { }
Testy.asm = function() {
	return (function(std, ext, heap) {"use asm";function _a(d) {d = d|0;var a = 2, b = 5, c = 6;return (a+b-c+d)|0;}return {fib: _a};})(window);
}
var Test = function() { }
Test.main = function() {
	var comp = Testy.asm();
	while(true) {
		var a = Std.parseFloat(js.Browser.window.prompt("Number","3"));
		js.Browser.window.alert("Diagonal: " + comp.fib(a));
	}
}
var js = {}
js.Browser = function() { }
js.Browser.window = typeof window != "undefined" ? window : null;
Test.main();
})();
