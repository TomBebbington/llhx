import js.Browser.*;
import js.html.*;
class CircleTools implements llhx.LowLevel {
	public static function area(r:Float):Float {
		return Math.PI * r * r;
	}
	public static function circ(r:Float):Float {
		return 2.0 * Math.PI * r;
	}
}
class Test {
	static var radius:InputElement;
	static var area:InputElement;
	static var circ:InputElement;
	//static var canvas:CanvasElement;
	//static var context:CanvasRenderingContext2D;
	static var lastVal:Float;
	public static function main() {
		lastVal = 0;
		if(untyped window.mozRequestAnimationFrame != null)
			untyped window.requestAnimationFrame = untyped window.mozRequestAnimationFrame;
		window.addEventListener("load", function(_) {
			radius = cast document.getElementById("radius");
			area = cast document.getElementById("area");
			circ = cast document.getElementById("circ");
			//canvas = cast document.getElementById("draw");
			//context = canvas.getContext2d();
			window.requestAnimationFrame(update);
		});
	}
	static function update(d:Float) {
		var radiusv = Std.parseFloat(radius.value);
		if(radiusv == lastVal)
			return true;
		area.value = Std.string(CircleTools.area(radiusv));
		circ.value = Std.string(CircleTools.circ(radiusv));
		
		//CircleTools.draw(Std.int(radiusv));
		window.requestAnimationFrame(update);
		return true;
	}
	public static function drawPixel(x:Int, y:Int) {
		trace('$x, $y');
	}
}