package com.xay.util;
#if openfl
import openfl.events.Event;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.media.SoundTransform;
#elseif flash
import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
#end
class XSound {
	static var ALL : Array<XSound> = new Array();
	static var muted = false;
	public var sound : Sound;
	public var channel : SoundChannel;
	public var volume : Float;
	public var transform : SoundTransform;
	public static function mute() {
		muted = true;
		for(s in ALL) {
			s.setVolume(0.);
		}
	}
	public static function unMute() {
		muted = false;
		for(s in ALL) {
			s.setVolume(s.volume);
		}
	}
	public function new(s:Sound) {
		sound = s;
		ALL.push(this);
		volume = 1.;
		transform = new SoundTransform();
	}
	public function delete() {
		ALL.remove(this);
	}
	public function play(pan=0., loops=1, offset=0., ?volume:Float) {
		if(muted) volume=0.;
		if(volume!=null) this.volume = volume;
		transform.volume = this.volume;
		transform.pan = pan;
		channel = sound.play(offset, loops, transform);
	}
	public function stop() {
		channel.stop();
	}
	public function setVolume(vol:Float) {
		volume = vol;
		updateTransform();
	}
	public function updateTransform() {
		if(channel==null) return;
		channel.soundTransform = new SoundTransform(muted?0.:volume, 0.);
	}
}