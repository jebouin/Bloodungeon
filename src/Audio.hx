package ;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
@:sound("res/floor0.mp3") class Floor0Music extends Sound {}
class Audio {
	public static var music : Sound;
	public static var mChan : SoundChannel;
	public static function init() {
		var music = new Floor0Music();
		mChan = music.play(0, 1<<30);
		mute();
	}
	public static function mute() {
		mChan.soundTransform = new SoundTransform(0.);
	}
	public static function unmute() {
		mChan.soundTransform = new SoundTransform(1.);
	}
}