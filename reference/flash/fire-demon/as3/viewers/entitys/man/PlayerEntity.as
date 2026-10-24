package viewers.entitys.man
{
   import com.game.engine.animation.DelayedCall;
   import com.game.engine.battle.interfaces.ICollide;
   import com.game.engine.character.ActionState;
   import com.game.engine.core.GameFrame;
   import com.game.engine.textures.Texture;
   import com.game.engine.utils.BitmapUtils;
   import com.game.engine.utils.SimpleTextLog;
   import com.game.engine.utils.Timer;
   import com.game.net.AssetManager;
   import com.game.utils.Filters;
   import com.game.utils.Vector2D;
   import com.greensock.TweenMax;
   import com.ywxgame.models.manager.EventManager;
   import controllers.battle.gushu.ITakePetRougeLike;
   import dragonBones.Armature;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.filters.GlowFilter;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.media.SoundChannel;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import models.GameEvent;
   import models.ai.AttackSeqSeqNode;
   import models.ai.acs.AwayKjAI;
   import models.ai.acs.JumpAI;
   import models.ai.others.MoveAddBuff;
   import models.ai.others.TuiAI;
   import models.ai.others.XiYing3AI;
   import models.ai.others.XiYingAI;
   import models.configs.CommonConfig;
   import models.constants.ManType;
   import models.managers.BattleModelManager;
   import models.managers.BuffModelManager;
   import models.managers.BuffSceneManager;
   import models.managers.GlobalData;
   import models.managers.ManModelManager;
   import models.managers.ManResourceManager;
   import models.managers.MusicManager;
   import models.managers.ResourceManager;
   import models.managers.SkillDebugModelManager;
   import models.managers.SkillModelManager;
   import models.managers.SoulStoneManager;
   import models.managers.UserModelManager;
   import models.skills.SkillAddBuff;
   import models.skills.SkillBullet;
   import models.skills.SkillBulletAngle;
   import models.skills.SkillBulletCrossRotate;
   import models.skills.SkillBulletFollowTarget;
   import models.skills.SkillBulletFollwSelf;
   import models.skills.SkillBulletLocate;
   import models.skills.SkillBulletLocateTarget;
   import models.skills.SkillBulletLocateTarget2;
   import models.skills.SkillBulletLocateTarget3;
   import models.skills.SkillBulletParabola;
   import models.skills.SkillBulletParabola2;
   import models.skills.SkillChangeDir;
   import models.skills.SkillDown;
   import models.skills.SkillDown2;
   import models.skills.SkillGravity;
   import models.skills.SkillJump;
   import models.skills.SkillMove;
   import models.skills.SkillParam;
   import models.skills.SkillRangeBuff;
   import models.skills.SkillStopMoveX;
   import models.skills.SkillSummon;
   import models.skills.SkillTeleport;
   import models.vo.AttackInfoVO;
   import models.vo.BodyUserData;
   import models.vo.BuffConfigVO;
   import models.vo.BuffVO;
   import models.vo.KeySetVO;
   import models.vo.ManConfigVO;
   import models.vo.MonsterBirthVO;
   import models.vo.MonsterConfigVO;
   import models.vo.ResourceVO;
   import models.vo.RoleConfigVO;
   import models.vo.SkillConfigVO;
   import models.vo.UserVO;
   import models.vo.module.ItemVoManager;
   import models.vo.module.PropVo;
   import models.vo.players.ItemVo;
   import modules.ApplicationFacade;
   import nape.callbacks.InteractionCallback;
   import nape.geom.Vec2;
   import nape.phys.Body;
   import nape.phys.BodyType;
   import nape.shape.Polygon;
   import utils.Physics;
   import viewers.component.AnimationMovieclip;
   import viewers.component.CreateMonsterTrigger;
   import viewers.component.Trigger;
   import viewers.component.WuShuanImage;
   import viewers.container.BattleMap;
   import viewers.entitys.Entity;
   import viewers.entitys.boats.BoatEntity;
   import viewers.entitys.horses.HorseEntity;
   import viewers.entitys.man.enemys.E3027;
   import viewers.entitys.man.skills.ring.TanLanBuffSkill;
   import viewers.entitys.man.skills.ts2.ArrowShenJinStay;
   import viewers.entitys.man.skills.wj2.ArrowStay;
   import viewers.entitys.others.BuffEffectEntity;
   import viewers.entitys.weapons.MagicWeaponEntity;
   
   public class PlayerEntity extends ManEntity implements ICollide
   {
      
      protected var _skillConfigVo:SkillConfigVO;
      
      private var _ab:Bitmap = new Bitmap();
      
      private var _hb:Bitmap = new Bitmap();
      
      private var _isUnbeatable:Boolean;
      
      private var _attackedTotalNum:Dictionary = new Dictionary();
      
      private var _lastAttackTime:Dictionary = new Dictionary();
      
      protected var _attackUserVo:UserVO;
      
      protected var _attackSkillConfigvo:SkillConfigVO;
      
      protected var _attackDirection:int;
      
      private var _AttackInfos:Vector.<AttackInfoVO>;
      
      private var _AttackInfo:AttackInfoVO;
      
      private var _buff_hu_dun:Boolean;
      
      private var _buff_hu_dun_hp:int;
      
      protected var _buff_ba_ti:Boolean;
      
      protected var _buff_ba_ti2:Boolean;
      
      protected var _buff_ba_tis:Vector.<BuffVO> = new Vector.<BuffVO>();
      
      protected var _buff_ba_tins:Vector.<BuffVO> = new Vector.<BuffVO>();
      
      protected var _attackPosition:Vector2D;
      
      private var _actions:Array = [];
      
      private var _attackAniFrame:int;
      
      private var _attackMan:PlayerEntity;
      
      private var _isWuShuan:Boolean;
      
      private var _stiffTimer:Timer;
      
      private var _rec:Rectangle;
      
      protected var _checkShootFrame:int = -1;
      
      protected var _checkMoveFrame:int = -1;
      
      protected var _isShoot:Boolean;
      
      protected var _shootTotalTime:int;
      
      protected var _shootNowTime:int;
      
      protected var _tweeHide:TweenMax;
      
      private var _moveDir:int;
      
      private var _isMove:Boolean;
      
      private var _isReadyCanAI:Boolean;
      
      private var _isCloseAI:Boolean;
      
      private var _buff_fang_shang:BuffVO;
      
      private var _buff_fang_shang151:BuffVO;
      
      private var _buff_fang_shang_:Boolean;
      
      private var _hurtDelayTimer:Timer;
      
      private var _xi_ying2AI:XiYingAI;
      
      private var _xi_ying3AIs:Vector.<XiYing3AI> = new Vector.<XiYing3AI>();
      
      private var _moveAddBuffs:Vector.<MoveAddBuff>;
      
      private var _tuiAI:TuiAI;
      
      protected var _hurtEffectAll:AnimationMovieclip;
      
      protected var _hurtEffectAll2:Armature;
      
      protected var _shootVel:Vec2;
      
      private var _wushuanNowTiem:Number = 0;
      
      protected var _buff_jing_zu:Boolean;
      
      protected var _buff_cheng_mo:Boolean;
      
      private var _isKillBySelf:Boolean;
      
      private var _buff_yuan_xian:Boolean;
      
      private var _buff_addhp_hu_dunVo:BuffVO;
      
      protected var _buff_hu_dun_attackVos:Vector.<BuffVO> = new Vector.<BuffVO>();
      
      private var _isCatchingPet:Boolean;
      
      protected var __test:Boolean = false;
      
      public var hasDamage:int;
      
      private var _deadsend:Boolean;
      
      private var _yyBuffs:Vector.<BuffVO> = new Vector.<BuffVO>();
      
      private var _arrows:Vector.<ArrowStay> = new Vector.<ArrowStay>();
      
      private var _arrowsts:Vector.<ArrowShenJinStay> = new Vector.<ArrowShenJinStay>();
      
      private var _buffs:Vector.<BuffVO> = new Vector.<BuffVO>();
      
      private const ro1:Array = [0,-10,10,-20,20];
      
      private const ro2:Array = [180,190,170,200,150];
      
      private var _stayArrows:Object = {
         -1:[],
         1:[]
      };
      
      private var _inDu:Boolean;
      
      private var _hitWallYunXian:Vector.<BuffVO>;
      
      private var _canReleaseBuff:Boolean;
      
      protected var _attackedSys:Array = [];
      
      public var hurtOneMan:PlayerEntity;
      
      public var hurtOnlyMan:PlayerEntity;
      
      protected var _canNotJumps:Vector.<BuffVO> = new Vector.<BuffVO>();
      
      protected var _canNotMJSBuff:BuffVO;
      
      private var _startJumpPos:Vec2 = Vector2D.getVec2();
      
      protected var _canSkill:Boolean = true;
      
      private var _canWalk:Boolean = true;
      
      private var _attackedSkillArr:Object;
      
      protected var chengMoCount:int;
      
      protected var yunXianCount:int;
      
      public var skillControls:Array = [];
      
      public var skp:SkillParam;
      
      protected var _buff_reverses:Array = [];
      
      protected var _buff_yunxianGravitys:Array = [];
      
      public var hu_dun_buff_canReduceHp:Array = [];
      
      private var _buff_attackedAddBuffs:Array = [];
      
      private var _mustHit:Boolean = false;
      
      protected var _useAttUservo:UserVO;
      
      private var _buff_addhp_hu_dunVo36:BuffVO;
      
      private var _buff_hu_dun_hp36:int;
      
      private var _buff_xi_ying111s:Vector.<BuffVO> = new Vector.<BuffVO>();
      
      private var _currA:AttackInfoVO;
      
      protected var _curSoundChannel:SoundChannel;
      
      protected var _gravMass0Num:int;
      
      private var _zaoXianBuffs:Array;
      
      protected var _needMpBuffs:Array;
      
      protected var _lockSkillAcs:Array;
      
      private var _canChangeProfession:Boolean = true;
      
      protected var _wudiCount:int = 0;
      
      public function PlayerEntity()
      {
         super();
      }
      
      public function get shootVel() : Vec2
      {
         return _shootVel;
      }
      
      public function addBuffs(param1:BuffVO) : void
      {
         _buffs.push(param1);
      }
      
      public function removeBuffs(param1:BuffVO) : void
      {
         var _loc2_:int = _buffs.indexOf(param1);
         if(_loc2_ > -1)
         {
            _buffs.splice(_loc2_,1);
         }
      }
      
      protected function get equipSkillCdObj() : Object
      {
         return this.userVo.getRootUservo().equipSkillCdObj;
      }
      
      public function set canWalk(param1:Boolean) : void
      {
         this._canWalk = param1;
      }
      
      public function get buff_addhp_hu_dunVo() : BuffVO
      {
         return _buff_addhp_hu_dunVo;
      }
      
      public function get buff_addhp_hu_dunVo36() : BuffVO
      {
         return _buff_addhp_hu_dunVo36;
      }
      
      public function get startJumpPos() : Vec2
      {
         return _startJumpPos;
      }
      
      public function get canNotMJSBuff() : BuffVO
      {
         return _canNotMJSBuff;
      }
      
      public function get canReleaseBuff() : Boolean
      {
         return _canReleaseBuff;
      }
      
      public function get hitWallYunXian() : Vector.<BuffVO>
      {
         return _hitWallYunXian;
      }
      
      public function get arrows() : Vector.<ArrowStay>
      {
         return _arrows;
      }
      
      public function get arrowsts() : Vector.<ArrowShenJinStay>
      {
         return _arrowsts;
      }
      
      public function get buff_yuan_xian() : Boolean
      {
         return _buff_yuan_xian;
      }
      
      public function get attackMan() : PlayerEntity
      {
         return _attackMan;
      }
      
      public function get attackUserVo() : UserVO
      {
         return _attackUserVo;
      }
      
      public function set isKillBySelf(param1:Boolean) : void
      {
         _isKillBySelf = param1;
      }
      
      public function get shootNowTime() : int
      {
         return _shootNowTime;
      }
      
      public function get isUnbeatable() : Boolean
      {
         return _isUnbeatable;
      }
      
      public function set isUnbeatable(param1:Boolean) : void
      {
         _isUnbeatable = param1;
      }
      
      public function get isKillBySelf() : Boolean
      {
         return _isKillBySelf;
      }
      
      public function get isReadyCanAI() : Boolean
      {
         if(isSleep)
         {
            return false;
         }
         if(getBuffKongju())
         {
            return false;
         }
         return _isReadyCanAI;
      }
      
      public function set isReadyCanAI(param1:Boolean) : void
      {
         _isReadyCanAI = param1;
      }
      
      public function get isCloseAI() : Boolean
      {
         return _isCloseAI;
      }
      
      public function set isCloseAI(param1:Boolean) : void
      {
         _isCloseAI = param1;
      }
      
      public function get isSleep() : Boolean
      {
         return this.userVo && this.userVo.buff_sleep_on_hurtMan;
      }
      
      public function get skillConfigVo() : SkillConfigVO
      {
         __test;
         _skillConfigVo = getSkillConfigVo(_actionState);
         return _skillConfigVo;
      }
      
      public function getSkillConfigVo(param1:int) : SkillConfigVO
      {
         var _loc2_:SkillConfigVO = null;
         var _loc3_:SkillConfigVO = _manConfigVo.skills[ActionState.getName(param1)];
         if(!_loc3_ && param1 == 101)
         {
            _loc3_ = this.dieSkillConfigVo;
         }
         if(!_loc3_ && param1 == -1)
         {
            _loc3_ = this.manConfigVo.skills["appear"];
         }
         if(_loc3_ && _loc3_.awakeSKId > 0)
         {
            if(_manConfigVo.awakeSkills[ActionState.getName(param1)] == null)
            {
               _loc2_ = SkillModelManager.getIns().getSkillConfigVOByID(_loc3_.awakeSKId).clone();
               _manConfigVo.awakeSkills[ActionState.getName(param1)] = _loc2_;
               _loc2_.isAwake = true;
            }
            _loc2_ = _manConfigVo.awakeSkills[ActionState.getName(param1)];
            _loc2_.level = _loc3_.level;
            _loc2_.level2 = _loc3_.level + 10;
            _loc2_.updateSub();
            if(this.userVo.buff_add_skill_level > 0)
            {
            }
            try
            {
               _loc2_.updateBuff_add_level(this.userVo.buff_add_skill_level);
               _loc2_.updateBuff(this.userVo.buff_add_skill_level);
            }
            catch(error:Error)
            {
            }
            _loc3_ = _loc2_;
         }
         if(_loc3_ && this.userVo && this.userVo.isLuoHan_ChenShi)
         {
            _loc3_.setLevel1();
         }
         else if(_loc3_)
         {
            if(_loc3_.isSetBuff1)
            {
               _loc3_.updateBuff();
               _loc3_.isSetBuff1 = false;
            }
         }
         return _loc3_;
      }
      
      public function get dieSkillConfigVo() : SkillConfigVO
      {
         if(getType() == "monster")
         {
            return _manConfigVo.skills["die"];
         }
         return null;
      }
      
      public function get protectSkillConfigVo() : SkillConfigVO
      {
         if(getType() == "monster")
         {
            return _manConfigVo.skills["protect"];
         }
         return null;
      }
      
      public function canCollide() : Boolean
      {
         return _isDie == false && _deleted == false && _actionState != 0 && _assetDict && Enabled == true && _actionState != -1;
      }
      
      override public function get isHide() : Boolean
      {
         if(this.userVo && this.userVo.buff_hides.length > 0)
         {
            return true;
         }
         return this._isHide;
      }
      
      override public function initialization() : void
      {
         super.initialization();
         _rec = new Rectangle();
         _AttackInfos = new Vector.<AttackInfoVO>();
      }
      
      override public function advanceTime(param1:Number) : void
      {
         var _loc8_:int = 0;
         var _loc4_:BuffVO = null;
         var _loc6_:UserVO = null;
         var _loc3_:int = 0;
         var _loc2_:PlayerEntity = null;
         var _loc5_:Number = NaN;
         var _loc7_:int = 0;
         updatBuffeffectDir();
         if(_hurtDelayTimer)
         {
            if(keyboard)
            {
               keyboard.reset();
            }
            if(keyControl)
            {
               keyControl.reset();
            }
            return;
         }
         if(_body && _isJump && _body.velocity.y > 0)
         {
            toJumpDown();
         }
         if(_hurtEffectAll2)
         {
            _hurtEffectAll2.advanceTime(param1 / 1000);
         }
         super.advanceTime(param1);
         if(deleted || isDie)
         {
            return;
         }
         if(_checkShootFrame != -1)
         {
            if(skillConfigVo && _nowAnimation)
            {
               if(getNowAnimationcurrentFrame() >= _checkShootFrame)
               {
                  _checkShootFrame = -1;
                  onAttShootCheckFrame();
               }
            }
            else
            {
               _checkShootFrame = -1;
            }
         }
         else if(_checkMoveFrame != -1)
         {
            if(skillConfigVo && _nowAnimation)
            {
               if(getNowAnimationcurrentFrame() >= _checkMoveFrame)
               {
                  _checkMoveFrame = -1;
                  onAttMoveCheckFrame();
               }
            }
            else
            {
               _checkMoveFrame = -1;
            }
         }
         if(_isShoot || _isMove)
         {
            _shootNowTime += param1;
            onShootOrMoveing();
            if(_shootNowTime >= _shootTotalTime)
            {
               if(_isShoot)
               {
                  shootEnd();
               }
               else if(_isMove)
               {
                  moveEnd();
               }
            }
         }
         checkHurtData();
         shakeMust();
         createWuShuanEffect(param1);
         createWuDiEffect(param1);
         if(this.getBuffKongju())
         {
            if(this.manConfigVo && currentActionState == 1 && this.getCanAwayKjAi())
            {
               if(!this.awayKjAi || this.awayKjAi && this.awayKjAi.deleted)
               {
                  _loc8_ = 0;
                  while(_loc8_ < this.getBuffKongju().length)
                  {
                     _loc4_ = getBuffKongju()[_loc8_];
                     _loc6_ = _loc4_.attUserVo;
                     if(_loc6_)
                     {
                        _loc3_ = _loc4_.totalTime - _loc4_.time;
                        _loc2_ = BattleModelManager.getIns().getPlayerByEntityId(_loc6_.entitieId) as PlayerEntity;
                        if(!_loc2_ && _loc6_.parent)
                        {
                           _loc2_ = BattleModelManager.getIns().getPlayerByEntityId(_loc6_.parent.entitieId) as PlayerEntity;
                        }
                        if(_loc2_)
                        {
                           _loc5_ = _loc4_.config.attributeV1 * this.userVo.walkSpeed;
                           this.awayKjAi = new AwayKjAI(this,_loc2_,_loc3_,_loc5_);
                        }
                        break;
                     }
                     _loc8_++;
                  }
               }
            }
         }
         if(_moveAddBuffs)
         {
            _loc7_ = 0;
            while(_loc7_ < _moveAddBuffs.length)
            {
               _moveAddBuffs[_loc7_].advanceTime(param1);
               _loc7_++;
            }
         }
         delSkillLock();
         if(false && BattleModelManager.showProtect && _userVo && _manConfigVo)
         {
            _label.text = _userVo.proScore + "/" + _manConfigVo.protectPoint;
         }
      }
      
      private function createWuDiEffect(param1:Number) : void
      {
         if(getNeedWudiEffect())
         {
            if(this.isWudiAction() || this._isUnbeatable || this.userVo.lockHp1 || this._wudiCount > 0)
            {
               this.display.alpha = 0.5;
            }
            else if(this.display.alpha != 1 && !isDie)
            {
               this.display.alpha = 1;
            }
         }
         else if(!_isUnbeatable && this.userVo)
         {
            if(this.display.alpha == 1 && this.userVo.lockHp1)
            {
               this.display.alpha = 0.5;
            }
            if(this.display.alpha == 0.5 && !this.userVo.lockHp1)
            {
               this.display.alpha = 1;
            }
         }
      }
      
      private function updatBuffeffectDir() : void
      {
         var _loc1_:Sprite = null;
         var _loc3_:int = 0;
         var _loc2_:BuffEffectEntity = null;
         if(deleted || isDie)
         {
            return;
         }
         try
         {
            _loc1_ = getDisplayLayer(1);
            _loc3_ = 0;
            while(_loc3_ < _loc1_.numChildren)
            {
               _loc2_ = _loc1_.getChildAt(_loc3_) as BuffEffectEntity;
               if(_loc2_)
               {
                  if(_loc2_.scaleX != this.direction && _loc2_.getDir() == 0)
                  {
                     _loc2_.scaleX = this.direction;
                  }
                  else if(_loc2_.scaleX != 1 && _loc2_.getDir() == 1)
                  {
                     _loc2_.scaleX = 1;
                  }
                  else if(_loc2_.scaleX != -1 && _loc2_.getDir() == -1)
                  {
                     _loc2_.scaleX = -1;
                  }
                  this.onUpdateBuffEffectDir(_loc2_);
               }
               _loc3_++;
            }
         }
         catch(error:Error)
         {
         }
         if(getDisplayLayer(2).scaleX != this.direction)
         {
            getDisplayLayer(2).scaleX = this.direction;
         }
      }
      
      protected function onUpdateBuffEffectDir(param1:BuffEffectEntity) : void
      {
      }
      
      private function createWuShuanEffect(param1:Number) : void
      {
         var _loc3_:Texture = null;
         var _loc5_:WuShuanImage = null;
         var _loc8_:Vector2D = null;
         var _loc2_:int = 0;
         var _loc7_:int = 0;
         var _loc6_:BitmapData = null;
         var _loc4_:Matrix = null;
         if(!userVo || !userVo.isWuShuan || userVo.isDie || deleted)
         {
            return;
         }
         if(this is Trigger || this._inDu == true)
         {
            return;
         }
         if(this.getType() != "role")
         {
            return;
         }
         _wushuanNowTiem += param1;
         if(_wushuanNowTiem >= 200)
         {
            _wushuanNowTiem -= 200;
            _loc3_ = _nowAnimation.getCurrentTexture();
            _loc5_ = new WuShuanImage(_loc3_);
            _loc8_ = this.position.clone();
            if(this._armature && UserModelManager.getIns().isRole(this.userVo.charID))
            {
               _loc2_ = 400;
               _loc7_ = 400;
               if(this is BLMEntity || this is TS2Entity)
               {
                  _loc2_ = 600;
                  _loc7_ = 400;
               }
               else if(this is BLM2Entity)
               {
                  _loc2_ = 700;
                  _loc7_ = 500;
               }
               _loc6_ = new BitmapData(_loc2_,_loc7_,true,0);
               if(this is WKEntity)
               {
                  _loc4_ = this._nowAnimation.transform.matrix.clone();
                  if(_loc4_.b != 0)
                  {
                     _loc4_.tx = _loc6_.width / 2;
                     _loc4_.ty = _loc6_.height / 2;
                     _loc4_.tx += 50 * this.direction;
                     if(this.direction == -1)
                     {
                        _loc4_.tx += 30;
                     }
                  }
                  else
                  {
                     _loc4_ = new Matrix();
                     _loc4_.tx = _loc6_.width / 2;
                     _loc4_.ty = _loc6_.height / 2;
                  }
               }
               else
               {
                  _loc4_ = new Matrix();
                  _loc4_.tx = _loc2_ / 2;
                  _loc4_.ty = _loc7_ / 2;
               }
               _loc6_.draw(_nowAnimation,_loc4_);
               _loc5_.setBd(_loc6_);
               _loc5_.x = _loc8_.x - _loc6_.width / 2 * this.direction;
               _loc5_.y = _loc8_.y - _loc6_.height / 2;
            }
            else
            {
               _loc5_.x = _loc8_.x + _loc3_.pivot.x * this.direction;
               _loc5_.y = _loc8_.y + _loc3_.pivot.y;
            }
            _loc5_.scaleX = this.direction;
            BattleMap.Ins.addChild2(_loc5_);
         }
      }
      
      public function shakeMust() : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc1_:String = null;
         var _loc2_:Point = null;
         if(!skillConfigVo || isDie || deleted)
         {
            return;
         }
         if(!skillConfigVo.mustShakeFrame || skillConfigVo.mustShakeFrame.length == 0)
         {
            return;
         }
         _loc4_ = 0;
         for(; _loc4_ < skillConfigVo.mustShakeFrame.length; _loc4_++)
         {
            _loc1_ = skillConfigVo.mustShakeFrame[_loc4_].name;
            if(this is RoleEntity)
            {
               if(_loc1_ != "r")
               {
                  continue;
               }
            }
            if(this is SkillEntity)
            {
               if(SkillEntity(this).effName != _loc1_)
               {
                  continue;
               }
            }
            _loc3_ = int(skillConfigVo.mustShakeFrame[_loc4_].value);
            if(_nowAnimation && getNowAnimationcurrentFrame() == _loc3_)
            {
               _loc2_ = new Point(_position.x,_position.y);
               ApplicationFacade.getInstance().sendNotification("nfShake",_loc2_);
               _loc2_ = null;
            }
         }
      }
      
      protected function onShootOrMoveing() : void
      {
         if(!skillConfigVo)
         {
            shootEnd();
            return;
         }
         var _loc1_:Vec2 = _body.velocity.copy();
         if(skillConfigVo.shootSpeedY != 0)
         {
            _loc1_.y = skillConfigVo.shootSpeedY;
         }
         if(skillConfigVo.back == true)
         {
            if(this.position.x >= this.screenRange.x + this.screenRange.width - 100)
            {
               reVel(-1);
            }
            else if(this.position.x <= this.screenRange.x + 100)
            {
               reVel(1);
            }
         }
      }
      
      public function reVel(param1:int) : void
      {
         setVelocity(userVo.walkSpeed * param1,0);
      }
      
      private function checkHurtData() : void
      {
         var _loc2_:AttackInfoVO = null;
         var _loc1_:int = 0;
         if(_AttackInfos.length > 0)
         {
            _loc2_ = _AttackInfos.shift();
            _loc2_.from = "t10";
            if(_loc2_.damageValue != 0)
            {
               ApplicationFacade.getInstance().sendNotification("NF_ENTITY_HURT",_loc2_);
               _currA = _loc2_;
               addHurtEffect();
            }
            else if(_loc2_.damageType == 2)
            {
               ApplicationFacade.getInstance().sendNotification("NF_ENTITY_HURT",_loc2_);
            }
            if(_loc2_.didan > 0)
            {
               ApplicationFacade.getInstance().sendNotification("NF_ENTITY_DIDAN",_loc2_);
            }
            if(BattleModelManager.getIns().levelInfo && BattleModelManager.getIns().levelInfo.isPK() == false)
            {
               _loc1_ = BattleModelManager.getIns().calXP(_loc2_.attUserVo,_loc2_.hurUserVo,_loc2_.attSkill,getBuff90V1());
               this.onGetXP(_loc1_);
            }
            if(userVo.type == "role")
            {
               ApplicationFacade.getInstance().sendNotification("nfPlayerInfoChange",this.userVo);
            }
         }
         if(isDie && _AttackInfos.length > 0)
         {
            checkHurtData();
         }
      }
      
      protected function addHurtEffect(param1:int = -60) : void
      {
         var _loc3_:Entity = null;
         if(this.userVo.configVo.typeId == 400101)
         {
            param1 = -30;
         }
         if(_hurtEffectAll)
         {
            return;
         }
         var _loc2_:Class = AssetManager.getIns().getClass("mission","hurtEffectAll");
         if(_loc2_ != null)
         {
            _hurtEffectAll = new AnimationMovieclip(_loc2_,false);
            _hurtEffectAll.y = param1;
            _display.addChild(_hurtEffectAll);
            _hurtEffectAll.addEventListener("complete",onHurtEffectAllComplete);
         }
         if(_currA && _currA.attSkill && _currA.attSkill.new_addHurtEffect)
         {
            _loc3_ = BattleModelManager.getIns().getPlayerByEntityId(_currA.attUserVo.entitieId);
            if(_loc3_)
            {
               this.addHurtEffect2(_loc3_.getHurtEffect(),param1);
               if(_hurtEffectAll)
               {
                  _hurtEffectAll.visible = false;
               }
            }
         }
      }
      
      protected function onHurtEffectAllComplete(param1:Event) : void
      {
         _hurtEffectAll.removeEventListener("complete",onHurtEffectAllComplete);
         _hurtEffectAll = null;
      }
      
      override protected function addHurtEffect2(param1:Armature, param2:int = -60) : void
      {
         if(_hurtEffectAll2)
         {
            return;
         }
         var _loc3_:int = 0;
         if(RoleConfigVO(this.manConfigVo) && RoleConfigVO(this.manConfigVo).locateCenter)
         {
            _loc3_ = int(RoleConfigVO(this.manConfigVo).locateCenter.x);
            param2 = int(RoleConfigVO(this.manConfigVo).locateCenter.y);
         }
         param1.display.x = _loc3_;
         param1.display.y = param2;
         _hurtEffectAll2 = param1;
         _hurtEffectAll2.addEventListener("complete",onHurtEffectAll2Complete);
         this._display.addChild(param1.display as DisplayObject);
      }
      
      protected function onHurtEffectAll2Complete(param1:Event) : void
      {
         try
         {
            this._display.removeChild(_hurtEffectAll2.display as DisplayObject);
         }
         catch(error:Error)
         {
         }
         _hurtEffectAll2.removeEventListener("complete",onHurtEffectAll2Complete);
         _hurtEffectAll2.dispose();
         _hurtEffectAll2 = null;
      }
      
      public function collided(param1:ICollide, param2:ICollide) : void
      {
         var _loc13_:WKEntity = null;
         var _loc7_:int = 0;
         var _loc8_:Array = null;
         _loc7_ = 0;
         var _loc3_:Number = NaN;
         var _loc11_:int = 0;
         var _loc9_:BuffVO = null;
         if(param2 != this)
         {
            return;
         }
         _attackMan = param1 as PlayerEntity;
         _attackUserVo = PlayerEntity(param1).getAttUserVo() || PlayerEntity(param1).userVo;
         _attackSkillConfigvo = PlayerEntity(param1).skillConfigVo;
         _attackDirection = PlayerEntity(param1).direction;
         _attackPosition = PlayerEntity(param1).position;
         if(!CollideBeforeCan() || !_attackSkillConfigvo)
         {
            return;
         }
         if(_attackSkillConfigvo.skySkill != null)
         {
            _loc13_ = BattleModelManager.getIns().getPlayerByEntityId(_attackUserVo.entitieId) as WKEntity;
            if(this._onGround == false || _loc13_ && GlobalData.getIsRelease619() && _loc13_.onGround == false)
            {
               _attackSkillConfigvo = _attackSkillConfigvo.skySkill;
               _attackSkillConfigvo.isSkySkill = true;
            }
         }
         if(_attackSkillConfigvo.noDamge)
         {
            return;
         }
         if(_attackSkillConfigvo.sort == 4)
         {
            if(this._attackSkillConfigvo.buffId)
            {
               if(this.getType() != ManType.SKILL || this.canReleaseBuff)
               {
                  createOtherBuff(_attackUserVo,this.userVo,_attackSkillConfigvo);
               }
            }
            if(this._attackSkillConfigvo.alone == 1)
            {
               setAttackedTotalNum(_attackUserVo.entitieId + "_" + _attackMan.Id,_attackSkillConfigvo.isSkySkill ? _attackSkillConfigvo.parent.id : _attackSkillConfigvo.id,1);
            }
            else if(this._attackSkillConfigvo.alone == 11)
            {
               setAttackedTotalNum("alone11_" + _attackUserVo.entitieId + "_" + _attackMan.Id,_attackSkillConfigvo.isSkySkill ? _attackSkillConfigvo.parent.id : _attackSkillConfigvo.id,1);
            }
            else
            {
               setAttackedTotalNum(_attackUserVo.entitieId.toString(),_attackSkillConfigvo.isSkySkill ? _attackSkillConfigvo.parent.id : _attackSkillConfigvo.id,1);
            }
            return;
         }
         _attackAniFrame = PlayerEntity(param1).getAnimationCurrentFrame();
         if(_attackSkillConfigvo.isAttOneMan > 0)
         {
            _attackMan.hurtOneMan = this;
         }
         var _loc12_:int = BattleModelManager.getIns().getGameTimer();
         if(_loc12_ - userVo.lastHurtedTime >= 3000)
         {
            userVo.proScore = 0;
         }
         var _loc4_:Boolean = _attackSkillConfigvo.zyId > 0;
         if(this.userVo.buff_protected != null && !_loc4_)
         {
            BuffModelManager.getIns().createBuff([this.userVo.buff_protected.config.attributeV1,this.userVo.buff_protected.config.attributeV2],null,0,_attackUserVo);
         }
         if(this.userVo.buff411_protected && this.userVo.buff411_protected.length > 0 && !_loc4_)
         {
            _loc7_ = 0;
            while(_loc7_ < this.userVo.buff411_protected.length)
            {
               BuffModelManager.getIns().createBuff([this.userVo.buff411_protected[_loc7_].config.attributeV1],null,1,this.userVo);
               _loc7_++;
            }
            _loc8_ = this.userVo.buff411_protected.concat();
            _loc7_ = 0;
            while(_loc7_ < _loc8_.length)
            {
               BuffModelManager.getIns().del(_loc8_[_loc7_]);
               _loc7_++;
            }
         }
         if(this.userVo.buff_create_hurt_hasDamage != null && !_loc4_)
         {
            BuffModelManager.getIns().createBuff([this.userVo.buff_create_hurt_hasDamage.config.attributeV1,this.userVo.buff_create_hurt_hasDamage.config.attributeV2],null,0,this.userVo);
         }
         if(_isUnbeatable || _attackSkillConfigvo.level < 0 || isWudiAction())
         {
            if(_attackSkillConfigvo && this._attackSkillConfigvo.buffId && _attackSkillConfigvo.level == -2)
            {
               if(this.getType() != ManType.SKILL || this.canReleaseBuff)
               {
                  createOtherBuff(_attackUserVo,this.userVo,_attackSkillConfigvo);
                  if(this._attackSkillConfigvo.alone == 1)
                  {
                     setAttackedTotalNum(_attackUserVo.entitieId + "_" + _attackMan.Id,_attackSkillConfigvo.isSkySkill ? _attackSkillConfigvo.parent.id : _attackSkillConfigvo.id,1);
                  }
                  if(this._attackSkillConfigvo.alone == 11)
                  {
                     setAttackedTotalNum("alone11_" + _attackUserVo.entitieId + "_" + _attackMan.Id,_attackSkillConfigvo.isSkySkill ? _attackSkillConfigvo.parent.id : _attackSkillConfigvo.id,1);
                  }
                  else
                  {
                     setAttackedTotalNum(_attackUserVo.entitieId.toString(),_attackSkillConfigvo.isSkySkill ? _attackSkillConfigvo.parent.id : _attackSkillConfigvo.id,1);
                  }
               }
            }
            return;
         }
         if(this.userVo.buff_protected_hasDamage != null && !_loc4_)
         {
            BuffModelManager.getIns().createBuff([this.userVo.buff_protected_hasDamage.config.attributeV1,this.userVo.buff_protected_hasDamage.config.attributeV2],null,0,_attackUserVo);
         }
         if(this.userVo.buff_create_hurt != null && !_loc4_)
         {
            BuffModelManager.getIns().createBuff([this.userVo.buff_create_hurt.config.attributeV1,this.userVo.buff_create_hurt.config.attributeV2],null,0,this.userVo);
         }
         var _loc6_:Array = this.getBuff142();
         if(_loc6_ && _attackUserVo)
         {
            _loc3_ = 0;
            _loc11_ = 0;
            while(_loc11_ < _loc6_.length)
            {
               _loc9_ = _loc6_[_loc11_][0];
               if(!(_loc9_.currCd != 0 && GameFrame.time - _loc9_.currCd < _loc9_.config.cd))
               {
                  if(_attackUserVo.entitieId == _loc9_.attUserVo.entitieId)
                  {
                     _loc3_ += _loc9_.attUserVo.hp * _loc9_.config.attributeV1 + _loc9_.config.attributeV3;
                  }
                  else
                  {
                     _loc3_ += _loc9_.attUserVo.hp * _loc9_.config.attributeV2 + _loc9_.config.attributeV3;
                  }
               }
               _loc11_++;
            }
            if(_loc3_ > 0)
            {
               this._attackUserVo.updateHP(_loc3_,false);
               ApplicationFacade.getInstance().sendNotification("nfEntityHurtAuto",{
                  "userVo":this._attackUserVo,
                  "hp":_loc3_,
                  "from":"getBuff142"
               });
            }
         }
         _additionalVelocity.setxy(0,0);
         if(_buff_xi_ying)
         {
            BuffModelManager.getIns().del(_buff_xi_ying);
         }
         _buff_xi_ying = null;
         if(_attackSkillConfigvo.hurtDelay > 0 && getIsBaTi() == false)
         {
            if(_buff_ba_ti2)
            {
               onHurt();
            }
            else
            {
               if(_hurtDelayTimer)
               {
                  _hurtDelayTimer.destroy();
                  _hurtDelayTimer = null;
               }
               _hurtDelayTimer = new Timer(onHurtByDelay,_attackSkillConfigvo.hurtDelay);
               _hurtDelayTimer.start();
               GameFrame.juggler.remove(this._nowAnimation);
               if(_body)
               {
                  _body.allowMovement = false;
                  updateBodyVelocity(new Vec2(0,0));
               }
            }
         }
         else
         {
            onHurt();
         }
         _attackIndex = 0;
         checkHurtData();
         userVo.lastHurtedTime = BattleModelManager.getIns().getGameTimer();
         var _loc10_:String = ResourceManager.getIns().getAssetURLByName("sound");
         var _loc5_:String = "hit";
         MusicManager.getIns().playSoundEffect(_loc10_,_loc5_);
         if(this.getType() == "role")
         {
            _loc5_ = ActionState.getName(_actionState);
            playSound(_loc5_);
            createEquChi();
         }
         checkGaiLiHurt();
      }
      
      protected function CollideBeforeCan() : Boolean
      {
         return true;
      }
      
      private function onHurtByDelay() : void
      {
         if(isDie || deleted)
         {
            return;
         }
         GameFrame.juggler.add(this._nowAnimation);
         if(_body)
         {
            _body.allowMovement = true;
         }
         _hurtDelayTimer.destroy();
         _hurtDelayTimer = null;
         onHurt();
      }
      
      protected function onHurt() : void
      {
         var _loc22_:RoleEntity = null;
         var _loc38_:Array = null;
         var _loc20_:AttackInfoVO = null;
         var _loc52_:Number = NaN;
         var _loc44_:Number = NaN;
         var _loc60_:int = 0;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc26_:int = 0;
         var _loc54_:Number = NaN;
         var _loc64_:* = null;
         var _loc49_:Object = null;
         _loc60_ = 0;
         var _loc42_:BuffVO = null;
         var _loc39_:MagicWeaponEntity = null;
         var _loc65_:MagicWeaponEntity = null;
         _loc60_ = 0;
         _loc42_ = null;
         var _loc45_:RoleEntity = null;
         var _loc3_:SkillConfigVO = null;
         var _loc56_:int = 0;
         var _loc15_:BuffVO = null;
         var _loc58_:int = 0;
         var _loc17_:BuffVO = null;
         var _loc28_:int = 0;
         var _loc31_:Number = NaN;
         var _loc1_:int = 0;
         var _loc55_:int = 0;
         var _loc62_:Number = NaN;
         _loc22_ = null;
         _loc64_ = null;
         var _loc53_:Array = null;
         var _loc29_:int = 0;
         var _loc46_:int = 0;
         _loc53_ = null;
         var _loc41_:Array = null;
         var _loc24_:Array = null;
         var _loc57_:int = 0;
         var _loc33_:UserVO = null;
         var _loc51_:BuffVO = null;
         var _loc43_:Number = NaN;
         _loc44_ = NaN;
         var _loc48_:int = 0;
         var _loc9_:Number = NaN;
         var _loc36_:int = 0;
         var _loc6_:int = 0;
         var _loc19_:Entity = null;
         var _loc8_:Array = null;
         var _loc4_:Number = NaN;
         _loc8_ = null;
         _loc4_ = NaN;
         var _loc35_:UserVO = null;
         var _loc61_:int = 0;
         _loc19_ = null;
         _loc8_ = null;
         _loc4_ = NaN;
         _loc8_ = null;
         _loc4_ = NaN;
         _loc35_ = null;
         var _loc16_:int = 0;
         var _loc2_:Number = NaN;
         var _loc25_:Array = null;
         _loc22_ = null;
         if(isDie || deleted)
         {
            return;
         }
         if(userVo)
         {
            userVo.isCatchingPet = false;
         }
         var _loc30_:int = _attackSkillConfigvo.sort;
         var _loc32_:Boolean = true;
         if(_loc30_ == 2 || _loc30_ == 3 || _loc30_ == 4)
         {
            _loc32_ = false;
         }
         if(this._attackSkillConfigvo.alone == 1)
         {
            setAttackedTotalNum(_attackUserVo.entitieId + "_" + _attackMan.Id,_attackSkillConfigvo.isSkySkill ? _attackSkillConfigvo.parent.id : _attackSkillConfigvo.id,1);
         }
         if(this._attackSkillConfigvo.alone == 11)
         {
            setAttackedTotalNum("alone11_" + _attackUserVo.entitieId + "_" + _attackMan.Id,_attackSkillConfigvo.isSkySkill ? _attackSkillConfigvo.parent.id : _attackSkillConfigvo.id,1);
         }
         else
         {
            setAttackedTotalNum(_attackUserVo.entitieId.toString(),_attackSkillConfigvo.isSkySkill ? _attackSkillConfigvo.parent.id : _attackSkillConfigvo.id,1);
         }
         this._attackUserVo.nowSkillHit++;
         addMaskEff();
         _AttackInfo = new AttackInfoVO();
         _AttackInfo.floating = 0;
         _AttackInfo.parameter = "";
         _AttackInfo.direction = _attackDirection;
         _AttackInfo.damageType = 0;
         _AttackInfo.attUserVo = _attackUserVo;
         _AttackInfo.hurUserVo = this.userVo;
         _AttackInfo.attSkill = _attackSkillConfigvo;
         _AttackInfo.hurUserVo = this.userVo;
         _AttackInfo.pos = this.display.localToGlobal(new Point(0,-120));
         if(_attackSkillConfigvo && _attackUserVo)
         {
            _AttackInfo.ind = this.getAttackedTotalNum(_attackUserVo.entitieId.toString(),_attackSkillConfigvo.isSkySkill ? _attackSkillConfigvo.parent.id : _attackSkillConfigvo.id);
            _loc22_ = BattleModelManager.getIns().getPlayerByEntityId(_attackUserVo.entitieId) as RoleEntity;
            if(_loc22_)
            {
               _loc38_ = _loc22_.getAttackedAddBuffs1();
               if(_loc38_ && _loc38_.length > 0)
               {
                  BuffModelManager.getIns().createBuff(_loc38_,[],1,this.userVo,_attackUserVo);
               }
            }
         }
         onSetAttackInfo(_AttackInfo);
         var _loc63_:int = 0;
         var _loc50_:Number = 0;
         var _loc21_:String = userVo.lastHurtedTime.toString();
         if(BattleModelManager.checkDodge(this.userVo) && _loc32_)
         {
            _loc52_ = BattleModelManager.calDodge(_attackUserVo,userVo);
            if(_loc52_ < 1)
            {
               _loc44_ = BattleModelManager.getIns().getRandom("playerEntity-1291");
               if(_loc44_ > _loc52_)
               {
                  _AttackInfo.damageType = 2;
                  _AttackInfo.damageValue = 0;
                  BattleModelManager.getIns().addHurtManData(_AttackInfo);
                  _AttackInfos.push(_AttackInfo);
                  return;
               }
            }
         }
         var _loc5_:Array = SoulStoneManager.getIns().getHurtByPlayerId(this.Id);
         _loc60_ = 0;
         while(_loc60_ < _loc5_.length)
         {
            _loc5_[_loc60_].ToTrigger();
            _loc60_++;
         }
         var _loc37_:Boolean = false;
         if(BattleModelManager.getIns().checkBaoJi(_attackUserVo) && !_buff_hu_dun && _loc32_ && hasHunDun() == false)
         {
            _loc13_ = BattleModelManager.getIns().calBaoJi(_attackUserVo,userVo);
            if(BattleModelManager.showBaoJi == false)
            {
               _loc13_ = 0;
            }
            _loc14_ = BattleModelManager.getIns().getRandom("playerEntity-1322");
            if(_loc14_ < _loc13_)
            {
               _loc63_ = BattleModelManager.getIns().calBaoJiDamage(_attackUserVo,userVo,_attackSkillConfigvo,_attackSkillConfigvo.type);
               _loc63_ = onCalDamage(_loc63_,null,null);
               _attackUserVo.baoJiNum++;
               _AttackInfo.damageType = 1;
               _loc37_ = true;
            }
         }
         if(_loc63_ == 0 && _loc32_)
         {
            _loc63_ += BattleModelManager.getIns().calDamage(this._attackSkillConfigvo.type,this._attackUserVo,this.userVo,this._attackSkillConfigvo,1,"normal");
            _loc63_ = onCalDamage(_loc63_,null,null);
            _AttackInfo.damageType = 0;
         }
         var _loc23_:RoleEntity = BattleModelManager.getIns().getPlayerByEntityId(_attackUserVo.entitieId) as RoleEntity;
         if(_loc23_)
         {
            _loc63_ = _loc23_.calDamageBySkillIdRatio(_loc63_,this._attackSkillConfigvo,this.userVo);
            _loc63_ = _loc23_.calDamageBySkillIdRatio2(_loc63_,this._attackSkillConfigvo,this.userVo,attackMan);
         }
         var _loc18_:Number = _attackSkillConfigvo.realDamagePercent + this._attackUserVo.getBuffProperty("realDamagePercent");
         _loc63_ *= 1 - _loc18_;
         if(_loc18_ > 0)
         {
            _loc12_ = Math.min(1 + this._attackUserVo.alllucky / 500,1.34);
            if(SkillDebugModelManager.average)
            {
               _loc12_ = 0.5 * (_loc12_ - 1) + 1;
            }
            else
            {
               _loc12_ = (_loc12_ - 1) * BattleModelManager.getIns().getRandom("playerEntity-1385") + 1;
            }
            _loc26_ = Math.min(_attackSkillConfigvo.getRealLevel,CommonConfig.skillAddMax) - 1;
            _loc54_ = _attackSkillConfigvo.skillDefault + _attackSkillConfigvo.skillAdd * _loc26_ + _attackSkillConfigvo.horseSkillAdd * _loc26_;
            _loc50_ = _loc18_ * this._attackUserVo.allatk * _loc12_ * _loc54_ * (_attackSkillConfigvo.realDamageRatio + this._attackUserVo.getBuffProperty("realDamageRatio"));
            if(_loc23_)
            {
               _loc50_ = _loc23_.calDamageBySkillIdRatio2_real(_loc50_,this._attackSkillConfigvo,this.userVo,attackMan);
            }
            if(_loc37_)
            {
               _loc50_ *= 1 + BattleModelManager.getIns().getBaoJiAdd(_attackUserVo,userVo);
            }
            _loc50_ = int(_loc50_);
            if(_loc50_ < 1)
            {
               _loc50_ = 1;
            }
            if(_loc50_ < 0)
            {
               _loc50_ = 0;
            }
            if(_loc50_ > 0)
            {
               _loc20_ = new AttackInfoVO();
               _loc20_.floating = 0;
               _loc20_.parameter = "";
               _loc20_.direction = _attackDirection;
               _loc20_.damageType = _loc37_ ? 4 : 3;
               _loc20_.attUserVo = _attackUserVo;
               _loc20_.hurUserVo = this.userVo;
               _loc20_.attSkill = _attackSkillConfigvo;
               _loc20_.hurUserVo = this.userVo;
               _loc20_.pos = this.display.localToGlobal(new Point(0,-120));
               _loc20_.damageValue = _loc50_;
            }
            if(!SimpleTextLog.Close)
            {
               SimpleTextLog.getIns().log2("部分真实伤害s2=",_loc50_,"s=" + _loc63_,"skillAddr=" + _loc54_,"_attackSkillConfigvo.skillAdd,minSkillAddMax ,_attackSkillConfigvo.horseSkillAdd",_attackSkillConfigvo.skillAdd,_loc26_,_attackSkillConfigvo.horseSkillAdd);
            }
         }
         _loc63_ = this.onHurtCalDamageAfter(_loc63_,this._attackSkillConfigvo,_attackMan,_attackUserVo);
         var _loc59_:Array = this.getBuff92();
         if(_loc59_ && _attackUserVo)
         {
            _loc49_ = {};
            _loc60_ = 0;
            while(_loc60_ < _loc59_.length)
            {
               _loc42_ = _loc59_[_loc60_];
               _loc49_[_loc42_.attUserVo.entitieId] = _loc42_.attUserVo.entitieId;
               _loc60_++;
            }
            for each(var _loc27_:Number in _loc49_)
            {
               _loc39_ = BattleModelManager.getIns().getOtherByEId(_loc27_) as MagicWeaponEntity;
               if(_loc39_)
               {
                  _loc39_.ToSkill(72,this);
               }
            }
            if(_attackUserVo.isMagic && !_loc23_)
            {
               _loc65_ = BattleModelManager.getIns().getOtherByEId(_attackUserVo.entitieId) as MagicWeaponEntity;
               if(_loc65_)
               {
                  _loc50_ = _loc65_.calDamageByBuff92(_loc50_,this);
                  if(_loc20_ && _loc50_ > 0)
                  {
                     _loc20_.damageValue = _loc50_;
                  }
               }
            }
            if(!SimpleTextLog.Close)
            {
               SimpleTextLog.getIns().log2("最终部分真实伤害s2=",_loc50_,"s=" + _loc63_);
            }
         }
         var _loc10_:Array = this.getBuff107TanLan();
         if(_loc10_ && _attackUserVo)
         {
            _loc60_ = 0;
            while(_loc60_ < _loc10_.length)
            {
               _loc42_ = _loc10_[_loc60_];
               if(!(_loc42_.children && _loc42_.children.length < _loc42_.config.stackMax - 1))
               {
                  if(_attackUserVo.entitieId == _loc42_.attUserVo.entitieId)
                  {
                     _loc45_ = BattleModelManager.getIns().getPlayerByEntityId(_loc42_.attUserVo.entitieId) as RoleEntity;
                     if(_loc45_)
                     {
                        _loc3_ = SkillModelManager.getIns().getSkillConfigVOByID(_loc42_.config.attributeV1);
                        new TanLanBuffSkill(_loc45_,this,_loc3_);
                        BuffModelManager.getIns().del(_loc42_);
                     }
                  }
               }
               _loc60_++;
            }
         }
         var _loc40_:int = 0;
         if(_buff_hu_dun)
         {
            _buff_hu_dun_hp -= _loc63_;
            if(_buff_hu_dun_hp > 0)
            {
               _loc40_ += _loc63_;
               _loc63_ = 0;
            }
            else
            {
               _loc40_ += _loc63_ - Math.abs(_buff_hu_dun_hp);
               _loc63_ = Math.abs(_buff_hu_dun_hp);
               _buff_hu_dun = false;
               _buff_hu_dun_hp = 0;
               if(_buff_addhp_hu_dunVo)
               {
                  _buff_addhp_hu_dunVo.totalTime = 0;
                  BuffModelManager.getIns().del(_buff_addhp_hu_dunVo);
               }
            }
         }
         if(_loc63_ > 0)
         {
            if(_buff_hu_dun_hp36 > 0)
            {
               _buff_hu_dun_hp36 -= _loc63_;
               if(_buff_hu_dun_hp36 >= 0)
               {
                  _loc40_ += _loc63_;
                  _loc63_ = 0;
               }
               else
               {
                  _loc40_ += _loc63_ - Math.abs(_buff_hu_dun_hp36);
                  _loc63_ = Math.abs(_buff_hu_dun_hp36);
                  _buff_hu_dun_hp36 = 0;
                  if(_buff_addhp_hu_dunVo36)
                  {
                     _buff_addhp_hu_dunVo36.totalTime = 0;
                     BuffModelManager.getIns().del(_buff_addhp_hu_dunVo36);
                  }
               }
            }
         }
         if(this._buff_hu_dun_attackVos.length > 0)
         {
            _loc56_ = 0;
            while(_loc56_ < this._buff_hu_dun_attackVos.length)
            {
               _loc15_ = this._buff_hu_dun_attackVos[_loc56_];
               _loc15_.hudun[0] = _loc15_.hudun[0] - _loc63_;
               if(_loc15_.hudun[0] >= 0)
               {
                  _loc40_ += _loc63_;
                  _loc63_ = 0;
                  break;
               }
               _loc40_ += _loc63_ - Math.abs(_loc15_.hudun[0]);
               _loc63_ = Math.abs(_loc15_.hudun[0]);
               _loc15_.totalTime = 0;
               BuffModelManager.getIns().del(_loc15_);
               _loc56_++;
            }
         }
         if(this.hu_dun_buff_canReduceHp.length > 0)
         {
            _loc58_ = 0;
            while(_loc58_ < this.hu_dun_buff_canReduceHp.length)
            {
               _loc17_ = this.hu_dun_buff_canReduceHp[_loc58_];
               _loc17_.value = _loc17_.value - _loc63_;
               if(_loc17_.value >= 0)
               {
                  _loc40_ += _loc63_;
                  _loc63_ = 0;
                  break;
               }
               _loc40_ += _loc63_ - Math.abs(_loc17_.value);
               _loc63_ = Math.abs(_loc17_.value);
               _loc17_.totalTime = 0;
               BuffModelManager.getIns().del(_loc17_);
               _loc58_++;
            }
         }
         if(_loc63_ > 0)
         {
            if(userVo && userVo.takePetRougeLike)
            {
               _loc28_ = 0;
               while(_loc28_ < userVo.takePetRougeLike.length)
               {
                  _loc31_ = 0;
                  _loc31_ = _loc31_ + ITakePetRougeLike(userVo.takePetRougeLike[_loc28_]).getExtraHp();
                  if(_loc31_ > 0)
                  {
                     _loc31_ -= _loc63_;
                     if(_loc31_ >= 0)
                     {
                        ITakePetRougeLike(userVo.takePetRougeLike[_loc28_]).addExtraHp(-_loc63_);
                        _loc40_ += _loc63_;
                        _loc63_ = 0;
                        break;
                     }
                     ITakePetRougeLike(userVo.takePetRougeLike[_loc28_]).addExtraHp(-_loc31_);
                     _loc40_ += _loc63_ - Math.abs(_loc31_);
                     _loc63_ = Math.abs(_loc31_);
                  }
                  _loc28_++;
               }
            }
         }
         var _loc11_:Number = SoulStoneManager.getIns().gethuDunByPlayerId(this.Id);
         if(_loc11_ > 0)
         {
            _loc1_ = _loc63_;
            _loc63_ = SoulStoneManager.getIns().calhuDunByPlayerId(this.Id,_loc63_);
            _loc40_ += _loc1_ - _loc63_;
         }
         _attackMan;
         _loc63_ = this.userVo.calRealReducehp(_loc63_,true);
         if(_loc63_ != 0)
         {
            _loc63_ = checkBuff113(_loc63_);
            this.userVo.updateHP(-_loc63_,false);
            this.onDamage(-_loc63_);
         }
         if(_loc50_ > 0)
         {
            _loc50_ = this.userVo.calRealReducehp(_loc50_,true);
            _loc50_ = checkBuff113(_loc50_);
            if(_loc20_ && _loc50_ > 0)
            {
               _loc20_.damageValue = _loc50_;
            }
            this.userVo.updateHP(-_loc50_,false);
            this.onDamage(-_loc50_);
         }
         _loc21_ = "s=" + _loc63_;
         if(_loc37_)
         {
            _loc21_ += "暴";
         }
         this.userVo.mp -= _attackSkillConfigvo.mpHurt;
         _AttackInfo.damageValue = _loc63_;
         _AttackInfo.didan = _loc40_;
         if(_attackMan)
         {
            if(_attackMan.skp && _attackMan.skp.attackedRemoveBuffs && _attackMan.skp.attackedRemoveBuffs.length > 0)
            {
               _loc55_ = 0;
               while(_loc55_ < _attackMan.skp.attackedRemoveBuffs.length)
               {
                  _loc62_ = Number(_attackMan.skp.attackedRemoveBuffs[_loc55_]);
                  BuffModelManager.getIns().delByconfigId(this.userVo.entitieId,_loc62_);
                  _loc55_++;
               }
            }
            _loc22_ = BattleModelManager.getIns().getPlayerByEntityId(_attackUserVo.entitieId) as RoleEntity;
            if(_loc22_)
            {
               _loc22_.hasDamage = _loc63_;
               _loc22_.attacked(this,_loc63_,_attackSkillConfigvo);
               if(_attackMan.Id != _loc22_.Id)
               {
                  _attackMan.hasDamage = _loc63_;
                  _attackMan.attacked(this,_loc63_);
               }
            }
            else
            {
               _attackMan.hasDamage = _loc63_;
               _attackMan.attacked(this,_loc63_);
            }
            if(_loc22_)
            {
               _loc53_ = _loc22_.getPetBuffs();
               _loc29_ = 0;
               while(_loc29_ < _loc53_.length)
               {
                  _loc46_ = int(_loc53_[_loc29_]);
                  if(_loc46_ > 0)
                  {
                     BuffModelManager.getIns().createBuff([_loc46_],[],1,this.userVo);
                  }
                  _loc29_++;
               }
               _loc53_ = _loc22_.getAttackedAddBuffs();
               if(_loc53_ && _loc53_.length > 0)
               {
                  BuffModelManager.getIns().createBuff(_loc53_,[],1,this.userVo,_attackUserVo);
               }
               _loc41_ = _loc22_.getAttackedAddBuffs2();
               if(_loc41_ && _loc41_.length > 0)
               {
                  BuffModelManager.getIns().createBuff(_loc41_,[],1,_attackUserVo);
               }
               if(_loc37_)
               {
                  _loc24_ = BuffModelManager.getIns().getManBuffsByType(_attackUserVo.entitieId,94);
                  _loc57_ = 0;
                  while(_loc57_ < _loc24_.length)
                  {
                     _loc33_ = BuffVO(_loc24_[_loc57_]).attUserVo;
                     if(!_loc33_.otherData)
                     {
                        _loc33_.otherData = {};
                     }
                     if(!_loc33_.otherData.hasOwnProperty("xindong"))
                     {
                        _loc33_.otherData.xindong = 0;
                     }
                     _loc33_.otherData.xindong += Math.abs(_loc63_);
                     _loc57_++;
                  }
               }
            }
         }
         if(_zaoXianBuffs && _zaoXianBuffs.length > 0)
         {
            _loc51_ = _zaoXianBuffs[0];
            if(this.userVo && this.userVo.type == "pet")
            {
               if(_loc51_.config.attributeV1 > 0)
               {
                  if(!_loc51_.oldData)
                  {
                     _loc51_.oldData = {};
                  }
                  if(!_loc51_.oldData.hasOwnProperty("zxDamage"))
                  {
                     _loc51_.oldData.zxDamage = _loc51_.config.attributeV1 * this.userVo.hpMax;
                  }
                  if(_loc63_ != 0)
                  {
                     _loc51_.oldData.zxDamage -= _loc63_;
                  }
                  if(_loc50_ > 0)
                  {
                     _loc51_.oldData.zxDamage -= _loc50_;
                  }
                  if(_loc51_.oldData.zxDamage <= 0)
                  {
                     BuffModelManager.getIns().del(_loc51_);
                  }
               }
            }
         }
         this.OnHurtAfter(_loc63_,_attackSkillConfigvo);
         var _loc47_:Number = 0;
         if(_loc63_ > 0)
         {
            _loc47_ += _loc63_;
         }
         if(_loc50_ > 0)
         {
            _loc47_ += _loc50_;
         }
         if(_loc47_ > 0)
         {
            _loc43_ = BattleModelManager.getIns().calSoulCritical(_attackUserVo,userVo);
            if(_loc43_ > 0)
            {
               _loc44_ = BattleModelManager.getIns().getRandom("playerEntity-calSoulCritical");
               if(_loc44_ <= _loc43_)
               {
                  _loc48_ = calDamageBySoul(_loc47_);
                  this.userVo.updateHP(-_loc48_,false);
               }
            }
            _loc9_ = this.getBuff112V1();
            if(_loc9_ != 0)
            {
               _loc9_ *= _loc47_;
               this.userVo.updateHP(_loc9_,false);
               ApplicationFacade.getInstance().sendNotification("nfEntityHurtAuto",{
                  "userVo":this.userVo,
                  "hp":_loc9_,
                  "from":"getBuff112V1"
               });
            }
         }
         if(!this.userVo.hpLoseDict[_attackUserVo.entitieId])
         {
            this.userVo.hpLoseDict[_attackUserVo.entitieId] = _loc63_;
         }
         else
         {
            var _loc67_:Number = _attackUserVo.entitieId;
            var _loc66_:Number = this.userVo.hpLoseDict[_loc67_] + _loc63_;
            this.userVo.hpLoseDict[_loc67_] = _loc66_;
         }
         addHatred(_attackUserVo.entitieId,_loc63_);
         this.userVo.loseHP += _loc63_;
         this.userVo.remainHp += _loc63_;
         if(_buff_yuan_xian)
         {
            _buff_ba_ti = false;
            afterBuffYuanXian();
         }
         if(userVo && userVo.buff_sleep_on_hurtMan)
         {
            userVo.buff_sleep_on_hurtMan.Delay(1000);
         }
         if(manConfigVo.superArmor == 1)
         {
            _buff_ba_ti = true;
         }
         if(this.getBaiTiAction() != null)
         {
            _buff_ba_ti = this.getBaiTiAction();
         }
         var _loc7_:Boolean = false;
         if(getIsBaTi() == false)
         {
            if(_attackSkillConfigvo.stiff > 0)
            {
               _actions.push([stiff,_attackSkillConfigvo]);
            }
         }
         _loc36_ = _attackDirection;
         if(_loc36_ > 0)
         {
            _loc36_ = 1;
         }
         else if(_loc36_ < 0)
         {
            _loc36_ = -1;
         }
         _moveDir = getMoveDir();
         if(!(getIsBaTi() || _buff_ba_ti2))
         {
            removeBeahaviorAI();
            if(_actionState == 52)
            {
               pauseJump();
            }
            else if(isJump)
            {
               pauseJump();
            }
            else
            {
               stopJump();
               _attackIndex = 41;
            }
         }
         var _loc34_:Boolean = true;
         if(this is E3027 && E3027(this).isFriend)
         {
            _loc34_ = false;
         }
         if(_loc34_)
         {
            BattleModelManager.getIns().addHurtManData(_AttackInfo);
            _AttackInfos.push(_AttackInfo);
            if(_loc20_)
            {
               _loc20_.pos.x = _AttackInfo.pos.x;
               _loc20_.pos.y = _AttackInfo.pos.y;
               BattleModelManager.getIns().addHurtManData(_loc20_);
               _AttackInfos.push(_loc20_);
            }
         }
         _attackUserVo.hitNum++;
         _additionalVelocity.setxy(0,0);
         if(_buff_xi_ying)
         {
            BuffModelManager.getIns().del(_buff_xi_ying);
         }
         _buff_xi_ying = null;
         if(_buff_fang_shang && _buff_fang_shang_)
         {
            _loc6_ = _buff_fang_shang.config.attributeV1 * _attackUserVo.atk + _buff_fang_shang.config.attributeV2;
            if(_attackUserVo.isMagic)
            {
               if(this.userVo.isFriend == false)
               {
                  try
                  {
                     _loc19_ = BattleModelManager.getIns().getPlayerByEntityId(_attackUserVo.parent.getCurrentUVO().entitieId);
                     if(_loc19_)
                     {
                        _loc8_ = _loc19_.reduceHuDunHp(_loc6_);
                        _loc6_ = int(_loc8_[0]);
                        _loc4_ = Number(_loc8_[1]);
                        if(_loc4_ > 0)
                        {
                           BattleModelManager.showDiDanHp(_loc4_,_loc19_);
                        }
                     }
                  }
                  catch(error:Error)
                  {
                  }
                  _loc6_ = _attackUserVo.parent.getCurrentUVO().calRealReducehp(_loc6_,true);
                  _attackUserVo.parent.getCurrentUVO().updateHP(-_loc6_,false);
                  ApplicationFacade.getInstance().sendNotification("nfEntityHurtAuto",{
                     "userVo":_attackUserVo.parent.getCurrentUVO(),
                     "hp":-_loc6_,
                     "from":"t1"
                  });
               }
            }
            else if(this.userVo.isFriend == false)
            {
               if(_loc22_)
               {
                  _loc8_ = _loc22_.reduceHuDunHp(_loc6_);
                  _loc6_ = int(_loc8_[0]);
                  _loc4_ = Number(_loc8_[1]);
                  if(_loc4_ > 0)
                  {
                     BattleModelManager.showDiDanHp(_loc4_,_loc22_);
                  }
               }
               _loc35_ = _attackUserVo;
               if(_attackUserVo.isRole)
               {
                  _loc35_ = _attackUserVo.getRootUservo();
                  _loc35_ = _loc35_.getCurrentUVO();
               }
               _loc6_ = _loc35_.calRealReducehp(_loc6_,true);
               _loc35_.updateHP(-_loc6_,false);
               ApplicationFacade.getInstance().sendNotification("nfEntityHurtAuto",{
                  "userVo":_loc35_,
                  "hp":-_loc6_,
                  "from":"t2"
               });
            }
            ApplicationFacade.getInstance().sendNotification("nfPlayerInfoChange",this._attackUserVo);
         }
         if(_buff_fang_shang151 && _loc63_ > 0)
         {
            _loc61_ = 0;
            if(UserModelManager.getIns().isRole(_attackUserVo.charID))
            {
               _loc61_ = _buff_fang_shang151.config.attributeV1 * (_loc63_ + _loc50_);
            }
            else
            {
               _loc61_ = _buff_fang_shang151.config.attributeV2 * (_loc63_ + _loc50_);
            }
            if(_attackUserVo.isMagic)
            {
               if(this.userVo.isFriend == false)
               {
                  try
                  {
                     _loc19_ = BattleModelManager.getIns().getPlayerByEntityId(_attackUserVo.parent.entitieId);
                     if(_loc19_)
                     {
                        _loc8_ = _loc19_.reduceHuDunHp(_loc61_);
                        _loc61_ = int(_loc8_[0]);
                        _loc4_ = Number(_loc8_[1]);
                        if(_loc4_ > 0)
                        {
                           BattleModelManager.showDiDanHp(_loc4_,_loc19_);
                        }
                     }
                  }
                  catch(error:Error)
                  {
                  }
                  _loc61_ = _attackUserVo.parent.calRealReducehp(_loc61_,true);
                  _attackUserVo.parent.updateHP(-_loc61_,false);
                  ApplicationFacade.getInstance().sendNotification("nfEntityHurtAuto",{
                     "userVo":_attackUserVo.parent,
                     "hp":-_loc61_,
                     "from":"t1"
                  });
               }
            }
            else if(this.userVo.isFriend == false)
            {
               if(_loc22_)
               {
                  _loc8_ = _loc22_.reduceHuDunHp(_loc61_);
                  _loc61_ = int(_loc8_[0]);
                  _loc4_ = Number(_loc8_[1]);
                  if(_loc4_ > 0)
                  {
                     BattleModelManager.showDiDanHp(_loc4_,_loc22_);
                  }
               }
               _loc35_ = _attackUserVo;
               if(_attackUserVo.isRole)
               {
                  _loc35_ = _attackUserVo.getRootUservo();
                  _loc35_ = _loc35_.getCurrentUVO();
               }
               _loc61_ = _loc35_.calRealReducehp(_loc61_,true);
               _loc35_.updateHP(-_loc61_,false);
               ApplicationFacade.getInstance().sendNotification("nfEntityHurtAuto",{
                  "userVo":_loc35_,
                  "hp":-_loc61_,
                  "from":"t2"
               });
            }
            ApplicationFacade.getInstance().sendNotification("nfPlayerInfoChange",this._attackUserVo);
         }
         if(this.userVo.hp <= 0)
         {
            setToDie();
         }
         else
         {
            if(getIsBaTi() == false && _loc63_ != 0)
            {
               if(_buff_ba_ti2 == false)
               {
                  hurt();
               }
               BattleModelManager.getIns().calProtectPoint(this.userVo,_attackSkillConfigvo,getBuff90V1());
            }
            else if(getMustCalProtectPoint())
            {
               BattleModelManager.getIns().calProtectPoint(this.userVo,_attackSkillConfigvo,getBuff90V1());
            }
            if(_manConfigVo.id == 3362)
            {
            }
            _loc16_ = _manConfigVo.protectPoint;
            if(BattleModelManager.getIns().isTeam && this.userVo.campId == 2)
            {
               _loc16_ += _loc16_ * CommonConfig.doubleProtectPoint;
            }
            else if(UserModelManager.getIns().getCurretPlayerInfo() && UserModelManager.getIns().getCurretPlayerInfo().pMode == 2 && this.userVo.campId == 2 && this.userVo.isPk == false)
            {
               _loc2_ = CommonConfig.doubleProtectPoint;
               if(GlobalData.getJoinBattleNumEqual1())
               {
                  _loc2_ = 0;
               }
               if(isNaN(this.userVo.doubleProtectPoint) == false)
               {
                  _loc2_ = this.userVo.doubleProtectPoint;
               }
               _loc16_ += _loc16_ * _loc2_;
            }
            if(this.userVo.proScore >= _loc16_)
            {
               this.userVo.proScore = 0;
               if(this is BoatEntity)
               {
                  BuffModelManager.getIns().createBuff([1000401],[],1,this.userVo);
               }
               else
               {
                  BuffModelManager.getIns().createBuff([1000101],[],1,this.userVo);
               }
               if(protectSkillConfigVo)
               {
                  createMyBuffBySkillConfigVo(protectSkillConfigVo,"protectSkill");
                  toProtectSkill(protectSkillConfigVo);
               }
               BattleModelManager.getIns().recalProtectPoint(this.userVo);
            }
            if(this._attackSkillConfigvo.buffId)
            {
               if(this.getType() != ManType.SKILL || this.canReleaseBuff)
               {
                  createOtherBuff(_attackUserVo,this.userVo,_attackSkillConfigvo);
                  if(_attackMan && _attackMan.skp && _attackMan.skp.buffId2s)
                  {
                     _loc25_ = _attackMan.skp.buffId2s;
                     BuffModelManager.getIns().createBuff(_loc25_,[],1,this.userVo,_attackUserVo);
                  }
               }
            }
            _loc22_ = BattleModelManager.getIns().getPlayerByEntityId(_attackUserVo.entitieId) as RoleEntity;
            if(this._attackSkillConfigvo.addIceValue > 0)
            {
               if(_attackSkillConfigvo.otherData && _attackSkillConfigvo.otherData.userEntity)
               {
                  _attackSkillConfigvo.otherData.userEntity.AddIceValueTo(this._attackSkillConfigvo.addIceValue,this,this._attackSkillConfigvo);
               }
            }
            if(_loc22_)
            {
               _loc22_.attacked2(this,_loc63_,_attackSkillConfigvo);
               _loc22_.attacked3(this,_loc63_,_attackSkillConfigvo,_attackMan);
               if(_attackMan.Id != _loc22_.Id)
               {
                  _attackMan.attacked2(this,_loc63_);
               }
            }
            else
            {
               _attackMan.attacked2(this,_loc63_);
            }
            EventManager.emit("evt_attacked2",{
               "s":_loc63_,
               "hur":this,
               "att":_loc22_,
               "skc":_attackMan
            });
            dispatchEvent(new GameEvent("evt_onHurt",{"att":_loc22_}));
         }
      }
      
      private function checkBuff113(param1:Number) : Number
      {
         var _loc8_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc7_:int = 0;
         var _loc6_:UserVO = null;
         var _loc2_:Number = NaN;
         var _loc4_:RoleEntity = null;
         var _loc5_:Array = this.getBuff113();
         if(_loc5_)
         {
            _loc8_ = param1;
            _loc7_ = 0;
            while(_loc7_ < _loc5_.length)
            {
               _loc6_ = BuffVO(_loc5_[_loc7_]).attUserVo;
               if(_loc6_)
               {
                  _loc2_ = _loc8_ * BuffVO(_loc5_[_loc7_]).config.attributeV1;
                  _loc6_.updateHP(-_loc2_,false);
                  param1 -= _loc2_;
                  ApplicationFacade.getInstance().sendNotification("nfEntityHurtAuto",{
                     "userVo":_loc6_,
                     "hp":-_loc2_,
                     "from":"getBuff113"
                  });
                  _loc4_ = BattleModelManager.getIns().getPlayerByEntityId(_loc6_.entitieId) as RoleEntity;
                  if(_loc4_)
                  {
                     _loc3_ = _loc4_.getBuff112V1();
                     if(_loc3_ != 0)
                     {
                        _loc3_ *= _loc2_;
                        _loc6_.updateHP(_loc3_,false);
                        ApplicationFacade.getInstance().sendNotification("nfEntityHurtAuto",{
                           "userVo":_loc6_,
                           "hp":_loc3_,
                           "from":"getBuff112V1"
                        });
                     }
                  }
               }
               _loc7_++;
            }
         }
         return param1;
      }
      
      protected function getMustCalProtectPoint() : Boolean
      {
         return false;
      }
      
      protected function onDamage(param1:Number) : void
      {
      }
      
      protected function onHurtCalDamageAfter(param1:int, param2:SkillConfigVO, param3:PlayerEntity, param4:UserVO) : int
      {
         return param1;
      }
      
      protected function getBaiTiAction() : Object
      {
         return null;
      }
      
      protected function OnHurtAfter(param1:int, param2:SkillConfigVO) : void
      {
         var _loc5_:Object = null;
         var _loc4_:String = null;
         var _loc7_:Array = null;
         var _loc3_:Boolean = false;
         if(this.userVo.buff_hurt_add_hp_per != 0)
         {
            this.userVo.updateHP(this.userVo.buff_hurt_add_hp_per * this.userVo.hpMax,false);
            ApplicationFacade.getInstance().sendNotification("NF_ENTITY_BUFF_HURT_ADD_HP",{
               "userVo":this.userVo,
               "value":0
            });
         }
         try
         {
            if(this.userVo.boss == 1)
            {
               var _loc9_:* = 2;
               var _loc10_:* = this.userVo.record_dmages[_loc9_] + param1;
               this.userVo.record_dmages[_loc9_] = _loc10_;
               if(param2 && _attackMan && _attackMan.manConfigVo)
               {
                  if(_attackMan.userVo && UserModelManager.getIns().isRole(_attackMan.userVo.charID))
                  {
                     _loc5_ = _attackMan.manConfigVo.skills || {};
                     for(var _loc6_:String in _loc5_)
                     {
                        if(_loc5_[_loc6_] && _loc5_[_loc6_].id == param2.id)
                        {
                           _loc4_ = _loc6_;
                        }
                     }
                     _loc7_ = ["attack1","attack2","attack3","attack4","effect1","effect2","effect3","effect4","effect5"];
                     _loc3_ = _loc7_.indexOf(_loc4_) > -1;
                     if(_loc3_)
                     {
                        _loc10_ = 0;
                        _loc9_ = this.userVo.record_dmages[_loc10_] + param1;
                        this.userVo.record_dmages[_loc10_] = _loc9_;
                     }
                     else
                     {
                        var _loc12_:int = 1;
                        var _loc11_:Number = this.userVo.record_dmages[_loc12_] + param1;
                        this.userVo.record_dmages[_loc12_] = _loc11_;
                     }
                  }
               }
            }
         }
         catch(error:Error)
         {
         }
      }
      
      protected function createOtherBuff(param1:UserVO, param2:Object, param3:SkillConfigVO) : void
      {
         var _loc4_:RoleEntity = null;
         if(!param1 || !param2)
         {
            return;
         }
         if(param3.createOtherBuffByAttackUservo)
         {
            _loc4_ = BattleModelManager.getIns().getPlayerByEntityId(param1.entitieId) as RoleEntity;
            if(_loc4_ && _loc4_.createOtherBuffByAttackUservo(param2,param3))
            {
               return;
            }
         }
         BuffModelManager.getIns().createOtherBuf(param1,this.userVo,param3);
      }
      
      public function createBuff(param1:UserVO, param2:Object, param3:SkillConfigVO) : void
      {
         createOtherBuff(param1,param2,param3);
      }
      
      protected function afterBuffYuanXian() : void
      {
      }
      
      private function addMaskEff() : void
      {
      }
      
      public function OnCalDamage(param1:int, param2:UserVO, param3:SkillConfigVO) : int
      {
         return this.onCalDamage(param1,param2,param3);
      }
      
      public function OnCalDmgRate() : Number
      {
         var _loc10_:int = 0;
         var _loc5_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc7_:Array = null;
         var _loc1_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc2_:Number = 1;
         var _loc9_:Number = 0;
         var _loc8_:Number = 0;
         if(this._oldUservo.buff_dmg_rate_on_hurtMan)
         {
            _loc10_ = 0;
            while(_loc10_ < this._oldUservo.buff_dmg_rate_on_hurtMan.length)
            {
               _loc5_ = 0;
               _loc4_ = this._oldUservo.buff_dmg_rate_on_hurtMan[_loc10_].config.attributeV1;
               if(this._oldUservo.buff_dmg_rate_on_hurtMan[_loc10_].config.changeType == 34)
               {
                  _loc7_ = this._oldUservo.buff_dmg_rate_on_hurtMan[_loc10_].children || [];
                  if(_loc7_.length > 0)
                  {
                     _loc4_ *= 1 + _loc7_.length;
                  }
               }
               if(_loc4_ > 1 && this._oldUservo.propertyVo)
               {
                  _loc4_ = 1 + (_loc4_ - 1) * this._oldUservo.propertyVo.reduce_debuff_per;
               }
               if(this._oldUservo.buff_dmg_rate_on_hurtMan[_loc10_].config.toward == 1)
               {
                  if(this._attackDirection != this.direction)
                  {
                     _loc5_ = 1 - _loc4_;
                  }
               }
               else if(this._oldUservo.buff_dmg_rate_on_hurtMan[_loc10_].config.toward == -1)
               {
                  if(this._attackDirection == this.direction)
                  {
                     _loc5_ = 1 - _loc4_;
                  }
               }
               else
               {
                  _loc5_ = 1 - _loc4_;
               }
               if(_loc5_ != 0)
               {
                  if(_loc4_ > 0)
                  {
                     _loc9_ += 1 / (1 - _loc5_) - 1;
                  }
                  else
                  {
                     _loc9_ += _loc4_;
                  }
               }
               _loc10_++;
            }
         }
         var _loc6_:Number = this._oldUservo.getSoulProperty("dmgRate");
         if(_loc6_ != 0)
         {
            _loc9_ += 1 / (1 - _loc6_) - 1;
         }
         if(this._oldUservo && this._oldUservo.getHorseSoulProperty())
         {
            _loc1_ = this._oldUservo.getHorseSoulProperty().hurtRate;
            _loc9_ += 1 / (1 - _loc1_) - 1;
         }
         if(_loc9_ != 0 && needCalDamgRateOnHurtMan)
         {
            _loc3_ = 1 - 1 / (_loc9_ + 1);
            if(_loc9_ <= 0)
            {
               _loc3_ = _loc9_;
            }
            return 1 - _loc3_;
         }
         return 1;
      }
      
      protected function onCalDamage(param1:int, param2:UserVO, param3:SkillConfigVO) : int
      {
         var _loc16_:int = 0;
         var _loc9_:* = NaN;
         var _loc18_:Number = NaN;
         var _loc13_:Array = null;
         var _loc5_:Number = NaN;
         var _loc8_:Number = NaN;
         _loc9_ = undefined;
         var _loc12_:int = 0;
         _loc8_ = NaN;
         var _loc11_:int = 0;
         _loc12_ = 0;
         var _loc4_:Number = NaN;
         var _loc17_:RoleEntity = null;
         var _loc19_:Number = NaN;
         var _loc22_:int = 0;
         var _loc20_:BuffVO = null;
         _loc22_ = 0;
         _loc20_ = null;
         _loc22_ = 0;
         _loc20_ = null;
         _loc22_ = 0;
         _loc20_ = null;
         if(!param2)
         {
            param2 = this._attackUserVo;
         }
         if(!param3)
         {
            param3 = this._attackSkillConfigvo;
         }
         var _loc14_:Number = 0;
         var _loc23_:Number = 0;
         if(this._oldUservo.buff_dmg_rate_on_hurtMan)
         {
            _loc16_ = 0;
            while(_loc16_ < this._oldUservo.buff_dmg_rate_on_hurtMan.length)
            {
               _loc9_ = 0;
               _loc18_ = this._oldUservo.buff_dmg_rate_on_hurtMan[_loc16_].config.attributeV1;
               if(this._oldUservo.buff_dmg_rate_on_hurtMan[_loc16_].config.changeType == 34)
               {
                  _loc13_ = this._oldUservo.buff_dmg_rate_on_hurtMan[_loc16_].children || [];
                  if(_loc13_.length > 0)
                  {
                     _loc18_ *= 1 + _loc13_.length;
                  }
               }
               if(_loc18_ > 1 && this._oldUservo.propertyVo)
               {
                  _loc18_ = 1 + (_loc18_ - 1) * this._oldUservo.propertyVo.reduce_debuff_per;
               }
               if(this._oldUservo.buff_dmg_rate_on_hurtMan[_loc16_].config.toward == 1)
               {
                  if(this._attackDirection != this.direction)
                  {
                     _loc9_ = 1 - _loc18_;
                  }
               }
               else if(this._oldUservo.buff_dmg_rate_on_hurtMan[_loc16_].config.toward == -1)
               {
                  if(this._attackDirection == this.direction)
                  {
                     _loc9_ = 1 - _loc18_;
                  }
               }
               else
               {
                  _loc9_ = 1 - _loc18_;
               }
               if(_loc9_ != 0)
               {
                  if(_loc18_ > 0)
                  {
                     _loc14_ += 1 / (1 - _loc9_) - 1;
                  }
                  else
                  {
                     _loc14_ += _loc18_;
                  }
               }
               _loc16_++;
            }
         }
         var _loc21_:Number = this._oldUservo.getSoulProperty("dmgRate");
         if(_loc21_ != 0)
         {
            _loc14_ += 1 / (1 - _loc21_) - 1;
         }
         if(this._oldUservo && this._oldUservo.getHorseSoulProperty())
         {
            _loc5_ = this._oldUservo.getHorseSoulProperty().hurtRate;
            _loc14_ += 1 / (1 - _loc5_) - 1;
         }
         if(_loc14_ != 0 && needCalDamgRateOnHurtMan)
         {
            _loc8_ = 1 - 1 / (_loc14_ + 1);
            if(_loc14_ <= 0)
            {
               _loc8_ = _loc14_;
            }
            param1 *= 1 - _loc8_;
         }
         _loc14_ = 0;
         _loc9_ = 0;
         var _loc6_:Number = 0;
         if(param2 && param2.buff_dmg_rate_on_attMan)
         {
            _loc9_ = 1 - param2.buff_dmg_rate_on_attMan.config.attributeV1;
            if(_loc9_ != 0)
            {
               _loc14_ += 1 / (1 - _loc9_) - 1;
            }
         }
         if(param2 && param2.buff_dmg_rate_on_attMan2.length > 0)
         {
            _loc12_ = 0;
            while(_loc12_ < param2.buff_dmg_rate_on_attMan2.length)
            {
               _loc9_ = 1 - param2.buff_dmg_rate_on_attMan2[_loc12_].config.attributeV1;
               if(_loc9_ != 0)
               {
                  _loc14_ += 1 / (1 - _loc9_) - 1;
               }
               _loc12_++;
            }
         }
         if(_loc14_ != 0)
         {
            _loc8_ = 1 - 1 / (_loc14_ + 1);
            param1 *= 1 - _loc8_;
         }
         var _loc7_:Number = 0;
         if(param2 && param2.buff60s)
         {
            _loc11_ = 0;
            while(_loc11_ < param2.buff60s.length)
            {
               _loc7_ += param2.buff60s[_loc11_].config.attributeV1 * param2.buff60s[_loc11_].config.attributeV2;
               _loc11_++;
            }
         }
         if(param2 && param2.buff_dmg_rate_on_attMan3.length > 0)
         {
            _loc12_ = 0;
            while(_loc12_ < param2.buff_dmg_rate_on_attMan3.length)
            {
               _loc4_ = param2.hp / param2.allhpMax;
               _loc4_ = Math.max(_loc4_,param2.buff_dmg_rate_on_attMan3[_loc12_].config.attributeV3);
               _loc9_ = (1 - _loc4_) * param2.buff_dmg_rate_on_attMan3[_loc12_].config.attributeV1 + param2.buff_dmg_rate_on_attMan3[_loc12_].config.attributeV2;
               _loc7_ += _loc9_;
               _loc12_++;
            }
         }
         param1 *= 1 + _loc7_;
         if(this._oldUservo.buff_sleep_on_hurtMan)
         {
            param1 *= 2;
         }
         if(param2 && param2.getHorseSoulProperty())
         {
            param1 *= param2.getHorseSoulProperty().damgeRate;
         }
         if(param3)
         {
            param1 += param3.hurtHp;
         }
         if(this.userVo.getSoulProperty("lastDamageRate") != 0)
         {
            param1 *= 1 + this.userVo.getSoulProperty("lastDamageRate");
         }
         if(param2)
         {
            _loc17_ = BattleModelManager.getIns().getPlayerByEntityId(param2.entitieId) as RoleEntity;
            if(_loc17_)
            {
               _loc19_ = 1;
               _loc22_ = 0;
               while(_loc22_ < this.getBufs().length)
               {
                  _loc20_ = this.getBufs()[_loc22_];
                  if(_loc20_.config.type == 79)
                  {
                     _loc19_ += _loc20_.config.attributeV1;
                  }
                  _loc22_++;
               }
               _loc22_ = 0;
               while(_loc22_ < _loc17_.getBufs().length)
               {
                  _loc20_ = _loc17_.getBufs()[_loc22_];
                  if(_loc20_.config.type == 80)
                  {
                     _loc19_ += _loc20_.config.attributeV1;
                  }
                  _loc22_++;
               }
               _loc19_ = Math.max(_loc19_,0);
               param1 *= _loc19_;
               _loc19_ = 1;
               _loc22_ = 0;
               while(_loc22_ < _loc17_.getBufs().length)
               {
                  _loc20_ = _loc17_.getBufs()[_loc22_];
                  if(_loc20_.config.type == 102)
                  {
                     if(this.hasBuffPrefix(_loc20_.config.attributeV3))
                     {
                        _loc19_ += _loc20_.config.attributeV1;
                     }
                  }
                  _loc22_++;
               }
               if(_loc19_ != 1)
               {
                  _loc19_ = Math.max(_loc19_,0);
                  param1 *= _loc19_;
               }
            }
         }
         _loc19_ = 0;
         var _loc15_:Number = 0;
         var _loc10_:Number = 0;
         _loc22_ = 0;
         while(_loc22_ < this.getBufs().length)
         {
            _loc20_ = this.getBufs()[_loc22_];
            if(_loc20_.config.type == 105)
            {
               _loc19_ += _loc20_.config.attributeV1;
               _loc15_ += _loc20_.config.attributeV2;
               _loc10_ += _loc20_.config.attributeV3;
            }
            _loc22_++;
         }
         if(_loc19_ != 0)
         {
            _loc19_ += this.userVo.allhpMax / this.userVo.hp * _loc15_;
            if(_loc19_ > _loc10_)
            {
               _loc19_ = _loc10_;
            }
            param1 *= 1 - _loc19_;
         }
         if(param1 <= 0)
         {
            param1 = 1;
         }
         return param1;
      }
      
      protected function get needCalDamgRateOnHurtMan() : Boolean
      {
         return true;
      }
      
      public function createBuffGaiLi(param1:BuffVO, param2:UserVO, param3:AttackInfoVO = null) : void
      {
         if(this.getType() == ManType.SKILL)
         {
            return;
         }
         if(this.isDie)
         {
            return;
         }
         if(param1.config.attributeT == "BUFF")
         {
            if(param1.config.target == 11)
            {
               BuffModelManager.getIns().createBuff([param1.config.attributeV1],[],1,this.userVo,param2);
            }
            else
            {
               BuffModelManager.getIns().createBuff([param1.config.attributeV1],[],1,this._attackUserVo || param2);
            }
         }
         else if(param1.config.attributeT == "SKILL")
         {
            _AttackInfo ||= param3;
            addSKillEntityByTrigger(param2,param1.config.attributeV1,param1,new Vector2D(_AttackInfo.pos.x,_AttackInfo.pos.y));
         }
      }
      
      protected function addSKillEntityByTrigger(param1:UserVO, param2:Number, param3:BuffVO, param4:Vector2D) : void
      {
         var _loc5_:SkillEntity = null;
         var _loc6_:int = param3.level;
         var _loc7_:SkillConfigVO = SkillModelManager.getIns().getSkillConfigVOByID(param2);
         _loc7_ = _loc7_.clone();
         _loc7_.level = _loc6_;
         _loc7_.level2 = _loc6_ + 10;
         var _loc9_:Vector2D = this.position.clone();
         if(this.userVo && this.manConfigVo && this.manConfigVo is RoleConfigVO)
         {
            if(RoleConfigVO(this.manConfigVo).locateCenter)
            {
               _loc9_.x += this.direction * RoleConfigVO(this.manConfigVo).locateCenter.x;
               _loc9_.y += RoleConfigVO(this.manConfigVo).locateCenter.y;
            }
            else if(RoleConfigVO(this.manConfigVo).targetCenter)
            {
               _loc9_.x += this.direction * RoleConfigVO(this.manConfigVo).targetCenter.x;
               _loc9_.y -= RoleConfigVO(this.manConfigVo).targetCenter.y;
            }
         }
         var _loc8_:PlayerEntity = BattleModelManager.getIns().getPlayerByEntityId(param1.entitieId) as PlayerEntity;
         if(_loc8_ && _loc8_.userVo == param1)
         {
            _loc5_ = _loc8_.addSKillEntity(_loc7_.assetLink[0],_loc7_,_loc9_,false,param1.campId);
            _loc8_.addSKillEntityByTriggerAfter(_loc5_);
            if(param3.config.attributeV2 > 0)
            {
               BuffModelManager.getIns().createBuff([param3.config.attributeV2],[],1,param1);
            }
         }
      }
      
      public function setToDie() : void
      {
         if(_inDu)
         {
            return;
         }
         if(this.userVo.hp > 0)
         {
            return;
         }
         if(this.userVo.checkLostHp() == false)
         {
         }
         if(this.userVo)
         {
            if(this.userVo.type == "role")
            {
               if(this.userVo.parent)
               {
                  this.userVo.parent.isDie = true;
               }
               else if(this.userVo.children)
               {
                  this.userVo.children.isDie = true;
               }
            }
            this.userVo.isDie = true;
         }
         if(_isDie)
         {
            return;
         }
         if(this.userVo.hp <= 0)
         {
            if(this.dieSkillConfigVo && _isKillBySelf == false)
            {
               checkZhaoHuan(this.dieSkillConfigVo);
            }
            else if(getNeedReleaseDieSkill())
            {
               checkZhaoHuan(this.dieSkillConfigVo);
            }
         }
         _isDie = true;
         clearStiff();
         toDie();
      }
      
      protected function getNeedReleaseDieSkill() : Boolean
      {
         return false;
      }
      
      public function goToDie() : void
      {
         _isKillBySelf = true;
         this.userVo.updateHP(-this.userVo.allhpMax * 2,false);
         setToDie();
      }
      
      public function goToDieNoKillBySelf() : void
      {
         this.userVo.updateHP(-this.userVo.hpMax,false);
         setToDie();
      }
      
      protected function onSetAttackInfo(param1:AttackInfoVO) : void
      {
      }
      
      private function getMoveDir() : int
      {
         var _loc1_:int = 1;
         if(_attackSkillConfigvo.attackedMoveDir == 0)
         {
            _loc1_ = _attackDirection;
         }
         else if(_attackSkillConfigvo.attackedMoveDir == 2)
         {
            _loc1_ = -_attackDirection;
         }
         else if(_attackSkillConfigvo.attackedMoveDir == 1)
         {
            if(this.position.x > _attackPosition.x)
            {
               _loc1_ = 1;
            }
            else
            {
               _loc1_ = -1;
            }
         }
         else if(_attackSkillConfigvo.attackedMoveDir == 3)
         {
            if(this.position.x > _attackPosition.x)
            {
               _loc1_ = -1;
            }
            else
            {
               _loc1_ = 1;
            }
         }
         return _loc1_;
      }
      
      public function addHatred(param1:Number, param2:int) : void
      {
         if(this.userVo.entitieId == param1)
         {
            return;
         }
         if(!this.userVo.hatred[param1])
         {
            this.userVo.hatred[param1] = param2;
         }
         else
         {
            var _loc3_:Number = param1;
            var _loc4_:Number = this.userVo.hatred[_loc3_] + param2;
            this.userVo.hatred[_loc3_] = _loc4_;
         }
      }
      
      public function addHatredMin0(param1:Number, param2:int) : void
      {
         if(this.userVo.entitieId == param1)
         {
            return;
         }
         if(!this.userVo.hatred[param1])
         {
            this.userVo.hatred[param1] = param2;
         }
         else
         {
            var _loc3_:Number = param1;
            var _loc4_:Number = this.userVo.hatred[_loc3_] + param2;
            this.userVo.hatred[_loc3_] = _loc4_;
         }
         if(this.userVo.hatred[param1] < 0)
         {
            this.userVo.hatred[param1] = 0;
         }
      }
      
      override protected function gotoJump() : void
      {
         if(!canJump)
         {
            return;
         }
         super.gotoJump();
         if(_isJump)
         {
            jumpTwo();
         }
         else if(_isJump2)
         {
            jumpThree();
         }
         else
         {
            jump();
         }
         _startJumpPos.setxy(this.bodyPosition.x,this.bodyPosition.y);
         _isJump = true;
      }
      
      protected function jump() : void
      {
         if(_actionState != 6)
         {
            _actionState = 6;
            updateAnimation();
         }
      }
      
      override protected function toJumpDown() : void
      {
         super.toJumpDown();
         if(userVo.isPk && userVo.campId != 1)
         {
            if(_AI && _AI is JumpAI)
            {
               _AI.destroy();
            }
         }
         if(getIsAttacking() || isHurting || isDie)
         {
            return;
         }
         jumpDown();
      }
      
      protected function jumpDown() : void
      {
         if(_actionState != 8)
         {
            _actionState = 8;
            updateAnimation();
         }
      }
      
      protected function jumpTwo() : void
      {
         if(_actionState != 7)
         {
            _actionState = 7;
            updateAnimation();
         }
      }
      
      protected function jumpThree() : void
      {
         if(_actionState != 7)
         {
            _actionState = 7;
            updateAnimation();
         }
      }
      
      public function toDie() : void
      {
         var _loc1_:Number = NaN;
         _moving = false;
         clearShoot();
         die();
         onDie();
         if(_AI)
         {
            _AI.destroy();
            _AI = null;
         }
         if(_body && isNaN(this._gravity) == false)
         {
            this._body.gravMass = this._gravity;
         }
         if(this.userVo.type != "role")
         {
            onsendEntityDeadCmd();
            if(_body && _manConfigVo.superArmor == 0)
            {
               onDieAfterVel();
            }
            _loc1_ = 0.5;
            if(manConfigVo && manConfigVo.dieHideDelay > 0)
            {
               _loc1_ = manConfigVo.dieHideDelay;
            }
            hide(_loc1_);
         }
         else
         {
            onDieAfterVel();
            GameFrame.juggler.delayCall(hide,1500,0.5);
            GameFrame.juggler.delayCall(sendEntityDeadCmd,1200);
         }
      }
      
      protected function onsendEntityDeadCmd() : void
      {
         sendEntityDeadCmd();
      }
      
      protected function sendEntityDeadCmd() : void
      {
         if(_deadsend == true)
         {
            return;
         }
         _deadsend = true;
         if(this.userVo.type == "role")
         {
            if(this.userVo.parent)
            {
               this.userVo.parent.isDie = true;
            }
            else if(this.userVo.children)
            {
               this.userVo.children.isDie = true;
            }
         }
         ApplicationFacade.getInstance().sendNotification("cmdEntityDead",this,_isKillBySelf ? "_isKillBySelf" : null);
      }
      
      protected function onDieAfterVel() : void
      {
         var _loc1_:Vec2 = _body.velocity;
         if(_attackPosition)
         {
            _loc1_.x = -_dieVelocity.x * _direction;
            _loc1_.y = -_dieVelocity.y;
         }
         maxVelocity.x = 200;
         updateBodyVelocity(_loc1_);
      }
      
      protected function hide(param1:Number) : void
      {
         if(BattleModelManager.getIns().levelInfo && BattleModelManager.getIns().levelInfo.getIsV2())
         {
            BattleModelManager.getIns().levelParam.logic.addDeadHide({
               "delayTime":400,
               "hideTime":param1 * 1000,
               "hidePerAlpha":1 / (param1 * 1000),
               "display":this.display,
               "onComplete":destory
            });
         }
         else
         {
            _tweeHide = TweenMax.to(_display,param1,{
               "alpha":0,
               "onComplete":destory,
               "delay":0.4
            });
         }
      }
      
      override protected function onAnimationPlayComplete() : void
      {
         if(_actionState == 100)
         {
            return;
         }
         super.onAnimationPlayComplete();
      }
      
      override public function destory() : void
      {
         removeAI();
         removeBeahaviorAI();
         if(deleted)
         {
            return;
         }
         _isReadyCanAI = false;
         super.destory();
         if(_tweeHide)
         {
            _tweeHide.kill();
            _tweeHide = null;
         }
         if(keyboard)
         {
            keyboard.reset();
         }
         if(keyControl)
         {
            keyControl.reset();
         }
         if(_ab)
         {
            _ab.bitmapData = null;
         }
         if(_hb)
         {
            _hb.bitmapData = null;
         }
         _ab = null;
         _hb = null;
         SoulStoneManager.getIns().remove(this.Id);
      }
      
      protected function hurt() : void
      {
         var _loc2_:Vec2 = null;
         var _loc4_:BodyUserData = null;
         var _loc1_:Body = null;
         var _loc3_:int = 0;
         if(_attackSkillConfigvo && _attackSkillConfigvo.isBati)
         {
            return;
         }
         if(!_hurtDelayTimer)
         {
            if(_actionState != 5)
            {
               if(getNeedStiff(_attackSkillConfigvo))
               {
                  _actionState = 5;
                  updateAnimation();
                  if(_nowAnimation)
                  {
                     onAddHurtActionState();
                     _nowAnimation.loop = true;
                  }
               }
               stopWalk();
               clearShoot();
            }
            if(!_body)
            {
               return;
            }
            _loc2_ = _body.velocity.copy();
            if(_attackSkillConfigvo.targetMove && _attackSkillConfigvo.targetMove.length != 0)
            {
               _loc2_.y = -_attackSkillConfigvo.targetMove.y;
               _loc2_.x = _attackSkillConfigvo.targetMove.x * _moveDir;
               maxVelocity.x = Math.abs(_loc2_.x);
            }
            if(!_attackSkillConfigvo.targetMove)
            {
               throw new Error(_attackSkillConfigvo.id + "_targetMove =null");
            }
            if(_attackSkillConfigvo.JiYiaOnFloor)
            {
               if(this._standInBody && _standInBody.userData)
               {
                  _loc4_ = _standInBody.userData.data;
                  if(_loc4_ && _loc4_.group == "floor")
                  {
                     _onGround = false;
                     _loc1_ = _standInBody;
                     if(!_loc1_.userData.data.collisionMask)
                     {
                        _loc1_.userData.data.collisionMask = _loc1_.shapes.at(0).filter.collisionMask;
                     }
                     _loc3_ = 0;
                     while(_loc3_ < _loc1_.shapes.length)
                     {
                        _loc1_.shapes.at(_loc3_).filter.collisionMask = ~this._body.shapes.at(0).filter.collisionGroup;
                        _loc3_++;
                     }
                     _needChangeFloor.push(_loc1_);
                  }
               }
            }
            onHurtVelocity(_loc2_);
            onHurtVelocity2(_loc2_,_attackSkillConfigvo);
            updateBodyVelocity(_loc2_);
            stiff(_attackSkillConfigvo);
         }
      }
      
      protected function onAddHurtActionState() : void
      {
      }
      
      protected function onHurtVelocity(param1:Vec2) : void
      {
      }
      
      protected function onHurtVelocity2(param1:Vec2, param2:SkillConfigVO) : void
      {
      }
      
      override public function attack(param1:int = 41) : void
      {
         if(_isJump)
         {
            _attackIndex = 0;
            toJumpAttack();
            return;
         }
         if(_actionState == 3)
         {
            toRunAttack();
            return;
         }
         if(_actionState == 2)
         {
            _moving = false;
            setMaterial(_staticFriction,_dynamicFriction);
            _isAttack = false;
         }
         super.attack(param1);
      }
      
      protected function toRunAttack() : void
      {
         runAttack();
      }
      
      protected function toJumpAttack() : void
      {
         jumpAttack();
      }
      
      private function jumpAttack() : void
      {
         if(_actionState != 61)
         {
            _isAttack = true;
            _actionState = 61;
            updateAnimation();
            _nowAnimation.loop = false;
            onAttacking();
         }
      }
      
      override protected function onAttacking() : void
      {
         var _loc1_:SkillConfigVO = null;
         var _loc2_:int = 0;
         var _loc14_:SkillConfigVO = null;
         var _loc9_:int = 0;
         var _loc12_:SkillConfigVO = null;
         var _loc13_:Array = null;
         var _loc17_:int = 0;
         var _loc3_:BuffVO = null;
         var _loc16_:Object = null;
         var _loc6_:Array = null;
         var _loc7_:int = 0;
         var _loc5_:SkillParam = null;
         var _loc8_:int = 0;
         _loc5_ = null;
         var _loc11_:String = null;
         _loc6_ = null;
         var _loc15_:SkillConfigVO = null;
         var _loc10_:Class = null;
         super.onAttacking();
         if(this.getType() != ManType.SKILL)
         {
            _loc1_ = skillConfigVo;
            if(!_loc1_)
            {
               return;
            }
            _loc1_.addXPTotal = 0;
            _loc1_.addBuff81 = 0;
            _loc1_.suckBloodNum = 0;
            _loc1_.backLashNum = 0;
            _loc2_ = 0;
            while(_loc2_ < _loc1_.subs.length)
            {
               _loc14_ = _loc1_.subs[_loc2_];
               _loc14_.addXPTotal = 0;
               _loc14_.addBuff81 = 0;
               _loc14_.suckBloodNum = 0;
               _loc14_.backLashNum = 0;
               if(_loc14_.subs)
               {
                  _loc9_ = 0;
                  while(_loc9_ < _loc14_.subs.length)
                  {
                     _loc12_ = _loc14_.subs[_loc9_];
                     _loc12_.addXPTotal = 0;
                     _loc12_.addBuff81 = 0;
                     _loc12_.suckBloodNum = 0;
                     _loc12_.backLashNum = 0;
                     _loc9_++;
                  }
               }
               _loc2_++;
            }
            BattleModelManager.getIns().setAttackedTotalNum(this.userVo.entitieId,skillConfigVo.id,0,this.userVo.type,this.userVo.campId);
            this.userVo.nowSkillHit = 0;
            _loc13_ = getBuff108TanLan();
            if(_loc13_)
            {
               _loc17_ = 0;
               while(_loc17_ < _loc13_.length)
               {
                  _loc3_ = _loc13_[_loc17_];
                  BuffModelManager.getIns().createBuff(_loc3_.config.attributeT.split(","),null,1,this.userVo,_loc3_.attUserVo);
                  _loc17_++;
               }
            }
         }
         checkMyBuff();
         var _loc4_:int = keyControl.directionLR * this.getRealDir();
         updateDirection(_loc4_);
         checkZhaoHuan(skillConfigVo);
         onBeginSkil();
         if(this.getType() != ManType.SKILL || canReleaseSkillParam())
         {
            if(skillConfigVo && skillConfigVo.param && !deleted)
            {
               if(this.userVo && this.userVo.iszhaohuan)
               {
                  skillConfigVo.param = skillConfigVo.param.replace(/"locateTarget"\s*:\s*1(?=[,}\]])/g,"\"locateTarget\":14");
               }
               _loc16_ = JSON.parse(skillConfigVo.param);
               _loc6_ = _loc16_.addBuffs || [];
               _loc7_ = 0;
               while(_loc7_ < _loc6_.length)
               {
                  _loc5_ = new SkillParam(_loc6_[_loc7_]);
                  new SkillAddBuff(this,_loc5_,skillConfigVo);
                  _loc7_++;
               }
               SkillBullet;
               SkillAddBuff;
               SkillDown;
               SkillJump;
               SkillModelManager;
               SkillTeleport;
               SkillBulletFollwSelf;
               SkillDown2;
               SkillGravity;
               SkillBulletLocateTarget;
               SkillBulletLocate;
               SkillStopMoveX;
               SkillChangeDir;
               SkillSummon;
               SkillBulletLocateTarget2;
               SkillBulletParabola;
               SkillBulletParabola2;
               SkillRangeBuff;
               SkillBulletAngle;
               SkillBulletFollowTarget;
               SkillBulletLocateTarget3;
               SkillBulletCrossRotate;
               if(_loc16_ is Array)
               {
                  _loc16_;
                  _loc8_ = 0;
                  while(_loc8_ < _loc16_.length)
                  {
                     this.beforeBuidSkill(_loc16_[_loc8_]);
                     _loc5_ = new SkillParam(_loc16_[_loc8_]);
                     _loc11_ = _loc16_[_loc8_].type;
                     _loc6_ = _loc11_.split("");
                     _loc6_[0] = _loc6_[0].toUpperCase();
                     _loc11_ = "Skill" + _loc6_.join("");
                     _loc10_ = getDefinitionByName("models.skills." + _loc11_) as Class;
                     if(_loc5_.skillId > 0)
                     {
                        _loc15_ = SkillModelManager.getIns().getSkillConfigVOByID(_loc5_.skillId).clone();
                        if(this.skillConfigVo.level > 0)
                        {
                           _loc15_.buff_add_level = this.skillConfigVo.buff_add_level;
                           _loc15_.level = this.skillConfigVo.level;
                           _loc15_.level2 = this.skillConfigVo.level2;
                           if(this.userVo && this.userVo.isLuoHan_ChenShi)
                           {
                              _loc15_.buff_add_level = 0;
                              _loc15_.level = 1;
                              _loc15_.level2 = 11;
                           }
                           _loc15_.updateBuff(_loc15_.buff_add_level);
                        }
                     }
                     else
                     {
                        _loc15_ = skillConfigVo;
                     }
                     this.skillControls.push(new _loc10_(this,_loc5_,_loc15_.clone()));
                     _loc8_++;
                  }
               }
            }
         }
      }
      
      protected function beforeBuidSkill(param1:Object) : void
      {
      }
      
      public function releaseSkc(param1:SkillConfigVO, param2:Boolean = false, param3:Vector2D = null, param4:SkillParam = null) : void
      {
         var _loc16_:Object = null;
         var _loc8_:Array = null;
         var _loc11_:int = 0;
         var _loc7_:SkillParam = null;
         var _loc12_:int = 0;
         _loc7_ = null;
         var _loc13_:String = null;
         _loc8_ = null;
         var _loc14_:Class = null;
         var _loc18_:int = 0;
         var _loc9_:int = 0;
         var _loc6_:int = 0;
         var _loc17_:Number = NaN;
         _loc17_ = NaN;
         var _loc19_:Number = NaN;
         var _loc5_:Vector2D = null;
         var _loc10_:Number = NaN;
         var _loc15_:Number = NaN;
         if(this.getType() != ManType.SKILL || canReleaseSkillParam() || param2)
         {
            if(param1.param && !deleted)
            {
               if(this.userVo && this.userVo.iszhaohuan)
               {
                  param1.param = param1.param.replace(/"locateTarget"\s*:\s*1(?=[,}\]])/g,"\"locateTarget\":14");
               }
               _loc16_ = JSON.parse(param1.param);
               _loc8_ = _loc16_.addBuffs || [];
               _loc11_ = 0;
               while(_loc11_ < _loc8_.length)
               {
                  _loc7_ = new SkillParam(_loc8_[_loc11_]);
                  new SkillAddBuff(this,_loc7_,param1);
                  _loc11_++;
               }
               SkillBullet;
               SkillAddBuff;
               SkillDown;
               SkillJump;
               SkillModelManager;
               SkillTeleport;
               SkillGravity;
               SkillBulletLocateTarget;
               SkillBulletLocate;
               SkillStopMoveX;
               if(_loc16_ is Array)
               {
                  _loc16_;
                  _loc12_ = 0;
                  while(_loc12_ < _loc16_.length)
                  {
                     _loc7_ = new SkillParam(_loc16_[_loc12_]);
                     _loc13_ = _loc16_[_loc12_].type;
                     _loc8_ = _loc13_.split("");
                     _loc8_[0] = _loc8_[0].toUpperCase();
                     _loc13_ = "Skill" + _loc8_.join("");
                     if(param3)
                     {
                        _loc7_.cfg.fromPos = param3;
                     }
                     _loc14_ = getDefinitionByName("models.skills." + _loc13_) as Class;
                     if(_loc7_.skillId > 0)
                     {
                        _loc18_ = param1.level;
                        _loc9_ = param1.level2;
                        _loc6_ = param1.buff_add_level;
                        param1 = SkillModelManager.getIns().getSkillConfigVOByID(_loc7_.skillId).clone();
                        if(this.skillConfigVo && this.skillConfigVo.level > 1)
                        {
                           _loc18_ = this.skillConfigVo.level;
                           _loc9_ = this.skillConfigVo.level2;
                        }
                        param1.level = _loc18_;
                        param1.level2 = _loc9_;
                        param1.buff_add_level = _loc6_;
                        param1.updateBuff();
                     }
                     if(param4 && param4.cfg.inherit)
                     {
                        if(param4.cfg.hasOwnProperty("currAngle"))
                        {
                           _loc17_ = Number(_loc7_.cfg.shootSpeedX);
                           _loc7_.cfg.shootSpeedY = Math.sin(param4.cfg.currAngle) * _loc17_;
                           _loc7_.cfg.shootSpeedX = Math.cos(param4.cfg.currAngle) * _loc17_;
                        }
                     }
                     if(param4 && param4.cfg.inherit2)
                     {
                        if(param4.cfg.hasOwnProperty("currAngle2"))
                        {
                           _loc17_ = Number(_loc7_.cfg.shootSpeedX);
                           _loc19_ = Number(_loc7_.cfg.shootSpeedY);
                           _loc5_ = new Vector2D(_loc17_,_loc19_);
                           _loc10_ = _loc5_.length;
                           _loc15_ = Number(param4.cfg.currAngle2);
                           _loc5_.angle += _loc15_ / 180 * 3.141592653589793;
                           _loc7_.cfg.dir = 1;
                           _loc7_.cfg.shootSpeedY = Math.sin(_loc5_.angle) * _loc10_;
                           _loc7_.cfg.shootSpeedX = Math.cos(_loc5_.angle) * _loc10_;
                        }
                     }
                     this.skillControls.push(new _loc14_(this,_loc7_,param1.clone()));
                     _loc12_++;
                  }
               }
            }
         }
      }
      
      protected function canReleaseSkillParam() : Boolean
      {
         return false;
      }
      
      protected function checkZhaoHuan(param1:SkillConfigVO) : void
      {
         if(this.getType() == ManType.SKILL)
         {
            return;
         }
         createSonMonster(param1,null);
      }
      
      public function CreateSonMonster(param1:SkillConfigVO, param2:Vector2D, param3:int) : void
      {
         this.createSonMonster(param1,param2,param3);
      }
      
      protected function createSonMonster(param1:SkillConfigVO, param2:Vector2D, param3:int = 0) : void
      {
         var _loc8_:MonsterConfigVO = null;
         var _loc5_:UserVO = null;
         var _loc10_:Vector2D = null;
         var _loc7_:Object = null;
         var _loc6_:int = 0;
         var _loc11_:* = undefined;
         var _loc13_:int = 0;
         var _loc4_:CreateMonsterTrigger = null;
         var _loc12_:MonsterBirthVO = null;
         var _loc9_:int = 0;
         if(param1)
         {
            if(param1.summonMonster > 0)
            {
               _loc8_ = ManModelManager.getIns().getManById(param1.summonMonster,"monster") as MonsterConfigVO;
               _loc8_ = _loc8_.clone() as MonsterConfigVO;
               if(BattleModelManager.getIns().levelInfo && BattleModelManager.getIns().levelInfo.getIsV2())
               {
                  BattleModelManager.getIns().levelParam.logic.initMonsterConfig(_loc8_);
               }
               _loc5_ = UserVO.buildFrom(_loc8_);
               _loc5_.type = _loc8_.getType();
               _loc5_.charID = _loc8_.id;
               _loc5_.configVo = _loc8_;
               _loc5_.campId = this.userVo.campId;
               _loc5_.isRole = false;
               _loc5_.isPk = this.userVo.isPk;
               _loc5_.isQc = this.userVo.isQc;
               _loc5_.isLuoHan_ChenShi = this.userVo.isLuoHan_ChenShi;
               if(param1.layerIndex != 0)
               {
                  _loc5_.layerIndex = param1.layerIndex;
               }
               if(_loc5_.type == "monster")
               {
                  _loc5_.campId = 2;
               }
               if(this.userVo.type == "pet" || this.userVo.type == ManType.HORSE)
               {
                  _loc5_.campId = this.userVo.campId;
               }
               if(param1.campId != 0)
               {
                  _loc5_.campId = param1.campId;
               }
               onCreateUVOAtZhaoHuan(_loc5_);
               _loc5_.oldAtk = _loc5_.atk;
               _loc5_.father = this.userVo;
               _loc10_ = this.position.clone();
               if(this._body)
               {
                  _loc10_ = new Vector2D(this.bodyPosition.x,this.bodyPosition.y);
               }
               if(param1.summonCoord == null)
               {
                  param1.summonCoord = new Point();
               }
               _loc10_.x += param1.summonCoord.x * _direction;
               _loc10_.y += param1.summonCoord.y;
               if(param2 != null)
               {
                  _loc10_ = param2;
               }
               _loc7_ = {"scaleX":1};
               if(param3 != 0)
               {
                  _loc7_.scaleX = param3;
                  _loc7_.useDir = true;
               }
               _loc7_.parent = this;
               onCreatePOSAtZhaoHuan(_loc10_,param1,_loc7_);
               _loc6_ = -1;
               if(param1.summonMonsterInherit == 1)
               {
                  _loc6_ = 1;
               }
               if(this is MonsterEntity)
               {
                  try
                  {
                     _loc11_ = BattleModelManager.getIns().getCreateMonsterTrigger();
                     _loc13_ = 0;
                     while(_loc13_ < _loc11_.length)
                     {
                        _loc4_ = _loc11_[_loc13_];
                        _loc9_ = 0;
                        while(_loc9_ < _loc4_.monsterBirths.length)
                        {
                           _loc12_ = _loc4_.monsterBirths[_loc9_];
                           if(_loc12_.id == MonsterEntity(this).birthId)
                           {
                              if(_loc12_.properties && _loc12_.properties.hasOwnProperty("isIncludeSummon"))
                              {
                                 _loc6_ = _loc12_.id;
                              }
                              if(_loc12_.properties && _loc12_.properties.hasOwnProperty("isIncludeSummon_random"))
                              {
                                 _loc6_ = _loc12_.id;
                              }
                           }
                           _loc9_++;
                        }
                        _loc13_++;
                     }
                  }
                  catch(error:Error)
                  {
                     SimpleTextLog.getIns().log("erroer=============");
                  }
               }
               ApplicationFacade.getInstance().sendNotification("addMonster",{
                  "userVo":_loc5_,
                  "pos":_loc10_,
                  "birthId":_loc6_,
                  "parent":_loc7_.parent,
                  "buff":param1.summonBuff,
                  "scaleX":_loc7_.scaleX,
                  "obj":_loc7_
               });
               if(param1.summonBuff && param1.getRealLevel > 0)
               {
                  param1.updateBuffSummonBuff(param1.buff_add_level,-1);
               }
               BuffModelManager.getIns().createSummonBuf(_loc5_,param1.summonBuff);
            }
         }
      }
      
      protected function onCreateUVOAtZhaoHuan(param1:UserVO) : void
      {
      }
      
      protected function onCreatePOSAtZhaoHuan(param1:Vector2D, param2:SkillConfigVO, param3:Object) : void
      {
      }
      
      protected function checkMyBuff() : void
      {
         if(this.getType() == ManType.SKILL)
         {
            return;
         }
         createMyBuff();
      }
      
      public function createMyBuff() : void
      {
         var _loc1_:BuffConfigVO = null;
         if(this.skillConfigVo && this.skillConfigVo.myBuff)
         {
            _loc1_ = BuffModelManager.getIns().getBuffById(this.skillConfigVo.myBuff[0]);
            if(_loc1_ && _loc1_.type == 6)
            {
            }
            if(_loc1_)
            {
               BuffModelManager.getIns().createMyBuf(userVo,skillConfigVo);
            }
         }
      }
      
      public function createMyBuffBySkillConfigVo(param1:SkillConfigVO, param2:String = "") : void
      {
         var _loc3_:BuffConfigVO = null;
         if(param1 && param1.myBuff)
         {
            _loc3_ = BuffModelManager.getIns().getBuffById(param1.myBuff[0]);
            if(_loc3_ && _loc3_.type == 6)
            {
            }
            if(_loc3_)
            {
               BuffModelManager.getIns().createMyBuf(userVo,param1);
            }
         }
      }
      
      protected function toProtectSkill(param1:SkillConfigVO) : void
      {
      }
      
      private function removeBeahaviorAI() : void
      {
      }
      
      private function checkInFloat() : Boolean
      {
         return false;
      }
      
      public function inFloatRan() : Boolean
      {
         return false;
      }
      
      public function endCollide() : void
      {
      }
      
      public function getCollidedWidth(param1:ICollide) : Boolean
      {
         var _loc6_:SkillConfigVO = null;
         var _loc3_:int = 0;
         var _loc4_:Boolean = false;
         var _loc5_:int = 0;
         if(param1 is SkillEntity)
         {
            return false;
         }
         if(PlayerEntity(param1).userVo.type == ManType.SKILL)
         {
            return false;
         }
         if(__test)
         {
            if(Math.random() >= 0.9)
            {
               param1.collided(this,param1);
            }
         }
         if(PlayerEntity(param1).userVo && PlayerEntity(param1).userVo.isWuDi)
         {
            return false;
         }
         if(PlayerEntity(param1).userVo && PlayerEntity(param1).userVo.lockHp1)
         {
            return false;
         }
         if(PlayerEntity(param1).isWudiAction())
         {
            return false;
         }
         var _loc2_:Boolean = getIsAttacking();
         if(_loc2_)
         {
            if(!this.skillConfigVo)
            {
               return false;
            }
            _loc6_ = this.skillConfigVo;
            if(_loc6_.skySkill != null)
            {
               if(PlayerEntity(param1).onGround == false)
               {
               }
            }
            if(_loc6_.isAttOneMan > 0 && this.hurtOneMan)
            {
               return false;
            }
            if(this.hurtOnlyMan && hurtOnlyMan != param1)
            {
               return false;
            }
            if(_loc6_.alone == 1)
            {
               if(PlayerEntity(param1).getAttackedTotalNum(this.userVo.entitieId + "_" + Id,_loc6_.id) >= _loc6_.attMax)
               {
                  return false;
               }
            }
            else if(_loc6_.alone == 11)
            {
               if(PlayerEntity(param1).getAttackedTotalNum("alone11_" + this.userVo.entitieId + "_" + Id,_loc6_.id) >= _loc6_.attMax)
               {
                  return false;
               }
            }
            else if(PlayerEntity(param1).getAttackedTotalNum(this.userVo.entitieId.toString(),_loc6_.isSkySkill ? _loc6_.parent.id : _loc6_.id) >= _loc6_.attMax)
            {
               return false;
            }
            if(this._attackedSkillArr)
            {
               this._attackedSkillArr[PlayerEntity(param1).Id] = this._attackedSkillArr[PlayerEntity(param1).Id] || 0;
               if(this._attackedSkillArr[PlayerEntity(param1).Id] >= _loc6_.attMax)
               {
                  return false;
               }
            }
            if(!(_loc6_.hitRangeType == 2 || _loc6_.hitRangeType == 21))
            {
               _rec.width = _loc6_.rangeFront + Math.abs(_loc6_.rangeBehind);
               if(_direction == 1)
               {
                  _rec.x = this.position.x + _loc6_.rangeBehind;
               }
               else
               {
                  _rec.x = this.position.x - _loc6_.rangeFront;
               }
               if(Entity(param1).position.x < _rec.x || Entity(param1).position.x > _rec.x + _rec.width)
               {
               }
            }
            _loc3_ = BattleModelManager.getIns().getGameTimer() - PlayerEntity(param1).getAttackedTime(this.userVo.entitieId.toString(),_loc6_);
            if(_loc6_.alone == 1)
            {
               _loc3_ = BattleModelManager.getIns().getGameTimer() - PlayerEntity(param1).getAttackedTime(this.userVo.entitieId + "_" + Id,_loc6_);
            }
            else if(_loc6_.alone == 11)
            {
               _loc3_ = BattleModelManager.getIns().getGameTimer() - PlayerEntity(param1).getAttackedTime("alone11_" + this.userVo.entitieId + "_" + Id,_loc6_);
            }
            if(_loc3_ < _loc6_.attInterval)
            {
               return false;
            }
            if(PlayerEntity(param1).currentActionState == 100)
            {
               return false;
            }
            _loc4_ = hitTest(param1);
            if(this._mustHit)
            {
               _loc4_ = true;
            }
            _loc5_ = getNowAnimationcurrentFrame();
            if(_loc6_.hitRangeType == 2 && _loc5_ >= _loc6_.hitStartFrame)
            {
               _loc4_ = true;
            }
            else if(_loc6_.hitRangeType == 21 && _loc5_ >= _loc6_.hitStartFrame)
            {
               if(BattleModelManager.getIns().inViewPort(PlayerEntity(param1).position) && PlayerEntity(param1).onGround)
               {
                  _loc4_ = true;
               }
            }
            if(_loc4_)
            {
               if(_loc6_.alone == 1)
               {
                  PlayerEntity(param1).setAttackedTime(this.userVo.entitieId + "_" + Id,_loc6_,BattleModelManager.getIns().getGameTimer());
                  if(this._attackedSkillArr)
                  {
                     this._attackedSkillArr[PlayerEntity(param1).Id] = this._attackedSkillArr[PlayerEntity(param1).Id] || 0;
                     this._attackedSkillArr[PlayerEntity(param1).Id]++;
                  }
               }
               else if(_loc6_.alone == 11)
               {
                  PlayerEntity(param1).setAttackedTime("alone11_" + this.userVo.entitieId + "_" + Id,_loc6_,BattleModelManager.getIns().getGameTimer());
                  if(this._attackedSkillArr)
                  {
                     this._attackedSkillArr[PlayerEntity(param1).Id] = this._attackedSkillArr[PlayerEntity(param1).Id] || 0;
                     this._attackedSkillArr[PlayerEntity(param1).Id]++;
                  }
               }
               else
               {
                  PlayerEntity(param1).setAttackedTime(this.userVo.entitieId.toString(),_loc6_,BattleModelManager.getIns().getGameTimer());
               }
               return _loc4_;
            }
         }
         return false;
      }
      
      public function setHitTest(param1:Boolean) : void
      {
         _mustHit = true;
      }
      
      private function aabbCollisionTest(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number, param8:Number) : Boolean
      {
         var _loc9_:Boolean = param1 <= param5 + param7;
         var _loc10_:Boolean = param1 + param3 >= param5;
         var _loc11_:Boolean = param2 <= param6 + param8;
         var _loc12_:Boolean = param2 + param4 >= param6;
         return _loc9_ && _loc10_ && _loc11_ && _loc12_;
      }
      
      protected function hitTest(param1:ICollide) : Boolean
      {
         var _loc2_:Boolean = false;
         var _loc10_:Boolean = BattleModelManager.showAbHb;
         var _loc6_:Bitmap = getAttackBp();
         var _loc7_:Bitmap = param1.getHitBox();
         if(!_loc6_.bitmapData || !_loc7_.bitmapData)
         {
            if(!_loc10_)
            {
               _loc6_.bitmapData = null;
               _loc7_.bitmapData = null;
            }
            return _loc2_;
         }
         if(_loc10_)
         {
            GameFrame.stage.addChild(_loc6_);
            GameFrame.stage.addChild(_loc7_);
         }
         var _loc8_:Rectangle = _loc6_.getBounds(_loc6_);
         var _loc9_:Rectangle = _loc7_.getBounds(_loc7_);
         var _loc4_:Rectangle = _loc8_.intersection(_loc9_);
         if(_loc4_.width == 0 && _loc4_.height == 0)
         {
            _loc8_ = null;
            _loc9_ = null;
            return false;
         }
         _loc8_ = null;
         _loc9_ = null;
         var _loc5_:Point = new Point(_loc6_.x,_loc6_.y);
         var _loc3_:Point = new Point(_loc7_.x,_loc7_.y);
         _loc2_ = _loc6_.bitmapData.hitTest(_loc5_,1,_loc7_.bitmapData,_loc3_,1);
         if(!_loc10_)
         {
            _loc6_.bitmapData = null;
            _loc7_.bitmapData = null;
         }
         _loc5_ = null;
         _loc3_ = null;
         if(_loc2_)
         {
            if(this.userVo.isPKBoss && this.userVo.isFriend)
            {
               if(Math.random() < 0.95)
               {
                  _loc2_ = false;
               }
            }
         }
         return _loc2_;
      }
      
      public function getAttackBp() : Bitmap
      {
         var _loc1_:Texture = null;
         var _loc2_:Vector.<Texture> = getABTextureByActionState(_actionState);
         var _loc3_:int = getNowAnimationcurrentFrame();
         if(_loc3_ >= _loc2_.length)
         {
            _loc3_ = _loc2_.length - 1;
         }
         if(_loc3_ >= 0)
         {
            _loc1_ = _loc2_[_loc3_];
            onGetABBox(_actionState,_loc2_,_loc3_,_ab);
            onGetabbPOS(_ab,_loc1_.pivot);
         }
         else
         {
            _ab.bitmapData = BitmapUtils.EMPTY;
         }
         return _ab;
      }
      
      protected function onGetabbPOS(param1:Bitmap, param2:Point) : void
      {
      }
      
      public function getHitBox() : Bitmap
      {
         var _loc1_:Vector.<Texture> = getHBTextureByActionState(_actionState);
         var _loc2_:int = getNowAnimationcurrentFrame();
         if(!_loc1_)
         {
            _loc1_ = new Vector.<Texture>();
         }
         if(_loc2_ >= _loc1_.length)
         {
            if(_loc1_.length == 0)
            {
               _hb.bitmapData = BitmapUtils.EMPTY;
               return _hb;
            }
            _loc2_ = _loc1_.length - 1;
         }
         onGetABBox(_actionState,_loc1_,_loc2_,_hb);
         return _hb;
      }
      
      protected function onGetABBox(param1:int, param2:Vector.<Texture>, param3:int, param4:Bitmap) : void
      {
         var _loc5_:Texture = param2[param3];
         param4.bitmapData = _loc5_.bd;
         param4.x = _position.x + _loc5_.pivot.x;
         param4.y = _position.y + _loc5_.pivot.y - 0;
      }
      
      public function getAnimationCurrentFrame() : int
      {
         return _nowAnimation.currentFrame;
      }
      
      public function isDeleteCollide() : Boolean
      {
         return false;
      }
      
      public function startCollide() : void
      {
      }
      
      public function getIsAttacking() : Boolean
      {
         if(_actionState == 41 || _actionState == 42 || _actionState == 43 || _actionState == 44 || _actionState == 45 || _actionState == 46 || _actionState == 61 || _actionState == 71 || _actionState == 711 || _actionState == 712 || _actionState == 713 || _actionState == 714 || _actionState == 715 || _actionState == 72 || _actionState == 73 || _actionState == 731 || _actionState == 732 || _actionState == 733 || _actionState == 734 || _actionState == 735 || _actionState == 74 || _actionState == 741 || _actionState == 75 || _actionState == 756 || _actionState == ActionState.EFFECT_SZ)
         {
            return true;
         }
         return false;
      }
      
      public function getAttackedTime(param1:String, param2:SkillConfigVO) : int
      {
         if(!_lastAttackTime[param1])
         {
            _lastAttackTime[param1] = {};
         }
         if(_lastAttackTime[param1].hasOwnProperty(param2.id) == false)
         {
            _lastAttackTime[param1][param2.id] = 0;
         }
         return _lastAttackTime[param1][param2.id];
      }
      
      public function getAttackedTotalNum(param1:String, param2:int) : int
      {
         if(!_attackedTotalNum[param1])
         {
            _attackedTotalNum[param1] = {};
            _attackedTotalNum[param1][param2] = 0;
         }
         return _attackedTotalNum[param1][param2];
      }
      
      public function setAttackedTime(param1:String, param2:SkillConfigVO, param3:int) : void
      {
         if(!_lastAttackTime[param1])
         {
            _lastAttackTime[param1] = {};
         }
         _lastAttackTime[param1][param2.id] = param3;
      }
      
      override public function setAttackedTotalNum(param1:String, param2:int, param3:int) : void
      {
         if(!_attackedTotalNum[param1])
         {
            _attackedTotalNum[param1] = [];
         }
         if(!_attackedTotalNum[param1][param2])
         {
            _attackedTotalNum[param1][param2] = 0;
         }
         if(param3 == 1)
         {
            _attackedTotalNum[param1][param2]++;
         }
         else
         {
            for(var _loc4_:String in _attackedTotalNum)
            {
               if(_loc4_.indexOf(param1) == 0)
               {
                  _attackedTotalNum[_loc4_][param2] = param3;
               }
            }
         }
      }
      
      private function getNeedStiff(param1:SkillConfigVO) : Boolean
      {
         if(param1 && param1.stiff == 0)
         {
            if(!param1.targetMove)
            {
               return false;
            }
            if(param1.targetMove.x == 0 && param1.targetMove.y == 0)
            {
               return false;
            }
         }
         return true;
      }
      
      public function stiff(... rest) : void
      {
         var _loc3_:SkillConfigVO = rest[0];
         if(!getNeedStiff(_loc3_))
         {
            return;
         }
         if(_loc3_ && _loc3_.stiff == 0)
         {
            if(!_loc3_.targetMove)
            {
               return;
            }
            if(_loc3_.targetMove.x == 0 && _loc3_.targetMove.y == 0)
            {
               return;
            }
         }
         if(_stiffTimer)
         {
            _stiffTimer.destroy();
            _stiffTimer = null;
         }
         var _loc2_:Number = _loc3_.stiff;
         if(_isWuShuan)
         {
            _loc2_ /= 2;
         }
         _stiffTimer = new Timer(handStiffComplete,_loc2_,1);
         _stiffTimer.start();
         if(_AI && _AI.parentNode is AttackSeqSeqNode)
         {
            _AI.pause();
         }
         else if(_loc2_ > 0)
         {
            isReadyCanAI = false;
            if(_AI)
            {
               _AI.clear();
            }
         }
      }
      
      public function clearStiff() : void
      {
         if(_stiffTimer)
         {
            _stiffTimer.destroy();
            _stiffTimer = null;
         }
         if(_isDie == false)
         {
            idle();
         }
         if(_onGround || _inWater)
         {
            if(_AI && _AI.isPause)
            {
               _AI.start();
            }
            else if(!isCloseAI)
            {
               isReadyCanAI = true;
            }
         }
         else if(this.getMoveType() == 2 || this.getMoveType() == 4)
         {
            if(_AI && _AI.isPause)
            {
               _AI.start();
            }
            else if(!isCloseAI)
            {
               isReadyCanAI = true;
            }
         }
      }
      
      override public function handOnFloor(param1:InteractionCallback) : void
      {
         super.handOnFloor(param1);
         if(_onGround && _stiffTimer == null)
         {
            if(_AI && _AI.isPause)
            {
               _AI.start();
            }
            else if(!isCloseAI)
            {
               isReadyCanAI = true;
            }
         }
         else if(this.getMoveType() == 2)
         {
            if(_AI && _AI.isPause)
            {
               _AI.start();
            }
            else if(!isCloseAI)
            {
               isReadyCanAI = true;
            }
         }
      }
      
      private function handStiffComplete() : void
      {
         if(deleted || isDie)
         {
            return;
         }
         clearStiff();
      }
      
      public function fly(param1:*) : void
      {
         if(_actionState == 51)
         {
            return;
         }
         _isPauseJump = true;
      }
      
      override public function handKey(param1:uint, param2:int) : void
      {
         var _loc17_:String = null;
         var _loc14_:* = 0;
         var _loc4_:String = null;
         var _loc13_:* = 0;
         var _loc11_:Vec2 = null;
         var _loc8_:Boolean = false;
         var _loc5_:Boolean = false;
         var _loc15_:int = 0;
         _loc15_ = 0;
         var _loc16_:* = undefined;
         var _loc3_:Array = null;
         var _loc12_:int = 0;
         var _loc6_:ItemVo = null;
         var _loc7_:ItemVo = null;
         var _loc10_:PropVo = null;
         var _loc9_:Object = null;
         if(deleted || isDie || canuseKey == false)
         {
            return;
         }
         if(_buff_yuan_xian && this.userVo)
         {
            if(canuseMagic)
            {
               super.handKey(param1,param2);
               this.onKeyDown(param1);
            }
            return;
         }
         if(userVo)
         {
            if(userVo.isDie && getType() != ManType.SKILL)
            {
               return;
            }
         }
         if(_hurtDelayTimer)
         {
            return;
         }
         super.handKey(param1,param2);
         if(param2 == 1)
         {
            _loc14_ = 0;
            _loc13_ = 0;
            if(userVo)
            {
               _loc14_ = uint(userVo.keyBoard.getKeyCodeByAction(41));
               _loc13_ = uint(userVo.keyBoard.getKey2CodeByAction(41));
            }
            if(BattleModelManager.getIns().levelInfo && BattleModelManager.getIns().levelInfo.isCanAttackSkill() == false)
            {
               _loc14_ = 0;
               _loc13_ = 0;
            }
            if(_loc14_ > 0)
            {
               _loc17_ = keyboard.getKeyName(_loc14_);
            }
            else
            {
               _loc17_ = "J";
            }
            if(_loc14_ == param1)
            {
               if(keyboard.justPressed(_loc17_))
               {
                  if(canAttack || canAttack2)
                  {
                     if(userVo.isPk && userVo.campId != 1)
                     {
                        attack();
                     }
                     else
                     {
                        attack();
                     }
                  }
               }
            }
            if(_loc13_ > 0)
            {
               _loc4_ = keyboard.getKeyName(_loc13_);
            }
            else
            {
               _loc4_ = "J";
            }
            if(_loc13_ == param1)
            {
               if(keyboard.justPressed(_loc4_))
               {
                  if(canAttack || canAttack2)
                  {
                     if(userVo.isPk && userVo.campId != 1)
                     {
                        attack();
                     }
                     else
                     {
                        attack();
                     }
                  }
               }
            }
            _loc11_ = _body.velocity;
            _loc8_ = false;
            if(userVo)
            {
               _loc14_ = uint(userVo.keyBoard.getKeyCodeByAction(21));
               _loc13_ = uint(userVo.keyBoard.getKey2CodeByAction(21));
            }
            if(_loc14_ > 0)
            {
               _loc17_ = keyboard.getKeyName(_loc14_);
            }
            if(_loc17_ != null)
            {
               _loc8_ = keyboard.pressed(_loc17_);
               if(!_loc8_ && _loc13_ > 0)
               {
                  _loc17_ = keyboard.getKeyName(_loc13_);
                  if(_loc17_ != null)
                  {
                     _loc8_ = keyboard.pressed(_loc17_);
                  }
               }
            }
            _loc14_ = 0;
            if(userVo)
            {
               _loc14_ = uint(userVo.keyBoard.getKeyCodeByAction(6));
               _loc13_ = uint(userVo.keyBoard.getKey2CodeByAction(6));
            }
            if(_loc14_ == 0)
            {
               _loc14_ = 75;
            }
            _loc5_ = param1 == _loc14_;
            if(!_loc5_ && _loc13_ > 0)
            {
               _loc5_ = param1 == _loc13_;
            }
            if(!_onGround && getStayInSky() && _loc5_ && _isJump == false && _loc8_ == false)
            {
               cancelStayInSKy();
            }
            else if(_onGround && _loc5_ && _isJump == false && _loc8_ == false && _inWater == false)
            {
               if(getStayInSky())
               {
                  cancelStayInSKy();
               }
               if(canJump)
               {
                  if(_inWater)
                  {
                     _loc11_.y = -(_jump1HeightMaxWater + _addJumpVelocity.y);
                     if(_additionalMaxVelocity.length > 0)
                     {
                        _additionalMaxVelocity.y = -(_additionalMaxVelocity.y + _addJumpVelocity.y);
                     }
                  }
                  else
                  {
                     _loc11_.y = -(_jump1HeightMaxLand + _addJumpVelocity.y);
                     if(_additionalMaxVelocity.length > 0)
                     {
                        _loc11_.y = -(_additionalMaxVelocity.y + _addJumpVelocity.y);
                     }
                  }
                  maxVelocity.y = Math.abs(_loc11_.y);
                  _onGround = false;
                  gotoJump();
               }
            }
            else if(_onGround == false && _isJump == false && _isJump2 == false && _isJump3 == false && _loc5_ && _loc8_ == false && _inWater == false)
            {
               if(getStayInSky())
               {
                  cancelStayInSKy();
               }
               if(canJump)
               {
                  resetFloor();
                  if(_inWater)
                  {
                     _loc11_.y = -(_jump1HeightMaxWater + _addJumpVelocity.y);
                     if(_additionalMaxVelocity.length > 0)
                     {
                        _additionalMaxVelocity.y = -(_additionalMaxVelocity.y + _addJumpVelocity.y);
                     }
                  }
                  else
                  {
                     _loc11_.y = -(_jump1HeightMaxLand + _addJumpVelocity.y);
                     if(_additionalMaxVelocity.length > 0)
                     {
                        _loc11_.y = -(_additionalMaxVelocity.y + _addJumpVelocity.y);
                     }
                  }
                  maxVelocity.y = Math.abs(_loc11_.y);
                  _onGround = false;
                  gotoJump();
               }
            }
            else if(_onGround == false && _isJump == true && _isJump2 == false && _isJump3 == false && _loc5_ && _loc8_ == false && _inWater == false)
            {
               if(getStayInSky())
               {
                  cancelStayInSKy();
               }
               if(canJump)
               {
                  if(_inWater)
                  {
                     _loc11_.y = -(_jump2HeightMaxWater + _addJumpVelocity.y);
                     _isJump = true;
                  }
                  else
                  {
                     _loc11_.y = -(_jump2HeightMaxLand + _addJumpVelocity.y);
                     _isJump2 = true;
                  }
                  maxVelocity.y = Math.abs(_loc11_.y);
                  gotoJump();
               }
            }
            else if(_onGround == false && _isJump2 == true && _isJump3 == false && _loc5_ && _loc8_ == false && _inWater == false)
            {
               if(canJump && canJump3())
               {
                  if(_inWater)
                  {
                     _loc11_.y = -(_jump2HeightMaxWater + _addJumpVelocity.y);
                     _isJump = true;
                  }
                  else
                  {
                     _loc11_.y = -(_jump2HeightMaxLand + _addJumpVelocity.y);
                     _isJump3 = true;
                  }
                  maxVelocity.y = Math.abs(_loc11_.y);
                  gotoJump();
               }
            }
            else if(_loc5_ && _inWater)
            {
               if(canJump)
               {
                  _loc11_.y = -(_jump1HeightMaxWater + _addJumpVelocity.y);
                  _isJump = false;
                  maxVelocity.y = Math.abs(_loc11_.y);
                  gotoJump();
               }
            }
            if(userVo && userVo.mode == 2 && param2 == 1)
            {
               if(userVo.isCatchingPet)
               {
                  return;
               }
               _loc15_ = int(KeySetVO["SKILL_KEY" + userVo.ps].indexOf(param1));
               if(_loc15_ == -1)
               {
                  if(this.userVo.keyBoard2)
                  {
                     if(userVo.ps == 1)
                     {
                        _loc15_ = int(KeySetVO["SKILL_KEY2"].indexOf(param1));
                     }
                     else if(userVo.ps == 2)
                     {
                        _loc15_ = int(KeySetVO["SKILL_KEY1"].indexOf(param1));
                     }
                  }
               }
               if(_loc15_ == -1)
               {
                  onKeyDown(param1);
                  return;
               }
               keyboard.reset();
               keyControl.reset();
               userVo.isCatchingPet = true;
               ApplicationFacade.getInstance().sendNotification("cmdCatchPet",{
                  "user":this.userVo,
                  "key":param1,
                  "pos":this.display.localToGlobal(new Point()),
                  "dir":this.direction
               });
            }
            else if(userVo && userVo.mode == 3 && param2 == 1)
            {
               if(BattleModelManager.getIns().levelInfo && BattleModelManager.getIns().levelInfo.isCanAttackSkill() == false)
               {
                  return;
               }
               _loc15_ = int(KeySetVO["SKILL_KEY" + userVo.ps].indexOf(param1));
               if(_loc15_ == -1)
               {
                  if(this.userVo.keyBoard2)
                  {
                     if(userVo.ps == 1)
                     {
                        _loc15_ = int(KeySetVO["SKILL_KEY2"].indexOf(param1));
                     }
                     else if(userVo.ps == 2)
                     {
                        _loc15_ = int(KeySetVO["SKILL_KEY1"].indexOf(param1));
                     }
                  }
               }
               if(_loc15_ == -1)
               {
                  onKeyDown(param1);
                  return;
               }
               keyboard.reset();
               keyControl.reset();
               _loc16_ = UserModelManager.getIns().getCurretPlayerInfo().itemsBag.getItemByPropType(27);
               if(BattleModelManager.getIns().levelInfo)
               {
                  _loc3_ = BattleModelManager.getIns().levelInfo.canCarryItemIds;
                  if(_loc3_)
                  {
                     _loc16_.length = 0;
                     _loc12_ = 0;
                     while(_loc12_ < _loc3_.length)
                     {
                        _loc6_ = UserModelManager.getIns().getCurretPlayerInfo().itemsBag.hasItemById(_loc3_[_loc12_]);
                        if(_loc6_)
                        {
                           _loc16_.push(_loc6_);
                        }
                        _loc12_++;
                     }
                  }
               }
               if(_loc16_.length <= _loc15_ || _loc16_.length == 0)
               {
                  return;
               }
               _loc7_ = _loc16_[_loc15_];
               _loc10_ = ItemVoManager.getIns().getPropVoById(_loc7_.id);
               _loc9_ = {
                  "way":1,
                  "itemId":_loc10_.id,
                  "propType":_loc10_.propType,
                  "pNum":this.userVo.ps,
                  "user":this.userVo
               };
               this.onCheckKeyDownUseItem(_loc9_);
            }
            else
            {
               onKeyDown(param1);
            }
         }
      }
      
      protected function onCheckKeyDownUseItem(param1:Object) : void
      {
         ApplicationFacade.getInstance().sendNotification("cmdUseSummonItem",param1);
      }
      
      protected function onKeyDown(param1:uint) : void
      {
      }
      
      override public function get canJump() : Boolean
      {
         if(this.isRole && _jump2HeightMax == 0)
         {
            if(_isJump)
            {
               return false;
            }
         }
         var _loc1_:Boolean = super.canJump;
         _loc1_ = _loc1_ && !_buff_jing_zu && !_canNotMJSBuff;
         if(_loc1_)
         {
            if(hasBuffType(87))
            {
               _loc1_ = false;
            }
            if(hasBuffType(3))
            {
               _loc1_ = false;
            }
         }
         if(this._canNotJumps.length > 0)
         {
            return false;
         }
         return _loc1_;
      }
      
      override public function getCanMove() : Boolean
      {
         if(_canNotMJSBuff)
         {
            return false;
         }
         return super.getCanMove();
      }
      
      public function setTestSkill(param1:SkillConfigVO) : void
      {
         _skillConfigVo = param1;
      }
      
      public function addBuff(param1:BuffVO, param2:BuffEffectEntity) : void
      {
         var _loc17_:Vector2D = null;
         var _loc16_:int = 0;
         var _loc6_:Vector2D = null;
         var _loc15_:Vector2D = null;
         _loc16_ = 0;
         var _loc19_:int = 0;
         var _loc13_:Vector2D = null;
         _loc13_ = null;
         _loc13_ = null;
         var _loc9_:Number = NaN;
         var _loc14_:int = 0;
         _loc9_ = NaN;
         _loc14_ = 0;
         _loc14_ = 0;
         var _loc10_:int = 0;
         _loc10_ = 0;
         var _loc21_:SkillConfigVO = null;
         var _loc5_:Number = NaN;
         var _loc18_:BuffVO = null;
         var _loc7_:BuffVO = null;
         var _loc3_:int = 0;
         var _loc20_:ColorTransform = null;
         _loc14_ = 0;
         var _loc11_:int = 0;
         var _loc8_:BuffVO = null;
         var _loc12_:UserVO = null;
         if(deleted || isDie)
         {
            return;
         }
         var _loc22_:int = param1.config.orderDisplay;
         if(_loc22_ == 0)
         {
            _loc22_ = 1;
         }
         if(_loc22_ == 1)
         {
            getDisplayLayer(1).addChild(param2);
         }
         else
         {
            getDisplayLayer(0).addChildAt(param2,0);
         }
         _buffs.push(param1);
         var _loc23_:PlayerEntity = BattleModelManager.getIns().getPlayerByEntityId(param1.attackId) as PlayerEntity;
         if(!_loc23_)
         {
            _loc23_ = BattleModelManager.getIns().getOtherByEId(param1.attackId) as PlayerEntity;
         }
         if(param1.config.type == 6)
         {
            _buff_ba_ti = true;
            this._buff_ba_tins.push(param1);
         }
         else if(param1.config.type == 1)
         {
            if(!(BattleModelManager.getIns().levelInfo && BattleModelManager.getIns().levelInfo.isRoleNeedWudiEffect() == false && this.userVo && this.userVo.type == "role"))
            {
               this.display.alpha = 0.5;
            }
            _isUnbeatable = true;
         }
         else if(param1.config.type == 61)
         {
            _buff_ba_tis.push(param1);
         }
         if(param1.config.type == 11)
         {
            if(!getIsMigration() && (userVo.type == "monster" || userVo.type == "npc"))
            {
               return;
            }
            if(!_loc23_)
            {
               return;
            }
            _loc17_ = _loc23_.position.subtract(this.position);
            _loc16_ = 1;
            if(_loc17_.x < 0)
            {
               _loc16_ = -1;
            }
            _additionalVelocity.setxy(0,0);
            if(param1.config.attributeT == "xSpeed")
            {
               _additionalVelocity.x = param1.config.attributeV1 * _loc16_;
               maxVelocity.x = param1.config.attributeV1;
            }
            else if(param1.config.attributeT == "ySpeed")
            {
               _additionalVelocity.y = param1.config.attributeV1 * _loc16_;
               maxVelocity.y = param1.config.attributeV1;
            }
            setMaterial(0,0);
            _buff_xi_ying = param1;
         }
         else if(param1.config.type == 111)
         {
            if(!getIsMigration() && (userVo.type == "monster" || userVo.type == "npc"))
            {
               return;
            }
            if(!_loc23_)
            {
               return;
            }
            _loc6_ = _loc23_.position.clone();
            if(attackMan)
            {
               _loc6_ = attackMan.position.clone();
            }
            _loc15_ = this.position.clone();
            try
            {
               if(RoleConfigVO(this.manConfigVo).locateCenter)
               {
                  _loc15_.x += this.direction * RoleConfigVO(MonsterEntity(this).manConfigVo).locateCenter.x;
                  _loc15_.y += RoleConfigVO(MonsterEntity(this).manConfigVo).locateCenter.y;
               }
               if(param1.config.offset)
               {
                  _loc6_.x += _loc23_.direction * param1.config.offset.x;
                  _loc6_.y += param1.config.offset.y;
               }
            }
            catch(error:Error)
            {
            }
            _loc17_ = _loc6_.subtract(_loc15_);
            _loc16_ = 1;
            if(_loc17_.x < 0)
            {
               _loc16_ = -1;
            }
            _loc19_ = 1;
            if(_loc17_.y < 0)
            {
               _loc19_ = -1;
            }
            if(param1.config.attributeT == "xSpeed")
            {
               _additionalVelocity.x = 0;
               _additionalVelocity.x = param1.config.attributeV1 * _loc16_;
               maxVelocity.x = param1.config.attributeV1;
            }
            else if(param1.config.attributeT == "ySpeed")
            {
               _additionalVelocity.y = 0;
               if(_loc19_ == 1)
               {
                  _additionalVelocity.y = param1.config.attributeV2 * _loc19_;
                  maxVelocity.y = param1.config.attributeV2;
               }
               else
               {
                  _additionalVelocity.y = param1.config.attributeV1 * _loc19_;
                  maxVelocity.y = param1.config.attributeV1;
               }
            }
            _buff_xi_ying111s.push(param1);
         }
         else if(param1.config.type == 17)
         {
            if(!getIsMigration() && (userVo.type == "monster" || userVo.type == "npc"))
            {
               return;
            }
            if(!_loc23_)
            {
               return;
            }
            if(getType() == ManType.SKILL)
            {
               return;
            }
            _body.velocity.setxy(0,0);
            _loc13_ = _loc23_.position.clone();
            if(param1.config.offset)
            {
               _loc13_.x += _loc23_.direction * param1.config.offset.x;
               _loc13_.y += param1.config.offset.y;
            }
            if(_loc13_.x <= BattleModelManager.getIns().stagePort.x)
            {
               _loc13_.x = BattleModelManager.getIns().stagePort.x + 20;
               if(param1.config.offset)
               {
                  _loc13_.x += param1.config.offset.x;
               }
            }
            else if(_loc13_.x >= BattleModelManager.getIns().stagePort.width)
            {
               _loc13_.x = BattleModelManager.getIns().stagePort.width - 20;
               if(param1.config.offset)
               {
                  _loc13_.x -= param1.config.offset.x;
               }
            }
            _loc17_ = _loc13_.subtract(this.position);
            updateXIYing(_loc17_,param1);
            setMaterial(0,0);
            _body.gravMass = 0;
            _gravMass0Num = _gravMass0Num + 1;
            if(this.userVo.type == "role")
            {
               _body.shapes.at(0).filter.collisionMask = 0x0400 | 0x0800 | 0x2000 | 0x4000;
               if(_body.shapes.length > 1)
               {
                  _body.shapes.at(1).filter.collisionMask = 0x0400 | 0x0800 | 0x2000 | 0x4000;
               }
            }
            else
            {
               _body.shapes.at(0).filter.collisionMask = 0x0400 | 0x0800 | 0x2000;
               if(_body.shapes.length > 1)
               {
                  _body.shapes.at(1).filter.collisionMask = 0x0400 | 0x0800 | 0x2000;
               }
            }
            _buff_xi_ying2 = param1;
            _xi_ying2AI = new XiYingAI(this,_loc13_,param1,param1.config.attributeV1);
         }
         else if(param1.config.type == 171)
         {
            if(!getIsMigration() && (userVo.type == "monster" || userVo.type == "npc"))
            {
               return;
            }
            if(!_loc23_)
            {
               return;
            }
            if(getType() == ManType.SKILL)
            {
               return;
            }
            _loc13_ = _loc23_.position.clone();
            if(_attackPosition && isNaN(_attackPosition.x) == false && isNaN(_attackPosition.y) == false)
            {
               _loc13_ = _attackPosition.clone();
            }
            if(param1.config.offset)
            {
               _loc13_.x += _loc23_.direction * param1.config.offset.x;
               _loc13_.y += param1.config.offset.y;
            }
            _xi_ying3AIs.push(new XiYing3AI(this,_loc13_,param1));
         }
         else if(param1.config.type == 172)
         {
            if(!getIsMigration() && (userVo.type == "monster" || userVo.type == "npc"))
            {
               return;
            }
            if(!_loc23_)
            {
               return;
            }
            if(getType() == ManType.SKILL)
            {
               return;
            }
            _loc13_ = _loc23_.position.clone();
            if(_attackPosition && isNaN(_attackPosition.x) == false && isNaN(_attackPosition.y) == false)
            {
               _loc13_ = _attackPosition.clone();
            }
            if(param1.config.offset)
            {
               _loc13_.x += _loc23_.direction * param1.config.offset.x;
               _loc13_.y += param1.config.offset.y;
            }
            _tuiAI = new TuiAI(this,_loc23_,param1);
         }
         else if(param1.config.type == 15)
         {
            _buff_fang_shang = param1;
            _buff_fang_shang_ = true;
         }
         else if(param1.config.type == 151)
         {
            _buff_fang_shang151 = param1;
         }
         else if(param1.config.type == 18)
         {
            userVo.buff_gaiLiArr.push(param1);
         }
         else if(param1.config.type == 181)
         {
            userVo.buff_gaiLiHurtArr.push(param1);
         }
         else if(param1.config.type == 19)
         {
            _oldUservo.buff_dmg_rate_on_hurtMan.push(param1);
         }
         else if(param1.config.type == 43)
         {
            _oldUservo.buff_sleep_on_hurtMan = param1;
         }
         else if(param1.config.type == 21)
         {
            if(param1.config.attributeT == "speed")
            {
               param1.oldData = [int(param1.config.attributeV1 * _walkX_accelerationMax),int(param1.config.attributeV1 * _walkY_accelerationMax),int(param1.config.attributeV1 * _run_accelerationMax)];
               _walkX_accelerationMax += param1.oldData[0];
               _walkY_accelerationMax += param1.oldData[1];
               _run_accelerationMax += param1.oldData[2];
            }
         }
         else if(param1.config.type == 22)
         {
            BattleMap.Ins.addMask(userVo,param1.attackId);
         }
         else if(param1.config.type == 221)
         {
            if(this.userVo.type == "role")
            {
               BattleMap.Ins.addMask(userVo,param1.attackId,false);
            }
         }
         else if(param1.config.type == 23)
         {
            _oldUservo.buff_dmg_rate_on_attMan = param1;
         }
         else if(param1.config.type == 231)
         {
            _oldUservo.buff_dmg_rate_on_attMan2.push(param1);
         }
         else if(param1.config.type == 97)
         {
            _oldUservo.buff_dmg_rate_on_attMan3.push(param1);
         }
         else if(param1.config.type == 32)
         {
            userVo.buff_cannot_equip = param1;
            if(this.userVo.type == "role")
            {
               BuffSceneManager.getIns().RemovePlayerBuffs();
               userVo.refreshRole();
               onAddCanNotEquip();
            }
         }
         else if(param1.config.type == 3)
         {
            _buff_jing_zu = true;
         }
         else if(param1.config.type == 4)
         {
            _buff_cheng_mo = true;
            this.chengMoCount++;
         }
         else if(param1.config.type == 2 && isCanYuanXian())
         {
            _buff_yuan_xian = true;
            keyboard.reset();
            keyControl.reset();
            this.yunXianCount++;
         }
         else if(param1.config.type == 29 && isCanYuanXian())
         {
            if(_loc23_)
            {
               if(this.direction == _loc23_.direction)
               {
                  param2.visible = false;
                  return;
               }
            }
            _buff_yuan_xian = true;
            keyboard.reset();
            keyControl.reset();
            this.yunXianCount++;
         }
         else if(param1.config.type == 24)
         {
            this.userVo.canAddHp = false;
         }
         else if(param1.config.type == 26)
         {
            _loc9_ = 0;
            _buff_addhp_hu_dunVo = param1;
            if(param1.config.attributeT == "hp")
            {
               _loc14_ = param1.config.attributeV1 * this.userVo.atk + param1.config.attributeV2;
               if(this.userVo.isPk || this.userVo.isQc)
               {
                  _loc14_ *= CommonConfig.pkReHpRate;
               }
               if(this.userVo.canAddHp == false)
               {
                  _loc14_ = 0;
               }
               _loc14_ = this.userVo.getHpValue(_loc14_);
               _loc9_ = this.userVo.hp + _loc14_ - this.userVo.hpMax;
               if(_loc14_ > 0)
               {
                  this.userVo.updateHP(_loc14_,false);
                  ApplicationFacade.getInstance().sendNotification("nfEntityHurtAuto",{
                     "userVo":this.userVo,
                     "hp":_loc14_,
                     "from":"t3"
                  });
               }
            }
            this._buff_hu_dun = true;
            if(_loc9_ > 0)
            {
               this._buff_hu_dun_hp = _loc9_ * param1.config.attributeV3;
            }
            else
            {
               this._buff_hu_dun_hp = 0;
               if(_buff_addhp_hu_dunVo)
               {
                  _buff_addhp_hu_dunVo.totalTime = 0;
               }
            }
         }
         else if(param1.config.type == 116)
         {
            _loc9_ = 0;
            if(param1.config.attributeT == "hp")
            {
               _loc14_ = param1.config.attributeV1 * this.userVo.allhpMax + param1.config.attributeV2;
               if(this.userVo.isPk || this.userVo.isQc)
               {
                  _loc14_ *= CommonConfig.pkReHpRate;
               }
               if(this.userVo.canAddHp == false)
               {
                  _loc14_ = 0;
               }
               _loc14_ = this.userVo.getHpValue(_loc14_);
               _loc9_ = this.userVo.hp + _loc14_ - this.userVo.allhpMax;
               if(_loc14_ > 0)
               {
                  this.userVo.updateHP(_loc14_,false);
                  ApplicationFacade.getInstance().sendNotification("nfEntityHurtAuto",{
                     "userVo":this.userVo,
                     "hp":_loc14_,
                     "from":"t3"
                  });
               }
               if(_loc9_ > 0)
               {
                  param1.value = _loc9_ * param1.config.attributeV3;
                  this.hu_dun_buff_canReduceHp.push(param1);
               }
            }
            else if(param1.config.attributeT == "mp")
            {
               _loc14_ = param1.config.attributeV1 * this.userVo.allmpMax + param1.config.attributeV2;
               if(this.userVo.isPk || this.userVo.isQc)
               {
                  _loc14_ *= CommonConfig.pkReHpRate;
               }
               if(this.userVo.canAddMp == false)
               {
                  _loc14_ = 0;
               }
               _loc9_ = this.userVo.mp + _loc14_ - this.userVo.allmpMax;
               if(_loc14_ > 0)
               {
                  this.userVo.updateMp(_loc14_,true);
               }
               if(_loc9_ > 0)
               {
                  param1.value = _loc9_ * param1.config.attributeV3;
                  this.userVo.buffs.push(param1);
               }
            }
         }
         else if(param1.config.type == 37)
         {
            _loc10_ = this.userVo.atk * param1.config.attributeV1;
            _loc10_ = _loc10_ + (param1.config.attributeV2 || 0);
            _buff_hu_dun_attackVos.push(param1);
            param1.hudun = [_loc10_,_loc10_];
         }
         else if(param1.config.type == 49)
         {
            _loc10_ = this.userVo.allhpMax * param1.config.attributeV1 + param1.config.attributeV2;
            param1.value = _loc10_;
            this.hu_dun_buff_canReduceHp.push(param1);
         }
         else if(param1.config.type == 36)
         {
            _buff_addhp_hu_dunVo36 = param1;
         }
         else if(param1.config.type == 27)
         {
            this.userVo.buff_mian_yi = true;
         }
         else if(param1.config.type == 271)
         {
            this.userVo.buff_mian_yi1s.push(param1);
         }
         else if(param1.config.type == 101)
         {
            this.userVo.buff_mian_yitypes.push(param1);
         }
         else if(param1.config.type == 34)
         {
            if(this.userVo.type == "role")
            {
               this.userVo.buff_add_skill_level = param1.config.attributeV1;
               for(var _loc4_:String in this.userVo.configVo.skills)
               {
                  _loc21_ = this.userVo.configVo.skills[_loc4_];
                  if(_loc4_.indexOf("effect") > -1)
                  {
                     _loc21_.updateBuff_add_level(this.userVo.buff_add_skill_level);
                  }
               }
            }
         }
         else if(param1.config.type == 40)
         {
            AddSkill(-1);
         }
         else if(param1.config.type == 28)
         {
            if(param1.config.attributeT == "me")
            {
               _loc5_ = 100000;
               if(!isNaN(param1.config.attributeV2))
               {
                  _loc5_ = param1.config.attributeV2;
               }
               param1.value = _loc5_;
               BattleModelManager.getIns().addHated(this.userVo,_loc5_);
            }
            else if(_loc23_)
            {
               this.addHatred(_loc23_.userVo.entitieId,99999);
            }
         }
         else if(param1.config.type == 30)
         {
            _yyBuffs.push(param1);
            if(_yyBuffs.length >= 2)
            {
               _loc18_ = _yyBuffs[0];
               _loc7_ = _yyBuffs[1];
               _loc3_ = _loc18_.config.attributeV1 + _loc7_.config.attributeV1;
               if(_loc3_ == 2)
               {
                  BuffModelManager.getIns().createBuff([5003301],[],1,this.userVo);
               }
               else if(_loc3_ == -2)
               {
                  BuffModelManager.getIns().createBuff([5003401],[],1,this.userVo);
               }
               else if(_loc3_ == 0)
               {
                  BuffModelManager.getIns().createBuff([2002101],[],1,this.userVo);
               }
               BuffModelManager.getIns().del(_loc18_);
               BuffModelManager.getIns().del(_loc7_);
            }
         }
         else if(param1.config.type == 31)
         {
            if(!_hitWallYunXian)
            {
               _hitWallYunXian = new Vector.<BuffVO>();
            }
            _hitWallYunXian.push(param1);
         }
         else if(param1.config.type == 35)
         {
            if(this.userVo.type == "role")
            {
               _canNotMJSBuff = param1;
               if(this.body)
               {
                  this.body.gravMass = 0;
                  _gravMass0Num = _gravMass0Num + 1;
               }
            }
         }
         else if(param1.config.type == 85)
         {
            _canNotJumps.push(param1);
         }
         else if(param1.config.type == 38)
         {
            if(this.userVo.type == "role")
            {
               this.userVo.reduceChiXiShangHaiBuff = param1;
            }
         }
         else if(param1.config.type == 39)
         {
            if(this.userVo)
            {
               this.userVo.reduceHPBuff = param1;
            }
         }
         else if(param1.config.type == 83)
         {
            if(this.userVo)
            {
               if(!this.userVo.reduceHPBuff2)
               {
                  this.userVo.reduceHPBuff2 = new Vector.<BuffVO>();
               }
               this.userVo.reduceHPBuff2.push(param1);
            }
         }
         else if(param1.config.type == 41)
         {
            if(this.userVo)
            {
               this.userVo.buff_protected = param1;
            }
         }
         else if(param1.config.type == 411)
         {
            if(this.userVo)
            {
               this.userVo.buff411_protected.push(param1);
            }
         }
         else if(param1.config.type == 141)
         {
            if(this.userVo)
            {
               this.userVo.buff_protected_hasDamage = param1;
            }
         }
         else if(param1.config.type == 46)
         {
            if(this.userVo)
            {
               this.userVo.buff_create_hurt = param1;
            }
         }
         else if(param1.config.type == 146)
         {
            if(this.userVo)
            {
               this.userVo.buff_create_hurt_hasDamage = param1;
            }
         }
         else if(param1.config.type == 42)
         {
            if(this.userVo)
            {
               BuffModelManager.getIns().removeEntityBuffsByDeleteGainBuff(this.userVo.entitieId);
            }
         }
         else if(param1.config.type == 45)
         {
            if(this.userVo)
            {
               this.userVo.buff_hides.push(param1);
               _loc20_ = Filters.getColorTransform(0,0.5);
               this.display.transform.colorTransform = _loc20_;
            }
         }
         else if(param1.config.type == 451)
         {
            if(this.userVo)
            {
               this.userVo.buff_hides.push(param1);
               this.display.visible = false;
            }
         }
         else if(param1.config.type == 60)
         {
            _oldUservo.buff60s.push(param1);
            if(_oldUservo.buff60s.length > 1)
            {
               _oldUservo.buff60s;
            }
         }
         else if(param1.config.type != 73)
         {
            if(param1.config.type == 67)
            {
               _loc14_ = param1.config.attributeV1 * this.userVo.hpMax;
               if(this.userVo.isPk || this.userVo.isQc)
               {
                  _loc14_ *= CommonConfig.pkReHpRate;
               }
               if(this.userVo.canAddHp == false)
               {
                  _loc14_ = 0;
               }
               if(_loc14_ > 0)
               {
                  this.userVo.updateHP(_loc14_,false);
                  ApplicationFacade.getInstance().sendNotification("nfEntityHurtAuto",{
                     "userVo":this.userVo,
                     "hp":_loc14_,
                     "from":"tsoul"
                  });
               }
            }
            else if(param1.config.type == 74)
            {
               _loc11_ = _jump1HeightMaxLand * param1.config.attributeV1 + param1.config.attributeV2;
               param1.value = _loc11_;
               this.addJumpVeloctity(0,_loc11_);
            }
            else if(param1.config.type == 75)
            {
               this._buff_reverses.push(param1);
            }
            else if(param1.config.type == 76)
            {
               this._buff_yunxianGravitys.push(param1);
               this.body.type = BodyType.STATIC;
            }
            else if(param1.config.type == 77)
            {
               this._buff_attackedAddBuffs.push(param1);
            }
            else if(param1.config.type == 84)
            {
               if(this.userVo)
               {
                  this.userVo.addNotAddBuffs(param1.config.attributeV1);
                  _loc8_ = BuffModelManager.getIns().getManBuffById(this.userVo.entitieId,param1.config.attributeV1);
                  if(_loc8_)
                  {
                     BuffModelManager.getIns().del(_loc8_);
                  }
               }
            }
            else if(param1.config.type == 95)
            {
               if(this.userVo)
               {
                  _loc12_ = param1.attUserVo;
                  if(_loc12_)
                  {
                     if(_loc12_.campId != this.userVo.campId)
                     {
                        if(!param1.oldData)
                        {
                           param1.oldData = {};
                        }
                        param1.oldData.campId = this.userVo.campId;
                        this.changeCampId(_loc12_.campId,true);
                        if(!_zaoXianBuffs)
                        {
                           _zaoXianBuffs = [];
                        }
                        this._zaoXianBuffs.push(param1);
                     }
                  }
               }
            }
            else if(param1.config.type == 96)
            {
               if(this.userVo)
               {
                  param1.value = param1.config.attributeV1;
                  this.userVo.updatePropertyByBattle(param1.value,param1.config.attributeT);
               }
            }
            else if(param1.config.type == 99)
            {
               if(!_moveAddBuffs)
               {
                  _moveAddBuffs = new Vector.<MoveAddBuff>();
               }
               _moveAddBuffs.push(new MoveAddBuff(this,param1));
            }
            else if(param1.config.type == 106)
            {
               if(!_needMpBuffs)
               {
                  _needMpBuffs = [];
               }
               _needMpBuffs.push(param1);
            }
            else if(param1.config.type == 115)
            {
               if(this.userVo)
               {
                  param1.value = param1.config.attributeV1;
                  this.userVo.updatePropertyByBuff(param1.value,param1.config.attributeT);
               }
            }
         }
      }
      
      private function changeCampId(param1:int, param2:Boolean) : void
      {
         if(param2)
         {
            if(param1 == 1)
            {
               param1 = 4;
            }
            else if(param1 == 2)
            {
               param1 = 5;
            }
         }
         BattleModelManager.getIns().removeHated(this.userVo);
         BattleModelManager.getIns().removeFromCamp(this.Id);
         this.userVo.campId = param1;
         BattleModelManager.getIns().addEntity(this,this.userVo.campId);
         if(param2)
         {
            this.display.filters = [new GlowFilter(16737945)];
         }
         else
         {
            this.display.filters = null;
         }
      }
      
      public function updateFreeHuDun(param1:Boolean, param2:Number) : void
      {
         this._buff_hu_dun_hp += param2;
         this._buff_hu_dun = param1;
      }
      
      public function updateFreeHuDun36(param1:Boolean, param2:Number) : void
      {
         this._buff_hu_dun_hp36 += param2;
      }
      
      public function getHuDunhp() : Number
      {
         return this._buff_hu_dun_hp;
      }
      
      public function getHuDunhp36() : Number
      {
         return this._buff_hu_dun_hp36;
      }
      
      protected function onAddCanNotEquip() : void
      {
      }
      
      protected function DelCanNotEquip() : void
      {
      }
      
      private function isCanYuanXian() : Boolean
      {
         if(this.manConfigVo && this.manConfigVo.immuneStun == 1)
         {
            return false;
         }
         return true;
      }
      
      public function updateXIYing(param1:Vector2D, param2:BuffVO) : void
      {
         var _loc3_:Number = param1.angle;
         _additionalVelocity.setxy(0,0);
         if(param2.config.attributeT == "speed")
         {
            _additionalVelocity.x = Math.cos(_loc3_) * param2.config.attributeV1;
            _additionalVelocity.y = Math.sin(_loc3_) * param2.config.attributeV1;
            if(_additionalVelocity.x < 0 && _additionalVelocity.x < param1.x)
            {
               _additionalVelocity.x = param1.x;
            }
            if(_additionalVelocity.x > 0 && _additionalVelocity.x > param1.x)
            {
               _additionalVelocity.x = param1.x;
            }
            maxVelocity.x = Math.abs(_additionalVelocity.x);
            maxVelocity.y = Math.abs(_additionalVelocity.y);
         }
      }
      
      public function updateXIYing3(param1:Vector2D, param2:BuffVO) : void
      {
         var _loc3_:Number = param1.angle;
         _additionalVelocity3.setxy(0,0);
         if(param2.config.attributeT == "speed")
         {
            _additionalVelocity3.x = param2.config.attributeV1;
            _additionalVelocity3.y = param2.config.attributeV2;
            param1 = param1.normalize();
            _additionalVelocity3.x *= param1.x;
            _additionalVelocity3.y *= param1.y;
         }
      }
      
      public function updatetui(param1:Vector2D) : void
      {
         _additionalVelocity3.setxy(0,0);
         _additionalVelocity3.x = param1.x;
         _additionalVelocity3.y = param1.y;
         maxVelocity.x = Math.abs(param1.x);
         maxVelocity.y = param1.y;
      }
      
      public function delBuff(param1:BuffVO) : void
      {
         var _loc11_:int = 0;
         _loc11_ = 0;
         _loc11_ = 0;
         var _loc14_:int = 0;
         _loc14_ = 0;
         var _loc15_:SkillConfigVO = null;
         var _loc8_:int = 0;
         _loc11_ = 0;
         var _loc3_:Sprite = null;
         var _loc9_:int = 0;
         var _loc22_:BuffEffectEntity = null;
         _loc11_ = 0;
         var _loc7_:int = 0;
         _loc11_ = 0;
         var _loc18_:int = 0;
         var _loc10_:XiYing3AI = null;
         var _loc6_:int = 0;
         _loc6_ = 0;
         var _loc12_:BuffVO = null;
         _loc11_ = 0;
         _loc11_ = 0;
         _loc11_ = 0;
         var _loc20_:RoleEntity = null;
         _loc9_ = 0;
         var _loc13_:int = 0;
         var _loc19_:int = 0;
         _loc11_ = 0;
         var _loc4_:int = 0;
         _loc11_ = 0;
         _loc11_ = 0;
         _loc11_ = 0;
         _loc11_ = 0;
         _loc11_ = 0;
         _loc11_ = 0;
         var _loc5_:int = 0;
         _loc11_ = 0;
         var _loc16_:int = 0;
         if(param1.config.type == 22)
         {
            BattleMap.Ins.removeMask();
         }
         else if(param1.config.type == 221)
         {
            if(this.userVo.type == "role")
            {
               BattleMap.Ins.removeMask();
            }
         }
         else if(param1.config.type == 19)
         {
            _loc11_ = userVo.buff_dmg_rate_on_hurtMan.indexOf(param1);
            if(_loc11_ > -1)
            {
               userVo.buff_dmg_rate_on_hurtMan.splice(_loc11_,1);
            }
         }
         else if(param1.config.type == 43)
         {
            userVo.buff_sleep_on_hurtMan = null;
         }
         else if(param1.config.type == 23)
         {
            userVo.buff_dmg_rate_on_attMan = null;
         }
         else if(param1.config.type == 231)
         {
            _loc11_ = userVo.buff_dmg_rate_on_attMan2.indexOf(param1);
            if(_loc11_ > -1)
            {
               userVo.buff_dmg_rate_on_attMan2.splice(_loc11_,1);
            }
         }
         else if(param1.config.type == 97)
         {
            _loc11_ = userVo.buff_dmg_rate_on_attMan3.indexOf(param1);
            if(_loc11_ > -1)
            {
               userVo.buff_dmg_rate_on_attMan3.splice(_loc11_,1);
            }
         }
         else if(param1.config.type == 32)
         {
            userVo.buff_cannot_equip = null;
            if(this.userVo.type == "role")
            {
               userVo.refreshRole();
               DelCanNotEquip();
               if(this.userVo.isDie == false && this.userVo.tempChangeProfession == false)
               {
                  BuffSceneManager.getIns().Start(0);
               }
            }
         }
         else if(param1.config.type == 27)
         {
            this.userVo.buff_mian_yi = false;
         }
         else if(param1.config.type == 271)
         {
            _loc14_ = this.userVo.buff_mian_yi1s.indexOf(param1);
            if(_loc14_ > -1)
            {
               this.userVo.buff_mian_yi1s.splice(_loc14_,1);
            }
         }
         else if(param1.config.type == 101)
         {
            _loc14_ = this.userVo.buff_mian_yitypes.indexOf(param1);
            if(_loc14_ > -1)
            {
               this.userVo.buff_mian_yitypes.splice(_loc14_,1);
            }
         }
         else if(param1.config.type == 34)
         {
            if(this.userVo.type == "role")
            {
               this.userVo.buff_add_skill_level = 0;
               for(var _loc2_:String in this.userVo.configVo.skills)
               {
                  _loc15_ = this.userVo.configVo.skills[_loc2_];
                  if(_loc2_.indexOf("effect") > -1)
                  {
                     _loc15_.updateBuff_add_level(this.userVo.buff_add_skill_level);
                  }
               }
            }
         }
         else if(param1.config.type == 40)
         {
            this.RemoveSkill(-1);
         }
         else if(param1.config.type == 24)
         {
            this.userVo.canAddHp = true;
         }
         else if(param1.config.type == 74)
         {
            _loc8_ = -param1.value;
            this.addJumpVeloctity(0,_loc8_);
         }
         else if(param1.config.type == 106)
         {
            _loc11_ = _needMpBuffs.indexOf(param1);
            if(_loc11_ > -1)
            {
               _needMpBuffs.splice(_loc11_,1);
            }
         }
         if(deleted || isDie)
         {
            return;
         }
         var _loc17_:int = _buffs.indexOf(param1);
         if(_loc17_ > -1)
         {
            _buffs.splice(_loc17_,1);
         }
         var _loc21_:int = 1;
         _loc21_ = param1.config.orderDisplay;
         if(_loc21_ == 0)
         {
            _loc21_ = 1;
         }
         if(_loc21_ == 1)
         {
            _loc3_ = getDisplayLayer(1);
         }
         else
         {
            _loc3_ = getDisplayLayer(0);
         }
         _loc9_ = 0;
         while(_loc9_ < _loc3_.numChildren)
         {
            _loc22_ = _loc3_.getChildAt(_loc9_) as BuffEffectEntity;
            if(_loc22_)
            {
               if(_loc22_.ID == param1.id)
               {
                  if(!(param1.config.interval == 0 && param1.config.time == 0))
                  {
                     _loc22_.destroy();
                  }
                  break;
               }
            }
            _loc9_++;
         }
         if(param1.config.type == 6)
         {
            _buff_ba_ti = false;
            _loc11_ = _buff_ba_tins.indexOf(param1);
            if(_loc11_ > -1)
            {
               _buff_ba_tins.splice(_loc11_,1);
            }
         }
         else if(param1.config.type == 1)
         {
            this.display.alpha = 1;
            _isUnbeatable = false;
         }
         else if(param1.config.type == 61)
         {
            _loc7_ = 0;
            while(_loc7_ < this._buff_ba_tis.length)
            {
               if(this._buff_ba_tis[_loc7_] == param1)
               {
                  this._buff_ba_tis.splice(_loc7_,1);
                  break;
               }
               _loc7_++;
            }
         }
         if(param1.config.type == 11)
         {
            if(!getIsMigration() && (userVo.type == "monster" || userVo.type == "npc"))
            {
               return;
            }
            if(param1.config.attributeT == "xSpeed")
            {
               _additionalVelocity.x = 0;
            }
            else if(param1.config.attributeT == "ySpeed")
            {
               _additionalVelocity.y = 0;
            }
            _buff_xi_ying = null;
         }
         else if(param1.config.type == 111)
         {
            if(!getIsMigration() && (userVo.type == "monster" || userVo.type == "npc"))
            {
               return;
            }
            if(param1.config.attributeT == "xSpeed")
            {
               _additionalVelocity.x = 0;
            }
            else if(param1.config.attributeT == "ySpeed")
            {
               _additionalVelocity.y = 0;
            }
            _loc11_ = _buff_xi_ying111s.indexOf(param1);
            if(_loc11_ != -1)
            {
               _buff_xi_ying111s.splice(_loc11_,1);
            }
            if(_buff_xi_ying111s.length == 0)
            {
               maxVelocity.y = 0;
            }
         }
         else if(param1.config.type == 17)
         {
            if(!getIsMigration() && (userVo.type == "monster" || userVo.type == "npc"))
            {
               return;
            }
            if(param1.config.attributeT == "speed")
            {
               _additionalVelocity.x = 0;
               _additionalVelocity.y = 0;
               maxVelocity.y = 0;
            }
            _buff_xi_ying2 = null;
            _gravMass0Num = _gravMass0Num - 1;
            if(_gravMass0Num <= 0)
            {
               _body.gravMass = _gravity;
            }
            _body.shapes.at(0).filter.collisionMask = _body.userData.data.collisionMask;
            if(_body.shapes.length > 1)
            {
               _body.shapes.at(1).filter.collisionMask = _body.userData.data.collisionMask;
            }
            setMaterial(_staticFriction,_dynamicFriction);
            if(_xi_ying2AI)
            {
               _xi_ying2AI.destroy();
            }
            _xi_ying2AI = null;
         }
         else if(param1.config.type == 171)
         {
            if(!getIsMigration() && (userVo.type == "monster" || userVo.type == "npc"))
            {
               return;
            }
            _additionalVelocity3.setxy(0,0);
            if(_xi_ying3AIs)
            {
               _loc18_ = 0;
               while(_loc18_ < _xi_ying3AIs.length)
               {
                  _loc10_ = _xi_ying3AIs[_loc18_];
                  if(_loc10_ && _loc10_.buff.id == param1.id)
                  {
                     _loc10_.destroy();
                     break;
                  }
                  _loc18_++;
               }
            }
         }
         else if(param1.config.type == 172)
         {
            if(!getIsMigration() && (userVo.type == "monster" || userVo.type == "npc"))
            {
               return;
            }
            updatetui(new Vector2D(0,0));
            if(_tuiAI)
            {
               _tuiAI.destroy();
            }
            _tuiAI = null;
         }
         else if(param1.config.type == 15)
         {
            _buff_fang_shang = null;
            _buff_fang_shang_ = false;
         }
         else if(param1.config.type == 151)
         {
            _buff_fang_shang151 = null;
         }
         else if(param1.config.type == 18)
         {
            _loc6_ = 0;
            while(_loc6_ < userVo.buff_gaiLiArr.length)
            {
               if(userVo.buff_gaiLiArr[_loc6_].id == param1.id)
               {
                  userVo.buff_gaiLiArr.splice(_loc6_,1);
                  break;
               }
               _loc6_++;
            }
         }
         else if(param1.config.type == 181)
         {
            _loc6_ = 0;
            while(_loc6_ < userVo.buff_gaiLiHurtArr.length)
            {
               if(userVo.buff_gaiLiHurtArr[_loc6_].id == param1.id)
               {
                  userVo.buff_gaiLiHurtArr.splice(_loc6_,1);
                  break;
               }
               _loc6_++;
            }
         }
         else if(param1.config.type == 21)
         {
            if(param1.config.attributeT == "speed")
            {
               _walkX_accelerationMax -= param1.oldData[0];
               _walkY_accelerationMax -= param1.oldData[1];
               _run_accelerationMax -= param1.oldData[2];
            }
         }
         else if(param1.config.type == 3)
         {
            _buff_jing_zu = false;
         }
         else if(param1.config.type == 4)
         {
            _buff_cheng_mo = false;
         }
         else if(param1.config.type == 2)
         {
            _buff_yuan_xian = false;
            try
            {
               _loc12_ = BuffModelManager.getIns().getManBuffByType2(this.userVo.entitieId,2);
               if(_loc12_)
               {
                  _buff_yuan_xian = true;
               }
            }
            catch(error:Error)
            {
            }
         }
         else if(param1.config.type == 29)
         {
            _buff_yuan_xian = false;
         }
         else if(param1.config.type == 26)
         {
            this._buff_hu_dun = false;
            this._buff_hu_dun_hp = 0;
         }
         else if(param1.config.type == 116)
         {
            _loc11_ = this.userVo.buffs.indexOf(param1);
            if(_loc11_ > -1)
            {
               this.userVo.buffs.splice(_loc11_,1);
            }
            _loc11_ = this.hu_dun_buff_canReduceHp.indexOf(param1);
            if(_loc11_ > -1)
            {
               this.hu_dun_buff_canReduceHp.splice(_loc11_,1);
            }
         }
         else if(param1.config.type == 36)
         {
            _buff_addhp_hu_dunVo36 = null;
            _buff_hu_dun_hp36 = 0;
         }
         else if(param1.config.type == 37)
         {
            _loc11_ = this._buff_hu_dun_attackVos.indexOf(param1);
            if(_loc11_ > -1)
            {
               this._buff_hu_dun_attackVos.splice(_loc11_,1);
            }
         }
         else if(param1.config.type == 49)
         {
            _loc11_ = this.hu_dun_buff_canReduceHp.indexOf(param1);
            if(_loc11_ > -1)
            {
               this.hu_dun_buff_canReduceHp.splice(_loc11_,1);
            }
         }
         else if(param1.config.type == 28)
         {
            if(param1.config.attributeT == "me")
            {
               BattleModelManager.getIns().addHated(this.userVo,-param1.value + 1);
            }
            else
            {
               _loc20_ = BattleModelManager.getIns().getPlayerByEntityId(param1.attackId) as RoleEntity;
               if(_loc20_)
               {
                  this.addHatred(_loc20_.userVo.entitieId,-99999);
               }
            }
         }
         else if(param1.config.type == 30)
         {
            _loc9_ = 0;
            while(_loc9_ < _yyBuffs.length)
            {
               if(_yyBuffs[_loc9_].id == param1.id)
               {
                  _yyBuffs.splice(_loc9_,1);
                  break;
               }
               _loc9_++;
            }
         }
         else if(param1.config.type == 31)
         {
            if(_hitWallYunXian)
            {
               _loc13_ = 0;
               while(_loc13_ < _hitWallYunXian.length)
               {
                  if(_hitWallYunXian[_loc13_].id == param1.id)
                  {
                     _hitWallYunXian.splice(_loc13_,1);
                     break;
                  }
                  _loc13_++;
               }
            }
         }
         else if(param1.config.type == 35)
         {
            _canNotMJSBuff = null;
            if(this.body)
            {
               _gravMass0Num = _gravMass0Num - 1;
               if(_gravMass0Num <= 0)
               {
                  this.body.gravMass = this._gravity;
               }
            }
         }
         else if(param1.config.type == 85)
         {
            _loc19_ = 0;
            while(_loc19_ < _canNotJumps.length)
            {
               if(_canNotJumps[_loc19_].id == param1.id)
               {
                  _canNotJumps.splice(_loc19_,1);
                  break;
               }
               _loc19_++;
            }
         }
         else if(param1.config.type == 38)
         {
            if(this.userVo.type == "role")
            {
               this.userVo.reduceChiXiShangHaiBuff = null;
            }
         }
         else if(param1.config.type == 39)
         {
            if(this.userVo)
            {
               this.userVo.reduceHPBuff = null;
            }
         }
         else if(param1.config.type == 83)
         {
            if(this.userVo)
            {
               if(!this.userVo.reduceHPBuff2)
               {
                  this.userVo.reduceHPBuff2 = new Vector.<BuffVO>();
               }
               _loc11_ = this.userVo.reduceHPBuff2.indexOf(param1);
               if(_loc11_ > -1)
               {
                  this.userVo.reduceHPBuff2.splice(_loc11_,1);
               }
            }
         }
         else if(param1.config.type == 41)
         {
            if(this.userVo)
            {
               this.userVo.buff_protected = null;
            }
         }
         else if(param1.config.type == 411)
         {
            if(this.userVo)
            {
               _loc4_ = this.userVo.buff411_protected.indexOf(param1);
               if(_loc4_ > -1)
               {
                  this.userVo.buff411_protected.splice(_loc4_,1);
               }
            }
         }
         else if(param1.config.type == 141)
         {
            if(this.userVo)
            {
               this.userVo.buff_protected_hasDamage = null;
            }
         }
         else if(param1.config.type == 46)
         {
            if(this.userVo)
            {
               this.userVo.buff_create_hurt = null;
            }
         }
         else if(param1.config.type == 146)
         {
            if(this.userVo)
            {
               this.userVo.buff_create_hurt_hasDamage = null;
            }
         }
         else if(param1.config.type == 45)
         {
            if(this.userVo)
            {
               _loc11_ = 0;
               _loc11_ = this.userVo.buff_hides.indexOf(param1);
               if(_loc11_ > -1)
               {
                  this.userVo.buff_hides.splice(_loc11_,1);
               }
               if(this.userVo.buff_hides.length == 0)
               {
                  this.display.transform.colorTransform = new ColorTransform();
               }
            }
         }
         else if(param1.config.type == 451)
         {
            if(this.userVo)
            {
               _loc11_ = 0;
               _loc11_ = this.userVo.buff_hides.indexOf(param1);
               if(_loc11_ > -1)
               {
                  this.userVo.buff_hides.splice(_loc11_,1);
               }
               if(this.userVo.buff_hides.length == 0)
               {
                  this.display.visible = true;
               }
            }
         }
         else if(param1.config.type == 60)
         {
            _loc11_ = _oldUservo.buff60s.indexOf(param1);
            if(_loc11_ > -1)
            {
               _oldUservo.buff60s.splice(_loc11_,1);
            }
         }
         else if(param1.config.type == 75)
         {
            _loc11_ = this._buff_reverses.indexOf(param1);
            if(_loc11_ > -1)
            {
               this._buff_reverses.splice(_loc11_,1);
            }
         }
         else if(param1.config.type == 76)
         {
            _loc11_ = this._buff_yunxianGravitys.indexOf(param1);
            if(_loc11_ > -1)
            {
               this._buff_yunxianGravitys.splice(_loc11_,1);
            }
            if(this._buff_yunxianGravitys.length == 0)
            {
               if(this.body)
               {
                  this.body.type = BodyType.DYNAMIC;
               }
            }
         }
         else if(param1.config.type == 77)
         {
            _loc11_ = this._buff_attackedAddBuffs.indexOf(param1);
            if(_loc11_ > -1)
            {
               this._buff_attackedAddBuffs.splice(_loc11_,1);
            }
         }
         else if(param1.config.type == 84)
         {
            if(this.userVo)
            {
               this.userVo.removeNotAddBuffs(param1.config.attributeV1);
            }
         }
         else if(param1.config.type == 95)
         {
            if(!_zaoXianBuffs)
            {
               _zaoXianBuffs = [];
            }
            if(this.userVo)
            {
               _loc5_ = 0;
               if(param1.oldData && param1.oldData.hasOwnProperty("campId"))
               {
                  _loc5_ = int(param1.oldData.campId);
               }
               if(_loc5_ > 0)
               {
                  this.changeCampId(_loc5_,false);
               }
               _loc11_ = _zaoXianBuffs.indexOf(param1);
               if(_loc11_ > -1)
               {
                  _zaoXianBuffs.splice(_loc11_,1);
               }
            }
         }
         else if(param1.config.type == 96)
         {
            if(this.userVo)
            {
               param1.value *= -1;
               this.userVo.updatePropertyByBattle(param1.value,param1.config.attributeT);
            }
         }
         else if(param1.config.type == 99)
         {
            if(_moveAddBuffs)
            {
               _loc16_ = 0;
               while(_loc16_ < _moveAddBuffs.length)
               {
                  if(_moveAddBuffs[_loc16_].buffId == param1.id)
                  {
                     _moveAddBuffs[_loc16_].destroy();
                     _moveAddBuffs.splice(_loc16_,1);
                     break;
                  }
                  _loc16_++;
               }
            }
         }
         else if(param1.config.type == 110)
         {
            delSkillLock();
         }
         else if(param1.config.type == 115)
         {
            if(this.userVo)
            {
               param1.value *= -1;
               this.userVo.updatePropertyByBuff(param1.value,param1.config.attributeT);
            }
         }
      }
      
      public function changeBuff(param1:BuffVO) : void
      {
         var _loc4_:int = 0;
         var _loc3_:BuffEffectEntity = null;
         var _loc2_:Sprite = getDisplayLayer(1);
         _loc4_ = 0;
         while(_loc4_ < _loc2_.numChildren)
         {
            _loc3_ = _loc2_.getChildAt(_loc4_) as BuffEffectEntity;
            if(_loc3_)
            {
               if(_loc3_.ID == param1.id)
               {
                  _loc3_.change();
                  break;
               }
            }
            _loc4_++;
         }
      }
      
      protected function toSkill(param1:int) : void
      {
         if(getNeedCheckCanRelease(param1))
         {
            SimpleTextLog.getIns().log2("不能释放=" + param1);
            return;
         }
         _moving = false;
         setMaterial(_staticFriction,_dynamicFriction);
         skill(param1);
      }
      
      public function canSkill() : Boolean
      {
         return this._canSkill;
      }
      
      public function setCanSkill(param1:Boolean) : void
      {
         this._canSkill = param1;
      }
      
      protected function getNeedCheckCanRelease(param1:int) : Boolean
      {
         var _loc2_:Boolean = _buff_cheng_mo || hasBuffType(87);
         return _isAttack || _buff_xi_ying || _loc2_ || !canSkill();
      }
      
      public function getCanNotReleaseSkillEntity() : Boolean
      {
         var _loc1_:Boolean = _buff_cheng_mo || hasBuffType(87);
         return _loc1_ || !canSkill() || buff_yuan_xian;
      }
      
      public function getCanNotAttack(param1:int = -1) : Boolean
      {
         return !canSkill() || buff_yuan_xian;
      }
      
      protected function getChengMoCanNotRelease(param1:int) : Boolean
      {
         var _loc2_:Boolean = _buff_cheng_mo || hasBuffType(87);
         if(param1 == 71 || param1 == 72 || param1 == 73 || param1 == 74 || param1 == 741 || param1 == 75 || param1 == 756)
         {
            return _loc2_;
         }
         return false;
      }
      
      public function skill(param1:int) : void
      {
         if(_actionState != param1)
         {
            _isAttack = true;
            _actionState = param1;
            updateAnimation();
            if(_nowAnimation)
            {
               _nowAnimation.loop = false;
            }
            onAttacking();
            _attackIndex = 0;
            SimpleTextLog.getIns().log2("skill=",param1);
            if(skillConfigVo)
            {
               skillConfigVo.nowCD = skillConfigVo.cd;
            }
            onSkillAfter(_actionState);
         }
      }
      
      protected function onBeginSkil() : void
      {
         if(skillConfigVo)
         {
            if(_isJump || _isJump2 || _isJump3)
            {
               updateBodyVelocity(new Vec2(0,_body.velocity.y));
            }
            else
            {
               updateBodyVelocity(new Vec2(0,0));
            }
            if(skillConfigVo.shootTime > 0 && skillConfigVo.shootFrame > -1)
            {
               _checkShootFrame = skillConfigVo.shootFrame;
               if(_checkShootFrame < 0)
               {
                  _checkShootFrame = -1;
               }
            }
            if(skillConfigVo.moveTime > 0 && skillConfigVo.moveFrame > -1)
            {
               _checkMoveFrame = skillConfigVo.moveFrame;
               if(_checkMoveFrame < 0)
               {
                  _checkMoveFrame = -1;
               }
            }
         }
      }
      
      public function onAddNextSKillEntity(param1:String, param2:SkillConfigVO, param3:Vector2D, param4:Boolean, param5:int, param6:int = 1, param7:int = 2, param8:int = 2, param9:int = -1, param10:Class = null, param11:int = 0, param12:Boolean = false, param13:Object = null) : void
      {
      }
      
      public function addSKillEntity(param1:String, param2:SkillConfigVO, param3:Vector2D, param4:Boolean, param5:int, param6:int = 1, param7:int = 2, param8:int = 2, param9:int = -1, param10:Class = null, param11:int = 0, param12:Boolean = false, param13:Object = null) : SkillEntity
      {
         var _loc15_:SkillEntity = null;
         if(param11 == 0)
         {
            param11 = this.direction;
         }
         var _loc16_:int = param11;
         if(param13 && param13.cfg)
         {
            if(param13.cfg.hasOwnProperty("fixedAssetDir"))
            {
               _loc16_ = int(param13.cfg.fixedAssetDir || 0);
            }
         }
         if(deleted || !_assetDict)
         {
            return _loc15_;
         }
         if(param10)
         {
            _loc15_ = new param10(param1,param2);
         }
         else
         {
            _loc15_ = new SkillEntity(param1,param2);
         }
         _loc15_.setOtherData(param13 as SkillParam);
         _loc15_.loop = param4;
         _loc15_.setUserVo(this.getAttUserVo(),this.getAttUserVo().configVo);
         if(param2.sort == 1 || param2.sort == 3)
         {
            if(this.userVo.isPk == false)
            {
               if(this.userVo.campId == 1)
               {
                  param5 = 2;
               }
               else if(this.userVo.campId == 2)
               {
                  param5 = 1;
               }
            }
         }
         var _loc17_:Rectangle = new Rectangle(param3.x + param2.x * param11,param3.y + param2.y,param7,param8);
         onAddSKillEntityRec(_loc17_,param3,param1,param2,param11);
         var _loc14_:Body = new Body(BodyType.DYNAMIC,new Vec2(_loc17_.x,_loc17_.y));
         _loc14_.allowRotation = false;
         var _loc19_:Polygon = new Polygon(Polygon.box(_loc17_.width,_loc17_.height));
         _loc14_.shapes.add(_loc19_);
         _loc14_.space = Physics.Ins.space;
         _loc15_.gravMass = _loc14_.gravMass;
         _loc14_.gravMass = 0;
         if(param13 && param13.gravMassScale > 0)
         {
            _loc14_.gravMassScale = param13.gravMassScale;
         }
         _loc19_.filter.collisionGroup = 0;
         _loc16_ = onAddSKillEntityFixedDir(_loc16_,param1,param2);
         _loc15_.setdir(_loc16_);
         _loc15_.setPhysicsBody(_loc14_);
         if(param9 == -1)
         {
            param9 = this.layerIndex + 1;
         }
         _loc15_.setLayerIndex(param9);
         BattleModelManager.getIns().addEntity(_loc15_,param5);
         if(param6 == 1)
         {
            BattleMap.Ins.addChild1(_loc15_.display);
         }
         else if(param6 == 2)
         {
            BattleMap.Ins.addChild2(_loc15_.display);
         }
         var _loc18_:Vector2D = param3.clone();
         _loc18_.x = _loc18_.x + param2.x * param11;
         _loc18_.y += param2.y;
         onAddSKillEntityPos(_loc18_,param3,param1,param2);
         _loc15_.position = _loc18_;
         _loc15_.skInvert = param12;
         if(this is HorseEntity)
         {
            _loc15_.setAssets(ManResourceManager.getIns().getResourceByManId(this.userVo.charID));
         }
         else
         {
            _loc15_.setAssets(_assetDict);
         }
         _loc15_.updateDirection(_loc16_);
         _loc15_.setScreen(this.screenRange);
         GameFrame.juggler.add(_loc15_);
         playSound(param1);
         return _loc15_;
      }
      
      protected function onAddSKillEntityFixedDir(param1:int, param2:String, param3:SkillConfigVO) : int
      {
         return param1;
      }
      
      protected function onAddSKillEntityRec(param1:Rectangle, param2:Vector2D, param3:String, param4:SkillConfigVO, param5:int) : void
      {
      }
      
      protected function onAddSKillEntityPos(param1:Vector2D, param2:Vector2D, param3:String, param4:SkillConfigVO) : void
      {
      }
      
      protected function getAttUserVo() : UserVO
      {
         return this._useAttUservo || this.userVo;
      }
      
      public function addSZSKillEntity(param1:String, param2:SkillConfigVO, param3:Vector2D, param4:Boolean, param5:int, param6:int = 1, param7:int = 2, param8:int = 2, param9:int = -1, param10:Class = null, param11:int = 0, param12:Boolean = false, param13:Object = null, param14:int = 0) : SkillEntity
      {
         return this.addSKillEntity(param1,param2,param3,param4,param5,param6,param7,param8,param9,param10,param11,param12,param13);
      }
      
      protected function onAttShootCheckFrame() : void
      {
         if(skillConfigVo.assetLink)
         {
            onStartShoot();
            clearShoot();
            return;
         }
         if(skillConfigVo.shootTime > 0)
         {
            shoot();
         }
      }
      
      protected function onStartShoot() : void
      {
         addSKillEntity(skillConfigVo.assetLink[0],skillConfigVo,this.position,true,this.userVo.campId);
      }
      
      private function onAttMoveCheckFrame() : void
      {
         if(skillConfigVo.moveTime > 0)
         {
            move();
         }
      }
      
      public function reDir(param1:int) : void
      {
         this.updateDirection(param1);
         this.setDirection(param1);
         var _loc2_:Vec2 = _body.velocity.copy();
         _loc2_.x = skillConfigVo.shootSpeedX * _direction;
         _loc2_.y = skillConfigVo.shootSpeedY;
         _shootVel = _loc2_;
         onShootByVel(_loc2_);
         updateBodyVelocity(_loc2_);
      }
      
      protected function shoot() : void
      {
         if(!_body || !skillConfigVo)
         {
            return;
         }
         var _loc1_:Vec2 = _body.velocity.copy();
         _loc1_.x = skillConfigVo.shootSpeedX * _direction;
         _loc1_.y = skillConfigVo.shootSpeedY;
         maxVelocity.x = Math.abs(skillConfigVo.shootSpeedX);
         maxVelocity.y = Math.abs(_loc1_.y);
         if(skillConfigVo.gravity == 1 && this is SkillEntity)
         {
            _body.gravMass = SkillEntity(this).gravMass;
            maxVelocity.y = 0;
         }
         else
         {
            setMaterial(0,0);
         }
         _isShoot = true;
         _shootNowTime = 0;
         _shootTotalTime = skillConfigVo.shootTime;
         _shootVel = _loc1_;
         onShootByVel(_loc1_);
         updateBodyVelocity(_loc1_);
      }
      
      override protected function onCanNotUpdateKeyVelocity(param1:Vec2) : void
      {
         if(_isShoot)
         {
            updateKeyVelocityByFix(param1,_shootVel);
            if(_buff_yuan_xian)
            {
               param1.x = param1.y = 0;
            }
            if(_canWalk == false)
            {
               param1.x = param1.y = 0;
            }
         }
      }
      
      override protected function updateKeyVelocity(param1:Vec2) : void
      {
         super.updateKeyVelocity(param1);
         if(_buff_yuan_xian)
         {
            param1.x = param1.y = 0;
         }
         if(_canWalk == false)
         {
            param1.x = param1.y = 0;
         }
      }
      
      protected function onShootByVel(param1:Vec2) : void
      {
      }
      
      public function toClearShoot() : void
      {
         this.clearShoot();
         if(_body)
         {
            _body.velocity.y = 0;
         }
         if(maxVelocity)
         {
            maxVelocity.y = 0;
         }
      }
      
      protected function clearShoot() : void
      {
         _isShoot = false;
         _isMove = false;
         _shootNowTime = 0;
         _shootTotalTime = 0;
         if(_body)
         {
            setMaterial(_staticFriction,_dynamicFriction);
            _body.velocity.x = 0;
            maxVelocity.x = 0;
            onClearShootAfter();
         }
      }
      
      protected function onClearShootAfter() : void
      {
         if(_shootVel && _shootVel.y != 0)
         {
            _body.velocity.y = 0;
         }
      }
      
      protected function shootEnd() : void
      {
         clearShoot();
         if(getType() != ManType.SKILL)
         {
         }
         toIdle();
      }
      
      override protected function updateBodyVelocity(param1:Vec2) : void
      {
         if(_buff_jing_zu || canNotMJSBuff || this.userVo && this.userVo.buff_sleep_on_hurtMan && this is RoleEntity || hasBuffType(87) || hasBuffType(3))
         {
            param1.x = param1.y = 0;
         }
         if(_canWalk == false)
         {
            param1.x = param1.y = 0;
         }
         super.updateBodyVelocity(param1);
      }
      
      public function updateBodyVelocityNow(param1:Vec2) : void
      {
         if(_buff_jing_zu || canNotMJSBuff || this.userVo && this.userVo.buff_sleep_on_hurtMan && this is RoleEntity || hasBuffType(87) || hasBuffType(3))
         {
            param1.x = param1.y = 0;
         }
         if(_canWalk == false)
         {
            param1.x = param1.y = 0;
         }
         super.updateBodyVelocity(param1);
      }
      
      protected function move() : void
      {
         maxVelocity.x = 0;
         var _loc1_:Vec2 = _body.velocity.copy();
         _loc1_.x = skillConfigVo.moveSpeed * _direction;
         _loc1_.y = 0;
         setMaterial(0,0);
         updateBodyVelocity(_loc1_);
         _isMove = true;
         _shootNowTime = 0;
         _shootTotalTime = skillConfigVo.moveTime;
      }
      
      private function moveEnd() : void
      {
         clearShoot();
         onMoveEnd();
      }
      
      protected function onMoveEnd() : void
      {
         toIdle();
      }
      
      public function addSKillEntityByTriggerAfter(param1:SkillEntity) : void
      {
         BattleModelManager.getIns().setAttackedTotalNum(this.userVo.entitieId,param1.skillConfigVo.id,0,this.userVo.type,this.userVo.campId);
      }
      
      public function playSound(param1:String) : void
      {
         var _loc3_:ManConfigVO = null;
         var _loc2_:int = 0;
         var _loc5_:ResourceVO = null;
         var _loc4_:String = null;
         _curSoundChannel = null;
         try
         {
            _loc3_ = _userVo.configVo;
            if(_userVo.isMagic)
            {
               return;
            }
            _loc2_ = _loc3_.resourcesId;
            _loc5_ = ResourceManager.getIns().getResourcesByID(_loc2_);
            if(_loc5_)
            {
               _loc4_ = _loc5_.sound;
               if(_loc4_ && _loc4_ != "" && param1 != "")
               {
                  _loc4_ = _loc5_.getSoundUrl();
                  _curSoundChannel = MusicManager.getIns().playSoundEffect(_loc4_,param1);
               }
            }
         }
         catch(error:Error)
         {
         }
      }
      
      override protected function onUpdateAnimationAfter() : void
      {
         var _loc1_:String = null;
         super.onUpdateAnimationAfter();
         if(this.getType() == "role")
         {
            _loc1_ = ActionState.getName(_actionState);
            playSound(_loc1_);
         }
      }
      
      public function canAttCollide() : Boolean
      {
         if(__test)
         {
            return true;
         }
         if(Enabled == false)
         {
            return false;
         }
         return getIsAttacking();
      }
      
      public function createEquChenLu(param1:PlayerEntity) : void
      {
         var _loc3_:Array = null;
         var _loc2_:SkillConfigVO = null;
         var _loc8_:int = 0;
         var _loc7_:int = 0;
         var _loc4_:BuffConfigVO = null;
         var _loc6_:BuffConfigVO = null;
         var _loc5_:Array = this.userVo.getEquSkillByChenLu();
         if(_loc5_)
         {
            _loc3_ = _loc5_[0];
            _loc2_ = _loc3_[0];
            if(!this.equipSkillCdObj[_loc5_[1]])
            {
               this.equipSkillCdObj[_loc5_[1]] = {"cd":-1};
            }
            _loc8_ = int(this.equipSkillCdObj[_loc5_[1]].cd);
            if(_loc8_ != -1 && GameFrame.time - _loc8_ < _loc2_.cd)
            {
               return;
            }
            if(createEquSkil(_loc2_))
            {
               this.equipSkillCdObj[_loc5_[1]].cd = GameFrame.time;
               _loc7_ = 1;
               while(_loc7_ < _loc3_.length)
               {
                  _loc2_ = _loc3_[_loc7_];
                  if(_loc2_.myBuff)
                  {
                     _loc4_ = BuffModelManager.getIns().getBuffById(_loc2_.myBuff[0]);
                     if(_loc4_)
                     {
                        BuffModelManager.getIns().createMyBuf(userVo,_loc2_);
                     }
                  }
                  if(_loc2_.buffId)
                  {
                     if(param1 && param1.userVo)
                     {
                        _loc6_ = BuffModelManager.getIns().getBuffById(_loc2_.buffId[0]);
                        if(_loc6_)
                        {
                           BuffModelManager.getIns().createOtherBuf(userVo,param1.userVo,_loc2_);
                        }
                     }
                  }
                  _loc7_++;
               }
            }
         }
      }
      
      public function createEquChen() : void
      {
         var _loc1_:SkillConfigVO = this.userVo.getEquSkillByChen();
         createEquSkil(_loc1_);
      }
      
      public function createEquChi() : void
      {
         var _loc4_:Array = null;
         var _loc1_:Array = null;
         var _loc8_:int = 0;
         var _loc7_:int = 0;
         var _loc3_:BuffConfigVO = null;
         var _loc5_:RoleEntity = null;
         var _loc6_:BuffConfigVO = null;
         var _loc2_:SkillConfigVO = this.userVo.getEquSkillByChi();
         createEquSkil(_loc2_);
         if(!_loc2_)
         {
            _loc4_ = this.userVo.getEquSkillByChi16();
            if(_loc4_)
            {
               _loc1_ = _loc4_[0];
               _loc2_ = _loc1_[0];
               if(!this.equipSkillCdObj[_loc4_[1]])
               {
                  this.equipSkillCdObj[_loc4_[1]] = {"cd":-1};
               }
               _loc8_ = int(this.equipSkillCdObj[_loc4_[1]].cd);
               if(_loc8_ != -1 && GameFrame.time - _loc8_ < _loc2_.cd)
               {
                  return;
               }
               if(createEquSkil(_loc2_))
               {
                  this.equipSkillCdObj[_loc4_[1]].cd = GameFrame.time;
                  _loc7_ = 1;
                  while(_loc7_ < _loc1_.length)
                  {
                     _loc2_ = _loc1_[_loc7_];
                     if(_loc2_.myBuff)
                     {
                        _loc3_ = BuffModelManager.getIns().getBuffById(_loc2_.myBuff[0]);
                        if(_loc3_)
                        {
                           BuffModelManager.getIns().createMyBuf(userVo,_loc2_);
                        }
                     }
                     if(_loc2_.buffId)
                     {
                        _loc5_ = BattleModelManager.getIns().getPlayerByEntityId(_attackUserVo.entitieId) as RoleEntity;
                        if(_loc5_)
                        {
                           _loc6_ = BuffModelManager.getIns().getBuffById(_loc2_.buffId[0]);
                           if(_loc6_)
                           {
                              BuffModelManager.getIns().createOtherBuf(userVo,_attackUserVo,_loc2_);
                           }
                        }
                     }
                     _loc7_++;
                  }
               }
            }
         }
      }
      
      protected function createEquSkil(param1:SkillConfigVO) : Boolean
      {
         var _loc3_:Boolean = false;
         var _loc2_:BuffConfigVO = null;
         if(param1)
         {
            _loc3_ = BattleModelManager.getIns().calBuffTrigger(this.userVo,null,param1);
            if(_loc3_)
            {
               if(param1.myBuff)
               {
                  _loc2_ = BuffModelManager.getIns().getBuffById(param1.myBuff[0]);
                  if(_loc2_)
                  {
                     BuffModelManager.getIns().createMyBuf(userVo,param1);
                  }
               }
               return true;
            }
         }
         return false;
      }
      
      public function checkGaiLiHurt() : void
      {
         var _loc5_:int = 0;
         var _loc2_:BuffVO = null;
         var _loc1_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Boolean = false;
         if(this.userVo.buff_gaiLiHurtArr)
         {
            _loc5_ = 0;
            while(_loc5_ < this.userVo.buff_gaiLiHurtArr.length)
            {
               _loc2_ = userVo.buff_gaiLiHurtArr[_loc5_];
               if(_loc2_.currCd == 0 || GameFrame.time - _loc2_.currCd > _loc2_.config.cd)
               {
                  _loc1_ = 0.2;
                  if(_loc2_ && isNaN(_loc2_.config.attributeV3) == false)
                  {
                     _loc1_ = _loc2_.config.attributeV3;
                  }
                  _loc3_ = BattleModelManager.getIns().getRandom("playerEntity-6634");
                  _loc4_ = _loc1_ >= _loc3_;
                  if(_loc4_)
                  {
                     BuffModelManager.getIns().createBuff([_loc2_.config.attributeV1],[],1,this.userVo);
                     _loc2_.currCd = GameFrame.time;
                  }
               }
               _loc5_++;
            }
         }
      }
      
      public function attacked(param1:PlayerEntity, param2:int, param3:SkillConfigVO = null) : void
      {
         var _loc4_:Boolean = false;
         var _loc5_:int = 0;
         _loc5_ = 0;
         if(this.skillControls && this.skillControls.length > 0)
         {
            _loc4_ = false;
            _loc5_ = 0;
            while(_loc5_ < this.skillControls.length)
            {
               if(this.skillControls[_loc5_] is SkillStopMoveX)
               {
                  _loc4_ = true;
               }
               _loc5_++;
            }
            if(_loc4_)
            {
               _loc5_ = 0;
               while(_loc5_ < this.skillControls.length)
               {
                  if(this.skillControls[_loc5_] is SkillMove || this.skillControls[_loc5_] is SkillJump)
                  {
                     this.skillControls[_loc5_].flagDel();
                  }
                  _loc5_++;
               }
            }
         }
         if(this.getType() == "role")
         {
            this.createEquChenLu(param1);
         }
      }
      
      public function attacked2(param1:PlayerEntity, param2:int, param3:SkillConfigVO = null) : void
      {
      }
      
      public function attacked3(param1:PlayerEntity, param2:int, param3:SkillConfigVO = null, param4:PlayerEntity = null) : void
      {
      }
      
      public function addArrow(param1:ArrowStay) : void
      {
         _arrows.push(param1);
      }
      
      public function addtsArrow(param1:ArrowShenJinStay) : void
      {
         _arrowsts.push(param1);
      }
      
      public function removeAllArrow() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < _arrows.length)
         {
            _arrows[_loc1_].destroy();
            _loc1_++;
         }
         _arrows.length = 0;
      }
      
      public function removeAllArrowts() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < _arrowsts.length)
         {
            _arrowsts[_loc1_].destroy();
            _loc1_++;
         }
         _arrowsts.length = 0;
      }
      
      public function CanStayItem(param1:String) : Boolean
      {
         var _loc2_:* = null;
         if(_stayArrows[param1] >= 5)
         {
            return false;
         }
         return true;
      }
      
      public function addStayItem(param1:Sprite) : void
      {
         var _loc3_:Sprite = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc7_:Array = null;
         var _loc2_:Array = null;
         var _loc8_:int = 0;
         var _loc6_:int = 0;
         this.getDisplayLayer(2).addChild(param1);
         _loc4_ = int(_stayArrows[param1.name].length);
         try
         {
            _loc5_ = _loc4_ - 1;
            while(_loc5_ >= 0)
            {
               if(_stayArrows[param1.name][_loc5_].deleted)
               {
                  _stayArrows[param1.name].splice(_loc5_,1);
               }
               _loc5_--;
            }
         }
         catch(error:Error)
         {
         }
         _stayArrows[param1.name].push(param1);
         _loc7_ = ro1.concat();
         _loc2_ = ro2.concat();
         _loc8_ = 0;
         _loc4_ = int(_stayArrows[param1.name].length);
         while(_loc8_ < _loc4_)
         {
            _loc3_ = _stayArrows[param1.name][_loc8_] as Sprite;
            if(_loc3_.name == "1")
            {
               _loc3_.rotation = _loc7_.shift();
            }
            else if(_loc3_.name == "-1")
            {
               _loc3_.rotation = _loc2_.shift();
            }
            _loc8_++;
         }
      }
      
      public function hasBuffPrefix(param1:int) : Boolean
      {
         var _loc3_:int = 0;
         var _loc2_:Boolean = false;
         _loc3_ = 0;
         while(_loc3_ < _buffs.length)
         {
            if(String(_buffs[_loc3_].config.id).indexOf(param1 + "") == 0)
            {
               _loc2_ = true;
               break;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      override public function hasBuff(param1:int) : Boolean
      {
         var _loc3_:int = 0;
         var _loc2_:Boolean = false;
         _loc3_ = 0;
         while(_loc3_ < _buffs.length)
         {
            if(_buffs[_loc3_].config.id == param1)
            {
               _loc2_ = true;
               break;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function hasBuffType(param1:int) : Boolean
      {
         var _loc3_:int = 0;
         var _loc2_:Boolean = false;
         _loc3_ = 0;
         while(_loc3_ < _buffs.length)
         {
            if(_buffs[_loc3_].config.type == param1)
            {
               _loc2_ = true;
               break;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function setYun(param1:Boolean) : void
      {
         _buff_yuan_xian = param1;
         if(keyboard)
         {
            keyboard.reset();
         }
         if(keyControl)
         {
            keyControl.reset();
         }
      }
      
      public function setInDu(param1:Boolean) : void
      {
         _inDu = param1;
      }
      
      public function setMaxVelx(param1:Number) : void
      {
         this.maxVelocity.x = param1;
      }
      
      public function simHurt(param1:SkillConfigVO) : void
      {
         var _loc2_:Vec2 = null;
         if(!_hurtDelayTimer)
         {
            if(_actionState != 5 && this.getIsBaTi() == false && this.manConfigVo.superArmor == 0)
            {
               _actionState = 5;
               updateAnimation();
               if(_nowAnimation)
               {
                  onAddHurtActionState();
                  _nowAnimation.loop = true;
               }
               stopWalk();
               clearShoot();
            }
            if(!_body)
            {
               return;
            }
            _loc2_ = _body.velocity.copy();
            if(param1.targetMove && param1.targetMove.length != 0)
            {
               _loc2_.y = -param1.targetMove.y;
               _loc2_.x = param1.targetMove.x * _moveDir;
               maxVelocity.x = Math.abs(_loc2_.x);
            }
            if(!param1.targetMove)
            {
               throw new Error(param1.id + "_targetMove =null");
            }
            onHurtVelocity(_loc2_);
            onHurtVelocity2(_loc2_,param1);
            updateBodyVelocity(_loc2_);
            stiff(param1);
         }
      }
      
      public function reDrawAB(param1:String, param2:MovieClip) : void
      {
         var _loc7_:int = 0;
         var _loc4_:int = 0;
         var _loc6_:Vector.<Texture> = Texture.drawMcToTextures(param2,false,1,1,false,null,false,null,"low");
         var _loc5_:Array = _assetDict["ab"][param1];
         var _loc3_:Vector.<Texture> = _loc5_[0];
         _loc7_ = 0;
         while(_loc7_ < _loc3_.length)
         {
            if(_loc3_[_loc7_] && _loc3_[_loc7_].bd)
            {
               _loc3_[_loc7_].bd.dispose();
            }
            _loc7_++;
         }
         _loc3_ = _loc5_[1];
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            if(_loc3_[_loc4_] && _loc3_[_loc4_].bd)
            {
               try
               {
                  _loc3_[_loc4_].bd.dispose();
               }
               catch(error:Error)
               {
               }
            }
            _loc4_++;
         }
         _assetDict["ab"][param1][0] = _loc6_;
         _assetDict["ab"][param1][1] = _loc6_;
      }
      
      public function setReleaseBuff(param1:Boolean) : void
      {
         _canReleaseBuff = param1;
      }
      
      public function addHitSYEntitys(param1:ArrowShenJinStay) : void
      {
         _attackedSys.push(param1);
      }
      
      public function removeHitSYEntitys(param1:ArrowShenJinStay) : void
      {
         var _loc2_:int = _attackedSys.indexOf(param1);
         if(_loc2_ > -1)
         {
            _attackedSys.splice(_loc2_,1);
         }
      }
      
      override public function SetEnabled(param1:Boolean) : void
      {
         super.SetEnabled(param1);
         isReadyCanAI = param1;
      }
      
      public function onGetXP(param1:int) : void
      {
      }
      
      public function addHideSKillEntity(param1:Dictionary, param2:SkillConfigVO) : void
      {
         param2.shootFrame = 1;
         param2.shootTime = 1000;
         var _loc3_:String = "ef_" + this.userVo.get1CharID();
         _assetDict["ac"]["effect_sz"] = param1["ac"][_loc3_];
         _assetDict["ab"]["effect_sz"] = param1["ab"][_loc3_];
         _assetDict["hb"]["effect_sz"] = param1["hb"][_loc3_];
         _manConfigVo.skills["effect_sz"] = param2;
         toSkill(ActionState.EFFECT_SZ);
      }
      
      public function changeFly(param1:int, param2:Number) : void
      {
         try
         {
            if(this.body)
            {
               this.body.gravMass = param1;
            }
            if(_changeFlyT)
            {
               GameFrame.juggler.remove(_changeFlyT);
               _changeFlyT = null;
            }
            if(param2 != 0)
            {
               _changeFlyT = new DelayedCall(changeFly,param2,[0,0]);
               GameFrame.juggler.add(_changeFlyT);
            }
         }
         catch(error:Error)
         {
         }
      }
      
      protected function hasHunDun() : Boolean
      {
         return _buff_hu_dun_attackVos.length > 0;
      }
      
      public function recordSEid() : void
      {
         this._attackedSkillArr = {};
      }
      
      public function getIsBaTi() : Boolean
      {
         if(this._buff_ba_ti)
         {
            return true;
         }
         if(this._buff_ba_tis && this._buff_ba_tis.length > 0)
         {
            return true;
         }
         try
         {
            if(this.userVo.configVo.actionSuperArmor && this._armature)
            {
               if(this.userVo.configVo.actionSuperArmor.indexOf(this._armature.animation.movementID) > -1)
               {
                  return true;
               }
            }
         }
         catch(error:Error)
         {
         }
         return false;
      }
      
      override public function CanSkill() : Boolean
      {
         if(this._buff_yuan_xian || this._buff_cheng_mo || hasBuffType(87))
         {
            return false;
         }
         return super.CanSkill();
      }
      
      public function addSKillEntityNew(param1:SkillParam) : void
      {
         this.addSKillEntity(param1.assetLink[0],param1.skillConfig,param1.pos,param1.loop,param1.campId);
      }
      
      public function getTargetPos() : Vector2D
      {
         var _loc1_:PlayerEntity = null;
         var _loc2_:Vector2D = this.position.clone();
         _loc1_ = this.userVo.getHatredEntity();
         if(_loc1_)
         {
            _loc2_ = _loc1_.position.clone();
            if(RoleConfigVO(_loc1_.manConfigVo).targetCenter)
            {
               _loc2_.x += _loc1_.direction * RoleConfigVO(_loc1_.manConfigVo).targetCenter.x;
               _loc2_.y -= RoleConfigVO(_loc1_.manConfigVo).targetCenter.y;
               if(RoleConfigVO(_loc1_.manConfigVo).targetCenter.y == 0)
               {
                  _loc2_.y -= 20;
               }
            }
            else
            {
               _loc2_.y -= 20;
            }
            if(this.body)
            {
               _loc2_.y -= 10;
            }
         }
         return _loc2_;
      }
      
      public function getTargetNoHidePos(param1:int = 25) : Vector2D
      {
         return this.getTargetPos();
      }
      
      public function setOtherData(param1:SkillParam) : void
      {
         this.skp = param1;
      }
      
      override public function getRealDir() : Number
      {
         if(this._buff_reverses.length > 0)
         {
            return -1;
         }
         return super.getRealDir();
      }
      
      public function isWudiAction() : Boolean
      {
         if(this.userVo.configVo.actionWuDi && _armature)
         {
            if(this.userVo.configVo.actionWuDi.indexOf(_armature.animation.movementID) > -1)
            {
               return true;
            }
         }
         return false;
      }
      
      protected function getNeedWudiEffect() : Boolean
      {
         if(BattleModelManager.getIns().levelInfo && BattleModelManager.getIns().levelInfo.isRoleNeedWudiEffect() == false && this.userVo && this.userVo.type == "role")
         {
            return false;
         }
         if(this.manConfigVo && this.manConfigVo.wuDiAlpha == 1)
         {
            return true;
         }
         return false;
      }
      
      public function setIsEdit(param1:Boolean) : void
      {
      }
      
      override public function reduceHuDunHp(param1:Number) : Array
      {
         var _loc6_:int = 0;
         var _loc3_:Number = NaN;
         var _loc5_:int = 0;
         var _loc4_:BuffVO = null;
         var _loc2_:Number = 0;
         if(param1 > 0)
         {
            if(userVo && userVo.takePetRougeLike)
            {
               _loc6_ = 0;
               while(_loc6_ < userVo.takePetRougeLike.length)
               {
                  _loc3_ = 0;
                  _loc3_ += ITakePetRougeLike(userVo.takePetRougeLike[_loc6_]).getExtraHp();
                  if(_loc3_ > 0)
                  {
                     _loc3_ -= param1;
                     if(_loc3_ >= 0)
                     {
                        ITakePetRougeLike(userVo.takePetRougeLike[_loc6_]).addExtraHp(-param1);
                        _loc2_ += param1;
                        param1 = 0;
                        break;
                     }
                     ITakePetRougeLike(userVo.takePetRougeLike[_loc6_]).addExtraHp(-_loc3_);
                     _loc2_ += param1 - Math.abs(_loc3_);
                     param1 = Math.abs(_loc3_);
                  }
                  _loc6_++;
               }
            }
         }
         if(this.hu_dun_buff_canReduceHp.length > 0)
         {
            _loc5_ = 0;
            while(_loc5_ < this.hu_dun_buff_canReduceHp.length)
            {
               _loc4_ = this.hu_dun_buff_canReduceHp[_loc5_];
               _loc4_.value = _loc4_.value - param1;
               if(_loc4_.value >= 0)
               {
                  _loc2_ += param1;
                  param1 = 0;
                  break;
               }
               _loc2_ += param1 - Math.abs(_loc4_.value);
               param1 = Math.abs(_loc4_.value);
               _loc4_.totalTime = 0;
               BuffModelManager.getIns().del(_loc4_);
               _loc5_++;
            }
         }
         return [param1,_loc2_];
      }
      
      override public function afterBackBlashreduceHuDunHp(param1:Number) : Array
      {
         var _loc5_:int = 0;
         var _loc2_:BuffVO = null;
         var _loc6_:int = 0;
         var _loc4_:BuffVO = null;
         var _loc3_:Number = 0;
         if(_buff_hu_dun)
         {
            _buff_hu_dun_hp -= param1;
            if(_buff_hu_dun_hp > 0)
            {
               _loc3_ += param1;
               param1 = 0;
            }
            else
            {
               _loc3_ += param1 - Math.abs(_buff_hu_dun_hp);
               param1 = Math.abs(_buff_hu_dun_hp);
               _buff_hu_dun = false;
               _buff_hu_dun_hp = 0;
               if(_buff_addhp_hu_dunVo)
               {
                  _buff_addhp_hu_dunVo.totalTime = 0;
                  BuffModelManager.getIns().del(_buff_addhp_hu_dunVo);
               }
            }
         }
         if(param1 > 0)
         {
            if(_buff_hu_dun_hp36 > 0)
            {
               _buff_hu_dun_hp36 -= param1;
               if(_buff_hu_dun_hp36 >= 0)
               {
                  _loc3_ += param1;
                  param1 = 0;
               }
               else
               {
                  _loc3_ += param1 - Math.abs(_buff_hu_dun_hp36);
                  param1 = Math.abs(_buff_hu_dun_hp36);
                  _buff_hu_dun_hp36 = 0;
                  if(_buff_addhp_hu_dunVo36)
                  {
                     _buff_addhp_hu_dunVo36.totalTime = 0;
                     BuffModelManager.getIns().del(_buff_addhp_hu_dunVo36);
                  }
               }
            }
         }
         if(param1 > 0)
         {
            if(this._buff_hu_dun_attackVos.length > 0)
            {
               _loc5_ = 0;
               while(_loc5_ < this._buff_hu_dun_attackVos.length)
               {
                  _loc2_ = this._buff_hu_dun_attackVos[_loc5_];
                  _loc2_.hudun[0] -= param1;
                  if(_loc2_.hudun[0] >= 0)
                  {
                     _loc3_ += param1;
                     param1 = 0;
                     break;
                  }
                  _loc3_ += param1 - Math.abs(_loc2_.hudun[0]);
                  param1 = Math.abs(_loc2_.hudun[0]);
                  _loc2_.totalTime = 0;
                  BuffModelManager.getIns().del(_loc2_);
                  _loc5_++;
               }
            }
         }
         if(param1 > 0)
         {
            if(this.hu_dun_buff_canReduceHp.length > 0)
            {
               _loc6_ = 0;
               while(_loc6_ < this.hu_dun_buff_canReduceHp.length)
               {
                  _loc4_ = this.hu_dun_buff_canReduceHp[_loc6_];
                  _loc4_.value = _loc4_.value - param1;
                  if(_loc4_.value >= 0)
                  {
                     _loc3_ += param1;
                     param1 = 0;
                     break;
                  }
                  _loc3_ += param1 - Math.abs(_loc4_.value);
                  param1 = Math.abs(_loc4_.value);
                  _loc4_.totalTime = 0;
                  BuffModelManager.getIns().del(_loc4_);
                  _loc6_++;
               }
            }
         }
         if(_loc3_ > 0)
         {
            BattleModelManager.showDiDanHp(_loc3_,this);
         }
         return [param1,_loc3_];
      }
      
      override public function getAttackedAddBuffs() : Array
      {
         var _loc3_:int = 0;
         var _loc2_:BuffVO = null;
         var _loc1_:Array = [];
         _loc3_ = 0;
         while(_loc3_ < this._buff_attackedAddBuffs.length)
         {
            _loc2_ = this._buff_attackedAddBuffs[_loc3_];
            _loc1_.push(_loc2_.config.attributeV1);
            _loc3_++;
         }
         return _loc1_;
      }
      
      public function getAttackedAddBuffs1() : Array
      {
         var _loc3_:int = 0;
         var _loc2_:BuffVO = null;
         var _loc1_:Array = [];
         _loc3_ = 0;
         while(_loc3_ < _buffs.length)
         {
            _loc2_ = this._buffs[_loc3_];
            if(_loc2_.config.type == 771)
            {
               _loc1_.push(_loc2_.config.attributeV1);
            }
            _loc3_++;
         }
         return _loc1_;
      }
      
      public function getAttackedAddBuffs2() : Array
      {
         var _loc3_:int = 0;
         var _loc2_:BuffVO = null;
         var _loc1_:Array = [];
         _loc3_ = 0;
         while(_loc3_ < _buffs.length)
         {
            _loc2_ = this._buffs[_loc3_];
            if(_loc2_.config.type == 772)
            {
               _loc1_.push(_loc2_.config.attributeV1);
            }
            _loc3_++;
         }
         return _loc1_;
      }
      
      public function getBuff78sV1() : Number
      {
         var _loc3_:int = 0;
         var _loc2_:BuffVO = null;
         var _loc1_:Number = 1;
         _loc3_ = 0;
         while(_loc3_ < this._buffs.length)
         {
            _loc2_ = this._buffs[_loc3_];
            if(_loc2_.config.type == 78)
            {
               _loc1_ += _loc2_.config.attributeV1;
            }
            _loc3_++;
         }
         return _loc1_;
      }
      
      public function getBuff82V1() : Number
      {
         var _loc1_:BuffVO = null;
         var _loc6_:int = 0;
         var _loc4_:BuffVO = null;
         var _loc3_:BuffVO = null;
         var _loc5_:int = 0;
         var _loc2_:Number = 0;
         if(!this.userVo || this.userVo.isDie)
         {
            return _loc2_;
         }
         _loc6_ = 0;
         while(_loc6_ < this._buffs.length)
         {
            _loc4_ = this._buffs[_loc6_];
            if(_loc4_.config.type == 82)
            {
               _loc3_ = BuffModelManager.getIns().getManBuffByType(this.userVo.entitieId,_loc4_.config.type,_loc4_.config.attributeT,_loc4_.config.group);
               if(_loc4_.config.stackMax > 0)
               {
                  _loc3_ = BuffModelManager.getIns().getManBuffById(this.userVo.entitieId,_loc4_.config.id);
               }
               _loc1_ = _loc3_;
               break;
            }
            _loc6_++;
         }
         if(_loc1_)
         {
            _loc2_ += _loc1_.config.attributeV1;
            if(_loc1_.children && _loc1_.children.length > 0)
            {
               _loc5_ = 0;
               while(_loc5_ < _loc1_.children.length)
               {
                  _loc2_ += _loc1_.children[_loc5_].config.attributeV1;
                  _loc5_++;
               }
            }
         }
         return _loc2_;
      }
      
      public function getBuff88V1() : Number
      {
         var _loc1_:* = null;
         var _loc4_:int = 0;
         var _loc3_:BuffVO = null;
         var _loc2_:Number = 1;
         if(!this.userVo || this.userVo.isDie)
         {
            return _loc2_;
         }
         _loc4_ = 0;
         while(_loc4_ < this._buffs.length)
         {
            _loc3_ = this._buffs[_loc4_];
            if(_loc3_.config.type == 88)
            {
               _loc2_ *= _loc3_.config.attributeV1;
            }
            _loc4_++;
         }
         if(_loc2_ < 0)
         {
            _loc2_ = 0;
         }
         return _loc2_;
      }
      
      public function getBuff89V1() : Number
      {
         var _loc1_:* = null;
         var _loc4_:int = 0;
         var _loc3_:BuffVO = null;
         var _loc2_:Number = 0;
         if(!this.userVo || this.userVo.isDie)
         {
            return _loc2_;
         }
         _loc4_ = 0;
         while(_loc4_ < this._buffs.length)
         {
            _loc3_ = this._buffs[_loc4_];
            if(_loc3_.config.type == 89)
            {
               _loc2_ += _loc3_.config.attributeV1;
            }
            _loc4_++;
         }
         _loc2_ = 1 - _loc2_;
         return Math.min(1,_loc2_);
      }
      
      public function getBuff90V1() : Number
      {
         var _loc1_:* = null;
         var _loc4_:int = 0;
         var _loc3_:BuffVO = null;
         var _loc2_:Number = 0;
         if(!this.userVo || this.userVo.isDie)
         {
            return _loc2_;
         }
         _loc4_ = 0;
         while(_loc4_ < this._buffs.length)
         {
            _loc3_ = this._buffs[_loc4_];
            if(_loc3_.config.type == 90)
            {
               _loc2_ += _loc3_.config.attributeV1;
            }
            _loc4_++;
         }
         _loc2_ = 1 - _loc2_;
         return Math.max(0,_loc2_);
      }
      
      public function getBuff112V1() : Number
      {
         var _loc1_:* = null;
         var _loc4_:int = 0;
         var _loc3_:BuffVO = null;
         var _loc2_:Number = 0;
         if(!this.userVo || this.userVo.isDie)
         {
            return _loc2_;
         }
         _loc4_ = 0;
         while(_loc4_ < this._buffs.length)
         {
            _loc3_ = this._buffs[_loc4_];
            if(_loc3_.config.type == 112)
            {
               _loc2_ += _loc3_.config.attributeV1;
            }
            _loc4_++;
         }
         return _loc2_;
      }
      
      public function getBuff142() : Array
      {
         var _loc2_:* = null;
         var _loc5_:int = 0;
         var _loc4_:BuffVO = null;
         var _loc3_:Number = 0;
         if(!this.userVo || this.userVo.isDie)
         {
            return null;
         }
         var _loc1_:Array = [];
         _loc5_ = 0;
         while(_loc5_ < this._buffs.length)
         {
            _loc4_ = this._buffs[_loc5_];
            if(_loc4_.config.type == 142)
            {
               _loc1_.push([_loc4_,_loc4_.config.attributeV1,_loc4_.config.attributeV2]);
            }
            _loc5_++;
         }
         return _loc1_;
      }
      
      public function getBuff92() : Array
      {
         var _loc2_:* = null;
         var _loc5_:int = 0;
         var _loc4_:BuffVO = null;
         var _loc3_:Number = 0;
         if(!this.userVo || this.userVo.isDie)
         {
            return null;
         }
         var _loc1_:Array = [];
         _loc5_ = 0;
         while(_loc5_ < this._buffs.length)
         {
            _loc4_ = this._buffs[_loc5_];
            if(_loc4_.config.type == 92)
            {
               _loc1_.push(_loc4_);
            }
            _loc5_++;
         }
         if(_loc1_.length == 0)
         {
            return null;
         }
         return _loc1_;
      }
      
      public function getCanAwayKjAi() : Boolean
      {
         if(manConfigVo && manConfigVo.awayKjAi == 0)
         {
            return false;
         }
         return true;
      }
      
      public function getBuffKongju() : Array
      {
         var _loc2_:* = null;
         var _loc5_:int = 0;
         var _loc4_:BuffVO = null;
         var _loc3_:Number = 0;
         if(!this.userVo || this.userVo.isDie)
         {
            return null;
         }
         var _loc1_:Array = [];
         _loc5_ = 0;
         while(_loc5_ < this._buffs.length)
         {
            _loc4_ = this._buffs[_loc5_];
            if(_loc4_.config.type == 93)
            {
               _loc1_.push(_loc4_);
            }
            _loc5_++;
         }
         if(_loc1_.length == 0)
         {
            return null;
         }
         return _loc1_;
      }
      
      public function getBuff108TanLan() : Array
      {
         var _loc2_:* = null;
         var _loc5_:int = 0;
         var _loc4_:BuffVO = null;
         var _loc3_:Number = 0;
         if(!this.userVo || this.userVo.isDie)
         {
            return null;
         }
         var _loc1_:Array = [];
         _loc5_ = 0;
         while(_loc5_ < this._buffs.length)
         {
            _loc4_ = this._buffs[_loc5_];
            if(_loc4_.config.type == 108)
            {
               _loc1_.push(_loc4_);
            }
            _loc5_++;
         }
         if(_loc1_.length == 0)
         {
            return null;
         }
         return _loc1_;
      }
      
      public function getBuff107TanLan() : Array
      {
         var _loc2_:* = null;
         var _loc5_:int = 0;
         var _loc4_:BuffVO = null;
         var _loc3_:Number = 0;
         if(!this.userVo || this.userVo.isDie)
         {
            return null;
         }
         var _loc1_:Array = [];
         _loc5_ = 0;
         while(_loc5_ < this._buffs.length)
         {
            _loc4_ = this._buffs[_loc5_];
            if(_loc4_.config.type == 107)
            {
               _loc1_.push(_loc4_);
            }
            _loc5_++;
         }
         if(_loc1_.length == 0)
         {
            return null;
         }
         return _loc1_;
      }
      
      public function getBuff109() : Array
      {
         var _loc1_:Array = null;
         var _loc2_:* = null;
         var _loc5_:int = 0;
         var _loc4_:BuffVO = null;
         var _loc3_:Number = 0;
         if(!this.userVo || this.userVo.isDie)
         {
            return null;
         }
         _loc5_ = 0;
         while(_loc5_ < this._buffs.length)
         {
            _loc4_ = this._buffs[_loc5_];
            if(_loc4_.config.type == 109)
            {
               if(!_loc1_)
               {
                  _loc1_ = [];
               }
               _loc1_.push(_loc4_);
            }
            _loc5_++;
         }
         return _loc1_;
      }
      
      public function getBuff110() : Array
      {
         var _loc1_:Array = null;
         var _loc2_:* = null;
         var _loc5_:int = 0;
         var _loc4_:BuffVO = null;
         var _loc3_:Number = 0;
         if(!this.userVo || this.userVo.isDie)
         {
            return null;
         }
         _loc5_ = 0;
         while(_loc5_ < this._buffs.length)
         {
            _loc4_ = this._buffs[_loc5_];
            if(_loc4_.config.type == 110)
            {
               if(!_loc1_)
               {
                  _loc1_ = [];
               }
               _loc1_.push(_loc4_);
            }
            _loc5_++;
         }
         return _loc1_;
      }
      
      public function getBuff113() : Array
      {
         var _loc1_:Array = null;
         var _loc2_:* = null;
         var _loc5_:int = 0;
         var _loc4_:BuffVO = null;
         var _loc3_:Number = 0;
         if(!this.userVo || this.userVo.isDie)
         {
            return null;
         }
         _loc5_ = 0;
         while(_loc5_ < this._buffs.length)
         {
            _loc4_ = this._buffs[_loc5_];
            if(_loc4_.config.type == 113)
            {
               if(!_loc1_)
               {
                  _loc1_ = [];
               }
               _loc1_.push(_loc4_);
            }
            _loc5_++;
         }
         return _loc1_;
      }
      
      public function getBuff114(param1:int) : Boolean
      {
         var _loc5_:int = 0;
         var _loc4_:BuffVO = null;
         var _loc3_:String = "magicWeapon";
         if(param1 == 2)
         {
            _loc3_ = "magicWeapon2";
         }
         var _loc2_:Number = 0;
         if(!this.userVo || this.userVo.isDie)
         {
            return false;
         }
         _loc5_ = 0;
         while(_loc5_ < this._buffs.length)
         {
            _loc4_ = this._buffs[_loc5_];
            if(_loc4_.config.type == 114 && _loc4_.config.attributeT == _loc3_)
            {
               return true;
            }
            _loc5_++;
         }
         return false;
      }
      
      public function getBufs() : Vector.<BuffVO>
      {
         return this._buffs;
      }
      
      public function addSKillEntityOnSkillBulleAfter(param1:SkillEntity, param2:SkillParam) : void
      {
      }
      
      public function getLocateTargetPosition() : Vector2D
      {
         return Vector2D.zero;
      }
      
      public function getLocateTargetPosition2(param1:Vector2D, param2:SkillParam) : Vector2D
      {
         return param1;
      }
      
      public function calDamageByBuff92(param1:Number, param2:PlayerEntity) : Number
      {
         return param1;
      }
      
      public function onGetLocalPositionBySkillMove(param1:PlayerEntity, param2:Vector2D) : Vector2D
      {
         return param2;
      }
      
      protected function onSkillAfter(param1:int) : void
      {
         var _loc14_:BuffVO = null;
         var _loc6_:int = 0;
         var _loc8_:UserVO = null;
         var _loc5_:Entity = null;
         var _loc13_:int = 0;
         var _loc9_:Array = null;
         var _loc4_:Number = NaN;
         var _loc3_:int = 0;
         var _loc2_:Object = null;
         var _loc11_:String = null;
         var _loc12_:SkillConfigVO = null;
         var _loc7_:Array = this.getBuff109();
         if(_loc7_)
         {
            _loc6_ = 0;
            while(_loc6_ < _loc7_.length)
            {
               _loc14_ = _loc7_[_loc6_];
               _loc5_ = BattleModelManager.getIns().getPlayerByEntityId(_loc14_.targetId);
               _loc13_ = 0;
               _loc8_ = _loc14_.userVo;
               _loc13_ = _loc8_.allatk * _loc14_.config.attributeV1;
               _loc13_ = _loc13_ * -1;
               if(isNaN(_loc8_.buff_reduce_hpPer))
               {
                  _loc8_.buff_reduce_hpPer = 1;
               }
               if(_loc13_ < 0)
               {
                  _loc13_ *= _loc8_.buff_reduce_hpPer;
                  if(_loc8_.propertyVo && _loc14_.config.attributeV1 > 0)
                  {
                     _loc13_ *= _loc8_.propertyVo.reduce_hp_damge_per;
                  }
                  if(_loc5_ && _loc5_ is PlayerEntity)
                  {
                     _loc13_ *= PlayerEntity(_loc5_).getBuff89V1();
                  }
                  if(_loc5_ && _loc13_ < 0)
                  {
                     _loc9_ = _loc5_.reduceHuDunHp(Math.abs(_loc13_));
                     _loc4_ = Number(_loc9_[1]);
                     if(_loc4_ > 0)
                     {
                        BattleModelManager.showDiDanHp(_loc4_,_loc5_);
                     }
                     _loc13_ = -_loc9_[0];
                  }
               }
               _loc13_ = _loc8_.calRealReducehp(_loc13_,false);
               _loc13_ = Math.ceil(_loc13_);
               _loc8_.buff_reduce_hpTotal += _loc13_;
               _loc8_.updateHP(_loc13_,false);
               if(_loc13_ < 0)
               {
                  _loc8_.loseHP += Math.abs(_loc13_);
               }
               ApplicationFacade.getInstance().sendNotification("nfPlayerInfoChange",_loc8_);
               ApplicationFacade.getInstance().sendNotification("nfEntityHurtAuto",{
                  "userVo":_loc8_,
                  "hp":_loc13_,
                  "from":"t4"
               });
               _loc6_++;
            }
         }
         var _loc10_:Array = this.getBuff110();
         if(_loc10_)
         {
            if(_loc10_.length > 0)
            {
               if(!_lockSkillAcs)
               {
                  _lockSkillAcs = [];
               }
               _loc3_ = int((param1 + "").slice(0,2));
               if(this._lockSkillAcs.length > 0 && this._lockSkillAcs[0].ac != _loc3_)
               {
                  while(this._lockSkillAcs.length > 0)
                  {
                     _loc2_ = _lockSkillAcs.pop();
                     _loc2_.skill.locked = false;
                  }
               }
               _loc11_ = ActionState.getName(_loc3_);
               _loc12_ = this.manConfigVo.skills[_loc11_];
               if(_loc12_)
               {
                  _loc12_.locked = true;
                  _lockSkillAcs.unshift({
                     "skill":_loc12_,
                     "ac":_loc11_
                  });
               }
               ApplicationFacade.getInstance().sendNotification("nfPlayerInfoChange",this.userVo);
            }
         }
      }
      
      private function delSkillLock() : void
      {
         var _loc1_:Object = null;
         if(this._lockSkillAcs && !this.getBuff110())
         {
            while(this._lockSkillAcs.length > 0)
            {
               _loc1_ = _lockSkillAcs.pop();
               _loc1_.skill.locked = false;
            }
            this._lockSkillAcs = null;
            SimpleTextLog.getIns().log2("删除封印技能的buff");
            ApplicationFacade.getInstance().sendNotification("nfPlayerInfoChange",this.userVo);
         }
      }
      
      public function onReleaseSzSummber() : void
      {
      }
      
      public function releaseSkcByJiYi(param1:UserVO, param2:SkillConfigVO, param3:Boolean = false, param4:Vector2D = null, param5:SkillParam = null) : void
      {
      }
      
      public function takeRougeLike() : Object
      {
         return null;
      }
      
      public function breakCurrAction() : void
      {
         this.clearStiff();
         this.stopWalk();
         this.clearShoot();
         if(keyboard)
         {
            keyboard.reset();
         }
         if(keyControl)
         {
            keyControl.reset();
         }
         this.toIdle();
      }
      
      public function getCanChangeProfession() : Boolean
      {
         return _canChangeProfession;
      }
      
      public function setCanChangeProfession(param1:Boolean) : void
      {
         this._canChangeProfession = param1;
      }
      
      private function calDamageBySoul(param1:Number) : int
      {
         param1 = BattleModelManager.getIns().calDamageBySoul(this._attackUserVo,this.userVo,param1);
         var _loc2_:AttackInfoVO = new AttackInfoVO();
         _loc2_.floating = 0;
         _loc2_.parameter = "";
         _loc2_.direction = _attackDirection;
         _loc2_.damageType = 5;
         _loc2_.attUserVo = _attackUserVo;
         _loc2_.hurUserVo = this.userVo;
         _loc2_.attSkill = _attackSkillConfigvo;
         _loc2_.hurUserVo = this.userVo;
         _loc2_.pos = this.display.localToGlobal(new Point(0,-120));
         _loc2_.damageValue = param1;
         ApplicationFacade.getInstance().sendNotification("NF_ENTITY_HURT",_loc2_);
         return param1;
      }
      
      override public function showDamageBySoul(param1:Number, param2:UserVO, param3:UserVO, param4:SkillConfigVO, param5:PlayerEntity) : void
      {
         var _loc8_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc9_:int = 0;
         var _loc6_:AttackInfoVO = null;
         super.showDamageBySoul(param1,param2,param3,param4,param5);
         if(isNaN(param1))
         {
            param1 = 0;
         }
         if(param1 < 0)
         {
            return;
         }
         if(!param2 || !param3 || !param5)
         {
            return;
         }
         try
         {
            _loc8_ = BattleModelManager.getIns().calSoulCritical(param2,param3);
            if(_loc8_ > 0)
            {
               _loc7_ = BattleModelManager.getIns().getRandom("showDamageBySoul-calSoulCritical");
               if(_loc7_ <= _loc8_)
               {
                  _loc9_ = BattleModelManager.getIns().calDamageBySoul(param2,param3,param1);
                  _loc6_ = new AttackInfoVO();
                  _loc6_.floating = 0;
                  _loc6_.parameter = "";
                  _loc6_.direction = 1;
                  _loc6_.damageType = 5;
                  _loc6_.attUserVo = param2;
                  _loc6_.hurUserVo = param3;
                  _loc6_.attSkill = param4;
                  if(param5)
                  {
                     _loc6_.pos = param5.display.localToGlobal(new Point(0,-120));
                  }
                  _loc6_.damageValue = _loc9_;
                  ApplicationFacade.getInstance().sendNotification("NF_ENTITY_HURT",_loc6_);
                  this.userVo.updateHP(-_loc9_,false);
               }
            }
         }
         catch(error:Error)
         {
         }
      }
      
      public function getIsMigration() : Boolean
      {
         if(!this.manConfigVo)
         {
            return true;
         }
         if(RoleConfigVO(this.manConfigVo).isMigration == 0)
         {
            return false;
         }
         try
         {
            if(this.userVo.configVo.actionMigration)
            {
               if(this.userVo.configVo.actionMigration.indexOf(ActionState.getName(currentActionState)) > -1)
               {
                  return false;
               }
            }
         }
         catch(error:Error)
         {
         }
         return true;
      }
      
      public function getSkillConfigVoByTest(param1:int) : SkillConfigVO
      {
         return this.getSkillConfigVo(param1);
      }
      
      public function testSkill(param1:int) : void
      {
      }
   }
}

