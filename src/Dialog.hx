package ;
import com.xay.util.Input;
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
	var baseX : Float;
	var baseY : Float;
	public static function say(x:Float, y:Float, str:String, t:Int) {
		var d = create();
		d.init(null, str, t, x, y);
	}
	public static function create() {
		for(d in ALL) {
			if(d.deleted) {
				d.deleted = false;
				Audio.playSound("dialog");
				return d;
			}
		}
		var d = new Dialog();
		ALL.push(d);
		return d;
	}
	public static function updateAll() {
		var n = 0;
		for(d in ALL) {
			if(!d.deleted) {
				n++;
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
		relX = 0;
		relY = -20;
		alpha = 1.;
		visible = true;
	}
	public function update() {
		if(entity == null) {
			x = baseX + relX;
			y = baseY + relY;
		} else {
			x = Std.int(entity.xx + relX);
			y = Std.int(entity.yy + relY);
		}
		if(timer < -2) {
			if(Input.newKeyPress("start")) {
				timer = 20;
			}
		} else if(timer >= 0) {
			if(timer < 20) {
				alpha = timer / 20;
				relY -= 1;
			}
			if(timer == 0) {
				delete();
				return;
			}
		}
		timer--;
	}
	public function init(e:Entity, str:String, time:Int, ?x:Float, ?y:Float) {
		entity = e;
		if(e == null) {
			baseX = x;
			baseY = y;
		}
		Game.CUR.lm.addChild(this, Const.FRONT_L);
		if(bitmap.bitmapData != null) {
			bitmap.bitmapData.dispose();
		}
		bitmap.bitmapData = Main.font.getText(str, 17, true);
		bitmap.x = Std.int(-bitmap.width * .5);
		bitmap.y = Std.int(-bitmap.height * .5);
		this.timer = time;
		var bw = bitmap.width - 2;
		var bh = bitmap.height + 2;
		back.scrollRect = new Rectangle(0, 0, bw, bh);
		back.x = Std.int(-bw * .5) - 3;
		back.y = Std.int(-bh * .5);
		update();
	}
}