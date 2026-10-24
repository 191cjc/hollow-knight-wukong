package viewers.container
{
   import com.bit101.components.CheckBox;
   import com.bit101.components.HBox;
   import com.bit101.components.InputText;
   import com.bit101.components.Label;
   import com.bit101.components.Panel;
   import com.bit101.components.PushButton;
   import com.bit101.components.VBox;
   import com.bit101.components.Window;
   import com.game.engine.battle.interfaces.ICollide;
   import com.game.engine.camera.Camera2;
   import com.game.engine.core.GameFrame;
   import com.game.engine.effects.Shake;
   import com.game.engine.tile.model.ObjectVO;
   import com.game.engine.tile.utils.TMXLayer;
   import com.game.engine.utils.SimpleTextLog;
   import com.game.engine.utils.Stats;
   import com.game.net.AssetItem;
   import com.game.net.AssetManager;
   import com.game.net.AssetsURL;
   import com.game.ui.KeyCode;
   import com.game.utils.Vector2D;
   import com.ywxgame.models.manager.EventManager;
   import controllers.battle.SlowPlayCmd;
   import controllers.team2.TeamHorseModelManager;
   import edit.SkillEdit;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.system.System;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import flash.utils.setTimeout;
   import models.GameData;
   import models.ai.AITree;
   import models.configs.CommonConfig;
   import models.configs.DecorConfigVO;
   import models.configs.LevelConfigVO;
   import models.constants.Const;
   import models.constants.GroupType;
   import models.constants.ManType;
   import models.managers.BattleModelManager;
   import models.managers.BehaviorManager;
   import models.managers.BuffModelManager;
   import models.managers.BuffSceneManager;
   import models.managers.GlobalData;
   import models.managers.LevelModelManager;
   import models.managers.ManResourceManager;
   import models.managers.NewGuidManager;
   import models.managers.SkillDebugModelManager;
   import models.managers.SkillModelManager;
   import models.managers.SoulStoneManager;
   import models.managers.UserModelManager;
   import models.managers.VipModelManager;
   import models.vo.BodyUserData;
   import models.vo.BuffVO;
   import models.vo.DropVO;
   import models.vo.HorseVO;
   import models.vo.KeySetVO;
   import models.vo.PetUserVO;
   import models.vo.RequestVO;
   import models.vo.RoleConfigVO;
   import models.vo.UserVO;
   import models.vo.module.ItemVoManager;
   import models.vo.module.MagicweaponVo;
   import models.vo.module.ZhouYinVo;
   import models.vo.pet.PetInfoVo;
   import modules.ApplicationFacade;
   import modules.skywars.RigidBody;
   import modules.systemset.model.SystemVo;
   import modules.task.model.TaskModelManager;
   import modules.utils.CreateComponent;
   import nape.geom.Vec2;
   import nape.phys.Body;
   import nape.phys.BodyType;
   import utils.CBTypes;
   import utils.Physics;
   import viewers.PreloadMediator;
   import viewers.component.AnimationMovieclip;
   import viewers.component.CreateMonsterTrigger;
   import viewers.component.DecorBasic;
   import viewers.component.WeatherTrigger;
   import viewers.container.layers.UILayer;
   import viewers.container.layers.UILayerMediator;
   import viewers.container.map.BackGroundContainer;
   import viewers.container.map.FrontGroundContainer;
   import viewers.container.map.Map;
   import viewers.container.map.ObjectLayerContainer;
   import viewers.container.uis.DebugWindow;
   import viewers.container.uis.DebugWindowMediator;
   import viewers.entitys.Entity;
   import viewers.entitys.XionMaoEntity;
   import viewers.entitys.horses.BaiHuEntity;
   import viewers.entitys.horses.BaiYuanEntity;
   import viewers.entitys.horses.CNMEntity;
   import viewers.entitys.horses.DTEntity;
   import viewers.entitys.horses.HorseEntity;
   import viewers.entitys.horses.HuoQiLingEntity;
   import viewers.entitys.horses.JianMaEntity;
   import viewers.entitys.horses.JiuSeLuEntity;
   import viewers.entitys.horses.KMLEntity;
   import viewers.entitys.horses.LongYuByDragonEntity;
   import viewers.entitys.horses.LongYuEntity;
   import viewers.entitys.horses.NianShouEntity;
   import viewers.entitys.horses.QZSWEntity;
   import viewers.entitys.horses.QingLong2Entity;
   import viewers.entitys.horses.QingLuanEntity;
   import viewers.entitys.horses.SenXiHorseEntity;
   import viewers.entitys.horses.WanWan2Entity;
   import viewers.entitys.horses.WanWanEntity;
   import viewers.entitys.horses.WenYuEntity;
   import viewers.entitys.horses.XSJEntity;
   import viewers.entitys.horses.XWEntity;
   import viewers.entitys.horses.XiaoLongEntity;
   import viewers.entitys.horses.XiaoLongFlyEntity;
   import viewers.entitys.horses.YangZhiEntity;
   import viewers.entitys.horses.YueTu2Entity;
   import viewers.entitys.horses.ZQEntity;
   import viewers.entitys.man.BLM2Entity;
   import viewers.entitys.man.BLMEntity;
   import viewers.entitys.man.ManEntity;
   import viewers.entitys.man.MonsterEntity;
   import viewers.entitys.man.NeZha2Entity;
   import viewers.entitys.man.NeZhaEntity;
   import viewers.entitys.man.PlayerEntity;
   import viewers.entitys.man.RoleEntity;
   import viewers.entitys.man.SkillEntity;
   import viewers.entitys.man.TS2Entity;
   import viewers.entitys.man.TSEntity;
   import viewers.entitys.man.WJ2Entity;
   import viewers.entitys.man.WJEntity;
   import viewers.entitys.man.WK2Entity;
   import viewers.entitys.man.WKEntity;
   import viewers.entitys.man.Ytu2Entity;
   import viewers.entitys.man.YtuEntity;
   import viewers.entitys.man.ZWJ2Entity;
   import viewers.entitys.man.ZWJEntity;
   import viewers.entitys.man.enemys.*;
   import viewers.entitys.man.enemys.skills.Buff9902101;
   import viewers.entitys.man.pets.P2000200;
   import viewers.entitys.man.pets.P2000300;
   import viewers.entitys.man.pets.P2000500;
   import viewers.entitys.man.pets.P2000520;
   import viewers.entitys.man.pets.P2000530;
   import viewers.entitys.man.pets.P2000600;
   import viewers.entitys.man.pets.P2000700;
   import viewers.entitys.man.pets.P2000710;
   import viewers.entitys.man.pets.P2000720;
   import viewers.entitys.man.pets.P2000800;
   import viewers.entitys.man.pets.P2000810;
   import viewers.entitys.man.pets.P2000820;
   import viewers.entitys.man.pets.P2000830;
   import viewers.entitys.man.pets.P2000900;
   import viewers.entitys.man.pets.P2000910;
   import viewers.entitys.man.pets.P2000920;
   import viewers.entitys.man.pets.P2000930;
   import viewers.entitys.man.pets.P2001000;
   import viewers.entitys.man.pets.P2001010;
   import viewers.entitys.man.pets.P2001020;
   import viewers.entitys.man.pets.P2001030;
   import viewers.entitys.man.pets.P2001100;
   import viewers.entitys.man.pets.P2001110;
   import viewers.entitys.man.pets.P2001120;
   import viewers.entitys.man.pets.P2001130;
   import viewers.entitys.man.pets.P2001200;
   import viewers.entitys.man.pets.P2001210;
   import viewers.entitys.man.pets.P2001220;
   import viewers.entitys.man.pets.P2001230;
   import viewers.entitys.man.pets.P2001320;
   import viewers.entitys.man.pets.P2001520;
   import viewers.entitys.man.pets.P2001530;
   import viewers.entitys.man.pets.P2001720;
   import viewers.entitys.man.pets.P2001800;
   import viewers.entitys.man.pets.P2001900;
   import viewers.entitys.man.pets.P2001930;
   import viewers.entitys.man.pets.P2002030;
   import viewers.entitys.man.pets.P2002060;
   import viewers.entitys.man.pets.P2011310;
   import viewers.entitys.man.pets.P2011320;
   import viewers.entitys.man.pets.P2011330;
   import viewers.entitys.man.pets.P2011910;
   import viewers.entitys.man.pets.P2011920;
   import viewers.entitys.man.pets.P2011930;
   import viewers.entitys.man.pets.P2012030;
   import viewers.entitys.man.pets.P2012130;
   import viewers.entitys.man.pets.PetEntity;
   import viewers.entitys.others.BuffEffectEntity;
   import viewers.entitys.prefabs.LookAt2;
   import viewers.entitys.prefabs.Prefab;
   import viewers.entitys.weapons.FaLuoEntity;
   import viewers.entitys.weapons.FoZhuEntity;
   import viewers.entitys.weapons.GuJianEntity;
   import viewers.entitys.weapons.JianchanEntity;
   import viewers.entitys.weapons.JinLunEntity;
   import viewers.entitys.weapons.JinPingEntity;
   import viewers.entitys.weapons.JiuYou2Entity;
   import viewers.entitys.weapons.JiuYouEntity;
   import viewers.entitys.weapons.JueEntity;
   import viewers.entitys.weapons.LingEntity;
   import viewers.entitys.weapons.LuEntity;
   import viewers.entitys.weapons.LuoyanEntity;
   import viewers.entitys.weapons.MagicWeaponEntity;
   import viewers.entitys.weapons.NachaEntity;
   import viewers.entitys.weapons.QielanEntity;
   import viewers.entitys.weapons.QingLianEntity;
   import viewers.entitys.weapons.QuanEntity;
   import viewers.entitys.weapons.RuYiEntity;
   import viewers.entitys.weapons.SiJianEntity;
   import viewers.entitys.weapons.TanwangEntity;
   import viewers.entitys.weapons.TianChuiEntity;
   import viewers.entitys.weapons.WuMingEntity;
   import viewers.entitys.weapons.XianEntity;
   import viewers.entitys.weapons.YanmieEntity;
   import viewers.entitys.weapons.YongSheng2Entity;
   import viewers.entitys.weapons.YongShengEntity;
   import viewers.entitys.weapons.YuShan2Entity;
   import viewers.entitys.weapons.YuShanEntity;
   import viewers.entitys.weapons.ZhuEntity;
   import viewers.entitys.weapons.ZhuoQuEntity;
   import viewers.entitys.weapons.ZuDIanEntity;
   import viewers.entitys.weapons.jianyis.MagicWeaponEntity2Yi;
   
   public class BattleMap extends BattleMapBase
   {
      
      public static var Ins:BattleMapBase;
      
      private var _mapAssetItem:AssetItem;
      
      protected var _bgContainer:BackGroundContainer;
      
      private var _manContainerC:ColorTransform;
      
      private var _man2ContainerC:ColorTransform;
      
      private var _manTopContainerC:ColorTransform;
      
      private var _playerBody:Body;
      
      private var _enemyVec:Vector.<ICollide>;
      
      protected var _playerVec:Vector.<RoleEntity> = new Vector.<RoleEntity>();
      
      protected var _camera:Camera2;
      
      protected var _levInfo:LevelConfigVO;
      
      protected var screenWidth:Number = 1200;
      
      protected var screenHeight:Number = 590;
      
      protected var _nowScreen:int = 1;
      
      protected var _createMonsterTriggers:Vector.<CreateMonsterTrigger>;
      
      private var _shake:Shake;
      
      private var _topWall:Body;
      
      private var _leftWall:Body;
      
      private var _rightWall:Body;
      
      private var _bgContainerC:ColorTransform;
      
      private var _maskShape:MovieClip;
      
      private var _maskShape1:MovieClip;
      
      private var _addedMask:Number = 0;
      
      protected var _isComplete:Boolean;
      
      protected var _weather:WeatherTrigger;
      
      private var _frontContainer:FrontGroundContainer = new FrontGroundContainer();
      
      private var _frontContainerC:ColorTransform;
      
      private var _frames:int = 0;
      
      protected var _lastPetUservo:UserVO;
      
      private var _monsterIndex:int = 10;
      
      protected var _teamPlayers:Dictionary = new Dictionary();
      
      private var _deactive_tip:MovieClip;
      
      protected var showCartoon:Boolean;
      
      protected var showCartoon_skip:Boolean;
      
      private var _testzs:Sprite;
      
      private var _createdPets:Array = [];
      
      private var _usedPets:Array = [];
      
      protected var _debugWin:DebugWindow;
      
      protected var _firstMonster:RoleEntity;
      
      private var isUpdateTeamHorseUser:Boolean;
      
      private var currPetEntity:MonsterEntity;
      
      protected var _test1000:Boolean;
      
      private var _upro:Window;
      
      private var _offPets:Array = [];
      
      private var lastOnOffTime:int = 0;
      
      private var lastOnTime:int = 0;
      
      private var lastOffTime:int = 0;
      
      private var _takePetSideTip:Array = [];
      
      protected var decideNotJoin:Boolean;
      
      private var _petSkillCD:Object;
      
      public function BattleMap()
      {
         super();
         Ins = this;
      }
      
      public function get camera() : Camera2
      {
         return _camera;
      }
      
      override public function get isComplete() : Boolean
      {
         return _isComplete;
      }
      
      override public function initialization() : void
      {
         super.initialization();
         _enemyVec = new Vector.<ICollide>();
         _levInfo = BattleModelManager.getIns().levelInfo;
         _levInfo.clearRole();
         screenWidth = _levInfo.screenWidth;
         screenHeight = _levInfo.height;
         BattleModelManager.getIns().nowScreen = 1;
      }
      
      override public function destroy() : void
      {
         var _loc2_:Vector2D = null;
         var _loc6_:Array = null;
         var _loc5_:int = 0;
         var _loc3_:String = null;
         var _loc4_:AssetItem = null;
         var _loc1_:RoleEntity = this._player1 || this._player2;
         if(_loc1_ && _levInfo && _levInfo.id == 6001)
         {
            _loc2_ = _loc1_.position.clone();
            _loc2_.y -= 60;
            BattleModelManager.getIns().setLuoHanYuanPlayerPos(_loc2_);
         }
         ApplicationFacade.getInstance().sendNotification("nfSkillMode",{"user":UserModelManager.getIns().playerUserVo1});
         ApplicationFacade.getInstance().sendNotification("nfSkillMode",{"user":UserModelManager.getIns().playerUserVo2});
         onSuperDestroy();
         onActive(null);
         if(_camera)
         {
            _camera.destroy();
         }
         _physic = null;
         _camera = null;
         if(_player1)
         {
            _player1 = null;
         }
         if(_player2)
         {
            _player2 = null;
         }
         _enemyVec.length = 0;
         if(this._debugWin)
         {
            this._debugWin.destroy();
         }
         this._debugWin = null;
         ApplicationFacade.getInstance().removeMediator("DebugWindowMediator");
         if(_weather)
         {
            _weather.destory();
            _weather = null;
         }
         if(this.showCartoon)
         {
            _loc6_ = this._levInfo.manhua;
            if(_loc6_ && _loc6_.length > 0)
            {
               _loc6_;
               _loc5_ = 0;
               while(_loc5_ < _loc6_.length)
               {
                  _loc3_ = AssetsURL.getMapCartoonURL(_loc6_[_loc5_]);
                  _loc4_ = AssetManager.getIns().getAsset(_loc3_);
                  if(_loc4_)
                  {
                     _loc4_.destory();
                  }
                  _loc5_++;
               }
            }
         }
         if(this._testzs)
         {
            this._testzs.parent.removeChild(this._testzs);
            this._testzs = null;
         }
         if(_mapAssetItem)
         {
            _mapAssetItem.destory();
            _mapAssetItem = null;
         }
         super.destroy();
      }
      
      protected function getGravity() : Number
      {
         return CommonConfig.gravity;
      }
      
      override protected function init() : void
      {
         _physic = new Physics(this,0,this.getGravity());
         _gameFrame = new GameFrame(stage,onEnter);
         super.init();
         loadMap();
      }
      
      protected function addEventListeners() : void
      {
         stage.addEventListener("keyDown",onKeyDown);
         stage.addEventListener("keyUp",onKeyUp);
         stage.addEventListener("activate",onActive);
         stage.addEventListener("deactivate",onDeactive);
      }
      
      override protected function removeEventListeners() : void
      {
         super.removeEventListeners();
         stage.removeEventListener("activate",onActive);
         stage.removeEventListener("deactivate",onDeactive);
      }
      
      protected function onActive(param1:Event) : void
      {
         if(_deactive_tip && _deactive_tip.parent && _deactive_tip.parent.contains(_deactive_tip))
         {
            _deactive_tip.parent.removeChild(_deactive_tip);
         }
         _deactive_tip = null;
      }
      
      protected function onDeactive(param1:Event) : void
      {
         var _loc2_:Class = null;
         if(!_deactive_tip)
         {
            _loc2_ = AssetManager.getIns().getClass("mission","deactive_tip");
            _deactive_tip = new _loc2_();
            _deactive_tip.x = 940 / 2;
            _deactive_tip.y = 590 / 2;
         }
         if(tipsprite)
         {
            tipsprite.addChild(_deactive_tip);
         }
      }
      
      override protected function onKeyDown(param1:KeyboardEvent) : void
      {
         var _loc5_:Boolean = false;
         var _loc2_:Boolean = false;
         var _loc3_:Entity = null;
         var _loc4_:KeySetVO = null;
         if(_gameFrame)
         {
            _loc5_ = _gameFrame.isPause;
         }
         if(stage && stage.focus != null || _loc5_)
         {
            return;
         }
         if(param1.keyCode == 87 && _player1 || param1.keyCode == 38 && _player1 && _player1.userVo && _player1.userVo.keyBoard2)
         {
            _loc3_ = BattleModelManager.getIns().getManInViewByRec(_player1,[_player1]);
            if(_loc3_)
            {
               _loc2_ = _loc3_.Enter(true);
            }
         }
         else if(param1.keyCode == 38 && _player2 || param1.keyCode == 87 && _player2 && _player2.userVo && _player2.userVo.keyBoard2)
         {
            _loc3_ = BattleModelManager.getIns().getManInViewByRec(_player2,[_player2]);
            if(_loc3_)
            {
               _loc2_ = _loc3_.Enter(true);
            }
         }
         if(_player1)
         {
            _loc4_ = _player1.userVo.keyBoard;
            if(_loc4_.indexOf(param1.keyCode))
            {
               _player1.handKey(param1.keyCode,1);
            }
         }
         if(_player2)
         {
            _loc4_ = _player2.userVo.keyBoard;
            if(_loc4_.indexOf(param1.keyCode))
            {
               _player2.handKey(param1.keyCode,1);
            }
         }
         if(_loc2_ && this.getNeedEnerNpcKeyUp())
         {
            if(_player1)
            {
               _player1.handKey(param1.keyCode,0);
            }
            if(_player2)
            {
               _player2.handKey(param1.keyCode,0);
            }
         }
         if(!(this is PKBattleMap || this is TownBattleMap || this is LianMengBattleMap || this is TeamBattleMap))
         {
            BattleModelManager.getIns().addKeyDown(param1.keyCode,_frames);
            BattleModelManager.getIns().checkKeyDown();
         }
         OnCheckKey_E(param1);
      }
      
      protected function getNeedEnerNpcKeyUp() : Boolean
      {
         return true;
      }
      
      protected function OnCheckKey_E(param1:KeyboardEvent) : void
      {
         var _loc4_:int = 0;
         if(_levInfo && _levInfo.getDisableKeys())
         {
            _loc4_ = 0;
            while(_loc4_ < _levInfo.getDisableKeys().length)
            {
               if(KeyCode.getKeyCode(_levInfo.getDisableKeys()[_loc4_]) == param1.keyCode)
               {
                  return;
               }
               _loc4_++;
            }
         }
         var _loc3_:Boolean = param1.keyCode == 69;
         var _loc2_:Boolean = param1.keyCode == 109 || param1.keyCode == 189;
         if(_player1 && UserModelManager.getIns().playerUserVo1.currentHorser == null)
         {
            if(_loc3_ || _player1.userVo.keyBoard2 && _loc2_)
            {
               if(UserModelManager.getIns().playerUserVo1.getCurrentUVO().mode == 1)
               {
                  ApplicationFacade.getInstance().sendNotification("nfItemMode",{"user":UserModelManager.getIns().playerUserVo1.getCurrentUVO()});
               }
               else
               {
                  ApplicationFacade.getInstance().sendNotification("nfSkillMode",{"user":UserModelManager.getIns().playerUserVo1.getCurrentUVO()});
               }
            }
         }
         if(UserModelManager.getIns().getCurretPlayerInfo().pMode == 2 && _player2 && UserModelManager.getIns().playerUserVo2.currentHorser == null)
         {
            if(_loc2_ || UserModelManager.getIns().playerUserVo2.getRootUservo().keyBoard2 && _loc3_)
            {
               if(UserModelManager.getIns().playerUserVo2.getCurrentUVO().mode == 1)
               {
                  ApplicationFacade.getInstance().sendNotification("nfItemMode",{"user":UserModelManager.getIns().playerUserVo2.getCurrentUVO()});
               }
               else
               {
                  ApplicationFacade.getInstance().sendNotification("nfSkillMode",{"user":UserModelManager.getIns().playerUserVo2.getCurrentUVO()});
               }
            }
         }
      }
      
      override protected function onKeyUp(param1:KeyboardEvent) : void
      {
         var _loc2_:Boolean = false;
         if(_gameFrame)
         {
            _loc2_ = _gameFrame.isPause;
         }
         if(_loc2_ == true)
         {
            return;
         }
         if(_player1)
         {
            _player1.handKey(param1.keyCode,0);
         }
         if(_player2)
         {
            _player2.handKey(param1.keyCode,0);
         }
         if(!(this is PKBattleMap || this is LianMengBattleMap || this is QieCuoBattleMap))
         {
            BattleModelManager.getIns().addKeyUp(param1.keyCode,_frames);
         }
      }
      
      protected function loadMap() : void
      {
         var _loc1_:String = AssetsURL.getMapURL(_levInfo.mapURL + ".swf");
         _mapAssetItem = AssetManager.getIns().getAsset(_loc1_);
         if(_levInfo.id == 1004)
         {
            if(_levInfo.night)
            {
               _loc1_ = AssetsURL.getMapURL(_levInfo.mapURL + "_night.swf");
               _mapAssetItem = AssetManager.getIns().getAsset(_loc1_);
            }
         }
         SimpleTextLog.getIns().log2("BattleMap.loadMap");
         if(!_mapAssetItem || _mapAssetItem.isRemove || !_mapAssetItem.isReady)
         {
            AssetManager.getIns().loadAsset(_loc1_,"swf",onloadmapc3);
         }
         else
         {
            createMap();
         }
      }
      
      private function onloadmapc3(... rest) : void
      {
         _mapAssetItem = rest[0];
         createMap();
      }
      
      private function on2(... rest) : void
      {
      }
      
      protected function onEnter(param1:Number) : void
      {
         try
         {
            this.onEnterFunc(param1);
         }
         catch(error:Error)
         {
         }
      }
      
      private function onEnterFunc(param1:Number) : void
      {
         var _loc3_:int = 0;
         var _loc2_:PlayerEntity = null;
         _loc3_ = 0;
         _loc2_ = null;
         _loc3_ = 0;
         _loc2_ = null;
         _loc3_ = 0;
         _loc2_ = null;
         if(isDeleted)
         {
            return;
         }
         if(!_stopStep)
         {
            _physic.step();
         }
         if(_camera)
         {
            _camera.advanceTime(param1);
         }
         if(_bgContainer)
         {
            _bgContainer.advanceTime(param1);
         }
         if(_frontContainer)
         {
            _frontContainer.advanceTime(param1);
         }
         setPlayerMinX();
         if(!_stopStep)
         {
            if(BattleModelManager.getIns().levelParam && GlobalData.getTestPetPk())
            {
               SimpleTextLog.getIns().log3("getCamp1Att()=" + BattleModelManager.getIns().getCamp1Att().length);
               SimpleTextLog.getIns().log3("getCamp2Att()=" + BattleModelManager.getIns().getCamp2Att().length);
               SimpleTextLog.getIns().log3("getCamp1()=" + BattleModelManager.getIns().getCamp1().length);
               SimpleTextLog.getIns().log3("getCamp2()=" + BattleModelManager.getIns().getCamp2().length);
               _loc3_ = 0;
               while(_loc3_ < BattleModelManager.getIns().getCamp1().length)
               {
                  _loc2_ = BattleModelManager.getIns().getCamp1()[_loc3_];
                  SimpleTextLog.getIns().log3("getCamp1",_loc3_,_loc2_.position,_loc2_.body.velocity.x,"hp=" + _loc2_.userVo.hp);
                  _loc3_++;
               }
               _loc3_ = 0;
               while(_loc3_ < BattleModelManager.getIns().getCamp2().length)
               {
                  _loc2_ = BattleModelManager.getIns().getCamp2()[_loc3_];
                  SimpleTextLog.getIns().log3("getCamp2",_loc3_,_loc2_.position,"hp=" + _loc2_.userVo.hp);
                  _loc3_++;
               }
               _loc3_ = 0;
               while(_loc3_ < BattleModelManager.getIns().getCamp1Att().length)
               {
                  _loc2_ = BattleModelManager.getIns().getCamp1Att()[_loc3_];
                  SimpleTextLog.getIns().log3("getCamp1Att",_loc3_,SkillEntity(_loc2_).effName,SkillEntity(_loc2_).skillConfigVo.id,_loc2_.position);
                  _loc3_++;
               }
               _loc3_ = 0;
               while(_loc3_ < BattleModelManager.getIns().getCamp2Att().length)
               {
                  _loc2_ = BattleModelManager.getIns().getCamp2Att()[_loc3_];
                  SimpleTextLog.getIns().log3("getCamp2Att",_loc3_,SkillEntity(_loc2_).effName,SkillEntity(_loc2_).skillConfigVo.id,_loc2_.position);
                  _loc3_++;
               }
            }
            checkCollide();
         }
         if(_maskShape && _addedMask != 0)
         {
            if(_addedMask == 1)
            {
               if(_player1 && _player1.isDie == false)
               {
                  _maskShape.x = _player1.position.x;
                  _maskShape.y = _player1.position.y - 40;
               }
               else if(UserModelManager.getIns().getCurretPlayerInfo().pMode == 2)
               {
                  if(_player2 && _player2.isDie == false)
                  {
                     _maskShape.x = _player2.position.x;
                     _maskShape.y = _player2.position.y - 40;
                  }
               }
            }
            else if(_addedMask == 2)
            {
               _maskShape.x = _player2.position.x;
               _maskShape.y = _player2.position.y - 40;
            }
            _maskShape1.x = _maskShape.x;
            _maskShape1.y = _maskShape.y;
         }
         if(!_stopStep)
         {
            BattleModelManager.getIns().advanceTime(param1);
            BuffModelManager.getIns().advanceTime(param1);
            BehaviorManager.getIns().advanceTime(param1);
            SoulStoneManager.getIns().advanceTime(param1);
            step(param1);
         }
         TeamHorseModelManager.getIns().countDownTime(this._levInfo,param1);
         TeamHorseModelManager.getIns().advanceTime(param1);
         if(_debugWin)
         {
            if(!(GameData.uid == 682337385 || GameData.uid == 1110671826 || GameData.uid == 99181269 || GameData.uid == 2277315620 || GameData.uid == 3930679497 || GameData.uid == 3743776457 || GameData.uid == 305120555))
            {
               _debugWin.destroy();
               _debugWin = null;
            }
         }
      }
      
      protected function step(param1:Number) : void
      {
         var _loc2_:int = 0;
         updateUservo(param1);
         _loc2_ = 0;
         while(_loc2_ < _enemyVec.length)
         {
            ManEntity(_enemyVec[_loc2_]).userVo.advanceTime(param1);
            _loc2_++;
         }
         _frames = _frames + 1;
         if(BattleModelManager.getIns().levelParam)
         {
            BattleModelManager.getIns().levelParam.advanceTime(param1);
         }
      }
      
      protected function updateUservo(param1:Number) : void
      {
         var _loc2_:Array = null;
         if(TeamHorseModelManager.getIns().isPlaying && this.isUpdateTeamHorseUser)
         {
            _loc2_ = TeamHorseModelManager.getIns().getMe();
            UserVO(_loc2_[0]).advanceTime(param1);
            return;
         }
         if(UserModelManager.getIns().playerUserVo1)
         {
            UserModelManager.getIns().playerUserVo1.advanceTime(param1);
         }
         if(UserModelManager.getIns().playerUserVo2)
         {
            UserModelManager.getIns().playerUserVo2.advanceTime(param1);
         }
      }
      
      private function createMap() : void
      {
         _map = new Map(_physic.space);
         _map.addEventListener("open",onMapDrawBefore);
         _map.addEventListener("complete",onMapComplete);
         _map.setAssetItem(_mapAssetItem);
         var _loc1_:String = ".tmx";
         _loc1_ = ".dat";
         var _loc2_:String = AssetsURL.getMapURL(_levInfo.mapURL + _loc1_);
         _map.load(_loc2_);
      }
      
      protected function onMapDrawBefore(param1:Event) : void
      {
         _levInfo.pmode = _levInfo.getPmode();
      }
      
      protected function onMapComplete(param1:Event) : void
      {
         var _loc9_:int = 0;
         var _loc10_:Vector2D = null;
         var _loc19_:int = 0;
         var _loc6_:TMXLayer = null;
         var _loc3_:Boolean = false;
         var _loc14_:Object = null;
         var _loc2_:UILayerMediator = ApplicationFacade.getInstance().retrieveMediator("UILayerMediator") as UILayerMediator;
         var _loc5_:UILayer = _loc2_.getViewComponent() as UILayer;
         _tipsprite = new Sprite();
         _tipsprite.name = "tipsprite";
         _loc5_.addChild(_tipsprite);
         _bgContainer = new BackGroundContainer();
         addChild(_bgContainer);
         addChild(_man2Container);
         addChild(_manContainer);
         addChild(_manTopContainer);
         addChild(_frontContainer);
         if(_map.getWeather())
         {
            _weather = _map.getWeather();
            _tipsprite.addChild(_map.getWeather().display);
         }
         _loc9_ = 0;
         while(_loc9_ < _map.layers.length)
         {
            _bgContainer.add(_map.layers[_loc9_]);
            _frontContainer.add(_map.layers[_loc9_]);
            _loc9_++;
         }
         var _loc7_:int = 940;
         var _loc15_:int = 590;
         var _loc17_:int = screenWidth;
         var _loc8_:int = screenHeight;
         if(_levInfo.getCameraViewPort())
         {
            _loc7_ = int(_levInfo.getCameraViewPort().w);
            _loc15_ = int(_levInfo.getCameraViewPort().h);
         }
         if(_levInfo.getScreenViewPort())
         {
            _loc17_ = int(_levInfo.getScreenViewPort().w);
            _loc8_ = int(_levInfo.getScreenViewPort().h);
         }
         _camera = new Camera2(this,new Rectangle(0,0,_loc7_,_loc15_),new Rectangle(0,0,_loc17_,_loc8_));
         BattleModelManager.getIns().stagePort = _camera.stagePort;
         BattleModelManager.getIns().viewPort = _camera.viewPort;
         BattleModelManager.getIns().lockStagePort = _camera.lockStagePort;
         var _loc4_:Class = _ass.getClass("mission","shapeMask");
         _maskShape = new _loc4_();
         _maskShape1 = new _loc4_();
         _maskShape.cacheAsBitmap = true;
         _maskShape1.cacheAsBitmap = true;
         _maskShape.mouseEnabled = _maskShape.mouseChildren = false;
         _maskShape1.mouseEnabled = _maskShape1.mouseChildren = false;
         _maskShape1.scaleX = _maskShape1.scaleY = 1.02;
         _map.createTerrain();
         createGrounds();
         createMonsterTrigger();
         createJITrigger();
         _createMonsterTriggers = _map.getCreateMonsterTriggers();
         _map.createItems();
         _map.getEnemys();
         createWall();
         _physic.addManFloorCollide();
         var _loc18_:ObjectVO = checkGotoScreen();
         var _loc11_:int = 0;
         if(_loc18_)
         {
            _loc11_ = int(_loc18_.properties.screen);
            _loc10_ = _loc18_.getCenter();
            _levInfo.birthPoint.x = _loc10_.x;
            _levInfo.birthPoint.y = _loc10_.y;
         }
         if(_loc11_ > 0)
         {
            _nowScreen = _loc11_;
            BattleModelManager.getIns().nowScreen = _nowScreen;
            _camera.stagePort.x = _levInfo.sceneStart[_nowScreen - 1];
            _camera.stagePort.width = _levInfo.sceneStart[_nowScreen - 1] + screenWidth;
         }
         BattleModelManager.getIns().calMonsterTotal();
         createPlayer();
         var _loc13_:Body = createEdgeWall1();
         var _loc12_:Body = createEdgeWall2();
         _camera.init(this.getBirthPoint(),_loc13_,_loc12_);
         _camera.follow(_player1,_player2);
         if(_loc11_ > 0)
         {
            _camera.inScreen(true,_levInfo.sceneStart[_nowScreen - 1]);
            _camera.viewPort.x = _levInfo.sceneStart[_nowScreen - 1];
            _camera.stagePort.x = _levInfo.sceneStart[_nowScreen - 1];
            _camera.stagePort.width = _levInfo.sceneStart[_nowScreen - 1] + screenWidth;
            updateRightWall(_camera.stagePort.width);
         }
         else
         {
            _camera.inScreen(true,0);
         }
         setPlayerMinX();
         _gameFrame.start();
         addEventListeners();
         BattleModelManager.getIns().start();
         stage.focus = null;
         NewGuidManager.isInTown = false;
         GameData.playerIsInTown = false;
         this.hideLoading();
         if(!(this is QieCuoBattleMap))
         {
            BuffSceneManager.getIns().Start(0);
         }
         if(_weather)
         {
            _weather.start();
         }
         _loc19_ = 0;
         while(_loc19_ < _map.layers.length)
         {
            _loc6_ = _map.layers[_loc19_];
            if(_loc6_.properties.hasOwnProperty("initVisible"))
            {
               if(int(_loc6_.properties.initVisible) == 0)
               {
                  _loc6_.visible = false;
               }
            }
            _loc19_++;
         }
         this.showCartoon = true;
         var _loc16_:Array = this._levInfo.manhua;
         if(_loc16_ && _loc16_.length > 0)
         {
            _loc3_ = TaskModelManager.getIns().getTaskHasPass1(_loc16_[0]);
            if(_levInfo.id == 2034 || _levInfo.id == 2054 || _levInfo.id == 2067 || _levInfo.id == 2080)
            {
               this.showCartoon = !_loc3_;
               this.showCartoon_skip = false;
            }
            else
            {
               this.showCartoon = BattleModelManager.getCartoonShow(this._levInfo.id);
               this.showCartoon_skip = true;
            }
         }
         createDebugWindow();
         if(_levInfo.id == 100002)
         {
            if(_player1)
            {
               _player1.userVo.isRun = true;
            }
            if(_player2)
            {
               _player2.userVo.isRun = true;
            }
         }
         this.isUpdateTeamHorseUser = false;
         if(this._levInfo && this._levInfo.param)
         {
            _loc14_ = JSON.parse(this._levInfo.param);
            this._levInfo.countDownTime = _loc14_.countDownTime;
            this.isUpdateTeamHorseUser = _loc14_.updateTeamHorseUser == 1;
         }
         if(_bgContainer)
         {
            _bgContainer.advanceTime(33);
         }
         EventManager.emit("event_map_complete");
         if(GlobalData.getOpenJoinBattle())
         {
            if(UserModelManager.getIns().getCurretPlayerInfo().pMode == 2)
            {
               if(BattleModelManager.getIns().levelParam && BattleModelManager.getIns().levelParam.getJoinPlayerTotal() == 1)
               {
                  try
                  {
                     BattleModelManager.getIns().levelParam.users[0].getRootUservo().setkey2();
                  }
                  catch(error:Error)
                  {
                     if(GlobalData.getIsLocal() && GameData.uid == 100)
                     {
                        throw new Error();
                     }
                  }
               }
            }
         }
      }
      
      protected function hideLoading() : void
      {
         PreloadMediator(ApplicationFacade.getInstance().retrieveMediator("PreloadMediator")).hide();
      }
      
      private function createGrounds() : void
      {
         var _loc9_:int = 0;
         var _loc5_:ObjectLayerContainer = null;
         var _loc6_:int = 0;
         var _loc3_:ObjectVO = null;
         var _loc4_:* = undefined;
         var _loc1_:String = null;
         var _loc2_:RigidBody = null;
         _loc6_ = 0;
         _loc3_ = null;
         _loc4_ = undefined;
         _loc2_ = null;
         var _loc8_:Vector.<TMXLayer> = _map.objectLayers;
         _loc9_ = 0;
         while(_loc9_ < _loc8_.length)
         {
            _loc5_ = _loc8_[_loc9_] as ObjectLayerContainer;
            if(_loc5_.name == "grounds")
            {
               _loc6_ = 0;
               while(_loc6_ < _loc5_.layerVO.objects.length)
               {
                  _loc3_ = _loc5_.layerVO.objects[_loc6_];
                  _loc4_ = _loc3_.getCenter();
                  _loc1_ = "st";
                  if(_loc3_.properties.hasOwnProperty("bodyType"))
                  {
                     _loc1_ = _loc3_.properties.bodyType;
                  }
                  _loc2_ = new RigidBody(_loc1_,_loc4_);
                  if(_loc3_.polygon_points)
                  {
                     _loc2_.addPolygon(_loc3_.polygon_points);
                  }
                  else if(_loc3_.ellipse)
                  {
                     _loc2_.addCircleCollider(_loc3_.width / 2,0,0);
                  }
                  else
                  {
                     _loc2_.addBoxCollider(0,0,_loc3_.width,_loc3_.height);
                  }
                  _loc2_.setMaterial(_loc3_.properties);
                  _loc2_.Awake();
                  if(_loc3_.type == "ground")
                  {
                     _loc2_.addCbTypes(CBTypes.groundType);
                     _loc2_.body.userData.data.group = _loc3_.type;
                     _loc2_.collisionGroup = 2048;
                  }
                  else if(_loc3_.type == "wall")
                  {
                     _loc2_.body.userData.data.group = _loc3_.type;
                     _loc2_.collisionGroup = 1024;
                     _loc2_.addCbTypes(CBTypes.wall);
                     if(_loc3_.properties.hasOwnProperty("groupType"))
                     {
                        if(_loc3_.properties.groupType == "edge")
                        {
                           _loc2_.addCbTypes(CBTypes.edgeType);
                           _loc2_.collisionGroup = 8192;
                        }
                     }
                     if(_loc3_.properties.hasOwnProperty("walkBack"))
                     {
                        if(!_loc2_.body.userData.data.data)
                        {
                           _loc2_.body.userData.data.data = {};
                        }
                        _loc2_.body.userData.data.data.walkBack = _loc3_.properties.walkBack;
                     }
                  }
                  if(_loc3_.properties.hasOwnProperty("who"))
                  {
                     if(_loc3_.properties.who == "monster")
                     {
                        _loc2_.collisionMask = 128;
                     }
                     else if(_loc3_.properties.who == "player")
                     {
                        _loc2_.collisionMask = 1 | 2;
                     }
                  }
                  if(_loc3_.properties.addPrefab)
                  {
                     if(_loc3_.properties.hasOwnProperty("active"))
                     {
                        _loc2_.active = _loc3_.properties.active;
                     }
                     _loc2_.name = _loc3_.name;
                     Prefab.add(_loc2_);
                  }
                  if(!_loc2_.body.userData.data.data)
                  {
                     _loc2_.body.userData.data.data = {};
                     for(var _loc7_:String in _loc3_.properties)
                     {
                        _loc2_.body.userData.data.data[_loc7_] = _loc3_.properties[_loc7_];
                     }
                  }
                  if(_loc3_.properties.hasOwnProperty("noBlockCampId"))
                  {
                     _loc2_.body.userData.data.data.campId = parseInt(_loc3_.properties.noBlockCampId);
                  }
                  _loc6_++;
               }
            }
            else if(_loc5_.name == "floors")
            {
               _loc6_ = 0;
               while(_loc6_ < _loc5_.layerVO.objects.length)
               {
                  _loc3_ = _loc5_.layerVO.objects[_loc6_];
                  _loc4_ = _loc3_.getCenter();
                  _loc2_ = new RigidBody("st",_loc4_);
                  if(_loc3_.polygon_points)
                  {
                     _loc2_.addPolygon(_loc3_.polygon_points);
                  }
                  else if(_loc3_.ellipse)
                  {
                     _loc2_.addCircleCollider(_loc3_.width / 2,0,0);
                  }
                  else
                  {
                     _loc2_.addBoxCollider(0,0,_loc3_.width,_loc3_.height);
                  }
                  _loc2_.setMaterial(_loc3_.properties);
                  _loc2_.Awake();
                  if(_loc3_.type == "floor")
                  {
                     _loc2_.addCbTypes(CBTypes.floorCbType);
                     _loc2_.body.userData.data.group = _loc3_.type;
                     _loc2_.collisionGroup = 256;
                  }
                  if(_loc3_.properties.hasOwnProperty("who"))
                  {
                     if(_loc3_.properties.who == "monster")
                     {
                        _loc2_.collisionMask = 128;
                     }
                     else if(_loc3_.properties.who == "player")
                     {
                        _loc2_.collisionMask = 1 | 2;
                     }
                  }
                  if(_loc3_.properties.addPrefab)
                  {
                     if(_loc3_.properties.hasOwnProperty("active"))
                     {
                        _loc2_.active = _loc3_.properties.active;
                     }
                     _loc2_.name = _loc3_.name;
                     Prefab.add(_loc2_);
                  }
                  _loc6_++;
               }
            }
            _loc9_++;
         }
      }
      
      private function checkGotoScreen() : ObjectVO
      {
         var _loc6_:int = 0;
         var _loc2_:ObjectLayerContainer = null;
         var _loc4_:int = 0;
         var _loc1_:ObjectVO = null;
         var _loc3_:int = 0;
         var _loc5_:Vector.<TMXLayer> = _map.objectLayers;
         _loc6_ = 0;
         loop0:
         while(_loc6_ < _loc5_.length)
         {
            _loc2_ = _loc5_[_loc6_] as ObjectLayerContainer;
            _loc4_ = 0;
            while(true)
            {
               if(_loc4_ >= _loc2_.layerVO.objects.length)
               {
                  _loc6_++;
                  continue loop0;
               }
               _loc1_ = _loc2_.layerVO.objects[_loc4_];
               if(_loc1_.type == "GotoScreen")
               {
                  break;
               }
               _loc4_++;
            }
            _loc3_ = int(_loc1_.properties.screen);
            return _loc1_;
         }
         return null;
      }
      
      private function createDebugWindow() : void
      {
         var pwidth:int;
         var v:VBox;
         var h:HBox;
         var c:CheckBox;
         var dp21:CheckBox;
         var dp22:CheckBox;
         var killMy:PushButton;
         var kill:PushButton;
         var replayBtn:PushButton;
         var pauseBtn:PushButton;
         var backBtn:PushButton;
         var xpBnt:PushButton;
         var skillBtn:PushButton;
         var dp241:CheckBox;
         var dp242:CheckBox;
         var dp2431:CheckBox;
         var dp243:CheckBox;
         var dp244:CheckBox;
         var addp:Panel;
         var inputtext1:InputText;
         var dp24:CheckBox;
         var inputtext2:InputText;
         var dp31:CheckBox;
         var dp32:CheckBox;
         if(GameData.uid == 682337385 || GameData.uid == 1110671826 || GameData.uid == 99181269 || GameData.uid == 2277315620 || GameData.uid == 3930679497 || GameData.uid == 3743776457 || GameData.uid == 305120555)
         {
            pwidth = 440;
            _debugWin = new DebugWindow(GameFrame.stage,940 - pwidth,0,"" + _levInfo.name + ",id=" + _levInfo.id + "," + _levInfo.classType);
            _debugWin.hasMinimizeButton = true;
            _debugWin.width = pwidth;
            _debugWin.height = 220;
            _debugWin.minimized = GameData.uid != 100;
            if(this._levInfo.id == 2088 || this._levInfo.id == 2111 || this._levInfo.id == 2110)
            {
               ApplicationFacade.getInstance().registerMediator(new DebugWindowMediator(_debugWin));
            }
            v = new VBox(_debugWin);
            h = new HBox(v);
            c = new CheckBox(h,0,4,"线条",function():void
            {
               if(c.selected)
               {
                  _physic.createDebug();
               }
               else
               {
                  _physic.removeDebug();
               }
               stage.focus = null;
            });
            if(GameData.uid == 100 && false || GameData.uid == 2002 && false)
            {
               c.selected = true;
               _physic.createDebug();
            }
            dp21 = new CheckBox(h,0,4,"log2",function():void
            {
               SimpleTextLog.Close = !dp21.selected;
               stage.focus = null;
            });
            dp21.selected = !SimpleTextLog.Close;
            dp22 = new CheckBox(h,0,4,"内存",function():void
            {
               var _loc1_:Stats = stage.getChildByName("stats") as Stats;
               if(_loc1_)
               {
                  if(dp22.selected)
                  {
                     stage.removeChild(_loc1_);
                  }
               }
               else
               {
                  _loc1_ = new Stats();
                  _loc1_.name = "stats";
                  _loc1_.x = stage.stageWidth - 100;
                  _loc1_.y = stage.stageHeight - 100;
                  stage.addChild(_loc1_);
               }
               stage.focus = null;
            });
            h = new HBox(v);
            killMy = new PushButton(h,0,0,"自杀",onTestkillMySelft);
            kill = new PushButton(h,0,0,"击败",onTestkill);
            killMy.width /= 2;
            kill.width /= 2;
            replayBtn = new PushButton(h,0,0,"重来",onReplayClick);
            replayBtn.width /= 2;
            pauseBtn = new PushButton(h,0,0,"暂停",onPauseClick);
            pauseBtn.width /= 2;
            backBtn = new PushButton(h,0,0,"退出",onBackClick);
            backBtn.width /= 2;
            backBtn = new PushButton(h,0,0,"杀4210",onKill4210Click);
            backBtn.width /= 1.5;
            backBtn = new PushButton(h,0,0,"杀4211",onKill4211Click);
            backBtn.width /= 1.5;
            h = new HBox(v);
            xpBnt = new PushButton(h,0,0,"无双",onXpClick);
            xpBnt.width /= 2;
            skillBtn = new PushButton(h,0,0,"技能",onSkillClick);
            skillBtn.width /= 2;
            skillBtn = new PushButton(h,0,0,"法宝技能",onMagicClick);
            skillBtn.width /= 2;
            skillBtn = new PushButton(h,0,0,"坐骑技能",onHorseClick);
            skillBtn.width /= 2;
            skillBtn = new PushButton(h,0,0,"宠物技能",onPetClick);
            skillBtn.width = 50;
            xpBnt = new PushButton(h,0,0,"时装技能",this.onTestSzSKill);
            xpBnt.width = 50;
            xpBnt = new PushButton(h,0,0,"咒印技能",this.onTestZySkill);
            xpBnt.width = 50;
            xpBnt = new PushButton(h,0,0,"放保护技",this.onTestProtect);
            xpBnt.width = 50;
            h = new HBox(v);
            xpBnt = new PushButton(h,0,0,"队胜利",onTeamWinClick);
            xpBnt.width /= 2;
            xpBnt = new PushButton(h,0,0,"队失败",onTeamFailClick);
            xpBnt.width /= 2;
            xpBnt = new PushButton(h,0,0,"koBoss",onTeamKoBossClick);
            xpBnt.width /= 2;
            xpBnt = new PushButton(h,0,0,"坐骑+",onHosrsePosClick);
            xpBnt.width /= 2;
            xpBnt = new PushButton(h,0,0,"下一屏",onExitRoom);
            xpBnt.width /= 2;
            xpBnt = new PushButton(h,0,0,"video",onVideo);
            xpBnt.width /= 2;
            xpBnt = new PushButton(h,0,0,"copy",onCopyClick);
            xpBnt.width /= 2;
            h = new HBox(v);
            xpBnt = new PushButton(h,0,0,"攻击",onAttClick);
            xpBnt.width /= 2;
            xpBnt = new PushButton(h,0,0,"防御",onPhydefClick);
            xpBnt.width /= 2;
            xpBnt = new PushButton(h,0,0,"回血",onReHpClick);
            xpBnt.width /= 2;
            xpBnt = new PushButton(h,0,0,"回蓝",onReMpClick);
            xpBnt.width /= 2;
            xpBnt = new PushButton(h,0,0,"失血0.5",onHitClick);
            xpBnt.width /= 2;
            xpBnt = new PushButton(h,0,0,"宠1000次",ongotoClick);
            xpBnt.width /= 2;
            xpBnt = new PushButton(h,0,0,"1p属性",on1pproClick);
            xpBnt.width /= 2;
            dp241 = new CheckBox(h,0,4,"伤害波动",function():void
            {
               SkillDebugModelManager.average = dp241.selected;
               stage.focus = null;
            });
            dp241.selected = SkillDebugModelManager.average;
            h = new HBox(v);
            dp242 = new CheckBox(h,0,4,"显示保护分",function():void
            {
               BattleModelManager.showProtect = dp242.selected;
               stage.focus = null;
            });
            dp242.selected = BattleModelManager.showProtect;
            dp2431 = new CheckBox(h,0,4,"显示碰撞",function():void
            {
               BattleModelManager.showAbHb = dp2431.selected;
               stage.focus = null;
            });
            dp2431.selected = BattleModelManager.showAbHb;
            dp243 = new CheckBox(h,0,4,"不暴击",function():void
            {
               BattleModelManager.showBaoJi = !dp243.selected;
               stage.focus = null;
            });
            dp243.selected = !BattleModelManager.showBaoJi;
            dp244 = new CheckBox(h,0,4,"显示无双值",function():void
            {
               BattleModelManager.showXPValue = dp244.selected;
               stage.focus = null;
            });
            dp244.selected = BattleModelManager.showXPValue;
            addp = new Panel(v);
            addp.width = 333;
            addp.height = 44;
            h = new HBox(addp,2,2);
            inputtext1 = new InputText(h,0,0,"输入回放码按回车");
            inputtext1.textField.addEventListener("keyDown",this.onInpuTextEnter);
            dp24 = new CheckBox(h,0,4,"log4",function():void
            {
               SimpleTextLog.Close4 = !dp24.selected;
               stage.focus = null;
            });
            dp24.selected = !SimpleTextLog.Close4;
            xpBnt = new PushButton(h,0,0,"拷贝技能cd数据",function(param1:*):void
            {
               SkillDebugModelManager.getIns().exportSkillCdData();
               if(GameData.uid == 100)
               {
                  ApplicationFacade.getInstance().sendNotification("cmdCreatePKBattle",{"pkSelf":true});
               }
            });
            xpBnt.width = 111;
            inputtext2 = new InputText(h,0,0,stage.frameRate + "");
            inputtext2.textField.addEventListener("keyDown",this.onInpuTextEnter2);
            h = new HBox(v);
            dp31 = new CheckBox(h,0,4,"只1p",function():void
            {
               ApplicationFacade.getInstance().sendNotification("CMD_JOIN_BATTLE_PLAYER",{
                  "num":1,
                  "noJoin":false
               });
               ApplicationFacade.getInstance().sendNotification("CMD_JOIN_BATTLE_PLAYER",{
                  "num":2,
                  "noJoin":dp31.selected
               });
               stage.focus = null;
            });
            dp32 = new CheckBox(h,0,4,"只2p",function():void
            {
               ApplicationFacade.getInstance().sendNotification("CMD_JOIN_BATTLE_PLAYER",{
                  "num":2,
                  "noJoin":false
               });
               ApplicationFacade.getInstance().sendNotification("CMD_JOIN_BATTLE_PLAYER",{
                  "num":1,
                  "noJoin":dp32.selected
               });
               stage.focus = null;
            });
            xpBnt = new PushButton(h,0,0,"无邪重置为第1关",function():void
            {
               var _loc1_:RequestVO = new RequestVO("scene.gmHandler.setZhuXie",{
                  "cur":8,
                  "score":8
               });
               ApplicationFacade.getInstance().sendNotification("cmdRequestServer",_loc1_);
            });
            xpBnt = new PushButton(h,0,0,"添加道具到古树背包",function():void
            {
               var _loc3_:int = 0;
               var _loc1_:RequestVO = null;
               var _loc2_:Array = [2000,2001,2002,2003,2004,2005,2006,2007];
               _loc3_ = 0;
               while(_loc3_ < _loc2_.length)
               {
                  _loc1_ = new RequestVO("scene.gmHandler.addGushuBag",{
                     "itemId":_loc2_[_loc3_],
                     "count":1
                  });
                  ApplicationFacade.getInstance().sendNotification("cmdRequestServer",_loc1_);
                  _loc3_++;
               }
            });
         }
      }
      
      private function onTestSzSKill(param1:MouseEvent) : void
      {
         var _loc2_:SkillEdit = null;
         if(this._player1 && this._player1.userVo.suitSkillId > 0)
         {
            stage.scaleMode = "noScale";
            _loc2_ = new SkillEdit();
            _loc2_.x = 600;
            _loc2_.setSzSkill(SkillModelManager.getIns().getSkillConfigVOByID(this._player1.userVo.suitSkillId));
            this._debugWin.skillEdit = _loc2_;
         }
      }
      
      private function onTestZySkill(param1:MouseEvent) : void
      {
         var _loc2_:SkillEdit = null;
         var _loc3_:Number = NaN;
         var _loc4_:ZhouYinVo = null;
         if(this._player1.userVo && this._player1.userVo.getRootUservo() && this._player1.userVo.getRootUservo().equipments && this._player1.userVo.getRootUservo().equipments.zhouYin)
         {
            stage.scaleMode = "noScale";
            _loc2_ = new SkillEdit();
            _loc2_.x = 600;
            _loc3_ = this._player1.userVo.getRootUservo().equipments.zhouYin.id;
            _loc4_ = ItemVoManager.getIns().getConfigVoById(_loc3_,"ZhouYin.xml") as ZhouYinVo;
            _loc2_.setZySkill(this._player1,SkillModelManager.getIns().getSkillConfigVOByID(_loc4_.skillId));
            this._debugWin.skillEdit = _loc2_;
         }
      }
      
      private function onBackClick(param1:MouseEvent) : void
      {
         ApplicationFacade.getInstance().sendNotification("cmdGoToTown");
      }
      
      private function onSkillClick(param1:MouseEvent) : void
      {
         stage.scaleMode = "noScale";
         var _loc2_:SkillEdit = new SkillEdit();
         _loc2_.x = 600;
         _firstMonster = null;
         _firstMonster = BattleModelManager.getIns().getManInNearViewByX2(_player1 || this._player2,[])[0];
         if(_firstMonster)
         {
            _loc2_.setMan(_firstMonster);
         }
         else
         {
            _loc2_.setMan(this._player1 || this._player2);
         }
         this._debugWin.skillEdit = _loc2_;
      }
      
      private function onTestProtect(param1:*) : void
      {
         if(_firstMonster)
         {
            if(_firstMonster.protectSkillConfigVo)
            {
               _firstMonster.createMyBuffBySkillConfigVo(_firstMonster.protectSkillConfigVo,"protectSkill");
            }
         }
      }
      
      private function onMagicClick(param1:MouseEvent) : void
      {
         var _loc3_:SkillEdit = new SkillEdit();
         var _loc2_:MagicWeaponEntity = UserModelManager.getIns().playerUserVo1.magicWeapon;
         if(_loc2_)
         {
            _loc3_.setMan(_loc2_);
            this._debugWin.skillEdit = _loc3_;
         }
      }
      
      private function onHorseClick(param1:MouseEvent) : void
      {
         var _loc2_:SkillEdit = null;
         if(HorseVO(_player1.userVo))
         {
            _loc2_ = new SkillEdit();
            _loc2_.setMan(_player1);
            this._debugWin.skillEdit = _loc2_;
            HorseVO(_player1.userVo).ridingFatigue = 0;
         }
      }
      
      private function onPetClick(param1:MouseEvent) : void
      {
         if(!this.currPetEntity)
         {
            return;
         }
         var _loc2_:SkillEdit = new SkillEdit();
         _loc2_.setMan(this.currPetEntity);
         this._debugWin.skillEdit = _loc2_;
      }
      
      private function onXpClick(param1:MouseEvent) : void
      {
         if(_player1)
         {
            _player1.userVo.xp = CommonConfig.xpMax;
         }
         if(_player2)
         {
            _player2.userVo.xp = CommonConfig.xpMax;
         }
      }
      
      private function onAttClick(param1:MouseEvent) : void
      {
         if(_player1)
         {
            _player1.userVo.atk *= 10;
         }
         if(_player2)
         {
            _player2.userVo.atk += 10000;
         }
      }
      
      private function onPauseClick(param1:MouseEvent) : void
      {
         if(!GameFrame.getCurrentFrame().isPause)
         {
            ApplicationFacade.getInstance().sendNotification("cmdPauseResumeGame",1);
         }
         else
         {
            ApplicationFacade.getInstance().sendNotification("cmdPauseResumeGame",0);
         }
      }
      
      private function onReplayClick(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:LevelConfigVO = BattleModelManager.getIns().levelInfo;
         if(_loc3_.isHide == 1)
         {
            _loc2_ = _loc3_.fromId;
            _loc3_ = LevelModelManager.getIns().getLevelByID(_loc2_);
            if(!_loc3_)
            {
               throw new Error("找不到副本=" + _loc2_);
            }
         }
         if(_loc3_.isPK())
         {
            ApplicationFacade.getInstance().sendNotification("cmdCreatePKBattle",_loc3_.id);
         }
         else if(_loc3_.isPetPk() == false)
         {
            ApplicationFacade.getInstance().sendNotification("cmdCreateBattle",_loc3_.id);
         }
      }
      
      private function onTeamWinClick(param1:MouseEvent) : void
      {
         ApplicationFacade.getInstance().sendNotification("cmdMissionComplete",{"result":1});
      }
      
      private function onTeamFailClick(param1:MouseEvent) : void
      {
         ApplicationFacade.getInstance().sendNotification("cmdMissionComplete",{"result":0});
      }
      
      private function onTeamKoBossClick(param1:MouseEvent) : void
      {
         TeamHorseModelManager.getIns().attackTeamHorseBoss(NaN,true);
      }
      
      private function onExitRoom(param1:MouseEvent) : void
      {
         goInNextScreen();
      }
      
      private function onVideo(param1:MouseEvent) : void
      {
         ApplicationFacade.getInstance().sendNotification("CMD_PLAY_VIDEO");
      }
      
      private function onCopyClick(param1:MouseEvent) : void
      {
         SimpleTextLog.getIns().copy();
      }
      
      private function onPhydefClick(param1:MouseEvent) : void
      {
         if(this._player1)
         {
            this._player1.userVo.phyDef += 99999;
            this._player1.userVo.magRes = 1;
            this._player1.userVo.protectedData.setValue("phyDef",this._player1.userVo.phyDef);
            this._player1.userVo.protectedData.setValue("magRes",this._player1.userVo.magRes);
         }
         if(this._player2)
         {
            this._player2.userVo.phyDef += 99999;
            this._player2.userVo.magRes = 1;
            this._player2.userVo.protectedData.setValue("phyDef",this._player2.userVo.phyDef);
            this._player2.userVo.protectedData.setValue("magRes",this._player2.userVo.magRes);
         }
      }
      
      private function onReHpClick(param1:MouseEvent) : void
      {
         var _loc4_:int = 0;
         var _loc2_:PetEntity = null;
         if(this._player1)
         {
            this._player1.userVo.reHP += 9999;
            this._player1.userVo.protectedData.setValue("reHP",this._player1.userVo.reHP);
         }
         if(this._player2)
         {
            this._player2.userVo.reHP += 9999;
            this._player2.userVo.protectedData.setValue("reHP",this._player2.userVo.reHP);
         }
         var _loc3_:Vector.<ICollide> = BattleModelManager.getIns().getCamp1();
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc2_ = _loc3_[_loc4_] as PetEntity;
            if(_loc2_ && _loc2_.userVo)
            {
               _loc2_.userVo.reHP += 9999;
            }
            _loc4_++;
         }
      }
      
      private function onReMpClick(param1:MouseEvent) : void
      {
         if(this._player1)
         {
            this._player1.userVo.reMP += 9999;
            this._player1.userVo.protectedData.setValue("reMP",this._player1.userVo.reMP);
         }
         if(this._player2)
         {
            this._player2.userVo.reMP += 9999;
            this._player2.userVo.protectedData.setValue("reMP",this._player2.userVo.reMP);
         }
      }
      
      private function onHitClick(param1:MouseEvent) : void
      {
         var _loc4_:int = 0;
         var _loc2_:ManEntity = null;
         if(this._player1)
         {
            this._player1.userVo.updateHP(-_player1.userVo.hpMax * 0.1,false);
         }
         if(this._player2)
         {
            this._player2.userVo.updateHP(-_player1.userVo.hpMax * 0.1,false);
         }
         var _loc3_:Vector.<ICollide> = BattleModelManager.getIns().getCamp2();
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc2_ = _loc3_[_loc4_];
            if(_loc2_ && _loc2_ is E4211 && _loc2_.userVo)
            {
               _loc2_.userVo.updateHP(-_loc2_.userVo.hpMax * 0.5,false);
            }
            BuffModelManager.getIns().createBuff([93000103],[],1,_loc2_.userVo);
            _loc4_++;
         }
         if(this.stage)
         {
            this.stage.focus = null;
         }
      }
      
      private function ongotoClick(param1:*) : void
      {
         this._test1000 = true;
         GameFrame.getCurrentFrame().SetFrameRate(10);
      }
      
      private function on1pproClick(param1:*) : void
      {
         var pos:Point;
         var m:RoleEntity;
         var strarr:Array;
         var vbox:VBox;
         var i:int;
         var l:Label;
         var e:* = param1;
         var vs:Vector.<ICollide> = BattleModelManager.getIns().getCamp1().concat();
         vs = vs.concat(BattleModelManager.getIns().getCamp2());
         var i2:int = 0;
         while(i2 < vs.length)
         {
            pos = this.globalToLocal(new Point(500 - i2 * 60,i2 * 60));
            m = vs[i2] as RoleEntity;
            if(m)
            {
               this._upro = new Window(this,pos.x,pos.y,m.userVo.name + "属性");
               this._upro.hasCloseButton = true;
               this._upro.addEventListener("close",function(param1:*):void
               {
                  param1.currentTarget.parent.removeChild(param1.currentTarget);
               });
               this._upro.hasMinimizeButton = true;
               this._upro.setSize(400,400);
               strarr = [["hp",m.userVo.hp],["hpmax",m.userVo.allhpMax],["mp",m.userVo.mp],["mpMax",m.userVo.allmpMax],["atk",m.userVo.allatk],["critical",m.userVo.allcritical],["dodge",m.userVo.alldodge],["guardian",m.userVo.allguardian],["hit",m.userVo.allhit],["lucky",m.userVo.alllucky],["magRes",m.userVo.allmagRes],["phyDef",m.userVo.allphyDef],["toughness",m.userVo.alltoughness],["reduceMagDef",m.userVo.reduceMagDef]];
               vbox = new VBox(this._upro);
               i = 0;
               while(i < strarr.length)
               {
                  l = new Label(vbox);
                  l.text = strarr[i][0] + "=" + strarr[i][1];
                  i = i + 1;
               }
            }
            i2 = i2 + 1;
         }
      }
      
      private function onInpuTextEnter(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == 13)
         {
            ApplicationFacade.getInstance().sendNotification("CMD_PLAY_VIDEO",{"code":param1.currentTarget.text});
         }
      }
      
      private function onInpuTextEnter2(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == 13)
         {
            stage.frameRate = param1.currentTarget.text;
         }
      }
      
      private function onHosrsePosClick(param1:MouseEvent) : void
      {
         if(this._player1)
         {
            this._player1.pickAddSpeed(100);
            this._player1.addRunVelocity(this._player1.getPickAddSpeed(),0);
         }
      }
      
      protected function getBirthPoint() : Point
      {
         var _loc1_:Vector2D = null;
         if(_levInfo.id == 6001)
         {
            _loc1_ = BattleModelManager.getIns().getLuoHanYuanPlayerPos();
            if(_loc1_)
            {
               return new Point(_loc1_.x,_loc1_.y);
            }
         }
         return _levInfo.birthPoint;
      }
      
      private function onTestkill(param1:MouseEvent) : void
      {
         var _loc4_:int = 0;
         var _loc2_:ManEntity = null;
         var _loc3_:Vector.<ICollide> = BattleModelManager.getIns().getCamp2();
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc2_ = _loc3_[_loc4_];
            if(_loc2_ && _loc2_ is E3392 == false && _loc2_.userVo)
            {
               _loc2_.userVo.setHP(0);
            }
            _loc4_++;
         }
         if(this.stage)
         {
            this.stage.focus = null;
         }
      }
      
      private function onKill4210Click(param1:MouseEvent) : void
      {
         var _loc4_:int = 0;
         var _loc2_:ManEntity = null;
         var _loc3_:Vector.<ICollide> = BattleModelManager.getIns().getCamp2();
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc2_ = _loc3_[_loc4_];
            if(_loc2_ && _loc2_ is E4210 && _loc2_.userVo.charID == 4210)
            {
               _loc2_.userVo.setHP(0);
            }
            _loc4_++;
         }
         if(this.stage)
         {
            this.stage.focus = null;
         }
      }
      
      private function onKill4211Click(param1:MouseEvent) : void
      {
         var _loc4_:int = 0;
         var _loc2_:ManEntity = null;
         var _loc3_:Vector.<ICollide> = BattleModelManager.getIns().getCamp2();
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc2_ = _loc3_[_loc4_];
            if(_loc2_ && _loc2_ is E4211 && _loc2_.userVo)
            {
               _loc2_.userVo.setHP(0);
            }
            _loc4_++;
         }
         if(this.stage)
         {
            this.stage.focus = null;
         }
      }
      
      private function onTestkillMySelft(param1:MouseEvent) : void
      {
         var _loc4_:int = 0;
         var _loc2_:ManEntity = null;
         var _loc3_:Vector.<ICollide> = BattleModelManager.getIns().getCamp1();
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc2_ = _loc3_[_loc4_];
            if(_loc2_ && _loc2_ is E3392 == false && _loc2_.userVo)
            {
               _loc2_.userVo.setHP(0);
            }
            _loc4_++;
         }
         this.stage.focus = null;
      }
      
      protected function createEdgeWall2() : Body
      {
         return map.createItem(new Rectangle(940,500,10,100000),GroupType.EDGE_ROLE,BodyType.KINEMATIC);
      }
      
      protected function createEdgeWall1() : Body
      {
         return map.createItem(new Rectangle(0,500,60,100000),GroupType.EDGE_ROLE,BodyType.KINEMATIC);
      }
      
      private function ttt2() : void
      {
      }
      
      private function ttt() : void
      {
         setTimeout(ttt2,2000);
         ApplicationFacade.getInstance().sendNotification("nfDecor",100306,"add");
      }
      
      protected function createMonsterTrigger() : void
      {
         var _loc8_:int = 0;
         var _loc3_:ObjectLayerContainer = null;
         var _loc5_:int = 0;
         var _loc4_:ObjectVO = null;
         var _loc2_:Rectangle = null;
         var _loc1_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Vector.<TMXLayer> = _map.objectLayers;
         _loc8_ = 0;
         while(_loc8_ < _loc7_.length)
         {
            _loc3_ = _loc7_[_loc8_] as ObjectLayerContainer;
            _loc5_ = 0;
            while(_loc5_ < _loc3_.triggers.length)
            {
               _loc4_ = _loc3_.triggers[_loc5_].properties;
               _loc2_ = new Rectangle(_loc4_.x + _loc4_.width / 2,_loc4_.y + _loc4_.height / 2,_loc4_.width,_loc4_.height);
               Entity(_loc3_.triggers[_loc5_]).setPhysicsBody(_map.createMonsterTrigger(_loc2_));
               _loc6_ = 0;
               while(_loc6_ < _levInfo.sceneStart.length)
               {
                  if(_loc4_.x < _levInfo.sceneStart[_loc6_] + screenWidth)
                  {
                     _loc1_ = _loc6_ + 1;
                     break;
                  }
                  _loc6_++;
               }
               if(!(_loc4_.properties.hasOwnProperty("npc") && _loc4_.properties.npc == "1"))
               {
                  BattleModelManager.getIns().setMonsterTrigger(_loc1_,Entity(_loc3_.triggers[_loc5_]) as CreateMonsterTrigger);
               }
               _loc5_++;
            }
            _loc8_++;
         }
      }
      
      protected function createJITrigger() : void
      {
         var _loc6_:int = 0;
         var _loc2_:ObjectLayerContainer = null;
         var _loc4_:int = 0;
         var _loc3_:ObjectVO = null;
         var _loc1_:Rectangle = null;
         var _loc5_:Vector.<TMXLayer> = _map.objectLayers;
         _loc6_ = 0;
         while(_loc6_ < _loc5_.length)
         {
            _loc2_ = _loc5_[_loc6_] as ObjectLayerContainer;
            _loc4_ = 0;
            while(_loc4_ < _loc2_.jiTriggers.length)
            {
               _loc3_ = _loc2_.jiTriggers[_loc4_].properties;
               if(!_loc3_.properties.hasOwnProperty("triggerAtScreenMonsterDead"))
               {
                  if(_loc2_.jiTriggers[_loc4_].createBodyAtInit() != false)
                  {
                     _loc1_ = new Rectangle(_loc3_.x + _loc3_.width / 2,_loc3_.y + _loc3_.height / 2,_loc3_.width,_loc3_.height);
                     Entity(_loc2_.jiTriggers[_loc4_]).setPhysicsBody(_map.createJITrigger(_loc1_));
                  }
               }
               _loc4_++;
            }
            _loc6_++;
         }
      }
      
      protected function getCreateByMap0Trigger() : Array
      {
         var _loc6_:int = 0;
         var _loc1_:ObjectLayerContainer = null;
         var _loc4_:int = 0;
         var _loc2_:ObjectVO = null;
         var _loc3_:Array = [];
         var _loc5_:Vector.<TMXLayer> = _map.objectLayers;
         _loc6_ = 0;
         while(_loc6_ < _loc5_.length)
         {
            _loc1_ = _loc5_[_loc6_] as ObjectLayerContainer;
            _loc4_ = 0;
            while(_loc4_ < _loc1_.createByMap0.length)
            {
               _loc2_ = _loc1_.createByMap0[_loc4_];
               _loc3_.push(_loc2_);
               _loc4_++;
            }
            _loc6_++;
         }
         return _loc3_;
      }
      
      protected function setPlayerMinX() : void
      {
         if(this._noUpdateWall)
         {
            return;
         }
         if(_player1)
         {
            _player1.screenMinX(_camera.stagePort.x);
         }
         if(_camera)
         {
            updateLeftWall(_camera.stagePort.x);
         }
      }
      
      protected function createWall() : void
      {
         _leftWall = _map.createScreenWall(_levInfo.sceneStart[_nowScreen - 1],10,_levInfo.height);
         BodyUserData(_leftWall.userData.data).group2 = 1024;
         _rightWall = _map.createScreenWall(_levInfo.sceneStart[_nowScreen - 1] + screenWidth,10,_levInfo.height);
         BodyUserData(_rightWall.userData.data).group2 = 1024;
         var _loc1_:Rectangle = new Rectangle(_levInfo.width / 2,-300,_levInfo.width,20);
         _topWall = _map.createItem(_loc1_,"wall",BodyType.STATIC);
         BodyUserData(_topWall.userData.data).group2 = 1024;
      }
      
      override public function atLastScreen() : Boolean
      {
         if(_nowScreen >= BattleModelManager.getIns().screenTotal)
         {
            return true;
         }
         return false;
      }
      
      override public function goInNextScreen() : void
      {
         var _loc2_:int = 0;
         var _loc1_:TMXLayer = null;
         if(_nowScreen >= BattleModelManager.getIns().screenTotal)
         {
            ApplicationFacade.getInstance().removeCommand("cmdSlowPlay");
            ApplicationFacade.getInstance().registerCommand("cmdSlowPlay",SlowPlayCmd);
            creteExitGateway();
            _isComplete = true;
            ApplicationFacade.getInstance().sendNotification("nfAllMonsterDie");
            ApplicationFacade.getInstance().sendNotification("cmdSlowPlay");
            if(_levInfo.getIsV2())
            {
               BattleModelManager.getIns().levelParam.logic.goEndtScreen();
            }
            _loc2_ = 0;
            while(_loc2_ < _map.layers.length)
            {
               _loc1_ = _map.layers[_loc2_];
               if(!(!_loc1_ || !_loc1_.properties))
               {
                  if(_loc1_.properties.hasOwnProperty("completeVisible"))
                  {
                     if(Number(_loc1_.properties.completeVisible) > 0)
                     {
                        GameFrame.juggler.delayCall(sharl,Number(_loc1_.properties.completeVisible),_loc1_);
                     }
                  }
               }
               _loc2_++;
            }
            return;
         }
         _nowScreen = _nowScreen + 1;
         BattleModelManager.getIns().nowScreen = _nowScreen;
         BattleModelManager.getIns().calMonsterTotal();
         if(LookAt2.Curr)
         {
            LookAt2.Curr.realWidth = _levInfo.sceneStart[_nowScreen - 1] + screenWidth;
         }
         _camera.stagePort.width = _levInfo.sceneStart[_nowScreen - 1] + screenWidth;
         _camera.inScreen(false,_levInfo.sceneStart[_nowScreen - 1]);
         updateRightWall(_camera.stagePort.width);
         dispatchEvent(new Event("nfGoToNextScreen"));
      }
      
      private function sharl(param1:TMXLayer) : void
      {
         var _loc3_:int = 0;
         var _loc2_:MovieClip = null;
         if(isDeleted)
         {
            return;
         }
         param1.visible = true;
         if(param1.properties.hasOwnProperty("completeVisiblePlay1"))
         {
            if(int(param1.properties.completeVisiblePlay1) == 1)
            {
               _loc3_ = 0;
               while(_loc3_ < param1.numChildren)
               {
                  _loc2_ = param1.getChildAt(_loc3_) as MovieClip;
                  if(_loc2_)
                  {
                     _loc2_.gotoAndPlay(1);
                  }
                  _loc3_++;
               }
            }
         }
      }
      
      protected function updateRightWall(param1:Number) : void
      {
         if(_rightWall && _rightWall.position.x != param1)
         {
            _rightWall.space.bodies.remove(_rightWall);
            _rightWall = _map.createScreenWall(param1 + 5,40,_levInfo.height);
            BodyUserData(_rightWall.userData.data).group2 = 1024;
         }
      }
      
      public function updateRightWall2(param1:Number) : void
      {
         if(_rightWall && _rightWall.position.x != param1)
         {
            _rightWall.space.bodies.remove(_rightWall);
            _rightWall = _map.createScreenWall(param1 + 5,40,_levInfo.height);
            BodyUserData(_rightWall.userData.data).group2 = 1024;
         }
      }
      
      protected function updateLeftWall(param1:Number) : void
      {
         if(_leftWall && _leftWall.position.x != param1)
         {
            Vector2D.disposeVec2(_leftWall.position);
            _leftWall.space.bodies.remove(_leftWall);
            _leftWall = _map.createScreenWall(param1,10,_levInfo.height);
            BodyUserData(_leftWall.userData.data).group2 = 1024;
         }
      }
      
      override public function createMonster(param1:UserVO, param2:Vector2D, param3:int, param4:Entity, param5:int = 1, param6:Object = null) : MonsterEntity
      {
         var _loc13_:RoleEntity = null;
         var _loc10_:Class = null;
         var _loc21_:int = 0;
         var _loc18_:AITree = null;
         var _loc8_:Object = null;
         var _loc16_:Number = NaN;
         var _loc11_:TMXLayer = null;
         var _loc17_:int = 0;
         E3004;
         E3005;
         E3007;
         E3012;
         E3013;
         E3020;
         E3021;
         E3027;
         E3030;
         E3033;
         E3034;
         E3048;
         E3028;
         E3049;
         E3029;
         E3035;
         E3052;
         E3042;
         E3056;
         E3037;
         E3040;
         E3041;
         E3038;
         E3057;
         E3062;
         E3063;
         E3058;
         E3069;
         E3065;
         E3070;
         E3071;
         E3076;
         E3077;
         E3078;
         E3080;
         E3081;
         E3082;
         E3091;
         E3092;
         E400201;
         E3109;
         E3111;
         E400501;
         E400701;
         E3110;
         E3113;
         E3112;
         E3116;
         E3118;
         E50003;
         E50004;
         E50005;
         E50012;
         E50011;
         E50002;
         E60011;
         E50017;
         E50018;
         E50019;
         E3117;
         E3120;
         E3123;
         E3124;
         E3125;
         E3121;
         E3128;
         E3127;
         E3133;
         E3135;
         E3136;
         E500101;
         E500201;
         E500301;
         E3154;
         E3156;
         E3155;
         E3157;
         E3158;
         E3161;
         E3168;
         E50025;
         E70001;
         E2000101;
         E3179;
         E50027;
         E3181;
         E3182;
         P2000200;
         E3184;
         E50028;
         E3189;
         E3190;
         E3191;
         E3192;
         E3200;
         E3202;
         E3203;
         E3204;
         E3210;
         E3216;
         E3223;
         E3225;
         E3224;
         E3222;
         E3227;
         P2000300;
         P2001320;
         E70002;
         E3267;
         E3269;
         E3257;
         E3258;
         E3271;
         E3270;
         E3272;
         E3277;
         E3278;
         E3280;
         E3279;
         E3300;
         E3301;
         E3303;
         E3304;
         E3305;
         E3302;
         E80130;
         E3307;
         E3309;
         E3310;
         E3311;
         E3313;
         E3312;
         E3323;
         E3318;
         E3319;
         E3324;
         E3325;
         E3328;
         E3329;
         E600501;
         E600101;
         E600401;
         E3336;
         E600301;
         E3337;
         E600601;
         E600201;
         E3335;
         E3338;
         E3339;
         E3343;
         E3345;
         E3346;
         E3347;
         P2000500;
         E3349;
         P2000520;
         P2000530;
         P2000600;
         E70007;
         E70008;
         E3352;
         E800101;
         E3353;
         E3354;
         E3357;
         E3361;
         E3370;
         E3371;
         E3372;
         E3373;
         E3376;
         E3649;
         E3381;
         E3382;
         E3383;
         E3384;
         E3385;
         E3392;
         E3390;
         E3391;
         E3389;
         E3362;
         E3359;
         P2001520;
         E3395;
         E3393;
         E3394;
         E3402;
         E3401;
         E3400;
         E3407;
         E3409;
         E3410;
         E3414;
         E3415;
         E3416;
         E3417;
         E3418;
         E3419;
         E3420;
         E3421;
         E3422;
         E3423;
         E3429;
         E3430;
         E3431;
         E3471;
         E3473;
         E3474;
         E3458;
         E3459;
         E3475;
         E3476;
         E3477;
         E3478;
         E3479;
         E3480;
         E3481;
         E3482;
         E3483;
         E3487;
         E3488;
         E3489;
         E3490;
         E60014;
         E3493;
         E3496;
         E3497;
         E3499;
         E3500;
         E3501;
         E3506;
         E3507;
         E3508;
         E3509;
         E3510;
         E3528;
         E3529;
         E3530;
         E3531;
         E3532;
         P2001530;
         E3539;
         E3541;
         E3542;
         E3543;
         E3544;
         P2000700;
         P2000710;
         P2000720;
         P2001720;
         E3546;
         E3547;
         E3549;
         SuoyungeABattleMap;
         E3556;
         P2011930;
         P2011910;
         P2011920;
         P2001900;
         P2001930;
         P2002030;
         E4179;
         P2002060;
         E3557;
         E3558;
         E3559;
         E3560;
         E3562;
         E3563;
         E3564;
         E3566;
         E3571;
         E3575;
         E3576;
         E3577;
         E3578;
         E90083;
         E90084;
         E90085;
         E90086;
         E3581;
         E3583;
         E3600;
         E3612;
         E3613;
         E3615;
         E3616;
         MushanshangBossBattleMap;
         E3621;
         E3628;
         E3630;
         E3631;
         E3632;
         E3633;
         E3789;
         E3794;
         E3791;
         E3793;
         E3847;
         E3851;
         E3856;
         E3858;
         E3861;
         E3862;
         E3865;
         E3625;
         E3626;
         E3627;
         E3620;
         E90101;
         E70009;
         E70010;
         E3652;
         E3654;
         E3656;
         E3657;
         E3658;
         E3659;
         E3660;
         E3666;
         E3667;
         E3757;
         E3868;
         E3873;
         E3871;
         E4059;
         E22;
         E4062;
         E4061;
         E4089;
         E4093;
         E4082;
         E4060;
         E4067;
         E4098;
         E4106;
         E4104;
         E4105;
         E4107;
         E4109;
         E4110;
         E4111;
         E4112;
         E4113;
         E4117;
         E4118;
         E4119;
         E4120;
         E4121;
         E4116;
         E4125;
         E4126;
         E4150;
         E4175;
         E4176;
         E4178;
         P2000810;
         P2000820;
         P2000830;
         P2000800;
         P2000910;
         P2000920;
         P2000900;
         P2000930;
         P2001130;
         P2011310;
         P2011320;
         P2012030;
         P2012130;
         P2001200;
         P2001210;
         P2001220;
         P2001230;
         E3690;
         E3691;
         E3692;
         E3697;
         E3698;
         E3699;
         E3703;
         E3704;
         E3765;
         E3766;
         E3848;
         E3850;
         P2001110;
         P2001120;
         P2001100;
         P2001800;
         P2001000;
         P2001010;
         P2001020;
         P2001030;
         E3672;
         E3670;
         E3671;
         E3668;
         E3675;
         E3676;
         E3679;
         E3678;
         E3681;
         E3684;
         P2011330;
         E3710;
         E3711;
         E3712;
         E3713;
         E3728;
         E3729;
         E3738;
         E3761;
         E3783;
         E3784;
         E3785;
         E3788;
         E3802;
         E3809;
         E3816;
         E3821;
         E3822;
         E3820;
         E3823;
         E3838;
         E3839;
         E3840;
         E3878;
         E3879;
         E3875;
         E3876;
         E3877;
         E3880;
         E3882;
         E3887;
         E3885;
         E3886;
         E3881;
         E3893;
         E3894;
         E3896;
         E3895;
         E3889;
         E3888;
         E3890;
         E3891;
         E3902;
         E3903;
         E4033;
         E4040;
         E4041;
         E4042;
         E4099;
         E4046;
         E4036;
         E4044;
         E4045;
         E4048;
         E4047;
         E4056;
         E4058;
         E4057;
         E4043;
         E4101;
         E4102;
         E4103;
         E4131;
         E4132;
         E4133;
         E4135;
         E4134;
         E4136;
         E4143;
         E4144;
         E4145;
         E4147;
         E4157;
         E4158;
         E4161;
         E4160;
         E4163;
         E4164;
         E4165;
         E4166;
         E4146;
         E4167;
         E4168;
         E4169;
         E4170;
         E4171;
         E4172;
         E4199;
         E4194;
         E4195;
         E4196;
         E4197;
         E4198;
         E4189;
         E4205;
         E4206;
         E4208;
         E4207;
         E4210;
         E4211;
         E4212;
         E4217;
         E4218;
         E4219;
         E4221;
         E4223;
         E4225;
         E4230;
         E4231;
         E4232;
         E4233;
         E4235;
         E4237;
         E4239;
         E4244;
         E4246;
         E4247;
         E4248;
         E4249;
         E4261;
         E4265;
         E4250;
         E4273;
         E4274;
         E4276;
         E4277;
         if(_levInfo.isPK())
         {
            param1.isPk = true;
         }
         if(BattleModelManager.getIns().isTeam)
         {
            param1.isTeam = true;
         }
         var _loc14_:int = param1.configVo.classType;
         if(_levInfo.isPetTrain())
         {
            if(_loc14_ != 0)
            {
               try
               {
                  _loc10_ = getDefinitionByName("viewers.entitys.man.pets.P" + _loc14_) as Class;
               }
               catch(error:Error)
               {
                  try
                  {
                     _loc10_ = getDefinitionByName("viewers.entitys.man.enemys.E" + _loc14_) as Class;
                  }
                  catch(error:Error)
                  {
                     _loc10_ = MonsterEntity;
                  }
               }
            }
            else
            {
               _loc10_ = MonsterEntity;
            }
         }
         else if(_loc14_ != 0 && (param1.type == "monster" || param1.type == "npc"))
         {
            _loc10_ = getDefinitionByName("viewers.entitys.man.enemys.E" + _loc14_) as Class;
         }
         else if(_loc14_ != 0 && param1.type == "pet")
         {
            _loc10_ = getDefinitionByName("viewers.entitys.man.pets.P" + _loc14_) as Class;
         }
         else if(_loc14_ != 0 && param1.type == "role")
         {
            _loc10_ = getDefinitionByName("viewers.entitys.man.enemys.E" + _loc14_) as Class;
         }
         else
         {
            _loc10_ = MonsterEntity;
         }
         _loc13_ = new _loc10_();
         if(param4)
         {
            _loc13_.setDirection(param4.direction);
         }
         _loc13_.name = "monster";
         if(param1.campId == 1)
         {
            param3 = -1;
         }
         if(param1.isPk || param1.isQc)
         {
            if(_loc13_ is E3027 || _loc13_ is E3013)
            {
               if(param4.userVo.campId == 1)
               {
                  param1.campId = 2;
               }
               else
               {
                  param1.campId = 1;
               }
            }
            else if(_loc13_ is E3373)
            {
               param1.campId = param4.userVo.campId;
            }
         }
         if(_loc13_ is MonsterEntity)
         {
            MonsterEntity(_loc13_).birthId = param3;
         }
         param1.buff_gaiLiArr = new Vector.<BuffVO>();
         param1.buff_gaiLiHurtArr = new Vector.<BuffVO>();
         var _loc22_:RoleConfigVO = param1.configVo;
         _loc13_.setUserVo(param1,_loc22_);
         if(_loc22_.id == 3901)
         {
            _loc13_.isHide = true;
         }
         var _loc15_:Number = BattleModelManager.getIns().stagePort.x;
         var _loc9_:Number = BattleModelManager.getIns().stagePort.x + BattleModelManager.getIns().stagePort.width;
         var _loc7_:Boolean = _camera.justMoveView;
         if(_loc7_)
         {
            _loc15_ = 0;
            _loc9_ = 2147483647;
         }
         if(!(_loc13_ is E3373))
         {
            if(param2.x < _loc15_)
            {
               param2.x = _loc15_;
            }
            else if(param2.x >= _loc9_)
            {
               param2.x = _loc9_ - 40;
            }
         }
         _loc13_.position = param2;
         if(param5 != 1)
         {
            if(param5 == 0)
            {
               param5 = 1;
               if(BattleModelManager.getIns().getRandom() > 0.5)
               {
                  param5 = -1;
               }
            }
            if(param5 == 2)
            {
               param5 = 1;
            }
            _loc13_.updateDirection(param5);
         }
         _loc13_.setAssets(ManResourceManager.getIns().getResourceByManId(param1.charID));
         if(param1.type != "npc")
         {
            _loc21_ = _loc22_.aiId;
            if(_loc22_.friendlyAiId > 0 && param1.iszhaohuan)
            {
               _loc21_ = _loc22_.friendlyAiId;
            }
            if(false && GameData.uid == 100)
            {
            }
            _loc18_ = BehaviorManager.getIns().createAIByAIid(_loc21_,_loc13_);
         }
         var _loc20_:Rectangle = new Rectangle(param2.x,param2.y,80,100);
         try
         {
            if(param1.configVo.param2)
            {
               _loc8_ = param1.configVo.param2.bodyRec;
               if(_loc8_)
               {
                  _loc20_.width = _loc8_.w;
                  _loc20_.height = _loc8_.h;
               }
            }
         }
         catch(error:Error)
         {
            SimpleTextLog.getIns().log2(error.message);
         }
         var _loc12_:Body = _physic.createEnemy(_loc20_,_loc22_.getMoveType(),param1.type);
         var _loc23_:BodyUserData = new BodyUserData();
         _loc23_.entity = _loc13_;
         _loc23_.group = "monster";
         _loc12_.userData.data = _loc23_;
         if(param1.campId == 1 && param1.type == "monster" && param1.iszhaohuan || param1.configVo.classType == 3407)
         {
            _loc13_.setLayerIndex(90);
         }
         else
         {
            _loc13_.setLayerIndex(_monsterIndex);
         }
         if(param1.layerIndex != 0)
         {
            _loc13_.setLayerIndex(param1.layerIndex);
         }
         _monsterIndex = _monsterIndex + 1;
         if(_monsterIndex > 80)
         {
            _monsterIndex = 10;
         }
         _loc13_.setPhysicsBody(_loc12_);
         if(_levInfo.sceneStart.length < _nowScreen)
         {
            _loc16_ = getScreenX();
            _loc13_.setScreen(new Rectangle(_loc16_,0,screenWidth,_camera.stagePort.height));
         }
         else
         {
            _loc13_.setScreen(new Rectangle(_levInfo.sceneStart[_nowScreen - 1],0,screenWidth,_camera.stagePort.height));
         }
         if(_loc22_.reHP > 0)
         {
            _enemyVec.push(_loc13_);
         }
         BattleModelManager.getIns().addEntity(_loc13_,_loc13_.userVo.campId);
         if(param4)
         {
            _loc13_.setDirection(param4.direction);
            if(param6 && param6.useDir)
            {
               _loc13_.updateDirection(param5);
               _loc13_.setDirection(param5);
            }
            _loc13_.setParent(param4);
            param4.addSon(_loc13_);
         }
         if(param6 && param6.parent2)
         {
            _loc13_.setParent(param6.parent2);
            param6.parent2.addSon(_loc13_);
         }
         if(param6 && param6.hasOwnProperty("fixedDirection"))
         {
            _loc13_.fixedDirection = param6.fixedDirection;
         }
         var _loc19_:Sprite = _manContainer;
         if(param6 && param6.hasOwnProperty("addChildLayer"))
         {
            _loc17_ = 0;
            while(_loc17_ < map.layers.length)
            {
               _loc11_ = map.layers[_loc17_];
               if(_loc11_ && _loc11_.name == param6.addChildLayer)
               {
                  _loc19_ = _loc11_;
                  break;
               }
               _loc17_++;
            }
         }
         _loc19_.addChild(_loc13_.display);
         GameFrame.juggler.add(_loc13_);
         if(_player1)
         {
            _manContainer.addChild(_player1.display);
         }
         if(_player2)
         {
            _manContainer.addChild(_player2.display);
         }
         swapManLayerChild();
         if(!_firstMonster)
         {
            _firstMonster = _loc13_;
         }
         _loc13_.onCreateAfter();
         if(_weather && _weather.properties.properties.hasOwnProperty("toMonsterBuffs"))
         {
            BuffModelManager.getIns().createBuff(String(_weather.properties.properties.toMonsterBuffs).split(","),null,1,param1);
         }
         return _loc13_ as MonsterEntity;
      }
      
      protected function getScreenX() : Number
      {
         return _nowScreen * 1000;
      }
      
      public function CreatePlayerMonsterByUerVO(param1:UserVO, param2:Boolean) : RoleEntity
      {
         var _loc3_:RoleEntity = null;
         _loc3_ = new RoleEntity();
         _loc3_.setUserVo(param1,param1.configVo);
         _loc3_.setDirection(param1.scaleX);
         _loc3_.setAssets(ManResourceManager.getIns().getResourceByRoleId(param1.userId,param1.charID));
         _manContainer.addChild(_loc3_.display);
         _loc3_.position = new Vector2D(param1.x,param1.y);
         var _loc4_:Body = _physic.createMan(new Rectangle(_loc3_.position.x,_loc3_.position.y,40,70),1,param1.ps);
         var _loc5_:BodyUserData = new BodyUserData();
         _loc5_.entity = _loc3_;
         _loc5_.group = "role";
         _loc4_.userData.data = _loc5_;
         _loc3_.setPhysicsBody(_loc4_);
         _loc3_.setLayerIndex(100);
         GameFrame.juggler.add(_loc3_);
         BattleModelManager.getIns().addEntity(_loc3_,param1.campId);
         _loc3_.onCreateAfter();
         return _loc3_;
      }
      
      protected function createPlayerByUerVO(param1:UserVO, param2:Boolean) : RoleEntity
      {
         var _loc3_:RoleEntity = null;
         param1.type = "role";
         if(isNaN(param1.entitieId))
         {
            param1.entitieId = UserVO.EID;
         }
         param1.buff_gaiLiArr = new Vector.<BuffVO>();
         param1.buff_gaiLiHurtArr = new Vector.<BuffVO>();
         if(param1.charID == 2001)
         {
            _loc3_ = new WKEntity();
         }
         else if(param1.charID == 2002)
         {
            _loc3_ = new TSEntity();
         }
         else if(param1.charID == 2003)
         {
            _loc3_ = new ZWJEntity();
         }
         else if(param1.charID == 2004)
         {
            _loc3_ = new WJEntity();
         }
         else if(param1.charID == 2005)
         {
            _loc3_ = new BLMEntity();
         }
         else if(param1.charID == 2006)
         {
            _loc3_ = new WK2Entity();
         }
         else if(param1.charID == 2007)
         {
            _loc3_ = new TS2Entity();
         }
         else if(param1.charID == 2008)
         {
            _loc3_ = new ZWJ2Entity();
         }
         else if(param1.charID == 2009)
         {
            _loc3_ = new WJ2Entity();
         }
         else if(param1.charID == 2010)
         {
            _loc3_ = new BLM2Entity();
         }
         else if(param1.charID == 20001)
         {
            _loc3_ = new YtuEntity();
         }
         else if(param1.charID == 20006)
         {
            _loc3_ = new Ytu2Entity();
         }
         else if(param1.charID == 20002)
         {
            _loc3_ = new NeZhaEntity();
         }
         else if(param1.charID == 20007)
         {
            _loc3_ = new NeZha2Entity();
         }
         else
         {
            _loc3_ = new RoleEntity();
         }
         param1.traceProperty();
         _loc3_.setUserVo(param1,param1.configVo);
         _loc3_.setDirection(param1.scaleX);
         _loc3_.setTestSkill(SkillModelManager.getIns().getSkillConfigVOByID(1001010));
         if(needReBuildRoleResource(param1))
         {
            if(this.needBuildResouce(param1))
            {
               ManResourceManager.getIns().buildResourceByRoleInBattle(param1.userId,param1.charID,param1.equipments,param1,false,false);
            }
            else
            {
               ManResourceManager.getIns().buildResourceByRoleInBattleShowFashion(param1.userId,param1.charID,param1.equipments,param1,false,false);
            }
         }
         if(_levInfo && _levInfo.isSLC())
         {
            ManResourceManager.getIns().buildResourceByRoleInBattle(-1,param1.charID,null,param1,false,false);
         }
         _loc3_.setAssets(ManResourceManager.getIns().getResourceByRoleId(param1.userId,param1.charID));
         _manContainer.addChild(_loc3_.display);
         _loc3_.position = new Vector2D(param1.x,param1.y);
         var _loc4_:Body = _physic.createMan(new Rectangle(_loc3_.position.x,_loc3_.position.y,40,70),1,param1.ps);
         var _loc5_:BodyUserData = new BodyUserData();
         _loc5_.entity = _loc3_;
         _loc5_.group = "role";
         _loc4_.userData.data = _loc5_;
         _loc3_.setPhysicsBody(_loc4_);
         _loc3_.setLayerIndex(100);
         GameFrame.juggler.add(_loc3_);
         BattleModelManager.getIns().addEntity(_loc3_,param1.campId);
         if(_levInfo)
         {
            _levInfo.addRole(param1);
         }
         _loc3_.onCreateAfter();
         createMagicWeapon(param1,param2);
         createMagicWeapon2(param1,param2);
         return _loc3_;
      }
      
      protected function needReBuildRoleResource(param1:UserVO) : Boolean
      {
         return true;
      }
      
      protected function needBuildResouce(param1:UserVO) : Boolean
      {
         return true;
      }
      
      protected function createPlayer() : void
      {
         var _loc7_:Array = null;
         var _loc8_:int = 0;
         var _loc6_:UserVO = null;
         var _loc2_:UserVO = null;
         var _loc1_:Vector2D = null;
         var _loc3_:int = 1;
         var _loc5_:int = 1;
         if(UserModelManager.getIns().getCurretPlayerInfo())
         {
            _loc5_ = UserModelManager.getIns().getCurretPlayerInfo().pMode;
         }
         if(_levInfo.pmode > 0)
         {
            _loc5_ = _levInfo.pmode;
         }
         if(_loc5_ == 1)
         {
            _loc7_ = [UserModelManager.getIns().playerUserVo1];
            if(GlobalData.getOpenJoinBattle() && UserModelManager.getIns().getCurretPlayerInfo().pMode == 2 && UserModelManager.getIns().playerUserVo1.isNotJoinBattle)
            {
               _loc7_ = [UserModelManager.getIns().playerUserVo2];
            }
         }
         else if(_loc5_ == 2)
         {
            _loc7_ = [UserModelManager.getIns().playerUserVo1,UserModelManager.getIns().playerUserVo2];
         }
         var _loc4_:Boolean = true;
         if(TeamHorseModelManager.getIns().isPlaying)
         {
            _loc7_ = TeamHorseModelManager.getIns().getMe();
            _loc4_ = false;
         }
         this.decideNotJoin = _loc4_;
         onCreatePlayer1Before(_loc7_);
         _loc8_ = 0;
         for(; _loc8_ < _loc7_.length; _loc8_++)
         {
            _loc6_ = _loc7_[_loc8_];
            _loc6_.entitieId = UserVO.EID;
            if(_loc6_.getCurrentUVO() && isNaN(_loc6_.getCurrentUVO().entitieId))
            {
               _loc6_.getCurrentUVO().entitieId = UserVO.EID;
            }
            if(GlobalData.getOpenJoinBattle() && this.decideNotJoin)
            {
               if(_loc6_.isNotJoinBattle)
               {
                  continue;
               }
            }
            if(_loc6_.children)
            {
               _loc6_.children.entitieId = _loc6_.entitieId;
            }
            _loc2_ = _loc6_.getCurrentUVO();
            _loc2_.magicWeapon = _loc6_.magicWeapon;
            _loc2_.currentPet = _loc6_.currentPet;
            if(_loc3_ == 0)
            {
               _loc2_.hp = _loc2_.hpMax = 1000000;
            }
            if(_loc3_ == 0 && _loc8_ == 1)
            {
               _loc2_.campId = 2;
            }
            _loc2_.x = _levInfo.birthPoint.x;
            _loc2_.y = _levInfo.birthPoint.y;
            if(_levInfo.id == 6001)
            {
               _loc1_ = BattleModelManager.getIns().getLuoHanYuanPlayerPos();
               if(_loc1_)
               {
                  _loc2_.x = _loc1_.x;
                  _loc2_.y = _loc1_.y;
               }
            }
            SimpleTextLog.getIns().log2("_levInfo.birthPoint",_levInfo.birthPoint);
            _loc6_.x = _loc2_.x;
            _loc6_.y = _loc2_.y;
            createPlayer1(_loc2_,_loc8_ + 1,false);
            if(GlobalData.getOpenJoinBattle())
            {
               BattleModelManager.getIns().levelParam.addUservo(_loc2_);
            }
         }
      }
      
      protected function onCreatePlayer1Before(param1:Array) : void
      {
      }
      
      override public function createPlayer1(param1:UserVO, param2:int, param3:Boolean) : void
      {
         var _loc6_:PetUserVO = null;
         var _loc5_:Entity = null;
         var _loc9_:int = 0;
         var _loc7_:UserVO = null;
         var _loc8_:Boolean = false;
         if(param1.x == -1 && param1.y == -1)
         {
            param1.x = _levInfo.birthPoint.x;
            param1.y = _levInfo.birthPoint.y;
            _loc8_ = true;
         }
         var _loc4_:RoleEntity = createPlayerByUerVO(param1,param3);
         resetPlayer12(param2,_loc4_);
         if(_levInfo.NeedSeeAllPlayer())
         {
            _loc4_.showName(16776960);
         }
         _loc4_.showTitle();
         _loc4_.showWing();
         _loc4_.updateWalk_Run_Jump();
         if(_loc8_)
         {
            reStart();
         }
         _camera.follow(_player1,_player2);
         if(param3 == false)
         {
            addNewPet(param1);
         }
         else
         {
            if(param1.ps == 1)
            {
               _loc6_ = UserModelManager.getIns().playerUserVo1.currentPet as PetUserVO;
            }
            else if(param1.ps == 2)
            {
               _loc6_ = UserModelManager.getIns().playerUserVo2.currentPet as PetUserVO;
            }
            if(_loc6_)
            {
               _loc5_ = BattleModelManager.getIns().getPlayerByEntityId(_loc6_.entitieId);
               if(_loc5_ && _loc4_)
               {
                  _loc5_.setParent(_loc4_);
               }
            }
            param1.currentPet = _loc6_;
         }
         if(BattleModelManager.getIns().isTeam)
         {
            _loc9_ = 0;
            while(_loc9_ < BattleModelManager.getIns().pkUser1.length)
            {
               _loc7_ = BattleModelManager.getIns().pkUser1[_loc9_];
               if(_loc7_.userId == param1.userId)
               {
                  param1.inCampIndex = param1.children.inCampIndex = _loc9_;
                  _teamPlayers[_loc9_] = _loc4_;
               }
               _loc9_++;
            }
         }
         SoulStoneManager.getIns().Start(_loc4_,param1);
      }
      
      protected function resetPlayer12(param1:int, param2:RoleEntity) : void
      {
         if(param1 == 1)
         {
            if(_player1)
            {
               _player1.display.visible = false;
            }
            _player1 = param2;
         }
         else
         {
            if(_player2)
            {
               _player2.display.visible = false;
            }
            _player2 = param2;
         }
      }
      
      private function createPet(param1:UserVO, param2:PetUserVO) : void
      {
         var _loc6_:* = null;
         var _loc3_:* = null;
         var _loc4_:* = null;
         var _loc7_:PetInfoVo = UserModelManager.getIns().getCurretPlayerInfo().getCurrentPet(param1.ps);
         var _loc8_:Number = param1.x;
         var _loc5_:Number = param1.y;
         createPetByPetInfoVO(_loc7_,_loc8_,_loc5_,param1.campId,param1.ps,param1.userId,param1,false,_loc8_,_loc5_);
      }
      
      protected function createPetByPetInfoVO(param1:PetInfoVo, param2:Number, param3:Number, param4:int, param5:int, param6:Number, param7:UserVO, param8:Boolean = false, param9:Number = 0, param10:Number = 0) : void
      {
         var _loc11_:UserVO = null;
         var _loc13_:Entity = null;
         var _loc14_:MonsterEntity = null;
         var _loc12_:int = 0;
         if(param1 && param1.isDie == false)
         {
            if(_offPets.indexOf(param1.petItemVo.entityId) > -1)
            {
               return;
            }
            _loc11_ = UserVO.buildFromPetInfoVo(param1,this._levInfo.id);
            _loc11_.isMePk = param8;
            _loc11_.x = param2;
            _loc11_.y = param3;
            _loc11_.isRole = true;
            if(!_petSkillCD)
            {
               _petSkillCD = {};
            }
            if(_lastPetUservo)
            {
               _loc11_.skillCD = _lastPetUservo.skillCD;
            }
            _lastPetUservo = _loc11_;
            if(param1.useUserVoHpMax)
            {
               param1.hp = _loc11_.hpMax;
               param1.useUserVoHpMax = false;
               _loc11_.hp = param1.hp;
               _loc11_.protectedData.build(_loc11_.cloneToObject());
            }
            if(param8 == false)
            {
               _loc11_.hp = param1.hp;
               _loc11_.protectedData.build(_loc11_.cloneToObject());
            }
            if(param7)
            {
               _loc13_ = BattleModelManager.getIns().getPlayerByEntityId(param7.entitieId);
            }
            if(_loc13_)
            {
               _loc11_.x = _loc13_.position.x;
               _loc11_.y = _loc13_.position.y - 60;
            }
            if(param9 != 0)
            {
               _loc11_.x = param9;
            }
            if(param10 != 0)
            {
               _loc11_.y = param10;
            }
            _loc11_.campId = param4;
            _loc11_.ps = param5;
            _loc11_.userId = param6;
            _loc11_.father = param7;
            if(param7)
            {
               _loc11_.isLuoHan_ChenShi = param7.isLuoHan_ChenShi;
               _loc11_.oldAtk = _loc11_.atk;
               param7.currentPet = _loc11_;
               this._usedPets[param5] = _loc11_.charID;
            }
            onCreateMonsterBefore(_loc11_,param7);
            _loc14_ = createMonster(_loc11_,new Vector2D(_loc11_.x,_loc11_.y),-1,null,1);
            _loc14_.setLayerIndex(90);
            _loc14_.setParent(_loc13_);
            this.currPetEntity = _loc14_;
            this.onCreatePet(_loc14_,_loc11_);
            if(_loc11_.takeCryStals)
            {
               _loc12_ = 0;
               while(_loc12_ < _loc11_.takeCryStals.length)
               {
                  _loc11_.takeCryStals[_loc12_].start();
                  _loc12_++;
               }
            }
         }
      }
      
      protected function onCreateMonsterBefore(param1:UserVO, param2:UserVO) : void
      {
      }
      
      protected function onCreatePet(param1:MonsterEntity, param2:UserVO) : void
      {
      }
      
      override public function addNewPet(param1:UserVO) : void
      {
         var _loc4_:PetUserVO = null;
         var _loc2_:PlayerEntity = null;
         var _loc3_:* = undefined;
         var _loc6_:int = 0;
         var _loc5_:MonsterEntity = null;
         if(_levInfo.take && _levInfo.take.length > 0)
         {
            if(int(_levInfo.take[0]) == 0)
            {
               return;
            }
         }
         if(param1.ps < 1 || param1.ps > 2)
         {
            throw new Error("p" + param1.ps + "换宠物");
         }
         _loc4_ = param1.currentPet as PetUserVO;
         if(_loc4_)
         {
            BuffModelManager.getIns().removeEntityBuffs(_loc4_.entitieId);
            BehaviorManager.getIns().removeAIByEntity(_loc4_.entitieId);
            _loc3_ = BattleModelManager.getIns().getCamp2();
            _loc6_ = 0;
            while(_loc6_ < _loc3_.length)
            {
               _loc5_ = _loc3_[_loc6_] as MonsterEntity;
               if(_loc5_)
               {
                  _loc5_.userVo.removeHatredByEid(_loc4_.entitieId);
               }
               _loc6_++;
            }
            _loc2_ = BattleModelManager.getIns().getPlayerByEntityId(_loc4_.entitieId) as PlayerEntity;
            if(_loc2_)
            {
               BattleModelManager.getIns().removeEntityByUid(_loc2_.Id,false);
               _loc2_.destory();
            }
            if(this._createdPets.indexOf(_loc4_.charID) == -1)
            {
               this._createdPets.push(_loc4_.charID);
            }
         }
         param1.currentPet = null;
         createPet(param1,_loc4_);
         this.lastOffTime = 0;
         this.lastOnTime = 0;
      }
      
      override public function takePetAtSide(param1:UserVO) : void
      {
         var _loc4_:PetUserVO = null;
         var _loc3_:PlayerEntity = null;
         var _loc7_:Boolean = false;
         var _loc8_:int = 0;
         var _loc2_:int = 0;
         var _loc6_:Entity = null;
         super.takePetAtSide(param1);
         if(_levInfo.take && _levInfo.take.length > 0)
         {
            if(int(_levInfo.take[0]) == 0)
            {
               return;
            }
         }
         if(param1.ps < 1 || param1.ps > 2)
         {
            throw new Error("p" + param1.ps + "换宠物");
         }
         this._takePetSideTip.push(param1);
         var _loc5_:int = 1;
         if(UserModelManager.getIns().getCurretPlayerInfo())
         {
            _loc5_ = UserModelManager.getIns().getCurretPlayerInfo().pMode;
         }
         if(this._takePetSideTip.length >= _loc5_)
         {
            _loc7_ = false;
            _loc8_ = 0;
            for(; _loc8_ < this._takePetSideTip.length; _loc8_++)
            {
               param1 = this._takePetSideTip[_loc8_];
               if(param1)
               {
                  _loc4_ = param1.currentPet as PetUserVO;
                  SimpleTextLog.getIns().log2("takePetAtSide","oldP=" + (_loc4_ != null));
                  if(_loc4_)
                  {
                     if(_loc7_ == false && this.lastOnOffTime != 0 && GameFrame.time - this.lastOnOffTime < 5000)
                     {
                        _loc2_ = 5000 - (GameFrame.time - this.lastOnOffTime);
                        _loc2_ = Math.ceil(_loc2_ / 1000);
                        CreateComponent.createAutoWarnBar("宠物回防冷却剩余" + _loc2_ + "秒");
                        _loc7_ = true;
                        _takePetSideTip.length = 0;
                        return;
                     }
                     _loc3_ = BattleModelManager.getIns().getPlayerByEntityId(_loc4_.entitieId) as PlayerEntity;
                     if(_loc3_)
                     {
                        _loc6_ = BattleModelManager.getIns().getPlayerByEntityId(param1.entitieId);
                        if(_loc6_)
                        {
                           try
                           {
                              _loc3_.body.position.setxy(_loc6_.body.position.x,_loc6_.body.position.y - 40);
                           }
                           catch(error:Error)
                           {
                           }
                           continue;
                        }
                     }
                  }
               }
            }
            this.lastOnOffTime = GameFrame.time;
            _takePetSideTip.length = 0;
         }
      }
      
      override public function setPetOnOff(param1:UserVO) : void
      {
         var _loc3_:PetUserVO = null;
         var _loc2_:PlayerEntity = null;
         var _loc5_:Boolean = false;
         var _loc4_:int = 0;
         var _loc7_:int = 0;
         var _loc11_:PetInfoVo = null;
         var _loc8_:int = 0;
         _loc8_ = 0;
         _loc5_ = false;
         _loc7_ = 0;
         _loc7_ = 0;
         var _loc9_:* = undefined;
         var _loc12_:int = 0;
         var _loc6_:MonsterEntity = null;
         super.setPetOnOff(param1);
         if(_levInfo.take && _levInfo.take.length > 0)
         {
            if(int(_levInfo.take[0]) == 0)
            {
               return;
            }
         }
         if(param1.ps < 1 || param1.ps > 2)
         {
            throw new Error("p" + param1.ps + "换宠物");
         }
         this._takePetSideTip.push(param1);
         var _loc10_:int = 1;
         if(UserModelManager.getIns().getCurretPlayerInfo())
         {
            _loc10_ = UserModelManager.getIns().getCurretPlayerInfo().pMode;
         }
         if(_loc10_ == 2 && GlobalData.getOpenJoinBattle())
         {
            if(BattleModelManager.getIns().levelParam.getJoinPlayerTotal() == 1)
            {
               _loc10_ = 1;
            }
         }
         if(_loc10_ == 2)
         {
            if(_player2.isDie || _player2.deleted)
            {
               this._takePetSideTip.push(_player2.userVo);
            }
            if(_player1.isDie || _player1.deleted)
            {
               this._takePetSideTip.push(_player1.userVo);
            }
         }
         var _loc13_:int = 1000;
         if(this._takePetSideTip.length >= _loc10_)
         {
            this._takePetSideTip.length = _loc10_;
            this._offPets.length = 0;
            _loc5_ = false;
            _loc4_ = 0;
            _loc7_ = 0;
            while(_loc7_ < this._takePetSideTip.length)
            {
               param1 = this._takePetSideTip[_loc7_];
               if(param1)
               {
                  _loc11_ = UserModelManager.getIns().getCurretPlayerInfo().getCurrentPet(param1.ps);
                  if(_loc11_ && _loc11_.isDie == false)
                  {
                     _loc4_++;
                  }
               }
               _loc7_++;
            }
            if(_loc4_ == 0)
            {
               return;
            }
            if(this.lastOffTime != 0 && GameFrame.time - this.lastOffTime < _loc13_)
            {
               _loc8_ = _loc13_ - (GameFrame.time - this.lastOffTime);
               _loc8_ = Math.ceil(_loc8_ / 1000);
               CreateComponent.createAutoWarnBar("宠物快捷出战冷却中");
               _takePetSideTip.length = 0;
               return;
            }
            if(this.lastOnTime != 0 && GameFrame.time - this.lastOnTime < _loc13_)
            {
               _loc8_ = _loc13_ - (GameFrame.time - this.lastOnTime);
               _loc8_ = Math.ceil(_loc8_ / 1000);
               CreateComponent.createAutoWarnBar("宠物快捷休息冷却中");
               _takePetSideTip.length = 0;
               return;
            }
            this._offPets.length = 0;
            _loc5_ = false;
            _loc7_ = 0;
            while(_loc7_ < this._takePetSideTip.length)
            {
               param1 = this._takePetSideTip[_loc7_];
               if(param1)
               {
                  _loc3_ = param1.currentPet as PetUserVO;
                  if(_loc3_)
                  {
                     _loc5_ = true;
                     break;
                  }
               }
               _loc7_++;
            }
            _loc7_ = 0;
            while(_loc7_ < this._takePetSideTip.length)
            {
               param1 = this._takePetSideTip[_loc7_];
               if(param1)
               {
                  _loc3_ = param1.currentPet as PetUserVO;
                  SimpleTextLog.getIns().log2("takePetAtSide","oldP=" + (_loc3_ != null),"uvo.ps=" + param1.ps);
                  if(_loc5_)
                  {
                     if(_loc3_)
                     {
                        BuffModelManager.getIns().removeEntityBuffs(_loc3_.entitieId);
                        BehaviorManager.getIns().removeAIByEntity(_loc3_.entitieId);
                        _loc9_ = BattleModelManager.getIns().getCamp2();
                        _loc12_ = 0;
                        while(_loc12_ < _loc9_.length)
                        {
                           _loc6_ = _loc9_[_loc12_] as MonsterEntity;
                           if(_loc6_)
                           {
                              _loc6_.userVo.removeHatredByEid(_loc3_.entitieId);
                           }
                           _loc12_++;
                        }
                        _loc2_ = BattleModelManager.getIns().getPlayerByEntityId(_loc3_.entitieId) as PlayerEntity;
                        if(_loc2_)
                        {
                           BattleModelManager.getIns().removeEntityByUid(_loc2_.Id,false);
                           _loc2_.destory();
                        }
                        if(this._createdPets.indexOf(_loc3_.charID) == -1)
                        {
                           this._createdPets.push(_loc3_.charID);
                        }
                        this._offPets.push(_loc3_.entityId);
                        param1.currentPet = null;
                        ApplicationFacade.getInstance().sendNotification("nfPlayerInfoChange",param1);
                        lastOffTime = GameFrame.time;
                     }
                  }
                  else
                  {
                     removeOldpet(param1);
                     if(!param1.isNotJoinBattle)
                     {
                        createPet(param1,_loc3_);
                     }
                     lastOnTime = GameFrame.time;
                  }
               }
               _loc7_++;
            }
            this.lastOnOffTime = GameFrame.time;
            _takePetSideTip.length = 0;
         }
      }
      
      private function removeOldpet(param1:UserVO) : void
      {
         var _loc4_:PetUserVO = null;
         var _loc2_:PlayerEntity = null;
         var _loc3_:* = undefined;
         var _loc6_:int = 0;
         var _loc5_:MonsterEntity = null;
         if(!param1)
         {
            return;
         }
         _loc4_ = param1.currentPet as PetUserVO;
         if(_loc4_)
         {
            BuffModelManager.getIns().removeEntityBuffs(_loc4_.entitieId);
            BehaviorManager.getIns().removeAIByEntity(_loc4_.entitieId);
            _loc3_ = BattleModelManager.getIns().getCamp2();
            _loc6_ = 0;
            while(_loc6_ < _loc3_.length)
            {
               _loc5_ = _loc3_[_loc6_] as MonsterEntity;
               if(_loc5_)
               {
                  _loc5_.userVo.removeHatredByEid(_loc4_.entitieId);
               }
               _loc6_++;
            }
            _loc2_ = BattleModelManager.getIns().getPlayerByEntityId(_loc4_.entitieId) as PlayerEntity;
            if(_loc2_)
            {
               BattleModelManager.getIns().removeEntityByUid(_loc2_.Id,false);
               _loc2_.destory();
            }
            param1.currentPet = null;
            ApplicationFacade.getInstance().sendNotification("nfPlayerInfoChange",param1);
         }
      }
      
      private function removeOldPetRes() : void
      {
         var _loc5_:int = 0;
         var _loc2_:int = 0;
         var _loc4_:Boolean = false;
         var _loc3_:int = 0;
         var _loc1_:int = 0;
         trace("this._createdPets",this._createdPets);
         trace("this._usedPets",this._usedPets);
         trace("3333============================",System.totalMemoryNumber / 1024 / 1024);
         _loc5_ = 0;
         while(_loc5_ < this._createdPets.length)
         {
            _loc2_ = int(this._createdPets[_loc5_]);
            _loc4_ = false;
            _loc3_ = 0;
            while(_loc3_ < this._usedPets.length)
            {
               _loc1_ = int(this._usedPets[_loc3_]);
               if(_loc2_ == _loc1_)
               {
                  _loc4_ = true;
                  break;
               }
               _loc3_++;
            }
            if(!_loc4_)
            {
               ManResourceManager.getIns().disposeMonster(_loc2_);
            }
            _loc5_++;
         }
      }
      
      protected function reStart() : void
      {
      }
      
      private function tt2() : void
      {
         _player1.handKey(76,1);
      }
      
      override public function createMagicWeapon(param1:UserVO, param2:Boolean) : void
      {
         var _loc6_:MagicweaponVo = null;
         var _loc8_:String = null;
         var _loc7_:Class = null;
         var _loc3_:MagicWeaponEntity = null;
         var _loc10_:Vector2D = null;
         if(_levInfo.take && _levInfo.take.length > 0)
         {
            if(int(_levInfo.take[1]) == 0)
            {
               return;
            }
         }
         if(param1.isTown)
         {
            return;
         }
         var _loc4_:RoleEntity = BattleModelManager.getIns().getPlayerByEntityId(param1.entitieId) as RoleEntity;
         if(!_loc4_)
         {
            return;
         }
         var _loc5_:UserVO = param1.getMagicWeapon();
         if(param2)
         {
            if(param1.magicWeapon)
            {
               param1.magicWeapon.follow(_loc4_);
               _loc4_.setMagicWeapon(param1.magicWeapon);
            }
            return;
         }
         var _loc9_:int = 0;
         if(param1.magicWeapon)
         {
            if(!param1.magicWeapon.deleted)
            {
               _loc9_ = param1.magicWeapon.skillConfigVo.nowCD;
            }
            if(_loc5_ && _loc9_ > 0 && param1.magicWeapon.userVo.entityId == _loc5_.entityId)
            {
               param1.magicWeapon.userVo.level = _loc5_.level;
               param1.magicWeapon.userVo.roleName = _loc5_.roleName;
               return;
            }
            param1.magicWeapon.destory();
            param1.magicWeapon = null;
         }
         if(!_loc5_)
         {
            param1.magicWeapon = null;
         }
         if(_loc5_)
         {
            _loc5_.canNotAddBuff = true;
            if(_loc5_.charID < 419000001)
            {
               CreateComponent.createAutoWarnBar("错误的法宝id=" + _loc5_.charID);
               return;
            }
            _loc6_ = ItemVoManager.getIns().getMagicweaponVoById(_loc5_.charID);
            _loc8_ = "viewers.entitys.weapons." + _loc6_.classType + "Entity";
            GuJianEntity;
            RuYiEntity;
            JinPingEntity;
            FoZhuEntity;
            QingLianEntity;
            YuShanEntity;
            YuShan2Entity;
            TianChuiEntity;
            ZuDIanEntity;
            LingEntity;
            QuanEntity;
            JinLunEntity;
            FaLuoEntity;
            ZhuoQuEntity;
            JiuYouEntity;
            JiuYou2Entity;
            YanmieEntity;
            YongShengEntity;
            YongSheng2Entity;
            WuMingEntity;
            JianchanEntity;
            NachaEntity;
            LuoyanEntity;
            QielanEntity;
            TanwangEntity;
            _loc7_ = getDefinitionByName(_loc8_) as Class;
            _loc3_ = new _loc7_();
            _loc3_.buildFromVO(_loc5_,null);
            _loc3_.follow(_loc4_);
            _loc3_.setNowCd(_loc9_);
            _loc10_ = _loc4_.position.clone();
            _loc10_.x = _loc10_.x + -_loc4_.direction * 60;
            _loc10_.y -= 10;
            _loc5_.parent = param1;
            _loc3_.setLayerIndex(200);
            _loc3_.position = _loc10_;
            _manContainer.addChild(_loc3_.display);
            BattleModelManager.getIns().addEntity(_loc3_,0);
            GameFrame.juggler.add(_loc3_);
            _loc4_.setMagicWeapon(_loc3_);
            param1.magicWeapon = _loc3_;
            swapManLayerChild();
         }
      }
      
      override public function createMagicWeapon2(param1:UserVO, param2:Boolean) : void
      {
         var _loc6_:MagicweaponVo = null;
         var _loc8_:String = null;
         var _loc7_:Class = null;
         var _loc3_:MagicWeaponEntity = null;
         var _loc9_:Vector2D = null;
         if(_levInfo.take && _levInfo.take.length > 0)
         {
            if(int(_levInfo.take[2]) == 0)
            {
               return;
            }
         }
         if(!TeamHorseModelManager.getIns().isPlaying)
         {
            if(_levInfo.getIsV2() == false)
            {
               if(param1.isTown || param1.isPk || param1.isQc || UserModelManager.getIns().isMe(param1) == false)
               {
                  return;
               }
            }
         }
         var _loc4_:RoleEntity = BattleModelManager.getIns().getPlayerByEntityId(param1.entitieId) as RoleEntity;
         var _loc5_:UserVO = param1.getMagicWeapon2();
         if(param2)
         {
            if(param1.magicWeapon2)
            {
               param1.magicWeapon2.follow(_loc4_);
               _loc4_.setMagicWeapon2(param1.magicWeapon2);
            }
            return;
         }
         if(param1.magicWeapon2)
         {
            param1.magicWeapon2.destory();
            param1.magicWeapon2 = null;
         }
         if(!_loc5_)
         {
            param1.magicWeapon2 = null;
         }
         if(_loc5_)
         {
            _loc6_ = ItemVoManager.getIns().getSwordVoById(_loc5_.charID);
            _loc8_ = "viewers.entitys.weapons." + _loc6_.classType + "Entity";
            JueEntity;
            LuEntity;
            XianEntity;
            ZhuEntity;
            SiJianEntity;
            _loc7_ = getDefinitionByName(_loc8_) as Class;
            _loc3_ = new _loc7_();
            _loc3_.buildFromVO(_loc5_,null);
            _loc3_.follow(_loc4_);
            _loc9_ = _loc4_.position.clone();
            _loc9_.x = _loc9_.x + -_loc4_.direction * 60;
            if(param1.magicWeapon)
            {
               _loc9_.x += -_loc4_.direction * 60;
            }
            _loc9_.y -= 10;
            _loc5_.parent = param1;
            _loc3_.setLayerIndex(201);
            _loc3_.position = _loc9_;
            _manContainer.addChild(_loc3_.display);
            BattleModelManager.getIns().addEntity(_loc3_,0);
            GameFrame.juggler.add(_loc3_);
            _loc4_.setMagicWeapon2(_loc3_);
            param1.magicWeapon2 = _loc3_;
            createMagicWeapon2Yi(_loc3_,_loc5_);
            swapManLayerChild();
         }
      }
      
      private function createMagicWeapon2Yi(param1:MagicWeaponEntity, param2:UserVO) : void
      {
         var _loc4_:MagicWeaponEntity2Yi = null;
         if(param2.swordShi <= 0)
         {
            return;
         }
         var _loc5_:Object = {
            "id":param2.swordShi,
            "level":param2.swordShiLevel
         };
         var _loc7_:UserVO = new UserVO();
         _loc7_.buildFromObject(param2.cloneToObject());
         _loc7_.campId = param2.campId;
         _loc7_.entitieId = UserVO.EID;
         _loc7_.hurtSkills = new Dictionary();
         _loc7_.hpLoseDict = new Dictionary();
         _loc7_.hatred = new Dictionary();
         _loc7_.hp = param2.hpMax;
         _loc7_.buff_gaiLiArr = new Vector.<BuffVO>();
         _loc7_.buff_gaiLiHurtArr = new Vector.<BuffVO>();
         _loc7_.isMagic = false;
         _loc7_.isMagicJianYi = true;
         _loc7_.type = ManType.SKILL;
         _loc7_.level = _loc5_.level;
         var _loc3_:Class = MagicWeaponEntity2Yi;
         _loc4_ = new _loc3_(_loc5_,ItemVoManager.getIns().getSwordVoById(_loc7_.charID).clone);
         _loc7_.charID = 730001001 + _loc5_.id;
         _loc4_.buildFromVO(_loc7_,null);
         _loc4_.follow(param1);
         param1.jianYi = _loc4_;
         var _loc6_:Vector2D = param1.position.clone();
         _loc4_.setLayerIndex(200 - param2.ps);
         _loc4_.position = _loc6_;
         _manContainer.addChild(_loc4_.display);
         BattleModelManager.getIns().addEntity(_loc4_,0);
         GameFrame.juggler.add(_loc4_);
         swapManLayerChild();
      }
      
      public function roleEnter(param1:UserVO, param2:HorseVO, param3:Vector2D, param4:int) : void
      {
         var _loc6_:RoleEntity = null;
         var _loc5_:PetEntity = null;
         var _loc10_:int = 0;
         _loc10_ = 0;
         var _loc7_:Array = null;
         var _loc12_:Array = null;
         param1.currentHorser = param2;
         if(!param1.currentHorser)
         {
            throw new Error("当前坐骑数据不符合。");
         }
         param2.isRole = true;
         if(param2.configVo.id == 1000100 || param2.configVo.id == 1001100 || param2.configVo.id == 1002600 || param2.configVo.id == 1000100)
         {
            _loc6_ = new XWEntity();
         }
         else if(param2.configVo.id == 1000200 || param2.configVo.id == 1001500 || param2.configVo.id == 1004400 || param2.configVo.id == 1000200)
         {
            _loc6_ = new ZQEntity();
         }
         else if(param2.configVo.id == 1000400 || param2.configVo.id == 1003000)
         {
            _loc6_ = new XSJEntity();
         }
         else if(param2.configVo.id == 1000600 || param2.configVo.id == 1001600 || param2.configVo.id == 1002400)
         {
            _loc6_ = new CNMEntity();
         }
         else if(param2.configVo.id == 1000700 || param2.configVo.id == 1001200)
         {
            _loc6_ = new QZSWEntity();
         }
         else if(param2.configVo.id == 1000800)
         {
            _loc6_ = new KMLEntity();
         }
         else if(param2.configVo.id == 1000900 || param2.configVo.id == 1004500)
         {
            _loc6_ = new DTEntity();
         }
         else if(param2.configVo.id == 1001000 || param2.configVo.id == 1004300)
         {
            _loc6_ = new YangZhiEntity();
         }
         else if(param2.configVo.id == 1001300)
         {
            _loc6_ = new XionMaoEntity();
         }
         else if(param2.configVo.id == 1001400 || param2.configVo.id == 1003900)
         {
            _loc6_ = new NianShouEntity();
         }
         else if(param2.configVo.id == 1001700 || param2.configVo.id == 1003400)
         {
            _loc6_ = new QingLuanEntity();
         }
         else if(param2.configVo.id == 1001800 || param2.configVo.id == 1005000)
         {
            _loc6_ = new QingLong2Entity();
         }
         else if(param2.configVo.id == 1003600)
         {
            _loc6_ = new QingLong2Entity();
         }
         else if(param2.configVo.id == 1001900 || param2.configVo.id == 1003800)
         {
            _loc6_ = new HuoQiLingEntity();
         }
         else if(param2.configVo.id == 1002000)
         {
            _loc6_ = new LongYuEntity();
         }
         else if(param2.configVo.id == 1003500)
         {
            _loc6_ = new LongYuByDragonEntity();
         }
         else if(param2.configVo.id == 1002100)
         {
            _loc6_ = new WanWanEntity();
         }
         else if(param2.configVo.id == 1003700)
         {
            _loc6_ = new WanWan2Entity();
         }
         else if(param2.configVo.id == 1002200 || param2.configVo.id == 1003100 || param2.configVo.id == 1000300)
         {
            _loc6_ = new BaiHuEntity();
         }
         else if(param2.configVo.id == 1002300 || param2.configVo.id == 1002800)
         {
            _loc6_ = new WenYuEntity();
         }
         else if(param2.configVo.id == 1002500 || param2.configVo.id == 1002700)
         {
            _loc6_ = new JiuSeLuEntity();
         }
         else if(param2.configVo.id == 1003200 || param2.configVo.id == 1003300)
         {
            _loc6_ = new BaiYuanEntity();
         }
         else if(param2.configVo.id == 1004000)
         {
            _loc6_ = new YueTu2Entity();
         }
         else if(param2.configVo.id == 1004100 || param2.configVo.id == 1004200)
         {
            _loc6_ = new YueTu2Entity();
         }
         else if(param2.configVo.id == 1004100 || param2.configVo.id == 1004200)
         {
            _loc6_ = new YueTu2Entity();
         }
         else if(param2.configVo.id == 1004700 || param2.configVo.id == 1004600 || param2.configVo.id == 1004900)
         {
            _loc6_ = new XiaoLongEntity();
         }
         else if(param2.configVo.id == 1004800)
         {
            _loc6_ = new XiaoLongFlyEntity();
         }
         else if(param2.configVo.id == 1005300)
         {
            _loc6_ = new SenXiHorseEntity();
         }
         else if(param2.configVo.id == 1005400 || param2.configVo.id == 1005500)
         {
            _loc6_ = new JianMaEntity();
         }
         else
         {
            _loc6_ = new HorseEntity();
         }
         _loc6_.name = "horse";
         _loc6_.setUserVo(param2,param2.configVo);
         _loc6_.setAssets(ManResourceManager.getIns().getResourceByManId(param2.configVo.id));
         _manContainer.addChild(_loc6_.display);
         _loc6_.position = param3;
         var _loc9_:Number = _loc6_.position.x;
         var _loc8_:Number = _loc6_.position.y - 48;
         var _loc13_:Body = _physic.createMan(new Rectangle(_loc9_,_loc8_,40,70),param2.configVo.getMoveType(),param2.ps);
         var _loc11_:BodyUserData = new BodyUserData();
         _loc11_.entity = _loc6_;
         _loc11_.group = "horse";
         _loc13_.userData.data = _loc11_;
         _loc6_.setPhysicsBody(_loc13_);
         _loc6_.setLayerIndex(100);
         _loc6_.updateDirection(param4);
         GameFrame.juggler.add(_loc6_);
         BattleModelManager.getIns().addEntity(_loc6_,param2.campId);
         _loc6_.onCreateAfter();
         if(param1.magicWeapon)
         {
            param1.magicWeapon.follow(_loc6_);
            _loc6_.setMagicWeapon(param1.magicWeapon);
         }
         if(param1.magicWeapon2)
         {
            param1.magicWeapon2.follow(_loc6_);
            _loc6_.setMagicWeapon2(param1.magicWeapon2);
         }
         if(param1.currentPet)
         {
            _loc5_ = BattleModelManager.getIns().getPlayerByEntityId(param1.currentPet.entitieId) as PetEntity;
            if(_loc5_)
            {
               _loc5_.setParent(_loc6_);
            }
         }
         if(BattleModelManager.getIns().isTeam)
         {
            if(param1 == _player1.userVo)
            {
               if(_player1)
               {
                  _loc10_ = 0;
                  while(_loc10_ < _playerVec.length)
                  {
                     if(_player1 == _playerVec[_loc10_])
                     {
                        _playerVec.splice(_loc10_,1);
                        break;
                     }
                     _loc10_++;
                  }
                  _player1.destory();
                  _player1 = null;
               }
               _player1 = _loc6_;
               _playerVec.push(_player1);
            }
            else
            {
               if(_player2)
               {
                  _loc10_ = 0;
                  while(_loc10_ < _playerVec.length)
                  {
                     if(_player2 == _playerVec[_loc10_])
                     {
                        _playerVec.splice(_loc10_,1);
                        break;
                     }
                     _loc10_++;
                  }
                  _player2.destory();
                  _player2 = null;
               }
               _player2 = _loc6_;
               _playerVec.push(_player2);
            }
         }
         else if(param1 == UserModelManager.getIns().playerUserVo1.getCurrentUVO())
         {
            if(_player1)
            {
               _player1.destory();
               _player1 = null;
            }
            _player1 = _loc6_;
         }
         else if(UserModelManager.getIns().playerUserVo2 && param1 == UserModelManager.getIns().playerUserVo2.getCurrentUVO())
         {
            if(_player2)
            {
               _player2.destory();
               _player2 = null;
            }
            _player2 = _loc6_;
         }
         this.onEnterHorse(_player1,_loc6_);
         _camera.follow(_player1,_player2);
         BuffSceneManager.getIns().Start(param1.ps);
         if(param2.hosrseInfo && param2.hosrseInfo.horseEquipVo)
         {
            _loc7_ = param2.hosrseInfo.horseEquipVo.getEquipBuff();
            if(_loc7_.length > 0)
            {
               BuffModelManager.getIns().createBuff(_loc7_,[],1,param2);
            }
            _loc12_ = param2.hosrseInfo.horseEquipVo.getEquip2BuffId();
            if(_loc12_.length > 0)
            {
               BuffModelManager.getIns().createBuff(_loc12_,[],1,param2);
            }
         }
      }
      
      protected function onEnterHorse(param1:RoleEntity, param2:RoleEntity) : void
      {
      }
      
      public function roleExitHorse(param1:HorseEntity) : void
      {
         var _loc2_:RoleEntity = null;
         var _loc3_:PetEntity = null;
         var _loc4_:UserVO = HorseVO(param1.userVo).parent;
         _loc4_.mode = 1;
         _loc2_ = createPlayerByUerVO(_loc4_,true);
         _loc2_.showTitle();
         BuffModelManager.getIns().createBuff([1000201],null,0,_loc4_);
         if(_loc4_.magicWeapon)
         {
            _loc4_.magicWeapon.follow(_loc2_);
            _loc2_.setMagicWeapon(_loc4_.magicWeapon);
         }
         if(_loc4_.magicWeapon2)
         {
            _loc4_.magicWeapon2.follow(_loc2_);
            _loc2_.setMagicWeapon2(_loc4_.magicWeapon2);
         }
         if(_loc4_.currentPet)
         {
            _loc3_ = BattleModelManager.getIns().getPlayerByEntityId(_loc4_.currentPet.entitieId) as PetEntity;
            if(_loc3_)
            {
               _loc3_.setParent(_loc2_);
            }
         }
         if(_loc4_ == UserModelManager.getIns().playerUserVo1.getCurrentUVO())
         {
            if(_player1)
            {
               _player1.destory();
               _player1 = null;
            }
            _player1 = _loc2_;
         }
         else if(UserModelManager.getIns().playerUserVo2 && _loc4_ == UserModelManager.getIns().playerUserVo2.getCurrentUVO())
         {
            if(_player2)
            {
               _player2.destory();
               _player2 = null;
            }
            _player2 = _loc2_;
         }
         _camera.follow(_player1,_player2);
         BuffSceneManager.getIns().Start(_loc4_.ps);
         SoulStoneManager.getIns().Start(_loc2_,_loc4_);
      }
      
      private function ttt1() : void
      {
         ApplicationFacade.getInstance().sendNotification("cmdRoleEnterHorse",{"oldEntity":_player1},"Z");
      }
      
      override public function shake(param1:Point) : void
      {
         if(_shake)
         {
            return;
         }
         _shake = new Shake([_manContainer,_man2Container,_bgContainer.bg1,_bgContainer.bg2,_frontContainer,_manTopContainer],param1);
         _shake.addEventListener("clear",onShakeComplete);
      }
      
      protected function onShakeComplete(param1:Event) : void
      {
         param1.currentTarget.removeEventListener("complete",onShakeComplete);
         _shake = null;
      }
      
      override public function showSlowEff() : void
      {
         var _loc8_:int = 0;
         var _loc2_:* = undefined;
         var _loc4_:Class = null;
         var _loc3_:AnimationMovieclip = null;
         var _loc1_:UILayerMediator = null;
         var _loc5_:UILayer = null;
         if(!canUseKeyAfterZS())
         {
            removeEventListeners();
            pause();
         }
         _bgContainerC = _bgContainer.transform.colorTransform;
         _frontContainerC = _frontContainer.transform.colorTransform;
         _manContainerC = _manContainer.transform.colorTransform;
         _man2ContainerC = _manContainer.transform.colorTransform;
         _manTopContainerC = _manTopContainer.transform.colorTransform;
         var _loc7_:ColorTransform = new ColorTransform();
         _loc7_.color = 0;
         var _loc6_:ColorTransform = new ColorTransform();
         _loc6_.color = 16777215;
         _loc8_ = 0;
         while(_loc8_ < _bgContainer.numChildren)
         {
            _loc2_ = _bgContainer.getChildAt(_loc8_);
            if(_loc2_)
            {
               if(_loc2_ is ObjectLayerContainer)
               {
                  _loc2_.transform.colorTransform = _loc6_;
               }
               else
               {
                  _loc2_.transform.colorTransform = _loc7_;
               }
            }
            _loc8_++;
         }
         _frontContainer.transform.colorTransform = _loc7_;
         _manContainer.transform.colorTransform = _loc6_;
         _man2Container.transform.colorTransform = _loc6_;
         _manTopContainer.transform.colorTransform = _loc6_;
         try
         {
            _loc4_ = AssetManager.getIns().getClass("mission","zs");
            _loc3_ = new AnimationMovieclip(_loc4_,false);
            _loc1_ = ApplicationFacade.getInstance().retrieveMediator("UILayerMediator") as UILayerMediator;
            _loc5_ = _loc1_.getViewComponent() as UILayer;
            _loc5_.addChild(_loc3_);
            _loc3_.x = 940 / 2;
            _loc3_.y = 590 / 2;
         }
         catch(error:Error)
         {
         }
      }
      
      override public function clearSlowEff() : void
      {
         var _loc3_:ColorTransform = null;
         var _loc6_:int = 0;
         var _loc1_:* = undefined;
         var _loc8_:int = 0;
         var _loc4_:ObjectLayerContainer = null;
         _loc6_ = 0;
         var _loc5_:ObjectVO = null;
         var _loc2_:Rectangle = null;
         if(isDeleted)
         {
            return;
         }
         if(!canUseKeyAfterZS())
         {
            addEventListeners();
            if(_player1 && !_player1.deleted)
            {
               _player1.keyboard.reset();
               _player1.keyControl.reset();
            }
            if(_player2 && !_player2.deleted)
            {
               _player2.keyboard.reset();
               _player2.keyControl.reset();
            }
         }
         if(_bgContainerC)
         {
            _loc3_ = new ColorTransform();
            _loc6_ = 0;
            while(_loc6_ < _bgContainer.numChildren)
            {
               _loc1_ = _bgContainer.getChildAt(_loc6_);
               if(_loc1_)
               {
                  _loc1_.transform.colorTransform = _loc3_;
               }
               _loc6_++;
            }
            _frontContainer.transform.colorTransform = _frontContainerC;
            _manContainer.transform.colorTransform = _manContainerC;
            _man2Container.transform.colorTransform = _man2ContainerC;
            _manTopContainer.transform.colorTransform = _manTopContainerC;
         }
         var _loc7_:Vector.<TMXLayer> = _map.objectLayers;
         _loc8_ = 0;
         while(_loc8_ < _loc7_.length)
         {
            _loc4_ = _loc7_[_loc8_] as ObjectLayerContainer;
            _loc6_ = 0;
            while(_loc6_ < _loc4_.jiTriggers.length)
            {
               _loc5_ = _loc4_.jiTriggers[_loc6_].properties;
               if(_loc5_.properties.hasOwnProperty("triggerAtScreenMonsterDead"))
               {
                  _loc2_ = new Rectangle(_loc5_.x + _loc5_.width / 2,_loc5_.y + _loc5_.height / 2,_loc5_.width,_loc5_.height);
                  Entity(_loc4_.jiTriggers[_loc6_]).setPhysicsBody(_map.createJITrigger(_loc2_));
               }
               _loc6_++;
            }
            _loc8_++;
         }
      }
      
      override public function completeCatch(param1:int, param2:int) : void
      {
      }
      
      override public function addMask(param1:UserVO, param2:Number, param3:Boolean = true) : void
      {
         if(param1.isPk)
         {
            return;
         }
         var _loc4_:Entity = BattleModelManager.getIns().getPlayerByEntityId(param2);
         if(!_loc4_)
         {
            return;
         }
         if(_player1 && _player1.isDie == false)
         {
            if(_player1.direction == _loc4_.direction && param3)
            {
               return;
            }
         }
         else if(UserModelManager.getIns().getCurretPlayerInfo().pMode == 2)
         {
            if(_player2 && _player2.isDie == false)
            {
               if(_player2.direction == _loc4_.direction && param3)
               {
                  return;
               }
            }
         }
         if(isDeleted)
         {
            return;
         }
         if(_addedMask != 0)
         {
            return;
         }
         addChild(_maskShape);
         addChild(_maskShape1);
         this.mask = _maskShape;
         _addedMask = 1;
      }
      
      override public function removeMask() : void
      {
         if(isDeleted || this.mask == null)
         {
            return;
         }
         removeChild(_maskShape);
         removeChild(_maskShape1);
         this.mask = null;
         _addedMask = 0;
      }
      
      override public function pause() : void
      {
         if(_player1)
         {
            _player1.handKey(65,0);
            _player1.handKey(68,0);
         }
         if(_player2)
         {
            _player2.handKey(37,0);
            _player2.handKey(39,0);
         }
      }
      
      override public function addPlayer(param1:UserVO) : void
      {
         var _loc3_:AITree = null;
         if(_playerVec.length >= 20)
         {
            return;
         }
         if(param1.x == -1 && param1.y == -1)
         {
            param1.x = _levInfo.birthPoint.x;
            param1.y = _levInfo.birthPoint.y;
         }
         var _loc2_:RoleEntity = createPlayerByUerVO(param1,false);
         _loc2_.body.shapes.at(0).filter.collisionMask = 0x0100 | 0x0400 | 0x0800;
         _loc2_.body.shapes.at(1).filter.collisionMask = 0x0100 | 0x0400 | 0x0800;
         _loc2_.showName(16777215);
         if(param1.isPKBoss)
         {
            _loc3_ = BehaviorManager.getIns().createAIByAIid(_loc2_.userVo.configVo.aiId,_loc2_);
            _loc2_.setScreen(new Rectangle(0,0,screenWidth,_camera.stagePort.height));
         }
         onAddedPlayerAfter(_loc2_);
         _playerVec.push(_loc2_);
      }
      
      protected function onAddedPlayerAfter(param1:RoleEntity) : void
      {
      }
      
      override public function onPlayerMove(param1:Object) : void
      {
         var _loc3_:RoleEntity = null;
         var _loc4_:int = 0;
         var _loc2_:Number = Number(param1.uid);
         _loc4_ = 0;
         while(_loc4_ < _playerVec.length)
         {
            _loc3_ = _playerVec[_loc4_];
            if(_loc3_.userVo.userId == _loc2_ && _loc3_.userVo.ps == param1.ps)
            {
               break;
            }
            _loc3_ = null;
            _loc4_++;
         }
         if(_loc3_)
         {
            _loc3_.walkTo(param1.ex,param1.ey);
         }
      }
      
      override public function onPlayerLeave(param1:Object) : void
      {
         var _loc3_:RoleEntity = null;
         var _loc4_:int = 0;
         var _loc2_:Number = Number(param1.uid);
         _loc4_ = _playerVec.length - 1;
         while(_loc4_ >= 0)
         {
            _loc3_ = _playerVec[_loc4_];
            if(_loc3_.userVo.userId == _loc2_)
            {
               if(_loc3_.magicWeaponEntity)
               {
                  BattleModelManager.getIns().removeEntityByUid(_loc3_.magicWeaponEntity.Id,true);
               }
               BattleModelManager.getIns().removeEntityByUid(_loc3_.Id,true);
               _playerVec.splice(_loc4_,1);
            }
            _loc4_--;
         }
      }
      
      override public function addDecor(param1:DecorConfigVO) : void
      {
         super.addDecor(param1);
         switch(param1.layer)
         {
            case 0:
               _bgContainer.addChildDec(new DecorBasic(param1),_bgContainer.bg3);
               break;
            case 1:
               _bgContainer.addChildDec(new DecorBasic(param1),_bgContainer.bg2);
               break;
            case 2:
               _bgContainer.addChildDec(new DecorBasic(param1),_bgContainer.bg1);
               break;
            case 5:
               _frontContainer.addChildDec(new DecorBasic(param1),_bgContainer.bg1);
         }
      }
      
      override public function removeDecor(param1:DecorConfigVO) : void
      {
         super.removeDecor(param1);
         _bgContainer.removeChildDec(param1);
         _frontContainer.removeChildDec(param1);
      }
      
      override public function addWeather(param1:WeatherTrigger) : void
      {
         super.addWeather(param1);
         _weather = param1;
         tipsprite.addChild(_weather.display);
      }
      
      override public function ChangeProfession(param1:PlayerEntity) : void
      {
         var _loc5_:Buff9902101 = null;
         var _loc4_:UserVO = null;
         var _loc3_:RoleEntity = null;
         var _loc8_:BuffEffectEntity = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc2_:BuffEffectEntity = null;
         super.ChangeProfession(param1);
         var _loc9_:UserVO = param1.userVo;
         _loc9_.scaleX = param1.direction;
         _loc9_.tempChangeProfession = true;
         BuffModelManager.getIns().addInherit(_loc9_.entitieId);
         BuffModelManager.getIns().removeEntityBuffs(_loc9_.entitieId);
         _loc9_.tempChangeProfession = false;
         ApplicationFacade.getInstance().sendNotification("nfSkillMode",{"user":_loc9_});
         var _loc10_:Vec2 = param1.bodyPosition.copy();
         if(_loc9_.ps == 1)
         {
            if(_player1)
            {
               _loc5_ = _player1.buff9902101;
               BattleModelManager.getIns().removeEntityByUid(_player1.Id,false);
               _player1.destory();
               _player1 = null;
            }
         }
         else if(_loc9_.ps == 2)
         {
            if(_player2)
            {
               _loc5_ = _player2.buff9902101;
               BattleModelManager.getIns().removeEntityByUid(_player2.Id,false);
               _player2.destory();
               _player2 = null;
            }
            else if(_player1 && this._levInfo.isLegBoss())
            {
               _loc5_ = _player1.buff9902101;
               BattleModelManager.getIns().removeEntityByUid(_player1.Id,false);
               _player1.destory();
               _player1 = null;
            }
         }
         ApplicationFacade.getInstance().sendNotification("NF_UPDATE_BUFF_SCENE");
         if(_loc9_.children)
         {
            _loc4_ = _loc9_.children;
            _loc9_.currentChildern = _loc4_;
         }
         else
         {
            _loc4_ = _loc9_.parent;
            _loc4_.currentChildern = null;
         }
         _loc9_.clearCheckDead();
         _loc4_.magicWeapon = _loc9_.magicWeapon;
         _loc4_.magicWeapon2 = _loc9_.magicWeapon2;
         _loc4_.currentPet = _loc9_.currentPet;
         _loc4_.setHP(_loc9_.hp);
         _loc4_.setMP(_loc9_.mp);
         _loc4_.changeCD = 15000;
         if(VipModelManager.getIns().vipVo.id >= 6)
         {
            _loc4_.changeCD = 10000;
         }
         if(VipModelManager.getIns().vipVo.id >= 8)
         {
            _loc4_.changeCD = 5000;
         }
         _loc4_.x = _loc10_.x;
         _loc4_.y = _loc10_.y - 11;
         _loc4_.scaleX = _loc9_.scaleX;
         createPlayer1(_loc4_,_loc9_.ps,true);
         _loc4_.scaleX = _loc9_.scaleX = 1;
         _camera.follow(_player1,_player2);
         ApplicationFacade.getInstance().sendNotification("nfPlayerInfoChange",_loc4_);
         OnChangeProfessionAfter(param1);
         if(getNeexSceneBuff())
         {
            BuffSceneManager.getIns().Start(_loc4_.ps);
         }
         BuffModelManager.getIns().startInheirt(_loc9_.entitieId,_loc4_);
         BuffModelManager.getIns().advanceTime(33);
         swapManLayerChild();
         if(_loc5_ && BuffModelManager.getIns().getManBuffById(_loc4_.entitieId,9902101))
         {
            if(_loc9_.ps == 1)
            {
               _loc3_ = _player1;
            }
            else if(_loc9_.ps == 2)
            {
               _loc3_ = _player2;
            }
            _loc8_ = null;
            _loc6_ = _loc3_.getDisplayLayer(1).numChildren;
            _loc7_ = 0;
            while(_loc7_ < _loc6_)
            {
               _loc2_ = _loc3_.getDisplayLayer(1).getChildAt(_loc7_) as BuffEffectEntity;
               if(_loc2_ && _loc2_.buffvo && _loc2_.buffvo.config.id == 9902101)
               {
                  _loc8_ = _loc2_;
               }
               _loc7_++;
            }
            _loc3_.addBuff9902101(_loc5_.copy(_loc3_,_loc8_));
         }
      }
      
      protected function getNeexSceneBuff() : Boolean
      {
         return true;
      }
      
      protected function OnChangeProfessionAfter(param1:PlayerEntity) : void
      {
      }
      
      override public function checkResetBattleItem() : void
      {
         super.checkResetBattleItem();
         this.map.checkResetBattleItem();
      }
      
      override public function reInitSoulStone() : void
      {
         if(this._levInfo && this._levInfo.isXuMiS())
         {
            SoulStoneManager.getIns().clear();
            if(this._player1)
            {
               SoulStoneManager.getIns().Start(this._player1,this._player1.userVo);
            }
            if(this._player2)
            {
               SoulStoneManager.getIns().Start(this._player2,this._player2.userVo);
            }
         }
      }
      
      override public function addChildFrontLayer(param1:DisplayObject) : void
      {
         this._frontContainer.addChild(param1);
      }
      
      override public function get lwpos() : Vec2
      {
         if(_leftWall)
         {
            return _leftWall.position;
         }
         return null;
      }
      
      override public function get rwpos() : Vec2
      {
         if(_rightWall)
         {
            return _rightWall.position;
         }
         return null;
      }
      
      public function removeEnemy(param1:Entity) : void
      {
         var _loc3_:int = 0;
         var _loc2_:ManEntity = null;
         _loc3_ = 0;
         while(_loc3_ < _enemyVec.length)
         {
            _loc2_ = ManEntity(_enemyVec[_loc3_]);
            if(_loc2_ && _loc2_.Id == param1.Id)
            {
               _enemyVec.splice(_loc3_,1);
               break;
            }
            _loc3_++;
         }
      }
      
      public function canUseKeyAfterZS() : Boolean
      {
         var _loc1_:SystemVo = GameData.systemData.readSo();
         var _loc2_:int = 0;
         if(_loc1_)
         {
            _loc2_ = _loc1_.hasZs;
         }
         return _loc2_ == 1;
      }
   }
}

