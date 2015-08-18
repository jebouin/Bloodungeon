package ;
import flash.display.Shape;
class Particle extends Shape {
	public static var ALL : Array<Particle> = [];
	public inline static var MAX_NB = 500;
	public var deleted : Bool;
	public var xx : Float;
	public var yy : Float;
	public var zz : Float;
	public var vx : Float;
	public var vy : Float;
	public var vz : Float;
	public var rotVel : Float;
	public var friction : Float;
	public var frictionZ : Float;
	public static function create() {
		for(p in ALL) {
			if(p.deleted) {
				p.deleted = false;
				return p;
			}
		}
		if(ALL.length >= MAX_NB) {
			return null;
		}
		var p = new Particle();
		ALL.push(p);
		return p;
	}
	public static function updateAll() {
		for(i in 0...MAX_NB) {
			if(ALL[i] == null) continue;
			if(ALL[i].deleted) continue;
			ALL[i].update();
		}
	}
	public function new() {
		super();
		deleted = false;
		reset();
	}
	function reset() {
		xx = yy = zz = vx = vy = vz = rotVel = friction = frictionZ = 0;
		alpha = 1.;
		visible = true;
		graphics.clear();
		if(parent != null) {
			parent.removeChild(this);
		}
	}
	public function delete() {
		if(deleted) return;
		deleted = true;
		reset();
	}
	public function update() {
		vx -= friction * vx;
		vy -= friction * vy;
		vz -= frictionZ * vz;
		xx += vx;
		yy += vy;
		zz += vz;
		this.x = Std.int(xx);
		this.y = Std.int(yy - zz * .5);
	}
	public function drawRect(wid:Float, hei:Float, col:Int, ?clear=false) {
		if(clear) {
			graphics.clear();
		}
		graphics.beginFill(col);
		graphics.drawRect(-wid*.5, -hei*.5, wid, hei);
		graphics.endFill();
	}
}