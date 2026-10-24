package viewers.entitys.man
{
   import com.game.engine.ai.behaviors.interfaceclass.INode;
   import com.game.engine.animation.DelayedCall;
   import com.game.engine.character.ActionState;
   import com.game.engine.core.GameFrame;
   import com.game.engine.utils.SimpleTextLog;
   import com.game.net.AssetItem;
   import com.game.net.AssetManager;
   import com.game.net.AssetsURL;
   import com.game.ui.KeyControl;
   import com.game.ui.KeyboradInput;
   import com.game.utils.Vector2D;
   import controllers.xms.MutilPlayerMapOperationCmd;
   import flash.geom.ColorTransform;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import models.GameEvent;
   import models.ai.acs.AIBasic;
   import models.ai.acs.AttackAI;
   import models.ai.acs.AwayAI;
   import models.ai.acs.AwayKjAI;
   import models.ai.acs.FollowAI;
   import models.ai.acs.FollowPathAI;
   import models.ai.acs.IdleAI;
   import models.ai.acs.JumpAI;
   import models.ai.acs.OutAngleAI;
   import models.ai.acs.SeekAI;
   import models.ai.acs.WalkAI;
   import models.ai.acs.WalkBackAI;
   import models.ai.acs.WalkInRectangleAI;
   import models.configs.CommonConfig;
   import models.constants.GroupType;
   import models.constants.ManType;
   import models.managers.BattleModelManager;
   import models.vo.BehaviorConfigVO;
   import models.vo.BodyUserData;
   import models.vo.BuffVO;
   import models.vo.HorseVO;
   import models.vo.ManConfigVO;
   import models.vo.RoleConfigVO;
   import models.vo.UserVO;
   import modules.ApplicationFacade;
   import modules.skywars.SWManEntity;
   import nape.callbacks.InteractionCallback;
   import nape.dynamics.Arbiter;
   import nape.geom.Vec2;
   import nape.phys.Body;
   import viewers.component.AnimationMovieclip;
   import viewers.container.BattleMap;
   import viewers.entitys.Entity;
   import viewers.entitys.boats.BoatEntity;
   import viewers.entitys.horses.HorseEntity;
   import viewers.entitys.others.MoveEntity;
   import viewers.entitys.others.ShipEntity;
   
   public class ManEntity extends Entity
   {
      
      public static const UPDATE:String = "update";
      
      protected var _enterEdge:Boolean;
      
      public var canuseKey:Boolean = true;
      
      public var canuseMagic:Boolean = false;
      
      private var _globalX:Number;
      
      private var _globalY:Number;
      
      protected var _nameLabel:TextField;
      
      private var mIsDown:Boolean;
      
      protected var _jumpSpeed:Number = 0;
      
      protected var _jumpStart:Number = -34;
      
      protected var _jumpStart2:Number = -34;
      
      protected var _gravity:Number = 0;
      
      protected var _jumpStartY:Number = -1;
      
      protected var _jumpNum:uint = 0;
      
      protected var _manConfigVo:ManConfigVO;
      
      protected var _isPauseJump:Boolean;
      
      private var _lastHurtTime:int;
      
      private var _keyboard:KeyboradInput;
      
      private var _keyControl:KeyControl;
      
      private var _time:Number;
      
      protected var _isDestroy:Boolean;
      
      protected var _priority:int = 2;
      
      private var _cleared:Boolean;
      
      protected var _needChangeFloor:Vector.<Body> = new Vector.<Body>();
      
      protected var _minX:Number;
      
      protected var _isJump2:Boolean;
      
      protected var _isJump3:Boolean;
      
      protected var _guanVisible:Boolean = true;
      
      protected var _jumpCrit:Boolean;
      
      protected var _normalAssetLoaded:Boolean;
      
      protected var _isJump:Boolean;
      
      protected var _canManipulate:Boolean = true;
      
      public var hided:Boolean;
      
      protected var _moving:Boolean;
      
      protected var _dynamicFriction:Number = 1;
      
      protected var _staticFriction:Number = 2;
      
      protected var _onGround:Boolean = false;
      
      protected var _grounds:Vector.<Body> = new Vector.<Body>();
      
      protected var _isAttack:Boolean;
      
      protected var _lasetActionState:int;
      
      protected var _attackIndex:uint;
      
      protected var _actionPlayCompleteTime:Number = 0;
      
      protected var _additionalVelocity:Vec2 = Vector2D.getVec2();
      
      protected var _additionalVelocity3:Vec2 = Vector2D.getVec2();
      
      protected var _additionalOtherVelocity:Vec2 = Vector2D.getVec2();
      
      protected var _additionalMaxVelocity:Vec2 = Vector2D.getVec2();
      
      protected var _walk_acceleration:Number = 30;
      
      public var maxVelocity:Vec2 = Vector2D.getVec2(100,0);
      
      protected var _jump1Height:Number = 330;
      
      protected var _jump2Height:Number = 330;
      
      protected var _walkX_accelerationMax:int = 70;
      
      protected var _walkY_accelerationMax:int = 70;
      
      protected var _run_accelerationMax:int = 110;
      
      protected var _jump1HeightMax:int = 330;
      
      protected var _jump2HeightMax:int = 330;
      
      protected var _jump1HeightMaxWater:int = 330;
      
      protected var _jump2HeightMaxWater:int = 330;
      
      protected var _jump1HeightMaxLand:int = 330;
      
      protected var _jump2HeightMaxLand:int = 330;
      
      protected var _hurtVelocity:Vector2D = new Vector2D(20,100);
      
      protected var _dieVelocity:Vector2D = new Vector2D(200,100);
      
      protected var _AI:AIBasic;
      
      private var _screenRange:Rectangle;
      
      protected var _AIs:Vector.<AIBasic> = new Vector.<AIBasic>();
      
      protected var _moveKeyPressed:Boolean;
      
      protected var _inWater:Boolean;
      
      protected var _buff_xi_ying:BuffVO;
      
      protected var _buff_xi_ying2:BuffVO;
      
      protected var _maxAttak:int = 45;
      
      private var _velocity:Vec2 = Vector2D.getVec2(0,0);
      
      protected var _waterScreenRange:Rectangle;
      
      private var _lasetAttackPressedTime:int;
      
      protected var _standOutBody:Body;
      
      protected var _standInBody:Body;
      
      protected var _inSand:Boolean;
      
      protected var _additionalVelocityBySand:Vec2 = Vector2D.getVec2(0,0);
      
      private var _moveMaxAddVelocity:Vec2 = Vector2D.getVec2(0,0);
      
      protected var _tempcheckInputVelo:Vec2;
      
      protected var _addWalkVelocity:Vector2D = new Vector2D();
      
      protected var _addRunVelocity:Vector2D = new Vector2D();
      
      protected var _addJumpVelocity:Vector2D = new Vector2D();
      
      public var additionalWinVelocity:Vec2 = Vector2D.getVec2();
      
      private var _inWalk:Boolean;
      
      protected var _changeFlyT:DelayedCall;
      
      protected var path:Vector.<Vector2D>;
      
      private var _lastPos:Vector2D = Vector2D.zero;
      
      private var _startPost:Vector2D;
      
      private var _isManual:Boolean = true;
      
      public var notNormalVel:Boolean;
      
      protected var _animationHeight:int = 0;
      
      protected var awayKjAi:AwayKjAI;
      
      protected var _currStayInSky:Boolean;
      
      public var isRole:Boolean;
      
      private var _canWuShan:Boolean = true;
      
      public var isNotLimtSpeed:Boolean;
      
      public function ManEntity()
      {
         super();
         if(CommonConfig.deathMove)
         {
            _dieVelocity.x = CommonConfig.deathMove.x;
            _dieVelocity.y = CommonConfig.deathMove.y;
         }
      }
      
      public function get walkX_accelerationMax() : int
      {
         return _walkX_accelerationMax;
      }
      
      public function get additionalOtherVelocity() : Vec2
      {
         return _additionalOtherVelocity;
      }
      
      public function get onGround() : Boolean
      {
         return _onGround;
      }
      
      public function setEnterEdge(param1:Boolean) : void
      {
         this._enterEdge = param1;
      }
      
      public function get enterEdge() : Boolean
      {
         return _enterEdge;
      }
      
      public function get AI() : AIBasic
      {
         return this._AI;
      }
      
      public function get run_accelerationMax() : int
      {
         return _run_accelerationMax;
      }
      
      public function get dieVelocity() : Vector2D
      {
         return _dieVelocity;
      }
      
      public function get inSand() : Boolean
      {
         return _inSand;
      }
      
      public function get waterScreenRange() : Rectangle
      {
         return _waterScreenRange;
      }
      
      public function get manConfigVo() : ManConfigVO
      {
         return _manConfigVo;
      }
      
      override public function initialization() : void
      {
         super.initialization();
         buildKeyControl();
      }
      
      protected function buildKeyControl() : void
      {
         _keyboard = new KeyboradInput();
         _keyControl = new KeyControl();
         keyControl.initialization(_keyboard);
      }
      
      protected function onMouseOut() : void
      {
      }
      
      protected function onHover() : void
      {
      }
      
      protected function onMouseUp() : void
      {
      }
      
      public function buildFromVO(param1:UserVO, param2:ManConfigVO) : void
      {
         _userVo = param1;
         _manConfigVo = param2;
         buildIdle();
         loadNormal();
         buildShadow();
      }
      
      override protected function onNormalTextureReady() : void
      {
         _actionState = 0;
         buildIdle();
         buildName();
         if(!_animationHeight && _nowAnimation)
         {
            _animationHeight = _nowAnimation.height;
            if(_armature && this.getType() == "role")
            {
               _animationHeight = 130;
            }
         }
      }
      
      protected function buildIdle() : void
      {
         if(deleted)
         {
            return;
         }
         idle();
      }
      
      protected function idle() : void
      {
         if(_actionState != 1)
         {
            if(_isAttack)
            {
               _isAttack = false;
            }
            _actionState = 1;
            updateAnimation();
         }
      }
      
      protected function walk() : void
      {
         if(_actionState != 2)
         {
            _actionState = 2;
            updateAnimation();
         }
      }
      
      protected function run() : void
      {
         if(_actionState != 3)
         {
            _actionState = 3;
            updateAnimation();
         }
      }
      
      public function buildShadow() : void
      {
      }
      
      public function hurtFall() : void
      {
         if(_actionState != 51)
         {
            this.stopAllAction();
            _actionState = 51;
            updateAnimation();
         }
      }
      
      protected function onJumpDown() : void
      {
         if(_actionState != 7)
         {
            return;
         }
      }
      
      private function ttt() : void
      {
      }
      
      public function stopJump() : void
      {
         _isJump = _isJump2 = _isJump3 = false;
      }
      
      protected function pauseJump() : void
      {
      }
      
      override public function update() : void
      {
         super.update();
      }
      
      override public function advanceTime(param1:Number) : void
      {
         if(deleted)
         {
            return;
         }
         super.advanceTime(param1);
         checkInput();
         if(_nowAnimation && _nowAnimation.isComplete)
         {
            _actionPlayCompleteTime = GameFrame.getGameTimer();
            _lasetActionState = _actionState;
            if(_isAttack)
            {
               _isAttack = false;
               if(_attackIndex > 41 && _attackIndex <= 45 && _actionState != _attackIndex)
               {
                  onAttackComplete();
                  return;
               }
               if(_actionState == 46)
               {
                  if(_userVo.isRun == false)
                  {
                     _keyControl.resetDouble();
                  }
                  stopWalk();
               }
            }
            onAnimationPlayComplete();
         }
      }
      
      protected function onAttackComplete() : void
      {
         if(userVo && userVo.isRole)
         {
            if(BattleModelManager.getIns().getGameTimer() - _lasetAttackPressedTime < 300)
            {
               attack(_actionState + 1);
            }
         }
         else if(userVo && userVo.isPk == true && userVo.campId != 1)
         {
         }
      }
      
      protected function onAnimationPlayComplete() : void
      {
         if(_actionState == 100)
         {
            return;
         }
         if(_moving)
         {
            if(_isJump || _isJump2 || _isJump3)
            {
               idle();
            }
            else if(keyControl.double)
            {
               toRun();
            }
            else
            {
               toWalk();
            }
         }
         else
         {
            idle();
         }
      }
      
      protected function checkInput() : void
      {
         if(deleted || !_body)
         {
            return;
         }
         if(!_tempcheckInputVelo)
         {
            _tempcheckInputVelo = _body.velocity.copy();
         }
         else
         {
            _tempcheckInputVelo.setxy(_body.velocity.x,_body.velocity.y);
         }
         _inWalk = false;
         if(canUpdateKeyVelocity())
         {
            if(getAttacking())
            {
               if(this is HorseEntity)
               {
               }
               if(keyControl.directionLR != _direction)
               {
                  if(getonKeyDirNoDirect())
                  {
                     onKeyDirNoDirect(_tempcheckInputVelo);
                     return;
                  }
               }
            }
            updateKeyVelocity(_tempcheckInputVelo);
         }
         else
         {
            onCanNotUpdateKeyVelocity(_tempcheckInputVelo);
         }
         updateBodyVelocity(_tempcheckInputVelo);
      }
      
      protected function getonKeyDirNoDirect() : Boolean
      {
         return true;
      }
      
      protected function onKeyDirNoDirect(param1:Vec2) : void
      {
      }
      
      protected function onCanNotUpdateKeyVelocity(param1:Vec2) : void
      {
      }
      
      protected function canUpdateKeyVelocity() : Boolean
      {
         if(_actionState == 5 || _actionState == 41 || _actionState == 42 || _actionState == 43 || _actionState == 44 || _actionState == 45 || _actionState == 71 || _actionState == 72 || _actionState == 73 || _actionState == 74 || _actionState == 741 || _actionState == 75 || _actionState == 756 || _actionState == 721 || _actionState == 722 || _actionState == 731 || _buff_xi_ying2)
         {
            return false;
         }
         return true;
      }
      
      private function getStandInIce() : Boolean
      {
         if(_standInBody && _standInBody.userData.data)
         {
            if(BodyUserData(_standInBody.userData.data).group == GroupType.ICE)
            {
               return true;
            }
         }
         return false;
      }
      
      protected function onWalkUPDown(param1:Vec2) : void
      {
         if(getMoveType() == 2 || getMoveType() == 4)
         {
            if(!_changeFlyT)
            {
               param1.y = 0;
               if(_keyControl.directionUB != 0)
               {
                  _moveKeyPressed = true;
                  param1.y = (_walkY_accelerationMax + _addWalkVelocity.y) * keyControl.directionUB;
               }
            }
         }
      }
      
      protected function updateKeyVelocity(param1:Vec2) : void
      {
         _moveKeyPressed = false;
         onWalkUPDown(param1);
         if(keyControl.directionLR != 0)
         {
            _moveKeyPressed = true;
            if(keyControl.double)
            {
               maxVelocity.x = _run_accelerationMax + _moveMaxAddVelocity.x + _addRunVelocity.x;
               param1.x = maxVelocity.x * keyControl.directionLR * this.getRealDir();
            }
            else
            {
               maxVelocity.x = _walkX_accelerationMax + _moveMaxAddVelocity.x + _addWalkVelocity.x;
               param1.x = maxVelocity.x * keyControl.directionLR * this.getRealDir();
            }
            if(this is SWManEntity && this.userVo.type == "role")
            {
               if(keyControl.directionLR == 1)
               {
                  maxVelocity.x = _run_accelerationMax + _moveMaxAddVelocity.x + _addRunVelocity.x;
                  param1.x = maxVelocity.x * keyControl.directionLR * this.getRealDir();
               }
               else if(keyControl.directionLR == -1)
               {
                  maxVelocity.x = _walkX_accelerationMax + _moveMaxAddVelocity.x + _addWalkVelocity.x;
                  param1.x = maxVelocity.x * keyControl.directionLR * this.getRealDir();
               }
            }
            if(getStandInIce())
            {
               param1.x = maxVelocity.x * this.direction;
            }
            onWalkLeftDown(param1);
         }
         if(this is Ytu2Entity)
         {
         }
         if(_moveKeyPressed && !_moving)
         {
            if(!(getStandInIce() && body.velocity.x != 0))
            {
               updateDirection(keyControl.directionLR);
            }
            if(keyControl.double)
            {
               toRun();
            }
            else
            {
               toWalk();
            }
            _moving = true;
         }
         else if(_moveKeyPressed == false && _moving)
         {
            if(BattleModelManager.getIns().levelInfo && BattleModelManager.getIns().levelInfo.isMutilPlayerMap() && MutilPlayerMapOperationCmd.NeedSendMove)
            {
               GameFrame.juggler.delayCall(onRoleMove,10000);
            }
            else
            {
               ApplicationFacade.getInstance().sendNotification("CMD_RoleMove",this);
            }
            if(!(_isJump || _isJump2 || _isJump3 || _isAttack))
            {
               if(getStandInIce())
               {
                  idle();
               }
               else
               {
                  param1.x = 0;
                  toIdle();
               }
            }
            _moving = false;
         }
         if(_moveKeyPressed)
         {
            if(_isAttack == false)
            {
               if(!getStandInIce())
               {
                  updateDirection(keyControl.directionLR * this.getRealDir());
               }
            }
            else
            {
               updateDirectionInAttacking(keyControl.directionLR * this.getRealDir());
            }
         }
         else if(getStandInIce())
         {
         }
      }
      
      protected function updateDirectionInAttacking(param1:int) : void
      {
      }
      
      protected function onWalkLeftDown(param1:Vec2) : void
      {
      }
      
      public function getRealDir() : Number
      {
         return 1;
      }
      
      private function onRoleMove() : void
      {
         if(isDie || deleted)
         {
            return;
         }
         if(this.position.equals(_lastPos))
         {
            return;
         }
         _lastPos = this.position.clone();
         ApplicationFacade.getInstance().sendNotification("CMD_RoleMove",this);
      }
      
      protected function updateKeyVelocityByFix(param1:Vec2, param2:Vec2) : void
      {
         param1.x = param2.x;
         param1.y = param2.y;
      }
      
      protected function stopWalk() : void
      {
         _moving = false;
         if(_additionalOtherVelocity.length == 0)
         {
            setMaterial(_staticFriction,_dynamicFriction);
         }
         else
         {
            setMaterial(0,0);
         }
         updateBodyVelocity(new Vec2(0,0));
      }
      
      private function dispatchEventWith(param1:String, param2:Boolean = false) : void
      {
         dispatchEvent(new GameEvent(param1,{
            "e":this,
            "byStop":param2
         }));
      }
      
      public function toWalk() : void
      {
         if(!_isJump && !_isAttack)
         {
            _isAttack = false;
            setMaterial(0,0);
            walk();
         }
      }
      
      protected function toJumpDown() : void
      {
      }
      
      public function toRun() : void
      {
         if(!_isJump && !_isAttack)
         {
            _isAttack = false;
            setMaterial(0,0);
            run();
         }
      }
      
      protected function updateBodyVelocity(param1:Vec2) : void
      {
         var _loc2_:Boolean = false;
         if(!_body)
         {
            return;
         }
         if(notNormalVel)
         {
            param1.setxy(0,0);
         }
         if(_additionalMaxVelocity.length > 0)
         {
            maxVelocity.x = _additionalMaxVelocity.x;
            maxVelocity.y = _additionalMaxVelocity.y;
         }
         if(maxVelocity.x == 0)
         {
            param1.x = 0;
         }
         param1.x += _additionalVelocity.x;
         param1.y += _additionalVelocity.y;
         param1.x += _additionalVelocity3.x;
         param1.y += _additionalVelocity3.y;
         param1.x += _additionalVelocityBySand.x;
         param1.y += _additionalVelocityBySand.y;
         param1.x += _additionalOtherVelocity.x;
         param1.y += _additionalOtherVelocity.y;
         if(this is BLMEntity)
         {
         }
         if(_body.position.x - _body.bounds.width / 2 <= _minX && param1.x < 0)
         {
            param1.x = 0;
         }
         if(userVo && userVo.configVo && userVo.configVo.getMoveType() == 2)
         {
            if(!(this is SWManEntity))
            {
               if(_body.position.y - _body.bounds.height / 2 <= 0 && param1.y < 0 || _body.position.y - _body.bounds.height / 2 >= BattleModelManager.getIns().levelInfo.height && param1.y > 0)
               {
                  SimpleTextLog.getIns().log2("要出副本height了");
                  if(!(this is SkillEntity))
                  {
                     param1.y = 0;
                  }
               }
            }
         }
         if(getMoveType() == 4)
         {
            if(_waterScreenRange)
            {
               if(_body.position.y - _body.bounds.height / 2 <= _waterScreenRange.y)
               {
                  param1.y = 1;
                  _loc2_ = true;
               }
               if(_body.position.x + _body.bounds.width / 2 >= _waterScreenRange.x + _waterScreenRange.width)
               {
                  param1.x = -1;
               }
            }
         }
         if(_buff_xi_ying2)
         {
            if(!_loc2_)
            {
               param1 = _additionalVelocity.copy();
            }
            setMaterial(0,0);
            _body.gravMass = 0;
         }
         if(!this.isNotLimtSpeed)
         {
            if(maxVelocity.x != 0)
            {
               if(param1.x > maxVelocity.x)
               {
                  param1.x = maxVelocity.x;
               }
               else if(param1.x < -maxVelocity.x)
               {
                  param1.x = -maxVelocity.x;
               }
            }
            if(maxVelocity.y != 0)
            {
               if(param1.y > maxVelocity.y)
               {
                  param1.y = maxVelocity.y;
               }
               else if(param1.y < -maxVelocity.y)
               {
                  param1.y = -maxVelocity.y;
               }
            }
         }
         if(this is MonsterEntity)
         {
            if(param1.x == 0)
            {
            }
         }
         if(currentActionState == 1)
         {
            if(additionalWinVelocity.length > 0)
            {
               param1.x = additionalWinVelocity.x;
               param1.y = additionalWinVelocity.y;
            }
         }
         else
         {
            param1.x += additionalWinVelocity.x;
            param1.y += additionalWinVelocity.y;
         }
         _body.velocity.setxy(param1.x,param1.y);
      }
      
      protected function gotoJump() : void
      {
      }
      
      public function attack(param1:int = 41) : void
      {
         if(_isAttack)
         {
            _attackIndex = _actionState + 1;
            _lasetAttackPressedTime = BattleModelManager.getIns().getGameTimer();
            return;
         }
         if(userVo.isPk && userVo.campId != 1)
         {
            if(_attackIndex == 0)
            {
               _attackIndex = 41;
            }
            param1 = int(_attackIndex);
         }
         _isAttack = true;
         if(param1 > _maxAttak)
         {
            param1 = 41;
            _attackIndex = param1;
         }
         _actionState = param1;
         if(param1 == 41)
         {
            _attackIndex = 41;
         }
         updateAnimation();
         onAttacking();
         if(_nowAnimation)
         {
            _nowAnimation.loop = false;
         }
      }
      
      protected function runAttack() : void
      {
         if(_actionState != 46)
         {
            _isAttack = true;
            _attackIndex = 0;
            _actionState = 46;
            updateAnimation();
            _nowAnimation.loop = false;
            onAttacking();
         }
      }
      
      protected function die() : void
      {
         if(_actionState != 100)
         {
            _actionState = 100;
            updateAnimation();
            if(_nowAnimation)
            {
               _nowAnimation.loop = false;
            }
         }
      }
      
      protected function onDie() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < _AIs.length)
         {
            _AIs[_loc1_].clear();
            _loc1_++;
         }
         setVelocity(0,0);
      }
      
      protected function onAttacking() : void
      {
      }
      
      override public function updateDisplay() : void
      {
         super.updateDisplay();
         _position.x = display.x = _body.position.x;
         _position.y = display.y = _body.position.y + _body.bounds.height / 2;
         updateUserVoXY();
         display.rotation = _body.rotation * 180 / 3.141592653589793 % 360;
      }
      
      protected function updatePostion(param1:Vector2D, param2:Boolean) : void
      {
         position = _position.add(param1);
      }
      
      override protected function onUpdateAnimationAfter() : void
      {
         super.onUpdateAnimationAfter();
         updateCanManipulate();
      }
      
      protected function updateCanManipulate() : void
      {
         _canManipulate = true;
         if(_isAttack)
         {
            _canManipulate = false;
         }
         if(_actionState == 5)
         {
            _canManipulate = false;
         }
         else if(_actionState == 100)
         {
            _canManipulate = false;
         }
         if(hided)
         {
            _canManipulate = false;
         }
         if(_isManual == false)
         {
            _canManipulate = false;
         }
      }
      
      public function set canManual(param1:Boolean) : void
      {
         this._isManual = param1;
      }
      
      public function get canManipulate() : Boolean
      {
         return _canManipulate;
      }
      
      public function getCanManipulate(param1:int) : Boolean
      {
         return this._canManipulate;
      }
      
      public function get canJump() : Boolean
      {
         return _actionState == 1 || _actionState == 2 || _actionState == 3 || _actionState == 6 || this.canJump3() || _actionState == 8 || _actionState == 100;
      }
      
      public function canJump3() : Boolean
      {
         return false;
      }
      
      public function get canAttack() : Boolean
      {
         if(_buff_xi_ying || userVo.mode != 1)
         {
            return false;
         }
         return _actionState == 1 || _actionState == 2 || _actionState == 3 || _actionState == 6 || _actionState == 7 || _actionState == 8 || _actionState == 41 || _actionState == 42 || _actionState == 43 || _actionState == 44 || _actionState == 45;
      }
      
      public function get canAttack2() : Boolean
      {
         return false;
      }
      
      public function set canWuShan(param1:Boolean) : void
      {
         this._canWuShan = param1;
      }
      
      public function get canWuShan() : Boolean
      {
         return _canWuShan;
      }
      
      public function get isHurting() : Boolean
      {
         if(_actionState == 5 || _actionState == 52)
         {
            return true;
         }
         return false;
      }
      
      public function get keyboard() : KeyboradInput
      {
         return _keyboard;
      }
      
      public function get keyControl() : KeyControl
      {
         return _keyControl;
      }
      
      public function get isJump() : Boolean
      {
         return _isJump;
      }
      
      public function addRandomAI() : void
      {
      }
      
      public function addAttackAI() : void
      {
      }
      
      public function draw() : void
      {
      }
      
      public function pause() : void
      {
      }
      
      public function resume() : void
      {
      }
      
      public function getNeedGuanHuan() : Boolean
      {
         return true;
      }
      
      public function clearOldFilter() : void
      {
      }
      
      public function handKey(param1:uint, param2:int) : void
      {
         if(param2 == 1)
         {
            if(keyboard)
            {
               keyboard.handleKeyDown(param1);
            }
            if(keyControl)
            {
               keyControl.add(param1);
            }
         }
         else
         {
            if(keyboard)
            {
               keyboard.handleKeyUp(param1);
            }
            if(keyControl)
            {
               keyControl.remove(param1);
            }
            onKeyUp(param1);
         }
      }
      
      protected function onKeyUp(param1:uint) : void
      {
      }
      
      override public function handOnFloor(param1:InteractionCallback) : void
      {
         var _loc4_:Vec2 = null;
         if(param1.arbiters.length == 0)
         {
            return;
         }
         var _loc3_:Arbiter = param1.arbiters.at(0);
         if(_loc3_.collisionArbiter == null)
         {
            if(param1.arbiters.length <= 1)
            {
               return;
            }
            _loc3_ = param1.arbiters.at(1);
            if(_loc3_.collisionArbiter == null)
            {
               return;
            }
         }
         var _loc2_:Boolean = BodyUserData(_loc3_.shape1.body.userData.data).group == "ground" || BodyUserData(_loc3_.shape1.body.userData.data).group == "floor" || BodyUserData(_loc3_.shape1.body.userData.data).group == GroupType.SAND || BodyUserData(_loc3_.shape1.body.userData.data).group == GroupType.EDGE || BodyUserData(_loc3_.shape1.body.userData.data).group == GroupType.EDGE_ROLE;
         if(_loc3_.collisionArbiter.normal.y < 0 && _loc2_)
         {
            standInFloor(param1.int2.castBody,param1.int1.castBody);
            if(param1.int2.castBody.userData && param1.int2.castBody.userData.data && param1.int2.castBody.userData.data.gameObject)
            {
               try
               {
                  param1.int2.castBody.userData.data.gameObject.OnManStandIn(this);
               }
               catch(error:Error)
               {
                  SimpleTextLog.getIns().log2("OnManStandIn",error);
               }
            }
            this.OnStandInGround();
         }
         else if(_loc3_.collisionArbiter.normal.y > 0 && _loc2_ == false)
         {
            standInFloor(param1.int2.castBody,param1.int1.castBody);
         }
         else if(param1.int1.castBody.position.y <= param1.int2.castBody.position.y)
         {
         }
         if(getStandInIce())
         {
            _loc4_ = new Vec2();
            _loc4_.x = 50 * this.direction;
            updateBodyVelocity(_loc4_);
         }
         super.handOnFloor(param1);
      }
      
      protected function OnStandInGround() : void
      {
      }
      
      protected function resetFloor() : void
      {
         var _loc2_:int = 0;
         var _loc1_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _needChangeFloor.length)
         {
            _loc1_ = 0;
            while(_loc1_ < _needChangeFloor[_loc2_].shapes.length)
            {
               _needChangeFloor[_loc2_].shapes.at(_loc1_).filter.collisionMask = _needChangeFloor[_loc2_].userData.data.collisionMask;
               _loc1_++;
            }
            _loc2_++;
         }
         _needChangeFloor.length = 0;
      }
      
      protected function standInFloor(param1:Body, param2:Body) : void
      {
         resetFloor();
         _grounds.push(param1);
         if(BodyUserData(param1.userData.data).group == GroupType.SAND)
         {
            _inSand = true;
            if(BodyUserData(param1.userData.data).data == "sandR")
            {
               _additionalVelocityBySand.setxy(30,30);
            }
            else
            {
               _additionalVelocityBySand.setxy(-30,30);
            }
            onInSand(param1);
         }
         else
         {
            _inSand = false;
            _additionalVelocityBySand.setxy(0,0);
         }
         _standInBody = param1;
         if(_standInBody.velocity.length > 0 && BodyUserData(_standInBody.userData.data).entity is MoveEntity)
         {
            _moveMaxAddVelocity.setxy(Math.abs(_standInBody.velocity.x),_standInBody.velocity.y);
         }
         var _loc3_:Boolean = _onGround;
         _onGround = true;
         stopJump();
         if(!(_actionState == ActionState.GET_UP || _actionState == 5))
         {
            if(_isAttack)
            {
               if(_actionState == 8)
               {
                  toIdle();
               }
            }
            else if(_loc3_ == false)
            {
               if(_actionState == 2 || _actionState == 3)
               {
                  if(_moving == false)
                  {
                     if(_body)
                     {
                        updateBodyVelocity(new Vec2(0,_body.velocity.y));
                     }
                     toIdle();
                  }
               }
               else if(currentActionState == -1)
               {
                  byStandInFloorToIdle();
               }
               else
               {
                  toIdle();
               }
            }
         }
         if(param1.userData.data.entity is ShipEntity)
         {
            if(this.userVo.type == "role" || this.userVo.type == ManType.HORSE)
            {
               ShipEntity(param1.userData.data.entity).setUserVo(this.userVo,this._manConfigVo);
               ShipEntity(param1.userData.data.entity).stmove();
            }
         }
      }
      
      protected function byStandInFloorToIdle() : void
      {
         toIdle();
      }
      
      protected function onInSand(param1:Body) : void
      {
         var _loc3_:String = null;
         var _loc2_:Array = null;
         if(BodyUserData(param1.userData.data).group == GroupType.SAND)
         {
            if(BodyUserData(param1.userData.data).entity && BodyUserData(param1.userData.data).entity.properties.properties.hasOwnProperty("velocity"))
            {
               _loc3_ = BodyUserData(param1.userData.data).entity.properties.properties.velocity;
               _loc2_ = _loc3_.split(",");
               _additionalVelocityBySand.setxy(_loc2_[0],_loc2_[1]);
            }
         }
      }
      
      override public function handEndOnFloor(param1:InteractionCallback) : void
      {
         super.handEndOnFloor(param1);
         var _loc2_:int = _grounds.indexOf(param1.int2.castBody);
         _standOutBody = param1.int2.castBody;
         if(_standInBody == _standOutBody)
         {
            _standInBody = null;
         }
         if(_moveMaxAddVelocity)
         {
            _moveMaxAddVelocity.setxy(0,0);
         }
         if(_moving == false)
         {
            if(_body)
            {
               if(_isJump)
               {
                  updateBodyVelocity(new Vec2(0,_body.velocity.y));
               }
            }
         }
         if(_loc2_ != -1)
         {
            if(param1.int2.castBody.userData.data.entity is ShipEntity)
            {
               if(this.userVo.type == "role")
               {
                  ShipEntity(param1.int2.castBody.userData.data.entity).manOut();
               }
            }
            _grounds.splice(_loc2_,1);
            if(_grounds.length == 0)
            {
               _onGround = false;
               if(this is RoleEntity)
               {
                  if(this.userVo.type == "role" || this.userVo.type == ManType.HORSE)
                  {
                  }
               }
            }
         }
         if(BodyUserData(param1.int2.castBody.userData.data).group == GroupType.SAND)
         {
            if(BodyUserData(param1.int2.castBody.userData.data).entity && BodyUserData(param1.int2.castBody.userData.data).entity.properties.properties.hasOwnProperty("velocity"))
            {
               _inSand = false;
               if(_additionalVelocityBySand)
               {
                  _additionalVelocityBySand.setxy(0,0);
               }
            }
         }
         if(param1.int2.castBody.userData && param1.int2.castBody.userData.data && param1.int2.castBody.userData.data.gameObject)
         {
            try
            {
               param1.int2.castBody.userData.data.gameObject.OnManStandOut(this);
            }
            catch(error:Error)
            {
            }
         }
      }
      
      public function toIdle() : void
      {
         try
         {
            _position.x = display.x = _body.position.x;
            _position.y = display.y = _body.position.y + _body.bounds.height / 2;
            updateUserVoXY();
         }
         catch(error:Error)
         {
         }
         if(_isDie || deleted)
         {
            return;
         }
         idle();
         _moving = false;
         if(_additionalOtherVelocity.length == 0)
         {
            setMaterial(_staticFriction,_dynamicFriction);
         }
         else
         {
            setMaterial(0,0);
         }
         if(getType() == "pet" && !this.isRole)
         {
            if(getMoveType() == 2)
            {
               updateBodyVelocity(new Vec2());
               setVelocity(0,0);
            }
         }
      }
      
      public function screenMinX(param1:Number) : void
      {
         _minX = param1;
      }
      
      public function setUserVo(param1:UserVO, param2:ManConfigVO) : void
      {
         var _loc4_:ColorTransform = null;
         var _loc3_:Number = NaN;
         _userVo = param1;
         if(param2)
         {
            _manConfigVo = param2;
         }
         _oldUservo = _userVo;
         if(_userVo)
         {
            _userVo.removeBattleProperty();
         }
         if(this.display && param2 && param2.id == 3707 && this is SkillEntity)
         {
            _loc4_ = this.display.transform.colorTransform;
            _loc3_ = 0.1;
            _loc4_.redMultiplier = _loc3_;
            _loc4_.greenMultiplier = _loc3_;
            _loc4_.blueMultiplier = _loc3_;
            this.display.transform.colorTransform = _loc4_;
         }
      }
      
      public function setVelocity(param1:Number, param2:Number, param3:Boolean = false) : void
      {
         var _loc4_:* = 0;
         if(keyboard)
         {
            keyboard.reset();
         }
         if(keyControl)
         {
            keyControl.reset();
         }
         if(_buff_xi_ying2)
         {
            return;
         }
         if(getType() == "monster")
         {
            if(getMoveType() == 2 || getMoveType() == 4)
            {
               _velocity.setxy(param1,param2);
               _walkX_accelerationMax = Math.abs(param1);
               _walkY_accelerationMax = Math.abs(param2);
            }
            else
            {
               param2 = 0;
            }
         }
         if(getType() == "pet")
         {
            if(getMoveType() == 2 || getMoveType() == 4)
            {
               _velocity.setxy(param1,param2);
               if(!this.isRole)
               {
                  _walkX_accelerationMax = Math.abs(param1);
                  _walkY_accelerationMax = Math.abs(param2);
               }
            }
            else
            {
               param2 = 0;
            }
         }
         if(this is BoatEntity)
         {
         }
         if(isNaN(param1))
         {
            param1 = 100;
         }
         if(isNaN(param2))
         {
            param2 = 0;
         }
         if(param1 < 0)
         {
            _loc4_ = 65;
         }
         else if(param1 > 0)
         {
            _loc4_ = 68;
         }
         handKey(_loc4_,1);
         if(param3)
         {
            handKey(_loc4_,0);
            handKey(_loc4_,1);
         }
         if(param2 != 0)
         {
            if(param2 > 0)
            {
               _loc4_ = 83;
            }
            else if(param2 < 0)
            {
               _loc4_ = 87;
            }
            handKey(_loc4_,1);
         }
      }
      
      public function stopAI(param1:AIBasic, param2:Boolean = false) : void
      {
         if(keyboard)
         {
            keyboard.reset();
         }
         if(keyControl)
         {
            keyControl.reset();
         }
         if(_AI)
         {
            _AI.destroy();
         }
         if(param1 is IdleAI)
         {
            dispatchEventWith("stopIdle");
         }
         else if(param1 is WalkAI)
         {
            dispatchEventWith("stopWalk");
         }
         else if(param1 is SeekAI)
         {
            dispatchEventWith("stopSeek");
         }
         else if(param1 is AttackAI)
         {
            _isAttack = false;
            dispatchEventWith("stopAttack",param2);
         }
         else if(param1 is AwayAI)
         {
            dispatchEventWith("stopAway");
         }
         else if(param1 is WalkBackAI)
         {
            dispatchEventWith("stopWalkBack");
         }
         else if(param1 is JumpAI)
         {
            dispatchEventWith("stopJump");
         }
         else if(param1 is FollowAI)
         {
            dispatchEventWith("stopFollow");
         }
         else if(param1 is WalkInRectangleAI)
         {
            dispatchEventWith("stopWalk");
         }
         else if(param1 is FollowPathAI)
         {
            dispatchEventWith("stopFollow");
         }
         else if(param1 is OutAngleAI)
         {
            dispatchEventWith("stopWalk");
         }
         if(param1)
         {
            param1.clear();
         }
      }
      
      public function gotoPatrol() : void
      {
         removeAI();
         _AI = new WalkAI(this,0,0);
         _AIs.push(_AI);
      }
      
      public function gotoFollow() : void
      {
         removeAI();
         var _loc1_:Vector2D = this.position.clone();
         if(_parent)
         {
            _loc1_ = _parent.position.clone();
            _loc1_.x -= _parent.direction * 100;
         }
         if(_loc1_.x < _screenRange.x + 50)
         {
            _loc1_.x = _screenRange.x + 50;
         }
         else if(_loc1_.x > _screenRange.x + _screenRange.width - 50)
         {
            _loc1_.x = _screenRange.x + _screenRange.width - 50;
         }
         _AI = new FollowAI(this,_loc1_,_parent ? _parent.userVo.entitieId : -1);
         _AIs.push(_AI);
      }
      
      public function gotoFollowPath(param1:BehaviorConfigVO, param2:INode) : AIBasic
      {
         if(!this._startPost)
         {
            this._startPost = this.position.clone();
         }
         removeAI();
         var _loc3_:int = 0;
         if(param1 && param1.value2 && param1.value2.length > 0)
         {
            _loc3_ = int(param1.value2[0]);
         }
         _AI = new FollowPathAI(this,this._startPost,path,_loc3_);
         _AI.parentNode = param2;
         _AIs.push(_AI);
         return _AI;
      }
      
      private function setFollowPathAI() : void
      {
      }
      
      public function gotoWait(param1:BehaviorConfigVO, param2:INode) : AIBasic
      {
         removeAI();
         _AI = new IdleAI(this,param1);
         _AI.parentNode = param2;
         _AIs.push(_AI);
         return _AI;
      }
      
      public function gotoWalkInRect(param1:BehaviorConfigVO, param2:INode) : AIBasic
      {
         removeAI();
         var _loc4_:Rectangle = new Rectangle(param1.value[0],param1.value[1],param1.value[2],param1.value[3]);
         var _loc3_:Number = BattleModelManager.getIns().getRandom() * (Number(param1.value2[1]) - Number(param1.value2[0])) + Number(param1.value2[0]);
         _AI = new WalkInRectangleAI(this,1,_loc3_,_loc4_);
         _AI.parentNode = param2;
         _AIs.push(_AI);
         return _AI;
      }
      
      public function gotoOutByAngle(param1:BehaviorConfigVO, param2:INode) : AIBasic
      {
         removeAI();
         _AI = new OutAngleAI(this,param1);
         _AI.parentNode = param2;
         _AIs.push(_AI);
         return _AI;
      }
      
      protected function removeAI() : void
      {
         if(_AI)
         {
            _AI.clear();
         }
         _AI = null;
         if(keyboard)
         {
            keyboard.reset();
         }
         if(keyControl)
         {
            keyControl.reset();
         }
      }
      
      public function gotoSeek(param1:Entity, param2:Array, param3:int, param4:Number, param5:INode) : void
      {
         if(isDie)
         {
            return;
         }
         removeAI();
         _AI = new SeekAI(this,param1 as ManEntity,param2,param3,param4);
         _AI.parentNode = param5;
         _AIs.push(_AI);
      }
      
      public function gotoAttack(param1:int, param2:INode) : void
      {
         if(isDie)
         {
            return;
         }
         removeAI();
         _AI = new AttackAI(this,param1);
         _AI.parentNode = param2;
         _AIs.push(_AI);
         if(param1 > 70 && _actionState != param1 && !getIsSameSkillByAc(_actionState,param1))
         {
            if(_AI)
            {
               _AI.destroy();
            }
         }
      }
      
      protected function getIsSameSkillByAc(param1:int, param2:int) : Boolean
      {
         return false;
      }
      
      public function gotoSkill(param1:int, param2:INode) : void
      {
         if(isDie)
         {
            return;
         }
         removeAI();
         _AI = new AttackAI(this,param1);
         _AI.parentNode = param2;
         _AIs.push(_AI);
      }
      
      public function gotoAway(param1:PlayerEntity, param2:Array, param3:INode) : void
      {
         if(isDie)
         {
            return;
         }
         removeAI();
         _AI = new AwayAI(this,param1,param2);
         _AI.parentNode = param3;
         _AIs.push(_AI);
      }
      
      public function gotoWalkBack(param1:PlayerEntity, param2:BehaviorConfigVO, param3:INode) : void
      {
         if(isDie)
         {
            return;
         }
         removeAI();
         _AI = new WalkBackAI(param1,param2.value);
         _AI.parentNode = param3;
         _AIs.push(_AI);
      }
      
      public function gotoJumpAI(param1:INode) : void
      {
         if(isDie)
         {
            return;
         }
         removeAI();
         _AI = new JumpAI(this);
         _AI.parentNode = param1;
         _AIs.push(_AI);
      }
      
      public function toAttack(param1:int) : void
      {
         if(isDie)
         {
            return;
         }
         removeAI();
      }
      
      public function setScreen(param1:Rectangle) : void
      {
         _screenRange = param1;
      }
      
      public function get screenRange() : Rectangle
      {
         return _screenRange;
      }
      
      override public function getCanMove() : Boolean
      {
         return canManipulate;
      }
      
      override public function getAttacking() : Boolean
      {
         return _isAttack;
      }
      
      override public function setPhysicsBody(param1:Body) : void
      {
         super.setPhysicsBody(param1);
         _gravity = _body.gravMass;
      }
      
      public function backBodyGravity() : void
      {
         if(this._body && this._body.gravMass != _gravity && _gravity != 0)
         {
            this._body.gravMass = _gravity;
         }
      }
      
      public function handInWater(param1:Body) : void
      {
         var _loc11_:int = 0;
         var _loc10_:int = 0;
         var _loc8_:Array = null;
         var _loc7_:BodyUserData = null;
         var _loc3_:Class = null;
         var _loc5_:String = null;
         var _loc6_:AssetItem = null;
         var _loc9_:AnimationMovieclip = null;
         _inWater = true;
         _loc11_ = 0;
         while(_loc11_ < _needChangeFloor.length)
         {
            _loc10_ = 0;
            while(_loc10_ < _needChangeFloor[_loc11_].shapes.length)
            {
               _needChangeFloor[_loc11_].shapes.at(_loc10_).filter.collisionMask = _needChangeFloor[_loc11_].userData.data.collisionMask;
               _loc10_++;
            }
            _loc11_++;
         }
         _grounds.length = 0;
         if(getType() == "monster" && getMoveType() == 4)
         {
         }
         _waterScreenRange = new Rectangle(param1.bounds.x,param1.bounds.y,param1.bounds.width,param1.bounds.height);
         this.clear_waterScreenRange();
         var _loc4_:Boolean = true;
         var _loc2_:Boolean = false;
         try
         {
            _loc7_ = param1.userData.data;
            if(_loc7_.data.properties.hasOwnProperty("waterEff"))
            {
               _loc4_ = Boolean(_loc7_.data.properties.waterEff);
            }
            if(_loc7_.data.properties.hasOwnProperty("waterEff_whoTriggerTag"))
            {
               _loc8_ = _loc7_.data.properties.waterEff_whoTriggerTag.split(",");
            }
            if(_loc7_.data.properties.hasOwnProperty("useCurrMap_waterEff"))
            {
               _loc2_ = Boolean(_loc7_.data.properties.useCurrMap_waterEff);
            }
         }
         catch(error:Error)
         {
         }
         if(_loc4_)
         {
            _loc4_ = this.userVo.type == "role" || this.userVo.type == ManType.HORSE;
            if(_loc8_)
            {
               _loc4_ = _loc8_.indexOf(this.userVo.type) > -1;
            }
         }
         if(_loc4_)
         {
            if(!_loc2_)
            {
               _loc3_ = AssetManager.getIns().getClass("mission","waterEff");
            }
            else
            {
               _loc5_ = BattleModelManager.getIns().levelInfo.mapURL;
               _loc5_ = AssetsURL.getMapURL(_loc5_) + ".swf";
               _loc6_ = AssetManager.getIns().getAsset(_loc5_);
               _loc3_ = _loc6_.loaderInfo.applicationDomain.getDefinition("waterEff") as Class;
            }
            _loc9_ = new AnimationMovieclip(_loc3_,false);
            _loc9_.x = this.position.x;
            _loc9_.y = this.position.y;
            BattleMap.Ins.addChild1(_loc9_,false);
         }
         if(this.userVo.type == ManType.HORSE && this.getMoveType() == 2)
         {
            HorseVO(this.userVo).fatigue = HorseVO(this.userVo).fatigueMax;
         }
      }
      
      protected function clear_waterScreenRange() : void
      {
      }
      
      public function handOutWater() : void
      {
         _inWater = false;
         maxVelocity.y = _jump2HeightMaxLand;
      }
      
      override public function getMoveType() : int
      {
         return RoleConfigVO(_manConfigVo).getMoveType();
      }
      
      public function setOtherVelocity(param1:int, param2:int) : void
      {
         _additionalMaxVelocity.setxy(param1,param2);
      }
      
      public function addWalkVelocity(param1:Number, param2:Number) : void
      {
         _addWalkVelocity.x = param1;
         _addWalkVelocity.y = param2;
      }
      
      public function addRunVelocity(param1:Number, param2:Number) : void
      {
         _addRunVelocity.x = param1;
         _addRunVelocity.y = param2;
      }
      
      public function updateGravMass(param1:Number) : void
      {
         if(this.body)
         {
            this.body.gravMassScale = param1;
         }
      }
      
      public function addJumpVeloctity(param1:Number, param2:Number) : void
      {
         _addJumpVelocity.x += param1;
         _addJumpVelocity.y += param2;
      }
      
      public function getRealCD() : Boolean
      {
         return false;
      }
      
      override public function destory() : void
      {
         resetFloor();
         super.destory();
      }
      
      public function transferChildren(param1:Number, param2:Number) : void
      {
      }
      
      public function GetChildNum() : int
      {
         return 0;
      }
      
      protected function setStayInSKy(param1:Boolean) : void
      {
         _currStayInSky = param1;
      }
      
      protected function cancelStayInSKy() : void
      {
      }
      
      protected function getStayInSky() : Boolean
      {
         return false;
      }
      
      override public function clean() : void
      {
         super.clean();
         Vector2D.disposeVec2(this._velocity);
         Vector2D.disposeVec2(this.maxVelocity);
         Vector2D.disposeVec2(this._additionalVelocityBySand);
         Vector2D.disposeVec2(this._moveMaxAddVelocity);
         Vector2D.disposeVec2(this._additionalVelocity);
         Vector2D.disposeVec2(this._additionalVelocity3);
         Vector2D.disposeVec2(this._additionalOtherVelocity);
         Vector2D.disposeVec2(this._additionalMaxVelocity);
         Vector2D.disposeVec2(this.additionalWinVelocity);
      }
      
      override public function get isHatredZero() : Boolean
      {
         if(manConfigVo && manConfigVo.isHatredZero == 1)
         {
            return true;
         }
         return super.isHatredZero;
      }
      
      override public function getWRect() : Array
      {
         if(this._manConfigVo)
         {
            return this._manConfigVo.wRect;
         }
         return super.getWRect();
      }
   }
}

