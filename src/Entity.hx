package ;
import com.xay.util.SpriteLib;
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
		onGround = false;
		shadow = new Shape();
		renderShadow();
		Game.CUR.lm.addChild(shadow, Const.SHADOW_L);
	}
	override public function delete() {
		super.delete();
	}
	public function update() {
		vz -= gravity;
		vx -= vx * friction;
		vy -= vy * friction;
		vz -= vz * frictionZ;
		if(maxSpeed > 0) {
			var s = vx*vx + vy*vy;
			if(s > maxSpeed*maxSpeed) {
				s = Math.sqrt(s);
				vx = vx / s * maxSpeed;
				vy = vy / s * maxSpeed;
			}
		}
		xx += vx;
		yy += vy;
		zz += vz;
		if(zz < 0) {
			onGround = true;
			zz = 0;
			vz = 0;
		} else if(vz > 0) {
			onGround = false;
		}
		this.x = Std.int(xx);
		this.y = Std.int(yy - zz * .5);
		shadow.x = Std.int(xx);
		shadow.y = Std.int(yy + height*.35);
		super.updateAnim();
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