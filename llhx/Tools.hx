package llhx;
using Lambda;
class Tools {
	public static inline function enumEq(a:EnumValue, b:EnumValue):Bool {
		return Type.enumEq(a, b);
	}
	public static function removeDuplicates<T>(a:Array<T>, eq:T -> T -> Bool):Array<T> {
		var exc = new Array<T>();
		for(i in a) {
			var unique = true;
			for(b in exc)
				if(i == b || eq(i, b)) {
					unique = false;
					break;
				}
			if(unique)
				exc.push(i);
		}
		return exc;
	}
}