import com.GameInterface.Game.Character;
import com.GameInterface.Inventory;
import com.Utils.Archive;
import com.Utils.ID32;
import com.fox.Utils.Common;
import flash.geom.Point;
import mx.utils.Delegate;
import com.Utils.GlobalSignal;
import com.GameInterface.DistributedValue;

class com.fox.Topbar.InventorySpace.Icon {
	private var m_swfRoot: MovieClip;
	private var m_InvSpaceIcon:MovieClip;
	private var m_Character:Character
	private var m_InvSpaceText:TextField;
	private var m_visible:DistributedValue;
	private var m_pos:Point
	private var m_Inventory:Inventory;
	private var m_BG:Boolean;
	private var m_Icon:MovieClip;

	public function Icon(swfRoot: MovieClip) {
		m_swfRoot = swfRoot;
	}
	
	//Ghetto Guiedit
	private function GuiEdit(state):Void {
		if (!state) {
			m_InvSpaceIcon.stopDrag()
			m_InvSpaceIcon.onPress = Delegate.create(this, function () {
				if (!this.m_visible.GetValue()) {
					this.m_visible.SetValue(true);
				} else {
					this.m_visible.SetValue(false);
				}
			});
			m_InvSpaceIcon.onPressAux = Delegate.create(this, function () {
				this.m_BG = !this.m_BG;
				this.m_Icon._visible = this.m_BG;
			});
			m_InvSpaceIcon.onRelease = undefined;
			m_InvSpaceIcon.onReleaseOutside = undefined;
			UpdatePosition();
		} else{
			m_InvSpaceIcon.onPress = Delegate.create(this, function() { this.m_InvSpaceIcon.startDrag(); } );
			m_InvSpaceIcon.onRelease = Delegate.create(this, function() { this.m_InvSpaceIcon.stopDrag(); } );
			m_InvSpaceIcon.onReleaseOutside = Delegate.create(this, function() {this.m_InvSpaceIcon.stopDrag(); } );
		}
	}

	public function Activate(config:Archive) {
		m_Character = Character.GetClientCharacter();
		m_pos = Point(config.FindEntry("iconPos", new Point(750, 0)));
		m_BG = Boolean(config.FindEntry("m_BG", true));
		m_Inventory = new Inventory(new ID32(_global.Enums.InvType.e_Type_GC_BackpackContainer, ((Character.GetClientCharacter()).GetID()).GetInstance()));
		m_Inventory.SignalInventoryExpanded.Connect(updateIcon, this);
		m_Inventory.SignalItemAdded.Connect(updateIcon, this);
		m_Inventory.SignalItemChanged.Connect(updateIcon, this);
		m_Inventory.SignalItemRemoved.Connect(updateIcon, this);
		m_Character.SignalStatChanged.Connect(SlotCharacterStatChanged, this);
		if (m_swfRoot.TopIcon == undefined){
			CreateTopIcon();
		}
	}

	private function SlotCharacterStatChanged(stat:Number) {
		if (stat == _global.Enums.Stat.e_ExtraItemInventorySlots || stat == _global.Enums.Stat.e_ExpandInventory || stat == _global.Enums.Stat.e_InventoryIncreasesPurchased) {
			updateIcon();
		}
	}

	public function Deactivate():Archive {
		m_Character.SignalStatChanged.Disconnect(SlotCharacterStatChanged, this);
		m_Inventory.SignalInventoryExpanded.Disconnect(updateIcon, this);
		m_Inventory.SignalItemAdded.Disconnect(updateIcon, this);
		m_Inventory.SignalItemChanged.Disconnect(updateIcon, this);
		m_Inventory.SignalItemRemoved.Disconnect(updateIcon, this);

		var archieve:Archive = new Archive();
		archieve.AddEntry("iconPos", m_pos);
		archieve.AddEntry("m_BG", m_BG);
		return archieve
	}

	private function UpdatePosition():Void {
		m_pos = Common.getOnScreen(m_InvSpaceIcon);
		m_InvSpaceIcon._x = m_pos.x;
		m_InvSpaceIcon._y = m_pos.y;
	}

	private function update() {
		var current = _root.backpack2.CalcNumItems();
		var max = m_Inventory.GetMaxItems();
		if (!max || !current) setTimeout(Delegate.create(this, update), 50);
		if (current > max - 6) {
			m_InvSpaceText.textColor=0xFF0000
		} else if (current>max-11) {
			m_InvSpaceText.textColor=0xFFFF00
		} else {
			m_InvSpaceText.textColor=0xFFFFFF
		}
		m_InvSpaceText.text = string(current) + "/" + string(max);
	}

	private function updateIcon() {
		setTimeout(Delegate.create(this, update), 100);
	}

	private function LoadIcon(mc, rdb, size) {
		var loader:MovieClipLoader = new MovieClipLoader();
		var object = new Object();
		object.mcScale = size;
		object.visible = m_BG;
		object.onLoadInit = function () {
			mc._xscale = this.mcScale;
			mc._yscale = this.mcScale;
		};
		object.onLoadComplete = function () {
			mc._y = 2;
			mc._visible = this.visible;
		}

		loader.addListener(object);
		loader.loadClip(rdb, mc);
	}

	public function CreateTopIcon():Void {
		m_visible = DistributedValue.Create("inventory_visible");
		m_InvSpaceIcon = m_swfRoot.createEmptyMovieClip("TopIcon", m_swfRoot.getNextHighestDepth());
		m_Icon = m_InvSpaceIcon.createEmptyMovieClip("Icon", m_InvSpaceIcon.getNextHighestDepth());
		LoadIcon(m_Icon, "rdb:1000624:6698994", 16);

		var format = new TextFormat("src.assets.fonts.FuturaMD_BT.ttf", 12, 0xFFFFFF,false);
		m_InvSpaceText = m_InvSpaceIcon.createTextField("text", m_InvSpaceIcon.getNextHighestDepth(),16,0, 0, 0);
		m_InvSpaceText.autoSize = true;
		m_InvSpaceText.setTextFormat(format);
		m_InvSpaceText.setNewTextFormat(format);

		GlobalSignal.SignalSetGUIEditMode.Connect(GuiEdit, this);
		m_InvSpaceIcon._x = m_pos.x;
		m_InvSpaceIcon._y = m_pos.y;
		updateIcon();
		m_InvSpaceIcon.onPress = Delegate.create(this, function () {
			if (!this.m_visible.GetValue()) {
				this.m_visible.SetValue(true);
			} else {
				this.m_visible.SetValue(false);
			}
		});
		m_InvSpaceIcon.onPressAux = Delegate.create(this, function () {
			this.m_BG = !this.m_BG;
			this.m_Icon._visible = this.m_BG;
		});
	}
}