package ;
import com.xay.util.LayerManager;
import com.xay.util.SceneManager.Scene;
import com.xay.util.Util;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.media.SoundChannel;
import flash.text.TextField;
class VoiceScene extends Scene {
	public static var CUR : VoiceScene;
	public static var pattern : BitmapData;
	var tfs : Array<TextField>;
	var strs : Array<Array<String> >;
	var cont : Sprite;
	var lm : LayerManager;
	var timer : Int;
	var textId : Int;
	var chan : SoundChannel;
	var back : Shape;
	var mat : Matrix;
	public function new() {
		CUR = this;
		super();
		Audio.stopMusics();
		Audio.stopSounds();
		chan = Audio.playSound("voices");
		lm = new LayerManager();
		Main.renderer.addChild(lm.getContainer());
		cont = new Sprite();
		cont.x = Const.WID * .5;
		cont.y = Const.HEI * .5;
		lm.addChild(cont, 0);
		if(pattern == null) {
			pattern = new BitmapData(32, 32);
		}
		back = new Shape();
		mat = new Matrix();
		mat.identity();
		cont.addChild(back);
		tfs = [];
		for(i in 0...3) {
			var tf = Util.createTextField("...", Main.xlmonoFont, null, 40);
			tf.x = -tf.width * .5;
			tf.y = -tf.height * .5 + (i-1) * Const.HEI * .3;
			cont.addChild(tf);
			tfs.push(tf);
			tf.blendMode = BlendMode.INVERT;
		}
		strs = [["i can't bear", "your stupid races", "anymore"],
				["it's time ", "for me", "to have fun"],
				["i improved", "your board", ""],
				["it now", "contains", "a bomb"],
				["you have", "10 seconds to get", "out of my dungeon"],
				["it seems a bit", "", "tough"],
				["", "huh?", ""],
				["i will be kind", "and reset the bomb", "after each room"],
				["", "and now", ""]];
		timer = 0;
		textId = 0;
		nextText();
	}
	override public function delete() {
		super.delete();
		lm.delete();
		Audio.stopSounds();
		CUR = null;
	}
	override public function update() {
		super.update();
		timer++;
		cont.rotation = Math.sin(timer * .01) * 10.;
		switch(textId) {
			case 1:
				if(chan.position > 4640) nextText();
			case 2:
				if(chan.position > 7870) nextText();
			case 3:
				if(chan.position > 10640) nextText();
			case 4:
				if(chan.position > 13390) nextText();
			case 5:
				if(chan.position > 18030) nextText();
			case 6:
				if(chan.position > 19870) nextText();
			case 7:
				if(chan.position > 20800) nextText();
			case 8:
				if(chan.position > 25870) nextText();
			case 9:
				if(chan.position > 30000) {
					delete();
					return;
				}
		}
		pattern.lock();
		var b = 255;
		var xm = Math.cos(timer * .01);
		var ym = Math.sin(timer * .01);
		for(j in 0...32) {
			for(i in 0...32) {
				b = ((Util.IABS(Std.int((i - 16)*xm))<<3) - timer) + ((Util.IABS(Std.int((j - 16)*ym))<<3) - timer);
				pattern.setPixel(i, j, (~b) + ((b) << 8) + ((b>>1) << 16));
			}
		}
		pattern.unlock();
		mat.translate(Math.cos(timer*.01), Math.sin(timer*.01));
		var g = back.graphics;
		g.clear();
		g.beginBitmapFill(pattern, mat);
		g.drawRect(-Const.WID * .65, -Const.HEI * .65, Const.WID * 1.3, Const.HEI * 1.3);
		g.endFill();
		if(Std.random(20) == 0) {
			Main.glitch();
		}
	}
	function nextText() {
		for(i in 0...3) {
			var tf = tfs[i];
			var str = strs[textId][i];
			if(str.length == 0) {
				tf.visible = false;
			} else {
				tf.visible = true;
				tf.text = str;
				tf.width = tf.textWidth * 1.04;
				tf.height = tf.textHeight * 1.2;
				tf.x = -tf.width * .5;
				tf.y = -tf.height * .5 + (i-1) * Const.HEI * .3;
			}
		}
		textId++;
	}
}