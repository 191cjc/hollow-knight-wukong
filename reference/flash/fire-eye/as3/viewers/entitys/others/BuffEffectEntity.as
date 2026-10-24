package viewers.entitys.others
{
   import com.game.engine.animation.IAnimatable;
   import com.game.net.AssetItem;
   import com.game.net.AssetManager;
   import com.game.view.component.Component;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import models.managers.ResourceManager;
   import models.vo.BuffConfigVO;
   import models.vo.BuffVO;
   import models.vo.ResourceVO;
   import viewers.component.AnimationMovieclip;
   import viewers.entitys.man.PlayerEntity;
   
   public class BuffEffectEntity extends Component implements IAnimatable
   {
      
      public static const DESTROY:String = "destroy";
      
      public static var _pools:Object = {};
      
      protected var _target:PlayerEntity;
      
      protected var _effMc:AnimationMovieclip;
      
      private var _buffvo:BuffVO;
      
      private var isIcon:Boolean;
      
      private var currFrame:int = 1;
      
      private var _display:Sprite;
      
      public function BuffEffectEntity(param1:BuffVO, param2:Boolean = false)
      {
         super();
         this._display = new Sprite();
         addChild(this._display);
         this.isIcon = param2;
         _buffvo = param1;
         this.mouseChildren = this.mouseEnabled = false;
         if(_buffvo)
         {
            loadAss();
         }
      }
      
      public static function push(param1:BuffConfigVO, param2:BuffEffectEntity) : void
      {
         if(!BuffEffectEntity._pools[param1.id])
         {
            BuffEffectEntity._pools[param1.id] = [];
         }
         BuffEffectEntity._pools[param1.id].push(param2);
      }
      
      public static function shift(param1:BuffVO) : BuffEffectEntity
      {
         var _loc3_:* = null;
         var _loc2_:Array = BuffEffectEntity._pools[param1.config.id];
         if(_loc2_ && _loc2_.length > 0)
         {
            return _loc2_.shift();
         }
         return new BuffEffectEntity(param1);
      }
      
      public function get buffvo() : BuffVO
      {
         return _buffvo;
      }
      
      public function Init(param1:BuffVO) : void
      {
         this._buffvo = param1;
         _isDeleted = false;
      }
      
      public function getDir() : int
      {
         return this._buffvo.config.effectDirection;
      }
      
      private function loadAss() : void
      {
         var _loc4_:String = null;
         var _loc3_:ResourceVO = null;
         var _loc1_:int = _buffvo.config.resourcesId;
         var _loc2_:AssetManager = AssetManager.getIns();
         if(isIcon == false)
         {
            _loc3_ = ResourceManager.getIns().getResourcesByID(_loc1_);
            if(!_loc3_)
            {
               return;
            }
            _loc4_ = _loc3_.getBuffBattleUrl();
            if(_loc4_ != "" && _loc3_.battle != null)
            {
               _loc4_ = _loc3_.getBuffBattleUrl();
               _loc2_.loadAsset(_loc4_,"swf",onBuffEffectLoadComplete);
            }
         }
      }
      
      public function get ID() : int
      {
         return _buffvo.id;
      }
      
      protected function onIconLoadComplete(... rest) : void
      {
      }
      
      protected function onBuffEffectLoadComplete(... rest) : void
      {
         var _loc3_:Class = null;
         var _loc4_:AnimationMovieclip = null;
         var _loc6_:AssetItem = rest[0];
         var _loc2_:Class = _loc6_.loaderInfo.applicationDomain.getDefinition("ef") as Class;
         var _loc5_:Boolean = true;
         if(_buffvo.config.interval == 0 && _buffvo.config.time == 0)
         {
            _loc5_ = false;
         }
         _effMc = new AnimationMovieclip(_loc2_,_loc5_);
         this._display.addChild(_effMc);
         if(_buffvo.config.interval == 0 && _buffvo.config.time == 0)
         {
            _effMc.addEventListener("complete",onC);
         }
         if(_effMc.mc && _effMc.mc.currentFrame != currFrame)
         {
            _effMc.mc.gotoAndStop(currFrame);
         }
         try
         {
            _loc3_ = _loc6_.loaderInfo.applicationDomain.getDefinition("ef0") as Class;
            _loc5_ = false;
            _loc4_ = new AnimationMovieclip(_loc3_,_loc5_);
            this._display.addChild(_loc4_);
         }
         catch(error:Error)
         {
         }
      }
      
      public function GotoAndStop(param1:int) : void
      {
         currFrame = param1;
         if(_effMc)
         {
            _effMc.mc.gotoAndStop(param1);
         }
      }
      
      public function GotoAndPlay(param1:int) : void
      {
         currFrame = param1;
         if(_effMc)
         {
            _effMc.mc.gotoAndPlay(param1);
         }
      }
      
      protected function onC(param1:Event) : void
      {
         _effMc.removeEventListener("complete",onC);
         destroy();
      }
      
      override public function destroy() : void
      {
         var _loc1_:* = undefined;
         if(!_buffvo.config.pool)
         {
            if(_effMc)
            {
               _effMc.destroy();
               _effMc = null;
            }
            if(this._display)
            {
               while(this._display.numChildren > 0)
               {
                  _loc1_ = this._display.removeChildAt(0);
                  if(_loc1_ is MovieClip)
                  {
                     MovieClip(_loc1_).stop();
                  }
               }
            }
            super.destroy();
         }
         else if(!this.isIcon)
         {
            BuffEffectEntity.push(this._buffvo.config,this);
            if(this.parent && this.parent.contains(this))
            {
               this.parent.removeChild(this);
            }
            _isDeleted = true;
         }
      }
      
      public function get isFront() : Boolean
      {
         return false;
      }
      
      public function advanceTime(param1:Number) : void
      {
      }
      
      public function change() : void
      {
         if(_effMc)
         {
            _effMc.destroy();
            _effMc = null;
         }
         loadAss();
      }
      
      public function setScale(param1:Number) : void
      {
         this._display.scaleX = param1;
         this._display.scaleY = param1;
      }
   }
}

