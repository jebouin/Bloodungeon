package com.xay.util;

import openfl.Lib;
import openfl.display.Sprite;
import openfl.display.DisplayObject;
import openfl.display.Shape;

class LayerManager {
	var container : Sprite;
	var layers : Array<DisplayObject>;
	public function new() {
		container = new Sprite();
		layers = new Array();
		container.mouseEnabled = false;
	}
	public function delete() {
		for(l in layers) {
			if(l==null) continue;
			l.parent.removeChild(l);
		}
		container.parent.removeChild(container);
	}
	public function clear() {
		for(l in layers) {
			l.parent.removeChild(l);
		}
	}
	public function getLayer(n) {
		var layer=layers[n];
		if(layer!=null) return layer;
		layer = new Shape();
		layer.visible = false;
		container.addChildAt(layer, getBottom(n));
		layers[n] = layer;
		return layer;
	}
	public function addChild<T>(nchild:T, layer:Int) {
		var child = cast(nchild, DisplayObject);
		if(child.parent!=null) child.parent.removeChild(child);
		container.addChildAt(child, container.getChildIndex(getLayer(layer)));
	}
	public function getBottom(layer:Int) {
		while(--layer>=0) {
			var curLayer = layers[layer];
			if(curLayer!=null) {
				return container.getChildIndex(curLayer)+1;
			}
		}
		return 0;
	}
	public function getContainer() {
		return container;
	}
}