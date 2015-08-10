package ;
import com.xay.util.SpriteLib;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
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
				var dist = i*16;
				p.x = Math.cos(a) * dist;
				p.y = Math.sin(a) * dist;
				p.rotation = a * 180. / Math.PI;
			}
		}
	}
	override public function update() {
		super.update();
		angle += rotSpeed;
		updatePos();
	}
}