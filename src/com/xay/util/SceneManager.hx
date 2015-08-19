package com.xay.util;
class Scene {
	public var onFocusGain : Void->Void;
	public var onFocusLoss : Void->Void;
	public function new() {
		SceneManager.add(this);
	}
	public function delete() {
		SceneManager.remove(this);
	}
	public function update() {
		
	}
}
class SceneManager {
	public static var scenes : Array<Scene>;
	public static function init() {
		scenes = new Array();
	}
	public static function update() {
		if(scenes.length<1) return;
		scenes[scenes.length-1].update();
	}
	@:allow(com.xay.util.Scene)
	static private function add(scene:Scene) {
		if(scenes.length > 0) {
			if(scenes[scenes.length-1].onFocusLoss != null) {
				scenes[scenes.length-1].onFocusLoss();
			}
		}
		scenes.push(scene);
	}
	@:allow(com.xay.util.Scene)
	static private function remove(scene:Scene) {
		scenes.remove(scene);
		if(scenes.length > 0) {
			if(scenes[scenes.length-1].onFocusGain != null) {
				scenes[scenes.length-1].onFocusGain();
			}
		}
	}
}