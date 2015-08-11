package ;
import com.xay.util.SpriteLib;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Matrix;
import haxe.Timer;
class Spinner extends Enemy {
	var nbBranches : Int;
	var size : Int;
	var rotSpeed : Float;
	var angle : Float;
	static var partBD : BitmapData;
	var parts : Array<Bitmap>;
	var partCont : Sprite;
	public function new(x:Float, y:Float, initAngle:Float, nbBranches:Int, size:Int, speed:Float) {
		super("spinnerBase", false);
		this.xx = x;
		this.yy = y;
		this.nbBranches = nbBranches;
		this.angle = initAngle;
		this.size = size;
		this.rotSpeed = speed;
		if(partBD == null) {
			partBD = new BitmapData(16, 16, true, 0x0);
			SpriteLib.copyFramePixelsFromSlice(partBD, "spinnerPart", 0, 0, 0);
		}
		partCont = new Sprite();
		parts = [];
		for(i in 0...size*nbBranches) {
			parts.push(new Bitmap(partBD));
		}
		for(p in parts) {
			partCont.addChild(p);
		}
		addChild(partCont);
	}
	function updatePos() {
		for(b in 0...nbBranches) {
			var da = Math.PI * 2. / nbBranches * b;
			var a = angle*Math.PI/180. + da;
			for(i in 0...size) {
				var p = parts[b * size + i];
				var mat = p.transform.matrix;
				var dist = i*16 + 18;
				/*p.x = Math.cos(a) * dist;
				p.y = Math.sin(a) * dist;
				p.rotation = a * 180. / Math.PI;*/
				mat.identity();
				mat.translate(-8, -8);
				mat.rotate(a);
				mat.translate(Math.cos(a) * dist, Math.sin(a) * dist);
				//mat.translate(Math.cos(a) * dist, Math.sin(a) * dist);
				p.transform.matrix = mat;
			}
		}
	}
	override public function update() {
		angle += rotSpeed;
		updatePos();
		super.update();
	}
	override public function collidesHero() {
		var hero = Game.CUR.hero;
		if(hero == null) return false;
		var dx = xx - hero.xx;
		var dy = yy - hero.yy;
		var r = 18 + size*16 + hero.cradius;
		if(dx*dx + dy*dy > r * r) {
			trace(Std.random(100));
			return false; //too far
		}
		for(p in parts) {
			var pa = p.rotation * Math.PI / 180.;
			var px = p.x + Math.cos(pa) * 16 - Math.sin(pa) * 8;
			var py = p.y + Math.sin(pa) * 16 + Math.cos(pa) * 8;
			var dx = xx + px - hero.xx;
			var dy = yy + py - hero.yy;
			var r = hero.cradius + 4;
			/*var s = new Shape();
			s.graphics.beginFill(0xFF0000);
			s.graphics.drawCircle(0, 0, 2);
			s.graphics.endFill();
			s.x = xx + px;
			s.y = yy + py;
			Game.CUR.lm.addChild(s, Const.FRONT_L);
			Timer.delay(function() {
				s.parent.removeChild(s);
			}, 300);*/
			if(dx*dx + dy*dy < r*r) {
				return true;
			}
		}
		return false;
	}
}