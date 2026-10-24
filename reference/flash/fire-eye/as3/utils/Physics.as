package utils
{
   import com.game.engine.nape.TerrainBody;
   import com.game.engine.nape.WaterBody;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.geom.Rectangle;
   import models.constants.GroupType;
   import models.constants.ManType;
   import models.managers.BattleModelManager;
   import models.managers.UserModelManager;
   import models.vo.BodyUserData;
   import models.vo.module.ItemVoManager;
   import models.vo.module.PropVo;
   import modules.ApplicationFacade;
   import nape.callbacks.CbEvent;
   import nape.callbacks.CbType;
   import nape.callbacks.InteractionCallback;
   import nape.callbacks.InteractionListener;
   import nape.callbacks.InteractionType;
   import nape.callbacks.PreCallback;
   import nape.callbacks.PreFlag;
   import nape.callbacks.PreListener;
   import nape.constraint.Constraint;
   import nape.dynamics.Arbiter;
   import nape.geom.Vec2;
   import nape.phys.Body;
   import nape.phys.BodyType;
   import nape.shape.Circle;
   import nape.shape.Polygon;
   import nape.shape.Shape;
   import nape.space.Space;
   import nape.util.ShapeDebug;
   import viewers.container.BattleMap;
   import viewers.entitys.Entity;
   import viewers.entitys.man.ManEntity;
   import viewers.entitys.man.MonsterEntity;
   import viewers.entitys.man.RoleEntity;
   import viewers.entitys.others.BattleExitGateway;
   import viewers.entitys.others.ShipEntity;
   
   public class Physics
   {
      
      public static var Ins:Physics;
      
      private static var _needRemoves:Array = [];
      
      private var _gv:Vec2;
      
      private var _space:Space;
      
      private var stage:DisplayObjectContainer;
      
      private var _debug:ShapeDebug;
      
      public var deltaTime:Number;
      
      private var _roleGroupIds:Array = [1,2,4,8,16,32,64];
      
      public function Physics(param1:DisplayObjectContainer, param2:int = 0, param3:int = 300, param4:Number = 0.1)
      {
         super();
         this.deltaTime = param4;
         this.stage = param1;
         _gv = new Vec2(param2,param3);
         _space = new Space(_gv);
         _space.worldAngularDrag = _space.worldLinearDrag = 0;
         Ins = this;
      }
      
      public static function addRemoveBody(param1:Body) : void
      {
      }
      
      public static function removeBody(param1:Body) : void
      {
         var _loc3_:int = 0;
         var _loc2_:Constraint = null;
         if(!param1)
         {
            return;
         }
         _loc3_ = 0;
         while(_loc3_ < param1.constraints.length)
         {
            _loc2_ = param1.constraints.at(_loc3_);
            _loc2_.space = null;
            _loc3_++;
         }
         param1.shapes.clear();
         param1.cbTypes.clear();
         if(param1.space)
         {
            param1.space.bodies.remove(param1);
         }
         if(param1.userData && param1.userData.data)
         {
            param1.userData.data.entity = null;
            param1.userData.data = null;
         }
         param1.shapes.clear();
         param1.space = null;
         param1 = null;
      }
      
      public function get space() : Space
      {
         return _space;
      }
      
      public function createMan(param1:Rectangle, param2:int, param3:int, param4:Boolean = false) : Body
      {
         var _loc7_:Body = null;
         var _loc6_:Circle = null;
         if(param4)
         {
            _loc7_ = createCircle(new Rectangle(param1.x,param1.y,2,2));
         }
         else
         {
            _loc7_ = createBox(param1);
         }
         _loc7_.cbTypes.add(CBTypes.manCbType);
         _loc7_.isBullet = true;
         var _loc5_:int = 40;
         if(param4)
         {
            _loc6_ = new Circle(param1.width / 2,new Vec2(0,0));
         }
         else
         {
            _loc6_ = new Circle(_loc5_ / 2,new Vec2(0,30));
         }
         _loc7_.shapes.unshift(_loc6_);
         _loc7_.align();
         _loc7_.shapes.at(0).filter.collisionGroup = param3;
         _loc7_.shapes.at(0).filter.collisionMask = 0x0100 | 0x0400 | 0x0800 | 0x1000 | 0x4000 | 0x040000 | 0x100000;
         _loc7_.shapes.at(0).filter.fluidGroup = param3;
         _loc7_.shapes.at(1).filter.collisionGroup = param3;
         _loc7_.shapes.at(1).filter.collisionMask = 0x0100 | 0x0400 | 0x0800 | 0x1000 | 0x4000 | 0x040000 | 0x100000;
         _loc7_.shapes.at(1).filter.fluidGroup = param3;
         _loc7_.shapes.at(0).material.elasticity = 0;
         _loc7_.shapes.at(1).material.elasticity = 0;
         if(param2 == 2)
         {
            _loc7_.gravMass = 0;
            _loc7_.shapes.at(0).filter.collisionMask = 0x0400 | 0x0800 | 0x1000 | 0x4000 | 0x040000 | 0x100000;
            _loc7_.shapes.at(1).filter.collisionMask = 0x0400 | 0x0800 | 0x1000 | 0x4000 | 0x040000 | 0x100000;
         }
         _loc7_.allowRotation = false;
         _loc7_.gravMass;
         return _loc7_;
      }
      
      public function createManSw(param1:Rectangle, param2:int, param3:int, param4:Vec2) : Body
      {
         var _loc7_:Body = null;
         var _loc6_:* = null;
         _loc7_ = createBox(param1);
         _loc7_.shapes.at(0).translate(param4);
         _loc7_.cbTypes.add(CBTypes.manCbType);
         _loc7_.isBullet = true;
         var _loc5_:int = 40;
         _loc7_.shapes.at(0).filter.collisionGroup = param3;
         _loc7_.shapes.at(0).filter.collisionMask = 0x0100 | 0x0400 | 0x0800 | 0x1000 | 0x4000 | 0x040000 | 0x100000;
         _loc7_.shapes.at(0).filter.fluidGroup = param3;
         _loc7_.shapes.at(0).material.elasticity = 0;
         _loc7_.allowRotation = false;
         _loc7_.gravMass = 0;
         return _loc7_;
      }
      
      public function createDropItem(param1:Rectangle) : Body
      {
         var _loc3_:Body = createCircle(param1);
         var _loc2_:Shape = _loc3_.shapes.at(0);
         _loc2_.filter.collisionGroup = 4096;
         _loc2_.filter.collisionMask = -21505;
         _loc3_.cbTypes.add(CBTypes.dropItemCbType);
         _loc3_.allowRotation = false;
         return _loc3_;
      }
      
      private function getRoleGroup() : int
      {
         return _roleGroupIds.shift();
      }
      
      public function createEnemy(param1:Rectangle, param2:int = 1, param3:String = "monster", param4:Boolean = false) : Body
      {
         var _loc6_:Body = null;
         var _loc5_:Circle = null;
         if(param4 == false)
         {
            _loc6_ = createBox(param1);
         }
         else
         {
            _loc6_ = createCircle(new Rectangle(param1.x,param1.y,2,2));
         }
         _loc6_.cbTypes.add(CBTypes.manCbType);
         if(param4)
         {
            _loc5_ = new Circle(param1.width / 2,new Vec2(0,0));
         }
         else
         {
            _loc5_ = new Circle(param1.width / 2,new Vec2(0,30));
         }
         _loc6_.shapes.unshift(_loc5_);
         _loc6_.align();
         _loc6_.shapes.at(0).filter.collisionGroup = 128;
         _loc6_.shapes.at(0).filter.collisionMask = 0x0100 | 0x0400 | 0x0800 | 0x2000 | 0x040000 | 0x080000;
         _loc6_.shapes.at(1).filter.collisionGroup = 128;
         _loc6_.shapes.at(1).filter.collisionMask = 0x0100 | 0x0400 | 0x0800 | 0x2000 | 0x040000 | 0x080000;
         _loc6_.allowRotation = false;
         if(param3 == "npc")
         {
            _loc6_.shapes.at(0).filter.collisionGroup = 65536;
            _loc6_.shapes.at(1).filter.collisionGroup = 65536;
            _loc6_.shapes.at(0).filter.collisionMask = 0x0100 | 0x0400 | 0x0800 | 0x2000 | 0x040000 | 0x080000;
            _loc6_.shapes.at(1).filter.collisionMask = 0x0100 | 0x0400 | 0x0800 | 0x2000 | 0x040000 | 0x080000;
         }
         if(param2 == 2 || param2 == 4)
         {
            _loc6_.gravMass = 0;
            _loc6_.shapes.at(0).filter.collisionMask = 0x0400 | 0x0800 | 0x040000 | 0x080000 | 0x200000;
            _loc6_.shapes.at(1).filter.collisionMask = 0x0400 | 0x0800 | 0x040000 | 0x080000 | 0x200000;
         }
         return _loc6_;
      }
      
      public function createPoly(param1:Rectangle) : Polygon
      {
         return new Polygon(Polygon.rect(param1.x,param1.y,param1.width,param1.height));
      }
      
      public function createBox(param1:Rectangle) : Body
      {
         var _loc3_:Body = new Body(BodyType.DYNAMIC,new Vec2(param1.x,param1.y));
         _loc3_.allowRotation = false;
         var _loc2_:Polygon = new Polygon(Polygon.box(param1.width,param1.height));
         _loc3_.shapes.add(_loc2_);
         _loc3_.space = this._space;
         return _loc3_;
      }
      
      public function createCircle(param1:Rectangle) : Body
      {
         var _loc3_:Body = new Body(BodyType.DYNAMIC,new Vec2(param1.x,param1.y));
         _loc3_.allowRotation = false;
         var _loc2_:Circle = new Circle(param1.width / 2,new Vec2(0,param1.width / 2));
         _loc3_.shapes.add(_loc2_);
         _loc3_.space = this._space;
         return _loc3_;
      }
      
      public function createCircle2(param1:Rectangle, param2:Vec2) : Body
      {
         var _loc4_:Body = new Body(BodyType.DYNAMIC,new Vec2(param1.x,param1.y));
         _loc4_.allowRotation = false;
         var _loc3_:Circle = new Circle(param1.width / 2,param2);
         _loc4_.shapes.add(_loc3_);
         _loc4_.space = this._space;
         return _loc4_;
      }
      
      public function createDebug() : void
      {
         var _loc1_:Number = 15000;
         var _loc2_:Number = 6500;
         _debug = new ShapeDebug(_loc1_,_loc2_);
         _debug.drawConstraints = true;
         stage.addChild(_debug.display);
      }
      
      public function removeDebug() : void
      {
         if(_debug)
         {
            _debug.clear();
         }
         _debug = null;
      }
      
      public function step() : void
      {
         var _loc2_:Body = null;
         var _loc3_:DisplayObject = null;
         var _loc1_:Vec2 = null;
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         if(!_space)
         {
            return;
         }
         if(_debug)
         {
            _debug.clear();
         }
         _space.step(deltaTime);
         if(!_space)
         {
            return;
         }
         _loc5_ = 0;
         while(_loc5_ < _space.liveBodies.length)
         {
            _loc2_ = _space.liveBodies.at(_loc5_);
            if(_loc2_.userData.data.group != "wall")
            {
               if(_loc2_.userData.data.entity)
               {
                  _loc3_ = _loc2_.userData.data.entity.display;
                  _loc1_ = _loc2_.position;
                  if(_loc3_ != null)
                  {
                     _loc2_.userData.data.entity.updateDisplay();
                  }
               }
            }
            _loc5_++;
         }
         _loc4_ = 0;
         while(_loc4_ < _space.bodies.length)
         {
            _loc2_ = _space.bodies.at(_loc4_);
            if(_loc2_.type == BodyType.KINEMATIC && _loc2_.userData.data && _loc2_.userData.data.entity)
            {
               _loc3_ = _loc2_.userData.data.entity.display;
               _loc1_ = _loc2_.position;
               if(_loc3_ != null)
               {
                  _loc2_.userData.data.entity.updateDisplay();
               }
            }
            _loc4_++;
         }
         if(_debug)
         {
            _debug.draw(_space);
            _debug.flush();
         }
      }
      
      public function addManFloorCollide() : void
      {
         var _loc25_:InteractionListener = new InteractionListener(CbEvent.BEGIN,InteractionType.COLLISION,CBTypes.manCbType,CBTypes.floorCbType,handBeginOnFloor);
         _space.listeners.add(_loc25_);
         var _loc18_:InteractionListener = new InteractionListener(CbEvent.END,InteractionType.COLLISION,CBTypes.manCbType,CBTypes.floorCbType,handEndOnFloor);
         _space.listeners.add(_loc18_);
         var _loc2_:InteractionListener = new InteractionListener(CbEvent.BEGIN,InteractionType.COLLISION,CBTypes.manCbType,CBTypes.groundType,handBeginOnFloor);
         _space.listeners.add(_loc2_);
         var _loc9_:InteractionListener = new InteractionListener(CbEvent.END,InteractionType.COLLISION,CBTypes.manCbType,CBTypes.groundType,handEndOnFloor);
         _space.listeners.add(_loc9_);
         var _loc17_:InteractionListener = new InteractionListener(CbEvent.BEGIN,InteractionType.SENSOR,CBTypes.manCbType,CBTypes.createMonsterCbType,handOnCreateMonster);
         _space.listeners.add(_loc17_);
         var _loc27_:InteractionListener = new InteractionListener(CbEvent.END,InteractionType.SENSOR,CBTypes.manCbType,CBTypes.createMonsterCbType,handOutCreateMonster);
         _space.listeners.add(_loc27_);
         var _loc22_:InteractionListener = new InteractionListener(CbEvent.BEGIN,InteractionType.SENSOR,CBTypes.manCbType,CBTypes.gatewayCbType,handOnGateway);
         _space.listeners.add(_loc22_);
         var _loc11_:InteractionListener = new InteractionListener(CbEvent.END,InteractionType.SENSOR,CBTypes.manCbType,CBTypes.gatewayCbType,handOutGateway);
         _space.listeners.add(_loc11_);
         var _loc16_:InteractionListener = new InteractionListener(CbEvent.BEGIN,InteractionType.SENSOR,CBTypes.horseCbType,CBTypes.gatewayCbType,handOnGateway);
         _space.listeners.add(_loc22_);
         var _loc14_:InteractionListener = new InteractionListener(CbEvent.END,InteractionType.SENSOR,CBTypes.horseCbType,CBTypes.gatewayCbType,handOutGateway);
         _space.listeners.add(_loc11_);
         var _loc8_:InteractionListener = new InteractionListener(CbEvent.BEGIN,InteractionType.SENSOR,CBTypes.itemCbType,CBTypes.createMonsterCbType,handOnGroupGateway);
         _space.listeners.add(_loc8_);
         var _loc21_:InteractionListener = new InteractionListener(CbEvent.BEGIN,InteractionType.COLLISION,CBTypes.manCbType,CBTypes.horseCbType,handOnItem);
         _space.listeners.add(_loc21_);
         var _loc24_:InteractionListener = new InteractionListener(CbEvent.BEGIN,InteractionType.COLLISION,CBTypes.floorCbType,CBTypes.groundType,handBeginOnFloor2);
         _space.listeners.add(_loc24_);
         var _loc23_:InteractionListener = new InteractionListener(CbEvent.BEGIN,InteractionType.COLLISION,CBTypes.floorCbType,CBTypes.floorCbType,handBeginOnFloor3);
         _space.listeners.add(_loc23_);
         var _loc30_:InteractionListener = new InteractionListener(CbEvent.BEGIN,InteractionType.FLUID,CbType.ANY_BODY,CBTypes.manCbType,handOnFluid);
         _space.listeners.add(_loc30_);
         var _loc20_:InteractionListener = new InteractionListener(CbEvent.END,InteractionType.FLUID,CbType.ANY_BODY,CBTypes.manCbType,handOutFluid);
         _space.listeners.add(_loc20_);
         var _loc19_:InteractionListener = new InteractionListener(CbEvent.BEGIN,InteractionType.COLLISION,CBTypes.manCbType,CBTypes.dropItemCbType,handBeginDropItem);
         _space.listeners.add(_loc19_);
         var _loc26_:PreListener = new PreListener(InteractionType.COLLISION,CBTypes.floorCbType,CBTypes.manCbType,handPrelistener);
         _space.listeners.add(_loc26_);
         var _loc4_:PreListener = new PreListener(InteractionType.COLLISION,CBTypes.edgeType,CBTypes.manCbType,handPreEdgelistener);
         _space.listeners.add(_loc4_);
         var _loc5_:PreListener = new PreListener(InteractionType.COLLISION,CBTypes.wall2,CBTypes.manCbType,handPreWall2listener);
         _space.listeners.add(_loc5_);
         var _loc6_:PreListener = new PreListener(InteractionType.COLLISION,CBTypes.wall,CBTypes.manCbType,handPreWall1listener);
         _space.listeners.add(_loc6_);
         var _loc28_:InteractionListener = new InteractionListener(CbEvent.BEGIN,InteractionType.COLLISION,CBTypes.edgeType,CBTypes.manCbType,handBeginOnEdge);
         _space.listeners.add(_loc28_);
         var _loc29_:InteractionListener = new InteractionListener(CbEvent.END,InteractionType.COLLISION,CBTypes.edgeType,CBTypes.manCbType,handEndOnEdge);
         _space.listeners.add(_loc29_);
         var _loc1_:PreListener = new PreListener(InteractionType.COLLISION,CBTypes.dropItemCbType,CBTypes.manCbType,handDropPrelistener);
         _space.listeners.add(_loc1_);
         var _loc32_:PreListener = new PreListener(InteractionType.COLLISION,CBTypes.horseCbType,CBTypes.manCbType,handPreItemlistener);
         _space.listeners.add(_loc32_);
         var _loc7_:InteractionListener = new InteractionListener(CbEvent.BEGIN,InteractionType.COLLISION,CBTypes.dropItemCbType,CBTypes.floorCbType,handDropBeginOnFloor);
         _space.listeners.add(_loc7_);
         var _loc10_:InteractionListener = new InteractionListener(CbEvent.BEGIN,InteractionType.COLLISION,CBTypes.dropItemCbType,CBTypes.groundType,handDropBeginOnFloor);
         _space.listeners.add(_loc10_);
         var _loc12_:InteractionListener = new InteractionListener(CbEvent.BEGIN,InteractionType.COLLISION,CBTypes.itemCbType,CBTypes.itemCbType,handGroundBegin);
         _space.listeners.add(_loc12_);
         var _loc13_:InteractionListener = new InteractionListener(CbEvent.BEGIN,InteractionType.COLLISION,CbType.ANY_BODY,CbType.ANY_BODY,handAnyBodyBegin);
         _space.listeners.add(_loc13_);
         var _loc15_:InteractionListener = new InteractionListener(CbEvent.END,InteractionType.COLLISION,CbType.ANY_BODY,CbType.ANY_BODY,handAnyBodyEnd);
         _space.listeners.add(_loc15_);
         var _loc3_:InteractionListener = new InteractionListener(CbEvent.BEGIN,InteractionType.SENSOR,CbType.ANY_BODY,CbType.ANY_BODY,handSensorEnter);
         _space.listeners.add(_loc3_);
         var _loc31_:InteractionListener = new InteractionListener(CbEvent.END,InteractionType.SENSOR,CbType.ANY_BODY,CbType.ANY_BODY,handSensorEnd);
         _space.listeners.add(_loc31_);
      }
      
      private function handSensorEnter(param1:InteractionCallback) : void
      {
         var _loc2_:BodyUserData = param1.int1.castBody.userData.data;
         var _loc3_:BodyUserData = param1.int2.castBody.userData.data;
         if(_loc2_ && _loc3_)
         {
            if(_loc2_ && _loc2_.gameObject && _loc2_.gameObject.hasOwnProperty("OnSensorEnter"))
            {
               _loc2_.gameObject.OnSensorEnter(_loc3_);
            }
            if(_loc3_ && _loc3_.gameObject && _loc3_.gameObject.hasOwnProperty("OnSensorEnter"))
            {
               _loc3_.gameObject.OnSensorEnter(_loc2_);
            }
            if(_loc2_ && _loc2_.gameObject && _loc2_.gameObject.hasOwnProperty("OnSensorEnter2"))
            {
               _loc2_.gameObject.OnSensorEnter2(_loc3_,_loc2_);
            }
            if(_loc3_ && _loc3_.gameObject && _loc3_.gameObject.hasOwnProperty("OnSensorEnter2"))
            {
               _loc3_.gameObject.OnSensorEnter2(_loc2_,_loc3_);
            }
         }
      }
      
      private function handSensorEnd(param1:InteractionCallback) : void
      {
         var _loc2_:BodyUserData = param1.int1.castBody.userData.data;
         var _loc3_:BodyUserData = param1.int2.castBody.userData.data;
         if(_loc2_ && _loc3_)
         {
            if(_loc2_ && _loc2_.gameObject && _loc2_.gameObject.hasOwnProperty("OnSensorExit"))
            {
               _loc2_.gameObject.OnSensorExit(_loc3_);
            }
            if(_loc3_ && _loc3_.gameObject && _loc3_.gameObject.hasOwnProperty("OnSensorExit"))
            {
               _loc3_.gameObject.OnSensorExit(_loc2_);
            }
         }
      }
      
      private function handAnyBodyBegin(param1:InteractionCallback) : void
      {
         var _loc2_:BodyUserData = param1.int1.castBody.userData.data;
         var _loc3_:BodyUserData = param1.int2.castBody.userData.data;
         if(_loc2_ && _loc2_.entity)
         {
            if(param1.arbiters.length > 0)
            {
               _loc2_.entity.handAnyCollided(_loc3_,param1.arbiters.at(0));
            }
            else
            {
               _loc2_.entity.handAnyCollided(_loc3_,null);
            }
         }
         if(_loc3_ && _loc3_.entity)
         {
            if(param1.arbiters.length > 0)
            {
               _loc3_.entity.handAnyCollided(_loc2_,param1.arbiters.at(0));
            }
            else
            {
               _loc3_.entity.handAnyCollided(_loc2_,null);
            }
         }
      }
      
      private function handAnyBodyEnd(param1:InteractionCallback) : void
      {
         var _loc2_:BodyUserData = param1.int1.castBody.userData.data;
         var _loc3_:BodyUserData = param1.int2.castBody.userData.data;
         if(_loc2_.entity)
         {
            _loc2_.entity.handAnyCollidedEnd(_loc3_,null);
         }
         if(_loc3_.entity)
         {
            _loc3_.entity.handAnyCollidedEnd(_loc2_,null);
         }
      }
      
      private function handGroundBegin(param1:InteractionCallback) : void
      {
         var _loc4_:Entity = null;
         var _loc2_:BodyUserData = param1.int1.castBody.userData.data;
         var _loc3_:BodyUserData = param1.int2.castBody.userData.data;
         if(_loc2_.entity && _loc3_.entity)
         {
            if(_loc2_.entity.properties.properties.hasOwnProperty("collison2") && _loc3_.entity.properties.properties.hasOwnProperty("collison2"))
            {
               if(_loc2_.entity.properties.properties.hasOwnProperty("collisonTrigger") && _loc3_.entity.properties.properties.hasOwnProperty("collisonTrigger"))
               {
                  _loc4_ = BattleMap.Ins.map.findEntityByTriggerID(_loc2_.entity.properties.properties.collisonTrigger);
                  if(_loc4_)
                  {
                     _loc4_.trigger(_loc2_.entity);
                  }
               }
               _loc2_.entity.Todie();
               _loc3_.entity.Todie();
            }
         }
      }
      
      private function handOnFluid(param1:InteractionCallback) : void
      {
         var _loc2_:ManEntity = param1.int2.castBody.userData.data.entity;
         _loc2_.handInWater(param1.int1.castBody);
      }
      
      private function handOutFluid(param1:InteractionCallback) : void
      {
         var _loc2_:ManEntity = param1.int2.castBody.userData.data.entity;
         _loc2_.handOutWater();
      }
      
      private function handOnCreateMonster(param1:InteractionCallback) : void
      {
         var _loc7_:Array = null;
         var _loc8_:int = 0;
         var _loc6_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Entity = null;
         var _loc3_:Entity = null;
         var _loc2_:Boolean = false;
         _loc5_ = null;
         _loc3_ = null;
         _loc2_ = false;
         if(param1.int2.castBody.userData.data.group == "createJITrigger")
         {
            if(param1.int2.castBody.userData.data.entity.properties.properties.hasOwnProperty("triggerGType"))
            {
               return;
            }
            if(param1.int2.castBody.userData.data.entity.properties.properties.hasOwnProperty("triggerCampIds"))
            {
               if(!param1.int2.castBody.userData.data.entity.properties.properties.triggerCampIdsArr)
               {
                  _loc7_ = String(param1.int2.castBody.userData.data.entity.properties.properties.triggerCampIds).split(";");
                  param1.int2.castBody.userData.data.entity.properties.properties.triggerCampIdsArr = [];
                  _loc8_ = 0;
                  while(_loc8_ < _loc7_.length)
                  {
                     param1.int2.castBody.userData.data.entity.properties.properties.triggerCampIdsArr[_loc8_] = int(_loc7_[_loc8_]);
                     _loc8_++;
                  }
               }
               _loc7_ = param1.int2.castBody.userData.data.entity.properties.properties.triggerCampIdsArr;
               if(_loc7_.indexOf(ManEntity(param1.int1.castBody.userData.data.entity).userVo.campId) > -1)
               {
                  param1.int2.castBody.userData.data.entity.trigger(ManEntity(param1.int1.castBody.userData.data.entity));
               }
               return;
            }
            if(param1.int2.castBody.userData.data.entity.properties.properties.hasOwnProperty("triggerCampId"))
            {
               _loc6_ = int(param1.int2.castBody.userData.data.entity.properties.properties.triggerCampId);
               if(ManEntity(param1.int1.castBody.userData.data.entity).userVo.campId == _loc6_ && _loc6_ != 1)
               {
                  if(param1.int2.castBody.userData.data.entity.properties.properties.hasOwnProperty("triggerMonsterId"))
                  {
                     _loc4_ = int(param1.int2.castBody.userData.data.entity.properties.properties.triggerMonsterId);
                     if(ManEntity(param1.int1.castBody.userData.data.entity).userVo && ManEntity(param1.int1.castBody.userData.data.entity).userVo.charID != _loc4_)
                     {
                        return;
                     }
                  }
                  param1.int2.castBody.userData.data.entity.trigger(ManEntity(param1.int1.castBody.userData.data.entity));
                  if(param1.int2.castBody.userData.data.entity.properties.properties.hasOwnProperty("deletedAtTriggerAfter"))
                  {
                     if(param1.int2.castBody.userData.data.entity.properties.properties.deletedAtTriggerAfter == "0")
                     {
                        return;
                     }
                  }
                  _space.bodies.remove(param1.int2.castBody);
                  addRemoveBody(param1.int2.castBody);
               }
               return;
            }
         }
         if(ManEntity(param1.int1.castBody.userData.data.entity).userVo.type == "role" || ManEntity(param1.int1.castBody.userData.data.entity).userVo.type == ManType.HORSE || ManEntity(param1.int1.castBody.userData.data.entity).isRole)
         {
            if(param1.int2.castBody.userData.data.group == "createJITrigger")
            {
               if(param1.int2.castBody.userData.data.entity.properties.properties.hasOwnProperty("p2In"))
               {
                  if(param1.int2.castBody.userData.data.entity.properties.properties.hasOwnProperty("parr") == false)
                  {
                     param1.int2.castBody.userData.data.entity.properties.properties.parr = [];
                  }
                  param1.int2.castBody.userData.data.entity.properties.properties.parr.push(ManEntity(param1.int1.castBody.userData.data.entity).userVo.ps);
                  if(int(param1.int2.castBody.userData.data.entity.properties.properties.p2In) == 1)
                  {
                     if(UserModelManager.getIns().getCurretPlayerInfo().pMode == 2)
                     {
                        _loc5_ = BattleModelManager.getIns().getPlayerByEntityId(UserModelManager.getIns().playerUserVo1.entitieId);
                        _loc3_ = BattleModelManager.getIns().getPlayerByEntityId(UserModelManager.getIns().playerUserVo2.entitieId);
                        _loc2_ = true;
                        if(!_loc5_ || _loc5_.isDie || _loc5_.deleted)
                        {
                           _loc2_ = false;
                        }
                        if(!_loc3_ || _loc3_.isDie || _loc3_.deleted)
                        {
                           _loc2_ = false;
                        }
                        if(_loc2_)
                        {
                           if(param1.int2.castBody.userData.data.entity.properties.properties.parr.length < 2)
                           {
                              return;
                           }
                        }
                     }
                  }
               }
               param1.int2.castBody.userData.data.entity.trigger(ManEntity(param1.int1.castBody.userData.data.entity));
            }
            else
            {
               if(param1.int2.castBody.userData.data.entity.properties.properties.hasOwnProperty("p2In"))
               {
                  if(param1.int2.castBody.userData.data.entity.properties.properties.hasOwnProperty("parr") == false)
                  {
                     param1.int2.castBody.userData.data.entity.properties.properties.parr = [];
                  }
                  param1.int2.castBody.userData.data.entity.properties.properties.parr.push(ManEntity(param1.int1.castBody.userData.data.entity).userVo.ps);
                  if(int(param1.int2.castBody.userData.data.entity.properties.properties.p2In) == 1)
                  {
                     if(UserModelManager.getIns().getCurretPlayerInfo().pMode == 2)
                     {
                        _loc5_ = BattleModelManager.getIns().getPlayerByEntityId(UserModelManager.getIns().playerUserVo1.entitieId);
                        _loc3_ = BattleModelManager.getIns().getPlayerByEntityId(UserModelManager.getIns().playerUserVo2.entitieId);
                        _loc2_ = true;
                        if(!_loc5_ || _loc5_.isDie || _loc5_.deleted)
                        {
                           _loc2_ = false;
                        }
                        if(!_loc3_ || _loc3_.isDie || _loc3_.deleted)
                        {
                           _loc2_ = false;
                        }
                        if(_loc2_)
                        {
                           if(param1.int2.castBody.userData.data.entity.properties.properties.parr.length < 2)
                           {
                              return;
                           }
                        }
                     }
                  }
               }
               ApplicationFacade.getInstance().sendNotification("createMonsterTrigger",param1.int2.castBody.userData.data.entity);
            }
            if(param1.int2.castBody.userData.data && param1.int2.castBody.userData.data.entity.properties.properties.hasOwnProperty("deletedAtTriggerAfter"))
            {
               if(param1.int2.castBody.userData.data.entity.properties.properties.deletedAtTriggerAfter == "0")
               {
                  return;
               }
            }
            _space.bodies.remove(param1.int2.castBody);
            addRemoveBody(param1.int2.castBody);
         }
      }
      
      private function handOnGroupGateway(param1:InteractionCallback) : void
      {
         var _loc3_:String = null;
         var _loc2_:Boolean = false;
         if(param1.int2.castBody.userData.data.group == "createJITrigger")
         {
            if(param1.int2.castBody.userData.data.entity.properties.properties.hasOwnProperty("triggerGType"))
            {
               _loc3_ = param1.int2.castBody.userData.data.entity.properties.properties.triggerGType;
               if(_loc3_ == Entity(param1.int1.castBody.userData.data.entity).properties.properties.groupType)
               {
                  _loc2_ = true;
                  param1.int2.castBody.userData.data.entity.trigger(Entity(param1.int1.castBody.userData.data.entity));
               }
            }
            if(_loc2_)
            {
               if(param1.int2.castBody.userData.data.entity.properties.properties.hasOwnProperty("deletedAtTriggerAfter"))
               {
                  if(param1.int2.castBody.userData.data.entity.properties.properties.deletedAtTriggerAfter == "0")
                  {
                     return;
                  }
               }
               _space.bodies.remove(param1.int2.castBody);
            }
         }
      }
      
      private function handOutCreateMonster(param1:InteractionCallback) : void
      {
         if(param1.int2.castBody.userData.data.entity.properties.properties.hasOwnProperty("triggerCampIds"))
         {
            param1.int2.castBody.userData.data.entity.outTrigger(ManEntity(param1.int1.castBody.userData.data.entity));
            return;
         }
         if(ManEntity(param1.int1.castBody.userData.data.entity).userVo.type == "role" || ManEntity(param1.int1.castBody.userData.data.entity).userVo.type == ManType.HORSE)
         {
            if(param1.int2.castBody.userData.data.group == "createJITrigger")
            {
               param1.int2.castBody.userData.data.entity.outTrigger(ManEntity(param1.int1.castBody.userData.data.entity));
            }
            if(param1.int2.castBody.userData.data.entity.properties.properties.hasOwnProperty("p2In"))
            {
               if(param1.int2.castBody.userData.data.entity.properties.properties.hasOwnProperty("parr") == false)
               {
                  param1.int2.castBody.userData.data.entity.properties.properties.parr = [];
               }
               else
               {
                  param1.int2.castBody.userData.data.entity.properties.properties.parr.shift();
               }
            }
         }
      }
      
      private function handOnGateway(param1:InteractionCallback) : void
      {
         var _loc2_:BattleExitGateway = null;
         if(ManEntity(param1.int1.castBody.userData.data.entity).userVo.type == "role" || ManEntity(param1.int1.castBody.userData.data.entity).userVo.type == ManType.HORSE || ManEntity(param1.int1.castBody.userData.data.entity).isRole)
         {
            RoleEntity(param1.int1.castBody.userData.data.entity).inGateWay(param1.int2.castBody.userData.data.entity);
            _loc2_ = BattleExitGateway(param1.int2.castBody.userData.data.entity);
            if(_loc2_)
            {
               _loc2_.manIn(RoleEntity(param1.int1.castBody.userData.data.entity));
            }
         }
      }
      
      private function handOutGateway(param1:InteractionCallback) : void
      {
         var _loc2_:BattleExitGateway = null;
         if(ManEntity(param1.int1.castBody.userData.data.entity).userVo.type == "role" || ManEntity(param1.int1.castBody.userData.data.entity).userVo.type == ManType.HORSE || ManEntity(param1.int1.castBody.userData.data.entity).isRole)
         {
            RoleEntity(param1.int1.castBody.userData.data.entity).outGateWay(param1.int2.castBody.userData.data.entity);
            _loc2_ = BattleExitGateway(param1.int2.castBody.userData.data.entity);
            if(_loc2_)
            {
               _loc2_.manOut(RoleEntity(param1.int1.castBody.userData.data.entity));
            }
         }
      }
      
      private function handPrelistener(param1:PreCallback) : PreFlag
      {
         var _loc2_:Boolean = param1.int1.castBody.userData.data.group == "floor";
         if(!_loc2_)
         {
            return PreFlag.ACCEPT;
         }
         if(param1.swapped == false)
         {
            if(param1.arbiter.collisionArbiter.normal.y >= 0)
            {
               return PreFlag.IGNORE;
            }
         }
         else if(param1.arbiter.collisionArbiter.normal.y <= 0)
         {
            return PreFlag.IGNORE;
         }
         return PreFlag.ACCEPT;
      }
      
      private function handPreEdgelistener(param1:PreCallback) : PreFlag
      {
         var _loc2_:MonsterEntity = null;
         var _loc3_:Boolean = param1.int1.castBody.userData.data.group == GroupType.EDGE;
         if(!_loc3_)
         {
            return PreFlag.ACCEPT;
         }
         if(Entity(param1.int1.castBody.userData.data.entity).properties.properties.hasOwnProperty("isStand"))
         {
            return PreFlag.ACCEPT;
         }
         _loc2_ = param1.int2.castBody.userData.data.entity as MonsterEntity;
         if(!_loc2_)
         {
            return PreFlag.IGNORE;
         }
         if(param1.swapped == false || _loc2_)
         {
            _loc2_ = param1.int2.castBody.userData.data.entity;
            if(_loc2_.getMoveType() != 1)
            {
               return PreFlag.IGNORE;
            }
            if(_loc2_.currentActionState != 5)
            {
               return PreFlag.ACCEPT;
            }
         }
         else
         {
            _loc2_ = param1.int1.castBody.userData.data.entity;
            if(_loc2_ && _loc2_.getMoveType() != 1)
            {
               return PreFlag.IGNORE;
            }
            if(_loc2_.currentActionState != 5)
            {
               return PreFlag.ACCEPT;
            }
         }
         return PreFlag.IGNORE;
      }
      
      private function handPreWall1listener(param1:PreCallback) : PreFlag
      {
         var _loc2_:BodyUserData = null;
         var _loc3_:BodyUserData = null;
         try
         {
            _loc2_ = param1.int1.castBody.userData.data;
            _loc3_ = param1.int2.castBody.userData.data;
            if(_loc2_.group == "wall" && (_loc3_.group == "role" || _loc3_.group == "monster" || _loc3_.group == "horse"))
            {
               if(_loc2_.data.campId == _loc3_.entity.userVo.campId)
               {
                  return PreFlag.IGNORE;
               }
            }
            else if(_loc3_.group == "wall" && (_loc2_.group == "role" || _loc2_.group == "monster" || _loc2_.group == "horse"))
            {
               if(_loc3_.data.campId == _loc2_.entity.userVo.campId)
               {
                  return PreFlag.IGNORE;
               }
            }
         }
         catch(error:Error)
         {
         }
         return PreFlag.ACCEPT;
      }
      
      private function handPreWall2listener(param1:PreCallback) : PreFlag
      {
         var _loc2_:BodyUserData = param1.int1.castBody.userData.data;
         var _loc3_:BodyUserData = param1.int2.castBody.userData.data;
         if(_loc2_.group == GroupType.WALL2 && (_loc3_.group == "role" || _loc3_.group == "monster"))
         {
            if(_loc2_.entity.userVo.campId != _loc3_.entity.userVo.campId)
            {
               if(_loc3_.entity.userVo.configVo && _loc3_.entity.userVo.configVo.isMigration == 0)
               {
                  return PreFlag.IGNORE;
               }
               return PreFlag.ACCEPT;
            }
         }
         else if(_loc3_.group == GroupType.WALL2 && (_loc2_.group == "role" || _loc2_.group == "monster"))
         {
            if(_loc2_.entity.userVo.campId != _loc3_.entity.userVo.campId)
            {
               if(_loc2_.entity.userVo.configVo && _loc2_.entity.userVo.configVo.isMigration == 0)
               {
                  return PreFlag.IGNORE;
               }
               return PreFlag.ACCEPT;
            }
         }
         try
         {
            if(_loc2_.group == GroupType.WALL2)
            {
               if(_loc2_.entity.getCollideWall2(_loc3_))
               {
                  return PreFlag.ACCEPT;
               }
            }
            if(_loc3_.group == GroupType.WALL2)
            {
               if(_loc3_.entity.getCollideWall2(_loc2_))
               {
                  return PreFlag.ACCEPT;
               }
            }
         }
         catch(error:Error)
         {
         }
         return PreFlag.IGNORE;
      }
      
      private function handDropPrelistener(param1:PreCallback) : PreFlag
      {
         return PreFlag.IGNORE;
      }
      
      private function handPreItemlistener(param1:PreCallback) : PreFlag
      {
         if(param1.int1.castBody.userData.data.group != "horse")
         {
            return PreFlag.ACCEPT;
         }
         if(param1.int2.castBody.userData.data.group == "monster")
         {
            return PreFlag.IGNORE;
         }
         if(param1.swapped == true)
         {
            if(param1.arbiter.collisionArbiter.normal.y <= 0)
            {
               return PreFlag.IGNORE;
            }
         }
         else if(param1.swapped == false)
         {
            if(param1.arbiter.collisionArbiter.normal.y >= 0)
            {
               return PreFlag.IGNORE;
            }
         }
         return PreFlag.ACCEPT;
      }
      
      private function handEndOnFloor(param1:InteractionCallback) : void
      {
         param1.int1.castBody.userData.data.entity.handEndOnFloor(param1);
         if(param1.int2.castBody.userData.data && param1.int2.castBody.userData.data.entity)
         {
            param1.int2.castBody.userData.data.entity.handEndOnFloor(param1);
         }
      }
      
      private function handBeginOnFloor(param1:InteractionCallback) : void
      {
         param1.int1.castBody.userData.data.entity.handOnFloor(param1);
         if(param1.int2.castBody.userData.data && param1.int2.castBody.userData.data.entity)
         {
            param1.int2.castBody.userData.data.entity.handOnFloor(param1);
         }
      }
      
      private function handDropBeginOnFloor(param1:InteractionCallback) : void
      {
         param1.int1.castBody.userData.data.entity.handOnFloor(param1);
      }
      
      private function handBeginOnEdge(param1:InteractionCallback) : void
      {
         var _loc4_:int = 0;
         var _loc2_:BodyUserData = param1.int1.castBody.userData.data;
         var _loc3_:BodyUserData = param1.int2.castBody.userData.data;
         if(_loc3_.group == "monster")
         {
            _loc3_.entity.handCollideEdge();
         }
         if(_loc2_.entity && Entity(_loc2_.entity).properties.properties.hasOwnProperty("isStand"))
         {
            handBeginOnFloor(param1);
         }
         if(_loc3_.entity && _loc3_.group == "monster" && _loc2_.data && _loc2_.data.walkBack)
         {
            _loc4_ = 0;
            if(param1.arbiters.at(0).collisionArbiter.normal.x > 0)
            {
               _loc4_ = -1;
            }
            else if(param1.arbiters.at(0).collisionArbiter.normal.x < 0)
            {
               _loc4_ = 1;
            }
            _loc3_.entity.handCollideEdgeWalkBack(_loc4_);
         }
      }
      
      private function handEndOnEdge(param1:InteractionCallback) : void
      {
         var _loc2_:BodyUserData = param1.int1.castBody.userData.data;
         var _loc3_:BodyUserData = param1.int2.castBody.userData.data;
         if(_loc3_.group == "monster")
         {
            _loc3_.entity.handCollideEndEdge();
         }
         if(_loc2_.entity && Entity(_loc2_.entity).properties.properties.hasOwnProperty("isStand"))
         {
            handEndOnFloor(param1);
         }
         if(_loc3_.entity && _loc3_.group == "monster" && _loc2_.data && _loc2_.data.walkBack)
         {
            _loc3_.entity.handCollideEndEdgeWalkBack();
         }
      }
      
      private function handBeginDropItem(param1:InteractionCallback) : void
      {
         var _loc5_:PropVo = null;
         var _loc3_:BodyUserData = param1.int1.castBody.userData.data;
         var _loc4_:BodyUserData = param1.int2.castBody.userData.data;
         if((_loc3_.group == "role" || _loc3_.group == "horse") && _loc4_.group == GroupType.EFFECT5_1)
         {
            param1.int1.castBody.userData.data.entity.handCollide(_loc4_);
            return;
         }
         var _loc6_:Entity = _loc3_.entity;
         if(_loc6_ && (_loc6_.isDie || _loc6_.deleted))
         {
            return;
         }
         var _loc2_:Entity = _loc4_.entity;
         var _loc7_:Boolean = false;
         if(_loc2_ && _loc2_.drovo.getIsItem())
         {
            _loc5_ = ItemVoManager.getIns().getPropVoById(_loc2_.drovo.id);
            if(_loc5_ && _loc5_.propType == 20)
            {
               _loc7_ = true;
            }
         }
         if(_loc2_ && _loc2_.drovo.getIsLuX())
         {
            return;
         }
         if(_loc2_ && (_loc2_.drovo.getIsXP() || _loc2_.drovo.getIsReFatigue() || _loc2_.drovo.getIsAddSpeed()))
         {
            if((_loc3_.group == "role" || _loc3_.group == "horse") && _loc4_.group == GroupType.DROP_ITEM)
            {
               ApplicationFacade.getInstance().sendNotification("cmdPickUpDropItem",[_loc2_,param1.int1.castBody.userData.data.entity,_loc2_.drovo]);
               param1.int1.castBody.userData.data.entity.handOnDrop(_loc4_.entity);
               _loc4_.group = "dropItem_geted";
               return;
            }
         }
         if(_loc2_ && _loc2_.drovo.getIsAddSkill())
         {
            if((_loc3_.group == "role" || _loc3_.group == "horse") && _loc4_.group == GroupType.DROP_ITEM)
            {
               ApplicationFacade.getInstance().sendNotification("cmdPickUpDropItem",[_loc2_,param1.int1.castBody.userData.data.entity,_loc2_.drovo]);
               param1.int1.castBody.userData.data.entity.handOnDrop(_loc4_.entity);
               _loc4_.group = "dropItem_geted";
               return;
            }
         }
         if(_loc2_.drovo.getIsItem() && _loc7_ == false && UserModelManager.getIns().getCurretPlayerInfo().getIsItemBgFull())
         {
            return;
         }
         if(_loc4_.entity.drovo.getIsEquip() && UserModelManager.getIns().getCurretPlayerInfo().getIsEquipBgFull())
         {
            return;
         }
         if(_loc4_.entity.drovo.getIsFeather() && UserModelManager.getIns().getCurretPlayerInfo().getIsFeatherBgFull())
         {
            return;
         }
         if(_loc4_.entity.drovo.getIsSoul() && UserModelManager.getIns().getCurretPlayerInfo().getIsSoulBgFull())
         {
            return;
         }
         if(_loc4_.entity.drovo.getIspetCrystal() && UserModelManager.getIns().getCurretPlayerInfo().getIsPetCrystalBgFull())
         {
            return;
         }
         if((_loc3_.group == "role" || _loc3_.group == "horse") && _loc4_.group == GroupType.DROP_ITEM)
         {
            ApplicationFacade.getInstance().sendNotification("cmdPickUpDropItem",[_loc2_,param1.int1.castBody.userData.data.entity,_loc2_.drovo]);
            param1.int1.castBody.userData.data.entity.handOnDrop(_loc4_.entity);
            _loc4_.group = "dropItem_geted";
         }
      }
      
      private function handBeginOnFloor2(param1:InteractionCallback) : void
      {
         try
         {
            param1.int1.castBody.userData.data.entity.handOnFloor(param1);
         }
         catch(error:Error)
         {
         }
      }
      
      private function handBeginOnFloor3(param1:InteractionCallback) : void
      {
         var _loc2_:BodyUserData = param1.int1.castBody.userData.data;
         var _loc3_:BodyUserData = param1.int2.castBody.userData.data;
         if(!(_loc2_.entity is ShipEntity))
         {
            if(_loc3_.entity is ShipEntity)
            {
            }
         }
      }
      
      private function handOnItem(param1:InteractionCallback) : void
      {
         var _loc2_:Entity = param1.int1.castBody.userData.data.entity;
         var _loc3_:Entity = param1.int2.castBody.userData.data.entity;
         if(param1.arbiters.length == 0)
         {
            return;
         }
         var _loc4_:Arbiter = param1.arbiters.at(0);
         if(BodyUserData(_loc4_.shape2.body.userData.data).group == "role")
         {
            if(_loc4_.collisionArbiter.normal.y < 0)
            {
               _loc3_.handOnItem(param1);
               _loc2_.handOnItem(param1);
            }
         }
         else if(BodyUserData(_loc4_.shape1.body.userData.data).group == "role")
         {
            if(_loc4_.collisionArbiter.normal.y > 0)
            {
               _loc3_.handOnItem(param1);
               _loc2_.handOnItem(param1);
            }
         }
      }
      
      public function destroy() : void
      {
         var _loc1_:Body = null;
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < _space.liveBodies.length)
         {
            _loc1_ = _space.liveBodies.at(_loc3_);
            _loc3_++;
         }
         _loc2_ = 0;
         while(_loc2_ < _space.bodies.length)
         {
            _loc1_ = _space.bodies.at(_loc2_);
            _loc2_++;
         }
         _space.liveBodies.clear();
         _space.bodies.clear();
         _space.arbiters.clear();
         _space.constraints.clear();
         _space.listeners.clear();
         _space.clear();
         _space = null;
         _debug = null;
      }
      
      public function createFromBD(param1:BitmapData, param2:int, param3:int) : Body
      {
         var _loc4_:TerrainBody = new TerrainBody(param1,1,this._space,param2,param3);
         var _loc5_:Body = _loc4_.body;
         _loc4_.destroy();
         _loc4_ = null;
         return _loc5_;
      }
      
      public function createWater(param1:int, param2:int, param3:int, param4:int, param5:Number, param6:Number, param7:Number = 100, param8:String = "st") : WaterBody
      {
         var _loc9_:WaterBody = new WaterBody(param1,param2,param3,param4,param5,param6,param7,param8);
         _loc9_.getBody().space = this._space;
         return _loc9_;
      }
   }
}

