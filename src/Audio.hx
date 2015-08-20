package ;
import flash.display.InteractiveObject;
import flash.events.Event;
import flash.Lib;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
//music should be 160 kbps
@:sound("res/floor0.mp3") class Floor0Music extends Sound {}
@:sound("res/floor1.mp3") class Floor1Music extends Sound {}
@:sound("res/floor2.mp3") class Floor2Music extends Sound {}
@:sound("res/floor3.mp3") class Floor3Music extends Sound {}
@:sound("res/rush.mp3") class RushMusic extends Sound {}
@:sound("res/title.mp3") class TitleMusic extends Sound {}
class Music {
	public var sound : Sound;
	public var chan : SoundChannel;
	public var length : Float;
	public var pausePos : Float;
	public var introLength : Float;
	public var playing : Bool;
	public function new(snd:Sound, introLength:Float, length:Float) {
		this.sound = snd;
		this.length = length;
		this.introLength = introLength;
		playing = false;
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, update);
	}
	public function play(?pos=0) {
		playing = true;
		chan = sound.play(pos, 0);
		if(Audio.musicMuted) {
			mute();
		}
	}
	public function pause() {
		pausePos = chan.position;
		chan.stop();
	}
	public function resume() {
		chan = sound.play(pausePos);
		if(Audio.musicMuted) {
			mute();
		}
	}
	public function stop() {
		if(!playing) return;
		playing = false;
		chan.stop();
	}
	function update(_) {
		if(playing) {
			if(chan.position / 1000. > length) {
				play(Std.int(introLength * 1000.));
			}
		}
	}
	public function mute() {
		if(chan == null) return;
		chan.soundTransform = new SoundTransform(0.);
	}
	public function unmute() {
		if(chan == null) return;
		chan.soundTransform = new SoundTransform(1.);
	}
}
class Audio {
	static var muteState : Int;
	public static var musicMuted : Bool;
	static var musics : Array<Music>;
	static var playingMusic : Int;
	public static function init() {
		musics = [];
		musics.push(new Music(new Floor0Music(), 22.80, 45.61));
		musics.push(new Music(new Floor1Music(), 41.77, 104.345));
		musics.push(new Music(new Floor2Music(), 29.56, 88.605));
		musics.push(new Music(new Floor3Music(), 0, 80));
		musics.push(new Music(new RushMusic(), 5.672, 80.47));
		musics.push(new Music(new TitleMusic(), 18.02, 66));
		muteState = 3;
		mute(false);
	}
	public static function playMusic(id:Int) {
		if(id >= 0 && id < musics.length) {
			playingMusic = id;
			for(m in musics) {
				m.stop();
			}
			musics[id].play(0);
		}
	}
	public static function mute(?announce=true) {
		muteState++;
		if(muteState == 4) {
			muteState = 0;
		}
		switch(muteState) {
			case 0:
				muteMusic(announce);
			case 1:
				muteSounds(announce);
			case 2:
				unmuteMusic(announce);
			case 3:
				unmuteSounds(announce);
		}
	}
	static function muteMusic(announce:Bool) {
		musicMuted = true;
		for(m in musics) {
			m.mute();
		}
		if(announce) {
			Main.announce("muted musics");
		}
	}
	static function unmuteMusic(announce:Bool) {
		musicMuted = false;
		for(m in musics) {
			m.unmute();
		}
		if(announce) {
			Main.announce("unmuted musics");
		}
	}
	static function muteSounds(announce:Bool) {
		if(announce) {
			Main.announce("muted sounds");
		}
	}
	static function unmuteSounds(announce:Bool) {
		if(announce) {
			Main.announce("unmuted sounds");
		}
	}
	public static function onFocusOut() {
		musics[playingMusic].pause();
	}
	public static function onFocusIn() {
		musics[playingMusic].resume();
	}
}