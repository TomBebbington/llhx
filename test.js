(function () { "use strict";
var llhx = {}
llhx.LowLevel = function() { }
var js = {}
js.Browser = function() { }
var Testy = function() { }
Testy.__interfaces__ = [llhx.LowLevel];
Testy.run = function() {
	return Math.PI;
}
var Test = function() { }
Test.main = function() {
	var r = Testy.run();
	console.log(r);
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
Testy = (function(std, ext, heap) {"use asm";function _a() {return 3.14159265359;}function init() {}return {run: _a, __init__: init};})(js.Browser.window,{ _b : function() {
	return Math.PI;
}},new ArrayBuffer(4096));
js.Browser.window = typeof window != "undefined" ? window : null;
Test.main();
})();
