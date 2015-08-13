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
class Music {
	public var sound : Sound;
	public var chan : SoundChannel;
	public var length : Float;
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
		if(Audio.muted) {
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
	public static var muted : Bool;
	static var musics : Array<Music>;
	static var playingMusic : Int;
	public static function init() {
		musics = [];
		musics.push(new Music(new Floor0Music(), 22.80, 45.61));
		musics.push(new Music(new Floor1Music(), 41.77, 104.345));
		mute();
	}
	public static function playMusic(id:Int) {
		if(id >= 0 && id < 2) {
			playingMusic = id;
			for(m in musics) {
				m.stop();
			}
			musics[id].play(0);
		}
	}
	public static function mute() {
		muted = true;
		for(m in musics) {
			m.mute();
		}
	}
	public static function unmute() {
		muted = false;
		for(m in musics) {
			m.unmute();
		}
	}
}