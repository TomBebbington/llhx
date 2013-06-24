@:build(llhx.Generator.gen()) class Testy {
	public static function root():Int {
		var a = [34, 235, 328, 235];
		return a[2];
	}
}
class Test {
	public static function main() {
		var t = Testy.getGenerated();
		while(true) {
			var a = Std.parseInt(js.Browser.window.prompt("Number", "3"));
			js.Browser.window.alert(Std.string(t.root()));
		}
	}
}