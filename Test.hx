import js.Browser.*;
class Testy implements llhx.LowLevel {
	public static function circleArea(r:Float):Float {
		return Math.PI * Math.pow(r, 2.0);
	}
}
class Test {
	public static function main() {
		trace(Testy.circleArea(16));
	}
}