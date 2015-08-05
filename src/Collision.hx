package ;
import flash.geom.Rectangle;
enum TILE_COLLISION_TYPE {
	NONE;
	FULL;
	HOLE;
}
class Collision {
	public static var TILE_COLLISIONS = [NONE,
										 NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,
										 NONE, NONE, NONE, FULL, FULL, FULL, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,
										 HOLE, NONE, NONE, FULL, FULL, FULL, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,
										 NONE, NONE, NONE, FULL, FULL, FULL, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,
										 NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,
										 NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,
										 NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,
										 NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,
										 NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,
										 NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,
										 NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,
										 NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,
										 NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,
										 NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,
										 NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,
										 NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE];
	public static function circleToCircle(x0:Float, y0:Float, r0:Float, x1:Float, y1:Float, r1:Float) {
		var dx = x1 - x0;
		var dy = y1 - y0;
		return dx*dx + dy*dy < r0*r0 + r1*r1;
	}
	public static function circleToRect(cx:Float, cy:Float, r:Float, rect:Rectangle) {
		var dx = Math.abs(cx - rect.left - rect.width * .5);
		var dy = Math.abs(cy - rect.top - rect.height * .5);
		if(dx > rect.width * .5 + r) return false;
		if(dy > rect.height * .5 + r) return false;
		if(dx < rect.width * .5) return true;
		if(dy < rect.height * .5) return true;
		var ddx = dx - rect.width * .5;
		var ddy = dy - rect.height * .5;
		var distSq = ddx*ddx + ddy*ddy;
		return distSq < r*r;
	}
}