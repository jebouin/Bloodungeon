package com.xay.util;
import com.xay.util.Renderer.Glitch;
import flash.geom.Point;
#if openfl
import openfl.geom.Rectangle;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Bitmap;
import openfl.display.PixelSnapping;
import openfl.utils.ByteArray;
#elseif flash
import flash.geom.Rectangle;
import flash.Lib;
import flash.display.Sprite;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Bitmap;
import flash.display.PixelSnapping;
import flash.utils.ByteArray;
#end
import motion.Actuate;
class Glitch {
	var x : Float;
	var y : Float;
	var h : Int;
	var invert : Bool;
	var rendererWid : Int;
	public var finished : Bool;
	public function new(rendererWid:Int, rendererHei:Int, time:Float, minh:Int, maxh:Int, minx:Int, maxx:Int) {
		invert = Std.random(2)==0;
		this.rendererWid = rendererWid;
		var ex = Util.randInt(minx, maxx);
		x = 0;
		h = Util.randInt(minh, maxh);
		y = Std.random(rendererHei - h);
		finished = false;
		Actuate.tween(this, time, {x:ex}).onComplete(function() {
			finished = true;
		});
	}
	public function getFillRect() {
		return new Rectangle(0, y, x, h);
	}
	public function getRect() {
		return new Rectangle(0, y, rendererWid - x, h);
	}
	public function getPoint() {
		return new Point(x, y);
	}
}
class Renderer {
	var screen : Sprite;
	var container : Sprite;
	public var buffer : BitmapData;
	var width : Int;
	var height : Int;
	public var scale : Int;
	var glitchs : Array<Glitch>;
	public function new(wid:Int, hei:Int, scale:Int) {
		width = wid;
		height = hei;
		this.scale = scale;
		screen = new Sprite();
		container = new Sprite();
		buffer = new BitmapData(width, height, false, 0xff0000);
		screen.addChild(new Bitmap(buffer, PixelSnapping.ALWAYS, false));
		screen.scaleX = screen.scaleY = scale;
		glitchs = [];
		Lib.current.stage.addChild(screen);
		update();
	}
	public function delete() {
		buffer.dispose();
	}
	public function addChild(nchild:DisplayObject, id:Int=null) {
		if(id==null) {
			container.addChild(nchild);
		} else {
			container.addChildAt(nchild, id);
		}
	}
	public function update() {
		buffer.fillRect(buffer.rect, 0x000000);
		buffer.draw(container);
		var i = 0;
		while(i < glitchs.length) {
			if(glitchs[i].finished) {
				glitchs.remove(glitchs[i]);
			} else {
				var pt = glitchs[i].getPoint();
				buffer.copyPixels(buffer, glitchs[i].getRect(), pt);
				buffer.fillRect(glitchs[i].getFillRect(), buffer.getPixel32(Std.int(pt.x), Std.int(pt.y)));
				i++;
			}
		}
	}
	public function setScreenPos(x:Float, y:Float) {
		screen.x = x;
		screen.y = y;
	}
	public function setScreenScale(scale:Float) {
		screen.scaleX = screen.scaleY = scale;
	}
	public function glitch() {
		glitchs.push(new Glitch(width, height, .1, 8, 100, 10, Std.int(width * .3)));
	}
}