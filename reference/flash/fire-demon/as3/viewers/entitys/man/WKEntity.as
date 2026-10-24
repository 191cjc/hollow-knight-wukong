package viewers.entitys.man
{
   import com.game.engine.utils.SimpleTextLog;
   import models.managers.BattleModelManager;
   import models.managers.GlobalData;
   import models.vo.SkillConfigVO;
   import models.vo.UserVO;
   import nape.geom.Vec2;
   
   public class WKEntity extends RoleEntity
   {
      
      private var _effect5_1:SkillEntity;
      
      private var _effect5_2:SkillEntity;
      
      private var _skill3:Boolean;
      
      private var skill4Cfg:Object;
      
      public function WKEntity()
      {
         super();
         _maxAttak = 44;
      }
      
      override public function onCreateAfter() : void
      {
         super.onCreateAfter();
         try
         {
            if(this.userVo.configVo.param2)
            {
               this.skill4Cfg = this.userVo.configVo.param2.skill4;
            }
         }
         catch(error:Error)
         {
            SimpleTextLog.getIns().log2(error.message);
         }
      }
      
      override protected function skill3() : void
      {
         super.skill3();
         _skill3 = true;
         _body.gravMass = 0;
         _body.velocity.setxy(0,0);
      }
      
      override protected function skill5() : void
      {
         super.skill5();
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
         _skillConfigVo5 = skillConfigVo;
      }
      
      override protected function onMoveEnd() : void
      {
         if(_actionState != 75)
         {
            super.onMoveEnd();
         }
      }
      
      override protected function shoot() : void
      {
         super.shoot();
      }
      
      override public function advanceTime(param1:Number) : void
      {
         onAdvanceTimeBefore();
         if(deleted || isDie)
         {
            return;
         }
         super.advanceTime(param1);
         if(_actionState == 75)
         {
            if(_nowAnimation.currentFrame >= 5)
            {
               addEff5_1();
            }
            if(_effect5_1 && _effect5_1.deleted)
            {
               addEff5_2();
               getWingTexture(751,_effect5_2.nowAnimation);
            }
            if(_effect5_2 && _effect5_2.deleted)
            {
               _effect5_2 = null;
               toIdle();
            }
            if(_effect5_2)
            {
               if(_wingEntity)
               {
                  _wingEntity.advanceTime(this.direction,_effect5_2.nowAnimation);
               }
            }
         }
         if(_skill3 && currentActionState != 73)
         {
            _body.gravMass = _gravity;
            _skill3 = false;
         }
      }
      
      override public function toIdle() : void
      {
         if(_effect5_2 && _effect5_2.deleted == false)
         {
            return;
         }
         super.toIdle();
      }
      
      private function addEff5_1() : void
      {
         if(_effect5_1)
         {
            return;
         }
         var _loc1_:SkillConfigVO = _skillConfigVo5.subs[0];
         _loc1_ = _loc1_.clone();
         _loc1_.x = 177;
         _loc1_.y = -95;
         _effect5_1 = addSKillEntity("effect5_1",_loc1_,this.position,false,this.userVo.campId);
      }
      
      private function addEff5_2() : void
      {
         if(_effect5_2)
         {
            return;
         }
         this._body.velocity.x = 0;
         var _loc1_:SkillConfigVO = skillConfigVo.subs[1];
         _effect5_2 = addSKillEntity("effect51",_loc1_,this.position,false,this.userVo.campId);
      }
      
      override protected function onShootByVel(param1:Vec2) : void
      {
         var _loc4_:* = 0;
         var _loc2_:* = 0;
         var _loc3_:* = 0;
         var _loc6_:* = 0;
         var _loc9_:Boolean = false;
         var _loc7_:Boolean = false;
         if(_direction == 1)
         {
            _loc4_ = uint(this.userVo.keyBoard.getKeyCodeByAction(24));
            _loc3_ = uint(this.userVo.keyBoard.getKey2CodeByAction(24));
         }
         else
         {
            _loc4_ = uint(this.userVo.keyBoard.getKeyCodeByAction(23));
            _loc3_ = uint(this.userVo.keyBoard.getKey2CodeByAction(23));
         }
         _loc2_ = uint(this.userVo.keyBoard.getKeyCodeByAction(22));
         _loc6_ = uint(this.userVo.keyBoard.getKey2CodeByAction(22));
         var _loc8_:String = keyboard.getKeyName(_loc4_);
         var _loc5_:String = keyboard.getKeyName(_loc2_);
         if(keyboard.pressed(_loc8_))
         {
            _loc9_ = true;
         }
         if(keyboard.pressed(_loc5_))
         {
            _loc7_ = true;
         }
         if(_loc3_ > 0 && _loc6_ > 0)
         {
            _loc8_ = keyboard.getKeyName(_loc3_);
            _loc5_ = keyboard.getKeyName(_loc6_);
            if(!_loc9_ && keyboard.pressed(_loc8_))
            {
               _loc9_ = true;
            }
            if(!_loc7_ && keyboard.pressed(_loc5_))
            {
               _loc7_ = true;
            }
         }
         if(currentActionState == 72)
         {
            if(_loc9_ && skillConfigVo.id == 1101220)
            {
               _shootTotalTime = 500;
            }
            else if(_loc7_ && skillConfigVo.id == 1101120)
            {
               param1.x = 0;
               param1.y = -250;
               maxVelocity.x = 0;
               maxVelocity.y = Math.abs(param1.y);
               _nowAnimation.rotation = -90 * _direction;
               _nowAnimation.x += _direction * 50;
               if(onGround == false)
               {
                  resetFloor();
               }
            }
         }
      }
      
      override protected function onClearShootAfter() : void
      {
         super.onClearShootAfter();
         if(currentActionState == 72)
         {
            toIdle();
         }
      }
      
      override public function calDamageBySkillIdRatio(param1:int, param2:SkillConfigVO, param3:UserVO) : int
      {
         var _loc6_:SkillConfigVO = null;
         var _loc5_:Boolean = false;
         var _loc7_:int = 0;
         var _loc4_:Number = NaN;
         if(GlobalData.getIsRelease619() && this.skill4Cfg)
         {
            _loc6_ = getSkillConfigVo(74);
            _loc5_ = hasBuff(_loc6_.myBuff[0]);
            if(_loc5_ && param2 && this.skill4Cfg.skillIds.indexOf(param2.id) > -1)
            {
               _loc7_ = BattleModelManager.getIns().hitCombo;
               _loc7_ = Math.min(_loc7_,this.skill4Cfg.hitCombMax);
               _loc4_ = this.skill4Cfg.ratioA[_loc6_.getRealLevel] * _loc7_;
               _loc4_ = param1 * (1 + _loc4_);
               SimpleTextLog.getIns().log2("最终伤害=" + _loc4_,"原=" + param1);
               return _loc4_;
            }
         }
         return param1;
      }
   }
}

