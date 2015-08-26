package ;
import com.xay.util.Util;
import flash.display.BlendMode;
import flash.display.Shape;
import flash.filters.GlowFilter;
import motion.Actuate;
class Bolt extends Shape {
	var x0 : Float;
	var y0 : Float;
	var x1 : Float;
	var y1 : Float;
	var length : Float;
	var timer : Int;
	public var deleted : Bool;
	public function new(x0:Float, y0:Float, x1:Float, y1:Float) {
		super();
		this.x0 = x0;
		this.y0 = y0;
		this.x1 = x1;
		this.y1 = y1;
		var dx = x1 - x0;
		var dy = y1 - y0;
		length = Math.sqrt(dx * dx + dy * dy);
		timer = 0;
		deleted = false;
		Game.CUR.lm.addChild(this, Const.FRONT_L);
		blendMode = BlendMode.ADD;
		render();
		Actuate.tween(this, .4, {alpha: 0.});
		filters = [new GlowFilter(0xFFFFFF, 1., 20, 20, 2, 0)];
	}
	function delete() {
		deleted = true;
		parent.removeChild(this);
	}
	public function update() {
		if(timer < 3) {
			if(heroCollides()) {
				Game.CUR.hero.die(Game.CUR.hero.vx, Game.CUR.hero.vy);
			}
		}
		render();
		timer++;
		if(timer >= 20) {
			delete();
		}
	}
	function render() {
		var g = graphics;
		var segl = 10;
		var nseg = Std.int(length / segl);
		g.clear();
		g.lineStyle(1., 0xFFFFFFFF, .5);
		g.moveTo(x0, y0);
		var dx = (x1 - x0) / length;
		var dy = (y1 - y0) / length;
		for(i in 1...nseg+1) {
			g.lineTo(x0 + dx * i * segl + dy * Util.randFloat(-4, 4), y0 + dy * i * segl + dx * Util.randFloat(-4, 4));
		}
		g.lineTo(x1, y1);
		g.endFill();
	}
	function heroCollides() {
		var hero = Game.CUR.hero;
		if(hero == null || hero.dead) return false;
		var dx = hero.xx - x0;
		var dy = hero.yy - y0;
		var dist = Math.sqrt(dx*dx + dy*dy);
		var heroAngle = Math.atan2(dy, dx);
		var angle = Math.atan2(y1 - y0, x1 - x0);
		var da = angle - heroAngle;
		var distFromBolt = Math.tan(da) * dist;
		if(Math.abs(distFromBolt) > 8) return false;
		var l = dist * Math.cos(da);
		if(l > 0 && l < length) {
			return true;
		}
		return false;
	}
}
class Tesla extends Enemy {
	public static var ALL : Array<Tesla> = [];
	var tx : Int;
	var ty : Int;
	public var id : Int;
	var links : Array<Int>;
	var bolts : Array<Bolt>;
	var time : Int;
	var timer : Int;
	public function new(tx:Int, ty:Int, id:Int, links:Array<Int>, time:Int, off:Int) {
		super("teslaIdle", true);
		anim.loop = true;
		anim.setFrame(Std.random(6));
		this.links = links.copy();
		this.id = id;
		this.tx = tx;
		this.ty = ty;
		this.time = time;
		off %= time;
		timer = off;
		//setOrigin(.5, 1);
		xx = tx * 16 + 8;
		yy = ty * 16 + 8;
		moves = false;
		shadow.alpha *= .4;
		ALL.push(this);
		bolts = [];
		update();
		shadow.scaleX *= .8;
		shadow.scaleY *= .8;
	}
	public static function init() {
		
	}
	override public function delete() {
		super.delete();
		ALL.remove(this);
		for(b in bolts) {
			if(b.parent != null) {
				b.parent.removeChild(b);
			}
		}
	}
	override public function update() {
		if(time > 0) {
			timer++;
			if(timer == time - 9) {
				charge();
			} if(timer >= time) {
				timer = 0;
				shoot();
			}
			var i = 0;
			while(i < bolts.length) {
				bolts[i].update();
				if(bolts[i].deleted) {
					bolts.remove(bolts[i]);
					i--;
				}
				i++;
			}
		}
		super.update();
	}
	public function charge() {
		/*setAnim("teslaCharge", true);
		anim.play();
		for(l in links) {
			for(t in ALL) {
				if(t.id == l) {
					t.setAnim("teslaCharge", true);
					t.anim.play();
					break;
				}
			}
		}*/
	}
	public function shoot() {
		for(l in links) {
			for(t in ALL) {
				if(t.id == l) {
					boltTo(t);
					break;
				}
			}
		}
		setAnim("teslaIdle", true);
		anim.play();
	}
	function boltTo(t:Tesla) {
		var b = new Bolt(xx, yy, t.xx, t.yy);
		bolts.push(b);
		t.setAnim("teslaIdle", true);
		t.anim.play();
	}
	override function collidesHero() {
		var hero = Game.CUR.hero;
		if(hero == null || hero.dead) return false;
		var dx = hero.xx - xx;
		var dy = hero.yy - yy;
		var r = hero.cradius + 2;
		return dx*dx + dy*dy < r * r;
	}
}