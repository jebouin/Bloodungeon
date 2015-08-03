package ;
import haxe.ds.IntMap;
import haxe.ds.StringMap;
class TiledMap {
	public var wid : Int;
	public var hei : Int;
	public var tileSize : Int;
	public var layers : StringMap<TiledLayer>;
	public var groups : StringMap<TiledGroup>;
	var tileProperties : IntMap<StringMap<String> >;
	public function new(content:String) {
		load(content);
	}
	function load(content:String) {
		layers = new StringMap();
		groups = new StringMap();
		tileProperties = new IntMap();
		var xml = Xml.parse(content).firstElement();
		wid = Std.parseInt(xml.get("width"));
		hei = Std.parseInt(xml.get("height"));
		tileSize = Std.parseInt(xml.get("tilewidth"));
		for(child in xml) {
			if(child.nodeType == Xml.Element) {
				if(child.nodeName == "layer") {
					var layer = new TiledLayer(child, tileSize);
					var lname = layer.layerName;
					if(layers.exists(lname)) {
						trace("Layer " + lname + " already exists");
						continue;
					}
					layers.set(lname, layer);
				} else if(child.nodeName == "tileset") {
					parseTileset(child);
				} else if(child.nodeName == "objectgroup") {
					var group = new TiledGroup(child);
					var gname = group.name;
					if(groups.exists(gname)) {
						trace("Group " + gname + " already exists");
						continue;
					}
					groups.set(gname, group);
				}
			}
		}
	}
	function parseTileset(xml:Xml) {
		for(child in xml) {
			if(child.nodeType == Xml.Element) {
				if(child.nodeName == "tile") {
					var id = Std.parseInt(child.get("id"));
					tileProperties.set(id, new StringMap());
					var propertiesXml = child.firstElement();
					for(pc in propertiesXml) {
						if(pc.nodeType == Xml.Element) {
							if(pc.nodeName == "property") {
								var name = pc.get("name");
								var value = pc.get("value");
								tileProperties.get(id).set(name, value);
							}
						}
					}
				}
			}
		}
	}
	public function getLayer(name:String) {
		if(!layers.exists(name)) {
			trace("Layer " + name + " not found");
		}
		return layers.get(name);
	}
	public function getGroup(name:String) {
		if(!groups.exists(name)) {
			trace("Group " + name + " not found");
		}
		return groups.get(name);
	}
	public function getTileProps(id:Int) {
		if(tileProperties.exists(id)) {
			return tileProperties.get(id);
		}
		return null;
	}
	public function getTileProp(id:Int, name:String) {
		var props = getTileProps(id);
		if(props == null) return null;
		if(props.exists(name)) {
			return props.get(name);
		}
		return null;
	}
}