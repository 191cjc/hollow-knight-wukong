package models.vo
{
   import com.game.net.vo.AssetVO;
   import com.game.utils.VoBasic;
   import flash.geom.Point;
   import models.configs.CommonConfig;
   
   public class SkillConfigVO extends VoBasic
   {
      
      public static const protectSkill:String = "protectSkill";
      
      public var resources:Vector.<AssetVO>;
      
      public var id:int;
      
      public var name:String;
      
      public var type:uint;
      
      public var targetType:int;
      
      public var sort:int;
      
      public var hitRangeType:int;
      
      public var rangeBehind:int;
      
      public var rangeFront:int;
      
      public var subSkillID:Array;
      
      public var hurt:Number;
      
      public var mpHurt:Number;
      
      public var skillDefault:Number;
      
      public var skillAdd:int;
      
      public var horseSkillAdd:Number;
      
      public var skillCountAdd:Array;
      
      public var attMax:int;
      
      public var attInterval:int;
      
      public var circleSize:int;
      
      public var circleTime:int;
      
      public var effectAppearTime:int;
      
      public var moveSpeed:Number;
      
      public var moveTime:int;
      
      public var moveFrame:int;
      
      public var assetLink:Array;
      
      public var shootFrame:int;
      
      public var shootSpeedX:Number;
      
      public var shootSpeedY:Number;
      
      public var shootTime:Number;
      
      public var slowFrames:Array;
      
      public var summonMonster:int;
      
      public var summonCoord:Point;
      
      public var summonMonsterInherit:int;
      
      public var buffId:Array;
      
      public var BuffID_Old:Array;
      
      public var myBuff:Array;
      
      public var MyBuff_Old:Array;
      
      public var summonBuff:Array;
      
      public var summonBuff_old:Array;
      
      public var buffLevInterval:Array;
      
      public var myBuffLevInterval:Array;
      
      public var summonBuffLevInterval:Array;
      
      public var attackedMoveDir:int;
      
      public var mustShakeFrame:Array;
      
      public var monsterTalkId:Array;
      
      public var talkProbability:Number;
      
      public var consumeXP:int;
      
      public var consumeMP:Array;
      
      public var resourceId:int;
      
      public var cd:Number;
      
      public var stiff:int;
      
      public var priority:int;
      
      public var x:int;
      
      public var y:int;
      
      public var hitSound:Array;
      
      public var addXP:int;
      
      public var sub:SkillConfigVO;
      
      public var subs:Vector.<SkillConfigVO>;
      
      public var parent:SkillConfigVO;
      
      private var _level:int = 1;
      
      public var nowCD:int;
      
      public var hurtHp:int = 0;
      
      public var shakeFrame:int;
      
      public var description:String = "";
      
      public var description1:String = "";
      
      public var targetMove:Point;
      
      public var xml:*;
      
      public var skillScope:Array;
      
      public var gravity:int;
      
      public var arrow:int;
      
      public var skillToward:int;
      
      public var back:Boolean;
      
      public var shootDisDelay:int;
      
      public var shootThrough:int;
      
      public var hurtDelay:Number;
      
      public var hitStartFrame:int;
      
      public var dieSkill:int;
      
      public var heartType:int;
      
      public var protectPoint:int;
      
      public var addXPTotal:int;
      
      public var alone:int;
      
      public var buffLevel:int;
      
      public var awakeSKId:int;
      
      public var awakeSkLev:uint;
      
      public var awakeningId:String = "-1";
      
      public var isAwake:Boolean;
      
      public var closed:Boolean;
      
      public var skySkill:SkillConfigVO;
      
      public var isSkySkill:Boolean;
      
      public var level2:int;
      
      public var JiYiaOnFloor:Boolean;
      
      public var isZhaoHuan:Boolean;
      
      public var isAttOneMan:int = 0;
      
      public var isBati:Boolean;
      
      public var addBuff81:int;
      
      public var buff_add_level:int = 0;
      
      public var arrowDisAngle:int;
      
      public var fadeToAlpha:Boolean;
      
      public var alphaTo1:Number = 0;
      
      public var isCanMove:Boolean = true;
      
      public var noDamge:Boolean;
      
      public var param:String;
      
      public var summonNumMax:int;
      
      public var fixedAssetDir:int;
      
      private var _isSetBuff1:Boolean;
      
      public var suckBloodNum:int;
      
      public var backLashNum:int;
      
      public var suckBloodShare:Array;
      
      public var suckBloodFactor:Number;
      
      public var backLashFactor:Number;
      
      public var isAttack:Boolean;
      
      public var realDamagePercent:Number = 0;
      
      public var realDamageRatio:Number = 0;
      
      public var new_addHurtEffect:Boolean;
      
      public var releaseAddPowerNum:Number;
      
      public var releaseAddPowerSub:Number;
      
      public var releaseAddPowerMin:Number;
      
      public var createOtherBuffByAttackUservo:Boolean;
      
      public var campId:int;
      
      public var addIceValue:int;
      
      public var otherData:Object;
      
      public var parentSkillId:int;
      
      public var canAttackKuilei:Boolean = true;
      
      public var locked:Boolean;
      
      public var zyId:int;
      
      public var layerIndex:int;
      
      public function SkillConfigVO()
      {
         super();
         resources = new Vector.<AssetVO>();
      }
      
      public static function getTest() : SkillConfigVO
      {
         var _loc1_:SkillConfigVO = new SkillConfigVO();
         _loc1_.shootSpeedX = 200;
         _loc1_.arrow = 2;
         _loc1_.targetMove = new Point(0,0);
         return _loc1_;
      }
      
      public function set isSetBuff1(param1:Boolean) : void
      {
         _isSetBuff1 = param1;
      }
      
      public function get isSetBuff1() : Boolean
      {
         return _isSetBuff1;
      }
      
      public function get getRealLevel() : int
      {
         var _loc1_:int = level + this.buff_add_level;
         if(_loc1_ > CommonConfig.skillLevelMax)
         {
            _loc1_ = CommonConfig.skillLevelMax;
         }
         return _loc1_;
      }
      
      public function get level() : int
      {
         return _level;
      }
      
      public function set level(param1:int) : void
      {
         _level = param1;
      }
      
      override public function buildFormXML(param1:XML) : void
      {
         var _loc4_:String = null;
         var _loc6_:int = 0;
         var _loc2_:String = null;
         var _loc3_:Array = null;
         super.buildFormXML(param1);
         this.xml = param1;
         if(!myBuff)
         {
            myBuff = [];
         }
         MyBuff_Old = [];
         this.MyBuff_Old = this.myBuff.concat();
         if(!buffId)
         {
            buffId = [];
         }
         if(buffId)
         {
            this.BuffID_Old = [];
            this.BuffID_Old = this.buffId.concat();
         }
         if(!summonBuff)
         {
            summonBuff = [];
         }
         this.summonBuff_old = this.summonBuff.concat();
         _loc4_ = param1.hitSound.toString();
         this.hitSound = [];
         if(_loc4_.length > 0)
         {
            this.hitSound = _loc4_.split("|");
         }
         if(!this.subSkillID)
         {
            this.subSkillID = [];
         }
         monsterTalkId = param1.MonsterTalkID.toString().split(";");
         var _loc5_:Array = [];
         if(mustShakeFrame)
         {
            _loc6_ = 0;
            while(_loc6_ < mustShakeFrame.length)
            {
               _loc2_ = mustShakeFrame[_loc6_];
               _loc3_ = _loc2_.split("-");
               _loc5_.push({
                  "name":_loc3_[0],
                  "value":_loc3_[1]
               });
               _loc6_++;
            }
            mustShakeFrame.length = 0;
         }
         mustShakeFrame = _loc5_;
         if(isNaN(this.cd))
         {
            cd = 1000;
            _loc4_ = param1.CD.toString();
            if(_loc4_.length > 0)
            {
               this.cd = _loc4_.split(";")[0];
            }
         }
         if(this.skillScope && this.skillScope.length == 2)
         {
            this.skillScope.push(0,0);
         }
         level = 1;
         level2 = 11;
         updateBuff();
         this.nowCD = 0;
      }
      
      public function updateBuff(param1:int = 0, param2:int = -1) : void
      {
         var _loc7_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc3_:int = level + param1 - 1;
         if(_loc3_ >= this.getRealLevel - 1)
         {
            _loc3_ = this.getRealLevel - 1;
         }
         if(param2 != -1)
         {
            _loc3_ = param2;
         }
         _loc7_ = 0;
         while(_loc7_ < myBuff.length)
         {
            if(!myBuffLevInterval)
            {
               throw new Error("myBuffLevInterval=null");
            }
            myBuff[_loc7_] = MyBuff_Old[_loc7_] * 100 + int(_loc3_ / myBuffLevInterval[_loc7_]) + 1;
            _loc7_++;
         }
         _loc4_ = 0;
         while(_loc4_ < buffId.length)
         {
            if(!buffLevInterval)
            {
               throw new Error("buffLevInterval=null");
            }
            if(buffLevInterval[_loc4_] > 0 && buffId[_loc4_] > 0)
            {
               buffId[_loc4_] = BuffID_Old[_loc4_] * 100 + int(_loc3_ / buffLevInterval[_loc4_]) + 1;
            }
            _loc4_++;
         }
         _loc5_ = 0;
         while(_loc5_ < summonBuff.length)
         {
            if(!summonBuff)
            {
               throw new Error("summonBuff=null");
            }
            summonBuff[_loc5_] = summonBuff_old[_loc5_] * 100 + int(_loc3_ / summonBuffLevInterval[_loc5_]) + 1;
            _loc5_++;
         }
         if(this.subs && this.subs.length > 0)
         {
            _loc6_ = 0;
            while(_loc6_ < this.subs.length)
            {
               this.subs[_loc6_].level = this.level;
               this.subs[_loc6_].level2 = this.level + 10;
               this.subs[_loc6_].updateBuff(param1,param2);
               _loc6_++;
            }
         }
      }
      
      public function updateBuffSummonBuff(param1:int = 0, param2:int = -1) : void
      {
         var _loc5_:int = 0;
         var _loc3_:int = level + param1 - 1;
         if(_loc3_ >= this.getRealLevel - 1)
         {
            _loc3_ = this.getRealLevel - 1;
         }
         if(param2 != -1)
         {
            _loc3_ = param2;
         }
         var _loc4_:Array = summonBuff || [];
         _loc5_ = 0;
         while(_loc5_ < _loc4_.length)
         {
            summonBuff[_loc5_] = summonBuff_old[_loc5_] * 100 + int(_loc3_ / summonBuffLevInterval[_loc5_]) + 1;
            _loc5_++;
         }
      }
      
      public function clone() : SkillConfigVO
      {
         var _loc3_:int = 0;
         var _loc1_:SkillConfigVO = null;
         var _loc2_:SkillConfigVO = new SkillConfigVO();
         _loc2_.buildFromObject(this.cloneToObject());
         _loc2_.mustShakeFrame = this.mustShakeFrame;
         _loc2_.subSkillID = this.subSkillID;
         _loc2_.assetLink = this.assetLink;
         _loc2_.skillCountAdd = this.skillCountAdd.concat();
         _loc2_.skillScope = this.skillScope;
         _loc2_.buffId = this.buffId.concat();
         _loc2_.myBuff = this.myBuff.concat();
         _loc2_.myBuffLevInterval = this.myBuffLevInterval != null ? this.myBuffLevInterval.concat() : null;
         _loc2_.buffLevInterval = this.buffLevInterval != null ? this.buffLevInterval.concat() : null;
         _loc2_.MyBuff_Old = MyBuff_Old != null ? this.MyBuff_Old.concat() : null;
         _loc2_.BuffID_Old = BuffID_Old != null ? this.BuffID_Old.concat() : null;
         _loc2_.summonBuff = this.summonBuff != null ? this.summonBuff.concat() : null;
         _loc2_.summonBuff_old = this.summonBuff_old != null ? this.summonBuff_old.concat() : null;
         _loc2_.hitSound = _loc2_.hitSound;
         _loc2_.monsterTalkId = this.monsterTalkId;
         _loc2_.level = this.level;
         _loc2_.subs = new Vector.<SkillConfigVO>();
         _loc3_ = 0;
         while(_loc3_ < this.subs.length)
         {
            _loc1_ = this.subs[_loc3_];
            _loc1_ = _loc1_.clone();
            _loc2_.subs.push(_loc1_);
            _loc1_.parent = _loc2_;
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function updateSub() : void
      {
         updatesuba(this);
      }
      
      private function updatesuba(param1:SkillConfigVO) : void
      {
         var _loc3_:int = 0;
         var _loc2_:SkillConfigVO = null;
         _loc3_ = 0;
         while(_loc3_ < param1.subs.length)
         {
            _loc2_ = param1.subs[_loc3_];
            _loc2_.level = param1.level;
            _loc2_.level2 = param1.level + 10;
            if(_loc2_.id == 1101153 || _loc2_.id == 1101154)
            {
               param1.skySkill = _loc2_;
            }
            try
            {
               _loc2_.updateBuff();
            }
            catch(error:Error)
            {
            }
            if(_loc2_.subs.length > 0)
            {
               updatesuba(_loc2_);
            }
            _loc3_++;
         }
      }
      
      public function updateBuff_add_level(param1:int) : void
      {
         this.buff_add_level = param1;
         updatesuba_add_level(this);
      }
      
      private function updatesuba_add_level(param1:SkillConfigVO) : void
      {
         var _loc3_:int = 0;
         var _loc2_:SkillConfigVO = null;
         try
         {
            param1.updateBuff(0,getRealLevel - 1);
         }
         catch(error:Error)
         {
         }
         _loc3_ = 0;
         while(_loc3_ < param1.subs.length)
         {
            _loc2_ = param1.subs[_loc3_];
            _loc2_.buff_add_level = param1.buff_add_level;
            if(_loc2_.subs.length > 0)
            {
               updatesuba_add_level(_loc2_);
            }
            _loc3_++;
         }
      }
      
      public function getSkillCountAdd(param1:int) : Number
      {
         var _loc2_:Number = Number(this.skillCountAdd[param1 - 1]);
         if(this.skillCountAdd && this.skillCountAdd.length < param1)
         {
            _loc2_ = Number(this.skillCountAdd[this.skillCountAdd.length - 1]);
         }
         if(isNaN(_loc2_))
         {
            _loc2_ = 0;
         }
         return _loc2_;
      }
      
      public function setLevel1() : void
      {
         try
         {
            this.updateBuff(0,0);
         }
         catch(error:Error)
         {
         }
         this._isSetBuff1 = true;
      }
   }
}

