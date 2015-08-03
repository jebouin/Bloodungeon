package ;
import haxe.Timer;
class Spike extends Enemy {
	public var out : Bool;
	public var tx : Int;
	public var ty : Int;
	public function new(tx:Int, ty:Int) {
		super("spikeIdle", false);
		setOrigin(0, 0);
		xx = tx * 16;
		yy = ty * 16 - 10;
		this.tx = tx;
		this.ty = ty;
		out = false;
		super.update();
	}
	override public function update() {
		var hero = Game.CUR.hero;
		if(out) {
			if(hits(hero)) {
				hero.die();
			}
		} else {
			if(isOnTop(hero)) {
				Timer.delay(function() {
					out = true;
					setAnim("spikeOut", false);
					anim.play();
					anim.onEnd = function() {
						out = false;
						setAnim("spikeIdle");
					}
				}, 300);
			}
		}
		super.update();
	}
	function isSameTile(otx:Int, oty:Int) {
		return otx == tx && oty == ty;
	}
	function isOnTop(e:Entity) {
		return (isSameTile(Std.int(e.xx - e.cradius) >> 4, Std.int(e.yy - e.cradius) >> 4))
			|| (isSameTile(Std.int(e.xx + e.cradius) >> 4, Std.int(e.yy - e.cradius) >> 4))
			|| (isSameTile(Std.int(e.xx + e.cradius) >> 4, Std.int(e.yy + e.cradius) >> 4))
			|| (isSameTile(Std.int(e.xx - e.cradius) >> 4, Std.int(e.yy + e.cradius) >> 4));
	}
	function hits(e:Entity) {
		return isSameTile(Std.int(e.xx) >> 4, Std.int(e.yy) >> 4);
	}
}