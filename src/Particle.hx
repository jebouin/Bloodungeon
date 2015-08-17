package ;
import flash.display.Shape;
class Particle extends Shape {
	public static var ALL : Array<Particle> = [];
	public inline static var MAX_NB = 300;
	public var deleted : Bool;
	public static function create() {
		if(ALL.length >= MAX_NB) {
			return null;
		}
		var p = new Particle();
		return p;
	}
	public static function updateAll() {
		var i = 0;
		while(i < ALL.length) {
			ALL[i].update();
			if(ALL[i].deleted) {
				ALL.remove(ALL[i]);
			} else {
				i++;
			}
		}
	}
	public function new() {
		super();
		ALL.push(this);
		deleted = false;
		if(Game.CUR != null) {
			Game.CUR.lm.addChild(this, Const.BACK_L);
		}
	}
	public function delete() {
		if(deleted) return;
		deleted = true;
		if(parent != null) {
			parent.removeChild(this);
		}
	}
	public function update() {
		
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