package com.game.engine.core
{
   import com.game.engine.animation.Juggler;
   import com.game.engine.utils.SimpleTextLog;
   import com.game.utils.Vector2D;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.utils.getTimer;
   import models.managers.BattleModelManager;
   import utils.Physics;
   
   public class GameFrame
   {
      
      public static var stage:Stage;
      
      public static var juggler:Juggler;
      
      public static var _ins:GameFrame;
      
      private static const FPS:Number = 30;
      
      public static var time:Number = 0;
      
      public static var gameTime:Number = 0;
      
      public static var battleModelManager:BattleModelManager;
      
      public static var current:GameFrame;
      
      private var _lastTime:int;
      
      private var _elapsedTime:Number = 0;
      
      private var _onEnterFrameFunc:Function;
      
      private var _deleted:Boolean;
      
      public var name:String;
      
      private var _lastDateTime:Number;
      
      private var _isPause:Boolean;
      
      private var _tempSpeed:int;
      
      private var _lastDate:Date;
      
      private var _canSpeed:Boolean = true;
      
      private var _isManual:Boolean;
      
      private var _removed:Boolean;
      
      public function GameFrame(param1:Stage, param2:Function = null)
      {
         super();
         _onEnterFrameFunc = param2;
         GameFrame.stage = param1;
         juggler = new Juggler();
         GameFrame._ins = this;
         name = "g" + Math.random();
         GameFrame.current = this;
      }
      
      public static function getCurrentFrame() : GameFrame
      {
         return _ins;
      }
      
      public static function getGameTimer() : Number
      {
         return getTimer();
      }
      
      public static function getRealBodyVelocityRatio() : Number
      {
         return 0.03333333333333333 / Physics.Ins.deltaTime;
      }
      
      public static function frameToBodyVelocity(param1:Number, param2:Number) : Vector2D
      {
         var _loc3_:Vector2D = Vector2D.weak(param1,param2);
         _loc3_.x = _loc3_.x * 30 * GameFrame.getRealBodyVelocityRatio();
         _loc3_.y = _loc3_.y * 30 * GameFrame.getRealBodyVelocityRatio();
         return _loc3_;
      }
      
      public static function normalToBodyVelocity(param1:Number, param2:Number) : Vector2D
      {
         var _loc3_:Vector2D = Vector2D.weak(param1,param2);
         _loc3_.x *= GameFrame.getRealBodyVelocityRatio();
         _loc3_.y *= GameFrame.getRealBodyVelocityRatio();
         return _loc3_;
      }
      
      public static function bodyToNormalVeloctiy(param1:Number, param2:Number) : Vector2D
      {
         var _loc3_:Vector2D = Vector2D.weak(param1,param2);
         _loc3_.x /= GameFrame.getRealBodyVelocityRatio();
         _loc3_.y /= GameFrame.getRealBodyVelocityRatio();
         return _loc3_;
      }
      
      public function get isPause() : Boolean
      {
         return _isPause;
      }
      
      public function get isPaused() : Boolean
      {
         return _isPause;
      }
      
      public function set canSpeed(param1:Boolean) : void
      {
         this._canSpeed = param1;
      }
      
      public function start() : void
      {
         stage.addEventListener("enterFrame",onEnterFrame);
         _lastTime = getTimer();
         var _loc1_:Date = new Date();
         _lastDateTime = _loc1_.time;
         SimpleTextLog.getIns().log("start" + name);
      }
      
      public function stop() : void
      {
         stage.removeEventListener("enterFrame",onEnterFrame);
         SimpleTextLog.getIns().log("stop" + name);
      }
      
      public function remove() : void
      {
         SimpleTextLog.getIns().log("remove" + name);
         _removed = true;
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         var _loc2_:Date = null;
         var _loc3_:Number = NaN;
         if(_deleted)
         {
            return;
         }
         if(!_canSpeed)
         {
            _loc2_ = new Date();
            if(!_lastDate)
            {
               _lastDate = _loc2_;
            }
            _loc3_ = _loc2_.time - _lastDate.time;
            _lastDate = _loc2_;
            _elapsedTime += _loc3_;
            if(_elapsedTime < 33)
            {
               return;
            }
            _elapsedTime -= 33.3;
            if(_elapsedTime > 130)
            {
               while(_elapsedTime > 130)
               {
                  this.__enterFrame(33);
                  _elapsedTime -= 33.3;
               }
            }
         }
         this.__enterFrame(33);
         var _loc4_:int = this._tempSpeed;
         while(_loc4_ > 0)
         {
            _loc4_--;
            this.__enterFrame(33);
         }
      }
      
      private function __enterFrame(param1:Number) : void
      {
         if(_removed)
         {
            return;
         }
         if(juggler)
         {
            juggler.advanceTime(param1);
         }
         if(_onEnterFrameFunc != null)
         {
            _onEnterFrameFunc.call(null,param1);
         }
         time += param1;
         gameTime += 33.33;
      }
      
      public function SetFrameRate(param1:int) : void
      {
         this._tempSpeed = param1;
      }
      
      public function destroy() : void
      {
         _deleted = true;
         stop();
         juggler.destroy();
         _onEnterFrameFunc = null;
         juggler = null;
         GameFrame._ins = null;
         _lastDate = null;
      }
      
      public function pause() : void
      {
         stop();
         _isPause = true;
         _lastDate = null;
      }
      
      public function resume() : void
      {
         if(!_isManual)
         {
            stage.addEventListener("enterFrame",onEnterFrame);
         }
         SimpleTextLog.getIns().log("resume" + name);
         _isPause = false;
      }
      
      public function nextFrameByManual() : void
      {
         onEnterFrame(null);
      }
      
      public function Manual() : void
      {
         this.__enterFrame(33);
      }
      
      public function setManual() : void
      {
         stage.removeEventListener("enterFrame",onEnterFrame);
         _lastTime = getTimer();
         _lastDate = new Date();
         this._isManual = true;
      }
   }
}

