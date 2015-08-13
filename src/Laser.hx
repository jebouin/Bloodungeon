package ;
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
		setOriginInPixels(6, 10);
		timer = 0;
		beam = new Shape();
		addChild(beam);
		update();
	}
	override public function update() {
		updateBeam();
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
	}
	function updateBeam() {
		length = getBeamLength();
		renderBeam();
	}
	function getBeamLength() {
		var angle = (rotation - 90) * Math.PI / 180.;
		var l = 0.;
		var dx = Math.cos(angle) * 2.;
		var dy = Math.sin(angle) * 2.;
		while(l < Const.WID) {
			l++;
			var tx = Std.int(xx + dx * l * .5) >> 4;
			var ty = Std.int(yy + dy * l * .5) >> 4;
			if(level.getCollision(tx, ty) == FULL) {
				break;
			}
		}
		return l - 1;
	}
	function renderBeam() {
		var g = beam.graphics;
		g.clear();
		//g.beginFill(0xFF00FF);
		g.lineStyle(1., 0xFF00FF);
		g.moveTo(0, 0);
		g.lineTo(0, -length);
		//g.endFill();
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