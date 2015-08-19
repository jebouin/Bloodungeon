package ;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
@:bitmap("res/jungle0.png") class JungleBD0 extends BitmapData {}
@:bitmap("res/jungle1.png") class JungleBD1 extends BitmapData {}
@:bitmap("res/jungle2.png") class JungleBD2 extends BitmapData {}
class JungleBack extends Sprite {
	var sky : Sprite;
	var stars : Array<Shape>;
	var jungle0 : Bitmap;
	var jungle1 : Bitmap;
	var jungle2 : Bitmap;
	var ground : Shape;
	var timer : Int;
	var eyeY : Float;
	var eyeX : Float;
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
		sky.y = Const.HEI * .5;
		stars = [];
		for(i in 0...3) {
			var s = new Shape();
			s.graphics.beginFill(0xA2C8C9, Math.random());
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
		ground.graphics.drawRect(0, 0, Const.WID, Const.HEI);
		ground.graphics.endFill();
		addChild(ground);
		timer = 0;
		setEye(0, 0);
	}
	public function update() {
		timer++;
		for(i in 0...stars.length) {
			stars[i].alpha = (Math.cos(timer * .2 + i / 3. * Math.PI * 2.) + 1.) * .7 + .3;
		}
		sky.rotation += .1;
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
	}
}