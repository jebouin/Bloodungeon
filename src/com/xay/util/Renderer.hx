package com.xay.util;
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
class Renderer {
	var screen : Sprite;
	var container : Sprite;
	public var buffer : BitmapData;
	var width : Int;
	var height : Int;
	public var scale : Int;
	public function new(wid:Int, hei:Int, scale:Int) {
		width = wid;
		height = hei;
		this.scale = scale;
		screen = new Sprite();
		container = new Sprite();
		buffer = new BitmapData(width, height, false, 0xff0000);
		screen.addChild(new Bitmap(buffer, PixelSnapping.ALWAYS, false));
		screen.scaleX = screen.scaleY = scale;
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
	}
	public function setScreenPos(x:Float, y:Float) {
		screen.x = x;
		screen.y = y;
	}
	public function setScreenScale(scale:Float) {
		screen.scaleX = screen.scaleY = scale;
	}
}