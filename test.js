(function () { "use strict";
var Std = function() { }
Std.parseFloat = function(x) {
	return parseFloat(x);
}
var Testy = function() { }
Testy.asm = function() {
	return (function(std, ext, heap) {"use asm";function _a(b) {b = b|0;var a = 0|0;;for(i=1;i<b;i++)a+=b|0;return a|0;}return {diag: _a};})(window);
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
