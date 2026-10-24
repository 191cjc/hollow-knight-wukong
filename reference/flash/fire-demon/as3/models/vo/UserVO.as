package models.vo
{
   import com.game.engine.character.ActionState;
   import com.game.engine.utils.SimpleTextLog;
   import com.game.utils.MathUtils;
   import com.game.utils.Vector2D;
   import com.game.utils.VoBasic;
   import controllers.battle.gushu.ITakePetRougeLike;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   import models.ProtectedData;
   import models.configs.CommonConfig;
   import models.constants.ManType;
   import models.managers.BattleModelManager;
   import models.managers.BuffModelManager;
   import models.managers.BuffSceneManager;
   import models.managers.GlobalData;
   import models.managers.ManModelManager;
   import models.managers.SkillModelManager;
   import models.managers.UserModelManager;
   import models.vo.horse.HorseInfoVo;
   import models.vo.module.BodyLevVo;
   import models.vo.module.EquipmentVo;
   import models.vo.module.ItemVoManager;
   import models.vo.module.SkillLevVo;
   import models.vo.module.SkillPassiveVo;
   import models.vo.module.SwordLevVo;
   import models.vo.pet.PetBloodVo;
   import models.vo.pet.PetInfoVo;
   import models.vo.pet.PetSkillVo;
   import models.vo.pet.TakeCrystal;
   import models.vo.players.Equipment;
   import models.vo.players.FightSkillVo;
   import models.vo.players.ItemVo;
   import modules.ApplicationFacade;
   import modules.bodyStrong.model.BodyStrongModelManager;
   import modules.pet.model.PetModelManager;
   import modules.skill.model.SkillUpgradeModel;
   import modules.sword.model.SwordModelManager;
   import modules.utils.Unify;
   import viewers.component.EquipEffect;
   import viewers.entitys.Entity;
   import viewers.entitys.man.PlayerEntity;
   import viewers.entitys.man.RoleEntity;
   import viewers.entitys.weapons.MagicWeaponEntity;
   
   public class UserVO extends VoBasic
   {
      
      private static var _EID:int = 0;
      
      public var player_ID:Number;
      
      public var player_ID2:Number;
      
      public var userId:Number;
      
      public var entitieId:Number;
      
      public var name:String = "无名";
      
      public var x:Number;
      
      public var y:Number;
      
      public var z:Number;
      
      public var startPos:Vector2D;
      
      public var charID:Number;
      
      public var action:uint;
      
      public var namelenth:int;
      
      public var proType:int;
      
      public var level:int;
      
      public var experience:Number;
      
      public var money:Number;
      
      public var dynamic:int;
      
      public var strength:int;
      
      public var intelligence:int;
      
      public var constitution:int;
      
      public var hpMax:Number;
      
      public var hpMax2:Number;
      
      public var hp:Number;
      
      public var mpMax:int;
      
      public var mp:int;
      
      public var atk:Number;
      
      public var oldAtk:Number;
      
      public var phyDef:Number;
      
      public var magRes:Number = 0;
      
      public var reduceMagDef:Number = 0;
      
      public var hit:Number = 0;
      
      public var dodge:Number = 0;
      
      public var critical:Number = 0;
      
      public var toughness:Number = 0;
      
      public var lucky:Number = 0;
      
      public var guardian:Number = 0;
      
      public var reHP:Number;
      
      public var reMP:Number;
      
      public var suckBlood:Number = 0;
      
      public var backLash:Number = 0;
      
      public var countXP:int;
      
      public var reXP:int;
      
      public var addDamage:int;
      
      public var subDamage:int;
      
      public var fightPowers:int;
      
      public var soulCritical:Number = 0;
      
      public var soulToughness:Number = 0;
      
      public var soulAtk:Number = 0;
      
      public var soulPhydef:Number = 0;
      
      public var type:String;
      
      public var criticalGrowUp:int;
      
      public var proScore:int;
      
      public var todayTime:int;
      
      public var boss:int;
      
      public var isPKBoss:Boolean;
      
      public var dodgeNum:int;
      
      public var hurtNum:int;
      
      public var hitNum:int;
      
      public var nowSkillHit:int = 0;
      
      public var loseHP:int;
      
      public var remainHp:int;
      
      public var baoJiNum:int;
      
      public var hurtSkills:Dictionary;
      
      public var AttackSpeed:int;
      
      public var walkSpeed:Number;
      
      public var ResourcesId:int;
      
      public var Attack0:int;
      
      public var Attack1:int;
      
      public var Attack2:int;
      
      public var Attack3:int;
      
      public var RunAttack:int;
      
      public var JumpAttack:int;
      
      public var Effect0:int;
      
      public var Effect1:int;
      
      public var Effect2:int;
      
      public var Effect3:int;
      
      public var Effect4:int;
      
      private var _shortName:String = "";
      
      private var _preName:String = "";
      
      public var isTeam:Boolean;
      
      public var isFriend:Boolean;
      
      public var isPk:Boolean;
      
      public var isFixed:Boolean = false;
      
      public var speedR:Number = 1;
      
      public var speedS:Number = 30;
      
      public var equip:*;
      
      public var campId:int;
      
      public var reduceDMG:Number = 0;
      
      public var petSprit:int;
      
      public var loginTime:int;
      
      public var petID:int;
      
      public var followTargetId:Number;
      
      public var parEntityId:int;
      
      public var buyReviveTimes:int;
      
      public var buyMarsBlessingTimes:int;
      
      public var dieHasTime:int;
      
      public var fight_powers:int;
      
      public var copyHpDamage:Number;
      
      public var fashions:Array;
      
      public var ps:int;
      
      public var vip:int;
      
      public var vipLevel:int;
      
      public var xiuWei:int;
      
      public var xiuXing:String;
      
      public var lilLianId:Array;
      
      public var LuckyDrawTime:Array;
      
      public var pearlMoney:int;
      
      public var luckyDrawNum:Array;
      
      public var totemNumber:int;
      
      public var totemLevel:int;
      
      public var totemCD:uint;
      
      public var luckyDrawYBNum:Array;
      
      public var battleWatcher:Boolean;
      
      public var XiuXingType:int;
      
      public var isMePk:Boolean;
      
      public var pet:*;
      
      public var captain:Boolean;
      
      public var pkOther:Boolean;
      
      public var quit:Boolean;
      
      public var totalDamage:int = 0;
      
      public var inCampIndex:int;
      
      public var inStage:Boolean;
      
      public var jy:Boolean;
      
      private var _isDie:Boolean;
      
      public var lastHurtedTime:int;
      
      public var devStrengthMax:int;
      
      public var devIntelligenceMax:int;
      
      public var devConstitutionMax:int;
      
      public var magicWeapon:MagicWeaponEntity;
      
      public var magicWeapon2:MagicWeaponEntity;
      
      public var xp:int;
      
      public var trumpId:int;
      
      public var avoidInjury:Number;
      
      public var hatred:Dictionary;
      
      public var hpLoseDict:Dictionary;
      
      public var trumpSpirit:int;
      
      public var getMonthNum:int;
      
      public var getMonthSte:int;
      
      public var carrys:Array;
      
      public var totalPowers:int;
      
      public var configVo:RoleConfigVO;
      
      public var keyBoard:KeySetVO = new KeySetVO();
      
      public var keyBoard2:KeySetVO;
      
      public var currentHorser:HorseVO;
      
      public var equipments:Equipment;
      
      public var fightSkills:Vector.<FightSkillVo>;
      
      public var awakenPoint1:int;
      
      public var awakenPoint2:int;
      
      public var roleName:String;
      
      public var kindName:String;
      
      public var buff_gaiLiArr:Vector.<BuffVO>;
      
      public var buff_gaiLiHurtArr:Vector.<BuffVO>;
      
      public var buff_dmg_rate_on_hurtMan:Vector.<BuffVO> = new Vector.<BuffVO>();
      
      public var buff_sleep_on_hurtMan:BuffVO;
      
      public var buff_dmg_rate_on_attMan:BuffVO;
      
      public var buff_dmg_rate_on_attMan2:Vector.<BuffVO> = new Vector.<BuffVO>();
      
      public var buff_dmg_rate_on_attMan3:Vector.<BuffVO> = new Vector.<BuffVO>();
      
      public var buff60s:Vector.<BuffVO> = new Vector.<BuffVO>();
      
      public var buffs:Vector.<BuffVO> = new Vector.<BuffVO>();
      
      public var buff_cannot_equip:BuffVO;
      
      private var _totalTime:Number;
      
      public var isWuShuan:Boolean;
      
      public var isRun:Boolean;
      
      public var isMagic:Boolean;
      
      public var isMagicJianYi:Boolean;
      
      public var parent:UserVO;
      
      public var protectedData:ProtectedData = new ProtectedData();
      
      public var isNewPlayer:Boolean;
      
      private var _showFashion:int = 2;
      
      private var _showMoEquip:int = 1;
      
      public var canAddHp:Boolean = true;
      
      public var canAddMp:Boolean = true;
      
      public var mode:int;
      
      public var isCatchingPet:Boolean;
      
      public var currentPet:UserVO;
      
      public var buff_mian_yi:Boolean;
      
      public var buff_mian_yi1s:Array = [];
      
      public var buff_mian_yitypes:Array = [];
      
      public var isSecondPassword:Boolean = false;
      
      public var soar:Number = 0;
      
      public var sprint:Number = 0;
      
      public var flagDead:Boolean = false;
      
      public var deadNum:int = 0;
      
      public var children:UserVO;
      
      public var currentChildern:UserVO;
      
      public var professionType:int = 1;
      
      public var sameMapRelation:SameMapRelationVo;
      
      public var currEquipBuffs:Array = [];
      
      public var currFashions:Array = [];
      
      public var record_dmages:Array = [0,0,0];
      
      public var propertyVo:UserPropertyVo;
      
      public var atkpointIndex:int = 0;
      
      public var skillAmulet:Object;
      
      public var minSpeed:int;
      
      public var isNotJoinBattle:Boolean;
      
      public var forceJoinBattle:Boolean;
      
      public var keepPercentHp:Number;
      
      public var lockHP:Boolean;
      
      public var takePetRougeLike:Object;
      
      private var _colsedSkill:Array;
      
      public var playerIndex:int;
      
      public var isQc:Boolean;
      
      public var recordId:String;
      
      public var isRole:Boolean;
      
      public var changeCD:int = 0;
      
      public var skillCD:Object;
      
      public var scaleX:int = 1;
      
      public var canNotAddBuff:Boolean;
      
      public var iszhaohuan:Boolean;
      
      public var isWuDi:Boolean;
      
      public var isXuWu:Boolean;
      
      public var isCanNotSubtractHp:Boolean;
      
      public var InCanNotSubtractHp:int = 0;
      
      public var buff_add_skill_level:int = 0;
      
      private var _buff_hurt_add_hp_per:Number = 0;
      
      private var _buff_useSkill_add_mp_per:Number = 0;
      
      private var _buff_useSkill_add_mp_target:Array = [];
      
      private var _buff_hurt_add_hp_target:Array = [];
      
      public var isTeamMe:Boolean;
      
      public var isCaptain:Boolean;
      
      public var reduceChiXiShangHaiBuff:BuffVO;
      
      public var reduceHPBuff:BuffVO;
      
      public var reduceHPBuff2:Vector.<BuffVO>;
      
      public var path:int;
      
      public var isTown:Boolean;
      
      public var children2:UserVO;
      
      public var leagueId:String;
      
      public var rid:String;
      
      public var buff_protected:BuffVO = null;
      
      public var buff411_protected:Array = [];
      
      public var buff_protected_hasDamage:BuffVO = null;
      
      public var buff_create_hurt:BuffVO = null;
      
      public var buff_create_hurt_hasDamage:BuffVO = null;
      
      public var enabled:Boolean = true;
      
      public var tempChangeProfession:Boolean;
      
      public var buff_hides:Array = [];
      
      public var iszhaohuanByZhuoQu:Boolean;
      
      public var zhuoQuSummonSurvivalTime:Number;
      
      private var _buffProperty:Object = {};
      
      private var _battleProperty:Object = {};
      
      private var _soulProperty:Object = {};
      
      public var isLuoHan_ChenShi:Boolean;
      
      public var atk0:Number;
      
      private var _prev_isLuoHan_ChenShi:Boolean;
      
      public var father:UserVO;
      
      public var luoHan:Array;
      
      public var reHpMx:int = -1;
      
      public var xingMoRatio:Number = 1;
      
      public var canNotEnterHore:Boolean;
      
      public var buff_reduce_hpPer:Number;
      
      public var buff_reduce_hpTotal:Number;
      
      public var isTeamBoss:Boolean;
      
      public var isTeamHorseMonster:Boolean;
      
      public var isTeamHorse:Boolean;
      
      public var sword:Object;
      
      public var otherData:Object;
      
      public var equipSkillCdObj:Object = {};
      
      public var noAddBuff:Boolean;
      
      private var _notAddBuffs:Array = [];
      
      private var _luoBoValue:Number = 0;
      
      private var _checkDeadParam:Object;
      
      public var lockHp1:Boolean;
      
      public var isUseChildren3:Boolean;
      
      public var isLastChildren2:Boolean;
      
      public var weaponEffect:EquipEffect;
      
      public var currEqiups:Array;
      
      public var entityId:String;
      
      public var petPk_suckBlood_backLash_damageRatio:Number;
      
      public var isNoTrue1:Boolean;
      
      public var wuShuanTime:int;
      
      public var shareUvo:UserVO;
      
      public var isBLYing:Boolean;
      
      private var _power:Number = 0;
      
      public var shareBuffHpPer:Number;
      
      public var canNotAddXp:Boolean;
      
      public var shareUpdateHpPer:Number;
      
      public var shareUpdateHpMax:Number;
      
      public var entityMan:Entity;
      
      public var isNotModityAtkHpAtBirth:Boolean;
      
      public var isFs:Boolean;
      
      public var takeCryStals:Array;
      
      private var _zufuHitV1:Array = [];
      
      public var zhouYinCd:Number;
      
      public var swordShi:int;
      
      public var swordShiLevel:int;
      
      public var isMe:Boolean;
      
      public var teamPs:int;
      
      public var pingTime:Number;
      
      public var takeHorser:HorseVO;
      
      public var isMeBattle:Boolean;
      
      public var layerIndex:int;
      
      public var doubleProtectPoint:Number;
      
      public var isPet:Boolean;
      
      protected var _fixedProperty:Object = {};
      
      public var life:int;
      
      public var keyBoardMagic:Array;
      
      public function UserVO()
      {
         super();
      }
      
      public static function get EID() : int
      {
         _EID = _EID + 1;
         return _EID;
      }
      
      public static function getTest() : UserVO
      {
         var _loc2_:UserVO = new UserVO();
         _loc2_.charID = 2015;
         _loc2_.userId = _loc2_.charID;
         _loc2_.entitieId = ++_EID;
         _loc2_.player_ID = 99181269;
         _loc2_.hurtSkills = new Dictionary();
         _loc2_.hpLoseDict = new Dictionary();
         _loc2_.hatred = new Dictionary();
         _loc2_.atk = 522.8;
         _loc2_.hp = 250000;
         _loc2_.hpMax = _loc2_.hp;
         _loc2_.phyDef = 20.4;
         _loc2_.reMP = 1000;
         _loc2_.magRes = 20.4;
         _loc2_.campId = 1;
         _loc2_.ps = 1;
         _loc2_.mode = 1;
         _loc2_.proScore = -1;
         _loc2_.mp = 1000;
         _loc2_.mpMax = _loc2_.mp;
         _loc2_.name = "测试人";
         _loc2_.keyBoard.setKey(87,22);
         _loc2_.keyBoard.setKey(65,23);
         _loc2_.keyBoard.setKey(83,21);
         _loc2_.keyBoard.setKey(68,24);
         _loc2_.keyBoard.setKey(74,41);
         _loc2_.keyBoard.setKey(75,6);
         _loc2_.keyBoard.setKey(32,ActionState.WU_SHUAN);
         _loc2_.keyBoard.setKey(89,71);
         _loc2_.keyBoard.setKey(85,72);
         _loc2_.keyBoard.setKey(73,73);
         _loc2_.keyBoard.setKey(79,74);
         _loc2_.keyBoard.setKey(76,75);
         var _loc1_:RoleConfigVO = ManModelManager.getIns().getManById(_loc2_.charID,"role");
         if(_loc1_)
         {
            _loc1_ = _loc1_.clone();
         }
         else
         {
            _loc1_ = new RoleConfigVO();
         }
         _loc2_.configVo = _loc1_;
         return _loc2_;
      }
      
      public static function buildFrom(param1:RoleConfigVO) : UserVO
      {
         var _loc2_:UserVO = new UserVO();
         _loc2_.mode = 1;
         _loc2_.buildFromObject(param1.cloneToObject());
         _loc2_.entitieId = ++_EID;
         _loc2_.hurtSkills = new Dictionary();
         _loc2_.hpLoseDict = new Dictionary();
         _loc2_.hatred = new Dictionary();
         _loc2_.hp = _loc2_.hpMax;
         _loc2_.protectedData.build(_loc2_.cloneToObject());
         _loc2_.enabled = true;
         return _loc2_;
      }
      
      public static function buildFromPinfo(param1:Object, param2:Number, param3:String) : UserVO
      {
         var _loc7_:UserVO = null;
         var _loc5_:String = null;
         var _loc8_:SkillConfigVO = null;
         _loc7_ = new UserVO();
         _loc7_.children = new UserVO();
         _loc7_.buildFromObject(param1);
         _loc7_.enabled = true;
         _loc7_.campId = 1;
         _loc7_.userId = param2;
         _loc7_.name = param3;
         _loc7_.type = "role";
         _loc7_.mode = 1;
         var _loc6_:RoleConfigVO = ManModelManager.getIns().getManById(_loc7_.charID,"role");
         _loc6_ = _loc6_.clone();
         _loc6_.fightConfig = _loc6_.fightConfig.clone();
         _loc7_.configVo = _loc6_;
         for(_loc5_ in _loc7_.configVo.skills)
         {
            _loc8_ = _loc7_.configVo.skills[_loc5_];
            _loc8_.level = 0;
            _loc8_.level2 = 10;
            if(_loc5_.indexOf("ttack") > -1)
            {
               _loc8_.level = 1;
               _loc8_.level2 = 11;
            }
         }
         loop1:
         for each(var _loc4_:FightSkillVo in _loc7_.fightSkills)
         {
            var _loc12_:int = 0;
            var _loc11_:Dictionary = _loc7_.configVo.skills;
            do
            {
               for each(_loc8_ in _loc11_)
               {
               }
               continue loop1;
            }
            while(_loc8_.id != _loc4_.skillId);
            _loc8_.level = _loc4_.level;
            _loc8_.level2 = _loc4_.level + 10;
            _loc8_.updateBuff();
         }
         return _loc7_;
      }
      
      public static function buildFromPetInfoVo(param1:PetInfoVo, param2:int = -1) : UserVO
      {
         var _loc5_:* = null;
         var _loc3_:Array = null;
         var _loc4_:Array = null;
         var _loc8_:Object = null;
         var _loc10_:int = 0;
         var _loc6_:PetUserVO = new PetUserVO();
         _loc6_.mode = 1;
         var _loc7_:PetConfigVO = param1.petConfigVo;
         _loc6_.buildFromObject(_loc7_.cloneToObject());
         _loc6_.experience = param1.petItemVo.exp;
         _loc6_.entitieId = UserVO.EID;
         _loc6_.entityId = param1.petItemVo.entityId;
         _loc6_.type = "pet";
         _loc6_.hp = param1.hp;
         _loc7_ = ManModelManager.getIns().getPetConfigById(param1.petConfigVo.id);
         _loc7_ = _loc7_.clone() as PetConfigVO;
         _loc6_.configVo = _loc7_;
         _loc6_.charID = _loc7_.id;
         _loc6_.updateSkill(param1);
         _loc6_.refreshPet();
         if(!BattleModelManager.getIns().levelInfo.isPetPk())
         {
            if(_loc6_.hp != _loc6_.hpMax)
            {
               _loc6_.updatehpLost(_loc6_.hp - _loc6_.hpMax);
            }
         }
         if(_loc7_.param)
         {
            if(!_loc7_.param2)
            {
               _loc7_.param2 = JSON.parse(_loc7_.param);
            }
         }
         if(_loc7_.param2 && _loc7_.param2.switchLand)
         {
            _loc3_ = _loc7_.param2.switchLand.stageId || [];
            if(_loc3_.indexOf(param2) > -1)
            {
               _loc7_.fly = 1;
            }
         }
         if(param1.petItemVo.petCrystal)
         {
            _loc4_ = [];
            for(var _loc9_:String in param1.petItemVo.petCrystal)
            {
               _loc8_ = param1.petItemVo.petCrystal[_loc9_];
               _loc4_[int(_loc9_)] = _loc8_;
               _loc8_.currCd;
            }
            _loc6_.takeCryStals = [];
            _loc10_ = 0;
            while(_loc10_ < _loc4_.length)
            {
               if(_loc4_[_loc10_])
               {
                  _loc6_.takeCryStals.push(new TakeCrystal(_loc6_,_loc4_[_loc10_]));
               }
               _loc10_++;
            }
         }
         return _loc6_;
      }
      
      public function get realMp() : int
      {
         return mp + otherMp;
      }
      
      public function get otherMp() : int
      {
         var _loc3_:int = 0;
         var _loc2_:BuffVO = null;
         var _loc1_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < buffs.length)
         {
            _loc2_ = buffs[_loc3_];
            if(_loc2_ && _loc2_.config.type == 116 && _loc2_.config.attributeT == "mp")
            {
               _loc1_ += _loc2_.value;
            }
            _loc3_++;
         }
         return _loc1_;
      }
      
      public function get buff_hurt_add_hp_target() : Array
      {
         return _buff_hurt_add_hp_target;
      }
      
      public function addbuff_hurt_add_hp_target(param1:Object, param2:Boolean = false) : void
      {
         _buff_hurt_add_hp_target.push(param1);
         if(children)
         {
            children.addbuff_hurt_add_hp_target(param1,param2);
         }
         if(param2)
         {
            _buff_useSkill_add_mp_target.length = 0;
         }
      }
      
      public function get buff_useSkill_add_mp_target() : Array
      {
         return _buff_useSkill_add_mp_target;
      }
      
      public function addbuff_useSkill_add_mp_target(param1:Object, param2:Boolean = false) : void
      {
         _buff_useSkill_add_mp_target.push(param1);
         if(children)
         {
            children.addbuff_useSkill_add_mp_target(param1,param2);
         }
         if(param2)
         {
            _buff_useSkill_add_mp_target.length = 0;
         }
      }
      
      public function get buff_useSkill_add_mp_per() : Number
      {
         return _buff_useSkill_add_mp_per;
      }
      
      public function set buff_useSkill_add_mp_per(param1:Number) : void
      {
         _buff_useSkill_add_mp_per = param1;
         if(children)
         {
            children.buff_useSkill_add_mp_per = param1;
         }
      }
      
      public function get buff_hurt_add_hp_per() : Number
      {
         return _buff_hurt_add_hp_per;
      }
      
      public function set buff_hurt_add_hp_per(param1:Number) : void
      {
         _buff_hurt_add_hp_per = param1;
         if(children)
         {
            children.buff_hurt_add_hp_per = param1;
         }
      }
      
      public function get isDie() : Boolean
      {
         return getCurrentUVO().getIsDie();
      }
      
      public function get currentUserVo() : UserVO
      {
         if(currentChildern != null)
         {
            return currentChildern;
         }
         return this;
      }
      
      public function set isDie(param1:Boolean) : void
      {
         _isDie = param1;
      }
      
      public function getShowFashioin() : Boolean
      {
         return showFashion == 2;
      }
      
      public function getShowMoEquip() : Boolean
      {
         return showMoEquip == 2;
      }
      
      public function get shortName() : String
      {
         if(!_shortName)
         {
            if(this.name)
            {
               if(this.name.indexOf(".") != -1)
               {
                  _shortName = this.name.split(".")[1];
               }
            }
         }
         if(!_shortName)
         {
            _shortName = "";
         }
         return _shortName;
      }
      
      public function set shortName(param1:String) : void
      {
         _shortName = param1;
      }
      
      public function get preName() : String
      {
         if(_preName == "")
         {
            if(this.name.indexOf(".") != -1)
            {
               _preName = this.name.split(".")[0];
            }
         }
         return _preName;
      }
      
      public function set preName(param1:String) : void
      {
         _preName = param1;
      }
      
      override public function buildFromObject(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc3_:FightSkillVo = null;
         var _loc6_:Number = getTimer();
         super.buildFromObject(param1);
         this.enabled = true;
         this.mode = 1;
         this.fightSkills = new Vector.<FightSkillVo>();
         var _loc5_:int = 1;
         if(param1.hasOwnProperty("showFashion"))
         {
            showFashion = param1.showFashion;
         }
         if(param1.hasOwnProperty("showMoEquip"))
         {
            showMoEquip = param1.showMoEquip;
         }
         if(param1.hasOwnProperty("equipments"))
         {
            this.equipments = new Equipment();
            this.equipments.setUserVo(this);
            this.equipments.buildFromObject(param1.equipments);
            this.equipments.yfFrame = -100;
            this.equipments.wqFrame = -100;
         }
         if(param1.hasOwnProperty("fightSkills"))
         {
            _loc2_ = param1["fightSkills"] as Object;
            for(var _loc4_:String in _loc2_)
            {
               _loc3_ = new FightSkillVo();
               _loc3_.buildFromObject(_loc2_[_loc4_]);
               this.fightSkills.push(_loc3_);
            }
         }
         this.hurtSkills = new Dictionary();
         this.hpLoseDict = new Dictionary();
         this.hatred = new Dictionary();
         if(this.mpMax < 0)
         {
            this.mpMax = 0;
         }
         this.hp = this.hpMax;
         this.mp = this.mpMax;
         this.protectedData = new ProtectedData();
         this.protectedData.build(this.cloneToObject());
         this.buff_reduce_hpTotal = 0;
         this.buff_reduce_hpPer = 1;
         if(param1.hasOwnProperty("keyBoard") && param1.keyBoard is KeySetVO)
         {
            this.keyBoard = param1.keyBoard.clone();
         }
         if(param1.hasOwnProperty("keyBoard2") && param1.keyBoard2 is KeySetVO)
         {
            this.keyBoard2 = param1.keyBoard2.clone();
         }
         if(!this.buff_gaiLiArr)
         {
            this.buff_gaiLiArr = new Vector.<BuffVO>();
         }
      }
      
      public function updatePassiveSkill(param1:int, param2:int, param3:Boolean = false) : void
      {
         var _loc7_:Number = NaN;
         var _loc5_:SkillPassiveVo = SkillUpgradeModel.getIns().getSkillPassive(param1);
         var _loc4_:SkillLevVo = SkillUpgradeModel.getIns().getSkillLev(param1);
         var _loc6_:Array = _loc4_.attributeV.split(";");
         if(_loc5_ == null)
         {
            return;
         }
         if(param2 == 1)
         {
            _loc7_ = Number(_loc6_[0]);
         }
         else
         {
            _loc7_ = _loc6_[param2 - 1] - _loc6_[param2 - 2];
         }
         if(param3)
         {
            _loc7_ = Number(_loc6_[param2 - 1]);
         }
         if(_loc5_.attributeType == "reHP")
         {
            this.reHP += _loc7_;
         }
         else if(_loc5_.attributeType == "reMP")
         {
            this.reMP += _loc7_;
         }
         else if(_loc5_.attributeType == "hpMax")
         {
            this.hpMax += _loc7_;
         }
         else if(_loc5_.attributeType == "mpMax")
         {
            this.mpMax += _loc7_;
         }
         else if(_loc5_.attributeType == "critical")
         {
            this.critical += _loc7_;
         }
         if(this.mpMax < 0)
         {
            this.mpMax = 0;
         }
         protectedData.build(this.cloneToObject());
      }
      
      public function updateBodyStrong(param1:int, param2:int) : void
      {
         var _loc3_:BodyLevVo = ItemVoManager.getIns().getBodyLevId(param1);
         var _loc4_:Array = _loc3_.attributV.split(";");
         if(_loc3_ == null)
         {
            return;
         }
         var _loc5_:Number = Number(_loc4_[param2 - 1]);
         if(_loc3_.attributeT == "atk")
         {
            this.atk += _loc5_;
         }
         else if(_loc3_.attributeT == "phyDef")
         {
            this.phyDef += _loc5_;
         }
         else if(_loc3_.attributeT == "hpMax")
         {
            this.hpMax += _loc5_;
         }
         else if(_loc3_.attributeT == "mpMax")
         {
            this.mpMax += _loc5_;
         }
         protectedData.build(this.cloneToObject());
      }
      
      public function updateSword(param1:int, param2:int) : void
      {
         var _loc8_:String = null;
         var _loc9_:Array = null;
         var _loc10_:Array = null;
         var _loc11_:int = 0;
         var _loc4_:SwordLevVo = ItemVoManager.getIns().getSwordLevVoById(param1);
         var _loc6_:Array = Unify.getItemIdByString(_loc4_.attributV);
         if(_loc4_ == null)
         {
            return;
         }
         var _loc3_:int = param2 - 1;
         var _loc7_:Number = Number(_loc6_[_loc3_]);
         var _loc5_:Array = Unify.getItemIdByString(_loc4_.attributeT);
         if(_loc5_.length == 1)
         {
            var _loc12_:String = _loc8_ = _loc4_.attributeT;
            var _loc13_:Number = this[_loc12_] + _loc7_;
            this[_loc12_] = _loc13_;
         }
         else
         {
            _loc9_ = _loc4_.attributV.split(";");
            _loc11_ = 0;
            while(_loc11_ < _loc5_.length)
            {
               _loc10_ = String(_loc9_[_loc11_]).split(",");
               _loc8_ = _loc5_[_loc11_];
               _loc7_ = Number(_loc10_[_loc3_]);
               this[_loc8_] += _loc7_;
               _loc11_++;
            }
         }
         protectedData.build(this.cloneToObject());
      }
      
      public function updatePetPassiveSkill(param1:PetSkillVo) : void
      {
         if(this.hasOwnProperty(param1.commonAttribute) && this[param1.commonAttribute] >= 0)
         {
            var _loc2_:String = param1.commonAttribute;
            var _loc3_:Number = this[_loc2_] + param1.commonValue;
            this[_loc2_] = _loc3_;
            protectedData.build(this.cloneToObject());
         }
      }
      
      public function getHatredEntity() : PlayerEntity
      {
         var targetEntity:PlayerEntity;
         var a1:String;
         var i:int;
         var a:Number;
         var n:Number;
         var targetEntity1:PlayerEntity;
         var eid:Number = -1;
         var h:Number = -1;
         var ar:Array = [];
         var keys:Array = [];
         for(a1 in this.hatred)
         {
            keys.push(Number(a1));
         }
         keys.sort(16);
         i = 0;
         while(i < keys.length)
         {
            a = Number(keys[i]);
            n = Number(this.hatred[a]);
            targetEntity1 = BattleModelManager.getIns().getPlayerByEntityId(a) as PlayerEntity;
            if(n > h && targetEntity1)
            {
               eid = a;
               targetEntity = targetEntity1;
               h = n;
            }
            if(targetEntity1 && targetEntity1.Enabled)
            {
               ar.push(targetEntity1);
            }
            i = i + 1;
         }
         if(GlobalData.getTestPetPk())
         {
         }
         if(h == 0)
         {
            ar.sort((function():*
            {
               var cccc:Function;
               return cccc = function(param1:Entity, param2:Entity):*
               {
                  if(param1 && param1.userVo && param1.userVo.isRole)
                  {
                     return -1;
                  }
                  if(param1.position.x < param2.position.x)
                  {
                     return -1;
                  }
                  if(param1.position.x > param2.position.x)
                  {
                     return 1;
                  }
                  return 0;
               };
            })());
            targetEntity = ar[0];
         }
         return targetEntity;
      }
      
      public function getHatredMansEid() : Array
      {
         var _loc3_:Number = -1;
         var _loc4_:Number = -1;
         var _loc2_:Array = [];
         for(var _loc1_:String in this.hatred)
         {
            _loc3_ = Number(_loc1_);
            _loc2_.push(_loc3_);
         }
         return _loc2_;
      }
      
      public function removeHatredByEid(param1:int) : void
      {
         var _loc3_:Number = -1;
         for(var _loc2_:String in this.hatred)
         {
            _loc3_ = Number(_loc2_);
            if(_loc3_ == param1)
            {
               delete this.hatred[_loc2_];
               break;
            }
         }
      }
      
      public function updateExp() : void
      {
         var _loc2_:int = 0;
         var _loc1_:EXPVo = ItemVoManager.getIns().getExpVoByLevel(this.level);
         _loc2_ = this.level;
         while(this.experience >= _loc1_.upgradeEXP)
         {
            if(++_loc2_ > CommonConfig.levelMax)
            {
               _loc2_ = CommonConfig.levelMax;
            }
            this.experience -= _loc1_.upgradeEXP;
            _loc1_ = ItemVoManager.getIns().getExpVoByLevel(_loc2_);
         }
         if(this.level != _loc2_)
         {
            BuffModelManager.getIns().removeEntityBuffs(this.entitieId);
            this.level = _loc2_;
            if(type == "role")
            {
               BuffSceneManager.getIns().clear();
               BuffSceneManager.getIns().clearSuit();
               refreshRole();
               ApplicationFacade.getInstance().sendNotification("NF_ROLE_LEVEL_UPDATE");
            }
            else if(type == ManType.HORSE)
            {
               refreshHorse();
            }
            else if(type == "pet")
            {
               refreshPet();
               this.hp = this.hpMax;
            }
            if(this.mpMax < 0)
            {
               this.mpMax = 0;
            }
            protectedData.build(this.cloneToObject());
            updateHP(this.hpMax,false);
            updateMp(this.mpMax,false);
            if(isDie)
            {
               updateHP(-this.hpMax,false);
            }
            if(this.type == "role")
            {
               BuffSceneManager.getIns().StartByUpLevel(0);
               ApplicationFacade.getInstance().sendNotification("NF_UPDATE_BUFF_SCENE");
            }
         }
      }
      
      public function get suitSkillId() : int
      {
         if(!equipments)
         {
            return -1;
         }
         return equipments.suitSkillId;
      }
      
      public function get suitAttribute() : Object
      {
         return equipments.dungeonAttribute;
      }
      
      private function setZero() : void
      {
         this.hpMax = 0;
         this.mpMax = 0;
         this.atk = 0;
         this.phyDef = 0;
         this.magRes = 0;
         this.reduceMagDef = 0;
         this.hit = 0;
         this.dodge = 0;
         this.critical = 0;
         this.toughness = 0;
         this.lucky = 0;
         this.guardian = 0;
         this.reHP = 0;
         this.reMP = 0;
         this.soar = 0;
         this.sprint = 0;
         this.suckBlood = 0;
         this.backLash = 0;
         this.soulAtk = 0;
         this.soulCritical = 0;
         this.soulPhydef = 0;
         this.soulToughness = 0;
      }
      
      public function refreshRole() : void
      {
         var _loc5_:int = 0;
         var _loc4_:String = null;
         var _loc2_:String = null;
         var _loc3_:int = 0;
         this.setZero();
         var _loc1_:Array = new Array("hpMaxAdd","mpMaxAdd","atkAdd","phyDefAdd");
         _loc5_ = 0;
         while(_loc5_ < _loc1_.length)
         {
            _loc4_ = _loc1_[_loc5_];
            _loc2_ = _loc4_.split("Add")[0];
            _loc3_ = Math.round(configVo[_loc2_] + configVo[_loc4_] * (this.level - 1));
            this[_loc2_] = _loc3_;
            _loc5_++;
         }
         SimpleTextLog.getIns().log("hpMax1=" + hpMax);
         this.reHP = configVo["reHP"];
         this.reMP = configVo["reMP"];
         this.critical = configVo["critical"];
         _loc5_ = 0;
         while(_loc5_ < fightSkills.length)
         {
            updatePassiveSkill(fightSkills[_loc5_].skillId,fightSkills[_loc5_].level,true);
            _loc5_++;
         }
         SimpleTextLog.getIns().log("hpMax2=" + hpMax);
         this.equipments.fullFashion = null;
         if(this.equipments && buff_cannot_equip == null)
         {
            this.equipments.reUpdateRoleProperty();
         }
         if(this.mpMax < 0)
         {
            this.mpMax = 0;
         }
         this.addBodyStrong();
         this.addSword();
      }
      
      private function addBodyStrong() : void
      {
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         BodyStrongModelManager.getIns().setP1P2(UserModelManager.getIns().getCurretPlayerInfo().pNum);
         var _loc2_:Object = BodyStrongModelManager.getIns().curr;
         if(_loc2_)
         {
            for(var _loc1_:String in _loc2_)
            {
               _loc3_ = _loc2_[_loc1_];
               _loc4_ = 0;
               while(_loc4_ < _loc3_.level)
               {
                  updateBodyStrong(int(_loc1_),_loc4_ + 1);
                  _loc4_++;
               }
            }
         }
      }
      
      private function addSword() : void
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         SwordModelManager.getIns().setP1P2(UserModelManager.getIns().getCurretPlayerInfo().pNum);
         var _loc4_:Object = SwordModelManager.getIns().curr;
         if(_loc4_)
         {
            for(var _loc1_:String in _loc4_)
            {
               _loc2_ = _loc4_[_loc1_];
               _loc3_ = 0;
               while(_loc3_ < _loc2_.level)
               {
                  updateSword(int(_loc1_),_loc3_ + 1);
                  _loc3_++;
               }
            }
         }
      }
      
      public function onCanNotEquipBuffRefreshRole() : void
      {
         var _loc5_:int = 0;
         var _loc4_:String = null;
         var _loc2_:String = null;
         var _loc3_:int = 0;
         this.setZero();
         var _loc1_:Array = new Array("hpMaxAdd","mpMaxAdd","atkAdd","phyDefAdd");
         _loc5_ = 0;
         while(_loc5_ < _loc1_.length)
         {
            _loc4_ = _loc1_[_loc5_];
            _loc2_ = _loc4_.split("Add")[0];
            _loc3_ = Math.round(configVo[_loc2_] + configVo[_loc4_] * (this.level - 1));
            this[_loc2_] = _loc3_;
            _loc5_++;
         }
         SimpleTextLog.getIns().log("hpMax1=" + hpMax);
         this.reHP = configVo["reHP"];
         this.reMP = configVo["reMP"];
         this.critical = configVo["critical"];
         _loc5_ = 0;
         while(_loc5_ < fightSkills.length)
         {
            updatePassiveSkill(fightSkills[_loc5_].skillId,fightSkills[_loc5_].level,true);
            _loc5_++;
         }
         SimpleTextLog.getIns().log("hpMax2=" + hpMax);
         if(this.equipments)
         {
            this.equipments.reUpdateRoleProperty();
         }
         if(this.mpMax < 0)
         {
            this.mpMax = 0;
         }
         SimpleTextLog.getIns().log("hpMax3=" + hpMax);
      }
      
      public function refreshHorse() : void
      {
         this.hpMax = configVo["hpMax"];
         this.atk = configVo["atk"];
         this.phyDef = configVo["phyDef"];
         var _loc5_:HorseInfoVo = HorseVO(this).hosrseInfo;
         var _loc2_:Number = hpMax * _loc5_.horseItemVo.hpQualification / _loc5_.horseConfigVo.hpQuaMax;
         var _loc3_:Number = atk * _loc5_.horseItemVo.atkQualification / _loc5_.horseConfigVo.atkQuaMax;
         var _loc7_:Number = phyDef * _loc5_.horseItemVo.defQualification / _loc5_.horseConfigVo.defQuaMax;
         var _loc6_:Number = _loc5_.horseItemVo.hpQualification * CommonConfig.hpQualificationIndex * (this.level - 1);
         var _loc1_:Number = _loc5_.horseItemVo.atkQualification * CommonConfig.atkQualificationIndex * (this.level - 1);
         var _loc4_:Number = _loc5_.horseItemVo.defQualification * CommonConfig.defQualificationIndex * (this.level - 1);
         this.hpMax = Math.ceil(_loc2_ + _loc6_);
         this.atk = _loc3_ + _loc1_;
         this.phyDef = _loc7_ + _loc4_;
         if(this.mpMax < 0)
         {
            this.mpMax = 0;
         }
         if(_loc5_.horseEquipVo)
         {
            _loc5_.horseEquipVo.reUpdateRoleProperty(this);
         }
         protectedData.build(this.cloneToObject());
      }
      
      public function refreshPet() : void
      {
         var _loc8_:int = 0;
         var _loc13_:Object = null;
         var _loc10_:String = null;
         var _loc1_:Number = NaN;
         this.setZero();
         this.hpMax = configVo["hpMax"];
         this.atk = configVo["atk"];
         this.phyDef = configVo["phyDef"];
         var _loc7_:PetInfoVo = PetUserVO(this).petInfo;
         var _loc4_:Number = hpMax * _loc7_.petItemVo.hpQualification / _loc7_.petConfigVo.hpQuaMax;
         var _loc12_:Number = atk * _loc7_.petItemVo.atkQualification / _loc7_.petConfigVo.atkQuaMax;
         var _loc16_:Number = phyDef * _loc7_.petItemVo.defQualification / _loc7_.petConfigVo.defQuaMax;
         var _loc15_:Number = _loc7_.petItemVo.hpQualification * CommonConfig.petHpQualificationIndex * (this.level - 1);
         var _loc11_:Number = _loc7_.petItemVo.atkQualification * CommonConfig.petAtkQualificationIndex * (this.level - 1);
         var _loc5_:Number = _loc7_.petItemVo.defQualification * CommonConfig.petDefQualificationIndex * (this.level - 1);
         this.hpMax = _loc4_ + _loc15_;
         this.atk = _loc12_ + _loc11_;
         this.phyDef = _loc16_ + _loc5_;
         this.reHP = configVo["reHP"];
         this.reMP = configVo["reMP"];
         this.critical = configVo["critical"];
         _loc8_ = 0;
         while(_loc8_ < _loc7_.petSkillVos.length)
         {
            updatePetPassiveSkill(_loc7_.petSkillVos[_loc8_]);
            _loc8_++;
         }
         if(_loc7_.petEquipVo)
         {
            _loc7_.petEquipVo.reUpdateRoleProperty(this);
         }
         var _loc14_:Object = {};
         var _loc9_:Object = {};
         if(_loc7_.petItemVo.petCrystal)
         {
            for each(var _loc6_:Object in _loc7_.petItemVo.petCrystal)
            {
               _loc13_ = _loc6_.attrs || {};
               for(var _loc3_:String in _loc13_)
               {
                  _loc10_ = _loc13_[_loc3_];
                  if(_loc10_.indexOf("%") > -1)
                  {
                     _loc14_[_loc3_] = Number(_loc10_.slice(0,_loc10_.length - 1));
                  }
                  else
                  {
                     _loc9_[_loc3_] = Number(_loc10_);
                  }
               }
            }
         }
         if(_loc7_.petItemVo.petBlood)
         {
            this.reUpdatePetProperty(_loc7_.petItemVo.petBlood,_loc14_);
            for(var _loc2_:String in _loc9_)
            {
               _loc1_ = Number(_loc9_[_loc2_]);
               if(!SimpleTextLog.Close)
               {
                  SimpleTextLog.getIns().log2("晶核固定+" + _loc2_ + "= " + _loc1_);
               }
               this.updateByPname(_loc2_,_loc1_);
            }
         }
         if(BattleModelManager.getIns().levelInfo.isPetPk())
         {
            this.hpMax *= CommonConfig.pethpMaxRate;
            if(GlobalData.getTestPetPk())
            {
               this.hpMax *= 10;
            }
         }
         if(this.mpMax < 0)
         {
            this.mpMax = 0;
         }
         protectedData.build(this.cloneToObject());
      }
      
      private function reUpdatePetProperty(param1:Object, param2:Object) : void
      {
         var _loc6_:PetBloodVo = null;
         var _loc5_:Array = null;
         var _loc8_:Array = null;
         var _loc9_:int = 0;
         var _loc7_:String = null;
         var _loc3_:Number = NaN;
         param1 ||= {};
         for(var _loc4_:int in param1)
         {
            _loc6_ = PetModelManager.getPetBloodConfigById(_loc4_);
            if(!(!_loc6_ || param1[_loc4_].level <= 0))
            {
               _loc5_ = (_loc6_.attributeT + "").split(";");
               _loc8_ = _loc6_.attributV.split(";");
               _loc9_ = 0;
               while(_loc9_ < _loc5_.length)
               {
                  _loc7_ = _loc5_[_loc9_];
                  _loc3_ = Number(Number(_loc8_[_loc9_].split(",")[param1[_loc4_].level]) || 0);
                  if(!SimpleTextLog.Close)
                  {
                     SimpleTextLog.getIns().log2("blood+" + _loc7_ + "= " + _loc3_);
                  }
                  if(param2[_loc7_])
                  {
                     _loc3_ += _loc3_ * param2[_loc7_];
                     if(!SimpleTextLog.Close)
                     {
                        SimpleTextLog.getIns().log2("晶核+" + param2[_loc7_] + "% blood+" + _loc7_ + "= " + _loc3_);
                     }
                  }
                  this.updateByPname(_loc7_,_loc3_);
                  _loc9_++;
               }
            }
         }
      }
      
      public function updatehpLost(param1:Number) : void
      {
         if(param1 < 0)
         {
            if(!hpLoseDict)
            {
               return;
            }
            if(this.hpLoseDict[0] == null)
            {
               this.hpLoseDict[0] = 0;
            }
            var _loc2_:int = 0;
            var _loc3_:Number = this.hpLoseDict[_loc2_] - param1;
            this.hpLoseDict[_loc2_] = _loc3_;
         }
      }
      
      public function calRealReducehp(param1:Number, param2:Boolean = false) : Number
      {
         var _loc3_:Entity = null;
         if(this.charID == 4179)
         {
            _loc3_ = BattleModelManager.getIns().getPlayerByEntityId(this.entitieId) as RoleEntity;
            if(_loc3_)
            {
               if(param2 || param1 < 0)
               {
                  param1 = _loc3_.OnUpdateHPBefore(param1);
               }
            }
         }
         return param1;
      }
      
      public function updateHP(param1:Number, param2:Boolean, param3:Boolean = true) : void
      {
         var _loc4_:Number = NaN;
         var _loc6_:int = 0;
         _loc6_ = 0;
         var _loc5_:Entity = null;
         if(this.currentHorser && param1 < 0)
         {
            param1 = 0;
         }
         if(this.entityMan)
         {
            param1 = this.entityMan.updateHP(this,param1);
         }
         if(param1 < 0 && isCanNotSubtractHp == true)
         {
            this.InCanNotSubtractHp += param1;
            return;
         }
         if(this.enabled == false)
         {
            return;
         }
         if(this.type == ManType.SKILL && this.hpLoseDict == null)
         {
            return;
         }
         updatehpLost(param1);
         if(this.children)
         {
            this.children.updatehpLost(param1);
         }
         else if(this.parent)
         {
            this.parent.updatehpLost(param1);
         }
         if(this.isPKBoss && this.boss == 1 && param3 == true)
         {
            return;
         }
         if(this.isTeamBoss && this.boss == 1 && param3 == true)
         {
            return;
         }
         if(this.isPKBoss && this.isFriend)
         {
            return;
         }
         if(this.canAddHp == false && param1 > 0)
         {
            param1 = 0;
         }
         if(takePetRougeLike && param1 > 0)
         {
            _loc4_ = 1;
            _loc6_ = 0;
            while(_loc6_ < takePetRougeLike.length)
            {
               _loc4_ += ITakePetRougeLike(takePetRougeLike[_loc6_]).getReHpRatio();
               _loc6_++;
            }
            param1 *= _loc4_;
            _loc6_ = 0;
            while(_loc6_ < takePetRougeLike.length)
            {
               ITakePetRougeLike(takePetRougeLike[_loc6_]).afterReHp(param1);
               _loc6_++;
            }
         }
         hp += param1;
         if(this.keepPercentHp > 0)
         {
            if(this.hp / this.allhpMax < this.keepPercentHp)
            {
               this.hp = this.allhpMax * this.keepPercentHp;
               param1 = 0;
               this.lockHP = true;
            }
         }
         if(hp >= hpMax2 && hpMax2 > 0)
         {
            hp = hpMax2;
         }
         if(hp >= hpMax)
         {
            if(takePetRougeLike && param1 > 0)
            {
               _loc6_ = 0;
               while(_loc6_ < takePetRougeLike.length)
               {
                  ITakePetRougeLike(takePetRougeLike[_loc6_]).addExtraHp(hp - allhpMax);
                  _loc6_++;
               }
            }
            hp = hpMax;
         }
         else if(hp <= 0)
         {
            hp = 0;
            isDie = true;
            this.checkDead(0);
            if(hp == 1000)
            {
               return;
            }
         }
         if(this.type == "role")
         {
         }
         protectedData.updateV("hp",param1);
         if(protectedData.getValue("hp") >= protectedData.getValue("hpMax"))
         {
            protectedData.setValue("hp",protectedData.getValue("hpMax"));
         }
         else if(protectedData.getValue("hp") <= 0)
         {
            protectedData.setValue("hp",0);
            isDie = true;
         }
         ApplicationFacade.getInstance().sendNotification("nfPlayerInfoChange",this);
         if(isDie == false)
         {
            ApplicationFacade.getInstance().sendNotification("NF_PLAYER_HP_CHANGE",{
               "userVo":this,
               "value":param1
            });
         }
         if(param2 && isDie == false)
         {
            ApplicationFacade.getInstance().sendNotification("NF_ENTITY_HP_CHANGE",{
               "userVo":this,
               "value":param1
            });
         }
         if(isDie && type == "monster")
         {
            ApplicationFacade.getInstance().sendNotification("NF_PLAYER_HP_CHANGE",{
               "userVo":this,
               "value":1
            });
         }
         if(shareUvo)
         {
            if(isNaN(shareUpdateHpPer) == false)
            {
               param1 *= shareUpdateHpPer;
            }
            if(isNaN(shareUpdateHpMax) == false)
            {
               if(shareUpdateHpMax + param1 < 0)
               {
                  param1 = -shareUpdateHpMax;
                  shareUpdateHpMax = 0;
               }
               else
               {
                  shareUpdateHpMax += param1;
               }
            }
            shareUvo.updateHP(param1,param2,param3);
            _loc5_ = BattleModelManager.getIns().getPlayerByEntityId(shareUvo.entitieId) as RoleEntity;
            if(_loc5_)
            {
               _loc5_.OnUpdateHpBy(this);
            }
         }
      }
      
      public function setHP(param1:Number) : void
      {
         if(this.lockHP)
         {
            return;
         }
         hp = param1;
         if(this.keepPercentHp > 0)
         {
            if(this.hp / this.allhpMax < this.keepPercentHp)
            {
               this.hp = this.allhpMax * this.keepPercentHp;
               param1 = 0;
               this.lockHP = true;
            }
         }
         if(hp >= hpMax)
         {
            hp = hpMax;
         }
         else if(hp <= 0)
         {
            hp = 0;
            isDie = true;
            this.checkDead(0);
         }
         protectedData.setValue("hp",hp);
         if(protectedData.getValue("hp") >= protectedData.getValue("hpMax"))
         {
            protectedData.setValue("hp",protectedData.getValue("hpMax"));
         }
         else if(protectedData.getValue("hp") <= 0)
         {
            protectedData.setValue("hp",0);
            isDie = true;
         }
         ApplicationFacade.getInstance().sendNotification("nfPlayerInfoChange",this);
         if(isDie == false)
         {
            ApplicationFacade.getInstance().sendNotification("NF_PLAYER_HP_CHANGE",{
               "userVo":this,
               "value":param1
            });
         }
         if(isDie && type == "monster")
         {
            ApplicationFacade.getInstance().sendNotification("NF_PLAYER_HP_CHANGE",{
               "userVo":this,
               "value":1
            });
         }
      }
      
      public function setMP(param1:int, param2:Boolean = true) : void
      {
         var _loc3_:Boolean = true;
         this.mp = param1;
         if(mp >= mpMax)
         {
            mp = mpMax;
            _loc3_ = false;
         }
         else if(mp <= 0)
         {
            mp = 0;
            _loc3_ = false;
         }
         protectedData.setValue("mp",param1);
         if(protectedData.getValue("mp") >= protectedData.getValue("mpMax"))
         {
            protectedData.setValue("mp",protectedData.getValue("mpMax"));
         }
         else if(protectedData.getValue("mp") <= 0)
         {
            protectedData.setValue("mp",0);
         }
         if(param1 > 0 && param2)
         {
            ApplicationFacade.getInstance().sendNotification("NF_ENTITY_MP_CHANGE",{
               "userVo":this,
               "value":param1
            });
         }
      }
      
      public function advanceTime(param1:Number) : void
      {
         var _loc2_:int = 0;
         this.checkDead(param1);
         this.updateWuShuanTime(param1);
         if(isDie)
         {
            return;
         }
         if(currentChildern)
         {
            currentChildern.advanceTime(param1);
            return;
         }
         if(currentPet)
         {
            currentPet.advanceTime(param1);
            ApplicationFacade.getInstance().sendNotification("nfPlayerInfoChange",currentPet);
         }
         if(currentHorser)
         {
            currentHorser.advanceTime(param1);
            ApplicationFacade.getInstance().sendNotification("nfPlayerInfoChange",currentHorser);
         }
         if(isNaN(_totalTime))
         {
            _totalTime = 0;
         }
         _totalTime += param1;
         this.addLuoAddValue(param1);
         if(_totalTime - 1000 >= 0)
         {
            _totalTime -= 1000;
            changeCD -= 1000;
            if(this.isXuWu)
            {
               updateMp(0,false);
               updateHP(0,false);
            }
            else if(this.reHpMx == 0)
            {
               updateHP(0,false);
               updateMp(this.allreMP,false);
            }
            else
            {
               updateMp(this.allreMP,false);
               updateHP(this.allreHP,false);
            }
         }
         if(this.takeCryStals)
         {
            _loc2_ = 0;
            while(_loc2_ < this.takeCryStals.length)
            {
               this.takeCryStals[_loc2_].advanceTime(param1);
               _loc2_++;
            }
         }
      }
      
      public function advanceTimeChangeCD(param1:Number) : void
      {
         if(currentChildern)
         {
            currentChildern.advanceTimeChangeCD(param1);
            return;
         }
         if(isNaN(_totalTime))
         {
            _totalTime = 0;
         }
         _totalTime += param1;
         if(_totalTime - 1000 >= 0)
         {
            _totalTime -= 1000;
            changeCD -= 1000;
         }
      }
      
      private function compare() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < protectedData.pname.length)
         {
            if(this[protectedData.pname[_loc1_]] != protectedData.getValue(protectedData.pname[_loc1_]))
            {
               this[protectedData.pname[_loc1_]] = protectedData.getValue(protectedData.pname[_loc1_]);
            }
            _loc1_++;
         }
      }
      
      public function updateMp(param1:int, param2:Boolean) : void
      {
         var _loc5_:int = 0;
         var _loc3_:BuffVO = null;
         var _loc4_:Boolean = true;
         if(param1 > 0)
         {
            if(canAddMp == false)
            {
               param1 = 0;
            }
         }
         if(param1 < 0)
         {
            _loc5_ = 0;
            while(_loc5_ < buffs.length)
            {
               _loc3_ = buffs[_loc5_];
               if(_loc3_ && _loc3_.config.type == 116 && _loc3_.config.attributeT == "mp")
               {
                  _loc3_.value += param1;
                  if(_loc3_.value > 0)
                  {
                     param1 = 0;
                     break;
                  }
                  param1 = _loc3_.value;
                  _loc3_.value = 0;
               }
               _loc5_++;
            }
         }
         this.mp += param1;
         if(mp >= mpMax)
         {
            mp = mpMax;
            _loc4_ = false;
         }
         else if(mp <= 0)
         {
            mp = 0;
            _loc4_ = false;
         }
         protectedData.updateV("mp",param1);
         if(protectedData.getValue("mp") >= protectedData.getValue("mpMax"))
         {
            protectedData.setValue("mp",protectedData.getValue("mpMax"));
         }
         else if(protectedData.getValue("mp") <= 0)
         {
            protectedData.setValue("mp",0);
         }
         if(param1 > 0 && param2)
         {
            ApplicationFacade.getInstance().sendNotification("NF_ENTITY_MP_CHANGE",{
               "userVo":this,
               "value":param1
            });
         }
         if(param1 < 0 && param2)
         {
            ApplicationFacade.getInstance().sendNotification("NF_ENTITY_MP_reduce_CHANGE",{
               "userVo":this,
               "value":param1
            });
         }
      }
      
      public function getMagicWeaponCharID() : int
      {
         var _loc1_:ItemVo = null;
         if(!equipments || !equipments.amulet)
         {
            return 0;
         }
         var _loc2_:int = equipments.amulet.id;
         if(skillAmulet)
         {
            if(typeof skillAmulet == "string")
            {
               _loc1_ = UserModelManager.getIns().getCurretPlayerInfo().equipsBag.hasItemByEntityId(skillAmulet as String);
               if(_loc1_)
               {
                  _loc2_ = _loc1_.id;
               }
            }
            else
            {
               skillAmulet;
               _loc2_ = int(skillAmulet.id);
            }
         }
         return _loc2_;
      }
      
      public function getMagicWeapon() : UserVO
      {
         var _loc1_:ItemVo = null;
         if(!equipments || !equipments.amulet)
         {
            return null;
         }
         var _loc2_:UserVO = new UserVO();
         _loc2_.buildFromObject(this.cloneToObject());
         _loc2_.charID = equipments.amulet.id;
         _loc2_.entityId = equipments.amulet.entityId;
         _loc2_.level = equipments.amulet.level;
         _loc2_.roleName = equipments.amulet.fiveElements.split(",").indexOf("2") > -1 ? "" : null;
         if(skillAmulet)
         {
            if(typeof skillAmulet == "string")
            {
               _loc1_ = UserModelManager.getIns().getCurretPlayerInfo().equipsBag.hasItemByEntityId(skillAmulet as String);
               if(_loc1_)
               {
                  _loc2_.charID = _loc1_.id;
                  _loc2_.level = _loc1_.level;
               }
            }
            else
            {
               skillAmulet;
               _loc2_.charID = skillAmulet.id;
               _loc2_.level = skillAmulet.level;
            }
            try
            {
               _loc2_.roleName = _loc1_.fiveElements.split(",").indexOf("2") > -1 ? "" : null;
            }
            catch(error:Error)
            {
            }
         }
         _loc2_.campId = this.campId;
         _loc2_.entitieId = ++_EID;
         _loc2_.hurtSkills = new Dictionary();
         _loc2_.hpLoseDict = new Dictionary();
         _loc2_.hatred = new Dictionary();
         _loc2_.hp = _loc2_.hpMax;
         _loc2_.buff_gaiLiArr = new Vector.<BuffVO>();
         _loc2_.buff_gaiLiHurtArr = new Vector.<BuffVO>();
         _loc2_.isMagic = true;
         _loc2_.type = ManType.SKILL;
         return _loc2_;
      }
      
      public function getMagicWeapon2CharID() : int
      {
         var _loc1_:Object = null;
         var _loc2_:Object = SwordModelManager.getIns().getCurrUse(this.ps);
         if(this.sword)
         {
            _loc2_ = null;
            for(var _loc3_:String in this.sword)
            {
               _loc1_ = this.sword[_loc3_];
               _loc1_["id"] = _loc3_;
               if(_loc1_.hasOwnProperty("use"))
               {
                  if(_loc1_["use"] == true)
                  {
                     _loc2_ = _loc1_;
                  }
               }
            }
         }
         if(_loc2_ && _loc2_["use"] == true)
         {
            return _loc2_.id;
         }
         return 0;
      }
      
      public function getMagicWeapon2() : UserVO
      {
         var _loc1_:Object = null;
         var _loc3_:UserVO = null;
         var _loc2_:Object = SwordModelManager.getIns().getCurrUse(this.ps);
         if(this.sword)
         {
            _loc2_ = null;
            for(var _loc4_:String in this.sword)
            {
               _loc1_ = this.sword[_loc4_];
               _loc1_["id"] = _loc4_;
               if(_loc1_.hasOwnProperty("use"))
               {
                  if(_loc1_["use"] == true)
                  {
                     _loc2_ = _loc1_;
                  }
               }
            }
         }
         if(_loc2_ && _loc2_["use"] == true)
         {
            _loc3_ = new UserVO();
            _loc3_.buildFromObject(this.cloneToObject());
            _loc3_.charID = _loc2_.id;
            _loc3_.level = _loc2_.level;
            _loc3_.swordShi = _loc2_.swordShi;
            _loc3_.swordShiLevel = _loc2_.swordShiLevel || 1;
            _loc3_.campId = this.campId;
            _loc3_.entitieId = ++_EID;
            _loc3_.hurtSkills = new Dictionary();
            _loc3_.hpLoseDict = new Dictionary();
            _loc3_.hatred = new Dictionary();
            _loc3_.hp = _loc3_.hpMax;
            _loc3_.buff_gaiLiArr = new Vector.<BuffVO>();
            _loc3_.buff_gaiLiHurtArr = new Vector.<BuffVO>();
            _loc3_.isMagic = true;
            _loc3_.type = ManType.SKILL;
            return _loc3_;
         }
         return null;
      }
      
      public function onStart() : void
      {
         isDie = false;
         this._checkDeadParam = null;
         this.lockHp1 = false;
         this.loseHP = 0;
         xp = 0;
         hp = hpMax;
         reHpMx = -1;
         hpMax2 = 0;
         canNotEnterHore = false;
         protectedData.setValue("hp",hpMax);
         mp = mpMax;
         protectedData.setValue("mp",mpMax);
         isWuShuan = false;
         currentHorser = null;
         currentPet = null;
         this._notAddBuffs = [];
         this.buff_cannot_equip = null;
         this.buff_protected = null;
         this.buff411_protected = [];
         this.buff_protected_hasDamage = null;
         this.buff_create_hurt = null;
         this.buff_create_hurt_hasDamage = null;
         this.reduceHPBuff = null;
         this.reduceHPBuff2 = null;
         this.reduceChiXiShangHaiBuff = null;
         this.buff_dmg_rate_on_attMan = null;
         this.buff_dmg_rate_on_attMan2.length = 0;
         this.buff_dmg_rate_on_attMan3.length = 0;
         this.buff_dmg_rate_on_hurtMan.length = 0;
         this.buff_sleep_on_hurtMan = null;
         this.buff60s.length = 0;
         this.buffs.length = 0;
         this.buff_mian_yi = false;
         this.buff_reduce_hpPer = 1;
         this.buff_reduce_hpTotal = 0;
         if(buff_hides)
         {
            buff_hides.length = 0;
         }
         this.currEquipBuffs.length = 0;
         this.buff_mian_yi1s.length = 0;
         this.buff_mian_yitypes.length = 0;
         this._luoBoValue = 0;
         this.xingMoRatio = 1;
         this.isCanNotSubtractHp = false;
         proScore = 0;
         if(children)
         {
            children.onStart();
         }
         if(children2)
         {
            children2.onStart();
         }
         isRun = false;
         mode = 1;
         isCatchingPet = false;
         for(var _loc5_:String in hurtSkills)
         {
            delete hurtSkills[_loc5_];
         }
         for(var _loc4_:String in hatred)
         {
            delete hatred[2];
         }
         for(var _loc3_:String in hpLoseDict)
         {
            delete hpLoseDict[_loc3_];
         }
         for(var _loc2_:String in equipSkillCdObj)
         {
            delete equipSkillCdObj[_loc2_];
         }
         _colsedSkill = [];
         ApplicationFacade.getInstance().sendNotification("nfPlayerInfoChange",this);
         for each(var _loc1_:SkillConfigVO in this.configVo.skills)
         {
            if(_loc1_)
            {
               if(_loc1_.closed)
               {
                  _colsedSkill.push(_loc1_);
               }
               _loc1_.closed = false;
               _loc1_.locked = false;
            }
         }
         this._prev_isLuoHan_ChenShi = false;
         if(this.isLuoHan_ChenShi)
         {
            this._prev_isLuoHan_ChenShi = true;
            this.protectedData.setValue("atk",this.atk);
         }
         this.isLuoHan_ChenShi = false;
         this.isBLYing = false;
         this._power = 0;
         this._zufuHitV1 = [];
         this.zhouYinCd = 0;
      }
      
      public function get allSprint() : Number
      {
         var _loc2_:Number = 0;
         if(this.configVo)
         {
            _loc2_ = Number(this.configVo.sprint || 0);
         }
         var _loc1_:int = this.getBuffProperty("sprint");
         return this.sprint + _loc2_ + _loc1_;
      }
      
      public function onBattle() : void
      {
         if(_colsedSkill)
         {
            for each(var _loc1_:SkillConfigVO in _colsedSkill)
            {
               if(_loc1_)
               {
                  _loc1_.closed = true;
               }
            }
         }
         if(this._prev_isLuoHan_ChenShi)
         {
            this.isLuoHan_ChenShi = true;
         }
         if(this.children)
         {
            this.children.onBattle();
         }
         if(this.children2)
         {
            this.children2.onBattle();
         }
      }
      
      public function updateXP(param1:Number) : void
      {
         if(isWuShuan)
         {
            return;
         }
         if(canNotAddXp)
         {
            return;
         }
         getRootUservo().xp = getRootUservo().xp + param1;
         if(getRootUservo().children)
         {
            getRootUservo().children.xp = getRootUservo().children.xp + param1;
         }
         if(getRootUservo().children2)
         {
            getRootUservo().children2.xp = getRootUservo().children2.xp + param1;
         }
      }
      
      public function getPropertyTotal() : String
      {
         var _loc2_:UserVO = new UserVO();
         _loc2_.buildFromObject(this.cloneToObject());
         var _loc1_:Object = BuffModelManager.getIns().calDelBuff(_loc2_);
         return _loc1_.hpMax + ";" + _loc1_.mpMax + ";" + _loc1_.atk + ";" + _loc1_.phyDef + ";" + _loc1_.reHP + ";" + _loc1_.reMP;
      }
      
      public function updateByPname(param1:String, param2:Number) : void
      {
         if(this.hasOwnProperty(param1))
         {
            if(isNaN(param2))
            {
               param2 = 0;
            }
            this[param1] += param2;
            this.protectedData.updateV(param1,param2);
         }
      }
      
      public function setByPname(param1:String, param2:Number) : void
      {
         this[param1] = param2;
         this.protectedData.setValue(param1,param2);
      }
      
      private function getEquSkill(param1:int) : SkillConfigVO
      {
         var _loc4_:int = 0;
         var _loc2_:EquipmentVo = null;
         var _loc3_:SkillConfigVO = null;
         if(!equipments)
         {
            return null;
         }
         if(!equipments.itemVos)
         {
            return null;
         }
         _loc4_ = 0;
         while(_loc4_ < equipments.itemVos.length)
         {
            _loc2_ = ItemVoManager.getIns().getEquipmentVoById(equipments.itemVos[_loc4_].id);
            if(_loc2_ && _loc2_.skillId > 0)
            {
               _loc3_ = SkillModelManager.getIns().getSkillConfigVOByID(_loc2_.skillId);
               if(!_loc3_)
               {
                  throw new Error(_loc2_.skillId + "找不到技能配置");
               }
               if(_loc3_.type == param1)
               {
                  return _loc3_;
               }
            }
            _loc4_++;
         }
         return null;
      }
      
      public function getEquSkillIds(param1:int) : Array
      {
         var _loc4_:Array = null;
         var _loc7_:int = 0;
         var _loc3_:EquipmentVo = null;
         var _loc2_:Array = null;
         var _loc6_:int = 0;
         var _loc5_:SkillConfigVO = null;
         if(!equipments)
         {
            return null;
         }
         if(!equipments.itemVos)
         {
            return null;
         }
         _loc7_ = 0;
         for(; _loc7_ < equipments.itemVos.length; _loc7_++)
         {
            _loc3_ = ItemVoManager.getIns().getEquipmentVoById(equipments.itemVos[_loc7_].id);
            if(_loc3_ && !!_loc3_.skillIds)
            {
               _loc4_ = [];
               _loc2_ = _loc3_.skillIds.split(";");
               _loc6_ = 0;
               while(_loc6_ < _loc2_.length)
               {
                  _loc5_ = SkillModelManager.getIns().getSkillConfigVOByID(_loc2_[_loc6_]);
                  if(!_loc5_)
                  {
                     throw new Error(_loc3_.skillId + "找不到技能配置");
                  }
                  if(_loc5_.type == param1)
                  {
                     _loc4_.push(_loc5_);
                  }
                  _loc6_++;
               }
            }
         }
         return _loc4_;
      }
      
      public function getMoEquXianQian(param1:String = "ornamentMo") : Object
      {
         var _loc8_:int = 0;
         var _loc4_:ItemVo = null;
         var _loc3_:EquipmentVo = null;
         var _loc2_:Array = null;
         var _loc7_:int = 0;
         var _loc6_:Number = NaN;
         var _loc5_:EquipmentVo = null;
         if(!equipments)
         {
            return null;
         }
         if(!equipments.itemVos)
         {
            return null;
         }
         _loc8_ = 0;
         for(; _loc8_ < equipments.itemVos.length; _loc8_++)
         {
            _loc4_ = equipments.itemVos[_loc8_];
            _loc3_ = ItemVoManager.getIns().getEquipmentVoById(equipments.itemVos[_loc8_].id);
            if(_loc3_ && _loc3_.part == param1)
            {
               _loc2_ = _loc4_.inlayInfo || [];
               _loc7_ = 0;
               while(_loc7_ < _loc2_.length)
               {
                  _loc6_ = Number(_loc2_[_loc7_].skillId);
                  if(_loc6_ > 0)
                  {
                     _loc5_ = ItemVoManager.getIns().getEquipmentVoById(_loc2_[_loc7_].id);
                     return {
                        "entityId":_loc2_[_loc7_].entityId,
                        "skillId":_loc6_,
                        "param":JSON.parse(_loc5_.param)
                     };
                  }
                  _loc7_++;
               }
            }
         }
         return null;
      }
      
      public function getEquIdBySkillType(param1:int) : int
      {
         var _loc4_:int = 0;
         var _loc2_:EquipmentVo = null;
         var _loc3_:SkillConfigVO = null;
         if(!equipments)
         {
            return null;
         }
         if(!equipments.itemVos)
         {
            return null;
         }
         _loc4_ = 0;
         while(_loc4_ < equipments.itemVos.length)
         {
            _loc2_ = ItemVoManager.getIns().getEquipmentVoById(equipments.itemVos[_loc4_].id);
            if(_loc2_ && _loc2_.skillId > 0)
            {
               _loc3_ = SkillModelManager.getIns().getSkillConfigVOByID(_loc2_.skillId);
               if(!_loc3_)
               {
                  throw new Error(_loc2_.skillId + "找不到技能配置");
               }
               if(_loc3_.type == param1)
               {
                  return _loc2_.id;
               }
            }
            _loc4_++;
         }
         return null;
      }
      
      public function getEquSkillByTan() : SkillConfigVO
      {
         return getEquSkill(11);
      }
      
      public function getEquSkillByChen() : SkillConfigVO
      {
         return getEquSkill(12);
      }
      
      public function getEquSkillByChi() : SkillConfigVO
      {
         return getEquSkill(13);
      }
      
      public function getEquSkillByChi16() : Array
      {
         var _loc2_:Array = null;
         var _loc1_:Array = null;
         if(getEquSkill(16))
         {
            _loc2_ = [getEquSkill(16)];
            _loc1_ = this.getEquSkillIds(16);
            if(_loc1_)
            {
               _loc2_ = _loc2_.concat(_loc1_);
            }
            return [_loc2_,getEquIdBySkillType(16)];
         }
         return null;
      }
      
      public function getEquSkillByTanYu() : SkillConfigVO
      {
         return getEquSkill(14);
      }
      
      public function getEquSkillByTanYu2() : Array
      {
         var _loc2_:Array = null;
         var _loc1_:Array = null;
         if(getEquSkill(141))
         {
            _loc2_ = [getEquSkill(141)];
            _loc1_ = this.getEquSkillIds(141);
            if(_loc1_)
            {
               _loc2_ = _loc2_.concat(_loc1_);
            }
            return [_loc2_,getEquIdBySkillType(141)];
         }
         return null;
      }
      
      public function getEquSkillByChenLu() : Array
      {
         var _loc2_:Array = null;
         var _loc1_:Array = null;
         if(getEquSkill(15))
         {
            _loc2_ = [getEquSkill(15)];
            _loc1_ = this.getEquSkillIds(15);
            if(_loc1_)
            {
               _loc2_ = _loc2_.concat(_loc1_);
            }
            return [_loc2_,getEquIdBySkillType(15)];
         }
         return null;
      }
      
      public function getEquSkillBy17() : Array
      {
         var _loc2_:Array = null;
         var _loc1_:Array = null;
         if(getEquSkill(17))
         {
            _loc2_ = [getEquSkill(17)];
            _loc1_ = this.getEquSkillIds(17);
            if(_loc1_)
            {
               _loc2_ = _loc2_.concat(_loc1_);
            }
            return [_loc2_,getEquIdBySkillType(17)];
         }
         return null;
      }
      
      public function getEquSkillBy18() : Array
      {
         var _loc2_:Array = null;
         var _loc1_:Array = null;
         if(getEquSkill(18))
         {
            _loc2_ = [getEquSkill(18)];
            _loc1_ = this.getEquSkillIds(18);
            if(_loc1_)
            {
               _loc2_ = _loc2_.concat(_loc1_);
            }
            return [_loc2_,getEquIdBySkillType(18)];
         }
         return null;
      }
      
      public function getEquSkillByTanHp(param1:Number) : Number
      {
         return param1 * getEquSkillByTan().skillCountAdd[0] * this.hpMax;
      }
      
      public function getEquSkillByTanMP(param1:Number) : Number
      {
         return param1 * getEquSkillByTan().skillCountAdd[1] * this.mpMax;
      }
      
      public function hasWing() : ItemVo
      {
         if(equipments && equipments.wing)
         {
            return equipments.wing;
         }
         return null;
      }
      
      public function getHurt() : int
      {
         return 0;
      }
      
      public function AddAtk(param1:int) : void
      {
         this.atk += param1;
         this.protectedData.setValue("atk",this.protectedData.getValue("atk") + param1);
      }
      
      public function AddHpMax(param1:int) : void
      {
         this.hpMax += param1;
         this.protectedData.setValue("hpMax",this.protectedData.getValue("hpMax") + param1);
      }
      
      public function ReSetEq() : void
      {
         if(equipments)
         {
            equipments.yfFrame = 0;
            equipments.wqFrame = 0;
            if(this.children)
            {
               this.children.equipments.yfFrame = 0;
               this.children.equipments.wqFrame = 0;
            }
         }
      }
      
      public function checkLostHp() : Boolean
      {
         var _loc1_:Number = Number(this.hpLoseDict[0]);
         if(this.hpMax < 2)
         {
            return false;
         }
         if(_loc1_ >= this.hpMax)
         {
            return true;
         }
         return false;
      }
      
      public function getCurrentUVO() : UserVO
      {
         if(this.currentChildern)
         {
            return this.currentChildern;
         }
         return this;
      }
      
      public function getIsDie() : Boolean
      {
         return _isDie;
      }
      
      public function getHaveStayBuff() : Boolean
      {
         if(this.charID == 2009 && this.configVo.skills["effect5"].level > 0)
         {
            return true;
         }
         return false;
      }
      
      public function getHaveTsStayBuff() : Boolean
      {
         if(this.charID == 2007 && this.configVo.skills["effect1"].level > 0)
         {
            return true;
         }
         return false;
      }
      
      public function get1CharID() : int
      {
         if(this.parent)
         {
            return this.parent.charID;
         }
         if(this.children)
         {
            return this.charID;
         }
         return 0;
      }
      
      public function getRootUservo() : UserVO
      {
         if(this.parent)
         {
            return this.parent;
         }
         return this;
      }
      
      public function get showFashion() : int
      {
         return _showFashion;
      }
      
      public function set showFashion(param1:int) : void
      {
         _showFashion = param1;
         if(this.children)
         {
            this.children._showFashion = param1;
         }
         if(this.children2)
         {
            this.children2._showFashion = param1;
         }
      }
      
      public function get showMoEquip() : int
      {
         return _showMoEquip;
      }
      
      public function set showMoEquip(param1:int) : void
      {
         _showMoEquip = param1;
         if(this.children)
         {
            this.children._showMoEquip = param1;
         }
         if(this.children2)
         {
            this.children2._showMoEquip = param1;
         }
      }
      
      public function resetBuff_hp_mp_per() : void
      {
         _buff_hurt_add_hp_per = _buff_useSkill_add_mp_per = 0;
         _buff_hurt_add_hp_target = [];
         _buff_useSkill_add_mp_target = [];
         if(children)
         {
            children.resetBuff_hp_mp_per();
         }
         if(children2)
         {
            children2.resetBuff_hp_mp_per();
         }
      }
      
      public function get allhpMax() : Number
      {
         return Math.round(this.hpMax + getBuffProperty("hpMax") + getBattleProperty("hpMax"));
      }
      
      public function get allreHP() : Number
      {
         return this.reHP + getBuffProperty("reHP");
      }
      
      public function get allmpMax() : Number
      {
         return Math.round(this.mpMax + getBuffProperty("mpMax"));
      }
      
      public function get allatk() : Number
      {
         return int(Math.round(this.atk + getBuffProperty("atk") + getSoulProperty("atk") + getBattleProperty("atk")));
      }
      
      public function get allphyDef() : Number
      {
         return int(Math.round(this.phyDef + getBuffProperty("phyDef") + getBattleProperty("phyDef")));
      }
      
      public function get allhit() : Number
      {
         var _loc5_:int = 0;
         var _loc2_:BuffVO = null;
         var _loc4_:Number = 0;
         var _loc3_:Number = 0;
         _loc5_ = 0;
         while(_loc5_ < _zufuHitV1.length)
         {
            _loc2_ = _zufuHitV1[_loc5_];
            _loc4_ += _loc2_.value;
            _loc3_ += _loc2_.config.attributeV2;
            _loc5_++;
         }
         if(_loc4_ != 0 && !SimpleTextLog.Close)
         {
            SimpleTextLog.getIns().log2("hitv1=" + _loc4_,"hitv2=" + _loc3_);
         }
         var _loc1_:Number = this.hit + getBuffProperty("hit") + _loc4_;
         if(_loc3_ != 0 && _loc1_ < _loc3_)
         {
            _loc1_ = _loc3_;
            SimpleTextLog.getIns().log2("最终命中不会小于V2 ",_loc1_);
         }
         return _loc1_;
      }
      
      public function get alldodge() : Number
      {
         return this.dodge + getBuffProperty("dodge");
      }
      
      public function get allcritical() : Number
      {
         return this.critical + getBuffProperty("critical") + getBattleProperty("critical");
      }
      
      public function get alltoughness() : Number
      {
         return this.toughness + getBuffProperty("toughness");
      }
      
      public function get alllucky() : Number
      {
         return this.lucky + getBuffProperty("lucky") + getBattleProperty("lucky");
      }
      
      public function get allguardian() : Number
      {
         return this.guardian + getBuffProperty("guardian");
      }
      
      public function get allreduceMagDef() : Number
      {
         return this.reduceMagDef + getBuffProperty("reduceMagDef");
      }
      
      public function get allreMP() : Number
      {
         return this.reMP + getBuffProperty("reMP");
      }
      
      public function get allmagRes() : Number
      {
         return this.magRes + getBuffProperty("magRes") + getBattleProperty("magRes");
      }
      
      public function get allsuckBlood() : Number
      {
         return this.suckBlood + getBuffProperty("suckBlood");
      }
      
      public function get allbackLash() : Number
      {
         return this.backLash + getBuffProperty("backLash");
      }
      
      public function get allsoulCritical() : Number
      {
         return this.soulCritical + getBuffProperty("soulCritical");
      }
      
      public function get allsoulToughness() : Number
      {
         return this.soulToughness + getBuffProperty("soulToughness");
      }
      
      public function get allsoar() : Number
      {
         return this.soar + getBuffProperty("soar");
      }
      
      public function get allsoulAtk() : Number
      {
         return this.soulAtk + getBuffProperty("soulAtk");
      }
      
      public function get allsoulPhydef() : Number
      {
         return this.soulPhydef + getBuffProperty("soulPhydef");
      }
      
      public function updatePropertyByBuff(param1:Number, param2:String) : void
      {
         if(!_buffProperty.hasOwnProperty(param2))
         {
            _buffProperty[param2] = 0;
         }
         var _loc3_:String = param2;
         var _loc4_:Number = _buffProperty[_loc3_] + param1;
         _buffProperty[_loc3_] = _loc4_;
      }
      
      public function getBuffProperty(param1:String) : Number
      {
         if(!_buffProperty.hasOwnProperty(param1))
         {
            _buffProperty[param1] = 0;
         }
         return _buffProperty[param1];
      }
      
      public function removeBuffProperty() : void
      {
         for(var _loc1_:String in _buffProperty)
         {
            delete _buffProperty[_loc1_];
         }
      }
      
      public function updatePropertyBySoul(param1:Number, param2:String) : void
      {
         if(!_soulProperty.hasOwnProperty(param2))
         {
            _soulProperty[param2] = 0;
         }
         var _loc3_:String = param2;
         var _loc4_:Number = _soulProperty[_loc3_] + param1;
         _soulProperty[_loc3_] = _loc4_;
      }
      
      public function getSoulProperty(param1:String) : Number
      {
         if(!_soulProperty.hasOwnProperty(param1))
         {
            _soulProperty[param1] = 0;
         }
         return _soulProperty[param1];
      }
      
      public function removeSoulProperty() : void
      {
         for(var _loc1_:String in _soulProperty)
         {
            delete _soulProperty[_loc1_];
         }
      }
      
      public function getCalDamageAtk() : Number
      {
         var _loc5_:Number = NaN;
         var _loc3_:Array = null;
         var _loc1_:Number = NaN;
         var _loc6_:int = 0;
         var _loc2_:BuffVO = null;
         var _loc4_:int = 0;
         if(this.isLuoHan_ChenShi)
         {
            _loc5_ = this.entitieId;
            if(this.type == ManType.SKILL && this.parent)
            {
               _loc5_ = this.parent.entitieId;
            }
            if(this.father && this.type == "monster")
            {
               _loc5_ = this.father.entitieId;
            }
            _loc3_ = BuffModelManager.getIns().getManAllBuffsByEid(_loc5_) || [];
            _loc1_ = 0;
            _loc6_ = 0;
            while(_loc6_ < _loc3_.length)
            {
               _loc2_ = _loc3_[_loc6_];
               if(String(_loc2_.config.id).indexOf("230013") > -1 || String(_loc2_.config.id).indexOf("230015") > -1)
               {
                  _loc1_ += _loc2_.config.attributeV1 || 0;
               }
               _loc6_++;
            }
            _loc4_ = this.atk * _loc1_;
            SimpleTextLog.getIns().log2("isLuoHan_ChenShi,this.atk*attributeV1=",_loc4_);
            this.protectedData.setValue("atk",_loc4_);
            return _loc4_;
         }
         if(charID == 3886)
         {
            return this.allatk + (this.allphyDef - this.configVo.phyDef) * 1.5;
         }
         return this.allatk;
      }
      
      public function getCalDamagePhyDef() : Number
      {
         return this.phyDef + getBattleProperty("phyDef");
      }
      
      public function addReFatigue(param1:Number) : void
      {
      }
      
      public function getHorseSoulProperty() : HorseSoulSkillVO
      {
         return null;
      }
      
      public function addNotAddBuffs(param1:Number) : void
      {
         _notAddBuffs.push(param1);
      }
      
      public function getNotAddBuffs() : Array
      {
         return _notAddBuffs;
      }
      
      public function removeNotAddBuffs(param1:Number) : void
      {
         var _loc2_:int = _notAddBuffs.indexOf(param1);
         if(_loc2_ > -1)
         {
            _notAddBuffs.splice(_loc2_,1);
         }
      }
      
      private function addLuoAddValue(param1:Number) : void
      {
         var _loc3_:Number = NaN;
         var _loc2_:SkillConfigVO = null;
         if(this.charID == 20001 && this.configVo.skills["effect4"].level >= 1)
         {
            _loc3_ = param1 / 20000;
            _loc2_ = this.configVo.skills["effect4"];
            if(_loc2_ && _loc2_.awakeSKId == 1111240)
            {
            }
            _luoBoValue += _loc3_;
         }
      }
      
      public function getPower() : Number
      {
         return this._power;
      }
      
      public function addPower(param1:Number) : void
      {
         this._power += param1;
         if(this._power < 0)
         {
            this._power = 0;
         }
      }
      
      public function getLuoBoPercent() : Number
      {
         if(_luoBoValue > 1)
         {
            _luoBoValue = 1;
         }
         return this._luoBoValue;
      }
      
      public function removeLuoboValue() : void
      {
         _luoBoValue = 0;
      }
      
      public function setCheckDead(param1:int, param2:Number, param3:Number, param4:Array) : void
      {
         this._checkDeadParam = {
            "time":param1,
            "hp":param2,
            "lockHpTime":param3,
            "buffs":param4,
            "addedBuff":false
         };
      }
      
      public function clearCheckDead() : void
      {
         this._checkDeadParam = null;
         this.lockHp1 = false;
      }
      
      private function checkDead(param1:Number) : void
      {
         if(this._checkDeadParam)
         {
            SimpleTextLog.getIns().log2("this._checkDeadParam",JSON.stringify(this._checkDeadParam));
            if(this._checkDeadParam.time > 0)
            {
               this._checkDeadParam.time -= param1;
               if(isDie)
               {
                  isDie = false;
                  this.updateHP(this._checkDeadParam.hp,false);
                  this._checkDeadParam.time = -999;
                  this.checkDead(0);
                  if(this.lockHp1)
                  {
                     BuffModelManager.getIns().delByconfigId(this.entitieId,9901101);
                  }
               }
            }
            else if(this._checkDeadParam.lockHpTime > 0 && this._checkDeadParam.time <= -999)
            {
               this._checkDeadParam.lockHpTime -= param1;
               isDie = false;
               this.lockHp1 = true;
               this.setHP(this._checkDeadParam.hp);
               if(this._checkDeadParam.lockHpTime <= 100 && !this._checkDeadParam.addedBuff)
               {
                  BuffModelManager.getIns().createBuff(this._checkDeadParam.buffs,[],1,this);
                  this._checkDeadParam.addedBuff = true;
               }
               if(this._checkDeadParam.lockHpTime <= 0)
               {
                  this.lockHp1 = false;
                  this._checkDeadParam = null;
               }
            }
            else
            {
               this._checkDeadParam = null;
            }
         }
      }
      
      private function updateWuShuanTime(param1:Number) : void
      {
         var _loc2_:UserVO = this.getRootUservo();
         if(_loc2_ == this && _loc2_.wuShuanTime > 0)
         {
            _loc2_.wuShuanTime -= param1;
            if(_loc2_.wuShuanTime <= 0)
            {
               _loc2_.isWuShuan = this.getRootUservo().children.isWuShuan = false;
               if(this.getRootUservo().children2)
               {
                  this.getRootUservo().children2.isWuShuan = false;
               }
            }
         }
      }
      
      public function getHpValue(param1:Number) : Number
      {
         var _loc7_:int = 0;
         var _loc6_:BuffVO = null;
         if(param1 < 0)
         {
            return param1;
         }
         var _loc5_:Number = 0;
         var _loc3_:Number = 0;
         var _loc4_:Number = 0;
         var _loc2_:Number = 0;
         if(this.reduceHPBuff2)
         {
            _loc7_ = 0;
            while(_loc7_ < this.reduceHPBuff2.length)
            {
               _loc6_ = this.reduceHPBuff2[_loc7_];
               _loc5_ = 1 - _loc6_.config.attributeV1;
               _loc3_ = 1 / (1 - _loc5_) - 1;
               if(_loc6_.config.attributeV1 < 0)
               {
                  _loc3_ = _loc6_.config.attributeV1;
               }
               _loc4_ += _loc3_;
               _loc7_++;
            }
            if(_loc4_ > 0)
            {
               _loc2_ = 1 - 1 / (_loc4_ + 1);
            }
            else
            {
               _loc2_ = _loc4_;
            }
         }
         SimpleTextLog.getIns().log2(param1,"检测身上有没有减少回血","d=" + _loc2_);
         if(this.reduceHPBuff)
         {
            param1 = param1 * this.reduceHPBuff.config.attributeV1 * (1 - _loc2_);
         }
         else
         {
            param1 *= 1 - _loc2_;
         }
         SimpleTextLog.getIns().log2("检测身上有没有减少回血","v=" + param1);
         return param1;
      }
      
      public function getSkillConfigVO(param1:Number) : SkillConfigVO
      {
         for each(var _loc2_:SkillConfigVO in configVo.skills)
         {
            if(_loc2_.id == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function updatePropertyByBattle(param1:Number, param2:String) : void
      {
         if(!_battleProperty.hasOwnProperty(param2))
         {
            _battleProperty[param2] = 0;
         }
         if(isNaN(param1))
         {
            param1 = 0;
         }
         var _loc3_:String = param2;
         var _loc4_:Number = _battleProperty[_loc3_] + param1;
         _battleProperty[_loc3_] = _loc4_;
      }
      
      public function getBattleProperty(param1:String) : Number
      {
         if(!_battleProperty.hasOwnProperty(param1))
         {
            _battleProperty[param1] = 0;
         }
         return _battleProperty[param1];
      }
      
      public function removeBattleProperty() : void
      {
         for(var _loc1_:String in _battleProperty)
         {
            delete _battleProperty[_loc1_];
         }
      }
      
      public function getCalDamageHpper() : Number
      {
         if(isNaN(this.shareBuffHpPer))
         {
            return 1;
         }
         return this.shareBuffHpPer;
      }
      
      public function setkey2() : void
      {
         var _loc1_:UserVO = this;
         if(this.ps == 2)
         {
            _loc1_.keyBoard2 = new KeySetVO();
            if(_loc1_.keyBoard)
            {
               _loc1_.keyBoard.addKey2(_loc1_.keyBoard2);
            }
            _loc1_.keyBoard2.setKey(87,22);
            _loc1_.keyBoard2.setKey(65,23);
            _loc1_.keyBoard2.setKey(83,21);
            _loc1_.keyBoard2.setKey(68,24);
            _loc1_.keyBoard2.setKey(74,41);
            _loc1_.keyBoard2.setKey(75,6);
            _loc1_.keyBoard2.setKey(32,ActionState.WU_SHUAN);
            _loc1_.keyBoard2.setKey(72,1002);
            _loc1_.keyBoard2.setKey(80,1003);
            _loc1_.keyBoard2.setKey(70,301);
            _loc1_.keyBoard2.setKey(89,_loc1_.keyBoard.getActionByKey(99));
            _loc1_.keyBoard2.setKey(85,_loc1_.keyBoard.getActionByKey(100));
            _loc1_.keyBoard2.setKey(73,_loc1_.keyBoard.getActionByKey(101));
            _loc1_.keyBoard2.setKey(79,_loc1_.keyBoard.getActionByKey(102));
            _loc1_.keyBoard2.setKey(76,_loc1_.keyBoard.getActionByKey(104));
            _loc1_.keyBoard2.setKey(90,200);
            _loc1_.keyBoard2.setKey(81,401);
            _loc1_.children.keyBoard2 = new KeySetVO();
            if(_loc1_.children.keyBoard)
            {
               _loc1_.children.keyBoard.addKey2(_loc1_.children.keyBoard2);
            }
            _loc1_.children.keyBoard2.setKey(87,22);
            _loc1_.children.keyBoard2.setKey(65,23);
            _loc1_.children.keyBoard2.setKey(83,21);
            _loc1_.children.keyBoard2.setKey(68,24);
            _loc1_.children.keyBoard2.setKey(74,41);
            _loc1_.children.keyBoard2.setKey(75,6);
            _loc1_.children.keyBoard2.setKey(32,ActionState.WU_SHUAN);
            _loc1_.children.keyBoard2.setKey(72,1002);
            _loc1_.children.keyBoard2.setKey(80,1003);
            _loc1_.children.keyBoard2.setKey(70,301);
            _loc1_.children.keyBoard2.setKey(89,_loc1_.children.keyBoard.getActionByKey(99));
            _loc1_.children.keyBoard2.setKey(85,_loc1_.children.keyBoard.getActionByKey(100));
            _loc1_.children.keyBoard2.setKey(73,_loc1_.children.keyBoard.getActionByKey(101));
            _loc1_.children.keyBoard2.setKey(79,_loc1_.children.keyBoard.getActionByKey(102));
            _loc1_.children.keyBoard2.setKey(76,_loc1_.children.keyBoard.getActionByKey(104));
            _loc1_.children.keyBoard2.setKey(90,200);
            _loc1_.children.keyBoard2.setKey(81,401);
            _loc1_.children2.keyBoard2 = new KeySetVO();
            if(_loc1_.children2.keyBoard)
            {
               _loc1_.children2.keyBoard.addKey2(_loc1_.children2.keyBoard2);
            }
            _loc1_.children2.keyBoard2.setKey(87,22);
            _loc1_.children2.keyBoard2.setKey(65,23);
            _loc1_.children2.keyBoard2.setKey(83,21);
            _loc1_.children2.keyBoard2.setKey(68,24);
            _loc1_.children2.keyBoard2.setKey(74,41);
            _loc1_.children2.keyBoard2.setKey(32,ActionState.WU_SHUAN);
            _loc1_.children2.keyBoard2.setKey(72,1002);
            _loc1_.children2.keyBoard2.setKey(80,1003);
            _loc1_.children2.keyBoard2.setKey(89,71);
            _loc1_.children2.keyBoard2.setKey(85,72);
            _loc1_.children2.keyBoard2.setKey(73,73);
            _loc1_.children2.keyBoard2.setKey(79,74);
            _loc1_.children2.keyBoard2.setKey(76,75);
         }
         else if(this.ps == 1)
         {
            _loc1_.keyBoard2 = new KeySetVO();
            if(_loc1_.keyBoard)
            {
               _loc1_.keyBoard.addKey2(_loc1_.keyBoard2);
            }
            _loc1_.keyBoard2.setKey(38,22);
            _loc1_.keyBoard2.setKey(40,21);
            _loc1_.keyBoard2.setKey(37,23);
            _loc1_.keyBoard2.setKey(39,24);
            _loc1_.keyBoard2.setKey(97,41);
            _loc1_.keyBoard2.setKey(98,6);
            _loc1_.keyBoard2.setKey(96,ActionState.WU_SHUAN);
            _loc1_.keyBoard2.setKey(103,1002);
            _loc1_.keyBoard2.setKey(106,1003);
            _loc1_.keyBoard2.setKey(70,301);
            _loc1_.keyBoard2.setKey(99,_loc1_.keyBoard.getActionByKey(89));
            _loc1_.keyBoard2.setKey(100,_loc1_.keyBoard.getActionByKey(85));
            _loc1_.keyBoard2.setKey(101,_loc1_.keyBoard.getActionByKey(73));
            _loc1_.keyBoard2.setKey(102,_loc1_.keyBoard.getActionByKey(79));
            _loc1_.keyBoard2.setKey(104,_loc1_.keyBoard.getActionByKey(76));
            _loc1_.keyBoard2.setKey(105,200);
            _loc1_.keyBoard2.setKey(107,401);
            _loc1_.children.keyBoard2 = new KeySetVO();
            if(_loc1_.children.keyBoard)
            {
               _loc1_.children.keyBoard.addKey2(_loc1_.children.keyBoard2);
            }
            _loc1_.children.keyBoard2.setKey(38,22);
            _loc1_.children.keyBoard2.setKey(40,21);
            _loc1_.children.keyBoard2.setKey(37,23);
            _loc1_.children.keyBoard2.setKey(39,24);
            _loc1_.children.keyBoard2.setKey(97,41);
            _loc1_.children.keyBoard2.setKey(98,6);
            _loc1_.children.keyBoard2.setKey(96,ActionState.WU_SHUAN);
            _loc1_.children.keyBoard2.setKey(103,1002);
            _loc1_.children.keyBoard2.setKey(106,1003);
            _loc1_.children.keyBoard2.setKey(70,301);
            _loc1_.children.keyBoard2.setKey(99,_loc1_.children.keyBoard.getActionByKey(89));
            _loc1_.children.keyBoard2.setKey(100,_loc1_.children.keyBoard.getActionByKey(85));
            _loc1_.children.keyBoard2.setKey(101,_loc1_.children.keyBoard.getActionByKey(73));
            _loc1_.children.keyBoard2.setKey(102,_loc1_.children.keyBoard.getActionByKey(79));
            _loc1_.children.keyBoard2.setKey(104,_loc1_.children.keyBoard.getActionByKey(76));
            _loc1_.children.keyBoard2.setKey(105,200);
            _loc1_.children.keyBoard2.setKey(107,401);
            _loc1_.children2.keyBoard2 = new KeySetVO();
            if(_loc1_.children2.keyBoard)
            {
               _loc1_.children2.keyBoard.addKey2(_loc1_.children2.keyBoard2);
            }
            _loc1_.children2.keyBoard2.setKey(38,22);
            _loc1_.children2.keyBoard2.setKey(40,21);
            _loc1_.children2.keyBoard2.setKey(37,23);
            _loc1_.children2.keyBoard2.setKey(39,24);
            _loc1_.children2.keyBoard2.setKey(97,41);
            _loc1_.children2.keyBoard2.setKey(96,ActionState.WU_SHUAN);
            _loc1_.children2.keyBoard2.setKey(103,1002);
            _loc1_.children2.keyBoard2.setKey(106,1003);
            _loc1_.children2.keyBoard2.setKey(99,71);
            _loc1_.children2.keyBoard2.setKey(100,72);
            _loc1_.children2.keyBoard2.setKey(101,73);
            _loc1_.children2.keyBoard2.setKey(102,74);
            _loc1_.children2.keyBoard2.setKey(104,75);
         }
      }
      
      public function updateKey2Skill() : void
      {
         var _loc1_:UserVO = null;
         if(this.keyBoard2)
         {
            _loc1_ = this;
            if(this.ps == 2)
            {
               _loc1_.keyBoard2.setKey(89,_loc1_.keyBoard.getActionByKey(99));
               _loc1_.keyBoard2.setKey(85,_loc1_.keyBoard.getActionByKey(100));
               _loc1_.keyBoard2.setKey(73,_loc1_.keyBoard.getActionByKey(101));
               _loc1_.keyBoard2.setKey(79,_loc1_.keyBoard.getActionByKey(102));
               _loc1_.keyBoard2.setKey(76,_loc1_.keyBoard.getActionByKey(104));
            }
            else if(this.ps == 1)
            {
               _loc1_.keyBoard2.setKey(99,_loc1_.keyBoard.getActionByKey(89));
               _loc1_.keyBoard2.setKey(100,_loc1_.keyBoard.getActionByKey(85));
               _loc1_.keyBoard2.setKey(101,_loc1_.keyBoard.getActionByKey(73));
               _loc1_.keyBoard2.setKey(102,_loc1_.keyBoard.getActionByKey(79));
               _loc1_.keyBoard2.setKey(104,_loc1_.keyBoard.getActionByKey(76));
            }
         }
      }
      
      public function delKey2() : void
      {
         if(this.keyBoard2)
         {
            try
            {
               this.keyBoard.delKey2();
               this.children.delKey2();
               this.children2.delKey2();
            }
            catch(error:Error)
            {
            }
         }
         this.keyBoard2 = null;
      }
      
      public function destroy() : void
      {
         var _loc1_:int = 0;
         if(this.takeCryStals)
         {
            _loc1_ = 0;
            while(_loc1_ < this.takeCryStals.length)
            {
               this.takeCryStals[_loc1_].destroy();
               _loc1_++;
            }
            this.takeCryStals = null;
         }
         this.father = null;
      }
      
      public function traceProperty() : void
      {
         if(SimpleTextLog.Close)
         {
            return;
         }
         SimpleTextLog.getIns().log2(this.name,"traceProperty ----------------------\nmagRes=" + allmagRes + "\treduceMagDef=" + reduceMagDef + "\nhit=" + allhit + "\tdodge=" + alldodge + "\ncritical=" + allcritical + "\ttoughness=" + alltoughness + "\nhpMax=" + allhpMax + "\tmpMax=" + allmpMax + "\natk=" + allatk + "\tphyDef=" + allphyDef + "\nreHP=" + allreHP + "\tlucky=" + alllucky + "\tguardian=" + allguardian + "\tlevel=" + level + "\nsuckBlood=" + allsuckBlood + " backLash=" + allbackLash + "\nsoulCritical=" + allsoulCritical + " soulAtk=" + allsoulAtk + "\nsoulPhydef=" + allsoulPhydef + " soulToughness=" + allsoulToughness + "\n----------------------------------------------");
      }
      
      public function addZuFuHitV1(param1:BuffVO) : void
      {
         _zufuHitV1.push(param1);
      }
      
      public function removeZuFuHitV1(param1:BuffVO) : void
      {
         var _loc2_:int = _zufuHitV1.indexOf(param1);
         if(_loc2_ > -1)
         {
            _zufuHitV1.splice(_loc2_,1);
         }
      }
      
      public function updateSelfKeySet(param1:Array) : void
      {
         var _loc7_:int = 0;
         var _loc5_:* = 0;
         var _loc3_:int = 0;
         var _loc6_:int = 0;
         _loc7_ = 0;
         var _loc2_:Array = [];
         var _loc4_:Array = [];
         var _loc8_:Array = [71,72,73,74,756];
         _loc7_ = 0;
         while(_loc7_ < _loc8_.length)
         {
            _loc5_ = uint(this.keyBoard.getKeyCodeByAction(_loc8_[_loc7_]));
            _loc6_ = KeySetVO.SKILL_KEY1.indexOf(_loc5_);
            if(_loc6_ == -1)
            {
               _loc6_ = KeySetVO.SKILL_KEY2.indexOf(_loc5_);
            }
            _loc3_ = int(param1[_loc6_]);
            _loc2_.push([_loc5_,_loc3_]);
            if(this.keyBoard.key2)
            {
               _loc5_ = uint(this.keyBoard.getKey2CodeByAction(_loc8_[_loc7_]));
               _loc6_ = KeySetVO.SKILL_KEY1.indexOf(_loc5_);
               if(_loc6_ == -1)
               {
                  _loc6_ = KeySetVO.SKILL_KEY2.indexOf(_loc5_);
               }
               _loc3_ = int(param1[_loc6_]);
               _loc4_.push([_loc5_,_loc3_]);
            }
            _loc7_++;
         }
         _loc7_ = 0;
         while(_loc7_ < _loc2_.length)
         {
            this.keyBoard.setKey(_loc2_[_loc7_][0],_loc2_[_loc7_][1]);
            if(this.keyBoard.key2)
            {
               this.keyBoard.key2.setKey(_loc4_[_loc7_][0],_loc4_[_loc7_][1]);
            }
            _loc7_++;
         }
      }
      
      public function ClearPropertyByFixed() : void
      {
         for(var _loc1_:String in _fixedProperty)
         {
            _fixedProperty[_loc1_] = 0;
         }
      }
      
      public function UpdatePropertyByFixed(param1:Number, param2:String) : void
      {
         if(!_fixedProperty.hasOwnProperty(param2))
         {
            _fixedProperty[param2] = 0;
         }
         param1 = MathUtils.decimal(param1,2);
         _fixedProperty[param2] += param1;
         SimpleTextLog.getIns().log2("UpdatePropertyByFixed=",param1,param2,this[param2],"all=" + this["all" + param2]);
      }
      
      public function GetPropertyByFixed(param1:String) : Number
      {
         if(!_fixedProperty.hasOwnProperty(param1))
         {
            _fixedProperty[param1] = 0;
         }
         return _fixedProperty[param1];
      }
      
      public function copyProperty(param1:Object) : void
      {
         var _loc2_:Array = ["hp","mp","hpMax","mpMax","atk","phyDef","magRes","reduceMagDef","hit","dodge","critical","toughness","lucky","guardian","reHP","reMP","soar","sprint","suckBlood","backLash","soulCritical","soulAtk","soulPhydef","soulToughness"];
         param1.hp = param1.hpMax;
         param1.mp = param1.mpMax;
         for each(var _loc3_:String in _loc2_)
         {
            this[_loc3_] = 0;
            this[_loc3_] = param1[_loc3_];
            if(isNaN(this[_loc3_]))
            {
               this[_loc3_] = 0;
            }
            protectedData.setValue(_loc3_,this[_loc3_]);
         }
      }
   }
}

