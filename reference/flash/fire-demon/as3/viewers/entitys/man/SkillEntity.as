package viewers.entitys.man
{
   import com.game.engine.battle.interfaces.ICollide;
   import com.game.engine.core.GameFrame;
   import com.game.engine.display.BitmapMovieClip;
   import com.game.engine.textures.Texture;
   import com.game.utils.Vector2D;
   import dragonBones.Armature;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.geom.ColorTransform;
   import models.constants.ManType;
   import models.managers.BattleModelManager;
   import models.managers.BuffModelManager;
   import models.managers.ManResourceManager;
   import models.managers.SkillModelManager;
   import models.skills.SkillParam;
   import models.vo.BodyUserData;
   import models.vo.BuffVO;
   import models.vo.SkillConfigVO;
   import modules.skywars.SWSKillEntity;
   import nape.geom.Vec2;
   import nape.phys.Body;
   import viewers.entitys.man.skills.szs.SZSkill2;
   import viewers.entitys.prefabs.WBattleItem;
   import viewers.entitys.weapons.QielanEntity;
   
   public class SkillEntity extends PlayerEntity
   {
      
      protected var _effName:String;
      
      protected var skill2:SkillConfigVO;
      
      public var loop:Boolean = false;
      
      public var gravMass:Number;
      
      protected var _oldPos:Vector2D;
      
      protected var _cleared:Boolean;
      
      private var _updateByBody:Boolean = true;
      
      private var _hited:Boolean;
      
      private var _inverted:Boolean;
      
      public var skInvert:Boolean;
      
      private var _newAB:Bitmap;
      
      private var _newTe:Texture;
      
      private var _stayInPlayer:PlayerEntity;
      
      private var _stayInPlayerVec:Vector2D;
      
      public var handGroundDestroy:Boolean;
      
      public var deletedDelBuff:BuffVO;
      
      private var _currDir:Object;
      
      private var _updateByDir:Boolean = true;
      
      private var _delayShootVel:Vec2;
      
      public function SkillEntity(param1:String, param2:SkillConfigVO)
      {
         super();
         skill2 = param2;
         this._effName = param1;
      }
      
      public static function build(param1:PlayerEntity, param2:SkillParam) : void
      {
         if(param2.shootFrame >= 0 && param2.addSubSkill > 0)
         {
            GameFrame.juggler.delayCall(param1.addSKillEntityNew,param2.shootFrame * 33,param2);
         }
      }
      
      public function get stayInPlayer() : PlayerEntity
      {
         return _stayInPlayer;
      }
      
      public function get hited() : Boolean
      {
         return _hited;
      }
      
      override public function setPhysicsBody(param1:Body) : void
      {
         super.setPhysicsBody(param1);
      }
      
      override public function advanceTime(param1:Number) : void
      {
         if(stayInPlayer)
         {
            if(stayInPlayer.isDie || stayInPlayer.deleted)
            {
               this.shootEnd();
               return;
            }
         }
         super.advanceTime(param1);
         if(this.skillConfigVo && this.skillConfigVo.fadeToAlpha)
         {
            this.display.alpha -= 0.03;
         }
         if(this.skillConfigVo && this.skillConfigVo.alphaTo1 != 0 && this.display.alpha < 1)
         {
            this.display.alpha += this.skillConfigVo.alphaTo1;
         }
         if(skp && skp.delayShoot > 0)
         {
            skp.cfg.delayShoot -= param1;
            if(skp.cfg.hasOwnProperty("startAngle"))
            {
               updateByBody(false);
               updateByDir(false);
               display.rotation = skp.cfg.startAngle;
            }
            if(skp.delayShoot <= 0)
            {
               if(skp.cfg.hasOwnProperty("startAngle"))
               {
                  updateByBody(true);
                  updateByDir(true);
                  display.rotation = skp.cfg.startAngle;
               }
               _moving = true;
               this.onShootByVel(this._delayShootVel);
               updateBodyVelocity(this._delayShootVel);
            }
         }
      }
      
      public function get effName() : String
      {
         return _effName;
      }
      
      override public function getIsAttacking() : Boolean
      {
         return _deleted == false;
      }
      
      override protected function checkInput() : void
      {
         var _loc1_:Vec2 = _body.velocity.copy();
         updateKeyVelocity(_loc1_);
         updateBodyVelocity(_loc1_);
      }
      
      override protected function onNormalTextureReady() : void
      {
         super.onNormalTextureReady();
      }
      
      override public function collided(param1:ICollide, param2:ICollide) : void
      {
         if(param2 == this)
         {
            return;
         }
         _hited = true;
         onHit(param1,param2);
         if(this.skillConfigVo.shootTime > 0 && this.skillConfigVo.shootThrough == 0)
         {
            if(this.skillConfigVo.shootDisDelay > 0)
            {
               GameFrame.juggler.delayCall(clear,this.skillConfigVo.shootDisDelay);
            }
            else
            {
               clear();
            }
         }
      }
      
      override public function getCollidedWidth(param1:ICollide) : Boolean
      {
         var _loc2_:Boolean = false;
         if(param1 is WBattleItem)
         {
            _loc2_ = Boolean(WBattleItem(param1).canCollideWidth(this.userVo,this.skillConfigVo));
            if(!_loc2_)
            {
               return false;
            }
         }
         return super.getCollidedWidth(param1);
      }
      
      protected function onHit(param1:ICollide, param2:ICollide) : void
      {
      }
      
      protected function clear() : void
      {
         toNext();
         this._isDie = true;
         _cleared = true;
         this.display.visible = false;
         if(_body)
         {
            keyboard.reset();
            keyControl.reset();
            _body.velocity.setxy(0,0);
            if(_body.space)
            {
               _body.space.liveBodies.remove(_body);
            }
         }
         GameFrame.juggler.remove(this);
      }
      
      override public function endCollide() : void
      {
         super.endCollide();
         if(_cleared)
         {
            destory();
            BattleModelManager.getIns().removeEntityByUid(Id,false);
         }
      }
      
      override public function destory() : void
      {
         if(_newTe)
         {
            _newTe.bd.dispose();
            _newTe = null;
         }
         if(deletedDelBuff)
         {
            BuffModelManager.getIns().del(deletedDelBuff);
            deletedDelBuff = null;
         }
         super.destory();
      }
      
      override protected function buildIdle() : void
      {
         super.buildIdle();
         _nowAnimation.loop = loop;
         _nowAnimation.name = effName;
         onAttacking();
      }
      
      override public function toWalk() : void
      {
         if(skInvert)
         {
            return;
         }
         super.toWalk();
      }
      
      override protected function onShootByVel(param1:Vec2) : void
      {
         if(skp && skp.onceSpeedY != 0)
         {
            param1.y = skp.onceSpeedY;
         }
         if(skp && skp.delayShoot > 0)
         {
            this._delayShootVel = param1.copy();
            param1.setxy(0,0);
         }
         else
         {
            _walk_acceleration = param1.x;
            _walkX_accelerationMax = Math.abs(param1.x);
            _walkY_accelerationMax = Math.abs(param1.y);
            setVelocity(param1.x,param1.y);
         }
      }
      
      override protected function onBeginSkil() : void
      {
         super.onBeginSkil();
         if(skillConfigVo)
         {
            if(skillConfigVo.shootTime > 0)
            {
               _checkShootFrame = 0;
            }
         }
      }
      
      override protected function onAttShootCheckFrame() : void
      {
         shoot();
      }
      
      override protected function shootEnd() : void
      {
         if(skp && skp.destroyDelay > 0)
         {
            clearShoot();
            canWalk = false;
            _body.velocity.setxy(0,0);
            skillConfigVo.isCanMove = false;
            if(GameFrame.juggler)
            {
               GameFrame.juggler.delayCall(super.shootEnd,skp.destroyDelay);
            }
         }
         else
         {
            super.shootEnd();
         }
      }
      
      override public function toIdle() : void
      {
         toNext();
         destory();
         BattleModelManager.getIns().removeEntityByUid(Id,false);
      }
      
      protected function toNext() : void
      {
         var _loc3_:int = 0;
         var _loc5_:SkillConfigVO = null;
         var _loc2_:SkillEntity = null;
         var _loc6_:PlayerEntity = null;
         var _loc4_:SkillConfigVO = null;
         _loc6_ = null;
         var _loc1_:RoleEntity = null;
         _loc1_ = null;
         if(_cleared)
         {
            return;
         }
         if(this.skillConfigVo.assetLink && this.skillConfigVo.assetLink.length > 1)
         {
            _loc3_ = this.skillConfigVo.assetLink.indexOf(this.effName);
            if(++_loc3_ < this.skillConfigVo.assetLink.length)
            {
               _loc5_ = getSkillconfig2();
               reSetSkc2(_loc5_);
               _loc2_ = addSKillEntity(this.skillConfigVo.assetLink[_loc3_],_loc5_,this.position,getSkill2Loop(),this.userVo.campId);
               reSetSk2(_loc2_);
               if(this.userVo)
               {
                  _loc6_ = BattleModelManager.getIns().getPlayerByEntityId(this.userVo.entitieId) as PlayerEntity;
                  if(_loc6_)
                  {
                     if(_loc6_.userVo && _loc6_.userVo.charID == this.userVo.charID)
                     {
                        _loc6_.onAddNextSKillEntity(this.skillConfigVo.assetLink[_loc3_],_loc5_,this.position,getSkill2Loop(),this.userVo.campId);
                     }
                  }
               }
            }
         }
         if(this.skp && this.skp.nextSkillId)
         {
            _loc4_ = SkillModelManager.getIns().getSkillConfigVOByID(this.skp.nextSkillId).clone();
            _loc4_.level = this.skillConfigVo.level;
            _loc4_.level2 = this.skillConfigVo.level2;
            _loc4_.buff_add_level = this.skillConfigVo.buff_add_level;
            _loc4_.updateBuff(_loc4_.buff_add_level);
            _loc4_.parentSkillId = this.skillConfigVo.id;
            _loc4_.zyId = this.skillConfigVo.zyId;
            if(this.userVo)
            {
               _loc6_ = BattleModelManager.getIns().getPlayerByEntityId(this.userVo.entitieId) as PlayerEntity;
               if(!_loc6_ && this.userVo.isMagic)
               {
                  if(this.userVo.parent)
                  {
                     _loc1_ = BattleModelManager.getIns().getPlayerByEntityId(this.userVo.parent.entitieId) as RoleEntity;
                     _loc6_ = _loc1_.magicWeaponEntity;
                     if(!(_loc6_ is QielanEntity))
                     {
                        _loc6_ = null;
                     }
                  }
               }
               else if(!_loc6_ && this.userVo.isMagicJianYi)
               {
                  if(this.userVo.parent)
                  {
                     _loc1_ = BattleModelManager.getIns().getPlayerByEntityId(this.userVo.parent.entitieId) as RoleEntity;
                     _loc6_ = _loc1_.magicWeaponEntity2;
                     if(_loc6_)
                     {
                        _loc6_.releaseSkcByJiYi(this.userVo,_loc4_,true,this.position.clone(),skp);
                        _loc6_ = null;
                     }
                  }
               }
               if(_loc6_)
               {
                  if(_loc6_.userVo && _loc6_.userVo.charID == this.userVo.charID)
                  {
                     _loc6_.releaseSkc(_loc4_,true,this.position.clone(),skp);
                  }
               }
            }
         }
      }
      
      protected function getSkill2Loop() : Boolean
      {
         return false;
      }
      
      protected function reSetSkc2(param1:SkillConfigVO) : void
      {
         param1.shootTime = -1;
         param1.shootFrame = -1;
         param1.assetLink = null;
         param1.x = 0;
         param1.y = 0;
         param1.arrow = 0;
      }
      
      protected function reSetSk2(param1:SkillEntity) : void
      {
      }
      
      protected function getSkillconfig2() : SkillConfigVO
      {
         return this.skillConfigVo.clone();
      }
      
      override protected function onAnimationPlayComplete() : void
      {
         super.onAnimationPlayComplete();
         shootEnd();
      }
      
      override protected function onUpdateAnimationBefore() : void
      {
         super.onUpdateAnimationBefore();
         _inverted = false;
         if(skInvert)
         {
            setInvert();
         }
      }
      
      override public function get skillConfigVo() : SkillConfigVO
      {
         return skill2;
      }
      
      override protected function getABTextureByActionState(param1:int) : Vector.<Texture>
      {
         var _loc3_:MovieClip = null;
         var _loc4_:* = undefined;
         var _loc5_:int = 0;
         var _loc2_:* = undefined;
         _loc5_ = 0;
         _loc2_ = undefined;
         if(this.skp && this.skp.angle > 0)
         {
            if(!_assetDict["ab"][effName][this.skp.angle])
            {
               _loc3_ = ManResourceManager.getIns().getMcByCharId(this.userVo.charID,"ab_" + this._effName);
               if(!_loc3_ && this is SZSkill2 && this.skillConfigVo.parentSkillId > 0)
               {
                  _loc3_ = ManResourceManager.getIns().getMcByCharId(this.skillConfigVo.parentSkillId,"ab_" + this._effName);
               }
               if(!_loc3_)
               {
                  _loc5_ = 0;
                  if(_direction == -1)
                  {
                     _loc5_ = 1;
                  }
                  if(!_assetDict["ab"][effName])
                  {
                     throw new Error("找不到ab." + effName,this.userVo.name);
                  }
                  return _assetDict["ab"][effName][_loc5_];
               }
               _loc3_.rotation = this.skp.angle;
               _loc4_ = Texture.drawMcToTextures(_loc3_,false,1,1,false,null,false,null,"low");
               _assetDict["ab"][effName][this.skp.angle] = _loc4_;
            }
            return _assetDict["ab"][effName][this.skp.angle];
         }
         _loc5_ = 0;
         if(_direction == -1)
         {
            _loc5_ = 1;
         }
         if(!_assetDict["ab"][effName])
         {
            throw new Error("找不到ab." + effName,this.userVo.name);
         }
         return _assetDict["ab"][effName][_loc5_];
      }
      
      override protected function getTextureByActionState(param1:int) : Vector.<Texture>
      {
         var _loc3_:String = effName;
         var _loc2_:Vector.<Texture> = _assetDict["ac"][_loc3_];
         if(!_loc2_)
         {
            throw new Error("找不到素材：" + _loc3_ + " id=" + this.userVo.charID);
         }
         return _loc2_;
      }
      
      override public function updateDirection(param1:int) : void
      {
         var _loc2_:Number = NaN;
         if(!_updateByDir)
         {
            return;
         }
         super.updateDirection(param1);
         if(skillConfigVo.arrow == 1)
         {
            _nowAnimation.scaleX = 1;
            _loc2_ = Math.atan2(skillConfigVo.shootSpeedY,skillConfigVo.shootSpeedX * _direction);
            _loc2_ = _loc2_ * 180 / 3.141592653589793;
            if(this.skp && this.skp.assetNoVertical == 1 && this._currDir == -1)
            {
               _loc2_ = 180 - _loc2_;
            }
            if(this.skp && this.skp.scaleVertical && skillConfigVo.shootSpeedX < 0)
            {
               _nowAnimation.scaleY = -1;
            }
            else if(this.skp && this.skp.scaleVerticalBullet && _currDir == -1)
            {
               _nowAnimation.scaleY = -1;
            }
            display.rotation = _loc2_;
         }
         if(this.skillConfigVo.fixedAssetDir == 1)
         {
            _nowAnimation.scaleX = 1;
         }
         if(skp && skp.angle > 0)
         {
            display.rotation = skp.angle;
         }
      }
      
      override public function updateDisplay() : void
      {
         var _loc1_:Number = NaN;
         if(_updateByBody == false)
         {
            return;
         }
         _position.x = display.x = _body.position.x;
         _position.y = display.y = _body.position.y + _body.bounds.height / 2;
         if(skillConfigVo.arrow == 1 && skillConfigVo.isCanMove)
         {
            if(!_oldPos)
            {
               _oldPos = _position.clone();
               _loc1_ = Math.atan2(skillConfigVo.shootSpeedY,skillConfigVo.shootSpeedX * _direction);
            }
            else
            {
               _loc1_ = Math.atan2(_position.y - _oldPos.y,_position.x - _oldPos.x);
            }
            _loc1_ = _loc1_ * 180 / 3.141592653589793;
            if(this.skp && this.skp.assetNoVertical == 1 && this._currDir == -1)
            {
               _loc1_ = 180 - _loc1_;
            }
            display.rotation = _loc1_;
            _oldPos.setXY(_position.x,_position.y);
         }
         if(skp && skp.angle > 0 && (skp.shootSpeedX == 0 || isNaN(skp.shootSpeedX)))
         {
            display.rotation = skp.angle;
         }
      }
      
      override public function getAttackBp() : Bitmap
      {
         if(_newAB)
         {
            _newAB.x = _newTe.pivot.x;
            _newAB.y = _newTe.pivot.y;
            _newAB.x += _position.x;
            _newAB.y += _position.y;
            return _newAB;
         }
         return super.getAttackBp();
      }
      
      public function setABbp(param1:Texture) : void
      {
         _newAB = new Bitmap(param1.bd);
         _newTe = param1;
      }
      
      override public function getType() : String
      {
         return ManType.SKILL;
      }
      
      public function updateByBody(param1:Boolean) : void
      {
         _updateByBody = param1;
      }
      
      public function updateByDir(param1:Boolean) : void
      {
         _updateByDir = param1;
      }
      
      public function setBodyRotation(param1:Number) : void
      {
         _body.allowRotation = true;
         _body.rotation = param1;
      }
      
      public function setInvert() : void
      {
         var _loc6_:Armature = null;
         var _loc3_:* = undefined;
         var _loc4_:BitmapMovieClip = null;
         var _loc1_:BitmapMovieClip = null;
         var _loc5_:Number = NaN;
         var _loc7_:Number = NaN;
         if(_inverted)
         {
            return;
         }
         _inverted = true;
         _invert = true;
         var _loc2_:Boolean = true;
         if(this.assetDict && this.assetDict["actionSkillFactory"])
         {
            _loc6_ = this.getSkillArmature(this.getSkillAramtureName());
            if(_loc6_)
            {
               _loc2_ = false;
               this.onSkillArmaAdd(_loc6_.display as DisplayObject);
               if(_invert)
               {
                  _nowAnimation.addChild(_loc6_.display as DisplayObject);
               }
            }
         }
         if(_loc2_)
         {
            _loc3_ = getTextureByActionState(1);
            _loc4_ = new BitmapMovieClip(_loc3_);
            _loc4_.loop = _nowAnimation.loop;
            _loc1_ = _nowAnimation.bm;
            _nowAnimation.add(_loc4_);
            _loc4_.advanceTime(0);
            _loc4_.updatePosition();
            _loc4_.blendMode = "invert";
            _loc5_ = 0;
            _loc7_ = 255;
            _loc1_.transform.colorTransform = new ColorTransform(_loc5_,_loc5_,_loc5_,1,_loc7_,_loc7_,_loc7_,0);
            _loc4_.blendMode = "subtract";
         }
      }
      
      public function setInvert2() : void
      {
         if(_inverted)
         {
            return;
         }
         var _loc1_:Vector.<Texture> = getTextureByActionState(1);
         var _loc2_:BitmapMovieClip = new BitmapMovieClip(_loc1_);
         _loc2_.loop = _nowAnimation.loop;
         _nowAnimation.add(_loc2_);
         _loc2_.gotoAndPlay(this._nowAnimation.bm.currentFrame);
         _loc2_.advanceTime(0);
         _loc2_.updatePosition();
         _loc2_.blendMode = "invert";
         _inverted = true;
      }
      
      public function setInvert3(param1:Vector.<Texture>) : void
      {
         if(_inverted)
         {
            return;
         }
         var _loc3_:BitmapMovieClip = new BitmapMovieClip(param1);
         _loc3_.loop = _nowAnimation.loop;
         _loc3_.gotoFrame(_nowAnimation.currentFrame + 1);
         var _loc2_:BitmapMovieClip = _nowAnimation.bm;
         _nowAnimation.add(_loc3_);
         var _loc4_:Number = 0;
         var _loc5_:Number = 255;
         _loc2_.transform.colorTransform = new ColorTransform(_loc4_,_loc4_,_loc4_,1,_loc5_,_loc5_,_loc5_,0);
         _loc3_.blendMode = "subtract";
         _inverted = true;
      }
      
      public function replaceTextures(param1:String, param2:Vector.<Texture>) : void
      {
         _effName = param1;
         _nowAnimation.bm.ts = param2;
      }
      
      override public function getMoveType() : int
      {
         if(skillConfigVo.gravity == 0)
         {
            return 2;
         }
         return 1;
      }
      
      override public function isDeleteCollide() : Boolean
      {
         return deleted;
      }
      
      public function setArrowStay(param1:PlayerEntity, param2:Number, param3:Number) : void
      {
         _stayInPlayer = param1;
         _stayInPlayerVec = new Vector2D(param2,param3);
      }
      
      public function getArrowStayPos() : Vector2D
      {
         return _stayInPlayerVec.add(_stayInPlayer.position);
      }
      
      public function setD(param1:Object) : void
      {
      }
      
      public function setdir(param1:int) : void
      {
         this._currDir = param1;
      }
      
      override protected function getSkillAramtureName() : String
      {
         return effName;
      }
      
      public function OnSensorEnter(param1:BodyUserData) : void
      {
         var _loc2_:SkillConfigVO = null;
         try
         {
            if(param1.gameObject is SWSKillEntity)
            {
               _loc2_ = this.skillConfigVo;
               if(_loc2_.shootTime > 0 && _loc2_.shootThrough == 0)
               {
                  if(_loc2_.shootDisDelay > 0)
                  {
                     GameFrame.juggler.delayCall(destory,_loc2_.shootDisDelay);
                  }
                  else
                  {
                     destory();
                  }
               }
            }
         }
         catch(error:Error)
         {
         }
      }
   }
}

