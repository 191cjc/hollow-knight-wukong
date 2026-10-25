package viewers.entitys.man
{
   import com.game.engine.character.ActionState;
   import com.game.engine.core.GameFrame;
   import com.game.engine.utils.SimpleTextLog;
   import dragonBones.Armature;
   import flash.display.DisplayObject;
   import models.managers.BuffModelManager;
   import models.managers.GlobalData;
   import models.vo.SkillConfigVO;
   import models.vo.UserVO;
   import nape.geom.Vec2;
   import viewers.container.BattleMap;
   import viewers.entitys.Entity;
   import viewers.entitys.man.enemys.E3506;
   import viewers.entitys.man.skills.wk2.W2e5;
   
   public class WK2Entity extends RoleEntity
   {
      
      private static var Eff4BirthFrame:Array = [12,26,40,52];
      
      private var _effect1_1:SkillEntity;
      
      private var _keyPressFrame:int;
      
      private var _effect2_1:SkillEntity;
      
      private var _skillConfigVo4:SkillConfigVO;
      
      private var _sons4:Vector.<Entity> = new Vector.<Entity>();
      
      private var _frame4:int = 0;
      
      private var _effect5_1:SkillEntity;
      
      private var _effect5_2:SkillEntity;
      
      private var _eff1_2:Boolean;
      
      private var _eff1_1:Boolean;
      
      private var _skillConfigVo2:SkillConfigVO;
      
      private var _skillConfigVo1:SkillConfigVO;
      
      private var _eff4Speed3:Boolean;
      
      private var _eff4Speed2:Boolean;
      
      private var _eff4BirthFrame:Array = [];
      
      private var _effect4s:Vector.<SkillEntity> = new Vector.<SkillEntity>();
      
      private var _eff2_1:Boolean;
      
      private var _sonsInds:Array;
      
      private var effect1_0:SkillEntity;
      
      private var _effect2_2:Boolean;
      
      private var son_hpPercent:Number;
      
      public function WK2Entity()
      {
         super();
         _maxAttak = 45;
      }
      
      public function get skill2Awake2() : Boolean
      {
         return getSkillConfigVo(72).id == 1102220;
      }
      
      public function get skill2Awake1() : Boolean
      {
         return getSkillConfigVo(72).id == 1102120;
      }
      
      public function get skill5Awake1() : Boolean
      {
         return getSkillConfigVo(75).id == 1102150;
      }
      
      public function get skill5Awake2() : Boolean
      {
         return getSkillConfigVo(75).id == 1102250;
      }
      
      public function get skill4Awake2() : Boolean
      {
         return getSkillConfigVo(74).id == 1102240;
      }
      
      public function get skill4Awake1() : Boolean
      {
         return getSkillConfigVo(74).id == 1102140;
      }
      
      override public function onCreateAfter() : void
      {
         super.onCreateAfter();
         try
         {
            if(this.userVo.configVo.param2)
            {
               this.son_hpPercent = this.userVo.configVo.param2.son_hpPercent;
            }
         }
         catch(error:Error)
         {
            SimpleTextLog.getIns().log2(error.message);
         }
         if(isNaN(son_hpPercent))
         {
            son_hpPercent = 0.25;
         }
      }
      
      override protected function onAttacking() : void
      {
         if(currentActionState != 71)
         {
            if(currentActionState != 72)
            {
               if(currentActionState != 73)
               {
                  if(currentActionState == 74)
                  {
                     if(GlobalData.getIsRelease619())
                     {
                     }
                     Eff4BirthFrame = [12,26,40,52];
                     if(skill4Awake1)
                     {
                        Eff4BirthFrame = [10,21,32,43,55];
                     }
                     _frame4 = 0;
                     _eff4BirthFrame.length = 0;
                     _eff4BirthFrame = Eff4BirthFrame.concat();
                     clearSon4();
                     _sons4.length = 0;
                  }
                  else if(currentActionState == 75)
                  {
                  }
               }
            }
         }
         super.onAttacking();
      }
      
      override protected function updateAnimation(param1:int = 30) : void
      {
         if(_actionState == 74)
         {
            if(skill4Awake2)
            {
               param1 = 45;
            }
         }
         super.updateAnimation(param1);
      }
      
      private function clearSon4() : void
      {
         for each(var _loc1_:Entity in this._sons4)
         {
            RoleEntity(_loc1_).goToDie();
         }
         _sons4.length = 0;
      }
      
      override protected function onKeyDown(param1:uint) : void
      {
         var _loc2_:int = userVo.keyBoard.getActionByKey(param1);
         if(!(_loc2_ == 71 && getAttacking() == false))
         {
            if(_loc2_ == 74 && getAttacking() == false)
            {
               if(_onGround == false)
               {
                  return;
               }
            }
            else if(_loc2_ == 75 && getAttacking() == false)
            {
               if(_onGround == false)
               {
                  return;
               }
            }
         }
         super.onKeyDown(param1);
      }
      
      override protected function onKeyUp(param1:uint) : void
      {
         var _loc4_:int = 0;
         var _loc2_:String = null;
         var _loc3_:Boolean = false;
         super.onKeyUp(param1);
         if(currentActionState == 72 || currentActionState == 721 || currentActionState == 722)
         {
            if(userVo)
            {
               _loc4_ = userVo.keyBoard.getKeyCodeByAction(72);
            }
            if(_loc4_ > 0)
            {
               _loc2_ = keyboard.getKeyName(_loc4_);
               _loc3_ = keyboard.justReleased(_loc2_);
               if(!_loc3_)
               {
                  _loc4_ = userVo.keyBoard.getKey2CodeByAction(72);
                  if(_loc4_ > 0)
                  {
                     _loc2_ = keyboard.getKeyName(_loc4_);
                     _loc3_ = keyboard.justReleased(_loc2_);
                  }
               }
               if(_loc3_)
               {
                  toEffect21();
               }
            }
         }
      }
      
      override protected function shootEnd() : void
      {
         if(currentActionState == 43 || currentActionState == 45 || currentActionState == 71 || currentActionState == 75)
         {
            clearShoot();
            return;
         }
         super.shootEnd();
      }
      
      override protected function onShootOrMoveing() : void
      {
         var _loc1_:Vec2 = null;
         _loc1_ = null;
         if(currentActionState == 74)
         {
            if(nowAnimation.currentFrame > 51 && nowAnimation.currentFrame < 64 && _eff4Speed2 == false)
            {
               _loc1_ = _body.velocity.copy();
               _loc1_.x = 150 * _direction;
               updateBodyVelocity(_loc1_);
               _eff4Speed2 = true;
            }
            else if(nowAnimation.currentFrame > 63 && _eff4Speed3 == false)
            {
               _loc1_ = _body.velocity.copy();
               _loc1_.x = 0 * _direction;
               updateBodyVelocity(_loc1_);
               _eff4Speed3 = true;
            }
         }
         super.onShootOrMoveing();
      }
      
      override protected function canUpdateKeyVelocity() : Boolean
      {
         if(GlobalData.getIsRelease619())
         {
            if(currentActionState == 74)
            {
               return true;
            }
         }
         if(_eff1_2)
         {
            return false;
         }
         if(currentActionState == 71 || currentActionState == 41 || currentActionState == 42)
         {
            return true;
         }
         return super.canUpdateKeyVelocity();
      }
      
      override protected function getonKeyDirNoDirect() : Boolean
      {
         if(GlobalData.getIsRelease619())
         {
            if(currentActionState == 74)
            {
               return false;
            }
         }
         if(currentActionState == 71)
         {
            return false;
         }
         return true;
      }
      
      override public function updateDirection(param1:int) : void
      {
         if(currentActionState == 71)
         {
            if(_effect1_1)
            {
               return;
            }
            return;
         }
         super.updateDirection(param1);
      }
      
      override protected function skill1() : void
      {
         var _loc3_:int = 0;
         var _loc2_:Entity = null;
         var _loc1_:Armature = null;
         if(!_skillConfigVo1)
         {
            _skillConfigVo1 = skillConfigVo;
         }
         _eff1_1 = false;
         _eff1_2 = false;
         _buff_ba_ti2 = true;
         super.skill1();
         _nowAnimation.loop = false;
         _nowAnimation.gotoAndStop(1);
         _loc3_ = 0;
         while(_loc3_ < this._sons4.length)
         {
            _loc2_ = this._sons4[_loc3_];
            if(!(_loc2_.isDie || _loc2_.deleted))
            {
               RoleEntity(_loc2_).updateDirection(this.direction);
            }
            _loc3_++;
         }
         if(this.assetDict && this.assetDict["actionSkillFactory"])
         {
            _loc1_ = this.getSkillArmature("effect1_0");
            if(_loc1_)
            {
               _loc1_.animation.gotoAndPlay("effect1_0");
               _loc1_.animation.timeScale = 1;
               _nowAnimation.addChildAt(_loc1_.display as DisplayObject,0);
               _nowAnimation.addArmatures(_loc1_);
            }
         }
      }
      
      override protected function onShootByVel(param1:Vec2) : void
      {
         if(currentActionState == 71)
         {
            if(onGround == false)
            {
               param1.y = 0;
            }
         }
         super.onShootByVel(param1);
      }
      
      private function addEff1_1() : void
      {
         var _loc2_:SkillConfigVO = null;
         var _loc1_:Vec2 = null;
         if(_eff1_2)
         {
            return;
         }
         if(_eff1_1 == false)
         {
            nowAnimation.gotoAndPlay(9);
            _loc2_ = _skillConfigVo1.subs[0];
            _loc1_ = this.body.velocity.copy();
            _loc1_.y = _loc2_.shootSpeedY;
            updateBodyVelocityNow(_loc1_);
            _effect1_1 = addSKillEntity("effect1_1",_loc2_,this.position,true,this.userVo.campId);
            _eff1_1 = true;
         }
         else if(nowAnimation.currentFrame >= 18)
         {
            nowAnimation.gotoAndStop(18);
         }
      }
      
      private function addEff1_2() : void
      {
         if(this._effect1_1)
         {
            _effect1_1.destory();
            _effect1_1 = null;
         }
         var _loc1_:SkillConfigVO = _skillConfigVo1.subs[1];
         _loc1_.assetLink = ["effect1_2"];
         addSKillEntity(_loc1_.assetLink[0],_loc1_,this.position,false,this.userVo.campId);
      }
      
      override protected function onBeginSkil() : void
      {
         super.onBeginSkil();
         if(currentActionState == 721 || currentActionState == 722)
         {
            skill2();
         }
      }
      
      override protected function toSkill(param1:int) : void
      {
         var _loc2_:SkillConfigVO = null;
         var _loc3_:* = undefined;
         if(param1 == 72)
         {
            _loc2_ = getSkillConfigVo(param1);
            if(skill2Awake1)
            {
               param1 = 721;
            }
            else if(skill2Awake2)
            {
               _loc3_ = new Vector.<int>();
               getKeydirs(22,_loc3_,1);
               if(_loc3_.length > 0)
               {
                  param1 = 722;
               }
            }
         }
         if(skill5Awake1 && param1 == 75)
         {
            if(_effect5_1 && _effect5_1.deleted == false)
            {
               return;
            }
         }
         super.toSkill(param1);
         if(skill5Awake1 && currentActionState == 75)
         {
            toIdle();
         }
      }
      
      override public function get skillConfigVo() : SkillConfigVO
      {
         var _loc1_:uint = uint(_actionState);
         if(_actionState == 721 || _actionState == 722)
         {
            _loc1_ = 72;
         }
         _skillConfigVo = getSkillConfigVo(_loc1_);
         return _skillConfigVo;
      }
      
      override protected function getMp(param1:int) : int
      {
         if(param1 == 721 || param1 == 722)
         {
            param1 = 72;
         }
         return super.getMp(param1);
      }
      
      override public function getIsAttacking() : Boolean
      {
         if(_actionState == 721 || _actionState == 722)
         {
            return true;
         }
         return super.getIsAttacking();
      }
      
      override protected function idle() : void
      {
         super.idle();
         if(_body)
         {
            if(this._body.gravMass != _gravity && _gravity != 0 && !canNotMJSBuff)
            {
               this._body.gravMass = _gravity;
            }
         }
      }
      
      private function getKeydirs(param1:uint, param2:Vector.<int>, param3:int) : void
      {
         var _loc4_:String = null;
         var _loc5_:Boolean = false;
         var _loc6_:int = userVo.keyBoard.getKeyCodeByAction(param1);
         if(_loc6_ > 0)
         {
            _loc4_ = keyboard.getKeyName(_loc6_);
            _loc5_ = _loc4_ && keyboard.pressed(_loc4_);
            if(!_loc5_)
            {
               _loc6_ = userVo.keyBoard.getKey2CodeByAction(param1);
               if(_loc6_ > 0)
               {
                  _loc4_ = keyboard.getKeyName(_loc6_);
                  _loc5_ = _loc4_ && keyboard.pressed(_loc4_);
               }
            }
            if(_loc5_)
            {
               param2.push(param3);
            }
         }
      }
      
      override protected function skill2() : void
      {
         var _loc2_:int = 0;
         var _loc1_:Entity = null;
         super.skill2();
         _keyPressFrame = 0;
         _skillConfigVo2 = skillConfigVo;
         _loc2_ = 0;
         while(_loc2_ < this._sons4.length)
         {
            _loc1_ = this._sons4[_loc2_];
            if(!(_loc1_.isDie || _loc1_.deleted))
            {
               RoleEntity(_loc1_).updateDirection(this.direction);
            }
            _loc2_++;
         }
         _effect2_1 = null;
         this._effect2_2 = false;
         _eff2_1 = false;
         if(skill2Awake2)
         {
            _body.gravMass = 0;
            _body.velocity.setxy(0,0);
         }
      }
      
      private function toEffect21() : void
      {
         var _loc5_:int = 0;
         var _loc1_:Entity = null;
         _loc5_ = 0;
         _loc1_ = null;
         var _loc2_:Number = 39;
         var _loc4_:Number = 59;
         var _loc3_:Number = 60;
         if(skill2Awake1)
         {
            _loc2_ = 19;
            _loc3_ = 90;
         }
         if(nowAnimation.currentFrame < _loc2_)
         {
            _keyPressFrame = nowAnimation.currentFrame;
            nowAnimation.gotoFrame(_loc3_);
            _loc5_ = 0;
            while(_loc5_ < this._sons4.length)
            {
               _loc1_ = this._sons4[_loc5_];
               if(!(_loc1_.isDie || _loc1_.deleted))
               {
                  RoleEntity(_loc1_).nowAnimation.gotoFrame(_loc3_);
               }
               _loc5_++;
            }
            addEff2_2();
         }
         else if(nowAnimation.currentFrame < _loc3_)
         {
            _keyPressFrame = nowAnimation.currentFrame;
            nowAnimation.gotoFrame(_loc3_);
            _loc5_ = 0;
            while(_loc5_ < this._sons4.length)
            {
               _loc1_ = this._sons4[_loc5_];
               if(!(_loc1_.isDie || _loc1_.deleted))
               {
                  RoleEntity(_loc1_).nowAnimation.gotoFrame(_loc3_);
               }
               _loc5_++;
            }
            addEff2_1(_keyPressFrame);
         }
         if(_keyPressFrame == 0)
         {
            _keyPressFrame = 1;
         }
      }
      
      private function addEff2_1(param1:int) : void
      {
         if(this._effect2_1)
         {
            return;
         }
         if(_eff2_1)
         {
            return;
         }
         _eff2_1 = true;
         GameFrame.juggler.delayCall(addEff2_1_1,100,param1);
      }
      
      private function addEff2_1_1(param1:int) : void
      {
         if(this._effect2_1)
         {
            return;
         }
         var _loc2_:SkillConfigVO = _skillConfigVo2.subs[0].clone();
         if(skill2Awake2 && currentActionState == 722)
         {
            _loc2_.arrow = 1;
            _loc2_.x = _loc2_.y = 0;
            _loc2_.shootSpeedY = _loc2_.shootSpeedX * Math.sin(-1.5707963267948966);
            _loc2_.shootSpeedX *= Math.cos(-1.5707963267948966);
         }
         reSetSKill2Skc(_loc2_,param1);
         this._effect2_1 = addSKillEntity(_loc2_.assetLink[0],_loc2_,this.position,true,this.userVo.campId);
      }
      
      private function addEff2_2() : void
      {
         if(this._effect2_2)
         {
            return;
         }
         this._effect2_2 = true;
         var _loc1_:SkillConfigVO = _skillConfigVo2.subs[1].clone();
         _loc1_.skillDefault += _keyPressFrame * 0.1;
         if(skill2Awake2 && currentActionState == 722)
         {
            _loc1_.arrow = 1;
            _loc1_.x = _loc1_.y = 0;
            _loc1_.assetLink = ["effect2_3"];
            _loc1_.shootSpeedY = _loc1_.shootSpeedX * Math.sin(-1.5707963267948966);
            _loc1_.shootSpeedX *= Math.cos(-1.5707963267948966);
         }
         reSetSKill2Skc(_loc1_,_keyPressFrame);
         addSKillEntity(_loc1_.assetLink[0],_loc1_,this.position,true,this.userVo.campId);
      }
      
      protected function reSetSKill2Skc(param1:SkillConfigVO, param2:int) : void
      {
         param1.skillDefault += param2 * 0.1;
         param1.suckBloodFactor = param2 * 0.1;
         param1.backLashFactor = param2 * 0.1;
      }
      
      override protected function skill3() : void
      {
         super.skill3();
      }
      
      override protected function skill4() : void
      {
         var _loc4_:SkillConfigVO = null;
         var _loc5_:int = 0;
         var _loc1_:SkillEntity = null;
         var _loc2_:int = 0;
         _frame4 = 0;
         _eff4Speed2 = false;
         _eff4Speed3 = false;
         _skillConfigVo4 = skillConfigVo;
         super.skill4();
         _effect4s.length = 0;
         _sonsInds = [1,2,3,4];
         if(skill4Awake1)
         {
            _sonsInds = [1,1,2,3,4];
         }
         var _loc3_:Array = [7,25,32,40,53];
         _loc5_ = 0;
         while(_loc5_ < 5)
         {
            _loc4_ = skillConfigVo.subs[_loc5_];
            _loc1_ = addSKillEntity("effect4_" + (_loc5_ + 1),_loc4_,this.position,false,this.userVo.campId);
            _effect4s.push(_loc1_);
            _loc2_ = _loc3_[_loc5_] * 33;
            GameFrame.juggler.delayCall(setEffect4_1Direction,_loc2_,_loc1_);
            _loc5_++;
         }
      }
      
      private function setEffect4_1Direction(param1:SkillEntity) : void
      {
         if(isDie || deleted)
         {
            return;
         }
         param1.updateDirection(this.direction);
      }
      
      private function addEff4Son() : void
      {
         if(currentActionState != 74)
         {
            return;
         }
         super.checkZhaoHuan(_skillConfigVo4);
      }
      
      override protected function checkZhaoHuan(param1:SkillConfigVO) : void
      {
         if(currentActionState == 74)
         {
            return;
         }
         super.checkZhaoHuan(param1);
      }
      
      override protected function onCreateUVOAtZhaoHuan(param1:UserVO) : void
      {
         param1.campId = this.userVo.campId;
         param1.hp = param1.hpMax = this.userVo.hpMax * this.son_hpPercent;
         param1.level = this.userVo.level;
         param1.atk = this.userVo.atk;
         param1.hit = this.userVo.hit;
         param1.critical = this.userVo.critical;
         param1.toughness = this.userVo.toughness;
         param1.lucky = this.userVo.lucky;
         param1.guardian = this.userVo.guardian;
         param1.magRes = this.userVo.magRes;
         param1.phyDef = this.userVo.phyDef;
         param1.reduceMagDef = this.userVo.reduceMagDef;
         param1.soulAtk = this.userVo.allsoulAtk;
         param1.soulCritical = this.userVo.allsoulCritical;
         param1.soulPhydef = this.userVo.allsoulPhydef;
         param1.soulToughness = this.userVo.allsoulToughness;
         if(skill4Awake2)
         {
            param1.dodge += 0.5;
         }
         param1.protectedData.build(param1.cloneToObject());
         param1.keyBoard = this.userVo.keyBoard;
         param1.type = "monster";
         param1.isLuoHan_ChenShi = this.userVo.isLuoHan_ChenShi;
         param1.oldAtk = param1.atk;
         param1.father = this.userVo;
         SimpleTextLog.getIns().log2("fs uvo.hp=" + param1.hp);
         super.onCreateUVOAtZhaoHuan(param1);
      }
      
      override public function handKey(param1:uint, param2:int) : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:int = 0;
         var _loc6_:String = null;
         for each(var _loc5_:Entity in _sons4)
         {
            if(!(_loc5_.isDie || _loc5_.deleted))
            {
               RoleEntity(_loc5_).userVo.setByPname("mp",this.userVo.mp);
               E3506(_loc5_).level = this.getSkillConfigVo(74).getRealLevel;
               E3506(_loc5_).mp1 = this.getMp(71);
               E3506(_loc5_).mp2 = this.getMp(72);
               E3506(_loc5_).skillOpen1 = this.getSillOpen(71);
               E3506(_loc5_).skillOpen2 = this.getSillOpen(72);
            }
         }
         super.handKey(param1,param2);
         if(currentActionState != 74)
         {
            _loc3_ = true;
            _loc4_ = userVo.keyBoard.getSkillActionByKey(param1);
            _loc6_ = ActionState.getName(_loc4_);
            if(manConfigVo.skills[_loc6_] && manConfigVo.skills[_loc6_].closed)
            {
               _loc3_ = false;
            }
            if(!_loc3_)
            {
               return;
            }
            for each(_loc5_ in _sons4)
            {
               if(!(_loc5_.isDie || _loc5_.deleted))
               {
                  if(this.getAttacking())
                  {
                     if(currentActionState == 71 || currentActionState == 72 || currentActionState == 721 || currentActionState == 722)
                     {
                        RoleEntity(_loc5_).handKey(param1,param2);
                     }
                  }
                  else
                  {
                     RoleEntity(_loc5_).handKey(param1,param2);
                  }
               }
            }
         }
      }
      
      override public function addSon(param1:Entity) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(param1 is E3506)
         {
            param1.nowAnimation.gotoAndStop(nowAnimation.currentFrame);
            _sons4.push(param1);
            E3506(param1).level = this.getSkillConfigVo(74).level;
            E3506(param1).gotoAndIdle(_sonsInds.shift());
            E3506(param1).awakeSkill2(skill2Awake1,skill2Awake2,getSkillConfigVo(72));
            E3506(param1).userVo.isPKBoss = this.userVo.isPKBoss;
            _loc2_ = 19006101;
            if(skill4Awake2)
            {
               _loc2_ = 19006201;
            }
            _loc3_ = 10100101;
            if(skill4Awake2)
            {
               _loc3_ = 10100201;
            }
            BuffModelManager.getIns().createBuff([_loc2_,_loc3_,89000101],null,1,param1.userVo);
         }
         super.addSon(param1);
      }
      
      override protected function skill5() : void
      {
         super.skill5();
         if(skill5Awake1)
         {
            if(_effect5_1 && _effect5_1.deleted == false)
            {
               return;
            }
         }
         if(_effect5_1)
         {
            _effect5_1.destory();
         }
         if(_effect5_2)
         {
            _effect5_2.destory();
         }
         _effect5_1 = null;
         _effect5_2 = null;
         if(skill5Awake2 == false)
         {
            _effect5_1 = addSKillEntity("effect5_0",skillConfigVo.subs[0],this.position,false,this.userVo.campId);
         }
         else
         {
            _effect5_1 = addSKillEntity("effect5_0",skillConfigVo.subs[0],this.position,false,this.userVo.campId,1,2,2,-1,W2e5);
         }
         _effect5_1.setLayerIndex(this.layerIndex - 1);
         BattleMap.Ins.swapManLayerChild();
         if(skill5Awake2 == false)
         {
            _effect5_2 = addSKillEntity("effect5_1",skillConfigVo.subs[1],this.position,false,this.userVo.campId);
         }
         else
         {
            _effect5_2 = addSKillEntity("effect5_1",skillConfigVo.subs[1],this.position,false,this.userVo.campId,1,2,2,-1,W2e5);
         }
      }
      
      override public function advanceTime(param1:Number) : void
      {
         var _loc3_:Vec2 = null;
         var _loc4_:int = 0;
         onAdvanceTimeBefore();
         if(deleted || isDie)
         {
            return;
         }
         super.advanceTime(param1);
         if(!(_actionState == 72 || currentActionState == 722))
         {
            if(this._body && this._body.gravMass != _gravity && _gravity != 0 && !this.canNotMJSBuff)
            {
               this._body.gravMass = _gravity;
            }
         }
         if(currentActionState != 71)
         {
            _eff1_2 = false;
            _buff_ba_ti2 = false;
         }
         if(_effect1_1)
         {
            if(_effect1_1.deleted == false)
            {
               _effect1_1.bodyPosition.setxy(this.bodyPosition.x,this.bodyPosition.y + 50);
            }
            else
            {
               _effect1_1 = null;
            }
         }
         if(_effect2_1 && _effect2_1.deleted)
         {
         }
         if(_effect5_1 && _effect5_1.deleted == false)
         {
            _effect5_1.bodyPosition.setxy(this.bodyPosition.x,this.bodyPosition.y + 50);
            if(skill5Awake1)
            {
               _effect5_1.updateDirection(this.direction);
            }
         }
         if(_effect5_2 && _effect5_2.deleted == false)
         {
            _effect5_2.bodyPosition.setxy(this.bodyPosition.x,this.bodyPosition.y + 50);
            if(skill5Awake1)
            {
               _effect5_2.updateDirection(this.direction);
            }
         }
         if(_actionState != 75)
         {
            if(skill5Awake1 == false)
            {
               if(_effect5_1 && _effect5_1.deleted == false)
               {
                  _effect5_1.destory();
               }
               if(_effect5_2 && _effect5_2.deleted == false)
               {
                  _effect5_2.destory();
               }
               _effect5_1 = null;
               _effect5_2 = null;
            }
         }
         if(currentActionState == 71)
         {
            _buff_ba_ti2 = true;
            _loc3_ = _body.velocity.copy();
            if(_loc3_.y >= 0)
            {
               addEff1_1();
               if(onGround && _eff1_2 == false)
               {
                  _eff1_2 = true;
                  nowAnimation.gotoAndPlay(19);
                  addEff1_2();
               }
               else if(onGround == false && _eff1_2 == false && startJumpPos.sub(this.bodyPosition).length < 6)
               {
                  _onGround = true;
                  _isJump = _isJump2 = false;
                  _eff1_2 = true;
                  nowAnimation.gotoAndPlay(19);
                  addEff1_2();
               }
            }
         }
         else if(_actionState == 72 || _actionState == 721 || _actionState == 722)
         {
            _loc4_ = 60;
            if(skill2Awake1)
            {
               _loc4_ = 90;
            }
            if(nowAnimation && nowAnimation.currentFrame >= _loc4_)
            {
               if(_keyPressFrame == 0)
               {
                  addEff2_1(_loc4_);
               }
            }
         }
         else if(_actionState == 74)
         {
            _frame4 = _frame4 + 1;
            if(_eff4BirthFrame.length > 0 && _eff4BirthFrame[0] <= nowAnimation.currentFrame)
            {
               addEff4Son();
               _eff4BirthFrame.shift();
            }
            for each(var _loc2_:SkillEntity in _effect4s)
            {
               if(_loc2_.deleted == false)
               {
                  _loc2_.bodyPosition.setxy(this.bodyPosition.x,this.bodyPosition.y + 50);
               }
            }
         }
      }
      
      override public function toIdle() : void
      {
         super.toIdle();
      }
      
      private function addEff5_1() : void
      {
      }
      
      private function addEff5_2() : void
      {
      }
      
      override public function get canAttack2() : Boolean
      {
         if(currentActionState == 71)
         {
            if(_effect1_1)
            {
               _effect1_1.destory();
               _effect1_1 = null;
            }
            _isAttack = false;
            return true;
         }
         return super.canAttack2;
      }
      
      override protected function updateKeyVelocity(param1:Vec2) : void
      {
         super.updateKeyVelocity(param1);
         if(GlobalData.getIsRelease619() && _moveKeyPressed && currentActionState == 74 && param1.x != 0)
         {
            updateDirection(keyControl.directionLR);
         }
      }
   }
}

