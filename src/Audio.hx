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
		musics.push(new Music(new RushMusic(), 1.437, 76.251));
		muteState = 3;
		mute();
	}
	public static function playMusic(id:Int) {
		if(id >= 0 && id < 5) {
			playingMusic = id;
			for(m in musics) {
				m.stop();
			}
			musics[id].play(0);
		}
	}
	public static function mute() {
		muteState++;
		if(muteState == 4) {
			muteState = 0;
		}
		switch(muteState) {
			case 0:
				muteMusic();
			case 1:
				muteSounds();
			case 2:
				unmuteMusic();
			case 3:
				unmuteSounds();
		}
	}
	static function muteMusic() {
		musicMuted = true;
		for(m in musics) {
			m.mute();
		}
		Main.announce("muted musics");
	}
	static function unmuteMusic() {
		musicMuted = false;
		for(m in musics) {
			m.unmute();
		}
		Main.announce("unmuted musics");
	}
	static function muteSounds() {
		Main.announce("muted sounds");
	}
	static function unmuteSounds() {
		Main.announce("unmuted sounds");
	}
}