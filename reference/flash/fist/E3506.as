package viewers.entitys.man.enemys
{
   import com.game.engine.character.ActionState;
   import com.game.engine.core.GameFrame;
   import models.vo.SkillConfigVO;
   import nape.geom.Vec2;
   import nape.phys.Body;
   import viewers.entitys.man.MonsterEntity;
   import viewers.entitys.man.SkillEntity;
   
   public class E3506 extends MonsterEntity
   {
      
      private var _effect1_1:SkillEntity;
      
      private var _keyPressFrame:int;
      
      private var _effect2_1:SkillEntity;
      
      private var _skillConfigVo4:SkillConfigVO;
      
      private var _frame4:int = 0;
      
      private var _eff1_2:Boolean;
      
      private var _eff1_1:Boolean;
      
      private var _skillConfigVo2:SkillConfigVO;
      
      private var _skillConfigVo1:SkillConfigVO;
      
      private var _eff2_1:Boolean;
      
      public var level:int;
      
      public var mp1:int;
      
      public var mp2:int;
      
      public var skillOpen1:Boolean;
      
      public var skillOpen2:Boolean;
      
      private var _idleInd:int = -1;
      
      private var skill2Awake1:Boolean;
      
      private var skill2Awake2:Boolean;
      
      private var _isReleaseEffect21:Boolean;
      
      public function E3506()
      {
         super();
      }
      
      override protected function getMpEnough(param1:int) : Boolean
      {
         if(param1 == 721 || param1 == 722)
         {
            param1 = 72;
         }
         return this.superGetMpEnough(param1);
      }
      
      override protected function getMp(param1:int) : int
      {
         if(param1 == 71)
         {
            return mp1;
         }
         if(param1 == 72 || param1 == 721 || param1 == 722)
         {
            return mp2;
         }
         return 0;
      }
      
      override protected function getSillOpen(param1:int) : Boolean
      {
         if(param1 == 71)
         {
            return skillOpen1;
         }
         if(param1 == 72 || param1 == 721 || param1 == 722)
         {
            return skillOpen2;
         }
         return super.getSillOpen(param1);
      }
      
      override protected function onAttacking() : void
      {
         super.onAttacking();
      }
      
      override protected function onBeginSkil() : void
      {
         super.onBeginSkil();
         if(currentActionState == 721 || currentActionState == 722)
         {
            skill2();
         }
      }
      
      override public function setPhysicsBody(param1:Body) : void
      {
         super.setPhysicsBody(param1);
         param1.shapes.at(0).filter.fluidMask = 0;
         param1.shapes.at(1).filter.fluidMask = 0;
         GameFrame.juggler.delayCall(toddd,10000);
      }
      
      private function toddd() : void
      {
         if(this.getIsAttacking())
         {
            return;
         }
         goToDie();
      }
      
      override protected function onDieAfterVel() : void
      {
      }
      
      override protected function onAnimationPlayComplete() : void
      {
         goToDie();
      }
      
      override public function handKey(param1:uint, param2:int) : void
      {
         var _loc4_:SkillConfigVO = null;
         var _loc6_:int = 0;
         var _loc3_:int = userVo.keyBoard.getSkillActionByKey(param1);
         var _loc5_:String = ActionState.getName(_loc3_);
         if(getIsAttacking() == false)
         {
            if(_loc5_ == "effect1" || _loc5_ == "effect2")
            {
               _loc4_ = _manConfigVo.skills[ActionState.getName(_loc3_)];
               _loc4_.level = this.level;
               _loc4_.level2 = this.level + 10;
               _loc4_.updateSub();
               _loc4_ = this.getSkillConfigVo(_loc3_);
               super.handKey(param1,param2);
            }
            else
            {
               _loc6_ = userVo.keyBoard.getKeyCodeByAction(22);
               if(_loc6_ != param1)
               {
                  _loc6_ = userVo.keyBoard.getKey2CodeByAction(22);
               }
               if(_loc6_ > 0 && _loc6_ == param1)
               {
                  super.handKey(param1,param2);
               }
            }
         }
         else
         {
            super.handKey(param1,param2);
         }
      }
      
      public function gotoAndIdle(param1:int) : void
      {
         _idleInd = param1;
         updateAnimation();
      }
      
      override protected function getTextureActionName(param1:int) : String
      {
         var _loc2_:String = super.getTextureActionName(param1);
         if(_idleInd != -1 && param1 == 1)
         {
            _loc2_ = "idle" + _idleInd;
         }
         return _loc2_;
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
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         var _loc2_:String = null;
         var _loc3_:Boolean = false;
         super.onKeyUp(param1);
         if(currentActionState == 72 || currentActionState == 721 || currentActionState == 722)
         {
            if(userVo)
            {
               _loc5_ = userVo.keyBoard.getKeyCodeByAction(72);
               _loc4_ = userVo.keyBoard.getKey2CodeByAction(72);
            }
            if((_loc5_ == param1 || _loc4_ == param1 && _loc4_ > 0) && !_isReleaseEffect21)
            {
               _isReleaseEffect21 = true;
               _loc2_ = keyboard.getKeyName(_loc5_);
               _loc3_ = keyboard.justReleased(_loc2_);
               if(!_loc3_ && _loc4_ > 0)
               {
                  _loc2_ = keyboard.getKeyName(_loc4_);
                  _loc3_ = keyboard.justReleased(_loc2_);
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
      
      override protected function canUpdateKeyVelocity() : Boolean
      {
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
      
      override public function getIsAttacking() : Boolean
      {
         if(_actionState == 721 || _actionState == 722)
         {
            return true;
         }
         return super.getIsAttacking();
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
               else if(this._parent && this._parent.currentActionState == 722)
               {
                  param1 = 722;
               }
            }
         }
         super.toSkill(param1);
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
         super.skill2();
         _keyPressFrame = 0;
         if(!_skillConfigVo2)
         {
            _skillConfigVo2 = skillConfigVo;
         }
         _effect2_1 = null;
         _eff2_1 = false;
         if(skill2Awake2)
         {
            _body.gravMass = 0;
            _body.velocity.setxy(0,0);
         }
         _isReleaseEffect21 = false;
      }
      
      private function toEffect21() : void
      {
         var _loc1_:Number = 39;
         var _loc3_:Number = 59;
         var _loc2_:Number = 60;
         if(skill2Awake1)
         {
            _loc1_ = 19;
            _loc2_ = 90;
         }
         if(nowAnimation.currentFrame < _loc1_)
         {
            _keyPressFrame = nowAnimation.currentFrame;
            nowAnimation.gotoFrame(_loc2_);
            addEff2_2();
         }
         else if(nowAnimation.currentFrame < _loc2_)
         {
            _keyPressFrame = nowAnimation.currentFrame;
            nowAnimation.gotoFrame(_loc2_);
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
         param1.skillDefault += param2 * 0.025;
      }
      
      override public function advanceTime(param1:Number) : void
      {
         var _loc2_:Vec2 = null;
         var _loc3_:int = 0;
         onAdvanceTimeBefore();
         if(deleted || isDie)
         {
            return;
         }
         super.advanceTime(param1);
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
         if(currentActionState == 71)
         {
            _buff_ba_ti2 = true;
            _loc2_ = _body.velocity.copy();
            if(_loc2_.y >= 0)
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
            _loc3_ = 60;
            if(skill2Awake1)
            {
               _loc3_ = 90;
            }
            if(nowAnimation && nowAnimation.currentFrame >= _loc3_)
            {
               if(_keyPressFrame == 0)
               {
                  addEff2_1(_loc3_);
               }
            }
         }
      }
      
      public function awakeSkill2(param1:Boolean, param2:Boolean, param3:SkillConfigVO) : void
      {
         var _loc4_:SkillConfigVO = _manConfigVo.skills[ActionState.getName(72)];
         _loc4_.awakeSKId = 0;
         _loc4_.awakeSkLev = 0;
         if(param1)
         {
            _loc4_.awakeSKId = _loc4_.awakeningId.split(";")[0];
            _loc4_.awakeSkLev = param3.awakeSkLev;
            if(_loc4_.awakeSkLev == 0)
            {
               _loc4_.awakeSkLev = 1;
            }
            _loc4_.updateBuff();
         }
         else if(param2)
         {
            _loc4_.awakeSKId = _loc4_.awakeningId.split(";")[1];
            _loc4_.awakeSkLev = param3.awakeSkLev;
            if(_loc4_.awakeSkLev == 0)
            {
               _loc4_.awakeSkLev = 1;
            }
            _loc4_.updateBuff();
         }
         this.skill2Awake2 = param2;
         this.skill2Awake1 = param1;
      }
   }
}

