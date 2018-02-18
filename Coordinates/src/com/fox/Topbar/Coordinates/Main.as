import com.fox.Topbar.Coordinates.Icon;
import com.Utils.Archive;

class com.fox.Topbar.Coordinates.Main {
	private static var s_app:Icon;

	public static function main(swfRoot:MovieClip):Void {
		s_app = new Icon(swfRoot);
		swfRoot.OnModuleActivated = OnActivated;
		swfRoot.OnModuleDeactivated = OnDeactivated;
	}

	public function Main() { }

	public static function OnActivated(config: Archive):Void {
		s_app.Activate(config);
	}

	public static function OnDeactivated():Archive {
		return s_app.Deactivate();
	}
}