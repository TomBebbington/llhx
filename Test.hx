import js.Browser.*;
class Testy implements llhx.LowLevel {
	public static function circumference(r:Float):Float {
		return r * Math.PI * 2.0;
	}
	public static function area(r:Float):Float {
		return Math.PI * r * r;
	}
	public static function diagonal(x:Float, y:Float):Float {
		return Math.sqrt(x * y);
	}
}
class Test {
	public static function main() {
		while(true) {
			var x = Std.parseFloat(window.prompt("Please enter the X value"));
			var y = Std.parseFloat(window.prompt("Please enter the Y value"));
			var d = Testy.diagonal(x, y);
			window.alert('Diagonal: $d');
		}
	}
}