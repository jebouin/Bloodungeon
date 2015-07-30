package com.xay.util;

class Scene {
	public function new() {

	}
	public function delete() {

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
	public static function add(scene:Scene) {
		scenes.push(scene);
	}
	public static function remove(scene:Scene) {
		scene.delete();
		scenes.remove(scene);
	}
}