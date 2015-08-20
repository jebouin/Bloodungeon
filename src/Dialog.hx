package ;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Rectangle;
class Dialog extends Sprite {
	public static var ALL : Array<Dialog> = [];
	public var entity : Entity;
	public var deleted : Bool;
	var back : Shape;
	var bitmap : Bitmap;
	var relX : Float;
	var relY : Float;
	var timer : Int;
	public static function create() {
		for(d in ALL) {
			if(d.deleted) {
				d.deleted = false;
				return d;
			}
		}
		var d = new Dialog();
		ALL.push(d);
		return d;
	}
	public static function updateAll() {
		for(d in ALL) {
			if(!d.deleted) {
				d.update();
			}
		}
	}
	public function new() {
		super();
		reset();
		deleted = false;
		back = new Shape();
		back.graphics.beginFill(0x0, .4);
		back.graphics.drawRect(0, 0, 100, 100);
		back.graphics.endFill();
		addChild(back);
		bitmap = new Bitmap();
		addChild(bitmap);
	}
	public function delete() {
		reset();
		deleted = true;
		if(parent != null) {
			parent.removeChild(this);
		}
	}
	function reset() {
		entity = null;
		deleted = true;
		relX = 0;
		relY = -20;
	}
	public function update() {
		x = Std.int(entity.xx + relX);
		y = Std.int(entity.yy + relY);
		timer--;
		if(timer < 20) {
			alpha = timer / 20;
			relY -= 1;
		}
		if(timer == 0) {
			delete();
		}
	}
	public function init(e:Entity, str:String, time:Int) {
		entity = e;
		Game.CUR.lm.addChild(this, Const.FRONT_L);
		if(bitmap.bitmapData != null) {
			bitmap.bitmapData.dispose();
		}
		bitmap.bitmapData = Main.font.getText(str);
		bitmap.x = Std.int(-bitmap.width * .5);
		bitmap.y = Std.int(-bitmap.height * .5);
		this.timer = time;
		var bw = bitmap.width + 2;
		var bh = bitmap.height + 2;
		back.scrollRect = new Rectangle(0, 0, bw, bh);
		back.x = Std.int(-bw * .5);
		back.y = Std.int(-bh * .5);
	}
}