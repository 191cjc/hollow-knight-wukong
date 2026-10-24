package models.managers
{
   import com.game.engine.animation.IAnimatable;
   import com.game.engine.battle.interfaces.ICollide;
   import com.game.engine.character.ActionState;
   import com.game.engine.core.GameFrame;
   import com.game.engine.utils.MathUtil;
   import com.game.engine.utils.SimpleTextLog;
   import com.game.utils.Singleton;
   import com.game.utils.Vector2D;
   import com.wdcgame.astart.world.aStar.AStar;
   import com.wdcgame.astart.world.aStar.Node;
   import controllers.SyncDropCmd;
   import controllers.battle.ContinueGameCmd;
   import controllers.battle.EnterGatewayCmd;
   import controllers.battle.MissonCompleteCmd;
   import controllers.team2.TeamHorseModelManager;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.net.SharedObject;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   import models.GameData;
   import models.configs.CombineConfigVO;
   import models.configs.CommonConfig;
   import models.configs.LevelConfigVO;
   import models.constants.ManType;
   import models.constants.RouteConst;
   import models.proxys.ArenaChallengeProxy;
   import models.vo.AttackInfoVO;
   import models.vo.BuffVO;
   import models.vo.DropVO;
   import models.vo.HorseVO;
   import models.vo.LeagueBossVO;
   import models.vo.LevelDropVo;
   import models.vo.LevelParam;
   import models.vo.MonsterBirthVO;
   import models.vo.NewLevelDropVO;
   import models.vo.PkLegBossVO;
   import models.vo.RoleConfigVO;
   import models.vo.ShipVO;
   import models.vo.SkillConfigVO;
   import models.vo.UserVO;
   import models.vo.horse.HorseInfoVo;
   import models.vo.module.ItemVoManager;
   import models.vo.module.UnionBossNewVo;
   import models.vo.pet.PetCrystalVo;
   import models.vo.pet.PetInfoVo;
   import models.vo.pet.PetListVo;
   import models.vo.players.FightSkillVo;
   import models.vo.players.ItemVo;
   import modules.ApplicationFacade;
   import modules.skywars.RigidBody;
   import modules.sword.model.SwordModelManager;
   import modules.utils.CreateComponent;
   import modules.utils.Unify;
   import nape.geom.AABB;
   import viewers.component.CreateMonsterTrigger;
   import viewers.container.BattleMap;
   import viewers.entitys.Entity;
   import viewers.entitys.Entity2;
   import viewers.entitys.boats.BoatEntity;
   import viewers.entitys.horses.HorseEntity;
   import viewers.entitys.man.MonsterEntity;
   import viewers.entitys.man.NpcEntity;
   import viewers.entitys.man.PlayerEntity;
   import viewers.entitys.man.RoleEntity;
   import viewers.entitys.man.SkillEntity;
   import viewers.entitys.man.enemys.E3013;
   import viewers.entitys.man.enemys.E3027;
   import viewers.entitys.man.enemys.E3325;
   import viewers.entitys.others.BattleItemEntity;
   import viewers.entitys.others.DropEntity;
   import viewers.entitys.prefabs.Prefab;
   import viewers.entitys.prefabs.WTrigger;
   
   public class BattleModelManager extends Singleton implements IAnimatable
   {
      
      public static const BAO_JI_RATIO:Number = 0.85;
      
      public static const DODGE_RATIO:Number = 0.34;
      
      public static var CurrentFrame:int = 0;
      
      public static const isNewLeagueBossHander:Boolean = true;
      
      public static var showProtect:Boolean = false;
      
      public static var showAbHb:Boolean;
      
      private static var _isNewDrop:Boolean;
      
      public static var showBaoJi:Boolean = true;
      
      public static var showXPValue:Boolean;
      
      public static var seaWarGoto1004:Boolean;
      
      public var screenTotal:int;
      
      private var _levelInfo:LevelConfigVO;
      
      public var countDownTime:int;
      
      public var hitCombo:int = 0;
      
      public var hitComboMax:int = 0;
      
      public var shouYuan:int;
      
      private var _hpToXPArr:Array;
      
      private var _dropItems:Vector.<DropEntity> = new Vector.<DropEntity>();
      
      public var copyLevel:int;
      
      private var _AttackInfos:Vector.<AttackInfoVO> = new Vector.<AttackInfoVO>();
      
      private var _battleSelectID:int = -1;
      
      public var recvSeq:int;
      
      private var _notClearAssetMonsters:Dictionary = new Dictionary();
      
      private var _monsterEntityIds:Array = [];
      
      public var nowPlayer:UserVO;
      
      public var gameData:Object = {};
      
      private var _entitys:Vector.<Entity> = new Vector.<Entity>();
      
      private var _entity2s:Vector.<Entity2> = new Vector.<Entity2>();
      
      private var _monsterTotal:int;
      
      private var _nowScreen:int = 0;
      
      public var isSeeOtherPlayerInWroldBoss:Boolean = true;
      
      private var _pkPetVos:Vector.<UserVO> = new Vector.<UserVO>();
      
      private var _userList:Vector.<UserVO> = new Vector.<UserVO>();
      
      private var _userList2:Vector.<UserVO> = new Vector.<UserVO>();
      
      private var _monsterTotalObj:Object = {};
      
      private var _ID:int = 0;
      
      public var meCampId:int;
      
      public var otherCampId:int = 2;
      
      public var pkUservo:UserVO;
      
      public var pkUserVos:Vector.<UserVO>;
      
      public var MonsterAI:Boolean = true;
      
      private var _randomSeed:Number;
      
      private var _camp1:Vector.<ICollide> = new Vector.<ICollide>();
      
      private var _camp1Att:Vector.<ICollide> = new Vector.<ICollide>();
      
      private var _camp2:Vector.<ICollide> = new Vector.<ICollide>();
      
      private var _camp2Att:Vector.<ICollide> = new Vector.<ICollide>();
      
      private var _camp3:Vector.<ICollide> = new Vector.<ICollide>();
      
      private var _camp3Att:Vector.<ICollide> = new Vector.<ICollide>();
      
      private var _camp4:Vector.<ICollide> = new Vector.<ICollide>();
      
      private var _camp4Att:Vector.<ICollide> = new Vector.<ICollide>();
      
      private var _camp5:Vector.<ICollide> = new Vector.<ICollide>();
      
      private var _camp5Att:Vector.<ICollide> = new Vector.<ICollide>();
      
      private var _screenMonsterTrigger:Dictionary = new Dictionary();
      
      private var _createMonsterTriggers:Vector.<CreateMonsterTrigger> = new Vector.<CreateMonsterTrigger>();
      
      private var _horseEntitys:Vector.<Entity>;
      
      private var _secTime:Number = 0;
      
      private var _enterCopyResponse:Object;
      
      private var _pickObject:Object;
      
      private var _finishCopy:Object;
      
      private var _deletedItems:Object;
      
      private var _lastHitTime:int = 0;
      
      private var _startTime:int;
      
      public var stagePort:Rectangle;
      
      public var lockStagePort:Rectangle;
      
      public var viewPort:Rectangle;
      
      private var _dropLevelVo:LevelDropVo;
      
      private var _dropObjects:Object = {};
      
      private var _hurtMan:Object = {};
      
      private var _killMonsters:Array;
      
      private var __test:Object;
      
      private var ss:Shape;
      
      private var _pkUser1:Vector.<UserVO>;
      
      private var _pkUser2:Vector.<UserVO>;
      
      private var _pkPetInfo1:Vector.<PetInfoVo> = new Vector.<PetInfoVo>();
      
      private var _pkPetInfo2:Vector.<PetInfoVo> = new Vector.<PetInfoVo>();
      
      private var _pkEndData:Object = {};
      
      public var resurrectionTime:int;
      
      private var mapEid:int = 1;
      
      private var _keyDowns:Object = {};
      
      private var _keyUps:Object = {};
      
      private var _calKey:Array;
      
      private var _recored:Boolean;
      
      private var _baoxian:Object;
      
      private var _mapGrid:Array;
      
      public var astar:AStar;
      
      private var _searWarClearMaps:Vector.<int> = new Vector.<int>();
      
      private var _currentCombineConfig:CombineConfigVO;
      
      public var lastSearWaMap:int = -1;
      
      public var CurrentDecor:Array = [];
      
      private var _pkBossAttInfo:Object = {};
      
      private var _pkLegBossVO:PkLegBossVO;
      
      private var _leagueBossVO:LeagueBossVO;
      
      public var InMapNextFunctionString:String = "";
      
      public var isOnLine:Boolean;
      
      public var maxFrame:int;
      
      public var isP2Pk:Boolean;
      
      private var _isTeam:Boolean;
      
      private var _takeMorePets:Vector.<int> = new Vector.<int>();
      
      private var _petTrain2:Vector.<int> = new Vector.<int>();
      
      private var _petTrainReward:Object = {};
      
      public var teamStartTime:Number;
      
      public var teamEnterTime:Number;
      
      public var teamNowTime:Number;
      
      public var lasetLevel:LevelConfigVO;
      
      private var _currLevel:LevelConfigVO;
      
      private var _currPlayerPos:Vector2D;
      
      private var _currPlayerPosInLuoHanYuan:Vector2D;
      
      private var _levelParam:LevelParam;
      
      private var _testJoinIndex:int;
      
      private var _testShapes:Array;
      
      public function BattleModelManager()
      {
         super();
         init();
      }
      
      public static function get isNewDrop() : Boolean
      {
         return _isNewDrop;
      }
      
      public static function getIns() : BattleModelManager
      {
         return Singleton.getIns(BattleModelManager);
      }
      
      public static function calDamageLuck(param1:Number, param2:Number) : Number
      {
         var _loc4_:Number = param1 * (1 + param2 / 500 - 1) + 1;
         var _loc3_:Number = Math.min(1 + param2 / 500,1.34);
         _loc4_ = param1 * (_loc3_ - 1) + 1;
         if(SkillDebugModelManager.average)
         {
            _loc4_ = 0.5 * (_loc3_ - 1) + 1;
         }
         return _loc4_;
      }
      
      public static function checkDodge(param1:UserVO) : Boolean
      {
         var _loc3_:Number = param1.dodgeNum / param1.hurtNum;
         var _loc2_:Boolean = true;
         if(_loc3_ >= 0.34)
         {
            return false;
         }
         return _loc2_;
      }
      
      public static function calDodge(param1:UserVO, param2:UserVO) : Number
      {
         var _loc3_:Number = 1;
         var _loc4_:Number = param1.allhit - param2.dodge;
         var _loc5_:Number = _loc3_ + _loc4_;
         _loc5_ = MathUtil.decimal(_loc5_,4);
         if(_loc5_ < 0.34)
         {
            _loc5_ = 0.34;
         }
         if(_loc5_ < 0.25 && param2.charID == 2004)
         {
            _loc5_ = 0.25;
         }
         return _loc5_;
      }
      
      public static function setMonsterTrigger(param1:int) : void
      {
      }
      
      public static function getLeagueBossRoute(param1:String, param2:String) : String
      {
         return param2;
      }
      
      public static function showDiDanHp(param1:Number, param2:Entity) : void
      {
         var _loc3_:AttackInfoVO = new AttackInfoVO();
         _loc3_.didan = param1;
         _loc3_.pos = param2.display.localToGlobal(new Point(0,-120));
         ApplicationFacade.getInstance().sendNotification("NF_ENTITY_DIDAN",_loc3_);
      }
      
      public static function getCartoonShow(param1:int) : Boolean
      {
         var _loc3_:Object = null;
         var _loc6_:Object = null;
         var _loc4_:String = UserModelManager.getIns().getCurretPlayerInfo()._id;
         var _loc2_:Object = RecordNewManager.getIns().clientStore;
         if(_loc2_)
         {
            _loc3_ = Unify.getServerData("cartoonShow");
            if(_loc3_)
            {
               _loc6_ = _loc3_[_loc4_ + "cartoon_" + param1];
               if(_loc6_)
               {
                  if(_loc6_.date == DateModelManager.getIns().getFullDateTime(DateModelManager.getIns().getServeDate().time))
                  {
                     return false;
                  }
                  if(_loc6_.neverShow)
                  {
                     return false;
                  }
               }
            }
         }
         var _loc5_:SharedObject = SharedObject.getLocal(_loc4_ + "cartoon_" + param1);
         if(_loc5_.data.date == DateModelManager.getIns().getFullDateTime(DateModelManager.getIns().getServeDate().time))
         {
            return false;
         }
         if(_loc5_.data.neverShow)
         {
            return false;
         }
         return true;
      }
      
      public static function saveCartoonShow(param1:int, param2:Boolean, param3:int) : void
      {
         var _loc5_:Object = null;
         var _loc7_:Object = null;
         if(param1 == 0)
         {
            param1 = int(BattleModelManager.getIns().levelInfo.id);
         }
         var _loc6_:String = UserModelManager.getIns().getCurretPlayerInfo()._id;
         var _loc4_:Object = RecordNewManager.getIns().clientStore;
         if(_loc4_)
         {
            _loc5_ = Unify.getServerData("cartoonShow") || {};
            _loc7_ = _loc5_[_loc6_ + "cartoon_" + param1] || {};
            _loc5_[_loc6_ + "cartoon_" + param1] = _loc7_;
            if(param2)
            {
               _loc7_["date"] = DateModelManager.getIns().getFullDateTime(DateModelManager.getIns().getServeDate().time);
            }
            else
            {
               delete _loc7_["date"];
            }
            _loc7_["neverShow"] = param3 == 1;
            Unify.setServerData("cartoonShow",_loc5_);
         }
      }
      
      public static function isAttack(param1:SkillConfigVO, param2:UserVO, param3:Boolean = false) : Boolean
      {
         if(param1 && param2)
         {
            if(param3 && param2.type != "role")
            {
               return false;
            }
            if(param2.configVo.attack1 != param1.id)
            {
               if(param2.configVo.attack2 != param1.id)
               {
                  if(param2.configVo.attack3 != param1.id)
                  {
                     if(param2.configVo.attack4 != param1.id)
                     {
                        if(param2.configVo.attack5 != param1.id)
                        {
                           if(param2.configVo.runAttack != param1.id)
                           {
                              if(param2.configVo.jumpAttack != param1.id)
                              {
                                 if(!param1.isAttack)
                                 {
                                    return false;
                                 }
                              }
                           }
                        }
                     }
                  }
               }
            }
            return true;
         }
         return false;
      }
      
      public function get pickObject() : Object
      {
         return _pickObject;
      }
      
      public function get userList2() : Vector.<UserVO>
      {
         return _userList2;
      }
      
      public function get isTeam() : Boolean
      {
         return _isTeam;
      }
      
      public function set isTeam(param1:Boolean) : void
      {
         _isTeam = param1;
      }
      
      public function get petTrain1() : Vector.<PetInfoVo>
      {
         return _pkPetInfo1;
      }
      
      public function setPetTrain1(param1:Vector.<PetInfoVo>) : void
      {
         var _loc2_:int = 0;
         if(param1.length < 3)
         {
            throw new Error("上场宠物数量为0");
         }
         _pkPetInfo1.length = 0;
         _loc2_ = 0;
         while(_loc2_ < param1.length)
         {
            _pkPetInfo1.push(param1[_loc2_]);
            _loc2_++;
         }
      }
      
      public function get petTrain2() : Vector.<int>
      {
         return _petTrain2;
      }
      
      public function setPetTrain2(param1:*) : void
      {
         var _loc2_:int = 0;
         _petTrain2.length = 0;
         _loc2_ = 0;
         while(_loc2_ < param1.length)
         {
            _petTrain2.push(param1[_loc2_]);
            _loc2_++;
         }
      }
      
      public function get petTrainReward() : Object
      {
         return _petTrainReward;
      }
      
      public function setPetTrainReward(param1:int, param2:Object) : void
      {
         _petTrainReward[param1] = param2;
      }
      
      public function get pkPetInfo2() : Vector.<PetInfoVo>
      {
         return _pkPetInfo2;
      }
      
      public function get pkPetInfo1() : Vector.<PetInfoVo>
      {
         return _pkPetInfo1;
      }
      
      public function get randomSeed() : Number
      {
         return _randomSeed;
      }
      
      public function set randomSeed(param1:Number) : void
      {
         _randomSeed = param1;
      }
      
      public function get pkLegBossVO() : LeagueBossVO
      {
         return LeagueBossVO.getIns();
      }
      
      public function get monsterTotalObj() : Object
      {
         return _monsterTotalObj;
      }
      
      public function get searWarClearMaps() : Vector.<int>
      {
         return _searWarClearMaps;
      }
      
      public function get mapGrid() : Array
      {
         return _mapGrid;
      }
      
      public function set mapGrid(param1:Array) : void
      {
         _mapGrid = param1;
      }
      
      public function get baoxianTotal() : Object
      {
         return _baoxian;
      }
      
      public function get enterCopyResponse() : Object
      {
         return _enterCopyResponse;
      }
      
      public function get screenMonsterTrigger() : Dictionary
      {
         return _screenMonsterTrigger;
      }
      
      public function get pkEndData() : Object
      {
         return _pkEndData;
      }
      
      public function get pkUser2() : Vector.<UserVO>
      {
         return _pkUser2;
      }
      
      public function set pkUser2(param1:Vector.<UserVO>) : void
      {
         _pkUser2 = param1;
      }
      
      public function get pkUser1() : Vector.<UserVO>
      {
         return _pkUser1;
      }
      
      public function get finishCopy() : Object
      {
         return _finishCopy;
      }
      
      public function getCamp3Att() : Vector.<ICollide>
      {
         return _camp3Att;
      }
      
      public function getCamp2Att() : Vector.<ICollide>
      {
         return _camp2Att;
      }
      
      public function getCamp4Att() : Vector.<ICollide>
      {
         return _camp4Att;
      }
      
      public function getCamp5Att() : Vector.<ICollide>
      {
         return _camp5Att;
      }
      
      public function getCamp1Att() : Vector.<ICollide>
      {
         return _camp1Att;
      }
      
      public function get entitys() : Vector.<Entity>
      {
         return _entitys;
      }
      
      public function get entity2s() : Vector.<Entity2>
      {
         return _entity2s;
      }
      
      public function get monsterTotal() : int
      {
         return _monsterTotal;
      }
      
      public function get pkPetVos() : Vector.<UserVO>
      {
         return _pkPetVos;
      }
      
      public function get levelInfo() : LevelConfigVO
      {
         return _levelInfo;
      }
      
      public function set levelInfo(param1:LevelConfigVO) : void
      {
         var _loc2_:LevelParam = null;
         _levelInfo = param1;
         if(param1)
         {
            param1.clearUser();
         }
         if(GlobalData.getOpenJoinBattle())
         {
            if(levelParam)
            {
               levelParam.destroy();
            }
            _loc2_ = new LevelParam(param1);
            this.setCurrentLevelParam(_loc2_);
            UserModelManager.getIns().playerUserVo1.isNotJoinBattle = GameData.systemData.readSo().pNum == 1;
            UserModelManager.getIns().playerUserVo1.children.isNotJoinBattle = UserModelManager.getIns().playerUserVo1.children2.isNotJoinBattle = UserModelManager.getIns().playerUserVo1.isNotJoinBattle;
            if(UserModelManager.getIns().playerUserVo2)
            {
               UserModelManager.getIns().playerUserVo2.isNotJoinBattle = GameData.systemData.readSo().pNum == 2;
               UserModelManager.getIns().playerUserVo2.children.isNotJoinBattle = UserModelManager.getIns().playerUserVo2.children2.isNotJoinBattle = UserModelManager.getIns().playerUserVo2.isNotJoinBattle;
               UserModelManager.getIns().playerUserVo1.delKey2();
               UserModelManager.getIns().playerUserVo1.children.delKey2();
               UserModelManager.getIns().playerUserVo1.children2.delKey2();
               UserModelManager.getIns().playerUserVo2.delKey2();
               UserModelManager.getIns().playerUserVo2.children.delKey2();
               UserModelManager.getIns().playerUserVo2.children2.delKey2();
            }
            UserModelManager.getIns().playerUserVo1.forceJoinBattle = false;
            if(UserModelManager.getIns().playerUserVo2)
            {
               UserModelManager.getIns().playerUserVo2.forceJoinBattle = false;
            }
            if(TeamHorseModelManager.getIns().isPlaying)
            {
               UserModelManager.getIns().playerUserVo1.forceJoinBattle = true;
            }
         }
      }
      
      public function get levelParam() : LevelParam
      {
         return _levelParam;
      }
      
      public function setCurrentLevelParam(param1:LevelParam) : void
      {
         _levelParam = param1;
      }
      
      public function get dropItems() : Vector.<DropEntity>
      {
         return _dropItems;
      }
      
      public function get battleSelectID() : int
      {
         return _battleSelectID;
      }
      
      public function set battleSelectID(param1:int) : void
      {
         _battleSelectID = param1;
      }
      
      public function init() : void
      {
         MissonCompleteCmd.sended = false;
         EnterGatewayCmd.SEND = false;
         ContinueGameCmd.CREATED = false;
         _nowScreen = 0;
         hitCombo = 0;
         hitComboMax = 0;
         _lastHitTime = 0;
         resurrectionTime = 0;
         _hpToXPArr = [];
         _pkPetVos.length = 0;
         destory();
         _horseEntitys = new Vector.<Entity>();
         _secTime = 0;
         clearPick();
         clearCreateMonsterTrigger();
         DropModelManager.getIns().init();
         _hurtMan = {};
         _killMonsters = [];
         if(_userList)
         {
            _userList.length = 0;
         }
         _userList2.length = 0;
         _dropItems.length = 0;
         _calKey = [];
         _recored = false;
         _monsterTotalObj = {};
         _pkBossAttInfo = {};
         SyncDropCmd._list.length = 0;
         SyncDropCmd.LOADING = false;
         gameData = {};
         _isNewDrop = false;
      }
      
      public function calXP(param1:UserVO, param2:UserVO, param3:SkillConfigVO, param4:Number) : int
      {
         var _loc8_:int = 0;
         var _loc7_:int = 0;
         var _loc6_:int = 0;
         var _loc5_:int = param2.hp / param2.hpMax * 100;
         if(_loc5_ < 100 && _loc5_ >= 0)
         {
            if(!_hpToXPArr[param2.entitieId])
            {
               _hpToXPArr[param2.entitieId] = [];
               _hpToXPArr[param2.entitieId] = new Array(100);
               _loc8_ = 0;
               while(_loc8_ < _hpToXPArr[param2.entitieId].length)
               {
                  _hpToXPArr[param2.entitieId][_loc8_] = 0;
                  _loc8_++;
               }
            }
            _loc7_ = _loc5_;
            while(_loc7_ < 100)
            {
               if(_hpToXPArr[param2.entitieId][_loc7_] == 0)
               {
                  _hpToXPArr[param2.entitieId][_loc7_] = 1;
                  _loc6_ += CommonConfig.hpToXP;
                  param2.proScore += CommonConfig.bloodProScore * param4;
               }
               _loc7_++;
            }
         }
         if(_levelInfo)
         {
            _loc6_ = _levelInfo.updateXP(_loc6_);
         }
         param2.updateXP(_loc6_);
         return _loc6_;
      }
      
      public function calProtectPoint(param1:UserVO, param2:SkillConfigVO, param3:Number) : int
      {
         var _loc4_:int = 0;
         if(_hurtMan.hasOwnProperty(param1.entitieId) == false)
         {
            _hurtMan[param1.entitieId] = {};
         }
         if(_hurtMan[param1.entitieId].hasOwnProperty(param2.id) == false)
         {
            _hurtMan[param1.entitieId][param2.id] = 0;
         }
         _hurtMan[param1.entitieId][param2.id]++;
         var _loc5_:int = int(_hurtMan[param1.entitieId][param2.id]);
         param1.proScore += param2.protectPoint * _loc5_ * param3;
         return param1.proScore;
      }
      
      public function recalProtectPoint(param1:UserVO) : void
      {
         delete _hurtMan[param1.entitieId];
      }
      
      public function calDamage(param1:int, param2:UserVO, param3:UserVO, param4:SkillConfigVO, param5:Number, param6:String) : int
      {
         var _loc7_:int = 0;
         switch(param1 - 1)
         {
            case 0:
               _loc7_ = calPhysicalDamage(param2,param3,param4,param5,param4.getRealLevel,param4.type);
               break;
            case 1:
               _loc7_ = calSkillDamage(param2,param3,param4,param5,param4.getRealLevel,param4.type);
               break;
            case 2:
               _loc7_ = calPhysicalDamage(param2,param3,param4,param5,param4.getRealLevel,param4.type);
               break;
            case 3:
               _loc7_ = calSkillDamage(param2,param3,param4,param5,param4.getRealLevel,param4.type);
         }
         return _loc7_;
      }
      
      private function calPhysicalDamage(param1:UserVO, param2:UserVO, param3:SkillConfigVO, param4:Number, param5:int, param6:int) : int
      {
         var _loc14_:int = 0;
         var _loc11_:int = 0;
         if(param1.type == "role" && param5 > param3.level2 - 10 && param1.buff_add_skill_level == 0)
         {
         }
         if(param1.isLuoHan_ChenShi)
         {
            param5 = 1;
         }
         var _loc15_:Number = Math.min(param5,CommonConfig.skillAddMax);
         var _loc13_:Number = getRandom();
         var _loc10_:Number = param1.getCalDamageAtk() - param2.getCalDamagePhyDef();
         var _loc7_:Number = Math.max(_loc10_,1);
         var _loc8_:Number = calDamageLuck(_loc13_,param1.alllucky);
         var _loc12_:Number = param3.skillDefault + param3.skillAdd * _loc15_ + param3.horseSkillAdd * _loc15_;
         var _loc9_:Number = _loc7_ * _loc8_ * _loc12_ + param3.getSkillCountAdd(param5);
         _loc9_ = _loc9_ * param4;
         if(!SimpleTextLog.Close)
         {
            SimpleTextLog.getIns().log("r=" + _loc13_,"skillLev=" + param5,"at.getCalDamageAtk()=" + param1.getCalDamageAtk(),"hu.getCalDamagePhyDef()=" + param2.getCalDamagePhyDef(),"baoJi=" + param4,"C=" + _loc10_,"D=" + _loc7_,"E=" + _loc8_,"skillAdd=" + _loc12_,"G=" + _loc9_,"skill.skillDefault=" + param3.skillDefault,"skill.skillAdd=" + param3.skillAdd);
         }
         if(_loc9_ > 2147483647)
         {
            _loc9_ = 2147483647;
         }
         _loc14_ = Math.ceil(_loc9_);
         if(SimpleTextLog.getIns().txt.visible || !SimpleTextLog.Close)
         {
         }
         _loc10_ = param1.protectedData.getValue("atk") - param2.protectedData.getValue("phyDef");
         _loc7_ = Math.max(_loc10_,1);
         _loc8_ = _loc13_ * (1 + param1.protectedData.getValue("lucky") / 500 - 1) + 1;
         _loc12_ = param3.skillDefault + param3.skillAdd * _loc15_ + param3.horseSkillAdd * _loc15_;
         _loc9_ = _loc7_ * _loc8_ * _loc12_ + param3.getSkillCountAdd(param5);
         _loc9_ = _loc9_ * param4;
         if(_loc9_ > 2147483647)
         {
            _loc9_ = 2147483647;
         }
         _loc11_ = Math.ceil(_loc9_);
         if(param1 is ShipVO)
         {
            _loc14_ = _loc11_ = param1.atk - param2.phyDef;
         }
         if(_loc14_ <= 0)
         {
            _loc14_ = 1;
         }
         if(_loc11_ <= 0)
         {
            _loc11_ = 1;
         }
         return _loc14_;
      }
      
      private function calSkillDamage(param1:UserVO, param2:UserVO, param3:SkillConfigVO, param4:Number, param5:int, param6:int) : int
      {
         var _loc14_:int = 0;
         var _loc11_:int = 0;
         if(param1.type == "role" && param5 - 2 > param3.level2 - 10 && param1.buff_add_skill_level == 0)
         {
         }
         if(param1.isLuoHan_ChenShi)
         {
            param5 = 1;
         }
         var _loc15_:Number = Math.min(param5,CommonConfig.skillAddMax);
         var _loc13_:Number = getRandom();
         var _loc8_:Number = calDamageLuck(_loc13_,param1.alllucky);
         var _loc12_:Number = param3.skillDefault + param3.skillAdd * _loc15_ + param3.horseSkillAdd * _loc15_;
         var _loc9_:Number = param1.getCalDamageAtk() * _loc8_ * _loc12_ + param3.getSkillCountAdd(param5);
         if(isNaN(param2.magRes))
         {
            param2.magRes = 0;
         }
         if(isNaN(param1.reduceMagDef))
         {
            param1.reduceMagDef = 0;
         }
         var _loc10_:Number = 1 - Math.max(0,param2.allmagRes - param1.allreduceMagDef);
         var _loc7_:Number = _loc9_ * _loc10_;
         _loc7_ = _loc7_ * param4;
         _loc14_ = Math.ceil(_loc7_);
         SimpleTextLog.getIns().log2("A=" + _loc8_,"skillAdd=" + _loc12_,"at.getCalDamageAtk()=" + param1.getCalDamageAtk(),_loc9_,"C=" + _loc10_,"G=" + _loc7_,"baoji=" + param4,"skill.getSkillCountAdd(skillLev)=" + param3.getSkillCountAdd(param5),"skillLev=" + param5);
         _loc8_ = _loc13_ * (1 + param1.protectedData.getValue("lucky") / 500 - 1) + 1;
         _loc12_ = param3.skillDefault + param3.skillAdd * _loc15_ + param3.horseSkillAdd * _loc15_;
         _loc9_ = param1.protectedData.getValue("atk") * _loc8_ * _loc12_ + param3.getSkillCountAdd(param5);
         if(isNaN(param2.protectedData.getValue("magRes")))
         {
            param2.protectedData.setValue("magRes",0);
         }
         if(isNaN(param1.protectedData.getValue("reduceMagDef")))
         {
            param1.protectedData.setValue("reduceMagDef",0);
         }
         _loc10_ = 1 - Math.max(0,param2.protectedData.getValue("magRes") - param1.protectedData.getValue("reduceMagDef"));
         _loc7_ = _loc9_ * _loc10_;
         _loc7_ = _loc7_ * param4;
         _loc11_ = Math.ceil(_loc7_);
         if(_loc14_ <= 0)
         {
            _loc14_ = 1;
         }
         if(_loc11_ <= 0)
         {
            _loc11_ = 1;
         }
         return _loc14_;
      }
      
      public function calBuffTrigger(param1:UserVO, param2:UserVO, param3:SkillConfigVO, param4:BuffVO = null) : Boolean
      {
         if(!param3)
         {
            return false;
         }
         var _loc8_:Number = Math.min(param3.getRealLevel,CommonConfig.skillAddMax);
         var _loc7_:Number = param3.skillDefault + param3.skillAdd * _loc8_;
         var _loc5_:Number = 0.2;
         if(param4 && isNaN(param4.config.attributeV3) == false)
         {
            _loc5_ = param4.config.attributeV3;
            if(param4.config.cd > 0)
            {
               _loc7_ = 1;
            }
         }
         var _loc9_:Number = _loc5_ * _loc7_;
         var _loc6_:Number = getRandom();
         if(isNaN(_loc9_))
         {
            _loc9_ = 1;
         }
         SimpleTextLog.getIns().log2("calBuffTrigger rand=",_loc6_,"概率=" + _loc9_);
         if(_loc6_ < _loc9_ || _loc9_ >= 1)
         {
            return true;
         }
         return false;
      }
      
      public function getBaoJiAdd(param1:UserVO, param2:UserVO) : Number
      {
         var _loc3_:Number = param1.alllucky;
         var _loc5_:Number = param2.allguardian;
         var _loc6_:Number = 100 + _loc3_ - _loc5_;
         var _loc4_:Number = _loc6_ / 100;
         _loc4_ = MathUtil.decimal(_loc4_,4);
         if(_loc4_ < 0)
         {
            _loc4_ = 0;
         }
         if(_loc4_ > 2)
         {
            _loc4_ = 2;
         }
         return _loc4_;
      }
      
      public function calBaoJiDamage(param1:UserVO, param2:UserVO, param3:SkillConfigVO, param4:int) : int
      {
         var _loc5_:int = 0;
         var _loc6_:Number = getBaoJiAdd(param1,param2);
         if(param4 == 1 || param4 == 3)
         {
            _loc5_ = calPhysicalDamage(param1,param2,param3,1 + _loc6_,param3.getRealLevel,param3.type);
         }
         else if(param4 == 2 || param4 == 4)
         {
            _loc5_ = calSkillDamage(param1,param2,param3,1 + _loc6_,param3.getRealLevel,param3.type);
         }
         return _loc5_;
      }
      
      public function checkBaoJi(param1:UserVO) : Boolean
      {
         var _loc2_:Boolean = false;
         return true;
      }
      
      public function calBaoJi(param1:UserVO, param2:UserVO) : Number
      {
         var _loc5_:Number = NaN;
         var _loc3_:Number = Math.min(param1.allcritical - param2.alltoughness,0.85);
         var _loc4_:Number = Math.max((param1.allcritical - param2.alltoughness - 0.85) / 10,0);
         _loc5_ = MathUtil.decimal(_loc3_ + _loc4_,4);
         if(_loc5_ < 0)
         {
            _loc5_ = 0;
         }
         if(_loc5_ > 1)
         {
            _loc5_ = 1;
         }
         return _loc5_;
      }
      
      public function getRandom(param1:String = "") : Number
      {
         var _loc3_:Number = NaN;
         var _loc2_:Number = NaN;
         if(this.levelParam && this.levelParam.logic)
         {
            return this.levelParam.logic.getRandom(param1);
         }
         if(isOnLine == false)
         {
            return Math.random();
         }
         _loc3_ = _randomSeed;
         _loc2_ = (_loc3_ * 29 + 37) % 1000;
         _randomSeed = _loc2_;
         return _loc2_ / 1000;
      }
      
      public function addDropItems(param1:DropEntity) : void
      {
         _dropItems.push(param1);
         _dropItems.sort(dropcompare);
      }
      
      private function dropcompare(param1:DropEntity, param2:DropEntity) : int
      {
         if(param1.position.x < param2.position.x)
         {
            return -1;
         }
         if(param1.position.x > param2.position.x)
         {
            return 1;
         }
         return 0;
      }
      
      public function clearDropItems() : void
      {
         _dropItems.length = 0;
      }
      
      public function getGameTimer() : int
      {
         if(_levelParam && _levelParam.logic)
         {
            return _levelParam.logic.getTimer();
         }
         if(isOnLine)
         {
            return BattleModelManager.CurrentFrame * 33;
         }
         return int(Math.round(GameFrame.gameTime));
      }
      
      public function addNotClearAssetItemMonster(param1:Array) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < param1.length)
         {
            _notClearAssetMonsters[param1[_loc2_]] = param1[_loc2_];
            _loc2_++;
         }
      }
      
      public function getNotClearAssetItemMonster() : Dictionary
      {
         return _notClearAssetMonsters;
      }
      
      public function addMonsterEntityId(param1:int) : void
      {
         _monsterEntityIds.push(param1);
      }
      
      public function getMonsterEntityId() : Array
      {
         return _monsterEntityIds;
      }
      
      public function getSID() : int
      {
         _ID = _ID + 1;
         return _ID;
      }
      
      public function clearSID() : void
      {
         _ID = 0;
      }
      
      public function removeHurtManData() : void
      {
         if(_AttackInfos)
         {
            _AttackInfos.splice(0,_AttackInfos.length);
         }
      }
      
      public function checkHurtManData() : void
      {
         var _loc24_:AttackInfoVO = null;
         var _loc8_:AttackInfoVO = null;
         var _loc20_:Object = null;
         var _loc17_:int = 0;
         var _loc1_:int = 0;
         var _loc14_:Object = null;
         var _loc5_:int = 0;
         var _loc28_:PlayerEntity = null;
         _loc5_ = 0;
         _loc28_ = null;
         var _loc12_:BuffVO = null;
         var _loc29_:* = undefined;
         var _loc16_:Number = NaN;
         var _loc26_:Number = NaN;
         var _loc19_:PlayerEntity = null;
         var _loc7_:int = 0;
         var _loc4_:Array = null;
         _loc7_ = 0;
         var _loc2_:int = 0;
         var _loc15_:Array = null;
         var _loc11_:Number = NaN;
         var _loc25_:UserVO = null;
         var _loc30_:AttackInfoVO = null;
         var _loc13_:Array = null;
         var _loc21_:int = 0;
         var _loc23_:int = 0;
         var _loc9_:SkillConfigVO = null;
         var _loc10_:UserVO = null;
         var _loc22_:int = 0;
         var _loc18_:int = 0;
         var _loc27_:Object = null;
         var _loc6_:Number = NaN;
         _loc18_ = 0;
         _loc27_ = null;
         var _loc3_:Boolean = false;
         if(_AttackInfos.length > 0)
         {
            _loc20_ = {};
            _loc17_ = 0;
            while(_loc17_ < _AttackInfos.length)
            {
               _loc8_ = _AttackInfos[_loc17_];
               _loc20_[_loc8_.attUserVo.entitieId] = _loc8_;
               _loc24_ = _loc8_;
               if(_loc8_.attUserVo.isPKBoss && _loc8_.attUserVo.boss == 0)
               {
                  if(this.levelInfo && this.levelInfo.isLegBoss())
                  {
                     if(!_pkBossAttInfo.hasOwnProperty("bossIndex"))
                     {
                        _pkBossAttInfo.bossIndex = LeagueBossVO.getIns().bossIndex;
                     }
                     if(!_pkBossAttInfo.hasOwnProperty("hurt"))
                     {
                        _pkBossAttInfo.hurt = 0;
                     }
                     _pkBossAttInfo.hurt += _loc8_.damageValue;
                  }
                  else
                  {
                     if(_pkBossAttInfo.hasOwnProperty(_loc8_.attUserVo.charID) == false)
                     {
                        _pkBossAttInfo[_loc8_.attUserVo.charID] = [];
                     }
                     _loc1_ = 0;
                     if(_loc8_.attSkill)
                     {
                        _loc1_ = _loc8_.attSkill.id;
                     }
                     _loc14_ = {
                        "atk":_loc8_.attUserVo.charID,
                        "pNum":_loc8_.attUserVo.ps,
                        "hurt":_loc8_.hurUserVo.charID,
                        "skId":_loc1_,
                        "skInd":_loc8_.ind,
                        "damage":_loc8_.damageValue
                     };
                     _pkBossAttInfo[_loc8_.attUserVo.charID].push(_loc14_);
                  }
               }
               if([2003].indexOf(_loc24_.attUserVo.charID) > -1)
               {
                  if(_loc24_.attSkill.addXPTotal < _loc24_.attSkill.addXP * _loc24_.attSkill.attMax)
                  {
                     _loc5_ = _loc24_.attSkill.addXP;
                     if(_levelInfo)
                     {
                        _loc5_ = _levelInfo.updateXP(_loc5_);
                     }
                     _loc24_.attUserVo.updateXP(_loc5_);
                     _loc28_ = getPlayerByEntityId(_loc24_.attUserVo.entitieId) as PlayerEntity;
                     if(_loc28_)
                     {
                        _loc28_.onGetXP(_loc5_);
                     }
                     if(_loc24_.hurUserVo && _loc24_.hurUserVo.propertyVo)
                     {
                        _loc24_.hurUserVo.propertyVo.addXP(_loc5_);
                     }
                     _loc24_.attSkill.addXPTotal += _loc5_;
                  }
                  _loc3_ = true;
               }
               _loc17_++;
            }
            for each(_loc24_ in _loc20_)
            {
               if(!(_loc24_.attUserVo.isDie || !_loc24_.attSkill))
               {
                  if(!_loc3_)
                  {
                     if(_loc24_.attSkill.addXPTotal < _loc24_.attSkill.addXP * _loc24_.attSkill.attMax)
                     {
                        _loc5_ = _loc24_.attSkill.addXP;
                        if(_levelInfo)
                        {
                           _loc5_ = _levelInfo.updateXP(_loc5_);
                        }
                        _loc24_.attUserVo.updateXP(_loc5_);
                        _loc28_ = getPlayerByEntityId(_loc24_.attUserVo.entitieId) as PlayerEntity;
                        if(_loc28_)
                        {
                           _loc28_.onGetXP(_loc5_);
                        }
                        if(_loc24_.hurUserVo && _loc24_.hurUserVo.propertyVo)
                        {
                           _loc24_.hurUserVo.propertyVo.addXP(_loc5_);
                        }
                        _loc24_.attSkill.addXPTotal += _loc5_;
                     }
                     else
                     {
                        _loc24_;
                     }
                  }
                  _loc12_ = BuffModelManager.getIns().getHasBuff81(_loc24_.attUserVo.entitieId);
                  if(_loc12_ && (_loc12_.config.triggerNum > 0 && _loc24_.attSkill.addBuff81 < _loc12_.config.triggerNum * _loc24_.attSkill.attMax || _loc12_.config.triggerNum < 1))
                  {
                     _loc24_.attSkill.addBuff81++;
                     _loc29_ = Math.min(_loc24_.attSkill.getRealLevel,CommonConfig.skillAddMax);
                     _loc16_ = _loc24_.attSkill.skillDefault + _loc24_.attSkill.skillAdd * _loc29_;
                     _loc26_ = _loc12_.config.attributeV1 * (_loc24_.attUserVo.getCalDamageAtk() * _loc16_ + int(_loc24_.attSkill.getSkillCountAdd(_loc24_.attSkill.getRealLevel))) + _loc12_.config.attributeV2;
                     if(_loc26_ > 0)
                     {
                        if(_loc24_.attUserVo.canAddHp == false)
                        {
                           _loc26_ = 0;
                        }
                     }
                     _loc26_ = _loc24_.attUserVo.getHpValue(_loc26_);
                     if(isNaN(_loc24_.attUserVo.buff_reduce_hpPer))
                     {
                        _loc24_.attUserVo.buff_reduce_hpPer = 1;
                     }
                     if(_loc26_ < 0)
                     {
                        _loc26_ *= _loc24_.attUserVo.buff_reduce_hpPer;
                        _loc19_ = getPlayerByEntityId(_loc24_.hurUserVo.entitieId) as PlayerEntity;
                        if(_loc19_ && _loc19_ is PlayerEntity)
                        {
                           _loc26_ *= PlayerEntity(_loc19_).getBuff89V1();
                        }
                        _loc24_.attUserVo.buff_reduce_hpTotal += _loc26_;
                     }
                     _loc26_ = _loc24_.attUserVo.calRealReducehp(_loc26_,false);
                     _loc24_.attUserVo.updateHP(_loc26_,false);
                     ApplicationFacade.getInstance().sendNotification("nfPlayerInfoChange",_loc24_.attUserVo);
                     ApplicationFacade.getInstance().sendNotification("nfEntityHurtAuto",{
                        "userVo":_loc24_.attUserVo,
                        "hp":_loc26_,
                        "from":"t8"
                     });
                     break;
                  }
               }
            }
            checkGaiLibuff(_loc20_);
            _loc7_ = 0;
            while(_loc7_ < _AttackInfos.length)
            {
               _loc8_ = _AttackInfos[_loc7_];
               checkGaiLibuff2(_loc8_);
               _loc7_++;
            }
            _loc20_ = {};
            _loc4_ = [];
            _loc7_ = 0;
            while(_loc7_ < _AttackInfos.length)
            {
               _loc24_ = _AttackInfos[_loc7_];
               if(!_loc20_[_loc24_.attUserVo.entitieId])
               {
                  _loc20_[_loc24_.attUserVo.entitieId] = [_loc24_];
                  _loc4_.push(_loc24_.attUserVo.entitieId);
               }
               else
               {
                  _loc20_[_loc24_.attUserVo.entitieId].push(_loc24_);
               }
               _loc7_++;
            }
            _loc24_ = null;
            _loc4_;
            _loc2_ = 0;
            while(_loc2_ < _loc4_.length)
            {
               _loc15_ = _loc20_[_loc4_[_loc2_]];
               _loc11_ = 0;
               _loc25_ = null;
               _loc30_ = null;
               _loc13_ = [];
               _loc21_ = 0;
               while(_loc21_ < _loc15_.length)
               {
                  _loc24_ = _loc15_[_loc21_];
                  if(!(_loc24_.bySuckBlood == 0 || _loc24_.attUserVo.isDie || !_loc24_.attSkill || !_loc24_.hurUserVo || !_loc24_.hurUserVo.configVo || _loc24_.hurUserVo.configVo.bySuckBlood == 0 || _loc24_.damageType == 2))
                  {
                     if(_loc24_.damageValue > 0 && _loc24_.attSkill.suckBloodNum < _loc24_.attSkill.attMax)
                     {
                        _loc24_.attSkill.suckBloodNum++;
                        _loc23_ = BattleModelManager.getIns().calSuckBlood(_loc24_.attUserVo,_loc24_.attSkill,_loc24_.damageValue);
                        if(_loc24_.attUserVo.canAddHp == false)
                        {
                           _loc23_ = 0;
                        }
                        if(_loc24_.attSkill.suckBloodShare)
                        {
                           _loc9_ = _loc24_.attUserVo.getSkillConfigVO(_loc24_.attSkill.suckBloodShare[1]);
                           if(_loc9_)
                           {
                              if(_loc9_.suckBloodNum < int(_loc24_.attSkill.suckBloodShare[0]))
                              {
                                 _loc9_.suckBloodNum++;
                              }
                              else
                              {
                                 _loc23_ = 0;
                              }
                           }
                        }
                        if(_loc23_ > 0)
                        {
                           _loc10_ = _loc24_.attUserVo;
                           if(_loc24_.attUserVo.type == "role" && UserModelManager.getIns().isRole(_loc10_.charID))
                           {
                              _loc10_ = _loc24_.attUserVo.getRootUservo().getCurrentUVO();
                           }
                           if(!isNaN(_loc10_.petPk_suckBlood_backLash_damageRatio) && _loc10_.petPk_suckBlood_backLash_damageRatio > 0)
                           {
                              _loc23_ *= _loc10_.petPk_suckBlood_backLash_damageRatio;
                           }
                           _loc23_ = _loc10_.calRealReducehp(_loc23_,false);
                           _loc13_.push({
                              "userVo":_loc10_,
                              "hp":_loc23_,
                              "hurUserVo":_loc24_.hurUserVo
                           });
                        }
                     }
                     if(_loc24_.didan >= 0)
                     {
                        if(_loc24_.hurUserVo.allbackLash > _loc11_ && _loc24_.attSkill.backLashNum < _loc24_.attSkill.attMax)
                        {
                           _loc24_.attSkill.backLashNum++;
                           _loc25_ = _loc24_.hurUserVo;
                           _loc11_ = _loc24_.hurUserVo.allbackLash;
                           _loc30_ = _loc24_;
                        }
                     }
                  }
                  _loc21_++;
               }
               if(_loc25_ && _loc30_)
               {
                  _loc22_ = BattleModelManager.getIns().calBackLash(_loc30_.attUserVo,_loc30_.hurUserVo,_loc30_.attSkill,_loc30_.damageValue);
                  _loc18_ = _loc13_.length - 1;
                  while(_loc18_ >= 0)
                  {
                     _loc27_ = _loc13_[_loc18_];
                     if(_loc27_.userVo.entitieId == _loc30_.attUserVo.entitieId && _loc27_.hurUserVo.entitieId == _loc30_.hurUserVo.entitieId)
                     {
                        _loc6_ = _loc22_;
                        _loc22_ -= _loc27_.hp;
                        if(_loc22_ < 0)
                        {
                           _loc27_.hp -= Math.abs(_loc6_);
                           break;
                        }
                        _loc13_.splice(_loc18_,1);
                        _loc27_.hp = 0;
                     }
                     _loc18_--;
                  }
                  if(_loc22_ > 0)
                  {
                     if(_loc30_.attSkill)
                     {
                        SimpleTextLog.getIns().log2("反伤给谁 attinfo=======",_loc30_.attSkill.name,_loc30_.attUserVo.name);
                     }
                     if(!isNaN(_loc30_.attUserVo.petPk_suckBlood_backLash_damageRatio) && _loc30_.attUserVo.petPk_suckBlood_backLash_damageRatio > 0)
                     {
                        _loc22_ *= _loc30_.attUserVo.petPk_suckBlood_backLash_damageRatio;
                     }
                     _loc22_ = _loc30_.attUserVo.calRealReducehp(_loc22_,true);
                     _loc30_.attUserVo.updateHP(-_loc22_,false);
                     ApplicationFacade.getInstance().sendNotification("nfEntityHurtAuto",{
                        "userVo":_loc30_.attUserVo,
                        "hp":-_loc22_,
                        "from":"fangs"
                     });
                  }
               }
               _loc18_ = 0;
               while(_loc18_ < _loc13_.length)
               {
                  _loc27_ = _loc13_[_loc18_];
                  _loc27_.userVo.updateHP(_loc27_.hp,false);
                  ApplicationFacade.getInstance().sendNotification("nfPlayerInfoChange",_loc27_.userVo);
                  ApplicationFacade.getInstance().sendNotification("nfEntityHurtAuto",{
                     "userVo":_loc27_.userVo,
                     "hp":_loc27_.hp,
                     "from":"t82"
                  });
                  _loc18_++;
               }
               _loc2_++;
            }
         }
      }
      
      private function checkGaiLibuff(param1:Object) : void
      {
         var _loc9_:int = 0;
         var _loc3_:AttackInfoVO = null;
         var _loc4_:UserVO = null;
         var _loc6_:UserVO = null;
         var _loc5_:SkillConfigVO = null;
         var _loc12_:int = 0;
         var _loc8_:BuffVO = null;
         var _loc11_:Boolean = false;
         var _loc7_:PlayerEntity = null;
         var _loc2_:Array = [];
         for(var _loc10_:int in param1)
         {
            _loc2_.push(_loc10_);
         }
         _loc2_.sort(16);
         _loc9_ = 0;
         while(_loc9_ < _loc2_.length)
         {
            _loc3_ = param1[_loc2_[_loc9_]];
            _loc4_ = _loc3_.attUserVo;
            _loc6_ = _loc3_.hurUserVo;
            _loc5_ = _loc3_.attSkill;
            _loc12_ = 0;
            while(_loc12_ < _loc4_.buff_gaiLiArr.length)
            {
               if(!_loc5_)
               {
                  break;
               }
               _loc8_ = _loc4_.buff_gaiLiArr[_loc12_];
               if(_loc8_.config.triggerNum == 1)
               {
                  _loc11_ = BattleModelManager.getIns().calBuffTrigger(_loc4_,_loc6_,_loc5_,_loc8_);
                  if(_loc8_.config.cd > 0)
                  {
                     if(_loc8_.currCd != 0 && GameFrame.time - _loc8_.currCd < _loc8_.config.cd)
                     {
                        _loc11_ = false;
                     }
                  }
                  if(_loc11_)
                  {
                     _loc7_ = getPlayerByEntityId(_loc6_.entitieId) as PlayerEntity;
                     if(_loc7_)
                     {
                        _loc7_.createBuffGaiLi(_loc8_,_loc4_,_loc3_);
                        _loc8_.currCd = GameFrame.time;
                     }
                  }
               }
               _loc12_++;
            }
            _loc9_++;
         }
      }
      
      private function checkGaiLibuff2(param1:AttackInfoVO) : void
      {
         var _loc8_:int = 0;
         var _loc6_:BuffVO = null;
         var _loc7_:Boolean = false;
         var _loc5_:PlayerEntity = null;
         var _loc2_:UserVO = param1.attUserVo;
         var _loc4_:UserVO = param1.hurUserVo;
         var _loc3_:SkillConfigVO = param1.attSkill;
         _loc8_ = 0;
         while(_loc8_ < _loc2_.buff_gaiLiArr.length)
         {
            _loc6_ = _loc2_.buff_gaiLiArr[_loc8_];
            if(_loc6_.config.triggerNum != 1)
            {
               _loc7_ = BattleModelManager.getIns().calBuffTrigger(_loc2_,_loc4_,_loc3_,_loc6_);
               if(_loc7_)
               {
                  _loc5_ = getPlayerByEntityId(_loc4_.entitieId) as PlayerEntity;
                  if(_loc5_)
                  {
                     _loc5_.createBuffGaiLi(_loc6_,_loc2_);
                  }
               }
            }
            _loc8_++;
         }
      }
      
      public function addHurtManData(param1:AttackInfoVO) : void
      {
         if(param1.attUserVo.isFriend || param1.hurUserVo.isFriend)
         {
            return;
         }
         _AttackInfos.push(param1);
      }
      
      public function getHurtManData() : Vector.<AttackInfoVO>
      {
         return _AttackInfos;
      }
      
      public function addEntity2(param1:Entity2) : void
      {
         _entity2s.push(param1);
      }
      
      public function addEntity(param1:Entity, param2:int) : void
      {
         _entitys.push(param1);
         if(param2 == -1)
         {
         }
         if(param2 == 1)
         {
            if(param1.getType() == ManType.SKILL)
            {
               _camp1Att.push(param1);
            }
            else
            {
               _camp1.push(param1);
            }
         }
         else if(param2 == 2)
         {
            if(param1.getType() == ManType.SKILL)
            {
               _camp2Att.push(param1);
            }
            else
            {
               _camp2.push(param1);
            }
         }
         else if(param2 == 3)
         {
            if(param1.getType() == ManType.SKILL)
            {
               _camp3Att.push(param1);
            }
            else
            {
               _camp3.push(param1);
            }
         }
         else if(param2 == 4)
         {
            if(param1.getType() == ManType.SKILL)
            {
               _camp4Att.push(param1);
            }
            else
            {
               _camp4.push(param1);
            }
         }
         else if(param2 == 5)
         {
            if(param1.getType() == ManType.SKILL)
            {
               _camp5Att.push(param1);
            }
            else
            {
               _camp5.push(param1);
            }
         }
         if(param1.getType() == ManType.HORSE)
         {
            _horseEntitys.push(param1);
         }
      }
      
      public function set nowScreen(param1:int) : void
      {
         _nowScreen = param1;
      }
      
      public function get nowScreen() : int
      {
         return _nowScreen;
      }
      
      public function removeMonsterByUid(param1:int, param2:int) : void
      {
         if(removeEntityByUid(param1,false))
         {
            if(param2 > -1)
            {
               _monsterTotal = _monsterTotal - 1;
            }
         }
      }
      
      public function removeEntity2ByUid(param1:int, param2:Boolean) : void
      {
         var _loc4_:Entity2 = null;
         var _loc5_:int = 0;
         var _loc3_:int = 0;
         _loc5_ = 0;
         while(_loc5_ < _entity2s.length)
         {
            _loc4_ = _entity2s[_loc5_];
            _loc3_ = _loc4_.Id;
            if(_loc3_ == param1)
            {
               if(param2)
               {
                  _loc4_.destroy();
               }
               _entity2s.splice(_loc5_,1);
               break;
            }
            _loc5_++;
         }
      }
      
      public function removeEntityByUid(param1:int, param2:Boolean) : Boolean
      {
         var _loc4_:Entity = null;
         var _loc6_:int = 0;
         var _loc3_:int = 0;
         var _loc5_:int = 0;
         _loc6_ = 0;
         while(_loc6_ < _entitys.length)
         {
            _loc4_ = _entitys[_loc6_];
            _loc3_ = _loc4_.Id;
            if(_loc3_ == param1)
            {
               if(param2)
               {
                  _loc4_.destory();
               }
               _loc5_ = _entitys.indexOf(_loc4_);
               if(_loc5_ == _loc6_)
               {
                  removeFromCamp(param1);
                  _entitys.splice(_loc6_,1);
               }
               if(_loc4_.getType() == ManType.HORSE)
               {
                  _loc5_ = _horseEntitys.indexOf(_loc4_);
                  if(_loc5_ > -1)
                  {
                     _horseEntitys.splice(_loc5_,1);
                  }
               }
               return true;
            }
            _loc6_++;
         }
         return false;
      }
      
      public function removeFromCamp(param1:int) : void
      {
         var _loc2_:Entity = null;
         var _loc8_:int = 0;
         var _loc4_:int = 0;
         var _loc6_:int = 0;
         var _loc5_:int = 0;
         var _loc7_:int = 0;
         var _loc3_:int = 0;
         _loc8_ = 0;
         while(_loc8_ < _camp1.length)
         {
            _loc2_ = _camp1[_loc8_] as Entity;
            if(_loc2_.Id == param1)
            {
               _camp1.splice(_loc8_,1);
               break;
            }
            _loc8_++;
         }
         _loc4_ = 0;
         while(_loc4_ < _camp2.length)
         {
            _loc2_ = _camp2[_loc4_] as Entity;
            if(_loc2_.Id == param1)
            {
               _camp2.splice(_loc4_,1);
               break;
            }
            _loc4_++;
         }
         _loc6_ = 0;
         while(_loc6_ < _camp3.length)
         {
            _loc2_ = _camp3[_loc6_] as Entity;
            if(_loc2_.Id == param1)
            {
               _camp3.splice(_loc6_,1);
               break;
            }
            _loc6_++;
         }
         _loc6_ = 0;
         while(_loc6_ < _camp4.length)
         {
            _loc2_ = _camp4[_loc6_] as Entity;
            if(_loc2_.Id == param1)
            {
               _camp4.splice(_loc6_,1);
               break;
            }
            _loc6_++;
         }
         _loc6_ = 0;
         while(_loc6_ < _camp5.length)
         {
            _loc2_ = _camp5[_loc6_] as Entity;
            if(_loc2_.Id == param1)
            {
               _camp5.splice(_loc6_,1);
               break;
            }
            _loc6_++;
         }
         _loc5_ = 0;
         while(_loc5_ < _camp1Att.length)
         {
            _loc2_ = _camp1Att[_loc5_] as Entity;
            if(_loc2_.Id == param1)
            {
               _camp1Att.splice(_loc5_,1);
               break;
            }
            _loc5_++;
         }
         _loc7_ = 0;
         while(_loc7_ < _camp2Att.length)
         {
            _loc2_ = _camp2Att[_loc7_] as Entity;
            if(_loc2_.Id == param1)
            {
               _camp2Att.splice(_loc7_,1);
               break;
            }
            _loc7_++;
         }
         _loc3_ = 0;
         while(_loc3_ < _camp3Att.length)
         {
            _loc2_ = _camp3Att[_loc3_] as Entity;
            if(_loc2_.Id == param1)
            {
               _camp3Att.splice(_loc3_,1);
               break;
            }
            _loc3_++;
         }
         _loc3_ = 0;
         while(_loc3_ < _camp4Att.length)
         {
            _loc2_ = _camp4Att[_loc3_] as Entity;
            if(_loc2_.Id == param1)
            {
               _camp4Att.splice(_loc3_,1);
               break;
            }
            _loc3_++;
         }
         _loc3_ = 0;
         while(_loc3_ < _camp5Att.length)
         {
            _loc2_ = _camp5Att[_loc3_] as Entity;
            if(_loc2_.Id == param1)
            {
               _camp5Att.splice(_loc3_,1);
               break;
            }
            _loc3_++;
         }
      }
      
      public function destory() : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _entitys.length)
         {
            if(_entitys[_loc2_])
            {
               _entitys[_loc2_].destory();
            }
            _loc2_++;
         }
         _entitys.splice(0,_entitys.length);
         _loc2_ = 0;
         while(_loc2_ < _entity2s.length)
         {
            if(_entity2s[_loc2_])
            {
               _entity2s[_loc2_].destroy();
            }
            _loc2_++;
         }
         _entity2s.splice(0,_entity2s.length);
         _camp1.length = 0;
         _camp2.length = 0;
         _camp3.length = 0;
         _camp4.length = 0;
         _camp5.length = 0;
         _camp1Att.length = 0;
         _camp2Att.length = 0;
         _camp3Att.length = 0;
         _camp4Att.length = 0;
         _camp5Att.length = 0;
         for(var _loc1_:String in _screenMonsterTrigger)
         {
            delete _screenMonsterTrigger[_loc1_];
         }
      }
      
      public function setAttackedTotalNum(param1:Number, param2:int, param3:Number, param4:String, param5:int) : void
      {
         var _loc6_:SkillConfigVO = null;
         var _loc9_:int = 0;
         var _loc8_:int = 0;
         var _loc7_:SkillConfigVO = null;
         _loc6_ = _loc6_ = SkillModelManager.getIns().getSkillConfigVOByID(param2);
         _loc9_ = 0;
         while(_loc9_ < _entitys.length)
         {
            if(_entitys[_loc9_].userVo && _entitys[_loc9_].userVo.campId != param5)
            {
               _entitys[_loc9_].setAttackedTotalNum(param1.toString(),param2,param3);
               if(param3 == 0)
               {
                  _loc8_ = 0;
                  while(_loc8_ < _loc6_.subs.length)
                  {
                     _loc7_ = _loc6_.subs[_loc8_];
                     _entitys[_loc9_].setAttackedTotalNum(param1.toString(),_loc7_.id,param3);
                     _loc8_++;
                  }
               }
            }
            _loc9_++;
         }
      }
      
      public function setMonsterTotal(param1:int) : void
      {
         SimpleTextLog.getIns().log("setMonsterTotal=" + param1);
         _monsterTotal = param1;
      }
      
      public function getPlayerByEntityId(param1:Number) : Entity
      {
         var _loc3_:int = 0;
         var _loc2_:Entity = null;
         _loc3_ = 0;
         while(_loc3_ < _entitys.length)
         {
            _loc2_ = _entitys[_loc3_];
            if(_loc2_ is RoleEntity)
            {
               if(_loc2_.entitieId == param1 && _loc2_ is RoleEntity)
               {
                  return _loc2_;
               }
            }
            _loc3_++;
         }
         return null;
      }
      
      public function getPlayerByEntityChar(param1:Number) : Entity
      {
         var _loc3_:int = 0;
         var _loc2_:Entity = null;
         _loc3_ = 0;
         while(_loc3_ < _entitys.length)
         {
            _loc2_ = _entitys[_loc3_];
            if(_loc2_ is RoleEntity)
            {
               if(_loc2_.userVo && _loc2_.userVo.charID == param1 && _loc2_ is RoleEntity)
               {
                  return _loc2_;
               }
            }
            _loc3_++;
         }
         return null;
      }
      
      public function getPlayerByEntityChars(param1:Number) : Vector.<Entity>
      {
         var _loc4_:int = 0;
         var _loc3_:Entity = null;
         var _loc2_:Vector.<Entity> = new Vector.<Entity>();
         _loc4_ = 0;
         while(_loc4_ < _entitys.length)
         {
            _loc3_ = _entitys[_loc4_];
            if(_loc3_ is RoleEntity)
            {
               if(_loc3_.userVo && _loc3_.userVo.charID == param1 && _loc3_ is RoleEntity)
               {
                  _loc2_.push(_loc3_);
               }
            }
            _loc4_++;
         }
         return _loc2_;
      }
      
      public function getPlayerByParentEid(param1:Number) : Vector.<Entity>
      {
         var _loc5_:int = 0;
         var _loc4_:Entity = null;
         var _loc2_:Entity = null;
         var _loc3_:Vector.<Entity> = new Vector.<Entity>();
         _loc5_ = 0;
         while(_loc5_ < _entitys.length)
         {
            _loc4_ = _entitys[_loc5_];
            _loc2_ = _loc4_.getParent();
            if(_loc4_ is RoleEntity && _loc2_)
            {
               if(_loc2_.userVo && _loc2_.userVo.entitieId == param1)
               {
                  _loc3_.push(_loc4_);
               }
            }
            _loc5_++;
         }
         return _loc3_;
      }
      
      public function getPlayerByTypeId(param1:Number) : Vector.<Entity>
      {
         var _loc4_:int = 0;
         var _loc3_:Entity = null;
         var _loc2_:Vector.<Entity> = new Vector.<Entity>();
         _loc4_ = 0;
         while(_loc4_ < _entitys.length)
         {
            _loc3_ = _entitys[_loc4_];
            if(_loc3_ is RoleEntity)
            {
               if(_loc3_.userVo && _loc3_.userVo.configVo.typeId == param1 && _loc3_.userVo.isDie == false)
               {
                  _loc2_.push(_loc3_);
               }
            }
            _loc4_++;
         }
         return _loc2_;
      }
      
      public function getNpcEntityChars(param1:int) : Vector.<NpcEntity>
      {
         var _loc4_:int = 0;
         var _loc3_:Entity = null;
         var _loc2_:Vector.<NpcEntity> = new Vector.<NpcEntity>();
         _loc4_ = 0;
         while(_loc4_ < _entitys.length)
         {
            _loc3_ = _entitys[_loc4_];
            if(_loc3_.getType() == "npc")
            {
               if(_loc3_.userVo.configVo.id == param1)
               {
                  _loc2_.push(_loc3_);
               }
            }
            _loc4_++;
         }
         return _loc2_;
      }
      
      public function getItemsrByItemId(param1:Number) : Vector.<BattleItemEntity>
      {
         var _loc4_:int = 0;
         var _loc3_:BattleItemEntity = null;
         var _loc2_:Vector.<BattleItemEntity> = new Vector.<BattleItemEntity>();
         _loc4_ = 0;
         while(_loc4_ < _entitys.length)
         {
            _loc3_ = _entitys[_loc4_] as BattleItemEntity;
            if(_loc3_)
            {
               if(_loc3_.properties.properties.itemId == param1)
               {
                  _loc2_.push(_loc3_);
               }
            }
            _loc4_++;
         }
         return _loc2_;
      }
      
      public function getItemrByEId(param1:Number) : Entity
      {
         var _loc3_:int = 0;
         var _loc2_:BattleItemEntity = null;
         _loc3_ = 0;
         while(_loc3_ < _entitys.length)
         {
            _loc2_ = _entitys[_loc3_] as BattleItemEntity;
            if(_loc2_)
            {
               if(_loc2_.Id == param1)
               {
                  return _loc2_;
               }
            }
            _loc3_++;
         }
         return null;
      }
      
      public function getOtherByEId(param1:Number) : Entity
      {
         var _loc3_:int = 0;
         var _loc2_:Entity = null;
         _loc3_ = 0;
         while(_loc3_ < _entitys.length)
         {
            _loc2_ = _entitys[_loc3_] as Entity;
            if(_loc2_)
            {
               if(_loc2_.userVo && _loc2_.userVo.entitieId == param1)
               {
                  return _loc2_;
               }
            }
            _loc3_++;
         }
         return null;
      }
      
      public function getCamp1() : Vector.<ICollide>
      {
         return _camp1;
      }
      
      public function getCamp3() : Vector.<ICollide>
      {
         return _camp3;
      }
      
      public function getCamp2() : Vector.<ICollide>
      {
         return _camp2;
      }
      
      public function getCamp4() : Vector.<ICollide>
      {
         return _camp4;
      }
      
      public function getCamp5() : Vector.<ICollide>
      {
         return _camp5;
      }
      
      public function getOtherCamps(param1:int) : Vector.<ICollide>
      {
         var _loc2_:Vector.<ICollide> = new Vector.<ICollide>();
         if(param1 == 1)
         {
            _loc2_ = _loc2_.concat(_camp2);
            _loc2_ = _loc2_.concat(_camp4);
            _loc2_ = _loc2_.concat(_camp5);
         }
         else if(param1 == 2)
         {
            _loc2_ = _loc2_.concat(_camp1);
            _loc2_ = _loc2_.concat(_camp4);
            _loc2_ = _loc2_.concat(_camp5);
         }
         else if(param1 == 4)
         {
            _loc2_ = _loc2_.concat(_camp2);
            _loc2_ = _loc2_.concat(_camp5);
         }
         else if(param1 == 5)
         {
            _loc2_ = _loc2_.concat(_camp1);
            _loc2_ = _loc2_.concat(_camp4);
         }
         return _loc2_;
      }
      
      public function getManInNearViewByX2(param1:Entity, param2:Array) : Array
      {
         var vs:Vector.<ICollide>;
         var e:Entity;
         var res:Entity;
         var dis2:Vector2D;
         var arr:Array;
         var i:int;
         var dis1:Vector2D;
         var input:Entity = param1;
         var noInclude:Array = param2;
         var cip:int = input.userVo.campId;
         if(cip == 1)
         {
            vs = _camp2;
         }
         else
         {
            vs = _camp1;
         }
         arr = [];
         i = 0;
         while(i < vs.length)
         {
            e = vs[i] as Entity;
            if(e is RoleEntity)
            {
               if(e.isDie || e.Enabled == false)
               {
               }
               if(noInclude.indexOf(e.userVo.charID) == -1)
               {
                  arr.push(e);
               }
            }
            i = i + 1;
         }
         arr.sort((function():*
         {
            var cccc:Function;
            return cccc = function(param1:Entity, param2:Entity):*
            {
               dis1 = input.position.subtract(param1.position);
               dis2 = input.position.subtract(param2.position);
               if(dis1.length < dis2.length)
               {
                  return -1;
               }
               if(dis1.length > dis2.length)
               {
                  return 1;
               }
               return 0;
            };
         })());
         return arr;
      }
      
      public function getManInNearViewByX(param1:Entity, param2:Array) : Array
      {
         var e:Entity;
         var res:Entity;
         var dis2:Vector2D;
         var dis1:Vector2D;
         var input:Entity = param1;
         var noInclude:Array = param2;
         var cip:int = input.userVo.campId;
         var vs:Vector.<ICollide> = getOtherCamps(cip);
         var arr:Array = [];
         var i:int = 0;
         while(i < vs.length)
         {
            e = vs[i] as Entity;
            if(e is RoleEntity)
            {
               if(!(e.isDie || e.Enabled == false || e.isHide))
               {
                  if(!e.isHatredZero)
                  {
                     if(noInclude.indexOf(e.userVo.charID) == -1)
                     {
                        arr.push(e);
                     }
                  }
               }
            }
            i = i + 1;
         }
         arr.sort((function():*
         {
            var cccc:Function;
            return cccc = function(param1:Entity, param2:Entity):*
            {
               dis1 = input.position.subtract(param1.position);
               dis2 = input.position.subtract(param2.position);
               if(dis1.length < dis2.length)
               {
                  return -1;
               }
               if(dis1.length > dis2.length)
               {
                  return 1;
               }
               return 0;
            };
         })());
         return arr;
      }
      
      public function getManInNearViewByY(param1:Entity, param2:Array) : Array
      {
         var vs:Vector.<ICollide>;
         var e:Entity;
         var res:Entity;
         var dis2:Vector2D;
         var arr:Array;
         var i:int;
         var dis1:Vector2D;
         var input:Entity = param1;
         var noInclude:Array = param2;
         var cip:int = input.userVo.campId;
         if(cip == 1)
         {
            vs = _camp2;
         }
         else
         {
            vs = _camp1;
         }
         arr = [];
         i = 0;
         while(i < vs.length)
         {
            e = vs[i] as Entity;
            if(e is RoleEntity)
            {
               if(!(e.isDie || e.Enabled == false || e.isHide))
               {
                  if(!e.isHatredZero)
                  {
                     if(noInclude.indexOf(e.userVo.charID) == -1 && input.position.x < e.position.x)
                     {
                        arr.push(e);
                     }
                  }
               }
            }
            i = i + 1;
         }
         arr.sort((function():*
         {
            var cccc:Function;
            return cccc = function(param1:Entity, param2:Entity):*
            {
               dis1 = input.position.subtract(param1.position);
               dis2 = input.position.subtract(param2.position);
               if(Math.abs(dis1.y) < Math.abs(dis2.y))
               {
                  return -1;
               }
               if(Math.abs(dis1.y) > Math.abs(dis2.y))
               {
                  return 1;
               }
               return 0;
            };
         })());
         return arr;
      }
      
      public function getManInRecViewBy(param1:Entity, param2:int, param3:Array, param4:Rectangle, param5:Boolean = false) : Array
      {
         var _loc10_:* = undefined;
         var _loc6_:Entity = null;
         var _loc11_:int = 0;
         var _loc8_:Rectangle = null;
         var _loc9_:AABB = null;
         if(param2 == 1)
         {
            _loc10_ = _camp1;
         }
         else if(param2 == -1)
         {
            _loc10_ = _camp2.concat();
            _loc10_ = _loc10_.concat(_camp3);
         }
         else if(param2 == -2)
         {
            _loc10_ = _camp1.concat();
            _loc10_ = _loc10_.concat(_camp3);
         }
         else
         {
            _loc10_ = _camp2;
         }
         var _loc7_:Array = [];
         _loc11_ = 0;
         while(_loc11_ < _loc10_.length)
         {
            _loc6_ = _loc10_[_loc11_] as Entity;
            if(!(_loc6_ && _loc6_ is E3013))
            {
               if(!(_loc6_.Enabled == false || _loc6_.isHide && !param5))
               {
                  if(!_loc6_.isHatredZero)
                  {
                     if(param3.indexOf(_loc6_) == -1 && (_loc6_.getType() == "role" || _loc6_.getType() == "npc" || _loc6_.getType() == "monster" || _loc6_.getType() == "pet"))
                     {
                        _loc8_ = new Rectangle(_loc6_.position.x - 20,_loc6_.position.y - 70,40,70);
                        if(_loc6_.bodyAABB)
                        {
                           _loc9_ = _loc6_.bodyAABB;
                           _loc8_.x = _loc9_.x;
                           _loc8_.y = _loc9_.y;
                           _loc8_.width = _loc9_.width;
                           _loc8_.height = _loc9_.height;
                        }
                        if(param4.intersects(_loc8_))
                        {
                           _loc7_.push(_loc6_);
                        }
                     }
                  }
               }
            }
            _loc11_++;
         }
         return _loc7_;
      }
      
      public function getManInNearView(param1:Entity, param2:Array, param3:Vector2D = null) : Entity
      {
         var _loc6_:Entity = null;
         var _loc5_:Entity = null;
         var _loc4_:* = null;
         var _loc11_:int = 0;
         var _loc7_:Number = NaN;
         var _loc10_:int = param1.userVo.campId;
         var _loc9_:Vector.<ICollide> = getOtherCamps(_loc10_);
         if(!param3 && param1)
         {
            param3 = param1.position;
         }
         var _loc8_:Number = 2147483647;
         _loc11_ = 0;
         while(_loc11_ < _loc9_.length)
         {
            _loc6_ = _loc9_[_loc11_] as Entity;
            if(_loc6_ is RoleEntity)
            {
               if(!(_loc6_.isDie || _loc6_ is E3013 || _loc6_ is E3325))
               {
                  if(!(_loc6_.Enabled == false || _loc6_.isHide))
                  {
                     if(!_loc6_.isHatredZero)
                     {
                        if(!(param2.indexOf(3027) > -1 && _loc6_ is E3027))
                        {
                           if(param2.indexOf(_loc6_.userVo.charID) == -1)
                           {
                              _loc7_ = param3.dist(_loc6_.position);
                              if(_loc7_ < _loc8_)
                              {
                                 _loc8_ = _loc7_;
                                 _loc5_ = _loc6_;
                              }
                           }
                        }
                     }
                  }
               }
            }
            _loc11_++;
         }
         return _loc5_;
      }
      
      public function getManInNearViewBossFrist(param1:Entity, param2:Array) : Entity
      {
         var _loc8_:* = undefined;
         var _loc5_:Entity = null;
         var _loc4_:Entity = null;
         var _loc3_:Vector2D = null;
         var _loc12_:int = 0;
         var _loc6_:Vector2D = null;
         var _loc10_:Boolean = false;
         var _loc9_:int = 0;
         _loc6_ = null;
         var _loc11_:int = param1.userVo.campId;
         if(_loc11_ == 1)
         {
            _loc8_ = _camp2;
         }
         else
         {
            _loc8_ = _camp1;
         }
         var _loc7_:Array = [];
         _loc12_ = 0;
         while(_loc12_ < _loc8_.length)
         {
            _loc5_ = _loc8_[_loc12_] as Entity;
            if(_loc5_ is RoleEntity)
            {
               if(!(_loc5_.isDie || _loc5_ is E3013))
               {
                  if(!(_loc5_.Enabled == false || _loc5_.isHide))
                  {
                     if(!_loc5_.isHatredZero)
                     {
                        if(param2.indexOf(_loc5_.userVo.charID) == -1)
                        {
                           _loc6_ = _loc5_.position.subtract(param1.position);
                           if(!_loc3_)
                           {
                              _loc3_ = _loc6_.clone();
                           }
                           _loc10_ = false;
                           if(_loc5_.userVo && _loc5_.userVo.configVo && _loc5_.userVo.configVo.boss == 1)
                           {
                              _loc10_ = true;
                           }
                           if(_loc6_.length <= _loc3_.length || _loc10_)
                           {
                              _loc4_ = _loc5_;
                              if(_loc10_)
                              {
                                 _loc7_.push(_loc5_);
                              }
                           }
                        }
                     }
                  }
               }
            }
            _loc12_++;
         }
         if(_loc7_.length > 0)
         {
            _loc3_ = null;
            _loc9_ = 0;
            while(_loc9_ < _loc7_.length)
            {
               _loc5_ = _loc7_[_loc9_] as Entity;
               _loc6_ = _loc5_.position.subtract(param1.position);
               if(!_loc3_)
               {
                  _loc3_ = _loc6_.clone();
               }
               if(_loc6_.length <= _loc3_.length)
               {
                  _loc4_ = _loc5_;
               }
               _loc9_++;
            }
         }
         return _loc4_;
      }
      
      public function getManInNearViewZhaoHuan(param1:Entity, param2:Array) : Array
      {
         var _loc8_:* = undefined;
         var _loc5_:Entity = null;
         var _loc4_:Entity = null;
         var _loc7_:Entity = null;
         var _loc3_:Vector2D = null;
         var _loc10_:int = 0;
         var _loc6_:Vector2D = null;
         if(!param1)
         {
            return null;
         }
         var _loc9_:int = param1.userVo.campId;
         if(_loc9_ == 1)
         {
            _loc8_ = _camp2;
         }
         else
         {
            _loc8_ = _camp1;
         }
         _loc10_ = 0;
         while(_loc10_ < _loc8_.length)
         {
            _loc5_ = _loc8_[_loc10_] as Entity;
            if(_loc5_ is MonsterEntity)
            {
               if(!(_loc5_.isDie || _loc5_ is E3013))
               {
                  if(!(_loc5_.Enabled == false || _loc5_.isHide))
                  {
                     if(!_loc5_.isHatredZero)
                     {
                        if(param2.indexOf(_loc5_.userVo.charID) == -1)
                        {
                           _loc6_ = _loc5_.position.subtract(param1.position);
                           if(!_loc3_)
                           {
                              _loc3_ = _loc6_.clone();
                           }
                           if(_loc5_.userVo && _loc5_.userVo.configVo)
                           {
                              if(_loc6_.length <= _loc3_.length)
                              {
                                 if(_loc5_.userVo.configVo.friendlyAiId > 0)
                                 {
                                    _loc4_ = _loc5_;
                                 }
                                 else
                                 {
                                    _loc7_ = _loc5_;
                                 }
                              }
                           }
                        }
                     }
                  }
               }
            }
            _loc10_++;
         }
         return [_loc4_,_loc7_];
      }
      
      public function getManInFarView(param1:Entity, param2:Array, param3:Boolean) : Entity
      {
         var _loc6_:Entity = null;
         var _loc5_:Entity = null;
         var _loc4_:Vector2D = null;
         var _loc11_:int = 0;
         var _loc9_:Rectangle = null;
         var _loc7_:Vector2D = null;
         var _loc10_:int = param1.userVo.campId;
         var _loc8_:Vector.<ICollide> = getOtherCamps(_loc10_);
         _loc11_ = 0;
         for(; _loc11_ < _loc8_.length; _loc11_++)
         {
            _loc6_ = _loc8_[_loc11_] as Entity;
            if(_loc6_ is RoleEntity)
            {
               if(!(_loc6_.isDie || _loc6_ is E3013))
               {
                  if(!(_loc6_.Enabled == false || _loc6_.isHide))
                  {
                     if(!_loc6_.isHatredZero)
                     {
                        if(param2.indexOf(_loc6_.userVo.charID) == -1)
                        {
                           if(param3)
                           {
                              _loc9_ = BattleModelManager.getIns().viewPort;
                              if(!_loc9_.contains(_loc6_.position.x,_loc6_.position.y))
                              {
                                 continue;
                              }
                           }
                           _loc7_ = _loc6_.position.subtract(param1.position);
                           if(!_loc4_)
                           {
                              _loc4_ = _loc7_.clone();
                           }
                           if(_loc7_.length >= _loc4_.length)
                           {
                              _loc5_ = _loc6_;
                           }
                        }
                     }
                  }
               }
            }
         }
         return _loc5_;
      }
      
      public function getManByBleed(param1:Entity, param2:Array) : Array
      {
         var vs:Vector.<ICollide>;
         var e:Entity;
         var res:Entity;
         var arr:Array;
         var i:int;
         var hp2:Number;
         var hp1:Number;
         var input:Entity = param1;
         var noInclude:Array = param2;
         var cip:int = input.userVo.campId;
         if(cip == 1)
         {
            vs = _camp2;
         }
         else
         {
            vs = _camp1;
         }
         arr = [];
         i = 0;
         while(i < vs.length)
         {
            e = vs[i] as Entity;
            if(!(e.getType() == ManType.SKILL || e is E3013 || e is E3325 || e is E3027 || e is RoleEntity == false || e.isHide))
            {
               if(e is RoleEntity)
               {
                  if(!(e.isDie || e.Enabled == false || e.isHide))
                  {
                     if(!e.isHatredZero)
                     {
                        if(noInclude.indexOf(e.userVo.charID) == -1)
                        {
                           arr.push(e);
                        }
                     }
                  }
               }
            }
            i = i + 1;
         }
         arr.sort((function():*
         {
            var cccc:Function;
            return cccc = function(param1:Entity, param2:Entity):*
            {
               hp1 = param1.userVo.hp;
               hp2 = param2.userVo.hp;
               if(hp1 < hp2)
               {
                  return -1;
               }
               if(hp1 > hp2)
               {
                  return 1;
               }
               return 0;
            };
         })());
         return arr;
      }
      
      public function getManByDirBleed(param1:Entity, param2:Array) : Array
      {
         var vs:Vector.<ICollide>;
         var e:Entity;
         var res:Entity;
         var arr:Array;
         var i:int;
         var hp2:Number;
         var hp1:Number;
         var input:Entity = param1;
         var noInclude:Array = param2;
         var cip:int = input.userVo.campId;
         if(cip == 1)
         {
            vs = _camp2;
         }
         else
         {
            vs = _camp1;
         }
         arr = [];
         i = 0;
         while(i < vs.length)
         {
            e = vs[i] as Entity;
            if(!(e.getType() == ManType.SKILL || e is E3013 || e is E3325 || e is RoleEntity == false || e.isHide))
            {
               if(e is RoleEntity)
               {
                  if(!(e.isDie || e.Enabled == false || e.isHide))
                  {
                     if(!e.isHatredZero)
                     {
                        if(!(e.position.x < input.position.x && input.direction == 1))
                        {
                           if(!(e.position.x > input.position.x && input.direction == -1))
                           {
                              if(noInclude.indexOf(e.userVo.charID) == -1)
                              {
                                 arr.push(e);
                              }
                           }
                        }
                     }
                  }
               }
            }
            i = i + 1;
         }
         arr.sort((function():*
         {
            var cccc:Function;
            return cccc = function(param1:Entity, param2:Entity):*
            {
               hp1 = param1.userVo.hp;
               hp2 = param2.userVo.hp;
               if(hp1 < hp2)
               {
                  return -1;
               }
               if(hp1 > hp2)
               {
                  return 1;
               }
               return 0;
            };
         })());
         return arr;
      }
      
      public function getManByDirDist(param1:Entity, param2:Array) : Array
      {
         var input:Entity = param1;
         var noInclude:Array = param2;
         var arr:Array = getManByDirBleed(input,noInclude);
         var dis:Number = 2147483647;
         arr.sort((function():*
         {
            var cccc:Function;
            return cccc = function(param1:Entity, param2:Entity):*
            {
               var _loc3_:Number = input.position.dist(param2.position);
               if(_loc3_ < dis)
               {
                  return -1;
               }
               if(_loc3_ > dis)
               {
                  return 1;
               }
               return 0;
            };
         })());
         return arr;
      }
      
      public function getManByDirDistY(param1:Entity, param2:Array) : Array
      {
         var input:Entity = param1;
         var noInclude:Array = param2;
         var arr:Array = getManByDirBleed(input,noInclude);
         var dis:Number = 2147483647;
         arr.sort((function():*
         {
            var cccc:Function;
            return cccc = function(param1:Entity, param2:Entity):*
            {
               var _loc3_:Number = Math.abs(input.position.y - param2.position.y);
               if(_loc3_ < dis)
               {
                  return -1;
               }
               if(_loc3_ > dis)
               {
                  return 1;
               }
               return 0;
            };
         })());
         return arr;
      }
      
      public function getManOutView(param1:Entity) : Vector.<Entity>
      {
         var _loc3_:Entity = null;
         var _loc7_:int = 0;
         var _loc4_:Vector2D = null;
         var _loc6_:int = param1.userVo.campId;
         var _loc5_:Vector.<ICollide> = getOtherCamps(_loc6_);
         var _loc2_:Vector.<Entity> = new Vector.<Entity>();
         _loc7_ = 0;
         while(_loc7_ < _loc5_.length)
         {
            _loc3_ = _loc5_[_loc7_] as Entity;
            if(!(_loc3_ is SkillEntity || _loc3_ is E3013))
            {
               if(!(_loc3_.Enabled == false || _loc3_.isHide))
               {
                  if(!_loc3_.isHatredZero)
                  {
                     _loc4_ = _loc3_.position.subtract(param1.position);
                     if(_loc4_.length > param1.userVo.configVo.viewRangePatorl)
                     {
                        _loc2_.push(_loc3_);
                     }
                  }
               }
            }
            _loc7_++;
         }
         return _loc2_;
      }
      
      public function getManInViewByRec(param1:Entity, param2:Array) : Entity
      {
         var _loc8_:int = 0;
         var _loc10_:Point = null;
         var _loc5_:Entity = null;
         var _loc4_:Entity = null;
         var _loc3_:* = null;
         var _loc11_:int = 0;
         var _loc6_:Rectangle = null;
         if(!_testShapes)
         {
            _testShapes = [];
         }
         _loc8_ = 0;
         while(_loc8_ < _testShapes.length)
         {
            GameData.stage.removeChild(_testShapes[_loc8_]);
            _loc8_++;
         }
         _testShapes = [];
         var _loc9_:Rectangle = param1.display.getBounds(GameData.stage);
         var _loc7_:Array = param1.getWRect();
         if(_loc7_)
         {
            _loc10_ = param1.display.localToGlobal(new Point());
            _loc9_.x = _loc10_.x + int(_loc7_[0]);
            _loc9_.y = _loc10_.y + int(_loc7_[1]);
            _loc9_.width = _loc7_[2];
            _loc9_.height = _loc7_[3];
         }
         _loc11_ = 0;
         while(_loc11_ < _entitys.length)
         {
            _loc5_ = _entitys[_loc11_] as Entity;
            if(!(_loc5_ && _loc5_ is E3013))
            {
               if(!(_loc5_.Enabled == false || _loc5_.isHide))
               {
                  if(!_loc5_.isHatredZero)
                  {
                     if(param2.indexOf(_loc5_) == -1 && (_loc5_.getType() == "role" || _loc5_.getType() == "npc" || _loc5_.getType() == "monster" || _loc5_.getType() == "pet"))
                     {
                        _loc6_ = _loc5_.display.getBounds(GameData.stage);
                        _loc7_ = _loc5_.getWRect();
                        if(_loc7_)
                        {
                           _loc10_ = _loc5_.display.localToGlobal(new Point());
                           _loc6_.x = _loc10_.x + int(_loc7_[0]);
                           _loc6_.y = _loc10_.y + int(_loc7_[1]);
                           _loc6_.width = _loc7_[2];
                           _loc6_.height = _loc7_[3];
                        }
                        if(_loc9_.intersects(_loc6_))
                        {
                           _loc4_ = _loc5_;
                           break;
                        }
                     }
                  }
               }
            }
            _loc11_++;
         }
         return _loc4_;
      }
      
      public function getManInRect(param1:Entity, param2:Rectangle) : Boolean
      {
         var _loc3_:Rectangle = param1.display.getBounds(GameData.stage);
         if(param2.intersects(_loc3_))
         {
            return true;
         }
         return false;
      }
      
      public function getManInView(param1:Entity) : Vector.<Entity>
      {
         var _loc3_:Entity = null;
         var _loc7_:int = 0;
         var _loc4_:Vector2D = null;
         var _loc6_:int = param1.userVo.campId;
         var _loc5_:Vector.<ICollide> = getOtherCamps(_loc6_);
         var _loc2_:Vector.<Entity> = new Vector.<Entity>();
         _loc7_ = 0;
         while(_loc7_ < _loc5_.length)
         {
            _loc3_ = _loc5_[_loc7_] as Entity;
            if(!(_loc3_ is E3013))
            {
               if(!(_loc3_.Enabled == false || _loc3_.isHide))
               {
                  if(!_loc3_.isHatredZero)
                  {
                     if(_loc3_ is RoleEntity)
                     {
                        _loc4_ = _loc3_.position.subtract(param1.position);
                        if(_loc4_.length < param1.userVo.configVo.viewRangePatorl)
                        {
                           _loc2_.push(_loc3_);
                        }
                     }
                  }
               }
            }
            _loc7_++;
         }
         return _loc2_;
      }
      
      public function getManInAttackRangeView(param1:Entity, param2:String) : Vector.<Entity>
      {
         var _loc9_:Array = null;
         var _loc4_:Entity = null;
         var _loc11_:int = 0;
         var _loc7_:Vector2D = null;
         var _loc6_:Boolean = false;
         var _loc10_:int = param1.userVo.campId;
         var _loc8_:Vector.<ICollide> = getOtherCamps(_loc10_);
         var _loc5_:int = 0;
         if(param2 == null)
         {
            _loc9_ = [0,100];
         }
         else
         {
            _loc9_ = param1.getSkillScope(param2);
            _loc5_ = int(SkillConfigVO(param1.userVo.configVo.skills[param2]).skillToward);
         }
         if(!_loc9_)
         {
            throw new Error(param1.userVo.configVo.name + "." + param2 + ".skillScope" + ".值!");
         }
         var _loc3_:Vector.<Entity> = new Vector.<Entity>();
         _loc11_ = 0;
         while(_loc11_ < _loc8_.length)
         {
            _loc4_ = _loc8_[_loc11_] as Entity;
            if(!(_loc4_.getType() == ManType.SKILL || _loc4_ is E3013))
            {
               if(!(_loc4_.Enabled == false || _loc4_.isHide))
               {
                  if(!_loc4_.isHatredZero)
                  {
                     _loc7_ = _loc4_.position.clone();
                     if(param1.getMoveType() == 1)
                     {
                     }
                     if(param1.userVo.getHatredMansEid().indexOf(_loc4_.userVo.entitieId) != -1)
                     {
                        _loc6_ = checkInRance(param1.position,_loc7_,param1.direction,_loc9_,_loc5_);
                        if(param1 is BoatEntity)
                        {
                           _loc6_ = checkInBoatRance(param1.position,_loc7_,_loc9_);
                        }
                        if(_loc6_)
                        {
                           _loc3_.push(_loc4_);
                        }
                     }
                  }
               }
            }
            _loc11_++;
         }
         return _loc3_;
      }
      
      public function getManNoCamp(param1:int) : Array
      {
         var _loc4_:Entity = null;
         var _loc3_:* = null;
         var _loc2_:* = null;
         var _loc7_:int = 0;
         var _loc6_:Vector.<ICollide> = getOtherCamps(param1);
         var _loc5_:Array = [];
         _loc7_ = 0;
         while(_loc7_ < _loc6_.length)
         {
            _loc4_ = _loc6_[_loc7_] as Entity;
            if(!(_loc4_ is SkillEntity || _loc4_ is E3013))
            {
               if(!(_loc4_.Enabled == false || _loc4_.isHide))
               {
                  if(!_loc4_.isHatredZero)
                  {
                     if(_loc4_ is RoleEntity)
                     {
                        if(!(_loc4_.isDie || _loc4_.Enabled == false || _loc4_.isHide))
                        {
                           _loc5_.push(_loc4_);
                        }
                     }
                  }
               }
            }
            _loc7_++;
         }
         return _loc5_;
      }
      
      public function checkInRance(param1:Vector2D, param2:Vector2D, param3:int, param4:Array, param5:int) : Boolean
      {
         var _loc10_:int = 0;
         _loc10_ = 0;
         while(_loc10_ < param4.length)
         {
            _loc10_++;
         }
         if(param5 == 0)
         {
            param3 = 1;
         }
         else
         {
            param3 = param5;
         }
         var _loc8_:Boolean = false;
         var _loc7_:Rectangle = new Rectangle(param1.x,param1.y);
         if(param3 == 1)
         {
            _loc7_.x = param1.x + int(param4[0]);
         }
         else
         {
            _loc7_.x = param1.x - int(param4[1]);
         }
         _loc7_.y = param1.y + int(param4[2]);
         if(int(param4[2]) == 0 && int(param4[3]) == 0)
         {
            _loc7_.y = param1.y - 300;
         }
         if(int(param4[3]) > 0)
         {
         }
         _loc7_.width = int(param4[1]) - param4[0];
         _loc7_.height = param4[3] - int(param4[2]);
         if(_loc7_.height == 0)
         {
            _loc7_.height = 600;
         }
         var _loc6_:Rectangle = new Rectangle(param2.x - 20,param2.y - 60,40,60);
         var _loc9_:Rectangle = _loc7_.intersection(_loc6_);
         if(_loc9_.width != 0 && _loc9_.height != 0)
         {
            _loc8_ = true;
         }
         if(_loc8_ == false && param5 == 0)
         {
            _loc8_ = checkInRance(param1,param2,0,param4,-1);
         }
         return _loc8_;
      }
      
      public function checkInBoatRance(param1:Vector2D, param2:Vector2D, param3:Array) : Boolean
      {
         var _loc4_:Boolean = false;
         var _loc5_:int = 0;
         _loc5_ = 1;
         while(_loc5_ <= 4)
         {
            _loc4_ = checkInBoatRance2(param1,param2,param3,_loc5_);
            if(_loc4_)
            {
               break;
            }
            _loc5_++;
         }
         return _loc4_;
      }
      
      private function checkInBoatRance2(param1:Vector2D, param2:Vector2D, param3:Array, param4:int) : Boolean
      {
         var _loc7_:Boolean = false;
         var _loc6_:Rectangle = new Rectangle(param1.x,param1.y);
         if(param4 == 1)
         {
            _loc6_.x = param1.x + int(param3[0]);
            _loc6_.y = param1.y + int(param3[2]);
         }
         else if(param4 == 3)
         {
            _loc6_.x = param1.x - int(param3[1]);
            _loc6_.y = param1.y - int(param3[3]);
         }
         else if(param4 == 2)
         {
            _loc6_.x = param1.x + int(param3[0]);
            _loc6_.y = param1.y + int(param3[2]);
         }
         else if(param4 == 4)
         {
            _loc6_.x = param1.x - int(param3[1]);
            _loc6_.y = param1.y - int(param3[3]);
         }
         _loc6_.width = int(param3[1]) - param3[0];
         _loc6_.height = param3[3] - int(param3[2]);
         var _loc5_:Rectangle = new Rectangle(param2.x - 20,param2.y - 20,40,40);
         var _loc8_:Rectangle = _loc6_.intersection(_loc5_);
         if(_loc8_.width != 0 && _loc8_.height != 0)
         {
            _loc7_ = true;
         }
         return _loc7_;
      }
      
      public function checkInRance2(param1:Vector2D, param2:Vector2D, param3:int, param4:Array, param5:int) : Boolean
      {
         var _loc8_:int = 0;
         _loc8_ = 0;
         while(_loc8_ < param4.length)
         {
            param4[_loc8_] = Math.abs(int(param4[_loc8_]));
            _loc8_++;
         }
         if(param5 == 0)
         {
            param3 = 1;
         }
         else
         {
            param3 = param5;
         }
         var _loc7_:Boolean = false;
         var _loc6_:Rectangle = new Rectangle(param1.x,param1.y);
         if(param3 == 1)
         {
            _loc6_.x = param1.x - int(param4[0]);
         }
         else
         {
            _loc6_.x = param1.x - int(param4[1]);
         }
         _loc6_.y = param1.y - int(param4[2]);
         if(int(param4[2]) == 0)
         {
            _loc6_.y = param2.y;
         }
         _loc6_.width = param4[0] + int(param4[1]);
         _loc6_.height = param4[2] + int(param4[3]);
         if(param2.x >= _loc6_.x && param2.x <= _loc6_.x + _loc6_.width && param2.y >= _loc6_.y && param2.y <= _loc6_.y + _loc6_.height)
         {
            _loc7_ = true;
         }
         if(_loc7_ == false && param5 == 0)
         {
            _loc7_ = checkInRance2(param1,param2,0,param4,-1);
         }
         return _loc7_;
      }
      
      public function getManInSeekRangeView(param1:Entity) : Vector.<Entity>
      {
         var _loc3_:Entity = null;
         var _loc7_:int = 0;
         var _loc4_:Vector2D = null;
         var _loc6_:int = param1.userVo.campId;
         var _loc5_:Vector.<ICollide> = getOtherCamps(_loc6_);
         var _loc2_:Vector.<Entity> = new Vector.<Entity>();
         _loc7_ = 0;
         while(_loc7_ < _loc5_.length)
         {
            _loc3_ = _loc5_[_loc7_] as Entity;
            if(!(_loc3_.getType() == ManType.SKILL || _loc3_ is E3013 || _loc3_ is RoleEntity == false || _loc3_.isHide))
            {
               if(!_loc3_.isHatredZero)
               {
                  _loc4_ = _loc3_.position.subtract(param1.position);
                  if(_loc4_.length < param1.userVo.configVo.viewRangeSeek)
                  {
                     _loc2_.push(_loc3_);
                  }
               }
            }
            _loc7_++;
         }
         return _loc2_;
      }
      
      public function setMonsterTrigger(param1:int, param2:Entity) : void
      {
         if(!_screenMonsterTrigger[param1])
         {
            _screenMonsterTrigger[param1] = [];
         }
         _screenMonsterTrigger[param1].push(param2);
      }
      
      public function calMonsterTotal() : void
      {
         var _loc7_:MonsterBirthVO = null;
         var _loc12_:int = 0;
         var _loc4_:CreateMonsterTrigger = null;
         var _loc11_:int = 0;
         var _loc9_:Array = null;
         var _loc3_:int = 0;
         var _loc2_:String = null;
         var _loc6_:Array = null;
         var _loc8_:int = 0;
         var _loc1_:int = 0;
         var _loc10_:Array = _screenMonsterTrigger[nowScreen];
         if(!_loc10_ || _loc10_.length == 0)
         {
            throw new Error("屏=" + nowScreen + "没有找到怪物触发点.");
         }
         var _loc5_:int = 0;
         _loc12_ = 0;
         while(_loc12_ < _loc10_.length)
         {
            _loc4_ = _loc10_[_loc12_];
            _loc11_ = 0;
            for(; _loc11_ < _loc4_.monsterBirths.length; _loc11_++)
            {
               _loc7_ = _loc4_.monsterBirths[_loc11_];
               if(_loc7_.properties.hasOwnProperty("noInclude"))
               {
                  if(_loc7_.properties.noInclude)
                  {
                     continue;
                  }
               }
               _loc1_ += _loc7_.total;
               SimpleTextLog.getIns().log2("点" + _loc7_.name,"mb.total=" + _loc7_.total,_loc1_);
               if(_monsterTotalObj.hasOwnProperty(_loc7_.tile.monsterId) == false)
               {
                  _monsterTotalObj[_loc7_.tile.monsterId] = 0;
               }
               var _loc13_:* = _loc7_.tile.monsterId;
               var _loc14_:* = _monsterTotalObj[_loc13_] + _loc7_.total;
               _monsterTotalObj[_loc13_] = _loc14_;
               if(_loc7_.mId2 > 0)
               {
                  _loc1_ += 1;
                  if(_monsterTotalObj.hasOwnProperty(_loc7_.mId2) == false)
                  {
                     _monsterTotalObj[_loc7_.mId2] = 0;
                  }
                  _loc14_ = _loc7_.mId2;
                  _loc13_ = _monsterTotalObj[_loc14_] + 1;
                  _monsterTotalObj[_loc14_] = _loc13_;
                  _loc7_.lifeTotal += 1;
               }
               if(_loc7_.properties && _loc7_.properties.hasOwnProperty("isIncludeSummon"))
               {
                  _loc1_ += _loc7_.total;
                  SimpleTextLog.getIns().log2("isIncludeSummon,add=" + _loc7_.total,_loc1_);
               }
               if(_loc7_.properties && _loc7_.properties.hasOwnProperty("includeSummonRandommMonsterIds"))
               {
                  _loc9_ = String(_loc7_.properties.includeSummonRandommMonsterIds).split(",");
                  _loc3_ = 0;
                  while(_loc3_ < _loc9_.length)
                  {
                     _loc2_ = _loc9_[_loc3_];
                     _loc6_ = _loc2_.split("-");
                     _loc6_[0] = int(_loc6_[0]);
                     _loc6_[1] = int(_loc6_[1]);
                     _loc9_[_loc3_] = _loc6_;
                     _loc3_++;
                  }
                  _loc8_ = BattleModelManager.getIns().getRandom() * _loc9_.length;
                  _loc7_.properties.randomMonsterId_ok = _loc9_[_loc8_][0];
                  if(_loc9_[_loc8_][1] > 0)
                  {
                     _loc7_.properties.isIncludeSummon_random = true;
                  }
                  _loc1_ += _loc9_[_loc8_][1];
                  _loc7_.lifeTotal += _loc9_[_loc8_][1];
                  SimpleTextLog.getIns().log2("includeSummonRandommMonsterIds,add=" + _loc7_.total,_loc1_);
               }
            }
            _loc12_++;
         }
         setMonsterTotal(_loc1_);
      }
      
      public function getNextWaveTime(param1:int) : int
      {
         var _loc3_:MonsterBirthVO = null;
         var _loc6_:int = 0;
         var _loc2_:CreateMonsterTrigger = null;
         var _loc5_:int = 0;
         var _loc4_:Array = _screenMonsterTrigger[nowScreen];
         if(!_loc4_ || _loc4_.length == 0)
         {
            throw new Error("屏=" + nowScreen + "没有找到怪物触发点.");
         }
         _loc6_ = 0;
         loop0:
         while(_loc6_ < _loc4_.length)
         {
            _loc2_ = _loc4_[_loc6_];
            _loc5_ = 0;
            while(true)
            {
               if(_loc5_ >= _loc2_.monsterBirths.length)
               {
                  _loc6_++;
                  continue loop0;
               }
               _loc3_ = _loc2_.monsterBirths[_loc5_];
               if(_loc3_.wave == param1)
               {
                  break;
               }
               _loc5_++;
            }
            return _loc3_.createAfterTime;
         }
         return -100;
      }
      
      public function addCreateMonsterTrigger(param1:CreateMonsterTrigger) : void
      {
         if(_createMonsterTriggers.indexOf(param1) == -1)
         {
            _createMonsterTriggers.push(param1);
         }
      }
      
      public function getCreateMonsterTrigger() : Vector.<CreateMonsterTrigger>
      {
         return _createMonsterTriggers;
      }
      
      public function clearCreateMonsterTrigger() : void
      {
         _createMonsterTriggers.length = 0;
      }
      
      public function advanceTime(param1:Number) : void
      {
         var _loc6_:int = 0;
         var _loc5_:HorseEntity = null;
         var _loc2_:HorseVO = null;
         var _loc4_:HorseInfoVo = null;
         var _loc3_:UserVO = null;
         checkHurtManData();
         removeHurtManData();
         _secTime += param1;
         if(_secTime >= 1000)
         {
            _secTime -= 1000;
            _loc6_ = 0;
            while(_loc6_ < _horseEntitys.length)
            {
               _loc5_ = _horseEntitys[_loc6_] as HorseEntity;
               _loc2_ = _loc5_.userVo as HorseVO;
               _loc2_.updateFatigue();
               _loc6_++;
            }
            if(UserModelManager.getIns().playerUserVo1.currentHorser == null)
            {
               _loc4_ = UserModelManager.getIns().getCurretPlayerInfo().getCurrentHorse(1);
               if(_loc4_)
               {
                  _loc4_.horseConfigVo.fatigue -= _loc4_.horseConfigVo.reFatigue;
                  if(_loc4_.horseConfigVo.fatigue < 0)
                  {
                     _loc4_.horseConfigVo.fatigue = 0;
                  }
               }
            }
            if(UserModelManager.getIns().playerUserVo2 && UserModelManager.getIns().playerUserVo2.currentHorser == null)
            {
               _loc4_ = UserModelManager.getIns().getCurretPlayerInfo().getCurrentHorse(2);
               if(_loc4_)
               {
                  _loc4_.horseConfigVo.fatigue -= _loc4_.horseConfigVo.reFatigue;
                  if(_loc4_.horseConfigVo.fatigue < 0)
                  {
                     _loc4_.horseConfigVo.fatigue = 0;
                  }
               }
            }
            if(_userList && _userList.length > 0)
            {
               if(levelInfo && levelInfo.isMutilPlayerMap())
               {
                  if(GameData.isShowPlayer == 1 || CommonConfig.showPlayer == 0)
                  {
                     return;
                  }
               }
               _loc3_ = _userList.shift();
               ApplicationFacade.getInstance().sendNotification("NF_ADD_PLAYER",_loc3_);
            }
         }
         if(this._leagueBossVO)
         {
            this._leagueBossVO.advanceTime(param1);
         }
      }
      
      public function buildDrops(param1:Object) : void
      {
         if(param1.hasOwnProperty("newDrops"))
         {
            _isNewDrop = true;
         }
         _enterCopyResponse = param1;
         if(_isNewDrop)
         {
            RouteConst.SyncDropInfo = "scene.copyHandler.syncDropInfoNew";
            _dropLevelVo = DropModelManager.getIns().buildNewDrops(param1);
         }
         else
         {
            _dropLevelVo = DropModelManager.getIns().getLevel(param1);
         }
         if(_keyDowns[mapEid - 2])
         {
            delete _keyDowns[mapEid - 2];
         }
         if(_keyUps[mapEid - 2])
         {
            delete _keyUps[mapEid - 2];
         }
         mapEid = mapEid + 1;
         _keyDowns[mapEid] = [];
         _keyUps[mapEid] = [];
         __test = {
            "exp":0,
            "sp":0
         };
      }
      
      public function getDrop(param1:int) : Vector.<DropVO>
      {
         var _loc4_:DropVO = null;
         var _loc12_:* = undefined;
         var _loc7_:Array = null;
         var _loc8_:int = 0;
         _loc7_ = null;
         _loc8_ = 0;
         _loc7_ = null;
         var _loc9_:int = 0;
         var _loc13_:ItemVo = null;
         _loc7_ = null;
         var _loc15_:int = 0;
         _loc13_ = null;
         _loc7_ = null;
         _loc15_ = 0;
         var _loc5_:PetCrystalVo = null;
         _loc13_ = null;
         _loc4_ = null;
         var _loc2_:Object = null;
         _loc13_ = null;
         _loc13_ = null;
         var _loc3_:Vector.<DropVO> = new Vector.<DropVO>();
         if(!_dropLevelVo)
         {
            return _loc3_;
         }
         _dropObjects = {};
         var _loc14_:int = 0;
         if(isTeam)
         {
            _loc14_ = UserModelManager.getIns().playerUserVo1.inCampIndex;
         }
         var _loc11_:Boolean = _dropLevelVo.dropByMobId(param1,_dropObjects,_loc14_);
         if(!_loc11_)
         {
            return _loc3_;
         }
         _pickObject.mobIds.push(param1);
         var _loc6_:Object = _dropObjects;
         if(_dropLevelVo is NewLevelDropVO)
         {
            _killMonsters.push(param1 + "_" + _loc6_.index);
            for(var _loc10_:String in _loc6_)
            {
               _loc4_ = new DropVO();
               _loc4_.charId = param1;
               _loc4_.index = _loc6_.index;
               _loc12_ = _loc6_[_loc10_];
               if(_loc10_ == "exp")
               {
                  _loc4_.id = 1;
                  _loc4_.pickId = _loc4_.id + "";
                  _loc4_.num = _loc12_;
                  _loc4_.name = "经验";
                  _loc3_.push(_loc4_);
               }
               else if(_loc10_ == "spirit")
               {
                  _loc4_.id = 900000001;
                  _loc4_.num = _loc12_;
                  _loc4_.name = "灵魂";
                  _loc4_.pickId = _loc4_.id + "";
                  _loc3_.push(_loc4_);
               }
               else if(_loc10_ == "item")
               {
                  for(var _loc17_:String in _loc6_.item)
                  {
                     _loc7_ = _loc6_.item[_loc17_];
                     _loc8_ = 0;
                     while(_loc8_ < _loc7_.length)
                     {
                        _loc4_ = new DropVO();
                        _loc4_.id = Number(_loc17_);
                        _loc4_.pickId = _loc7_[_loc8_];
                        _loc4_.num = 1;
                        _loc4_.charId = param1;
                        _loc4_.name = ItemVoManager.getIns().getPropName(_loc4_.id);
                        _loc4_.isAutoPickup = ItemVoManager.getIns().getPropVoById(_loc4_.id).isAutoPickup == 1 ? true : false;
                        _loc4_.killMonster = param1 + "_" + _loc6_.index;
                        _loc3_.push(_loc4_);
                        _loc8_++;
                     }
                  }
               }
               else if(_loc10_ == "feather")
               {
                  for(_loc17_ in _loc6_.feather)
                  {
                     _loc7_ = _loc6_.feather[_loc17_];
                     _loc8_ = 0;
                     while(_loc8_ < _loc7_.length)
                     {
                        _loc4_ = new DropVO();
                        _loc4_.id = Number(_loc17_);
                        _loc4_.pickId = _loc7_[_loc8_];
                        _loc4_.num = 1;
                        _loc4_.charId = param1;
                        _loc4_.name = ItemVoManager.getIns().getPropName(_loc4_.id);
                        _loc4_.isAutoPickup = ItemVoManager.getIns().getPropVoById(_loc4_.id).isAutoPickup == 1 ? true : false;
                        _loc4_.killMonster = param1 + "_" + _loc6_.index;
                        _loc3_.push(_loc4_);
                        _loc8_++;
                     }
                  }
               }
               else if(_loc10_ == "equip")
               {
                  for(var _loc16_:String in _loc6_.equip)
                  {
                     _loc7_ = _loc6_.equip[_loc16_];
                     _loc9_ = 0;
                     while(_loc9_ < _loc7_.length)
                     {
                        _loc4_ = new DropVO();
                        _loc4_.id = Number(_loc16_);
                        _loc4_.pickId = _loc7_[_loc9_];
                        _loc4_.num = 1;
                        _loc4_.charId = param1;
                        _loc4_.name = ItemVoManager.getIns().getPropName(_loc4_.id);
                        _loc13_ = new ItemVo();
                        _loc13_.id = Number(_loc16_);
                        _loc4_.itemvo = _loc13_;
                        _loc4_.isAutoPickup = false;
                        if(ItemVoManager.getIns().getEquipmentVoById(_loc4_.id))
                        {
                           _loc4_.isAutoPickup = ItemVoManager.getIns().getEquipmentVoById(_loc4_.id).isAutoPickup == 1 ? true : false;
                        }
                        _loc3_.push(_loc4_);
                        _loc9_++;
                     }
                  }
               }
               else if(_loc10_ == "fuIntegral")
               {
                  _loc4_.id = 10;
                  _loc4_.num = _loc12_;
                  _loc4_.name = "福积分";
                  _loc4_.pickId = _loc4_.id + "";
                  _loc3_.push(_loc4_);
               }
               else if(_loc10_ == "soul")
               {
                  for(_loc17_ in _loc6_.soul)
                  {
                     _loc7_ = _loc6_.soul[_loc17_];
                     _loc15_ = 0;
                     while(_loc15_ < _loc7_.length)
                     {
                        _loc4_ = new DropVO();
                        _loc4_.id = Number(_loc17_);
                        _loc4_.pickId = _loc7_[_loc15_];
                        _loc4_.num = 1;
                        _loc4_.charId = param1;
                        _loc4_.name = ItemVoManager.getIns().getPropName(_loc4_.id);
                        _loc13_ = new ItemVo();
                        _loc13_.id = Number(_loc17_);
                        _loc4_.soulItemvo = _loc13_;
                        _loc3_.push(_loc4_);
                        _loc15_++;
                     }
                  }
               }
               else if(_loc10_ == "petCrystal")
               {
                  for(_loc17_ in _loc6_.petCrystal)
                  {
                     _loc7_ = _loc6_.petCrystal[_loc17_];
                     _loc15_ = 0;
                     while(_loc15_ < _loc7_.length)
                     {
                        _loc4_ = new DropVO();
                        _loc4_.id = Number(_loc17_);
                        _loc4_.pickId = _loc7_[_loc15_];
                        _loc4_.num = 1;
                        _loc4_.charId = param1;
                        _loc4_.name = ItemVoManager.getIns().getPropName(_loc4_.id);
                        _loc5_ = ItemVoManager.getIns().getPetCrystalVoById(_loc4_.id);
                        if(_loc5_)
                        {
                           _loc4_.isAutoPickup = _loc5_.isAutoPickup == 1 ? true : false;
                        }
                        _loc13_ = new ItemVo();
                        _loc13_.id = Number(_loc17_);
                        _loc4_.petCrystalItemvo = _loc13_;
                        _loc3_.push(_loc4_);
                        _loc15_++;
                     }
                  }
               }
            }
         }
         else
         {
            _killMonsters.push(param1);
            for(_loc10_ in _loc6_)
            {
               _loc4_ = new DropVO();
               _loc4_.charId = param1;
               _loc2_ = _loc6_[_loc10_];
               if(_loc10_ == "exp")
               {
                  _loc4_.id = 1;
                  _loc4_.num = _loc2_ as int;
                  _loc4_.name = "经验";
                  _loc3_.push(_loc4_);
                  __test.exp += _loc4_.num;
               }
               else if(_loc10_ == "spirit")
               {
                  _loc4_.id = 900000001;
                  _loc4_.num = _loc2_ as int;
                  _loc4_.name = "灵魂";
                  _loc3_.push(_loc4_);
                  __test.sp += _loc4_.num;
               }
               else if(_loc10_ == "itemID")
               {
                  for(_loc17_ in _loc6_.itemID)
                  {
                     _loc4_ = new DropVO();
                     _loc4_.id = Number(_loc17_);
                     _loc4_.num = _loc6_.itemID[_loc17_];
                     _loc4_.charId = param1;
                     _loc4_.name = ItemVoManager.getIns().getPropName(_loc4_.id);
                     _loc4_.isAutoPickup = ItemVoManager.getIns().getPropVoById(_loc4_.id).isAutoPickup == 1 ? true : false;
                     _loc3_.push(_loc4_);
                  }
               }
               else if(_loc10_ == "equipID")
               {
                  for(_loc16_ in _loc6_.equipID)
                  {
                     _loc4_ = new DropVO();
                     _loc4_.id = Number(_loc16_);
                     _loc4_.num = _loc6_.equipID[_loc16_];
                     _loc4_.charId = param1;
                     _loc4_.name = ItemVoManager.getIns().getPropName(_loc4_.id);
                     _loc13_ = new ItemVo();
                     _loc13_.id = Number(_loc16_);
                     _loc4_.itemvo = _loc13_;
                     _loc4_.isAutoPickup = false;
                     if(ItemVoManager.getIns().getEquipmentVoById(_loc4_.id))
                     {
                        _loc4_.isAutoPickup = ItemVoManager.getIns().getEquipmentVoById(_loc4_.id).isAutoPickup == 1 ? true : false;
                     }
                     _loc3_.push(_loc4_);
                  }
               }
               else if(_loc10_ == "fuIntegral")
               {
                  _loc4_.id = 10;
                  _loc4_.num = _loc2_ as int;
                  _loc4_.name = "福积分";
                  _loc3_.push(_loc4_);
               }
               else if(_loc10_ == "soulID")
               {
                  for(_loc17_ in _loc6_.soulID)
                  {
                     _loc4_ = new DropVO();
                     _loc4_.id = Number(_loc17_);
                     _loc4_.num = _loc6_.itemID[_loc17_];
                     _loc4_.charId = param1;
                     _loc4_.name = ItemVoManager.getIns().getPropName(_loc4_.id);
                     _loc13_ = new ItemVo();
                     _loc13_.id = Number(_loc17_);
                     _loc4_.soulItemvo = _loc13_;
                     _loc3_.push(_loc4_);
                  }
               }
            }
         }
         return _loc3_;
      }
      
      public function pickDrop(param1:DropVO) : void
      {
         var _loc3_:int = 0;
         var _loc2_:Object = _pickObject;
         _loc2_ = _loc2_["pickItems"];
         if(param1.getIsItem() || param1.getIsFeather())
         {
            _loc3_ = 0;
            while(_loc3_ < param1.num)
            {
               _loc2_.push(param1.getDropPickId());
               if(param1.killMonster)
               {
                  _killMonsters.push(param1.killMonster);
               }
               _loc3_++;
            }
         }
         else if(param1.getIsEquip())
         {
            _loc2_.push(param1.getDropPickId());
            if(param1.killMonster)
            {
               _killMonsters.push(param1.killMonster);
            }
         }
         else if(param1.getIsSoul())
         {
            _loc2_.push(param1.getDropPickId());
            if(param1.killMonster)
            {
               _killMonsters.push(param1.killMonster);
            }
         }
         else if(param1.getIspetCrystal())
         {
            _loc2_.push(param1.getDropPickId());
            if(param1.killMonster)
            {
               _killMonsters.push(param1.killMonster);
            }
         }
      }
      
      public function sellItems(param1:int, param2:String, param3:int) : void
      {
         var _loc4_:Object = _deletedItems;
         if(param1 == -1)
         {
            _loc4_.equipID.push(param2);
         }
         else
         {
            _loc4_.sellItems[param1] = param3;
         }
      }
      
      public function useItems(param1:int, param2:int) : void
      {
         var _loc3_:Object = _deletedItems;
         if(_loc3_.useItems.hasOwnProperty(param1))
         {
            var _loc4_:int = param1;
            var _loc5_:Number = _loc3_.useItems[_loc4_] + param2;
            _loc3_.useItems[_loc4_] = _loc5_;
         }
         else
         {
            _loc3_.useItems[param1] = param2;
         }
      }
      
      public function equipP(param1:int, param2:Object) : void
      {
         _pickObject["p" + param1 + "OnEquips"] = param2;
      }
      
      public function getFinishCopyToServer(param1:Boolean, param2:Boolean = false) : Object
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(!_dropLevelVo)
         {
            return null;
         }
         _finishCopy.copyId = _dropLevelVo.copyId;
         _finishCopy.pickItems = _pickObject.pickItems;
         _finishCopy.mobIds = _pickObject.mobIds;
         _finishCopy.killMonsters = _killMonsters;
         _finishCopy.completed = param1 ? 1 : 0;
         _finishCopy.currentEXP = UserModelManager.getIns().playerUserVo1.experience;
         _finishCopy.pickExp = __test.exp;
         _finishCopy.pickSp = __test.sp;
         _finishCopy.propertyP1Str = UserModelManager.getIns().playerUserVo1.getPropertyTotal();
         if(UserModelManager.getIns().playerUserVo2)
         {
            _finishCopy.propertyP2Str = UserModelManager.getIns().playerUserVo2.getPropertyTotal();
         }
         else
         {
            _finishCopy.propertyP2Total = 0;
         }
         if(BattleModelManager.getIns().levelInfo.isShou())
         {
            _pickObject = {
               "pickItems":[],
               "mobIds":[]
            };
            _deletedItems = {
               "sellItems":{},
               "useItems":{},
               "equipID":[]
            };
            _pickObject.deletedItems = _deletedItems;
            _pickObject.p1OnEquips = null;
            _pickObject.p2OnEquips = null;
            _dropObjects = {};
            _loc3_ = BattleModelManager.getIns().levelInfo.fu2;
            if(_loc3_ < 0)
            {
               BattleModelManager.getIns().levelInfo.fu3 = BattleModelManager.getIns().levelInfo.fu3 + _loc3_;
               _loc3_ = 0;
            }
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               getDrop(600101);
               _loc4_++;
            }
            BattleModelManager.getIns().levelInfo.fu2 = 0;
            _finishCopy._mobNum = BattleModelManager.getIns().levelInfo.fu3;
            _finishCopy.pickItems = _pickObject.pickItems;
            _finishCopy.mobIds = _pickObject.mobIds;
            _finishCopy.killMonsters = _killMonsters;
         }
         else if(BattleModelManager.getIns().levelInfo.isQianShou())
         {
            _finishCopy.score = BattleModelManager.getIns().levelInfo.fu;
         }
         else if(BattleModelManager.getIns().levelInfo.isCatchSprite() || BattleModelManager.getIns().levelInfo.isSummonCL() || BattleModelManager.getIns().levelInfo.isGuCang() || BattleModelManager.getIns().levelInfo.isYvtubenyue() || BattleModelManager.getIns().levelInfo.isPutishu())
         {
            _finishCopy.score = BattleModelManager.getIns().levelInfo.fu;
         }
         else if(!BattleModelManager.getIns().levelInfo.isPantao())
         {
            if(BattleModelManager.getIns().levelInfo.isGuCang())
            {
            }
         }
         _finishCopy.hitCombo = hitComboMax;
         SimpleTextLog.getIns().log("_finishCopy.id2=",_finishCopy.copyId);
         SimpleTextLog.getIns().log("_finishCopy.pickItems=",_finishCopy.pickItems);
         SimpleTextLog.getIns().log("_finishCopy.mobIds=",_finishCopy.mobIds);
         SimpleTextLog.getIns().log("_finishCopy.killMonsters=",_finishCopy.killMonsters);
         __test.exp = 0;
         __test.sp = 0;
         return _finishCopy;
      }
      
      public function updateHitCombo() : void
      {
         hitCombo = hitCombo + 1;
         if(hitComboMax < hitCombo)
         {
            hitComboMax = hitCombo;
         }
      }
      
      public function getBattleTime() : int
      {
         var _loc1_:Number = getTimer() - _startTime;
         return int(_loc1_ / 1000);
      }
      
      public function start() : void
      {
         _startTime = getTimer();
      }
      
      public function clearPick() : void
      {
         _finishCopy = {};
         _pickObject = {
            "pickItems":[],
            "mobIds":[]
         };
         if(_isNewDrop)
         {
            _killMonsters = [];
         }
         _deletedItems = {
            "sellItems":{},
            "useItems":{},
            "equipID":[]
         };
         _pickObject.deletedItems = _deletedItems;
         _pickObject.p1OnEquips = null;
         _pickObject.p2OnEquips = null;
         _dropObjects = {};
      }
      
      public function removeCamp(param1:int) : void
      {
         var _loc2_:int = 0;
         _loc2_ = _camp2.length - 1;
         while(_loc2_ >= 0)
         {
            MonsterEntity(_camp2[_loc2_]).goToDie();
            _loc2_--;
         }
      }
      
      public function League_add(param1:UserVO) : void
      {
         if(_userList)
         {
            _userList.push(param1);
         }
         _userList2.push(param1);
      }
      
      public function League_remove(param1:Number) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         if(_userList)
         {
            _loc3_ = _userList.length - 1;
            while(_loc3_ >= 0)
            {
               if(_userList[_loc3_].userId == param1)
               {
                  _userList.splice(_loc3_,1);
               }
               _loc3_--;
            }
         }
         _loc2_ = _userList2.length - 1;
         while(_loc2_ >= 0)
         {
            if(_userList2[_loc2_].userId == param1)
            {
               _userList2.splice(_loc2_,1);
            }
            _loc2_--;
         }
      }
      
      public function getItemNear(param1:Vector2D, param2:int) : Vector2D
      {
         var _loc3_:DropEntity = null;
         if(_dropItems.length > 0)
         {
            if(param2 == 1)
            {
               _loc3_ = _dropItems[0];
            }
            else
            {
               _loc3_ = _dropItems[_dropItems.length - 1];
            }
         }
         if(_loc3_)
         {
            return _loc3_.position.clone();
         }
         return null;
      }
      
      public function removeDropNear(param1:Vector2D, param2:int) : DropEntity
      {
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         if(_dropItems.length > 0)
         {
            _loc4_ = 0;
            while(_loc4_ < _dropItems.length)
            {
               if(_dropItems[_loc4_].position.x >= param1.x)
               {
                  return _dropItems[_loc4_];
               }
               _loc4_++;
            }
            _loc3_ = _dropItems.length - 1;
            while(_loc3_ >= 0)
            {
               if(_dropItems[_loc3_].position.x <= param1.x)
               {
                  return _dropItems[_loc3_];
               }
               _loc3_--;
            }
         }
         return null;
      }
      
      public function removeDrop(param1:DropEntity) : void
      {
         var _loc4_:int = 0;
         _loc4_ = 0;
         while(_loc4_ < _dropItems.length)
         {
            if(_dropItems[_loc4_] == param1)
            {
               _dropItems.splice(_loc4_,1);
               break;
            }
            _loc4_++;
         }
         var _loc3_:int = 0;
         var _loc2_:* = param1.drovo.charId;
         if(_pickObject.mobIds)
         {
            _loc3_ = int(_pickObject.mobIds.indexOf(_loc2_));
            if(_loc3_ > -1)
            {
               _pickObject.mobIds.splice(_loc3_,1);
            }
         }
         if(isNewDrop)
         {
            _loc2_ = _loc2_ + "_" + param1.drovo.index;
         }
         if(_killMonsters)
         {
            _loc3_ = _killMonsters.indexOf(_loc2_);
            if(_loc3_ > -1)
            {
               _killMonsters.splice(_loc3_,1);
            }
         }
      }
      
      public function initPetPk(param1:Object, param2:Object, param3:Object) : void
      {
         _pkPetInfo1.length = 0;
         _pkPetInfo2.length = 0;
         initPetPKUser(1,param1.petList,1,_pkPetInfo1);
         initPetPKUser(2,param2.petList,1,_pkPetInfo2);
         _pkEndData.isfightBack = 0;
         _pkEndData.pkRecordId = param3.pkRecordId;
         _pkEndData.rolename1 = param1.name;
         _pkEndData.rolename2 = param2.name;
         _pkEndData.charId1 = param1.charId;
         _pkEndData.charId2 = param2.charId;
         _pkEndData.userId1 = param1.userId;
         _pkEndData.userId2 = param2.userId;
         _pkEndData.isPkSelf = false;
      }
      
      private function initPetPKUser(param1:int, param2:Object, param3:int, param4:Vector.<PetInfoVo>) : void
      {
         var _loc6_:int = 0;
         var _loc5_:PetListVo = new PetListVo();
         if(param2)
         {
            _loc5_.itemCount = param2.length;
            _loc5_.buildFromObject({"pets":param2});
         }
         _loc6_ = 0;
         while(_loc6_ < _loc5_.petInfoVos.length)
         {
            _loc5_.petInfoVos[_loc6_].hp *= CommonConfig.pethpMaxRate;
            param4.push(_loc5_.petInfoVos[_loc6_]);
            param4[param4.length - 1].useUserVoHpMax = true;
            _loc6_++;
         }
      }
      
      public function initQc(param1:Object) : void
      {
         var _loc3_:int = 0;
         var _loc2_:UserVO = null;
         maxFrame = param1.maxFrame;
         this.randomSeed = param1.randomSeed.seed1;
         _pkUser1 = new Vector.<UserVO>();
         _loc3_ = 0;
         while(_loc3_ < param1.playerInfo.length)
         {
            _loc2_ = initQCUser(param1.playerInfo[_loc3_]);
            _loc2_.userId = _loc2_.children.userId = param1.playerInfo[_loc3_].playerId;
            _loc2_.isQc = _loc2_.children.isQc = true;
            _loc2_.isPk = _loc2_.children.isPk = false;
            _loc2_.entitieId = _loc2_.children.entitieId = UserVO.EID;
            if(_loc2_.userId == UserModelManager.getIns().getCurretPlayerInfo().userId)
            {
               _loc2_.isMePk = true;
               _loc2_.children.isMePk = true;
               if(isP2Pk)
               {
                  if(_loc3_ == 1)
                  {
                     _loc2_.isMePk = false;
                     _loc2_.children.isMePk = false;
                  }
               }
            }
            _loc2_.playerIndex = _loc2_.children.playerIndex = _loc3_;
            _pkUser1.push(_loc2_);
            _loc3_++;
         }
      }
      
      public function initPkSelf() : void
      {
         _pkUser1 = new Vector.<UserVO>();
         _pkUser2 = new Vector.<UserVO>();
         var _loc5_:UserVO = initPkSelfUvo(1);
         _loc5_.isPk = _loc5_.children.isPk = true;
         _loc5_.isMePk = true;
         _pkUser1.push(_loc5_);
         _loc5_ = initPkSelfUvo(2);
         _loc5_.isPk = _loc5_.children.isPk = true;
         _loc5_.isMePk = false;
         _loc5_.userId++;
         _loc5_.children.userId = _loc5_.userId;
         _loc5_.configVo.showHP = 1;
         var _loc4_:int = Unify.getRoleType(_loc5_.charID);
         var _loc1_:ArenaChallengeProxy = ApplicationFacade.getInstance().retrieveProxy("ArenaChallenge") as ArenaChallengeProxy;
         var _loc3_:XML = _loc1_.getConfigDataByroleConditions(_loc4_ + "");
         if(_loc3_)
         {
            _loc5_.equipments.wardRobeArmor = _loc3_["wardRobeArmor"];
            _loc5_.equipments.wardRobeWeapon = _loc3_["wardRobeWeapon"];
            _loc5_.children.equipments.wardRobeArmorTwo = _loc3_["wardRobeArmor"];
            _loc5_.children.equipments.wardRobeWeaponTwo = _loc3_["wardRobeWeapon"];
            for each(var _loc2_:XML in _loc3_.elements())
            {
               _pkEndData[_loc2_.name()] = String(_loc2_.valueOf());
            }
         }
         _pkUser2.push(_loc5_);
         _pkEndData.isfightBack = 0;
         _pkEndData.pkRecordId = 0;
         _pkEndData.rolename1 = _loc5_.name;
         _pkEndData.rolename2 = "神秘竞技者";
         _pkEndData.charId1 = _loc5_.charID;
         _pkEndData.charId2 = _loc5_.charID;
         _pkEndData.isPkSelf = true;
         _pkEndData.uid1 = _loc5_.userId - 1;
         _pkEndData.uid2 = _loc5_.userId - 1;
      }
      
      private function initPkSelfUvo(param1:int) : UserVO
      {
         var _loc2_:String = null;
         var _loc9_:SkillConfigVO = null;
         var _loc6_:UserVO = UserModelManager.getIns().getCurretPlayerInfo().getUserVoBypNum(1);
         _loc6_ = _loc6_.getRootUservo();
         _loc6_.entitieId = UserVO.EID;
         if(_loc6_.children)
         {
            _loc6_.children.entitieId = _loc6_.entitieId;
         }
         var _loc8_:Object = _loc6_.cloneToObject();
         var _loc4_:Object = _loc6_.children.cloneToObject();
         _loc8_.showFashion = _loc6_.showFashion;
         _loc8_.showMoEquip = _loc6_.showMoEquip;
         _loc4_.showFashion = _loc6_.children.showFashion;
         _loc4_.showMoEquip = _loc6_.children.showMoEquip;
         _loc8_.campId = param1;
         _loc4_.campId = param1;
         delete _loc8_.children;
         delete _loc8_.currentChildern;
         delete _loc4_.parent;
         var _loc7_:UserVO = new UserVO();
         _loc7_.entitieId = _loc6_.entitieId + 1;
         _loc7_.children = new UserVO();
         _loc7_.children.entitieId = _loc7_.entitieId + 1;
         _loc7_.children.parent = _loc7_;
         _loc8_.hp *= CommonConfig.hpMaxRate;
         _loc8_.hpMax *= CommonConfig.hpMaxRate;
         _loc4_.hp *= CommonConfig.hpMaxRate;
         _loc4_.hpMax *= CommonConfig.hpMaxRate;
         _loc7_.buildFromObject(_loc8_);
         _loc7_.children.buildFromObject(_loc4_);
         var _loc5_:RoleConfigVO = ManModelManager.getIns().getManById(_loc7_.charID,"role");
         _loc5_ = _loc5_.clone();
         _loc5_.fightConfig = _loc5_.fightConfig.clone();
         _loc7_.configVo = _loc5_;
         if(_loc7_.configVo.param && !_loc7_.configVo.param2)
         {
            _loc7_.configVo.param2 = JSON.parse(_loc7_.configVo.param);
         }
         var _loc3_:int = _loc7_.charID + 5;
         _loc7_.children.charID = _loc3_;
         _loc5_ = ManModelManager.getIns().getManById(_loc3_,"role");
         _loc5_ = _loc5_.clone();
         if(UserModelManager.hasOpenProfession(_loc7_.charID))
         {
            _loc5_.fightConfig = _loc5_.fightConfig.clone();
         }
         _loc7_.children.configVo = _loc5_;
         if(_loc7_.children.configVo.param && !_loc7_.children.configVo.param2)
         {
            _loc7_.children.configVo.param2 = JSON.parse(_loc7_.children.configVo.param);
         }
         _loc7_.isNotJoinBattle = false;
         _loc7_.currentHorser = null;
         _loc7_.currentPet = null;
         _loc7_.children.currentHorser = null;
         _loc7_.children.currentPet = null;
         for(_loc2_ in _loc7_.configVo.skills)
         {
            _loc9_ = _loc7_.configVo.skills[_loc2_];
            _loc9_.level = 0;
            _loc9_.level = 10;
            if(_loc2_.indexOf("ttack") > -1)
            {
               _loc9_.level = 1;
               _loc9_.level2 = 11;
            }
            else if(_loc2_.indexOf("effect") > -1)
            {
               _loc9_.level = _loc6_.configVo.skills[_loc2_].level;
               _loc9_.level2 = _loc6_.configVo.skills[_loc2_].level + 10;
               _loc9_.updateBuff();
               _loc9_.awakeSKId = _loc6_.configVo.skills[_loc2_].awakeSKId;
               _loc9_.awakeSkLev = _loc6_.configVo.skills[_loc2_].awakeSkLev;
            }
         }
         for(_loc2_ in _loc7_.children.configVo.skills)
         {
            _loc9_ = _loc7_.children.configVo.skills[_loc2_];
            _loc9_.level = 0;
            _loc9_.level2 = 10;
            if(_loc2_.indexOf("ttack") > -1)
            {
               _loc9_.level = 1;
               _loc9_.level2 = 11;
            }
            else if(_loc2_.indexOf("effect") > -1)
            {
               _loc9_.level = _loc6_.children.configVo.skills[_loc2_].level;
               _loc9_.level2 = _loc6_.children.configVo.skills[_loc2_].level + 10;
               _loc9_.updateBuff();
               _loc9_.awakeSKId = _loc6_.children.configVo.skills[_loc2_].awakeSKId;
               _loc9_.awakeSkLev = _loc6_.children.configVo.skills[_loc2_].awakeSkLev;
            }
         }
         if(_loc6_.currentChildern && param1 == 1)
         {
            _loc7_.currentChildern = _loc7_.children;
         }
         return _loc7_;
      }
      
      public function initPk(param1:Object, param2:Object, param3:Object) : void
      {
         _pkUser1 = new Vector.<UserVO>();
         _pkUser2 = new Vector.<UserVO>();
         _pkUser1.push(initPkUser(param1,1,param1.p1Info,1));
         if(param1.p2Info)
         {
            _pkUser1.push(initPkUser(param1,1,param1.p2Info,2));
         }
         _pkUser2.push(initPkUser(param2,2,param2.p1Info,1));
         if(param2.p2Info)
         {
            _pkUser2.push(initPkUser(param2,2,param2.p2Info,2));
         }
         _pkEndData.isfightBack = param3.isfightBack;
         _pkEndData.pkRecordId = param3.pkRecordId;
         _pkEndData.rolename1 = param1.name;
         _pkEndData.rolename2 = param2.name;
         _pkEndData.charId1 = param1.p1Info.charID;
         _pkEndData.charId2 = param2.p1Info.charID;
         _pkEndData.isPkSelf = false;
         _pkEndData.uid1 = _pkUser1[0].userId;
         _pkEndData.uid2 = _pkUser2[0].userId;
      }
      
      private function initPkUser(param1:Object, param2:int, param3:Object, param4:int) : UserVO
      {
         var _loc12_:SkillConfigVO = null;
         var _loc5_:String = null;
         var _loc11_:RoleConfigVO = null;
         var _loc14_:* = null;
         var _loc9_:int = 0;
         var _loc6_:Array = null;
         var _loc7_:int = 0;
         var _loc10_:Object = null;
         if(param2 == 1)
         {
         }
         var _loc13_:UserVO = new UserVO();
         _loc13_.children = new UserVO();
         _loc13_.children.parent = _loc13_;
         _loc13_.buildFromObject(param3);
         _loc13_.userId = param1.userId;
         if(param3.professionType == 2 && _loc13_.userId == UserModelManager.getIns().getCurretPlayerInfo().userId)
         {
            _loc13_.currentChildern = _loc13_.children;
         }
         _loc13_.isRole = true;
         _loc13_.campId = param2;
         _loc13_.ps = param4;
         _loc13_.type = "role";
         _loc13_.name = param1.name;
         _loc13_.isPk = true;
         if(param2 == 1)
         {
            _loc13_.isMePk = true;
         }
         _loc13_.mode = 1;
         if(_loc13_.equipments)
         {
            _loc13_.equipments.yfFrame = -100;
            _loc13_.equipments.wqFrame = -100;
         }
         if(UserModelManager.getIns().isRole(_loc13_.charID) == false)
         {
            CreateComponent.createAutoWarnBar(_loc13_.name + "user.charID=" + _loc13_.charID,10);
         }
         _loc13_.children.buildFromObject(param3);
         _loc13_.children.isRole = true;
         _loc13_.children.campId = param2;
         _loc13_.children.userId = param1.userId;
         _loc13_.children.ps = param4;
         _loc13_.children.type = "role";
         _loc13_.children.name = param1.name;
         _loc13_.children.isPk = true;
         if(param2 == 1)
         {
            _loc13_.children.isMePk = true;
         }
         _loc13_.children.mode = 1;
         if(_loc13_.children.equipments)
         {
            _loc13_.children.equipments.yfFrame = -100;
            _loc13_.children.equipments.wqFrame = -100;
         }
         if(param3.swordYi)
         {
            SwordModelManager.getIns().intAttr(_loc13_,param3.swordYi);
            _loc13_.hp = _loc13_.hpMax;
            _loc13_.mp = _loc13_.mpMax;
            if(_loc13_.children)
            {
               _loc13_.children.hp = _loc13_.children.hpMax;
               _loc13_.children.mp = _loc13_.children.mpMax;
            }
         }
         _loc13_.hp = _loc13_.hpMax = _loc13_.hpMax * CommonConfig.hpMaxRate * 1;
         _loc13_.protectedData.setValue("hp",_loc13_.hp);
         _loc13_.protectedData.setValue("hpMax",_loc13_.hpMax);
         _loc13_.reHP *= CommonConfig.hpMaxRate;
         _loc13_.protectedData.setValue("reHP",_loc13_.reHP);
         _loc13_.children.hp = _loc13_.children.hpMax = _loc13_.children.hpMax * CommonConfig.hpMaxRate * 1;
         _loc13_.children.protectedData.setValue("hp",_loc13_.children.hp);
         _loc13_.children.protectedData.setValue("hpMax",_loc13_.children.hpMax);
         _loc13_.children.reHP *= CommonConfig.hpMaxRate;
         _loc13_.children.protectedData.setValue("reHP",_loc13_.children.reHP);
         _loc11_ = ManModelManager.getIns().getManById(_loc13_.charID,"role");
         _loc11_ = _loc11_.clone();
         if(param2 == 2)
         {
            _loc11_.showHP = 1;
            _loc11_.showName = 1;
         }
         _loc11_.fightConfig = _loc11_.fightConfig.clone();
         _loc13_.configVo = _loc11_;
         for(_loc5_ in _loc13_.configVo.skills)
         {
            _loc12_ = _loc13_.configVo.skills[_loc5_];
            _loc12_.level = 1;
            _loc12_.level2 = 11;
            if(param2 == 1)
            {
               _loc12_.level = 0;
               _loc12_.level2 = 10;
            }
            if(_loc5_.indexOf("ttack") > -1)
            {
               _loc12_.level = 1;
               _loc12_.level2 = 11;
            }
         }
         loop1:
         for each(var _loc8_:FightSkillVo in _loc13_.fightSkills)
         {
            var _loc19_:int = 0;
            var _loc18_:Dictionary = _loc13_.configVo.skills;
            do
            {
               for each(_loc12_ in _loc18_)
               {
               }
               continue loop1;
            }
            while(_loc12_.id != _loc8_.skillId);
            _loc12_.level = _loc8_.level;
            _loc12_.level2 = _loc8_.level + 10;
            _loc12_.updateBuff();
            _loc12_.awakeSKId = _loc8_.awakeSkId;
            _loc12_.awakeSkLev = _loc8_.awakeSkLev;
         }
         if(_loc13_.children)
         {
            _loc9_ = _loc13_.charID + 5;
            _loc13_.children.charID = _loc9_;
            _loc11_ = ManModelManager.getIns().getManById(_loc13_.children.charID,"role");
            _loc11_ = _loc11_.clone();
            if(param2 == 2)
            {
               _loc11_.showHP = 1;
               _loc11_.showName = 1;
            }
            _loc11_.fightConfig = _loc11_.fightConfig.clone();
            _loc13_.children.configVo = _loc11_;
            for(_loc5_ in _loc13_.children.configVo.skills)
            {
               _loc12_ = _loc13_.children.configVo.skills[_loc5_];
               _loc12_.level = 1;
               _loc12_.level2 = 11;
               if(param2 == 1)
               {
                  _loc12_.level = 0;
                  _loc12_.level2 = 10;
               }
               if(_loc5_.indexOf("ttack") > -1)
               {
                  _loc12_.level = 1;
                  _loc12_.level2 = 11;
               }
            }
            loop4:
            for each(_loc8_ in _loc13_.children.fightSkills)
            {
               var _loc25_:int = 0;
               var _loc24_:Dictionary = _loc13_.children.configVo.skills;
               do
               {
                  for each(_loc12_ in _loc24_)
                  {
                  }
                  continue loop4;
               }
               while(_loc12_.id != _loc8_.skillId);
               _loc12_.level = _loc8_.level;
               _loc12_.level2 = _loc8_.level + 10;
               _loc12_.updateBuff();
               _loc12_.awakeSKId = _loc8_.awakeSkId;
               _loc12_.awakeSkLev = _loc8_.awakeSkLev;
            }
         }
         if(param4 == 1)
         {
            _loc13_.keyBoard.setKey(87,22);
            _loc13_.keyBoard.setKey(65,23);
            _loc13_.keyBoard.setKey(83,21);
            _loc13_.keyBoard.setKey(68,24);
            _loc13_.keyBoard.setKey(74,41);
            _loc13_.keyBoard.setKey(75,6);
            _loc13_.keyBoard.setKey(32,ActionState.WU_SHUAN);
            _loc13_.keyBoard.setKey(72,1002);
            _loc13_.keyBoard.setKey(80,1003);
            _loc13_.keyBoard.setKey(89,71);
            _loc13_.keyBoard.setKey(85,72);
            _loc13_.keyBoard.setKey(73,73);
            _loc13_.keyBoard.setKey(79,74);
            _loc13_.keyBoard.setKey(76,75);
            _loc13_.keyBoard.setKey(90,200);
            _loc13_.keyBoard.setKey(81,401);
            if(_loc13_.children)
            {
               _loc13_.children.keyBoard.setKey(87,22);
               _loc13_.children.keyBoard.setKey(65,23);
               _loc13_.children.keyBoard.setKey(83,21);
               _loc13_.children.keyBoard.setKey(68,24);
               _loc13_.children.keyBoard.setKey(74,41);
               _loc13_.children.keyBoard.setKey(75,6);
               _loc13_.children.keyBoard.setKey(32,ActionState.WU_SHUAN);
               _loc13_.children.keyBoard.setKey(72,1002);
               _loc13_.children.keyBoard.setKey(80,1003);
               _loc13_.children.keyBoard.setKey(70,301);
               _loc13_.children.keyBoard.setKey(89,71);
               _loc13_.children.keyBoard.setKey(85,72);
               _loc13_.children.keyBoard.setKey(73,73);
               _loc13_.children.keyBoard.setKey(79,74);
               _loc13_.children.keyBoard.setKey(76,75);
               _loc13_.children.keyBoard.setKey(90,200);
               _loc13_.children.keyBoard.setKey(81,401);
            }
            _loc6_ = param3.keyBoard;
            _loc7_ = 0;
            if(_loc6_ == null || _loc6_ && _loc6_.length == 0)
            {
               _loc6_ = [];
               _loc6_.push({
                  "keyCode":89,
                  "ac":71
               });
               _loc6_.push({
                  "keyCode":85,
                  "ac":72
               });
               _loc6_.push({
                  "keyCode":73,
                  "ac":73
               });
               _loc6_.push({
                  "keyCode":79,
                  "ac":74
               });
               _loc6_.push({
                  "keyCode":76,
                  "ac":75
               });
            }
            _loc7_ = 0;
            while(_loc7_ < _loc6_.length)
            {
               _loc10_ = _loc6_[_loc7_];
               _loc13_.keyBoard.setKey(_loc10_.keyCode,_loc10_.ac);
               _loc7_++;
            }
            _loc13_.keyBoardMagic = param3.keyBoardMagic;
            if(_loc13_.children)
            {
               _loc6_ = param3.keyBoardTwo;
               if(_loc6_ == null || _loc6_ && _loc6_.length == 0)
               {
                  _loc6_ = [];
                  _loc6_.push({
                     "keyCode":89,
                     "ac":71
                  });
                  _loc6_.push({
                     "keyCode":85,
                     "ac":72
                  });
                  _loc6_.push({
                     "keyCode":73,
                     "ac":73
                  });
                  _loc6_.push({
                     "keyCode":79,
                     "ac":74
                  });
                  _loc6_.push({
                     "keyCode":76,
                     "ac":75
                  });
               }
               _loc7_ = 0;
               while(_loc7_ < _loc6_.length)
               {
                  _loc10_ = _loc6_[_loc7_];
                  _loc13_.children.keyBoard.setKey(_loc10_.keyCode,_loc10_.ac);
                  _loc7_++;
               }
               _loc13_.children.keyBoardMagic = param3.keyBoardMagic;
            }
         }
         else
         {
            _loc13_.keyBoard.setKey(38,22);
            _loc13_.keyBoard.setKey(40,21);
            _loc13_.keyBoard.setKey(37,23);
            _loc13_.keyBoard.setKey(39,24);
            _loc13_.keyBoard.setKey(97,41);
            _loc13_.keyBoard.setKey(98,6);
            _loc13_.keyBoard.setKey(96,ActionState.WU_SHUAN);
            _loc13_.keyBoard.setKey(103,1002);
            _loc13_.keyBoard.setKey(106,1003);
            _loc13_.keyBoard.setKey(99,71);
            _loc13_.keyBoard.setKey(100,72);
            _loc13_.keyBoard.setKey(101,73);
            _loc13_.keyBoard.setKey(102,74);
            _loc13_.keyBoard.setKey(104,75);
            _loc13_.keyBoard.setKey(105,200);
            _loc13_.keyBoard.setKey(107,401);
            if(_loc13_.children)
            {
               _loc13_.children.keyBoard.setKey(38,22);
               _loc13_.children.keyBoard.setKey(40,23);
               _loc13_.children.keyBoard.setKey(37,21);
               _loc13_.children.keyBoard.setKey(39,24);
               _loc13_.children.keyBoard.setKey(97,41);
               _loc13_.children.keyBoard.setKey(98,6);
               _loc13_.children.keyBoard.setKey(96,ActionState.WU_SHUAN);
               _loc13_.children.keyBoard.setKey(103,1002);
               _loc13_.children.keyBoard.setKey(106,1003);
               _loc13_.children.keyBoard.setKey(99,71);
               _loc13_.children.keyBoard.setKey(100,72);
               _loc13_.children.keyBoard.setKey(101,73);
               _loc13_.children.keyBoard.setKey(102,74);
               _loc13_.children.keyBoard.setKey(104,75);
            }
            _loc6_ = param3.keyBoard;
            if(_loc6_ == null || _loc6_ && _loc6_.length == 0)
            {
               _loc6_ = [];
               _loc6_.push({
                  "keyCode":99,
                  "ac":71
               });
               _loc6_.push({
                  "keyCode":100,
                  "ac":72
               });
               _loc6_.push({
                  "keyCode":101,
                  "ac":73
               });
               _loc6_.push({
                  "keyCode":102,
                  "ac":74
               });
               _loc6_.push({
                  "keyCode":104,
                  "ac":75
               });
            }
            _loc7_ = 0;
            while(_loc7_ < _loc6_.length)
            {
               _loc10_ = _loc6_[_loc7_];
               _loc13_.keyBoard.setKey(_loc10_.keyCode,_loc10_.ac);
               _loc7_++;
            }
            _loc13_.keyBoardMagic = param3.keyBoardMagic;
         }
         if(_loc13_.children)
         {
            _loc6_ = param3.keyBoardTwo;
            if(_loc6_ == null || _loc6_ && _loc6_.length == 0)
            {
               _loc6_ = [];
               _loc6_.push({
                  "keyCode":99,
                  "ac":71
               });
               _loc6_.push({
                  "keyCode":100,
                  "ac":72
               });
               _loc6_.push({
                  "keyCode":101,
                  "ac":73
               });
               _loc6_.push({
                  "keyCode":102,
                  "ac":74
               });
               _loc6_.push({
                  "keyCode":104,
                  "ac":75
               });
            }
            _loc7_ = 0;
            while(_loc7_ < _loc6_.length)
            {
               _loc10_ = _loc6_[_loc7_];
               _loc13_.children.keyBoard.setKey(_loc10_.keyCode,_loc10_.ac);
               _loc7_++;
            }
            _loc13_.children.keyBoardMagic = param3.keyBoardMagic;
         }
         return _loc13_;
      }
      
      public function initQCUser(param1:Object) : UserVO
      {
         var _loc6_:SkillConfigVO = null;
         var _loc3_:String = null;
         var _loc5_:RoleConfigVO = null;
         var _loc9_:* = null;
         var _loc4_:Object = null;
         param1.children = null;
         var _loc8_:UserVO = new UserVO();
         _loc8_.children = new UserVO();
         _loc8_.buildFromObject(param1);
         _loc8_.children.buildFromObject(param1);
         _loc8_.children.parent = _loc8_;
         _loc8_.currentChildern = null;
         _loc8_.children.currentChildern = null;
         if(param1.professionType == 2)
         {
            _loc8_.currentChildern = _loc8_.children;
         }
         _loc8_.isRole = true;
         _loc8_.children.isRole = true;
         if(BattleModelManager.getIns().isTeam == false)
         {
            _loc8_.hp = _loc8_.hpMax = _loc8_.hpMax * CommonConfig.hpMaxRate * 1;
            _loc8_.children.hp = _loc8_.children.hpMax = _loc8_.children.hpMax * CommonConfig.hpMaxRate * 1;
            _loc8_.protectedData.setValue("hp",_loc8_.hp);
            _loc8_.children.protectedData.setValue("hp",_loc8_.children.hp);
            _loc8_.protectedData.setValue("hpMax",_loc8_.hpMax);
            _loc8_.children.protectedData.setValue("hpMax",_loc8_.children.hpMax);
            _loc8_.reHP *= CommonConfig.hpMaxRate;
            _loc8_.children.reHP *= CommonConfig.hpMaxRate;
            _loc8_.protectedData.setValue("reHP",_loc8_.reHP);
            _loc8_.children.protectedData.setValue("reHP",_loc8_.children.reHP);
         }
         if(param1.hasOwnProperty("ps"))
         {
            _loc8_.ps = param1.ps;
            _loc8_.children.ps = _loc8_.ps;
         }
         else
         {
            _loc8_.ps = 1;
            _loc8_.children.ps = 1;
         }
         _loc8_.type = _loc8_.children.type = "role";
         _loc8_.isPk = _loc8_.children.isPk = true;
         _loc8_.mode = _loc8_.children.mode = 1;
         if(_loc8_.equipments)
         {
            _loc8_.equipments.yfFrame = -100;
            _loc8_.equipments.wqFrame = -100;
         }
         if(_loc8_.children.equipments)
         {
            _loc8_.children.equipments.yfFrame = -100;
            _loc8_.children.equipments.wqFrame = -100;
         }
         if(UserModelManager.getIns().isRole(_loc8_.charID) == false)
         {
            CreateComponent.createAutoWarnBar(_loc8_.name + "user.charID=" + _loc8_.charID,10);
         }
         _loc5_ = ManModelManager.getIns().getManById(_loc8_.charID,"role");
         _loc5_ = _loc5_.clone();
         _loc5_.showHP = 1;
         _loc5_.showName = 1;
         _loc5_.fightConfig = _loc5_.fightConfig.clone();
         _loc8_.configVo = _loc5_;
         _loc8_.children.charID = _loc8_.charID + 5;
         _loc5_ = ManModelManager.getIns().getManById(_loc8_.children.charID,"role");
         _loc5_ = _loc5_.clone();
         _loc5_.showHP = 1;
         _loc5_.showName = 1;
         _loc5_.fightConfig = _loc5_.fightConfig.clone();
         _loc8_.children.configVo = _loc5_;
         for(_loc3_ in _loc8_.configVo.skills)
         {
            _loc6_ = _loc8_.configVo.skills[_loc3_];
            _loc6_.level = 0;
            _loc6_.level2 = 10;
            if(_loc3_.indexOf("ttack") > -1)
            {
               _loc6_.level = 1;
               _loc6_.level2 = 11;
            }
         }
         for(_loc3_ in _loc8_.children.configVo.skills)
         {
            _loc6_ = _loc8_.children.configVo.skills[_loc3_];
            _loc6_.level = 0;
            _loc6_.level2 = 10;
            if(_loc3_.indexOf("ttack") > -1)
            {
               _loc6_.level = 1;
               _loc6_.level2 = 11;
            }
         }
         for each(var _loc2_:FightSkillVo in _loc8_.fightSkills)
         {
            for each(_loc6_ in _loc8_.configVo.skills)
            {
               if(_loc6_.id == _loc2_.skillId)
               {
                  _loc6_.level = _loc2_.level;
                  _loc6_.level2 = _loc2_.level + 10;
                  _loc6_.updateBuff();
                  _loc6_.awakeSKId = _loc2_.awakeSkId;
                  _loc6_.awakeSkLev = _loc2_.awakeSkLev;
               }
            }
            for each(_loc6_ in _loc8_.children.configVo.skills)
            {
               if(_loc6_.id == _loc2_.skillId)
               {
                  _loc6_.level = _loc2_.level;
                  _loc6_.level2 = _loc2_.level + 10;
                  _loc6_.updateBuff();
                  _loc6_.awakeSKId = _loc2_.awakeSkId;
                  _loc6_.awakeSkLev = _loc2_.awakeSkLev;
               }
            }
         }
         if(_loc8_.ps == 1)
         {
            _loc8_.keyBoard.setKey(87,22);
            _loc8_.keyBoard.setKey(65,23);
            _loc8_.keyBoard.setKey(83,21);
            _loc8_.keyBoard.setKey(68,24);
            _loc8_.keyBoard.setKey(74,41);
            _loc8_.keyBoard.setKey(75,6);
            _loc8_.keyBoard.setKey(32,ActionState.WU_SHUAN);
            _loc8_.keyBoard.setKey(72,1002);
            _loc8_.keyBoard.setKey(80,1003);
            _loc8_.keyBoard.setKey(89,71);
            _loc8_.keyBoard.setKey(85,72);
            _loc8_.keyBoard.setKey(73,73);
            _loc8_.keyBoard.setKey(79,74);
            _loc8_.keyBoard.setKey(76,75);
            _loc8_.keyBoard.setKey(90,200);
            _loc8_.keyBoard.setKey(81,401);
            _loc8_.children.keyBoard.setKey(87,22);
            _loc8_.children.keyBoard.setKey(65,23);
            _loc8_.children.keyBoard.setKey(83,21);
            _loc8_.children.keyBoard.setKey(68,24);
            _loc8_.children.keyBoard.setKey(74,41);
            _loc8_.children.keyBoard.setKey(75,6);
            _loc8_.children.keyBoard.setKey(32,ActionState.WU_SHUAN);
            _loc8_.children.keyBoard.setKey(72,1002);
            _loc8_.children.keyBoard.setKey(80,1003);
            _loc8_.children.keyBoard.setKey(89,71);
            _loc8_.children.keyBoard.setKey(85,72);
            _loc8_.children.keyBoard.setKey(73,73);
            _loc8_.children.keyBoard.setKey(79,74);
            _loc8_.children.keyBoard.setKey(76,75);
            _loc8_.children.keyBoard.setKey(90,200);
            _loc8_.children.keyBoard.setKey(81,401);
         }
         else
         {
            _loc8_.keyBoard.setKey(38,22);
            _loc8_.keyBoard.setKey(40,21);
            _loc8_.keyBoard.setKey(37,23);
            _loc8_.keyBoard.setKey(39,24);
            _loc8_.keyBoard.setKey(97,41);
            _loc8_.keyBoard.setKey(98,6);
            _loc8_.keyBoard.setKey(96,ActionState.WU_SHUAN);
            _loc8_.keyBoard.setKey(103,1002);
            _loc8_.keyBoard.setKey(106,1003);
            _loc8_.keyBoard.setKey(99,71);
            _loc8_.keyBoard.setKey(100,72);
            _loc8_.keyBoard.setKey(101,73);
            _loc8_.keyBoard.setKey(102,74);
            _loc8_.keyBoard.setKey(104,75);
            _loc8_.keyBoard.setKey(105,200);
            _loc8_.keyBoard.setKey(107,401);
            _loc8_.children.keyBoard.setKey(38,22);
            _loc8_.children.keyBoard.setKey(40,21);
            _loc8_.children.keyBoard.setKey(37,23);
            _loc8_.children.keyBoard.setKey(39,24);
            _loc8_.children.keyBoard.setKey(97,41);
            _loc8_.children.keyBoard.setKey(98,6);
            _loc8_.children.keyBoard.setKey(96,ActionState.WU_SHUAN);
            _loc8_.children.keyBoard.setKey(103,1002);
            _loc8_.children.keyBoard.setKey(106,1003);
            _loc8_.children.keyBoard.setKey(99,71);
            _loc8_.children.keyBoard.setKey(100,72);
            _loc8_.children.keyBoard.setKey(101,73);
            _loc8_.children.keyBoard.setKey(102,74);
            _loc8_.children.keyBoard.setKey(104,75);
            _loc8_.children.keyBoard.setKey(105,200);
            _loc8_.children.keyBoard.setKey(107,401);
         }
         var _loc7_:Array = param1.keyBoard;
         var _loc10_:int = 0;
         _loc10_ = 0;
         while(_loc10_ < _loc7_.length)
         {
            _loc4_ = _loc7_[_loc10_];
            _loc8_.keyBoard.setKey(_loc4_.keyCode,_loc4_.ac);
            _loc10_++;
         }
         _loc8_.keyBoardMagic = param1.keyBoardMagic;
         _loc7_ = param1.keyBoardTwo;
         if(_loc7_)
         {
            _loc10_ = 0;
            while(_loc10_ < _loc7_.length)
            {
               _loc4_ = _loc7_[_loc10_];
               _loc8_.children.keyBoard.setKey(_loc4_.keyCode,_loc4_.ac);
               _loc10_++;
            }
         }
         _loc8_.children.keyBoardMagic = param1.keyBoardMagic;
         return _loc8_;
      }
      
      public function initTeamHorseUser(param1:Object, param2:int, param3:Object, param4:int) : UserVO
      {
         var _loc12_:SkillConfigVO = null;
         var _loc5_:String = null;
         var _loc11_:RoleConfigVO = null;
         var _loc14_:* = null;
         var _loc9_:int = 0;
         var _loc6_:Array = null;
         var _loc7_:int = 0;
         var _loc10_:Object = null;
         if(param2 == 1)
         {
         }
         var _loc13_:UserVO = new UserVO();
         _loc13_.children = new UserVO();
         _loc13_.children.parent = _loc13_;
         _loc13_.buildFromObject(param3);
         _loc13_.userId = param1.userId;
         if(param3.professionType == 2 && _loc13_.userId == UserModelManager.getIns().getCurretPlayerInfo().userId)
         {
            _loc13_.currentChildern = _loc13_.children;
         }
         _loc13_.isRole = true;
         _loc13_.isTeamHorse = true;
         _loc13_.sword = param3.sword || {};
         _loc13_.campId = param2;
         _loc13_.ps = param4;
         _loc13_.type = "role";
         _loc13_.name = param1.name;
         _loc13_.userId = param1.playerId;
         _loc13_.mode = 1;
         if(_loc13_.equipments)
         {
            _loc13_.equipments.yfFrame = -100;
            _loc13_.equipments.wqFrame = -100;
         }
         if(UserModelManager.getIns().isRole(_loc13_.charID) == false)
         {
            CreateComponent.createAutoWarnBar(_loc13_.name + "user.charID=" + _loc13_.charID,10);
         }
         _loc13_.children.buildFromObject(param3);
         _loc13_.children.isRole = true;
         _loc13_.children.isTeamHorse = true;
         _loc13_.children.sword = param3.sword;
         _loc13_.children.campId = param2;
         _loc13_.children.userId = param1.playerId;
         _loc13_.children.ps = param4;
         _loc13_.children.type = "role";
         _loc13_.children.name = param1.name;
         _loc13_.children.mode = 1;
         if(_loc13_.children.equipments)
         {
            _loc13_.children.equipments.yfFrame = -100;
            _loc13_.children.equipments.wqFrame = -100;
         }
         if(param3.swordYi)
         {
            SwordModelManager.getIns().intAttr(_loc13_,param3.swordYi);
            _loc13_.hp = _loc13_.hpMax;
            _loc13_.mp = _loc13_.mpMax;
            if(_loc13_.children)
            {
               _loc13_.children.hp = _loc13_.children.hpMax;
               _loc13_.children.mp = _loc13_.children.mpMax;
            }
         }
         _loc11_ = ManModelManager.getIns().getManById(_loc13_.charID,"role");
         _loc11_ = _loc11_.clone();
         if(param2 == 2)
         {
            _loc11_.showHP = 1;
            _loc11_.showName = 1;
         }
         _loc11_.fightConfig = _loc11_.fightConfig.clone();
         _loc13_.configVo = _loc11_;
         for(_loc5_ in _loc13_.configVo.skills)
         {
            _loc12_ = _loc13_.configVo.skills[_loc5_];
            _loc12_.level = 1;
            _loc12_.level2 = 11;
            if(param2 == 1)
            {
               _loc12_.level = 0;
               _loc12_.level2 = 10;
            }
            if(_loc5_.indexOf("ttack") > -1)
            {
               _loc12_.level = 1;
               _loc12_.level2 = 11;
            }
         }
         loop1:
         for each(var _loc8_:FightSkillVo in _loc13_.fightSkills)
         {
            var _loc18_:int = 0;
            var _loc17_:Dictionary = _loc13_.configVo.skills;
            do
            {
               for each(_loc12_ in _loc17_)
               {
               }
               continue loop1;
            }
            while(_loc12_.id != _loc8_.skillId);
            _loc12_.level = _loc8_.level;
            _loc12_.level2 = _loc8_.level + 10;
            _loc12_.updateBuff();
            _loc12_.awakeSKId = _loc8_.awakeSkId;
            _loc12_.awakeSkLev = _loc8_.awakeSkLev;
         }
         if(_loc13_.children)
         {
            _loc9_ = _loc13_.charID + 5;
            _loc13_.children.charID = _loc9_;
            _loc11_ = ManModelManager.getIns().getManById(_loc13_.children.charID,"role");
            _loc11_ = _loc11_.clone();
            if(param2 == 2)
            {
               _loc11_.showHP = 1;
               _loc11_.showName = 1;
            }
            _loc11_.fightConfig = _loc11_.fightConfig.clone();
            _loc13_.children.configVo = _loc11_;
            for(_loc5_ in _loc13_.children.configVo.skills)
            {
               _loc12_ = _loc13_.children.configVo.skills[_loc5_];
               _loc12_.level = 1;
               _loc12_.level2 = 11;
               if(param2 == 1)
               {
                  _loc12_.level = 0;
                  _loc12_.level2 = 10;
               }
               if(_loc5_.indexOf("ttack") > -1)
               {
                  _loc12_.level = 1;
                  _loc12_.level2 = 11;
               }
            }
            loop4:
            for each(_loc8_ in _loc13_.children.fightSkills)
            {
               var _loc24_:int = 0;
               var _loc23_:Dictionary = _loc13_.children.configVo.skills;
               do
               {
                  for each(_loc12_ in _loc23_)
                  {
                  }
                  continue loop4;
               }
               while(_loc12_.id != _loc8_.skillId);
               _loc12_.level = _loc8_.level;
               _loc12_.level2 = _loc8_.level + 10;
               _loc12_.updateBuff();
               _loc12_.awakeSKId = _loc8_.awakeSkId;
               _loc12_.awakeSkLev = _loc8_.awakeSkLev;
            }
         }
         if(param4 == 1)
         {
            _loc13_.keyBoard.setKey(87,22);
            _loc13_.keyBoard.setKey(65,23);
            _loc13_.keyBoard.setKey(83,21);
            _loc13_.keyBoard.setKey(68,24);
            _loc13_.keyBoard.setKey(74,41);
            _loc13_.keyBoard.setKey(75,6);
            _loc13_.keyBoard.setKey(32,ActionState.WU_SHUAN);
            _loc13_.keyBoard.setKey(72,1002);
            _loc13_.keyBoard.setKey(80,1003);
            _loc13_.keyBoard.setKey(89,71);
            _loc13_.keyBoard.setKey(85,72);
            _loc13_.keyBoard.setKey(73,73);
            _loc13_.keyBoard.setKey(79,74);
            _loc13_.keyBoard.setKey(76,75);
            _loc13_.keyBoard.setKey(90,200);
            _loc13_.keyBoard.setKey(81,401);
            if(_loc13_.children)
            {
               _loc13_.children.keyBoard.setKey(87,22);
               _loc13_.children.keyBoard.setKey(65,23);
               _loc13_.children.keyBoard.setKey(83,21);
               _loc13_.children.keyBoard.setKey(68,24);
               _loc13_.children.keyBoard.setKey(74,41);
               _loc13_.children.keyBoard.setKey(75,6);
               _loc13_.children.keyBoard.setKey(32,ActionState.WU_SHUAN);
               _loc13_.children.keyBoard.setKey(72,1002);
               _loc13_.children.keyBoard.setKey(80,1003);
               _loc13_.children.keyBoard.setKey(70,301);
               _loc13_.children.keyBoard.setKey(89,71);
               _loc13_.children.keyBoard.setKey(85,72);
               _loc13_.children.keyBoard.setKey(73,73);
               _loc13_.children.keyBoard.setKey(79,74);
               _loc13_.children.keyBoard.setKey(76,75);
               _loc13_.children.keyBoard.setKey(90,200);
               _loc13_.children.keyBoard.setKey(81,401);
            }
            _loc6_ = param3.keyBoard;
            _loc7_ = 0;
            if(_loc6_ == null || _loc6_ && _loc6_.length == 0)
            {
               _loc6_ = [];
               _loc6_.push({
                  "keyCode":89,
                  "ac":71
               });
               _loc6_.push({
                  "keyCode":85,
                  "ac":72
               });
               _loc6_.push({
                  "keyCode":73,
                  "ac":73
               });
               _loc6_.push({
                  "keyCode":79,
                  "ac":74
               });
               _loc6_.push({
                  "keyCode":76,
                  "ac":75
               });
            }
            _loc7_ = 0;
            while(_loc7_ < _loc6_.length)
            {
               _loc10_ = _loc6_[_loc7_];
               _loc13_.keyBoard.setKey(_loc10_.keyCode,_loc10_.ac);
               _loc7_++;
            }
            _loc13_.keyBoardMagic = param3.keyBoardMagic;
            if(_loc13_.children)
            {
               _loc6_ = param3.keyBoardTwo;
               if(_loc6_ == null || _loc6_ && _loc6_.length == 0)
               {
                  _loc6_ = [];
                  _loc6_.push({
                     "keyCode":89,
                     "ac":71
                  });
                  _loc6_.push({
                     "keyCode":85,
                     "ac":72
                  });
                  _loc6_.push({
                     "keyCode":73,
                     "ac":73
                  });
                  _loc6_.push({
                     "keyCode":79,
                     "ac":74
                  });
                  _loc6_.push({
                     "keyCode":76,
                     "ac":75
                  });
               }
               _loc7_ = 0;
               while(_loc7_ < _loc6_.length)
               {
                  _loc10_ = _loc6_[_loc7_];
                  _loc13_.children.keyBoard.setKey(_loc10_.keyCode,_loc10_.ac);
                  _loc7_++;
               }
               _loc13_.children.keyBoardMagic = param3.keyBoardMagic;
            }
         }
         else
         {
            _loc13_.keyBoard.setKey(38,22);
            _loc13_.keyBoard.setKey(40,21);
            _loc13_.keyBoard.setKey(37,23);
            _loc13_.keyBoard.setKey(39,24);
            _loc13_.keyBoard.setKey(97,41);
            _loc13_.keyBoard.setKey(98,6);
            _loc13_.keyBoard.setKey(96,ActionState.WU_SHUAN);
            _loc13_.keyBoard.setKey(103,1002);
            _loc13_.keyBoard.setKey(106,1003);
            _loc13_.keyBoard.setKey(99,71);
            _loc13_.keyBoard.setKey(100,72);
            _loc13_.keyBoard.setKey(101,73);
            _loc13_.keyBoard.setKey(102,74);
            _loc13_.keyBoard.setKey(104,75);
            _loc13_.keyBoard.setKey(105,200);
            _loc13_.keyBoard.setKey(107,401);
            if(_loc13_.children)
            {
               _loc13_.children.keyBoard.setKey(38,22);
               _loc13_.children.keyBoard.setKey(40,23);
               _loc13_.children.keyBoard.setKey(37,21);
               _loc13_.children.keyBoard.setKey(39,24);
               _loc13_.children.keyBoard.setKey(97,41);
               _loc13_.children.keyBoard.setKey(98,6);
               _loc13_.children.keyBoard.setKey(96,ActionState.WU_SHUAN);
               _loc13_.children.keyBoard.setKey(103,1002);
               _loc13_.children.keyBoard.setKey(106,1003);
               _loc13_.children.keyBoard.setKey(99,71);
               _loc13_.children.keyBoard.setKey(100,72);
               _loc13_.children.keyBoard.setKey(101,73);
               _loc13_.children.keyBoard.setKey(102,74);
               _loc13_.children.keyBoard.setKey(104,75);
            }
            _loc6_ = param3.keyBoard;
            if(_loc6_ == null || _loc6_ && _loc6_.length == 0)
            {
               _loc6_ = [];
               _loc6_.push({
                  "keyCode":99,
                  "ac":71
               });
               _loc6_.push({
                  "keyCode":100,
                  "ac":72
               });
               _loc6_.push({
                  "keyCode":101,
                  "ac":73
               });
               _loc6_.push({
                  "keyCode":102,
                  "ac":74
               });
               _loc6_.push({
                  "keyCode":104,
                  "ac":75
               });
            }
            _loc7_ = 0;
            while(_loc7_ < _loc6_.length)
            {
               _loc10_ = _loc6_[_loc7_];
               _loc13_.keyBoard.setKey(_loc10_.keyCode,_loc10_.ac);
               _loc7_++;
            }
            _loc13_.keyBoardMagic = param3.keyBoardMagic;
         }
         if(_loc13_.children)
         {
            _loc6_ = param3.keyBoardTwo;
            if(_loc6_ == null || _loc6_ && _loc6_.length == 0)
            {
               _loc6_ = [];
               _loc6_.push({
                  "keyCode":99,
                  "ac":71
               });
               _loc6_.push({
                  "keyCode":100,
                  "ac":72
               });
               _loc6_.push({
                  "keyCode":101,
                  "ac":73
               });
               _loc6_.push({
                  "keyCode":102,
                  "ac":74
               });
               _loc6_.push({
                  "keyCode":104,
                  "ac":75
               });
            }
            _loc7_ = 0;
            while(_loc7_ < _loc6_.length)
            {
               _loc10_ = _loc6_[_loc7_];
               _loc13_.children.keyBoard.setKey(_loc10_.keyCode,_loc10_.ac);
               _loc7_++;
            }
            _loc13_.children.keyBoardMagic = param3.keyBoardMagic;
         }
         if(param3.professionType == 2)
         {
            _loc13_.currentChildern = _loc13_.children;
         }
         return _loc13_;
      }
      
      public function removeHated(param1:UserVO) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc3_:RoleEntity = null;
         var _loc2_:Vector.<ICollide> = new Vector.<ICollide>();
         if(param1)
         {
            _loc4_ = 0;
            while(_loc4_ < _entitys.length)
            {
               if(_entitys[_loc4_] is RoleEntity && entitys[_loc4_].userVo && entitys[_loc4_].userVo.campId != param1.campId)
               {
                  _loc2_.push(_entitys[_loc4_]);
               }
               _loc4_++;
            }
            _loc5_ = 0;
            while(_loc5_ < _loc2_.length)
            {
               _loc3_ = _loc2_[_loc5_] as RoleEntity;
               if(_loc3_)
               {
                  _loc3_.userVo.removeHatredByEid(param1.entitieId);
               }
               _loc5_++;
            }
         }
      }
      
      public function addHated(param1:UserVO, param2:int) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc4_:RoleEntity = null;
         var _loc3_:Vector.<ICollide> = new Vector.<ICollide>();
         if(param1)
         {
            _loc5_ = 0;
            while(_loc5_ < _entitys.length)
            {
               if(_entitys[_loc5_] is RoleEntity && entitys[_loc5_].userVo && entitys[_loc5_].userVo.campId != param1.campId)
               {
                  _loc3_.push(_entitys[_loc5_]);
               }
               _loc5_++;
            }
            _loc6_ = 0;
            while(_loc6_ < _loc3_.length)
            {
               _loc4_ = _loc3_[_loc6_] as RoleEntity;
               if(_loc4_)
               {
                  _loc4_.addHatredMin0(param1.entitieId,param2);
               }
               _loc6_++;
            }
         }
      }
      
      public function addKeyDown(param1:int, param2:int) : void
      {
         _keyDowns[mapEid].push(param1);
      }
      
      public function addKeyUp(param1:int, param2:int) : void
      {
         _keyUps[mapEid].push(param1);
      }
      
      public function checkKeyDown() : void
      {
         var _loc3_:int = 0;
         var _loc5_:int = 0;
         var _loc1_:Boolean = false;
         if(_recored)
         {
            return;
         }
         var _loc2_:Array = _keyDowns[mapEid - 1];
         var _loc4_:Array = _keyDowns[mapEid];
         if(_loc2_)
         {
            _loc3_ = int(_loc2_[_loc4_.length - 1]);
            _loc5_ = int(_loc4_[_loc4_.length - 1]);
            _loc1_ = _loc3_ == _loc5_;
            if(!_loc1_)
            {
               _loc4_.pop();
               _calKey.length = 0;
            }
            else
            {
               _calKey.push(1);
            }
            if(_calKey.length >= 100)
            {
               _recored = true;
            }
         }
      }
      
      public function addDropBaoXian(param1:Object) : void
      {
         _baoxian = param1;
      }
      
      public function removeDropBaoXian() : void
      {
         _baoxian = null;
      }
      
      public function getPath(param1:Vector2D, param2:Vector2D) : Vector.<Node>
      {
         var _loc7_:Number = NaN;
         var _loc6_:* = undefined;
         var _loc3_:String = null;
         trace("getPath",param1,param2);
         var _loc4_:int = 32;
         var _loc5_:Node = astar.getNode(param2.x / _loc4_,param2.y / _loc4_);
         var _loc8_:Node = astar.getNode(param1.x / _loc4_,param1.y / 32);
         if(!_loc8_ || !_loc5_)
         {
            return null;
         }
         if(_loc5_)
         {
            if(_loc5_.walkable)
            {
               _loc7_ = getTimer();
               _loc6_ = astar.findPath(_loc8_,_loc5_);
               _loc3_ = "";
               if(_loc6_)
               {
                  _loc3_ = "寻路用时:" + (String(getTimer() - _loc7_)) + " ms";
               }
               else
               {
                  _loc3_ = "未找到路径";
               }
               drawPath(_loc6_);
               return _loc6_;
            }
         }
         return null;
      }
      
      private function drawPath(param1:Vector.<Node>) : void
      {
         var _loc5_:int = 0;
         var _loc2_:* = null;
         var _loc6_:int = 0;
      }
      
      public function getCombine() : CombineConfigVO
      {
         var _loc1_:int = 0;
         if(!_currentCombineConfig)
         {
            _loc1_ = 0;
            _loc1_ = BattleModelManager.getIns().getRandom() * 7;
            _currentCombineConfig = LevelModelManager.getIns().combineConfigs[_loc1_];
         }
         return _currentCombineConfig;
      }
      
      public function addSearWarClearMap(param1:int) : void
      {
         if(_searWarClearMaps.indexOf(param1) == -1)
         {
            _searWarClearMaps.push(param1);
         }
      }
      
      public function clearCombie() : void
      {
         _searWarClearMaps.length = 0;
         UserModelManager.getIns().getShip(1).onStart();
         UserModelManager.getIns().getShip(2).onStart();
         _currentCombineConfig = null;
      }
      
      public function GetpkBossAttInfo() : Object
      {
         var _loc1_:Object = _pkBossAttInfo;
         _pkBossAttInfo = {};
         return _loc1_;
      }
      
      public function initPkBoss(param1:Object) : void
      {
         var _loc3_:UnionBossNewVo = null;
         var _loc2_:Array = null;
         _loc3_ = Unify.vo(param1.bossIndex,"UnionBossNew.xml");
         _loc2_ = [];
         if(_loc3_.buffIds)
         {
            _loc2_ = _loc3_.buffIds.split(",");
         }
         param1.bossStatus = {
            "bossOpenTime":0,
            "countdownTime":0,
            "buffIds":_loc2_
         };
         _leagueBossVO = LeagueBossVO.getIns();
         _leagueBossVO.init(param1);
      }
      
      public function inViewPort(param1:Vector2D) : Boolean
      {
         if(param1.x > viewPort.x && param1.x < viewPort.x + viewPort.width + 50)
         {
            if(param1.y > viewPort.y && param1.y < viewPort.y + viewPort.height)
            {
               return true;
            }
         }
         return false;
      }
      
      public function initTeam(param1:Object) : void
      {
         var _loc3_:int = 0;
         var _loc2_:UserVO = null;
         param1;
         maxFrame = param1.maxFrame;
         this.randomSeed = param1.randomSeed.seed1;
         _pkUser1 = new Vector.<UserVO>();
         _loc3_ = 0;
         while(_loc3_ < param1.playerInfo.length)
         {
            _loc2_ = initQCUser(param1.playerInfo[_loc3_]);
            _loc2_.campId = _loc2_.children.campId = 1;
            _loc2_.isPk = _loc2_.children.isPk = false;
            _loc2_.userId = _loc2_.children.userId = param1.playerInfo[_loc3_].playerId;
            _loc2_.isTeam = _loc2_.children.isTeam = true;
            _loc2_.entitieId = _loc2_.children.entitieId = UserVO.EID;
            _loc2_.playerIndex = _loc2_.children.playerIndex = _loc3_;
            _pkUser1.push(_loc2_);
            _loc3_++;
         }
      }
      
      public function League_hide() : void
      {
         var _loc2_:int = 0;
         var _loc1_:UserVO = null;
         _loc2_ = 0;
         while(_loc2_ < this._userList2.length)
         {
            _loc1_ = this.userList2[_loc2_];
            ApplicationFacade.getInstance().sendNotification("NF_REMOVE_PLAYER",{"uid":_loc1_.userId});
            _loc2_++;
         }
         _userList = null;
      }
      
      public function League_show() : void
      {
         _userList = _userList2.concat();
      }
      
      public function HasManByDrop(param1:Number) : int
      {
         if(!this._dropLevelVo)
         {
            return 0;
         }
         return this._dropLevelVo.hasDropByMonsterId(param1);
      }
      
      public function getDropByMonsterId(param1:Number) : Object
      {
         if(!this._dropLevelVo)
         {
            return null;
         }
         return this._dropLevelVo.getDropByMonsterId(param1);
      }
      
      public function setCurrLevelConfig(param1:LevelConfigVO) : void
      {
         this._currLevel = param1;
      }
      
      public function getCurrLevelConfig() : LevelConfigVO
      {
         return this._currLevel;
      }
      
      public function setCurrPlayerPos(param1:Vector2D) : void
      {
         this._currPlayerPos = param1;
      }
      
      public function getCurrPlayerPos() : Vector2D
      {
         return this._currPlayerPos;
      }
      
      public function getPlayeTotal() : int
      {
         var _loc1_:RoleEntity = null;
         var _loc2_:int = 1;
         if(UserModelManager.getIns().getCurretPlayerInfo() && UserModelManager.getIns().getCurretPlayerInfo().pMode == 2)
         {
            if(UserModelManager.getIns().playerUserVo2)
            {
               _loc2_++;
            }
            _loc1_ = this.getPlayerByEntityId(UserModelManager.getIns().playerUserVo1.entitieId) as RoleEntity;
            if(_loc1_ && _loc1_.isDie || _loc1_.deleted)
            {
               _loc2_--;
            }
            if(UserModelManager.getIns().playerUserVo2)
            {
               _loc1_ = this.getPlayerByEntityId(UserModelManager.getIns().playerUserVo2.entitieId) as RoleEntity;
               if(_loc1_ && _loc1_.isDie || _loc1_.deleted)
               {
                  _loc2_--;
               }
            }
         }
         return _loc2_;
      }
      
      public function setLuoHanYuanPlayerPos(param1:Vector2D) : void
      {
         this._currPlayerPosInLuoHanYuan = param1;
      }
      
      public function getLuoHanYuanPlayerPos() : Vector2D
      {
         return this._currPlayerPosInLuoHanYuan;
      }
      
      public function addBuffAttackInfo(param1:int, param2:SkillConfigVO, param3:UserVO, param4:UserVO) : void
      {
         var _loc5_:AttackInfoVO = new AttackInfoVO();
         _loc5_.floating = 0;
         _loc5_.parameter = "";
         _loc5_.direction = 1;
         _loc5_.damageType = 0;
         _loc5_.damageValue = param1;
         _loc5_.attUserVo = param3;
         _loc5_.hurUserVo = param4;
         _loc5_.attSkill = param2;
         _loc5_.ind = 0;
         _loc5_.pos = new Point();
         if(false && param2)
         {
            ApplicationFacade.getInstance().sendNotification("NF_DEBUG_DAMAGE",_loc5_);
         }
         this.addHurtManData(_loc5_);
      }
      
      public function get takeMorePets() : Vector.<int>
      {
         return _takeMorePets;
      }
      
      public function setTakeMorePets(param1:*) : void
      {
         var _loc2_:int = 0;
         _takeMorePets.length = 0;
         _loc2_ = 0;
         while(_loc2_ < param1.length)
         {
            _takeMorePets.push(param1[_loc2_]);
            _loc2_++;
         }
      }
      
      public function calSuckBlood(param1:UserVO, param2:SkillConfigVO, param3:Number) : int
      {
         var _loc6_:Number = 0;
         var _loc5_:PlayerEntity = PlayerEntity(getPlayerByEntityId(param1.entitieId));
         var _loc7_:Boolean = false;
         if(_loc5_)
         {
            _loc6_ = _loc5_.getBuff82V1();
            _loc7_ = param1.type == "role" || param1.type == ManType.HORSE;
         }
         var _loc4_:int = 0;
         var _loc8_:Number = Math.max(1 - _loc6_,0);
         if(_loc7_)
         {
            _loc4_ = Math.min(param1.allsuckBlood * param2.suckBloodFactor,param3) * _loc8_;
         }
         else
         {
            _loc4_ = param1.allsuckBlood * param2.skillDefault * param1.configVo.suckBloodFactor * _loc8_;
         }
         return _loc4_;
      }
      
      public function calBackLash(param1:UserVO, param2:UserVO, param3:SkillConfigVO, param4:Number) : int
      {
         var _loc6_:PlayerEntity = null;
         var _loc5_:Number = NaN;
         var _loc10_:Array = null;
         var _loc8_:Boolean = false;
         _loc8_ = param1.type == "role" || param1.type == ManType.HORSE;
         var _loc7_:int = 0;
         if(_loc8_)
         {
            _loc7_ = param2.allbackLash * param3.backLashFactor;
         }
         else
         {
            _loc7_ = param2.allbackLash * param3.skillDefault * param1.configVo.suckBloodFactor;
         }
         if(_loc7_ > 0)
         {
            _loc6_ = PlayerEntity(getPlayerByEntityId(param1.entitieId));
            if(_loc6_)
            {
               _loc5_ = _loc6_.OnCalDmgRate();
               _loc7_ *= _loc5_;
               _loc10_ = _loc6_.afterBackBlashreduceHuDunHp(_loc7_);
               _loc7_ = int(_loc10_[0]);
            }
         }
         if(_loc7_ > 15000)
         {
            _loc7_;
         }
         var _loc9_:PlayerEntity = this.getPlayerByEntityId(param1.entitieId) as PlayerEntity;
         if(_loc9_)
         {
            _loc7_ *= _loc9_.getBuff88V1();
         }
         return _loc7_;
      }
      
      public function getItemObjByName(param1:String) : *
      {
         var _loc2_:* = Prefab.getObjByName(param1);
         if(!(_loc2_ is WTrigger))
         {
            if(!(_loc2_ is RigidBody))
            {
               if(!_loc2_)
               {
                  _loc2_ = BattleMap.Ins.map.getEntityByName(param1);
               }
            }
         }
         return _loc2_;
      }
      
      public function calSoulCritical(param1:UserVO, param2:UserVO) : Number
      {
         var _loc3_:Number = Math.min(param1.allsoulCritical - param2.allsoulToughness,0.85) + Math.max((param1.allsoulCritical - param2.allsoulToughness - 0.85) / 10,0);
         if(SimpleTextLog.Close)
         {
         }
         if(_loc3_ < 0)
         {
            _loc3_ = 0;
         }
         if(_loc3_ > 1)
         {
            _loc3_ = 1;
         }
         return _loc3_;
      }
      
      public function calDamageBySoul(param1:UserVO, param2:UserVO, param3:Number) : int
      {
         var _loc5_:Number = Number(CommonConfig.soulAtkCoefficient || 0.4);
         var _loc6_:Number = 0;
         var _loc4_:int = 0;
         _loc6_ = _loc5_ + param1.allsoulAtk - param2.allsoulPhydef;
         if(_loc6_ < 0)
         {
            _loc6_ = 0;
         }
         if(_loc6_ > 1.25)
         {
            _loc6_ = 1.25;
         }
         _loc4_ = param3 * _loc6_;
         if(!SimpleTextLog.Close)
         {
            SimpleTextLog.getIns().log2("魂击伤害=" + _loc4_,"A=" + _loc5_,"魂击伤害系数C=" + _loc6_,"at.soulAtk=" + param1.allsoulAtk,"hu.soulPhydef=" + param2.allsoulPhydef);
         }
         return _loc4_;
      }
   }
}

