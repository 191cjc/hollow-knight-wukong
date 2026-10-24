package viewers.component
{
   import com.game.engine.animation.IAnimatable;
   import com.game.engine.core.GameFrame;
   import com.game.view.component.Component;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class AnimationMovieclip extends Component implements IAnimatable
   {
      
      private var _mc:MovieClip;
      
      private var _loop:Boolean;
      
      private var speed:int;
      
      private var isGf:Boolean;
      
      public function AnimationMovieclip(param1:Class, param2:Boolean, param3:int = 0, param4:Boolean = false)
      {
         super();
         this.isGf = param4;
         this.speed = param3;
         _loop = param2;
         _mc = new param1() as MovieClip;
         _mc.cacheAsBitmap = true;
         this.mouseChildren = this.mouseEnabled = false;
         this.addChild(_mc);
         if(this.isGf)
         {
            if(GameFrame.juggler)
            {
               GameFrame.juggler.add(this);
            }
         }
         else if(!_loop)
         {
            _mc.addEventListener("enterFrame",one);
         }
      }
      
      public function get mc() : MovieClip
      {
         return _mc;
      }
      
      public function clear() : void
      {
         if(_mc)
         {
            _mc.removeEventListener("enterFrame",one);
            _mc.stop();
         }
         super.destroy();
      }
      
      private function one(param1:Event) : void
      {
         if(this.speed > 0)
         {
            _mc.gotoAndStop(_mc.currentFrame + this.speed);
         }
         if(_mc.currentFrame >= _mc.totalFrames)
         {
            _mc.stop();
            destroy();
         }
      }
      
      override public function destroy() : void
      {
         if(_mc)
         {
            _mc.removeEventListener("enterFrame",one);
            _mc.stop();
         }
         super.destroy();
         dispatchEvent(new Event("complete"));
         if(this.isGf)
         {
            if(GameFrame.juggler)
            {
               GameFrame.juggler.remove(this);
            }
         }
      }
      
      public function advanceTime(param1:Number) : void
      {
         var _loc2_:int = 0;
         if(_mc)
         {
            _loc2_ = _mc.currentFrame + 1;
            if(this.isGf)
            {
               if(_loc2_ >= _mc.totalFrames)
               {
                  _mc.stop();
                  destroy();
               }
            }
            else if(_loc2_ > _mc.totalFrames)
            {
               _loc2_ = 1;
            }
            _mc.gotoAndStop(_loc2_);
         }
      }
   }
}

