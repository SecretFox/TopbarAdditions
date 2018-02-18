import com.Utils.Archive;
import com.fox.Topbar.AnimaAllocation.Icon;

class com.fox.Topbar.AnimaAllocation.Main {
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