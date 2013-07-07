(function () { "use strict";
var llhx = {}
llhx.LowLevel = function() { }
var Testy = function() { }
Testy.__interfaces__ = [llhx.LowLevel];
var Test = function() { }
Test.main = function(){
	console.log(Testy.circleArea(16));
}
Math.__name__ = ["Math"];
Math.NaN = Number.NaN;
Math.NEGATIVE_INFINITY = Number.NEGATIVE_INFINITY;
Math.POSITIVE_INFINITY = Number.POSITIVE_INFINITY;
Math.isFinite = function(i){
	return isFinite(i);
};
Math.isNaN = function(i){
	return isNaN(i);
};
Testy = (function(std, ext, heap) {"use asm";var _b = std.Math.pow;function _a(r) {r = +r;return +(+(+3.14159265359)*+_b(+r, +2.0));}function init() {}return {__init__: init, circleArea: _a};})(window,{ },new ArrayBuffer(4096));
Testy.__init__();
Test.main();
})();
