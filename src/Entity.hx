package ;
import com.xay.util.XSprite;
import flash.display.Shape;
import flash.display.Sprite;
class Entity extends XSprite {
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
	public function new() {
		super();
		xx = Const.WID * .5;
		yy = Const.HEI * .5;
		zz = 0.;
		vx = vy = vz = 0.;
		maxSpeed = -1.;
		friction = .3;
		frictionZ = .01;
		gravity = .8;
		speed = 2.;
		cradius = 6;
		onGround = collides = locked = false;
		shadow = new Shape();
		renderShadow();
		Game.CUR.lm.addChild(shadow, Const.SHADOW_L);
	}
	override public function delete() {
		super.delete();
	}
	public override function update() {
		if(locked) return;
		vz -= gravity;
		vx -= vx * friction;
		vy -= vy * friction;
		vz -= vz * frictionZ;
		handleStairFriction();
		if(maxSpeed > 0) {
			var s = vx*vx + vy*vy;
			if(s > maxSpeed*maxSpeed) {
				s = Math.sqrt(s);
				vx = vx / s * maxSpeed;
				vy = vy / s * maxSpeed;
			}
		}
		tryMove(vx, vy, vz);
		this.x = Std.int(xx);
		this.y = Std.int(yy - zz * 16);
		var groundZ = Game.CUR.level.getHeightAt(xx, yy);
		shadow.x = Std.int(xx);
		shadow.y = Std.int(yy + height*.35 - groundZ * 16);
		super.update();
	}
	function handleStairFriction() {
		if(!onGround) return;
		var col = Game.CUR.level.getCollisionAt(xx, yy);
		if(col == USTR) {
			vy /= 10.41;
		} else if(col == LSTR || col == RSTR) {
			vx /= 10.41;
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
		var groundZ = Game.CUR.level.getHeightAt(xx, yy);
		if(zz + dz < groundZ) {
			onGround = true;
			zz = groundZ;
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
}