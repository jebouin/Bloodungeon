package ;
import flash.display.BlendMode;
import flash.display.Shape;
class Laser extends Enemy {
	var tx : Int;
	var ty : Int;
	var beam : Shape;
	var timer : Int;
	var length : Float;
	var level : Level;
	public function new(level:Level, tx:Int, ty:Int) {
		super("xana", false);
		anim.stop();
		moves = false;
		this.tx = tx;
		this.ty = ty;
		this.level = level;
		xx = tx * 16 + 8;
		yy = ty * 16 + 8;
		setOriginInPixels(7, 11);
		timer = 0;
		beam = new Shape();
		beam.blendMode = BlendMode.ADD;
		addChild(beam);
		update();
	}
	override public function update() {
		super.update();
		var hero = Game.CUR.hero;
		if(hero != null) {
			var curAngle = (rotation - 90) * Math.PI / 180.;
			var heroAngle = Math.atan2(hero.yy - yy, hero.xx - xx);
			/*if(curAngle > Math.PI) curAngle -= Math.PI * 2.;
			if(curAngle < -Math.PI) curAngle += Math.PI * 2.;*/
			var rotSpeed = .07 * 180 / Math.PI;
			if(curAngle < heroAngle) {
				var d = heroAngle - curAngle;
				var dd = curAngle - heroAngle + Math.PI * 2.;
				if(d < dd) {
					rotation += d * rotSpeed;
				} else {
					rotation -= dd * rotSpeed;
				}
			} else if(heroAngle < curAngle) {
				var d = curAngle - heroAngle;
				var dd = heroAngle + Math.PI * 2. - curAngle;
				if(d < dd) {
					rotation -= d * rotSpeed;
				} else {
					rotation += dd * rotSpeed;
				}
			}
			if(rotation < 90) rotation += 360;
			if(rotation > 270) rotation -= 360;
			if(timer <= 2) {
				rotation = heroAngle * 180 / Math.PI + 90;
			}
			timer++;
		}
		updateBeam();
	}
	function updateBeam() {
		length = getBeamLength();
		renderBeam();
	}
	function getBeamLength() {
		var thwomps = [];
		for(e in Game.CUR.entities) {
			if(Type.getClass(e) == Thwomp) {
				var t = cast(e, Thwomp);
				thwomps.push(t.getCollisionRect());
			}
		}
		var angle = (rotation - 90) * Math.PI / 180.;
		var l = 0.;
		var dx = Math.cos(angle);
		var dy = Math.sin(angle);
		while(l < Const.WID) {
			l += 2;
			var lx = xx + dx * l;
			var ly = yy + dy * l;
			if(level.getCollision(Std.int(lx) >> 4, Std.int(ly) >> 4) == FULL) {
				break;
			}
			var hit = false;
			for(r in thwomps) {
				if(r.contains(lx, ly)) {
					hit = true;
					break;
				}
			}
			if(hit) break;
		}
		return l - 1;
	}
	function renderBeam() {
		var g = beam.graphics;
		g.clear();
		var loff = 10;
		var thick = (timer >> 1) & 1 == 0 ? 1. : 3.;
		if((timer >> 1) & 1 == 0) {
			g.lineStyle(2, 0xAA0000, .5);
			g.moveTo(0, -loff);
			g.lineTo(0, -length);
		} else {
			g.lineStyle(3, 0xFF0000, .7);
			g.moveTo(0, -loff);
			g.lineTo(0, -length);
		}
	}
	override public function collidesHero() {
		var hero = Game.CUR.hero;
		if(hero == null) return false;
		var dx = hero.xx - xx;
		var dy = hero.yy - yy;
		var dist = Math.sqrt(dx*dx + dy*dy);
		var heroAngle = Math.atan2(dy, dx);
		var angle = (rotation - 90) * Math.PI / 180.;
		var da = angle - heroAngle;
		var distFromBeam = Math.tan(da) * dist;
		if(Math.abs(distFromBeam) > 5) return false;
		var l = dist * Math.cos(da);
		if(l > 0 && l < length) {
			return true;
		}
		return false;
	}
}