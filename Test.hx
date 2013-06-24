@:build(llhx.Generator.gen()) class Testy {
	public static function fib(d:Int):Int {
		var s:String = "Hello, world!";
		var n:Int = 0;
		while(d-- > 0)
			n += d;
		return n;
	}
}
class Test {
	public static function main() {
		//var comp = Testy.getGenerated();
		var t = new Testy();
		while(true) {
			var a = Std.parseInt(js.Browser.window.prompt("Number", "3"));
			js.Browser.window.alert(Std.string(t.fib(a)));
		}
	}
}