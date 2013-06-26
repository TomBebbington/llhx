class Testy implements llhx.LowLevel {
	public static function diameter(r:Float):Float {
		return r * Math.PI * 2.0;
	}
}
class Test {
	public static function main() {
		var r = Testy.diameter(10);
		trace(r);
	}
}