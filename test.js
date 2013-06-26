(function () { "use strict";
var Std = function() { }
Std.parseFloat = function(x) {
	return parseFloat(x);
}
var llhx = {}
llhx.LowLevel = function() { }
var js = {}
js.Browser = function() { }
var Testy = function() { }
Testy.__interfaces__ = [llhx.LowLevel];
var Test = function() { }
Test.main = function() {
	while(true) {
		var x = Std.parseFloat(js.Browser.window.prompt("Please enter the X value"));
		var y = Std.parseFloat(js.Browser.window.prompt("Please enter the Y value"));
		var d = Testy.diagonal(x,y);
		js.Browser.window.alert("Diagonal: " + d);
	}
}
Math.__name__ = ["Math"];
Math.NaN = Number.NaN;
Math.NEGATIVE_INFINITY = Number.NEGATIVE_INFINITY;
Math.POSITIVE_INFINITY = Number.POSITIVE_INFINITY;
Math.isFinite = function(i) {
	return isFinite(i);
};
Math.isNaN = function(i) {
	return isNaN(i);
};
Testy = (function(std, ext, heap) {"use asm";function _c(x, y) {x = +x;y = +y;return +(ext._d(+(+x*+y)));}function _b(r) {r = +r;return +3.14159265359*+r*+r;}function _a(r) {r = +r;return +(+(+r*+3.14159265359)*+2.0);}function init() {}return {diagonal: _c, area: _b, __init__: init, circumference: _a};})(js.Browser.window,{ _d : Math.sqrt, _e : function() {
	return Math.PI;
}},new ArrayBuffer(4096));
js.Browser.window = typeof window != "undefined" ? window : null;
Test.main();
})();
