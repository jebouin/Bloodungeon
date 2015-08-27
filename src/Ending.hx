package ;
import com.xay.util.LayerManager;
import com.xay.util.SceneManager.Scene;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.ColorTransform;
import haxe.Timer;
import motion.Actuate;
import motion.easing.Linear;
class Ending extends Scene {
	public static var CUR : Ending;
	public var sky : Sprite;
	public var stars : Array<Shape>;
	public var lm : LayerManager;
	public var front : Shape;
	public var congrats : Bitmap;
	public var deaths : Bitmap;
	public var rip : Bitmap;
	public var thanks : Bitmap;
	public var by : Bitmap;
	var timer : Int;
	public function new(shape:Shape, nbDeaths:Int) {
		CUR = this;
		super();
		lm = new LayerManager();
		Audio.playMusic(6);
		sky = new Sprite();
		sky.graphics.beginFill(0x001B43);
		sky.graphics.drawRect(0, 0, Const.WID, Const.WID);
		sky.graphics.endFill();
		sky.mouseChildren = sky.mouseEnabled = false;
		lm.addChild(sky, 0);
		stars = [];
		for(i in 0...3) {
			var s = new Shape();
			s.graphics.beginFill(0xA2C8C9);
			for(j in 0...400) {
				var int = Math.random() * Math.random() * Math.random() * .9;
				var sx = Math.random() * Const.WID;
				var sy = Math.random() * Const.WID;
				s.graphics.drawCircle(sx, sy, .3 + int * .8);
			}
			s.graphics.endFill();
			sky.addChild(s);
			stars.push(s);
		}
		front = shape;
		lm.addChild(front, 2);
		Actuate.tween(front, 3., {alpha: 0.}).ease(Linear.easeNone).onComplete(function() {
			front.parent.removeChild(front);
		}).ease(Linear.easeNone);
		congrats = new Bitmap(Main.font.getText("congratulations"));
		congrats.scaleX = congrats.scaleY = 2;
		congrats.x = Const.WID * .5 - congrats.width * .5;
		congrats.y = Const.HEI * .3 - congrats.height * .5;
		congrats.alpha = 0;
		lm.addChild(congrats, 1);
		Timer.delay(function() {
			Actuate.tween(congrats, 2., {alpha: 1.}).ease(Linear.easeNone);
		}, 4000);
		deaths = new Bitmap(Main.font.getText("deaths: " + Std.string(nbDeaths)));
		deaths.scaleX = deaths.scaleY = 2;
		deaths.x = Const.WID * .1;
		deaths.y = Const.HEI * .5 - deaths.height * .5;
		deaths.alpha = 0;
		lm.addChild(deaths, 1);
		Timer.delay(function() {
			Actuate.tween(deaths, 2., {alpha: 1.}).ease(Linear.easeNone);
		}, 6300);
		rip = new Bitmap(Main.font.getText(nbDeaths == 0 ? "!!!" : "RIP"));
		rip.scaleX = rip.scaleY = 2.;
		rip.x = Const.WID * .9 - rip.width;
		rip.y = Const.HEI * .5 - rip.height * .5;
		rip.alpha = 0;
		lm.addChild(rip, 1);
		Timer.delay(function() {
			Actuate.tween(rip, 2., {alpha: 1.}).ease(Linear.easeNone);
		}, 9000);
		thanks = new Bitmap(Main.font.getText("thanks for playing"));
		by = new Bitmap(Main.font.getText("game by jeremy \"xaychru\" bouin"));
		thanks.x = Const.WID * .5 - thanks.width * .5;
		by.x = Const.WID * .5 - by.width * .5;
		thanks.y = Const.HEI * .8 - thanks.height * .5;
		by.y = Const.HEI * .9 - by.height * .5;
		thanks.transform.colorTransform = new ColorTransform(.9, .9, .7);
		by.transform.colorTransform = thanks.transform.colorTransform;
		thanks.alpha = 0;
		by.alpha = 0;
		lm.addChild(thanks, 1);
		lm.addChild(by, 1);
		Timer.delay(function() {
			Actuate.tween(thanks, 2., {alpha: 1.}).ease(Linear.easeNone);
			Actuate.tween(by, 2., {alpha: 1.}).ease(Linear.easeNone);
		}, 11500);
		Timer.delay(function() {
			front.transform.colorTransform = new ColorTransform(0, 0, 0);
			front.alpha = 0;
			lm.addChild(front, 2);
			front.visible = true;
			Actuate.tween(front, 4., {alpha: 1.}).onComplete(function() {
				front.parent.removeChild(front);
				Menu.creditsBefore = true;
				Menu.front = front;
				delete();
			}).ease(Linear.easeNone);
		}, 23000);
		Main.renderer.addChild(lm.getContainer(), 0);
		timer = 0;
	}
	override public function delete() {
		super.delete();
		lm.delete();
		CUR = null;
	}
	override public function update() {
		super.update();
		timer++;
		for(i in 0...stars.length) {
			stars[i].alpha = (Math.cos(timer * .1 + i / 3. * Math.PI * 2.) + 1.) * .5;
		}
	}
}