package ;
import flash.display.BitmapCompressColorSpace;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Shape;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import motion.Actuate;
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
	public var gravity : Float;
	public var bounciness : Float;
	public var rotVel : Float;
	public var friction : Float;
	public var frictionZ : Float;
	public var onBounce : Particle->Void;
	public var onUpdate : Particle->Void;
	public var onDie : Void->Void;
	public var lifeTime : Int;
	public var timer : Int;
	public var ct : ColorTransform;
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
	public static function deleteAll() {
		for(p in ALL) {
			p.onDie = null;
			p.delete();
		}
	}
	public function new() {
		super();
		deleted = false;
		ct = new ColorTransform();
		reset();
	}
	function reset() {
		Actuate.stop(this);
		xx = yy = zz = vx = vy = vz = rotVel = friction = frictionZ = gravity = bounciness = 0.;
		transformColor(1., 1., 1., 1.);
		blendMode = BlendMode.NORMAL;
		timer = 0;
		scaleX = scaleY = 1.;
		alpha = 1.;
		visible = true;
		onUpdate = null;
		onBounce = null;
		onDie = null;
		lifeTime = -1;
		graphics.clear();
		if(parent != null) {
			parent.removeChild(this);
		}
	}
	public function delete() {
		if(deleted) return;
		deleted = true;
		if(onDie != null) {
			onDie();
		}
		reset();
	}
	public function update() {
		if(deleted) return;
		if(onUpdate != null) {
			onUpdate(this);
		}
		vx -= friction * vx;
		vy -= friction * vy;
		vz -= gravity;
		vz -= frictionZ * vz;
		xx += vx;
		yy += vy;
		zz += vz;
		rotation += rotVel;
		if(zz < 0 && bounciness >= 0) {
			zz = 0;
			vz *= -bounciness;
			if(onBounce != null) {
				onBounce(this);
			}
		}
		this.x = Std.int(xx);
		this.y = Std.int(yy - zz * .5);
		timer++;
		if(lifeTime > 0 && timer >= lifeTime) {
			delete();
		}
	}
	public function drawRect(wid:Float, hei:Float, col:Int, ?clear=false) {
		if(clear) {
			graphics.clear();
		}
		graphics.beginFill(col);
		graphics.drawRect(-wid*.5, -hei*.5, wid, hei);
		graphics.endFill();
	}
	public function drawCircle(r:Float, col:Int, ?clear=false) {
		if(clear) {
			graphics.clear();
		}
		graphics.beginFill(col);
		graphics.drawCircle(0, 0, r);
		graphics.endFill();
	}
	public function drawToBD(bd:BitmapData, ?useAlpha=true) {
		var mat = new Matrix();
		mat.rotate(rotation * Math.PI / 180.);
		mat.translate(xx, yy);
		if(useAlpha) {
			bd.draw(this, mat, new ColorTransform(1., 1., 1., alpha));
		} else {
			bd.draw(this, mat, ct);
		}
	}
	public function transformColor(r:Float, g:Float, b:Float, a:Float) {
		ct.redMultiplier = r;
		ct.greenMultiplier = g;
		ct.blueMultiplier = b;
		ct.alphaMultiplier = a;
		transform.colorTransform = ct;
	}
}