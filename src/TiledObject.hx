package ;
import haxe.ds.StringMap;
class TiledObject {
	public var type : String;
	public var properties : StringMap<String>;
	public function new(xml:Xml) {
		properties = new StringMap();
		type = xml.get("type");
		for(p in xml.attributes()) {
			if(p != "type") {
				properties.set(p, xml.get(p));
			}
		}
	}
}