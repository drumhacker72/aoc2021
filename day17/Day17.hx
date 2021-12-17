using StringTools;

class Day17 {
	static function inside(x:Int, y:Int, xMin:Int, xMax:Int, yMin:Int, yMax:Int):Bool {
		return x >= xMin && x <= xMax && y >= yMin && y <= yMax;
	}

	static function height(vx:Int, vy:Int, xMin:Int, xMax:Int, yMin:Int, yMax:Int):Null<Int> {
		var x:Int = 0;
		var y:Int = 0;
		var highest:Int = y;
		while (true) {
			x += vx;
			y += vy;
			if (vx > 0) --vx;
			else if (vx < 0) ++vx;
			--vy;

			if (y > highest) highest = y;
			if (inside(x, y, xMin, xMax, yMin, yMax)) return highest;
			if (vx == 0 && (x < xMin || x > xMax)) return null;
			if (vy < 0 && y < yMin) return null;
		}
	}

	static public function main() {
		var targetArea:String = sys.io.File.getContent('day17.txt').rtrim();
		var r:EReg = ~/target area: x=(\d+)\.\.(\d+), y=(-\d+)\.\.(-\d+)/;
		r.match(targetArea);
		var xMin:Int = Std.parseInt(r.matched(1));
		var xMax:Int = Std.parseInt(r.matched(2));
		var yMin:Int = Std.parseInt(r.matched(3));
		var yMax:Int = Std.parseInt(r.matched(4));

		var bestHeight:Int = 0;
		var count:Int = 0;
		for (vx in Std.int(Math.sqrt(xMin))...xMax+1) {
			for (vy in yMin...-yMin+1) {
				var h:Null<Int> = height(vx, vy, xMin, xMax, yMin, yMax);
				if (h != null) {
					++count;
					if (h > bestHeight) bestHeight = h;
				}
			}
		}

		Sys.println(bestHeight);
		Sys.println(count);
	}
}
