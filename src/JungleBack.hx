package ;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import haxe.Template;
import haxe.Timer;
import motion.Actuate;
import motion.easing.Cubic;
import motion.easing.Linear;
import motion.easing.Quad;
@:bitmap("res/jungle0.png") class JungleBD0 extends BitmapData {}
@:bitmap("res/jungle1.png") class JungleBD1 extends BitmapData {}
@:bitmap("res/jungle2.png") class JungleBD2 extends BitmapData {}
@:bitmap("res/entrance.png") class EntranceBD extends BitmapData {}
class JungleBack extends Sprite {
	var sky : Sprite;
	var stars : Array<Shape>;
	var jungle0 : Bitmap;
	var jungle1 : Bitmap;
	var jungle2 : Bitmap;
	var entrance : Bitmap;
	var ground : Shape;
	var timer : Int;
	var eyeY : Float;
	var eyeX : Float;
	var down : Bool;
	var started : Bool;
	public function new() {
		super();
		mouseEnabled = mouseChildren = false;
		Menu.CUR.lm.addChild(this, 0);
		sky = new Sprite();
		sky.graphics.beginFill(0x001B43);
		sky.graphics.drawRect(-Const.WID * .5 * 1.5, -Const.WID * .5 * 1.5, Const.WID * 1.5, Const.WID * 1.5);
		sky.graphics.endFill();
		addChild(sky);
		sky.x = Const.WID * .5;
		sky.y = Const.HEI * .8;
		stars = [];
		for(i in 0...3) {
			var s = new Shape();
			s.graphics.beginFill(0xA2C8C9);
			for(j in 0...1000) {
				var int = Math.random() * Math.random() * Math.random() * .9;
				var sx = (Math.random() * Const.WID - Const.WID * .5) * 1.5;
				var sy = (Math.random() * Const.WID - Const.WID * .5) * 1.5;
				s.graphics.drawCircle(sx, sy, .3 + int * .8);
			}
			s.graphics.endFill();
			sky.addChild(s);
			stars.push(s);
			s.graphics.endFill();
		}
		jungle0 = new Bitmap(new JungleBD0(0, 0));
		addChild(jungle0);
		jungle1 = new Bitmap(new JungleBD1(0, 0));
		addChild(jungle1);
		jungle2 = new Bitmap(new JungleBD2(0, 0));
		addChild(jungle2);
		ground = new Shape();
		ground.graphics.beginFill(0x001331);
		ground.graphics.drawRect(0, 0, Const.WID, 84);
		ground.graphics.endFill();
		entrance = new Bitmap(new EntranceBD(0, 0));
		addChild(entrance);
		addChild(ground);
		timer = 0;
		setEye(0, 0);
		down = false;
		started = true;
	}
	public function startTransition() {
		started = false;
		for(s in stars) {
			s.alpha = 0.;
			Actuate.tween(s, 3., {alpha: 1.}).ease(Linear.easeNone);
		}
		jungle0.y = Const.HEI + 1;
		jungle1.y = Const.HEI + 50;
		jungle2.y = Const.HEI + 100;
		Timer.delay(function() {
			Actuate.tween(jungle0, 3., {y:0}).ease(Quad.easeOut);
			Actuate.tween(jungle1, 3., {y:0}).ease(Quad.easeOut);
			Actuate.tween(jungle2, 3., {y:0}).ease(Quad.easeOut);
		}, 3000);
		Timer.delay(function() {
			started = true;
		}, 6000);
	}
	public function update() {
		timer++;
		if(started) {
			for(i in 0...stars.length) {
				stars[i].alpha = (Math.cos(timer * .1 + i / 3. * Math.PI * 2.) + 1.) * .5;
			}
		}
		sky.rotation += .06;
	}
	function setEye(x:Float, y:Float) {
		eyeY = y;
		eyeX = x;
		jungle0.y = -y * .5;
		jungle0.x = -x * .5;
		jungle1.y = -y * .7;
		jungle1.x = -x * .7;
		jungle2.y = -y;
		jungle2.x = -x;
		ground.y = Const.HEI - y - 1.;
		ground.x = -x;
		entrance.y = Const.HEI + 80 - y;
		entrance.x = -x;
	}
	public function goDown() {
		Actuate.tween(this, 2., {eyeY:Const.HEI * 1.754}).onUpdate(function() {
			setEye(0, eyeY);
		}).onComplete(function() {
			down = true;
		}).ease(Quad.easeIn);
	}
	public function goUp() {
		Actuate.tween(this, 2, {eyeY:0}).onUpdate(function() {
			setEye(0, eyeY);
		}).onComplete(function() {
			down = false;
		}).ease(Quad.easeIn);
	}
	public function goInDungeon() {
		var ty = 320;
		var tx = -60;
		var t = 1.;
		Actuate.tween(entrance, t, {x:Const.WID * .5 - 57 * 8., y:Const.HEI * .5 - 157 * 8., scaleX:8., scaleY:8.}).ease(Quad.easeOut);
	}
	public function goOutDungeon() {
		
	}
}