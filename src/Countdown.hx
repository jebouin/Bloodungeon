package ;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Sprite;
import flash.Lib;
import haxe.Timer;
import motion.Actuate;
class Countdown extends Sprite {
	static var bds : Array<BitmapData>;
	var text : Bitmap;
	var timer : Int;
	var frameRate : Int;
	public function new() {
		super();
		this.mouseChildren = this.mouseEnabled = false;
		if(bds == null) {
			createBDS();
		}
		text = new Bitmap();
		scaleX = scaleY = 3.;
		x = Std.int(20);
		y = Std.int(16);
		addChild(text);
		Game.CUR.frontlm.addChild(this, 0);
		blendMode = BlendMode.ADD;
		alpha = .8;
		frameRate = Std.int(Lib.current.stage.frameRate);
		reset();
		visible = false;
	}
	function createBDS() {
		bds = [];
		for(i in 0...11) {
			bds.push(Main.font.getText(Std.string(i)));
		}
	}
	public function reset() {
		timer = Std.int(10 * frameRate);
		updateBitmap();
	}
	public function update() {
		timer--;
		if(timer % frameRate == 0) {
			tick();
		}
	}
	function tick() {
		if(visible) {
			updateBitmap();
			alpha = 1.;
			scaleX = scaleY = 4.;
			Actuate.tween(this, .3, {alpha: .8, scaleX: 3., scaleY: 3.});
		}
	}
	public function updateBitmap() {
		text.bitmapData = bds[Std.int(timer / frameRate)];
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