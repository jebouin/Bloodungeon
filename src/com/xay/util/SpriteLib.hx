package com.xay.util;
#if openfl
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.Lib;
#elseif flash
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Lib;
#end
typedef Animation = {
	wid : Int,
	hei : Int,
	anim : Array<Int>,
	frameSetName : String
};

class XSprite extends Sprite {
	public var bitmap : Bitmap;
	var curAnim : Animation;
	public var originX : Float;
	public var originY : Float;
	var centerX : Float;
	var centerY : Float;
	var frame : Int;
	var animTimer : Int;
	var animPlays : Int;
	var animName : String;
	public var playing : Bool;
	var nbPlays : Int;
	var animSet : Bool;
	public var onEndAnim : Null<Void->Void>;
	public var deleted : Bool;
	override public function new(?anim:String=null, ?nframe=0) {
		super();
		mouseChildren = mouseEnabled = false;
		bitmap = new Bitmap();
		animSet = false;
		playing = false;
		animTimer = 0;
		deleted = false;
		nbPlays = 0;
		if(anim!=null) {
			setAnimation(anim, nframe);
			playAnim(anim);
			bitmap.bitmapData = new BitmapData(curAnim.wid, curAnim.hei, true, 0x00000000);
			setFrameData();
		}
		setCenter(.5, .5);
		addChild(bitmap);
	}
	public function delete() {
		if(deleted) return;
		deleted = true;
		if(parent!=null) {
			parent.removeChild(this);
		}
		if(bitmap.bitmapData!=null) {
			bitmap.bitmapData.dispose();
		}
	}
	public function playAnim(?nAnimName=null, ?nbPlays=-1) {
		if(nAnimName==null) {
			if(!animSet) return;
			nAnimName = this.animName;
		}
		playing = true;
		animTimer = 0;
		frame = 0;
		setAnimation(nAnimName);
		this.nbPlays = nbPlays;
	}
	public function stopAnim() {
		if(!playing) return;
		playing = false;
		setFrame(0);
	}
	public function updateAnim() {
		if(!playing||!animSet) return;
		var nextFrame = (frame+1);
		if(nextFrame==curAnim.anim.length) {
			if(onEndAnim!=null) onEndAnim();
			nextFrame = 0;
			if(nbPlays>0) {
				nbPlays--;
			}
			if(nbPlays==0) {
				stopAnim();
				return;
			}
		}
		setFrame(nextFrame);
	}
	public function setAnimation(anim:String, ?frame=0) {
		animSet = true;
		animName = anim;
		this.frame = frame;
		curAnim = SpriteLib.getAnim(animName);
		setCenter(centerX, centerY);
	}
	public function getAnimation() {
		return animName;
	}
	public function setFrame(f:Int) {
		frame = f;
		setFrameData();
	}
	public function getCurFrameId() {
		return curAnim.anim[frame];
	}
	public function getFrame() {
		return frame;
	}
	function setFrameData() {
		if(!animSet) return;
		SpriteLib.copyFramePixels(bitmap.bitmapData, curAnim.frameSetName, 0, 0, curAnim.anim[frame]);
	}
	public function setCenter(xRatio:Float, yRatio:Float) {
		centerX = xRatio;
		centerY = yRatio;
		if(animSet) {
			originX = xRatio*curAnim.wid;
			originY = yRatio*curAnim.hei;
		}
		bitmap.x = -originX;
		bitmap.y = -originY;
	}
}

typedef FrameSet = {
	tilesheetOffset : Int,
	wid: Int,
	hei: Int
};

class SpriteLib {
	public static var sourceBDs : Array<BitmapData>;
	public static var currentBDid : Int;
	static var p0 : Point;
	static var animations : Map<String, Animation>;
	public static var bdSet = false;
	static var curTilesheetOffset = 0;
	static var frameSets : Map<String, FrameSet>;
	static var curFrameSet : String;
	static var frameRects : Array<Rectangle>;
	public static function init() {
		bdSet = false;
		p0 = new Point(0, 0);
		animations = new Map();
		frameSets = new Map();
		frameRects = new Array();
		sourceBDs = new Array();
		currentBDid = -1;
	}
	public static function addBD(bd:BitmapData) {
		sourceBDs.push(bd);
	}
	public static function setBD(id:Int) {
		if(id<0||id>=sourceBDs.length) return;
		currentBDid = id;
		bdSet = true;
	}
	public static function createAnim(animName:String, frameSet:String){
		if(animations.exists(animName)) {
			throw "Animation " + animName + " is already defined";
		}
		if(!frameSets.exists(frameSet)) {
			trace("FrameSet " + frameSet + " doesn't exist...");
			return;
		}
		animations[animName] = {wid: frameSets[frameSet].wid, hei: frameSets[frameSet].hei, anim: new Array(), frameSetName:frameSet};
	}
	public static function getAnim(animName:String) {
		if(animations.exists(animName)) {
			return animations[animName];
		} else {
			throw "Animation " + animName + " doesn't exist";
		}
	}
	public static function copyFramePixels(bd:BitmapData, frameSetName:String, xpos=0, ypos=0, ?frame=0) {
		bd.copyPixels(sourceBDs[currentBDid], frameRects[frameSets[frameSetName].tilesheetOffset+frame], new Point(xpos, ypos));
	}
	public static function getFrameSetWid(frameSetName:String) {
		return frameSets.get(frameSetName).wid;
	}
	public static function getFrameSetHei(frameSetName:String) {
		return frameSets.get(frameSetName).hei;
	}
	public static function useFrameSet(name:String) {
		curFrameSet = name;
	}
	public static function refreshAll() {
		
	}
	public static function sliceFrameSet(frameSetName:String, x:Int, y:Int, wid:Int, hei:Int, ?repeatX=1, ?repeatY=1) {
		if(!bdSet) {
			trace("BD not set, can't slice!");
			return;
		}
		if(frameSets.exists(frameSetName)) {
			trace("FrameSet " + frameSetName + " already exists");
			return;
		}
		var frameSet = {tilesheetOffset:curTilesheetOffset, wid:wid, hei:hei};
		frameSets[frameSetName] = frameSet;
		for(j in 0...repeatY) {
			for(i in 0...repeatX) {
				frameRects.push(new Rectangle(x+i*(wid), y+j*(hei), wid, hei));
				curTilesheetOffset++;
			}
		}
		curFrameSet = frameSetName;
	}
	public static function defineAnim(animName:String, content:String) {
		if(curFrameSet==null) {
			trace("FrameSet not defined!");
			return;
		}
		createAnim(animName, curFrameSet);
		//remove spaces and replace par so we can split the string
		content = StringTools.replace(content, " ", "");
		content = StringTools.replace(content, ")", "(");
		//parse string into frames
		var frames = new Array<Int>();
		var parts = content.split(",");
		for(part in parts) {
			var curTime=1;
			var from=0;
			var to=0;
			var backwards = false;
			if(part.indexOf("(")>0) {
				var t = Std.parseInt(part.split("(")[1]);
				if(Math.isNaN(t)) {
					trace("Invalid frame time"); return;
				}
				curTime = t;
				part = part.substr(0, part.indexOf("("));
			}
			if(part.indexOf("-")>0) {
				from = Std.parseInt(part.split("-")[0]);
				to = Std.parseInt(part.split("-")[1]);
				if(from>to) {
					backwards = true;
					from ^= to; to ^= from; from ^= to;
				}
			} else if(part.indexOf("-")<0) {
				from = to = Std.parseInt(part);
			} else {
				trace("Invalid anim definition of " + animName); return;
			}
			for(i in from...to+1) {
				for(t in 0...curTime) {
					if(backwards) frames.insert(0, i);
					else frames.push(i);
				}
			}
		}
		animations[animName].anim = frames;
	}
}