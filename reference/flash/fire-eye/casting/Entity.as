package viewers.entitys
{
   import com.game.engine.animation.IAnimatable;
   import com.game.engine.character.ActionState;
   import com.game.engine.core.GameFrame;
   import com.game.engine.display.BitmapMovieClip;
   import com.game.engine.display.BitmapSprite;
   import com.game.engine.textures.Texture;
   import com.game.engine.tile.model.ObjectVO;
   import com.game.engine.utils.SimpleTextLog;
   import com.game.net.AssetItem;
   import com.game.net.AssetManager;
   import com.game.net.BundleLoader;
   import com.game.utils.Vector2D;
   import dragonBones.Armature;
   import dragonBones.events.FrameEvent;
   import dragonBones.factories.NativeFactory;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.ColorTransform;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Dictionary;
   import models.GameData;
   import models.managers.DragonResourceManager;
   import models.managers.ManResourceManager;
   import models.managers.ResourceManager;
   import models.managers.UserModelManager;
   import models.vo.BodyUserData;
   import models.vo.DropVO;
   import models.vo.ManConfigVO;
   import models.vo.ResourceVO;
   import models.vo.SkillConfigVO;
   import models.vo.UserPropertyVo;
   import models.vo.UserVO;
   import modules.skywars.BLM3Entity;
   import modules.skywars.NeZha3Entity;
   import modules.skywars.WK3Entity;
   import modules.skywars.Ytu3Entity;
   import nape.callbacks.InteractionCallback;
   import nape.dynamics.Arbiter;
   import nape.geom.AABB;
   import nape.geom.Vec2;
   import nape.phys.Body;
   import nape.phys.Material;
   import nape.space.Space;
   import utils.Debug;
   import utils.Physics;
   import viewers.component.WearComponent;
   import viewers.entitys.man.NpcEntity;
   import viewers.entitys.man.PlayerEntity;
   import viewers.entitys.man.RoleEntity;
   import viewers.entitys.weapons.MagicWeaponEntity;
   import viewers.entitys.weapons.jianyis.MagicWeaponEntity2Yi;
   
   public class Entity extends EventDispatcher implements IEntity, IAnimatable
   {
      
      public static var _ID:int = 0;
      
      public var notYutuSkill4:Boolean;
      
      private var _Enabled:Boolean = true;
      
      protected var _deleted:Boolean;
      
      protected var _position:Vector2D;
      
      protected var _actionState:int;
      
      protected var _direction:int = 1;
      
      protected var _isDie:Boolean;
      
      protected var _assetDict:Dictionary;
      
      protected var _body:Body;
      
      protected var _material:Material;
      
      protected var _display:Sprite;
      
      protected var _nowAnimation:BitmapSprite;
      
      private var _name:String;
      
      protected var _userVo:UserVO;
      
      public var Id:Number = ++_ID;
      
      public var properties:ObjectVO;
      
      protected var _normalUrl:String;
      
      protected var _txtName:TextField;
      
      protected var _invert:Boolean = false;
      
      private var _layerIndex:int = 10;
      
      protected var _oldUservo:UserVO;
      
      private var _entitieId:Number;
      
      protected var _parent:Entity;
      
      protected var _isHide:Boolean;
      
      protected var _armature:Armature;
      
      protected var resourceVo:ResourceVO;
      
      private var _canCheck:Boolean = false;
      
      private var _active:Boolean = true;
      
      private var _bodySpace:Space;
      
      public var wearComponent:WearComponent;
      
      private var _fixedDirection:int = 0;
      
      private var _skillArmatures:Object = {};
      
      protected var _label:TextField;
      
      private var _enterEdgeWalkBack:int;
      
      protected var _iceValue:int;
      
      private var _iceCd:Number = 0;
      
      public function Entity()
      {
         super();
         initialization();
      }
      
      public function get iceCd() : Number
      {
         return _iceCd;
      }
      
      public function set iceCd(param1:Number) : void
      {
         _iceCd = param1;
      }
      
      public function get enterEdgeWalkBack() : int
      {
         return _enterEdgeWalkBack;
      }
      
      public function get armature() : Armature
      {
         return this._armature;
      }
      
      public function get active() : Boolean
      {
         return _active;
      }
      
      public function set active(param1:Boolean) : void
      {
         _active = param1;
         if(this._body && !_active)
         {
            this._bodySpace = this.body.space;
            this._body.space = null;
         }
         else if(this._body && _active && this._bodySpace)
         {
            this._body.space = this._bodySpace;
         }
         this.display.visible = _active;
      }
      
      public function get canCheck() : Boolean
      {
         return _canCheck;
      }
      
      public function set canCheck(param1:Boolean) : void
      {
         _canCheck = param1;
      }
      
      public function get isHide() : Boolean
      {
         return _isHide;
      }
      
      public function set isHide(param1:Boolean) : void
      {
         _isHide = param1;
      }
      
      public function get Enabled() : Boolean
      {
         return _Enabled;
      }
      
      public function set Enabled(param1:Boolean) : void
      {
         _Enabled = param1;
      }
      
      public function get entitieId() : Number
      {
         return _oldUservo.entitieId;
      }
      
      public function get layerIndex() : int
      {
         return _layerIndex;
      }
      
      public function get body() : Body
      {
         return _body;
      }
      
      public function get assetDict() : Dictionary
      {
         return _assetDict;
      }
      
      public function get nowAnimation() : BitmapSprite
      {
         return _nowAnimation;
      }
      
      public function get currentActionState() : int
      {
         return _actionState;
      }
      
      public function get userVo() : UserVO
      {
         return _userVo;
      }
      
      public function get name() : String
      {
         return _name;
      }
      
      public function set name(param1:String) : void
      {
         _name = param1;
      }
      
      public function get direction() : int
      {
         return _direction;
      }
      
      public function get display() : Sprite
      {
         return _display;
      }
      
      public function get fixedDirection() : int
      {
         return _fixedDirection;
      }
      
      public function set fixedDirection(param1:int) : void
      {
         _fixedDirection = param1;
      }
      
      public function initialization() : void
      {
         _display = new Sprite();
         var _loc3_:Sprite = new Sprite();
         _display.addChild(_loc3_);
         var _loc1_:Sprite = new Sprite();
         _display.addChild(_loc1_);
         var _loc2_:Sprite = new Sprite();
         _display.addChild(_loc2_);
         _loc2_.mouseChildren = _loc2_.mouseEnabled = false;
         _loc2_.cacheAsBitmap = true;
         _display.mouseEnabled = _display.mouseChildren = false;
         _display.cacheAsBitmap = true;
      }
      
      public function getDisplayLayer(param1:int) : Sprite
      {
         return _display.getChildAt(param1) as Sprite;
      }
      
      protected function getRes() : void
      {
         var _loc2_:ManConfigVO = _userVo.configVo;
         var _loc1_:int = _loc2_.resourcesId;
         var _loc3_:ResourceVO = ResourceManager.getIns().getResourcesByID(_loc1_);
         this.resourceVo = _loc3_;
         if(_loc3_)
         {
            _normalUrl = _loc3_.getManNormalURL();
         }
      }
      
      public function buildName(param1:Number = -210, param2:String = "", param3:uint = 16777011) : void
      {
         var _loc4_:TextFormat = null;
         if(!_txtName)
         {
            _txtName = new TextField();
            _txtName.selectable = false;
            _loc4_ = new TextFormat(null,12,param3);
            _loc4_.align = "center";
            _txtName.defaultTextFormat = _loc4_;
         }
         _txtName.text = param2;
         _txtName.y = param1;
      }
      
      protected function loadNormal() : void
      {
         if(!_normalUrl)
         {
            SimpleTextLog.getIns().log2("_normalUrl=null");
            return;
         }
         SimpleTextLog.getIns().log2("AssetManager.getIns().getAsset(_normalUrl)",_normalUrl);
         if(AssetManager.getIns().getAsset(_normalUrl))
         {
            Debug.log("1");
         }
         else
         {
            Debug.log("2");
         }
         if(!checkAssetLoaded())
         {
            AssetManager.getIns().loadAsset(_normalUrl,"swf",onNormalLoadComplete);
         }
      }
      
      protected function checkAssetLoaded() : Boolean
      {
         return false;
      }
      
      protected function onNormalLoadComplete(... rest) : void
      {
         var _loc6_:String = null;
         _loc6_ = null;
         var _loc2_:Array = null;
         var _loc4_:Object = null;
         var _loc3_:BundleLoader = null;
         if(this.deleted || isDie)
         {
            return;
         }
         if(this.resourceVo)
         {
            SimpleTextLog.getIns().log2("onNormalLoadComplete",this.resourceVo.normal,this.resourceVo.resourceType);
         }
         if(this.resourceVo && resourceVo.resourceType == 12)
         {
            _loc6_ = resourceVo.getManBattleURL();
            SimpleTextLog.getIns().log2("burl",_loc6_);
            AssetManager.getIns().loadAsset(_loc6_,"bytes",onBattlelLoadComplete);
         }
         else if(this.resourceVo && resourceVo.resourceType == 13)
         {
            _loc6_ = this.getBattleUrl();
            SimpleTextLog.getIns().log2("burl",_loc6_);
            _loc2_ = [];
            _loc2_.push(_loc6_ + ".swf");
            if(this.resourceVo.isItem)
            {
               _loc4_ = this.resourceVo.getItemBattle2URL();
            }
            else
            {
               _loc4_ = this.resourceVo.getManBattle2URL();
            }
            if(_loc4_)
            {
               for each(var _loc5_:String in _loc4_)
               {
                  _loc2_.push(_loc5_ + ".swf");
               }
            }
            _loc3_ = new BundleLoader();
            for each(var _loc7_:String in _loc2_)
            {
               _loc3_.add(_loc7_,"bytes");
            }
            _loc3_.addEventListener("loadcomplete",onLoadC);
            _loc3_.start();
         }
         else
         {
            onNormalLoadedAfter(rest[0]);
         }
      }
      
      protected function getBattleUrl() : String
      {
         if(this.resourceVo.isItem)
         {
            return this.resourceVo.getSeedURL();
         }
         return this.resourceVo.getManBattleURL();
      }
      
      protected function onLoadC(param1:Event) : void
      {
         var self:Entity;
         var event:Event = param1;
         var url:String = this.getBattleUrl();
         var bar2:Object = this.resourceVo.getManBattle2URL();
         var t:* = 1;
         if(bar2)
         {
            t += bar2.length;
         }
         self = this;
         DragonResourceManager.getIns().build13(url,function():void
         {
            t = Number(t) - 1;
            SimpleTextLog.getIns().log2("t1=",t);
            if(t == 0)
            {
               self.onFacComplete(null);
            }
         });
         if(bar2)
         {
            for each(url in bar2)
            {
               DragonResourceManager.getIns().build13(url,function():void
               {
                  t = Number(t) - 1;
                  SimpleTextLog.getIns().log2("t2=",t);
                  if(t == 0)
                  {
                     self.onFacComplete(null);
                  }
               });
            }
         }
      }
      
      private function onBattlelLoadComplete(... rest) : void
      {
         SimpleTextLog.getIns().log2("onBattlelLoadComplete");
         var _loc2_:AssetItem = rest[0];
         var _loc3_:Boolean = DragonResourceManager.getIns().getFactoryReady(_loc2_.url);
         SimpleTextLog.getIns().log2("ar==",_loc3_);
         if(!_loc3_)
         {
            DragonResourceManager.getIns().buildRes(_loc2_.url,_loc2_.data,this.onFacComplete);
         }
         else
         {
            this.onFacComplete(null);
         }
      }
      
      private function onFacComplete(param1:Event = null) : void
      {
         var _loc3_:String = this.getBattleUrl();
         var _loc2_:Boolean = DragonResourceManager.getIns().getFactoryReady(_loc3_);
         if(_loc2_)
         {
            onNormalLoadedAfter(AssetManager.getIns().getAsset(_normalUrl));
         }
      }
      
      protected function onNormalLoadedAfter(param1:AssetItem) : void
      {
         if(this.deleted || isDie)
         {
            return;
         }
         if(!userVo)
         {
            return;
         }
         ManResourceManager.getIns().buildResourceByMan(userVo.charID,param1,true);
         if(getType() == "role")
         {
            setAssets(ManResourceManager.getIns().getResourceByRoleId(userVo.userId,userVo.charID));
         }
         else
         {
            setAssets(ManResourceManager.getIns().getResourceByManId(userVo.charID));
         }
      }
      
      public function setAssets(param1:Dictionary) : void
      {
         var _loc4_:String = null;
         var _loc3_:Armature = null;
         var _loc2_:Object = null;
         this._assetDict = param1;
         if(this._assetDict == null)
         {
            getRes();
            loadNormal();
         }
         else
         {
            if((this is RoleEntity || this is MagicWeaponEntity || this is NpcEntity || this is MagicWeaponEntity2Yi) && this.assetDict && this.assetDict["armature"])
            {
               _loc4_ = this.assetDict["armature"];
               _loc3_ = DragonResourceManager.getIns().getArmature(_loc4_);
               this._armature = _loc3_;
               if(UserModelManager.getIns().isRole(this.userVo.charID))
               {
                  ManResourceManager.getIns().wear(_loc3_,this.userVo.equipments,this.userVo,this);
               }
            }
            onNormalTextureReady();
            if(this.userVo && UserModelManager.getIns().isRole(this.userVo.charID))
            {
               this.updateEquipEffect();
            }
         }
         if(this._armature)
         {
            this._armature.addEventListener("animationFrameEvent",this.onFrameEvent);
         }
         if(this.userVo && this.userVo.configVo && this.userVo.configVo.param)
         {
            if(!this.userVo.configVo.param2)
            {
               this.userVo.configVo.param2 = JSON.parse(this.userVo.configVo.param);
            }
            _loc2_ = this.userVo.configVo.param2;
            if(_loc2_ && _loc2_.colorTransfor)
            {
               this._display.transform.colorTransform = new ColorTransform(_loc2_.colorTransfor,_loc2_.colorTransfor,_loc2_.colorTransfor);
            }
            if(_loc2_ && _loc2_.colorMatrix)
            {
               this._display.filters = [new ColorMatrixFilter(_loc2_.colorMatrix)];
            }
            if(_loc2_ && _loc2_.hasOwnProperty("propertyVo"))
            {
               if(!this.userVo.propertyVo)
               {
                  this.userVo.propertyVo = new UserPropertyVo(_loc2_,this.userVo);
               }
            }
         }
      }
      
      public function updateEquipEffect() : void
      {
      }
      
      public function setPhysicsBody(param1:Body) : void
      {
         var _loc2_:BodyUserData = null;
         if(_body && _body.space)
         {
            _body.space.bodies.remove(_body);
         }
         _body = param1;
         _material = param1.shapes.at(0).material;
         if(!_body.userData.data)
         {
            _loc2_ = new BodyUserData();
            _body.userData.data = _loc2_;
         }
         _body.userData.data.entity = this;
         BodyUserData(_body.userData.data).collisionMask = param1.shapes.at(0).filter.collisionMask;
      }
      
      public function Todie() : void
      {
      }
      
      public function setMaterial(param1:Number, param2:Number, param3:Number = -1) : void
      {
         var _loc4_:int = 0;
         if(!_body)
         {
            return;
         }
         _loc4_ = 0;
         while(_loc4_ < _body.shapes.length)
         {
            _body.shapes.at(_loc4_).material.staticFriction = param1;
            _body.shapes.at(_loc4_).material.dynamicFriction = param2;
            if(param3 != -1)
            {
               _body.shapes.at(_loc4_).material.density = param3;
            }
            _loc4_++;
         }
      }
      
      protected function onNormalTextureReady() : void
      {
      }
      
      protected function updateAnimation(param1:int = 30) : void
      {
         var _loc3_:BitmapMovieClip = null;
         if(deleted || !GameFrame.juggler)
         {
            return;
         }
         var _loc4_:int = _actionState;
         if(_nowAnimation)
         {
            _nowAnimation.destroy();
            _nowAnimation = null;
         }
         var _loc2_:Vector.<Texture> = getTextureByActionState(_actionState);
         _nowAnimation = new BitmapSprite(_loc2_,param1);
         _loc2_ = getEffectTextureByActionState(_actionState);
         if(_loc2_)
         {
            _loc3_ = new BitmapMovieClip(_loc2_,param1);
            _nowAnimation.add(_loc3_);
            if(_invert)
            {
               _loc3_ = new BitmapMovieClip(_loc2_,param1);
               _nowAnimation.add(_loc3_);
               _loc3_.blendMode = "invert";
            }
         }
         onUpdateAnimationBefore();
         Sprite(this._display.getChildAt(0)).addChild(_nowAnimation);
         if(GameFrame.juggler)
         {
            GameFrame.juggler.add(_nowAnimation);
         }
         _nowAnimation.scaleX = _direction;
         if((this is RoleEntity || this is MagicWeaponEntity || this is NpcEntity) && this.assetDict && this.assetDict["armature"])
         {
            this._armature.animation.stop();
            this._armature.animation.gotoAndPlay(getTextureActionName(_actionState));
            this._armature.animation.timeScale = param1 / 30;
            _nowAnimation.addChildAt(this._armature.display as DisplayObject,0);
            _nowAnimation.addArmature(this._armature);
         }
         onUpdateAnimationAfter();
         this.onUpdateAnimationAfter2(param1);
      }
      
      protected function GotoPlay(param1:String) : void
      {
         var _loc3_:BitmapMovieClip = null;
         if(deleted || !GameFrame.juggler || !_assetDict)
         {
            return;
         }
         if(_nowAnimation)
         {
            _nowAnimation.destroy();
            _nowAnimation = null;
         }
         var _loc2_:Vector.<Texture> = _assetDict["ac"][param1];
         if(!_loc2_)
         {
            throw new Error(this.userVo.charID + ".找不到=" + param1);
         }
         _nowAnimation = new BitmapSprite(_loc2_,30);
         _loc2_ = getEffectTextureByActionState(_actionState);
         if(_loc2_)
         {
            _loc3_ = new BitmapMovieClip(_loc2_,30);
            _nowAnimation.add(_loc3_);
            if(_invert)
            {
               _loc3_ = new BitmapMovieClip(_loc2_,30);
               _nowAnimation.add(_loc3_);
               _loc3_.blendMode = "invert";
            }
         }
         onUpdateAnimationBefore();
         Sprite(this._display.getChildAt(0)).addChild(_nowAnimation);
         if(GameFrame.juggler)
         {
            GameFrame.juggler.add(_nowAnimation);
         }
         _nowAnimation.scaleX = _direction;
         if((this is NeZha3Entity || this is Ytu3Entity || this is BLM3Entity || this is WK3Entity || this is MagicWeaponEntity) && this.assetDict && this.assetDict["armature"])
         {
            this._armature.animation.stop();
            this._armature.animation.gotoAndPlay(getTextureActionName(_actionState));
            this._armature.animation.timeScale = 1;
            _nowAnimation.addChildAt(this._armature.display as DisplayObject,0);
            _nowAnimation.addArmature(this._armature);
         }
         onUpdateAnimationAfter();
      }
      
      public function changeTOAnimationByAc(param1:int) : void
      {
         var _loc3_:BitmapMovieClip = null;
         _actionState = param1;
         var _loc4_:int = _actionState;
         if(_nowAnimation)
         {
            _nowAnimation.destroy();
            _nowAnimation = null;
         }
         var _loc2_:Vector.<Texture> = getTextureByActionState(_actionState);
         _nowAnimation = new BitmapSprite(_loc2_);
         _loc2_ = getEffectTextureByActionState(_actionState);
         if(_loc2_)
         {
            _loc3_ = new BitmapMovieClip(_loc2_);
            _nowAnimation.add(_loc3_);
            if(_invert)
            {
               _loc3_ = new BitmapMovieClip(_loc2_);
               _nowAnimation.add(_loc3_);
               _loc3_.blendMode = "invert";
            }
         }
         Sprite(this._display.getChildAt(0)).addChild(_nowAnimation);
         GameFrame.juggler.add(_nowAnimation);
         _nowAnimation.scaleX = _direction;
         onUpdateAnimationAfter();
      }
      
      public function playAni(param1:int, param2:Boolean = false) : void
      {
         _actionState = param1;
         updateAnimation();
         if(_nowAnimation)
         {
            _nowAnimation.loop = param2;
         }
      }
      
      protected function onUpdateAnimationBefore() : void
      {
      }
      
      protected function onUpdateAnimationAfter() : void
      {
      }
      
      protected function onUpdateAnimationAfter2(param1:int) : void
      {
         var _loc2_:Armature = null;
         if(this.assetDict && this.assetDict["actionSkillFactory"])
         {
            _loc2_ = this.getSkillArmature(this.getSkillAramtureName());
            if(_loc2_)
            {
               _loc2_.animation.stop();
               _loc2_.animation.gotoAndPlay(this.getSkillAramtureName());
               _loc2_.animation.timeScale = param1 / 30;
               this.onSkillArmaAdd(_loc2_.display as DisplayObject);
               _nowAnimation.addChild(_loc2_.display as DisplayObject);
               _nowAnimation.addArmatures(_loc2_);
            }
         }
      }
      
      protected function onSkillArmaAdd(param1:DisplayObject) : void
      {
         var _loc2_:Armature = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(_invert)
         {
            _loc2_ = this.getSkillArmatureAlone(this.getSkillAramtureName());
            _loc2_.animation.stop();
            _loc2_.animation.gotoAndPlay(this.getSkillAramtureName());
            _nowAnimation.addChild(_loc2_.display as DisplayObject);
            _nowAnimation.addArmatures(_loc2_);
            _loc3_ = 0;
            _loc4_ = 255;
            Sprite(_loc2_.display).transform.colorTransform = new ColorTransform(_loc3_,_loc3_,_loc3_,1,_loc4_,_loc4_,_loc4_,0);
            param1.blendMode = "subtract";
         }
         else
         {
            param1.blendMode = "normal";
            param1.x = 0;
            param1.y = 0;
         }
      }
      
      protected function getSkillAramtureName() : String
      {
         return getTextureActionName(_actionState);
      }
      
      protected function getTextureByActionState(param1:int) : Vector.<Texture>
      {
         var _loc2_:* = undefined;
         _loc2_ = undefined;
         if(!_assetDict)
         {
            _loc2_ = new Vector.<Texture>();
            _loc2_.push(Texture.empty(2,2));
            return _loc2_;
         }
         var _loc4_:String = getTextureActionName(param1);
         var _loc3_:Vector.<Texture> = _assetDict["ac"][_loc4_];
         if(!_loc3_)
         {
            _loc2_ = new Vector.<Texture>();
            _loc2_.push(Texture.empty(2,2));
            return _loc2_;
         }
         return _loc3_;
      }
      
      protected function getTextureActionName(param1:int) : String
      {
         if(param1 == 3 && getIsSwitchToRun1())
         {
            return ActionState.getName(param1) + "1";
         }
         return ActionState.getName(param1);
      }
      
      protected function getEffectTextureByActionState(param1:int) : Vector.<Texture>
      {
         var _loc3_:String = ActionState.getName(param1);
         if(!_assetDict)
         {
            return null;
         }
         return _assetDict["ef"][_loc3_];
      }
      
      protected function getABTextureByActionState(param1:int) : Vector.<Texture>
      {
         var _loc3_:String = getAbTextureActionName(param1);
         var _loc4_:int = 0;
         if(_direction == -1)
         {
            _loc4_ = 1;
         }
         if(!_assetDict["ab"][_loc3_])
         {
            throw new Error(userVo.configVo.name + "找不到ab_" + _loc3_);
         }
         return _assetDict["ab"][_loc3_][_loc4_];
      }
      
      protected function getAbTextureActionName(param1:int) : String
      {
         return ActionState.getName(param1);
      }
      
      protected function getHBTextureByActionState(param1:int) : Vector.<Texture>
      {
         var _loc3_:String = ActionState.getName(param1);
         var _loc4_:int = 0;
         if(_direction == -1)
         {
            _loc4_ = 1;
         }
         if(!_assetDict || !_assetDict["hb"][_loc3_])
         {
            return null;
         }
         return _assetDict["hb"][_loc3_][_loc4_];
      }
      
      public function get isDie() : Boolean
      {
         return _isDie;
      }
      
      public function set position(param1:Vector2D) : void
      {
         _position = param1;
         updatePos();
      }
      
      private function updatePos() : void
      {
         this._display.x = _position.x;
         this._display.y = _position.y;
         updateUserVoXY();
      }
      
      protected function updateUserVoXY() : void
      {
         if(this.userVo)
         {
            this.userVo.x = _position.x;
            this.userVo.y = _position.y;
         }
      }
      
      public function get position() : Vector2D
      {
         return _position;
      }
      
      public function get bodyPosition() : Vec2
      {
         return _body.position;
      }
      
      public function get bodyAABB() : AABB
      {
         if(!_body)
         {
            return null;
         }
         return _body.bounds;
      }
      
      public function get deleted() : Boolean
      {
         return _deleted;
      }
      
      public function getSkillScope(param1:String) : Array
      {
         var _loc2_:String = null;
         try
         {
            SkillConfigVO(userVo.configVo.skills[param1]);
         }
         catch(error:Error)
         {
            _loc2_ = "getSkillScope=====" + this.toString() + "_ac=" + "_" + userVo + " isdie=" + isDie + "de=" + deleted;
            if(userVo)
            {
               _loc2_ += userVo;
               if(userVo.configVo)
               {
                  _loc2_ += "userVo.configVo=" + userVo.configVo;
               }
            }
            throw new Error(_loc2_);
         }
         if(!userVo.configVo.skills[param1])
         {
            throw new Error("找不到技能-" + param1 + "_" + this.userVo.charID);
         }
         return SkillConfigVO(userVo.configVo.skills[param1]).skillScope;
      }
      
      public function stopAllAction() : void
      {
      }
      
      public function destory() : void
      {
         if(_deleted)
         {
            return;
         }
         _deleted = true;
         if(_nowAnimation)
         {
            _nowAnimation.destroy();
            _nowAnimation = null;
         }
         _display.removeChildren();
         if(GameFrame.juggler)
         {
            GameFrame.juggler.remove(this);
         }
         if(this._armature)
         {
            this._armature.removeEventListener("animationFrameEvent",this.onFrameEvent);
         }
         if(this._display.parent && this._display.parent.contains(this._display))
         {
            this._display.filters = null;
            this._display.parent.removeChild(this._display);
         }
         if(_body && _body.space)
         {
            _body.velocity.setxy(0,0);
            _body.space.bodies.remove(_body);
            Physics.addRemoveBody(_body);
         }
         _body = null;
         if(this.userVo && this.getType() == "role")
         {
         }
         if(this is RoleEntity)
         {
            if(this._armature)
            {
               this._armature.dispose();
               this._armature = null;
            }
         }
         for each(var _loc1_:Armature in this._skillArmatures)
         {
            _loc1_.dispose();
         }
         this._skillArmatures = null;
         if(wearComponent)
         {
            wearComponent.destroy();
            wearComponent = null;
         }
         try
         {
            this.clean();
         }
         catch(error:Error)
         {
            if(false && GameData.uid == 100)
            {
               throw new Error();
            }
         }
      }
      
      public function update() : void
      {
      }
      
      public function advanceTime(param1:Number) : void
      {
      }
      
      public function handOnFloor(param1:InteractionCallback) : void
      {
      }
      
      public function handEndOnFloor(param1:InteractionCallback) : void
      {
      }
      
      public function handOnItem(param1:InteractionCallback) : void
      {
      }
      
      public function updateDisplay() : void
      {
      }
      
      public function setDirection(param1:int) : void
      {
         if(param1 == 0)
         {
            return;
         }
         if(_direction != param1)
         {
            _direction = param1;
         }
      }
      
      public function updateDirection(param1:int) : void
      {
         if(this.fixedDirection != 0)
         {
            param1 = this.fixedDirection;
         }
         if(param1 == 0)
         {
            return;
         }
         if(_direction != param1)
         {
            _direction = param1;
            if(_nowAnimation)
            {
               _nowAnimation.scaleX = param1;
            }
         }
      }
      
      public function setAttackedTotalNum(param1:String, param2:int, param3:int) : void
      {
      }
      
      public function setParent(param1:Entity) : void
      {
         _parent = param1;
      }
      
      public function getParent() : Entity
      {
         return this._parent;
      }
      
      public function addSon(param1:Entity) : void
      {
      }
      
      public function getNeedBody() : Boolean
      {
         return true;
      }
      
      public function createBodyAtInit() : Boolean
      {
         return true;
      }
      
      public function setVisible(param1:Boolean) : void
      {
         this.display.visible = param1;
      }
      
      public function getCanMove() : Boolean
      {
         return true;
      }
      
      public function getAttacking() : Boolean
      {
         return false;
      }
      
      public function getType() : String
      {
         return null;
      }
      
      public function getMoveType() : int
      {
         return -1;
      }
      
      public function endMove() : void
      {
      }
      
      public function setLayerIndex(param1:int) : void
      {
         _layerIndex = param1;
      }
      
      public function get drovo() : DropVO
      {
         return null;
      }
      
      public function trigger(param1:Entity) : void
      {
      }
      
      public function outTrigger(param1:Entity) : void
      {
      }
      
      public function changNight(param1:Boolean) : void
      {
      }
      
      public function canDeadByEdge() : Boolean
      {
         if(this.userVo)
         {
            if(this.isDie)
            {
               return false;
            }
         }
         return true;
      }
      
      public function Enter(param1:Boolean) : Boolean
      {
         return false;
      }
      
      public function handCollideEdge() : void
      {
      }
      
      public function handCollideEndEdge() : void
      {
      }
      
      public function handAnyCollided(param1:BodyUserData, param2:Arbiter = null) : void
      {
      }
      
      public function handAnyCollidedEnd(param1:BodyUserData, param2:Arbiter = null) : void
      {
      }
      
      public function ChangeByTriggerAfter(param1:String) : void
      {
      }
      
      public function AddSkill(param1:int) : void
      {
      }
      
      protected function RemoveSkill(param1:int) : void
      {
      }
      
      public function hasBuff(param1:int) : Boolean
      {
         return false;
      }
      
      public function SetEnabled(param1:Boolean) : void
      {
         Enabled = param1;
      }
      
      public function getNowAnimationcurrentFrame() : int
      {
         return _nowAnimation.currentFrame;
      }
      
      public function CanSkill() : Boolean
      {
         return true;
      }
      
      public function get isHatredZero() : Boolean
      {
         return false;
      }
      
      public function getSkillArmature(param1:String) : Armature
      {
         var _loc4_:NativeFactory = null;
         var _loc2_:Number = NaN;
         var _loc3_:String = null;
         var _loc5_:Armature = null;
         var _loc6_:Object = this.assetDict["actionSkillFactory"][param1];
         if(!_loc6_)
         {
            return null;
         }
         if(!this._skillArmatures[param1])
         {
            _loc4_ = _loc6_.fac;
            _loc2_ = Number(_loc6_.scale);
            if(_loc4_)
            {
               _loc3_ = param1;
               _loc5_ = _loc4_.buildArmature(_loc3_);
               _loc5_.display.scaleX = _loc5_.display.scaleY = 1 / _loc2_;
               this._skillArmatures[param1] = _loc5_;
            }
         }
         return this._skillArmatures[param1];
      }
      
      public function getSkillArmatureAlone(param1:String) : Armature
      {
         var _loc3_:String = null;
         var _loc5_:Armature = null;
         var _loc6_:Object = this.assetDict["actionSkillFactory"][param1];
         if(!_loc6_)
         {
            return null;
         }
         var _loc4_:NativeFactory = _loc6_.fac;
         var _loc2_:Number = Number(_loc6_.scale);
         if(_loc4_)
         {
            _loc3_ = param1;
            _loc5_ = _loc4_.buildArmature(_loc3_);
            _loc5_.display.scaleX = _loc5_.display.scaleY = 1 / _loc2_;
         }
         return _loc5_;
      }
      
      protected function onFrameEvent(param1:FrameEvent) : void
      {
         SimpleTextLog.getIns().log2("onFrameEvent=",param1.frameLabel);
      }
      
      public function reduceHuDunHp(param1:Number) : Array
      {
         return [param1,0];
      }
      
      public function afterBackBlashreduceHuDunHp(param1:Number) : Array
      {
         return [param1,0];
      }
      
      public function getAttackedAddBuffs() : Array
      {
         return null;
      }
      
      protected function getIsSwitchToRun1() : Boolean
      {
         return false;
      }
      
      protected function addHurtEffect2(param1:Armature, param2:int = -60) : void
      {
      }
      
      public function getHurtEffect() : Armature
      {
         return null;
      }
      
      public function clean() : void
      {
      }
      
      public function getCollideWall2(param1:BodyUserData) : Boolean
      {
         return false;
      }
      
      public function OnUpdateHpBy(param1:UserVO) : void
      {
      }
      
      public function handCollideEdgeWalkBack(param1:int) : void
      {
         _enterEdgeWalkBack = param1;
      }
      
      public function handCollideEndEdgeWalkBack() : void
      {
         _enterEdgeWalkBack = 0;
      }
      
      public function setEnterEdgeWalkBack(param1:int) : void
      {
         _enterEdgeWalkBack = param1;
      }
      
      public function getWRect() : Array
      {
         return null;
      }
      
      public function OnUpdateHPBefore(param1:Number) : Number
      {
         return param1;
      }
      
      public function AddIceValue(param1:int) : int
      {
         if(GameFrame.time - _iceCd < 0)
         {
            return -1;
         }
         _iceValue += param1;
         if(_iceValue <= 0)
         {
            _iceValue = 0;
         }
         return param1;
      }
      
      public function GetIceValue() : int
      {
         return _iceValue;
      }
      
      public function updateHP(param1:UserVO, param2:Number) : Number
      {
         return param2;
      }
      
      public function showDamageBySoul(param1:Number, param2:UserVO, param3:UserVO, param4:SkillConfigVO, param5:PlayerEntity) : void
      {
      }
   }
}

