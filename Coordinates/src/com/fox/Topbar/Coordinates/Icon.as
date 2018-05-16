import com.GameInterface.Game.Character;
import com.Utils.Archive;
import com.fox.Utils.Common;
import flash.geom.Point;
import mx.utils.Delegate;
import com.Utils.GlobalSignal;

class com.fox.Topbar.Coordinates.Icon {
	private var m_swfRoot: MovieClip;
	private var m_Coordinates:MovieClip;
	private var m_Character:Character
	private var m_CoordinateText:TextField;
	private var m_pos:Point;
	private var updateInterval;

	public function Icon(swfRoot: MovieClip) {
		m_swfRoot = swfRoot;

	}
	public function Load() {
		m_Character = Character.GetClientCharacter();
	}
	public function Activate(config:Archive):Void {
		m_pos = Point(config.FindEntry("CoordPos", new Point(650, 0)));
		if (!m_Coordinates) {
			CreateTopIcon();
		}
		clearInterval(updateInterval);
		updateInterval = setInterval(Delegate.create(this, updateIcon), 500);
	}

	public function Deactivate() {
		var config:Archive = new Archive();
		config.AddEntry("CoordPos", m_pos);
		return config
	}

	//Ghetto Guiedit
	private function GuiEdit(state:Boolean) {
		if (state) {
			m_Coordinates.onPress = Delegate.create(this,function ():Void {
				this.m_Coordinates.startDrag();
			});
			m_Coordinates.onRelease = Delegate.create(this,function ():Void {
				this.m_Coordinates.stopDrag();
			});
			m_Coordinates.onReleaseOutside = Delegate.create(this,function ():Void {
				this.m_Coordinates.stopDrag();
			});
		} else {
			m_Coordinates.stopDrag();
			m_Coordinates.onPress = undefined;
			m_Coordinates.onRelease = undefined;
			m_Coordinates.onReleaseOutside = undefined;
			UpdatePosition();
		}
	}

	private function UpdatePosition():Void {
		m_pos = Common.getOnScreen(m_Coordinates);
		m_Coordinates._x = m_pos.x;
		m_Coordinates._y = m_pos.y;
	}
	private function updateIcon() {
		var playerpos = m_Character.GetPosition();
		m_CoordinateText.text = string(Math.round(playerpos.x)) + "," + string(Math.round(playerpos.z));
	}

	public function CreateTopIcon():Void {
		m_Coordinates = m_swfRoot.createEmptyMovieClip("TopIcon", m_swfRoot.getNextHighestDepth());
		var m_format = new TextFormat("src.assets.fonts.FuturaMD_BT.ttf", 12, 0xFFFFFF,false);
		m_CoordinateText = m_Coordinates.createTextField("text", m_Coordinates.getNextHighestDepth(), 0, 0, 0, 0);
		m_CoordinateText.autoSize = true;
		m_CoordinateText.setTextFormat(m_format);
		m_CoordinateText.setNewTextFormat(m_format);

		m_Coordinates._x = m_pos.x;
		m_Coordinates._y = m_pos.y;
		updateIcon();
		GlobalSignal.SignalSetGUIEditMode.Connect(GuiEdit, this);
	}
}