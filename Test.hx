class Testy implements llhx.LowLevel {
	public static function run() {
		js.Browser.window.alert(Math.PI);
	}
}
class Test {
	public static function main() {
		var t = Testy.getGenerated();
		t.run();
	}
}