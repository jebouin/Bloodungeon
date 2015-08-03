package ;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Sprite;
import haxe.Timer;
import motion.Actuate;
class Countdown extends Sprite {
	static var bds : Array<BitmapData>;
	var text : Bitmap;
	var timer : Int;
	public function new() {
		super();
		this.mouseChildren = this.mouseEnabled = false;
		if(bds == null) {
			createBDS();
		}
		text = new Bitmap();
		scaleX = scaleY = 6.;
		x = Const.WID * .5;
		y = Const.HEI * .5;
		addChild(text);
		Game.CUR.frontlm.addChild(this, 0);
		reset();
		blendMode = BlendMode.ADD;
		alpha = .2;
		visible = false;
	}
	function createBDS() {
		bds = [];
		for(i in 0...11) {
			bds.push(Main.font.getText(Std.string(i)));
		}
	}
	public function reset() {
		timer = 10;
		updateBitmap();
	}
	public function tick() {
		timer--;
		updateBitmap();
		alpha = 1.;
		scaleX = scaleY = 8.;
		Actuate.tween(this, .3, {alpha: .2, scaleX: 6., scaleY: 6.});
	}
	public function updateBitmap() {
		text.bitmapData = bds[timer];
		text.x = -text.width * .5;
		text.y = -text.height * .5;
	}
	public function lock() {
		//visible = false;
	}
	public function unlock() {
		//visible = true;
	}
}