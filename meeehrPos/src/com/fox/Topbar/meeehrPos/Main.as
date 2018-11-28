import mx.utils.Delegate;
class com.fox.Topbar.meeehrPos.Main {
	public static function main(swfRoot:MovieClip):Void {
		var Mod:Main = new Main();
		swfRoot.onLoad = function () {Mod.Load()};
	}
	public function Main(){};
	public function Load(){setTimeout(Delegate.create(this, DoTheThing), 500)};
	public function DoTheThing(){
		if (_root.mainmenuwindow.LayoutHooks[100] && !_root.mainmenuwindow.LayoutHooks[101]){
			_root.mainmenuwindow.LayoutHooks[101] = OnLayOut;
			_root.mainmenuwindow.Layout();
		}
	}
	public function OnLayOut(){
		var friends = _root.mainmenuwindow.m_FriendsIconContainer;
		var width = friends.m_HitBox._width + 10;
		if (_root.mainmenuwindow.m_MailIcon.enabled) _root.mainmenuwindow.m_AgentIconContainer._x = _root.mainmenuwindow.m_AgentIconContainer._x - (width - 10);
		else _root.mainmenuwindow.m_AgentIconContainer._x = _root.mainmenuwindow.m_AgentIconContainer._x - (width - 5);
	}
}