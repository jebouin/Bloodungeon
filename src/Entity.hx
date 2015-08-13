package ;
import com.xay.util.XSprite;
import flash.display.Shape;
import flash.display.Sprite;
import haxe.Timer;
import motion.Actuate;
import motion.easing.Cubic;
import motion.easing.Linear;
import motion.easing.Quad;
class Entity extends XSprite {
	public var roomId : Int;
	public var xx : Float;
	public var yy : Float;
	public var zz : Float;
	public var vx : Float;
	public var vy : Float;
	public var vz : Float;
	public var gravity : Float;
	public var frictionZ : Float;
	public var friction : Float;
	public var speed : Float;
	public var maxSpeed : Float;
	public var shadow : Shape;
	public var onGround : Bool;
	public var collides : Bool;
	public var locked : Bool;
	public var cradius : Float;
	public var dead : Bool;
	public var moves : Bool;
	public var onIce : Bool;
	public function new(?animName:String, ?hasShadow=true) {
		super(animName);
		xx = Const.WID * .5;
		yy = Const.HEI * .5;
		zz = 0.;
		vx = vy = vz = 0.;
		maxSpeed = -1.;
		roomId = -1;
		friction = .3;
		frictionZ = .01;
		gravity = .8;
		speed = 2.;
		cradius = 5;
		onGround = collides = locked = dead = onIce = false;
		moves = true;
		if(hasShadow) {
			shadow = new Shape();
			renderShadow();
			Game.CUR.lm.addChild(shadow, Const.SHADOW_L);
		}
	}
	override public function delete() {
		if(shadow != null) {
			if(shadow.parent != null) {
				shadow.parent.removeChild(shadow);
			}
		}
		super.delete();
	}
	public override function update() {
		if(locked) return;
		if(moves) {
			onIce = false;
			var col = Game.CUR.level.getCollisionAt(xx, yy);
			var curFriction = friction;
			if(col == ICE) {
				onIce = true;
				curFriction = 0;
			}
			vz -= gravity;
			vx -= vx * curFriction;
			vy -= vy * curFriction;
			vz -= vz * frictionZ;
			if(maxSpeed > 0) {
				var s = vx*vx + vy*vy;
				if(s > maxSpeed*maxSpeed) {
					s = Math.sqrt(s);
					vx = vx / s * maxSpeed;
					vy = vy / s * maxSpeed;
				}
			}
			tryMove(vx, vy, vz);
		}
		this.x = Std.int(xx);
		this.y = Std.int(yy - zz * .5);
		if(shadow != null) {
			shadow.x = Std.int(xx);
			shadow.y = Std.int(yy + height * (1. - originYRatio) - 3.);
		}
		super.update();
		if(collides) {
			if(canFall()) {
				fall();
			}
		}
	}
	function tryMove(dx:Float, dy:Float, dz:Float) {
		if(collides) {
			if(Game.CUR.level.entityCollides(this, xx+dx, yy)) {
				if(dx > 0) {
					xx = Std.int(xx / 16 + 1.) * 16 - cradius - .2;
				} else if(dx < 0) {
					xx = Std.int(xx / 16) * 16 + cradius + .2;
				}
				vx = 0;
			} else {
				xx += dx;
			}
			if(Game.CUR.level.entityCollides(this, xx, yy+dy)) {
				if(dy > 0) {
					yy = Std.int(yy / 16 + 1.) * 16 - cradius - .2;
				} else if(dy < 0) {
					yy = Std.int(yy / 16) * 16 + cradius + .2;
				}
				vy = 0;
			} else {
				yy += dy;
			}
		} else {
			xx += dx;
			yy += dy;
		}
		if(zz + dz < 0) {
			onGround = true;
			zz = 0;
			vz = 0;
		} else if(dx > 0) {
			onGround = false;
		}
	}
	public function renderShadow(size=8.) {
		shadow.graphics.clear();
		shadow.graphics.beginFill(0x0);
		shadow.graphics.drawCircle(0, 0, size);
		shadow.graphics.endFill();
		shadow.alpha = .5;
		shadow.scaleY = .5;
	}
	public function jump() {
		if(!onGround) return;
		vz = 10.;
	}
	public function die() {
		delete();
	}
	public function canFall() {
		return Game.CUR.level.entityCollidesFully(this, xx, yy, HOLE);
	}
	public function fall() {
		locked = true;
		if(shadow != null) {
			shadow.visible = false;
		}
		parent.removeChild(this);
		Game.CUR.lm.addChild(this, Const.VOID_L);
		var tt = .5;
		Actuate.tween(this, tt, {x: x + vx*tt*20}).ease(Cubic.easeOut);
		Actuate.tween(this, tt, {y: y+20, scaleX: 0., scaleY: 0.}).onComplete(function() {
			die();
		}).ease(Linear.easeNone);
	}
}