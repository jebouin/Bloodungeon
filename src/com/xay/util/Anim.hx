package com.xay.util;
class Anim {
	var sliceName : String;
	var frames : Array<Int>;
	var frame : Float;
	public var frameChanged : Bool;
	public var frameTime : Float;
	public var timer : Float;
	public var loop : Bool;
	public var playing : Bool;
	public var onEnd : Dynamic;
	public function new(sliceName:String, frames:Array<Int>, frameTime=10., loop=true) {
		this.frames = frames;
		this.frameTime = frameTime;
		this.loop = loop;
		this.sliceName = sliceName;
		frameChanged = false;
		frame = timer = 0;
		playing = true;
	}
	public function update() {
		if(playing) {
			var prevFrame = frame;
			timer++;
			while(timer >= frameTime) {
				timer -= frameTime;
				frame++;
				frameChanged = true;
			}
			if(frame >= frames.length) {
				if(loop) {
					frame %= frames.length;
				} else {
					if(onEnd != null) {
						onEnd();
					}
					playing = false;
					return;
				}
			}
		}
	}
	public function stop() {
		playing = false;
		frame = 0;
		frameChanged = true;
	}
	public function play() {
		stop();
		playing = true;
	}
	public function pause() {
		if(!playing) return;
		playing = false;
	}
	public function resume() {
		if(playing) return;
		playing = true;
	}
	public function getFrame() {
		return Std.int(frame);
	}
	public function getSliceName() {
		return sliceName;
	}
	public function getFrameRect() {
		return SpriteLib.getSliceFrameRect(sliceName, frames[Std.int(frame)]);
	}
}