import com.GameInterface.Game.Character;
import com.Utils.Archive;
import com.fox.Utils.Common;
import flash.geom.Point;
import mx.utils.Delegate;
import com.Utils.GlobalSignal;
import com.GameInterface.DistributedValue;

class com.fox.Topbar.AnimaAllocation.Icon {
	private var m_swfRoot: MovieClip;
	private var m_AllocationIcon:MovieClip;
	private var m_Icon:MovieClip;
	private var skillHive_Window:DistributedValue;
	private var m_Character:Character

	private var m_Dps:TextField;
	private var m_Heal:TextField;
	private var m_Health:TextField;

	private var update;
	private var m_pos:Point;
	private var m_BG:Boolean;

	public function Icon(swfRoot: MovieClip) {
		m_swfRoot = swfRoot;

	}
	public function Load() {
		m_Character = Character.GetClientCharacter();
		m_Character.SignalStatChanged.Connect(updateIcon, this);
	}
	public function Unload() {
		m_Character.SignalStatChanged.Disconnect(updateIcon, this);
	}
	//Ghetto Guiedit
	private function GuiEdit(state:Boolean) {
		if (state) {
			m_AllocationIcon.onPress = Delegate.create(this,function () {
				this.m_AllocationIcon.startDrag();
			});
			m_AllocationIcon.onRelease = Delegate.create(this,function () {
				this.m_AllocationIcon.stopDrag();
			});
			m_AllocationIcon.onReleaseOutside = Delegate.create(this,function () {
				this.m_AllocationIcon.stopDrag();
			});
		} else {
			m_AllocationIcon.stopDrag();
			m_AllocationIcon.onPress = Delegate.create(this, OpenAnimaAllocation);
			m_AllocationIcon.onPressAux = Delegate.create(this, function () {
				this.m_BG = !this.m_BG;
				this.m_Icon._visible = this.m_BG;
			});
			m_AllocationIcon.onRelease = undefined;
			m_AllocationIcon.onReleaseOutside = undefined;
			UpdatePosition();
		}
	}

	public function Activate(config:Archive):Void {
		m_pos = Point(config.FindEntry("CoordPos", new Point(550, 0)));
		m_BG = Boolean(config.FindEntry("m_BG", true));
		if (!m_AllocationIcon) {
			CreateTopIcon();
		}
	}

	public function Deactivate() {
		var config:Archive = new Archive();
		config.AddEntry("CoordPos", m_pos);
		config.AddEntry("m_BG", m_BG);
		return config
	}

	private function UpdatePosition():Void {
		m_pos = Common.getOnScreen(m_AllocationIcon);
		m_AllocationIcon._x = m_pos.x;
		m_AllocationIcon._y = m_pos.y;
	}

	private function SwitchTab() {
		_root.skillhivesimple.m_Window.m_ButtonBar.clip2.onPress();
		_root.skillhivesimple.m_Window.m_ButtonBar.clip2.onRelease();
	}

	private function ChangeTab() {
		if (skillHive_Window.GetValue()) {
			if (_root.skillhivesimple.m_ContentLoaded && _root.skillhivesimple.m_Window.m_ButtonBar.clip2) {
				SwitchTab();
			} else {
				setTimeout(Delegate.create(this, ChangeTab), 50);
			}
		}
	}

	private function statsChanged() {
		clearTimeout(update);
		update = setTimeout(Delegate.create(this,updateIcon), 100);
	}

	private function updateIcon() {
		var heal:Number = m_Character.GetStat(_global.Enums.Stat.e_TriangleHealingRatio, 2);
		var health:Number = m_Character.GetStat(_global.Enums.Stat.e_TriangleHealthRatio, 2);
		var dps:Number = 100 - heal - health;

		m_Dps.text = string(dps);
		m_Health.text = string(health);
		m_Heal.text = string(heal);

		//dps
		if (dps == 0) m_Dps.text = "";
		//health
		if (health != 0) {
			if (dps != 0) m_Health._x = m_Dps._x + m_Dps._width;
			else m_Health._x = m_Icon._width+2;
		} else {
			m_Health.text = "";
			m_Health._x = m_Icon._width+2;
		}
		//healing
		if (heal != 0) {
			if (health != 0) m_Heal._x = m_Health._x + m_Health._width;
			else if (dps != 0) m_Heal._x = m_Dps._x + m_Dps._width;
			else m_Heal._x =m_Icon._width+2;
		} else {
			m_Heal.text = "";
			m_Heal._x = m_Icon._width+2;
		}
	}

	private function OpenAnimaAllocation() {
		if (!skillHive_Window.GetValue()) {
			skillHive_Window.SetValue(true);
			ChangeTab();
		} else {
			skillHive_Window.SetValue(false);
		}
	}

	public function CreateTopIcon():Void {
		skillHive_Window = DistributedValue.Create("skillhive_window");

		m_AllocationIcon = m_swfRoot.createEmptyMovieClip("TopIcon", m_swfRoot.getNextHighestDepth());
		m_Icon = m_AllocationIcon.attachMovie("src.assets.allocation.png", "Icon", m_AllocationIcon.getNextHighestDepth(),{_y:1,_xscale:65,_yscale:65,_visible:m_BG});
		var format: TextFormat = new TextFormat("src.assets.fonts.FuturaMD_BT.ttf", 12, 0xFFFFFF,true);
		m_Dps = m_AllocationIcon.createTextField("m_DPS",m_AllocationIcon.getNextHighestDepth(),m_Icon._width+2, 0, 0, 0);
		m_Health = m_AllocationIcon.createTextField("m_Health",m_AllocationIcon.getNextHighestDepth(),m_Icon._width+2, 0, 0, 0);
		m_Heal = m_AllocationIcon.createTextField("m_Heal",m_AllocationIcon.getNextHighestDepth(),m_Icon._width+2, 0, 0, 0);

		m_Dps.selectable = false;
		m_Dps.embedFonts = true;
		m_Dps.autoSize = true;
		format.color = 0xff2531;
		m_Dps.setNewTextFormat(format);
		m_Dps.setTextFormat(format);

		m_Health.selectable = false;
		m_Health.embedFonts = true;
		m_Health.autoSize = true;
		format.color = 0x1896ff
		m_Health.setNewTextFormat(format);
		m_Health.setTextFormat(format);

		m_Heal.selectable = false;
		m_Heal.embedFonts = true;
		m_Heal.autoSize = true;
		format.color = 0x16d951;
		m_Heal.setNewTextFormat(format);
		m_Heal.setTextFormat(format);

		m_AllocationIcon._x = m_pos.x;
		m_AllocationIcon._y = m_pos.y;
		updateIcon();
		GlobalSignal.SignalSetGUIEditMode.Connect(GuiEdit, this);
		GuiEdit(false);
	}
}