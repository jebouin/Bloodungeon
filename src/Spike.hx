package ;
import haxe.Timer;
class Spike extends Enemy {
	public static var ALL : Array<Spike> = [];
	public var timer : Timer;
	public var outTimer : Int;
	public var out : Bool;
	public var tx : Int;
	public var ty : Int;
	public var dir : Const.DIR8;
	public var dirStr : String;
	public function new(tx:Int, ty:Int, dir:Const.DIR8) {
		this.dir = dir;
		var animName = "spikeIdle";
		if(dir != null) {
			dirStr = Const.dir8ToString(dir);
			dirStr = "spike" + dirStr.charAt(0).toUpperCase() + dirStr.substr(1);
			animName = dirStr + "Idle";
		}
		super(animName, false);
		setOrigin(0, 0);
		xx = tx * 16;
		yy = ty * 16;
		if(dir == null) {
			yy -= 10;
		} else if(dir == UP_LEFT || dir == UP_RIGHT || dir == UP) {
			setOriginInPixels(0, 16);
		}
		if(dir != null) {
			Game.CUR.lm.addChild(this, Const.BACKWALL_L);
		}
		this.tx = tx;
		this.ty = ty;
		out = false;
		moves = false;
		anim.setFrame((tx + ty & 1) * 2);
		super.update();
		ALL.push(this);
	}
	override public function delete() {
		super.delete();
		ALL.remove(this);
	}
	override public function update() {
		var hero = Game.CUR.hero;
		if(dir == null) {
			if(!out) {
				if(isOnTop(hero)) {
					out = true;
					outTimer = 18;
				}
			} else {
				outTimer--;
				if(outTimer == 0) {
					Audio.playSound("spike");
					setAnim("spikeOut", false);
					anim.play();
					anim.onEnd = function() {
						out = false;
						setAnim("spikeIdle", false);
					}
					if(hits(hero)) {
						killHero(hero);
					}
				}
			}
		} else {
			if(!out) {
				if(hits(hero)) {
					Audio.playSound("spike");
					goOut(null);
					killHero(hero);
				}
			}
		}
		super.update();
	}
	public function goOut(dd:Const.DIR8) {
		if(out || dir == null) return;
		out = true;
		setAnim(dirStr + "Out", false);
		anim.play();
		anim.onEnd = function() {
			out = false;
			setAnim(dirStr + "Idle", false);
		}
		timer = Timer.delay(function() {
			var dirs = [];
			for(d in Const.DIRS8) {
				if(!Const.isOpposite8(d, dd)) {
					dirs.push(d);
					continue;
				}
			}
			for(s in ALL) {
				if(s != this) {
					for(d in dirs) {
						if(s.tx + Const.getDir8X(d) == tx && s.ty + Const.getDir8Y(d) == ty) {
							s.goOut(d);
						}
					}
				}
			}
		}, 50);
	}
	function isSameTile(otx:Int, oty:Int) {
		return otx == tx && oty == ty;
	}
	function isOnTop(e:Entity) {
		if(e.dead) return false;
		if(dir != null) return false;
		return (isSameTile(Std.int(e.xx - e.cradius) >> 4, Std.int(e.yy - e.cradius) >> 4))
			|| (isSameTile(Std.int(e.xx + e.cradius) >> 4, Std.int(e.yy - e.cradius) >> 4))
			|| (isSameTile(Std.int(e.xx + e.cradius) >> 4, Std.int(e.yy + e.cradius) >> 4))
			|| (isSameTile(Std.int(e.xx - e.cradius) >> 4, Std.int(e.yy + e.cradius) >> 4));
	}
	function hits(e:Entity) {
		if(e.dead) return false;
		var sameTile = isSameTile(Std.int(e.xx) >> 4, Std.int(e.yy) >> 4);
		if(!sameTile) {
			return false;
		}
		if(dir == null) {
			return true;
		} else {
			switch(dir) {
				case UP:
					return touchesWall(e, UP);
				case DOWN:
					return touchesWall(e, DOWN);
				case LEFT:
					return touchesWall(e, LEFT);
				case RIGHT:
					return touchesWall(e, RIGHT);
				case UP_LEFT:
					return touchesWall(e, UP) || touchesWall(e, LEFT);
				case UP_RIGHT:
					return touchesWall(e, UP) || touchesWall(e, RIGHT);
				case DOWN_LEFT:
					return touchesWall(e, DOWN) || touchesWall(e, LEFT);
				case DOWN_RIGHT:
					return touchesWall(e, DOWN) || touchesWall(e, RIGHT);
				default:
					
			}
		}
		return false;
	}
	function touchesWall(e:Entity, dir:Const.DIR) {
		switch(dir) {
			case UP:
				return (e.yy - e.cradius < yy + 2);
			case DOWN:
				return (e.yy + e.cradius > yy + 15);
			case LEFT:
				return (e.xx - e.cradius < xx + 2);
			case RIGHT:
				return (e.xx + e.cradius > xx + 15);
			default:
		}
	}
	override function killHero(h:Hero) {
		var dx = 0;
		var dy = 0;
		if(dir != null) {
			dx = Const.getDir8X(dir);
			dy = Const.getDir8Y(dir);
		}
		h.die(dx, dy);
	}
}