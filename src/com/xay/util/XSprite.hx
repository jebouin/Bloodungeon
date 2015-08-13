package com.xay.util;
#if openfl
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
#elseif flash
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
#end
class XSprite extends Sprite {
	public var bmp : Bitmap;
	public var anim : Anim;
	public var originXRatio : Float;
	public var originYRatio : Float;
	public var deleted : Bool;
	public function new(?animName:String, ?loop:Bool) {
		super();
		bmp = new Bitmap();
		addChild(bmp);
		originXRatio = originYRatio = 0.;
		if(animName != null) {
			originXRatio = originYRatio = .5;
			setAnim(animName, loop==null?true:loop);
			anim.play();
			updateBitmap();
		}
	}
	public function delete() {
		if(deleted) return;
		if(parent != null) {
			parent.removeChild(this);
		}
		if(bmp != null) {
			if(bmp.parent != null) {
				bmp.parent.removeChild(bmp);
			}
			if(bmp.bitmapData != null) {
				bmp.bitmapData.dispose();
			}
		}
		deleted = true;
	}
	public function update() {
		if(anim != null) {
			anim.update();
			if(anim.frameChanged) {
				updateBitmap();
				anim.frameChanged = false;
			}
		}
	}
	public function updateBitmap() {
		SpriteLib.copyFramePixelsFromAnim(bmp.bitmapData, anim);
	}
	public function setAnim(name:String, loop=true) {
		var shouldAllocateNewBD = false;
		var prevSliceName = anim==null?null:anim.getSliceName();
		anim = SpriteLib.getNewAnim(name);
		anim.loop = loop;
		var nSlice = SpriteLib.slices.get(anim.getSliceName());
		var nFrameWid = nSlice.frameWid;
		var nFrameHei = nSlice.frameHei;
		if(prevSliceName != null) {
			var pSlice = SpriteLib.slices.get(prevSliceName);
			var pFrameWid = pSlice.frameWid;
			var pFrameHei = pSlice.frameHei;
			if(nFrameHei != pFrameHei || nFrameWid != pFrameWid) {
				shouldAllocateNewBD = true;
			}
		} else {
			shouldAllocateNewBD = true;
		}
		if(shouldAllocateNewBD) {
			if(bmp.bitmapData != null) {
				bmp.bitmapData.dispose();
			}
			bmp.bitmapData = new BitmapData(nFrameWid, nFrameHei, true);
			setOrigin(originXRatio, originYRatio);
		}
	}
	public function setOrigin(xRatio:Float, yRatio:Float) {
		originXRatio = xRatio;
		originYRatio = yRatio;
		bmp.x = -originXRatio * bmp.width;
		bmp.y = -originYRatio * bmp.height;
	}
	public function setOriginInPixels(ox:Float, oy:Float) {
		bmp.x = -ox;
		bmp.y = -oy;
	}
}