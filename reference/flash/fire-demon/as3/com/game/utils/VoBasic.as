package com.game.utils
{
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   
   public class VoBasic
   {
      
      public static var ClassDescribes:Dictionary = new Dictionary();
      
      private var thisOb:Object;
      
      private var _className:String;
      
      public function VoBasic()
      {
         super();
         _className = getQualifiedClassName(this);
         if(ClassDescribes[_className])
         {
            thisOb = ClassDescribes[_className];
         }
         else
         {
            thisOb = DescribeClass.describe_flash(this);
            ClassDescribes[_className] = thisOb;
         }
      }
      
      public function updateFromObject(param1:Object) : void
      {
         for(var _loc2_:String in param1)
         {
            try
            {
               this[_loc2_] = param1[_loc2_];
            }
            catch(error:Error)
            {
            }
         }
      }
      
      public function buildFromObject(param1:Object) : void
      {
         var _loc3_:String = null;
         var _loc4_:Array = null;
         for(var _loc2_:String in thisOb)
         {
            if(param1.hasOwnProperty(_loc2_) != false)
            {
               _loc3_ = param1[_loc2_];
               if(_loc3_)
               {
                  _loc4_ = _loc3_.split(",");
                  if(param1[_loc2_] == "Array")
                  {
                     this[_loc2_] = _loc4_;
                  }
                  else if(param1[_loc2_] == "int")
                  {
                     this[_loc2_] = int(_loc3_);
                  }
                  else if(param1[_loc2_] != "flash.utils::Dictionary")
                  {
                     try
                     {
                        this[_loc2_] = param1[_loc2_];
                     }
                     catch(error:Error)
                     {
                     }
                     continue;
                  }
               }
            }
         }
      }
      
      public function buildFormXMLAttr(param1:XML) : void
      {
         thisOb = DescribeClass.describe_flash(this);
         for(var _loc2_:String in thisOb)
         {
            try
            {
               this[_loc2_] = param1[_loc2_];
            }
            catch(err:Error)
            {
            }
         }
      }
      
      public function buildFormXML(param1:XML) : void
      {
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         if(param1 == null)
         {
            return;
         }
         for(var _loc2_:String in thisOb)
         {
            _loc3_ = param1[_loc2_].text();
            if(_loc3_)
            {
               _loc4_ = _loc3_.split(",");
               if(thisOb[_loc2_] == "Array")
               {
                  this[_loc2_] = _loc4_;
               }
               else if(thisOb[_loc2_] == "int")
               {
                  this[_loc2_] = int(_loc3_);
               }
               else if(thisOb[_loc2_] == "flash.geom::Point")
               {
                  this[_loc2_] = new Point(_loc4_[0],_loc4_[1]);
               }
               else if(thisOb[_loc2_] == "__AS3__.vec::Vector.<int>")
               {
                  this[_loc2_] = new Vector.<int>();
                  _loc5_ = 0;
                  while(_loc5_ < _loc4_.length)
                  {
                     this[_loc2_].push(_loc4_[_loc5_]);
                     _loc5_++;
                  }
               }
               else
               {
                  this[_loc2_] = param1[_loc2_].text();
               }
               if(typeof this[_loc2_] == "boolean")
               {
                  if(param1[_loc2_].text() == "true" || Number(param1[_loc2_].text()) > 0)
                  {
                     this[_loc2_] = true;
                  }
                  else
                  {
                     this[_loc2_] = false;
                  }
               }
            }
         }
      }
      
      public function cloneToObject() : Object
      {
         var _loc1_:Object = {};
         for(var _loc2_:String in thisOb)
         {
            _loc1_[_loc2_] = this[_loc2_];
         }
         return _loc1_;
      }
   }
}

