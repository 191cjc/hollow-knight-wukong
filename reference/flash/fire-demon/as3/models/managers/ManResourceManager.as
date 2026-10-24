package models.managers
{
   import com.game.engine.character.ActionState;
   import com.game.engine.textures.Texture;
   import com.game.engine.utils.BitmapUtils;
   import com.game.engine.utils.SimpleTextLog;
   import com.game.net.AssetItem;
   import com.game.net.AssetManager;
   import com.game.utils.Singleton;
   import dragonBones.Armature;
   import dragonBones.Bone;
   import dragonBones.factories.NativeFactory;
   import dragonBones.objects.AnimationData;
   import dragonBones.objects.ArmatureData;
   import dragonBones.objects.DragonBonesData;
   import flash.display.MovieClip;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getTimer;
   import models.GameData;
   import models.configs.CommonConfig;
   import models.constants.BoatActionState;
   import models.constants.ManType;
   import models.vo.DungeonItemVO;
   import models.vo.MonsterConfigVO;
   import models.vo.ResourceVO;
   import models.vo.RoleConfigVO;
   import models.vo.UserVO;
   import models.vo.module.FashionVo;
   import models.vo.module.ItemVoManager;
   import models.vo.module.MagicweaponVo;
   import models.vo.players.Equipment;
   import utils.Debug;
   import viewers.component.WearComponent;
   import viewers.entitys.Entity;
   
   public class ManResourceManager extends Singleton
   {
      
      private static const AB_HB_SCALE:Number = 1;
      
      private static const FILL:Boolean = false;
      
      private static var _battles:Array = [];
      
      private var _resource:Dictionary = new Dictionary();
      
      private var _resourceRole:Dictionary = new Dictionary();
      
      private var _ride:Object = {};
      
      private var _resourceMC:Dictionary = new Dictionary();
      
      private var _resourceClass:Dictionary = new Dictionary();
      
      private var _acLink:Dictionary = new Dictionary();
      
      public function ManResourceManager()
      {
         super();
      }
      
      public static function getIns() : ManResourceManager
      {
         return Singleton.getIns(ManResourceManager);
      }
      
      public function getTestSz() : Boolean
      {
         return false && GameData.uid == 100;
      }
      
      public function buildResourceByManByscale(param1:Number, param2:AssetItem, param3:Boolean, param4:int = 1, param5:Boolean = false, param6:Boolean = false, param7:Number = 1) : void
      {
         var _loc14_:Object = null;
         var _loc8_:Object = null;
         var _loc11_:Class = null;
         var _loc15_:MovieClip = null;
         var _loc9_:* = undefined;
         var _loc19_:* = undefined;
         var _loc13_:String = null;
         var _loc16_:int = 0;
         var _loc12_:String = null;
         if(!param2)
         {
            return;
         }
         var _loc21_:Number = getTimer();
         SimpleTextLog.getIns().log2("_resource[manid]=" + _resource[param1],param1);
         if(_resource[param1])
         {
            _loc14_ = _resource[param1];
            for(var _loc18_:String in _loc14_)
            {
               _loc8_ = _loc14_[_loc18_];
               if(_loc18_ == "ab")
               {
                  for each(var _loc10_:Object in _loc8_)
                  {
                     dispose(_loc10_);
                  }
               }
            }
         }
         _resource[param1]["ab"] = new Dictionary();
         var _loc20_:Array = param2.classLink.concat();
         SimpleTextLog.getIns().log2(param1,"alllink=",_loc20_);
         var _loc17_:Array = ActionState.NAMES;
         if(param6)
         {
            _loc17_ = BoatActionState.NAMES;
         }
         _loc16_ = 0;
         while(_loc16_ < _loc20_.length)
         {
            _loc12_ = _loc13_ = _loc20_[_loc16_];
            if(_loc13_.indexOf("ab_") == 0 || _loc13_.indexOf("hb_") == 0)
            {
               _loc15_ = _resourceMC[param1][_loc12_];
               if(!_loc15_)
               {
                  _loc11_ = param2.loaderInfo.applicationDomain.getDefinition(_loc12_) as Class;
                  _loc15_ = new _loc11_();
               }
               _loc9_ = Texture.drawMcToTextures(_loc15_,false,1,param7,true,null,false,null,"low");
               _resourceMC[param1][_loc12_] = _loc15_;
               if(_loc13_.indexOf("ab_") == 0)
               {
                  _loc12_ = _loc12_.substr(3);
                  _loc19_ = Texture.drawMcToTextures(_loc15_,false,-1,param7,true,null,false,null,"low");
                  _resource[param1]["ab"][_loc12_] = [_loc9_,_loc19_];
               }
               else if(_loc12_.indexOf("hb_") == 0)
               {
                  _loc12_ = _loc12_.substr(3);
                  _loc19_ = Texture.drawMcToTextures(_loc15_,false,-1,param7,true,null,false,null,"low");
                  _resource[param1]["hb"][_loc12_] = [_loc9_,_loc19_];
               }
            }
            _loc16_++;
         }
      }
      
      public function buildResourceByMan(param1:Number, param2:AssetItem, param3:Boolean, param4:int = 1, param5:Boolean = false, param6:Boolean = false, param7:Boolean = false, param8:Array = null, param9:ResourceVO = null, param10:ResourceVO = null) : void
      {
         var _loc14_:Array = null;
         var _loc22_:int = 0;
         var _loc26_:ResourceVO = null;
         var _loc34_:int = 0;
         var _loc11_:MagicweaponVo = null;
         var _loc13_:RoleConfigVO = null;
         var _loc20_:Class = null;
         var _loc27_:MovieClip = null;
         var _loc12_:* = undefined;
         var _loc16_:* = undefined;
         var _loc25_:DungeonItemVO = null;
         var _loc24_:String = null;
         var _loc36_:Array = null;
         var _loc28_:int = 0;
         var _loc30_:int = 0;
         var _loc23_:String = null;
         var _loc29_:int = 0;
         var _loc15_:Boolean = false;
         var _loc37_:int = 0;
         var _loc32_:int = 0;
         var _loc35_:Boolean = false;
         var _loc21_:String = null;
         _loc21_ = null;
         _loc21_ = null;
         if(!param2)
         {
            return;
         }
         var _loc18_:Number = getTimer();
         SimpleTextLog.getIns().log2("_resource[manid]=" + _resource[param1],param1);
         if(_resource[param1])
         {
            return;
         }
         if(CommonConfig.dungeonActivityMonsterIDs && CommonConfig.getdungeonActivityMonsterOpen())
         {
            _loc14_ = CommonConfig.dungeonActivityMonsterIDs.split(";");
            _loc22_ = 0;
            while(_loc22_ < 1)
            {
               if(param1 == _loc14_[_loc22_] && _resource[_loc14_[0]])
               {
                  _resource[param1] = _resource[_loc14_[0]];
                  return;
               }
               _loc22_++;
            }
         }
         var _loc31_:RoleConfigVO = ManModelManager.getIns().getManById(param1,null);
         if(_loc31_)
         {
            _loc34_ = _loc31_.resourcesId;
            _loc26_ = ResourceManager.getIns().getResourcesByID(_loc34_);
         }
         else
         {
            _loc11_ = ItemVoManager.getIns().getSwordVoById(param1);
            if(!_loc11_)
            {
               _loc11_ = ItemVoManager.getIns().getMagicweaponVoById(param1);
            }
            if(_loc11_)
            {
               _loc26_ = ResourceManager.getIns().getResourcesByID(_loc11_.resourceId);
            }
            if(!_loc26_ && param10)
            {
               _loc26_ = param10;
            }
         }
         if(_loc26_)
         {
            for(var _loc19_:Number in _resource)
            {
               _loc13_ = ManModelManager.getIns().getManById(_loc19_,null);
               if(_loc13_ && _loc13_ is MonsterConfigVO)
               {
                  if(_loc13_.resourcesId == _loc26_.resourcesId && !_resource[_loc19_].deleted)
                  {
                  }
               }
            }
         }
         _resource[param1] = new Dictionary();
         _resource[param1]["ac"] = new Dictionary();
         _resource[param1]["ac_draw_man"] = new Dictionary();
         _resource[param1]["ef"] = new Dictionary();
         _resource[param1]["ab"] = new Dictionary();
         _resource[param1]["hb"] = new Dictionary();
         _resourceMC[param1] = new Dictionary();
         _resourceClass[param1] = new Dictionary();
         var _loc17_:Array = param2.classLink.concat();
         SimpleTextLog.getIns().log2(param1,"alllink=",_loc17_);
         if(!_loc26_)
         {
            _loc25_ = ManModelManager.getIns().getItemById(param1);
            if(_loc25_)
            {
               _loc26_ = ResourceManager.getIns().getResourcesByID(_loc25_.resourcesId);
            }
         }
         if(param5)
         {
            _loc17_ = ["idle","walk"];
            if(_loc26_ && _loc26_.resourceType == 13)
            {
            }
         }
         var _loc33_:Array = ActionState.NAMES;
         if(param6)
         {
            _loc33_ = BoatActionState.NAMES;
         }
         if(param8 != null)
         {
            _loc33_ = param8;
            _loc36_ = [];
            _loc28_ = 0;
            while(_loc28_ < _loc33_.length)
            {
               _loc24_ = _loc33_[_loc28_];
               _loc30_ = _loc17_.length - 1;
               while(_loc30_ >= 0)
               {
                  _loc23_ = _loc17_[_loc30_];
                  if(_loc23_ == _loc24_ || _loc23_ == "ab_" + _loc24_ || _loc23_ == "hb_" + _loc24_ || _loc23_ == "ef_" + _loc24_)
                  {
                     _loc36_.push(_loc23_);
                  }
                  _loc30_--;
               }
               _loc28_++;
            }
            _loc17_ = _loc36_;
            _loc33_ = ActionState.NAMES.concat();
            _loc29_ = _loc33_.length - 1;
            while(_loc29_ >= 0)
            {
               _loc15_ = false;
               _loc37_ = 0;
               while(_loc37_ < _loc17_.length)
               {
                  if(_loc17_[_loc37_] == _loc33_[_loc29_])
                  {
                     _loc15_ = true;
                     break;
                  }
                  _loc37_++;
               }
               if(!_loc15_)
               {
                  _loc33_.splice(_loc29_,1);
               }
               _loc29_--;
            }
         }
         if(param1 == 3024)
         {
            param1;
         }
         _loc32_ = 0;
         while(_loc32_ < _loc33_.length)
         {
            _loc24_ = _loc33_[_loc32_];
            if(_loc17_.indexOf(_loc24_) >= 0)
            {
               try
               {
                  _loc20_ = param2.loaderInfo.applicationDomain.getDefinition(_loc24_) as Class;
               }
               catch(error:Error)
               {
                  _loc20_ = null;
                  remove(_loc17_,_loc24_);
               }
               if(_loc20_)
               {
                  _loc27_ = new _loc20_();
                  _loc27_.name = _loc24_;
                  _resourceMC[param1][_loc24_] = _loc27_;
                  _resourceClass[param1][_loc24_] = _loc20_;
                  _loc12_ = null;
                  if(UserModelManager.getIns().isRole(param1))
                  {
                     if(!_acLink[param1])
                     {
                        _acLink[param1] = [];
                     }
                     if(_acLink[param1].indexOf(_loc24_) == -1)
                     {
                        _acLink[param1].push(_loc24_);
                     }
                     remove(_loc17_,_loc24_);
                  }
                  else
                  {
                     _loc12_ = Texture.drawMcToTextures(_loc27_,false);
                     _resource[param1]["ac"][_loc24_] = _loc12_;
                     remove(_loc17_,_loc24_);
                  }
                  if(param3)
                  {
                     if(_loc17_.indexOf("hb_" + _loc24_) == -1 && _loc24_ != "dead")
                     {
                        _loc35_ = false;
                        if(UserModelManager.getIns().isRole(param1))
                        {
                           _loc35_ = true;
                        }
                        if(param6 == false && !_loc35_)
                        {
                           _loc16_ = Texture.drawMcToTextures(_loc27_,false,-1,1,true,null,false,null,"low");
                        }
                        if(!_loc35_)
                        {
                           _resource[param1]["hb"][_loc24_] = [_loc12_,_loc16_];
                        }
                     }
                  }
                  if(param3)
                  {
                     if(_loc17_.indexOf("ab_" + _loc24_) > -1)
                     {
                        _loc20_ = param2.loaderInfo.applicationDomain.getDefinition("ab_" + _loc24_) as Class;
                        _loc27_ = new _loc20_();
                        _loc27_.name = "ab_" + _loc24_ + "_manid=" + param1;
                        _loc12_ = Texture.drawMcToTextures(_loc27_,false,1,1,true,null,false,null,"low");
                        if(param6 == false)
                        {
                           _loc16_ = Texture.drawMcToTextures(_loc27_,false,-1,1,true,null,false,null,"low");
                        }
                        _resource[param1]["ab"][_loc24_] = [_loc12_,_loc16_];
                        remove(_loc17_,"ab_" + _loc24_);
                     }
                  }
                  if(_loc17_.indexOf("ef_" + _loc24_) >= 0)
                  {
                     _loc20_ = param2.loaderInfo.applicationDomain.getDefinition("ef_" + _loc24_) as Class;
                     _loc27_ = new _loc20_();
                     _loc27_.name = "ef_" + _loc24_ + "_manid=" + param1;
                     _loc12_ = Texture.drawMcToTextures(_loc27_,false);
                     _resource[param1]["ef"][_loc24_] = _loc12_;
                     remove(_loc17_,"ef_" + _loc24_);
                  }
               }
            }
            _loc32_++;
         }
         if(_loc17_.length > 0)
         {
            buildRemain(_loc17_,param2,param1);
         }
         if(param1 == 2001220)
         {
            param1;
         }
         if(_loc26_ && _loc26_.resourceType == 12)
         {
            SimpleTextLog.getIns().log2("==============resvo.resourceType==12","manid=" + param1);
            _loc21_ = _loc26_.getManBattleURL();
            SimpleTextLog.getIns().log2("allLink",_loc17_,"dragurl=" + _loc21_);
            buildActionByDragon(param1,_loc21_);
            param1;
            if(_loc26_.getManBattle2URL() && !param5)
            {
               buildSkillByDragon(param1,_loc26_.getManBattle2URL());
            }
         }
         else if(_loc26_ && _loc26_.resourceType == 13)
         {
            SimpleTextLog.getIns().log2("==============resvo.resourceType==13","manid=" + param1);
            _loc21_ = _loc26_.getManBattleURL();
            if(_loc25_)
            {
               _loc21_ = _loc26_.getSeedURL();
            }
            SimpleTextLog.getIns().log2("allLink",_loc17_,"dragurl=" + _loc21_);
            buildActionByDragon13(param1,_loc21_);
            param1;
            if(_loc26_.getManBattle2URL() && !param5)
            {
               buildSkillByDragon(param1,_loc26_.getManBattle2URL());
            }
         }
         else if(param9 && param9.resourceType == 13)
         {
            SimpleTextLog.getIns().log2("==============skillResvo.resourceType==13","manid=" + param1);
            _loc21_ = param9.getSkillNormalURL();
            SimpleTextLog.getIns().log2("allLink",_loc17_,"dragurl=" + _loc21_);
            param1;
            if(param9.getSkillBattle2URL() && !param5)
            {
               buildSkillByDragon(param1,param9.getSkillBattle2URL());
            }
         }
         if(!SimpleTextLog.Close)
         {
            SimpleTextLog.getIns().log2("花费: ",getTimer() - _loc18_,param1,param2.url);
         }
      }
      
      private function buildActionByDragon(param1:Number, param2:String) : void
      {
         var _loc4_:AssetItem = null;
         var _loc10_:* = undefined;
         var _loc11_:int = 0;
         var _loc7_:AnimationData = null;
         var _loc9_:String = null;
         var _loc3_:int = 0;
         var _loc5_:* = undefined;
         var _loc8_:Armature = DragonResourceManager.getIns().getArmature(param2);
         if(!_loc8_)
         {
            _loc4_ = AssetManager.getIns().getAsset(param2);
            if(_loc4_)
            {
               DragonResourceManager.getIns().buildRes(param2,_loc4_.data);
               _loc8_ = DragonResourceManager.getIns().getArmature(param2);
            }
         }
         var _loc6_:Array = [];
         if(false && !_loc8_)
         {
            _loc10_ = DragonResourceManager.getIns().res;
            throw new Error("manId=" + param1 + " no armature," + "dragurl=" + param2);
         }
         var _loc12_:Texture = Texture.empty(1,1);
         _loc11_ = 0;
         while(_loc11_ < _loc8_.armatureData.animationDataList.length)
         {
            _loc7_ = _loc8_.armatureData.animationDataList[_loc11_];
            _loc9_ = _loc7_.name;
            _loc3_ = Math.round(_loc7_.duration / 33);
            _loc5_ = new Vector.<Texture>();
            while(_loc3_ > 0)
            {
               _loc5_.push(_loc12_);
               _loc3_--;
            }
            if(!_resource[param1]["hb"]["idle"])
            {
               throw new Error(param1 + "-找不到hb_idle");
            }
            _resource[param1]["ac"][_loc9_] = _loc5_;
            if(!_resource[param1]["hb"][_loc9_])
            {
               _resource[param1]["hb"][_loc9_] = _resource[param1]["hb"]["idle"];
            }
            _loc11_++;
         }
         _resource[param1]["armature"] = param2;
         if(_loc8_)
         {
            _loc8_.dispose();
         }
      }
      
      private function buildActionByDragon13(param1:Number, param2:String) : void
      {
         var _loc13_:* = undefined;
         var _loc8_:ArmatureData = null;
         var _loc9_:int = 0;
         var _loc5_:AnimationData = null;
         var _loc6_:String = null;
         var _loc10_:int = 0;
         var _loc4_:* = undefined;
         var _loc12_:NativeFactory = DragonResourceManager.getIns().getFactory(param2);
         var _loc7_:Armature = DragonResourceManager.getIns().getArmature(param2);
         var _loc11_:Array = [];
         if(false && !_loc7_)
         {
            _loc13_ = DragonResourceManager.getIns().res;
            throw new Error("mainid=" + param1 + "dragurl=" + param2);
         }
         var _loc14_:Texture = Texture.empty(1,1);
         var _loc3_:Vector.<AnimationData> = new Vector.<AnimationData>();
         if(param1 == 20001)
         {
            _loc8_ = _loc12_.getSkeletonData("res").getArmatureDataByName("res_attack1_1");
            _loc3_ = _loc3_.concat(_loc8_.animationDataList);
         }
         _loc3_ = _loc3_.concat(_loc7_.armatureData.animationDataList);
         _loc9_ = 0;
         while(_loc9_ < _loc3_.length)
         {
            _loc5_ = _loc3_[_loc9_];
            _loc6_ = _loc5_.name;
            _loc10_ = Math.round(_loc5_.duration / 33);
            _loc4_ = new Vector.<Texture>();
            while(_loc10_ > 0)
            {
               _loc4_.push(_loc14_);
               _loc10_--;
            }
            if(_resource[param1]["hb"]["idle"])
            {
            }
            _resource[param1]["ac"][_loc6_] = _loc4_;
            if(!_resource[param1]["hb"][_loc6_])
            {
               _resource[param1]["hb"][_loc6_] = _resource[param1]["hb"]["idle"];
            }
            _loc9_++;
         }
         _resource[param1]["armature"] = param2;
         if(_loc7_)
         {
            _loc7_.dispose();
         }
      }
      
      private function buildSkillByDragon(param1:int, param2:Object) : void
      {
         var _loc13_:NativeFactory = null;
         var _loc9_:DragonBonesData = null;
         var _loc17_:int = 0;
         var _loc8_:ArmatureData = null;
         var _loc11_:Number = NaN;
         var _loc10_:int = 0;
         var _loc5_:AnimationData = null;
         var _loc6_:String = null;
         var _loc12_:int = 0;
         var _loc3_:* = undefined;
         var _loc7_:ResourceVO = null;
         var _loc4_:String = null;
         _loc13_ = null;
         SimpleTextLog.getIns().log2("buildSkillByDragon=",param1);
         var _loc16_:Texture = Texture.empty(1,1);
         _resource[param1]["actionSkillFactory"] = {};
         var _loc15_:Array = [];
         if(param2)
         {
            for each(_loc4_ in param2)
            {
               _loc13_ = DragonResourceManager.getIns().getFactory(_loc4_);
               _loc9_ = _loc13_.getSkeletonData("res");
               _loc17_ = 0;
               while(_loc17_ < _loc9_.armatureDataList.length)
               {
                  _loc8_ = _loc9_.armatureDataList[_loc17_];
                  _loc11_ = 1;
                  if(_loc4_.indexOf("2006/skill5") != -1)
                  {
                     _loc11_ = 0.7;
                  }
                  _resource[param1]["actionSkillFactory"][_loc8_.name] = {
                     "fac":_loc13_,
                     "scale":_loc11_
                  };
                  _loc10_ = 0;
                  while(_loc10_ < _loc8_.animationDataList.length)
                  {
                     _loc5_ = _loc8_.animationDataList[_loc10_];
                     _loc6_ = _loc5_.name;
                     if(!_resource[param1]["ac"][_loc6_])
                     {
                        _loc12_ = Math.round(_loc5_.duration / 33);
                        _loc3_ = new Vector.<Texture>();
                        while(_loc12_ > 0)
                        {
                           _loc3_.push(_loc16_);
                           _loc12_--;
                        }
                        _resource[param1]["ac"][_loc6_] = _loc3_;
                     }
                     _loc10_++;
                  }
                  _loc17_++;
               }
            }
            if(param1 == 20001)
            {
               _loc7_ = ResourceManager.getIns().getResourcesByID(ManModelManager.getIns().getManById(param1,"role").resourcesId);
               _loc4_ = _loc7_.getManBattleURL();
               _loc13_ = DragonResourceManager.getIns().getFactory(_loc4_);
               _resource[param1]["actionSkillFactory"]["res_attack1_1"] = {
                  "fac":_loc13_,
                  "scale":1
               };
            }
         }
         var _loc14_:Object = _resource[param1]["actionSkillFactory"];
      }
      
      public function buildResourceByManBYStack(param1:Number, param2:AssetItem, param3:Boolean, param4:int = 1, param5:Boolean = false, param6:Boolean = false) : void
      {
         var _loc7_:Array = null;
         var _loc8_:Number = getTimer();
         var _loc9_:Array = ActionState.NAMES;
         if(!_resource[param1])
         {
            _loc7_ = param2.classLink.concat();
            _resource[param1] = new Dictionary();
            _resource[param1]["ac"] = new Dictionary();
            _resource[param1]["ef"] = new Dictionary();
            _resource[param1]["ab"] = new Dictionary();
            _resource[param1]["hb"] = new Dictionary();
         }
      }
      
      private function buildResourceByRole(param1:Number, param2:Number, param3:Equipment, param4:Boolean, param5:UserVO, param6:Boolean, param7:Boolean) : void
      {
         var _loc21_:Boolean = false;
         var _loc32_:int = 0;
         var _loc29_:ResourceVO = null;
         var _loc20_:Boolean = false;
         var _loc8_:FashionVo = null;
         _loc8_ = null;
         var _loc26_:MovieClip = null;
         var _loc9_:* = undefined;
         var _loc30_:int = 0;
         var _loc25_:String = null;
         var _loc33_:Array = null;
         var _loc23_:Boolean = false;
         var _loc13_:* = undefined;
         var _loc35_:int = 0;
         var _loc34_:int = 0;
         var _loc15_:int = 0;
         var _loc22_:int = 0;
         _loc22_ = 0;
         var _loc18_:int = 0;
         var _loc12_:int = 0;
         var _loc27_:int = 0;
         var _loc10_:String = param1 + "_" + param2;
         if(!_resourceRole[_loc10_])
         {
            _resourceRole[_loc10_] = new Dictionary();
            _resourceRole[_loc10_]["ac"] = new Dictionary();
            _resourceRole[_loc10_]["ac_old"] = new Dictionary();
            for(var _loc28_:String in _resource[param2]["ac"])
            {
               _resourceRole[_loc10_]["ac"][_loc28_] = _resource[param2]["ac"][_loc28_].concat();
            }
            _resourceRole[_loc10_]["ac_draw_man"] = new Dictionary();
            _resourceRole[_loc10_]["ef"] = _resource[param2]["ef"];
            _resourceRole[_loc10_]["ab"] = _resource[param2]["ab"];
            _resourceRole[_loc10_]["hb"] = _resource[param2]["hb"];
            if(_resource[param2]["armature"])
            {
               _loc21_ = true;
               _resourceRole[_loc10_]["armature"] = _resource[param2]["armature"];
            }
            if(_resource[param2]["actionSkillFactory"])
            {
               _loc21_ = true;
               _resourceRole[_loc10_]["actionSkillFactory"] = _resource[param2]["actionSkillFactory"];
            }
         }
         _loc21_ = Boolean(_resourceRole[_loc10_]["armature"]);
         var _loc19_:String = "";
         if(param5 && UserModelManager.isProfession2(param5.charID))
         {
            _loc19_ = "Two";
         }
         param5.fashions = [];
         var _loc36_:int = -1;
         var _loc14_:int = 1;
         if(param5.getShowMoEquip())
         {
            if(param3 && param3.armorMo)
            {
               _loc36_ = param3.armorMo.id;
               _loc32_ = ItemVoManager.getIns().getEquipmentVoById(_loc36_).resourceId;
               _loc29_ = ResourceManager.getIns().getResourcesByID(_loc32_);
               _loc14_ = _loc29_.frame;
            }
         }
         else if(param3 && param3.armor)
         {
            _loc36_ = param3.armor.id;
            _loc32_ = ItemVoManager.getIns().getEquipmentVoById(_loc36_).resourceId;
            _loc29_ = ResourceManager.getIns().getResourcesByID(_loc32_);
            _loc14_ = _loc29_.frame;
         }
         if(param3 && param3.suit && param5.getShowFashioin())
         {
            _loc36_ = param3.suit.id;
            _loc32_ = ItemVoManager.getIns().getFashionVoById(_loc36_).resourceId;
            _loc29_ = ResourceManager.getIns().getResourcesByID(_loc32_);
            _loc14_ = _loc29_.frame;
            _loc20_ = true;
         }
         if(param5.equipments["wardRobeArmor" + _loc19_] && param5.equipments["wardRobeArmor" + _loc19_] > 0)
         {
            _loc36_ = int(param5.equipments["wardRobeArmor" + _loc19_]);
            _loc20_ = Boolean(ItemVoManager.getIns().getFashionVoById(_loc36_));
            if(_loc20_)
            {
               _loc32_ = ItemVoManager.getIns().getFashionVoById(_loc36_).resourceId;
            }
            else
            {
               _loc32_ = ItemVoManager.getIns().getEquipmentVoById(_loc36_).resourceId;
            }
            _loc29_ = ResourceManager.getIns().getResourcesByID(_loc32_);
            _loc14_ = _loc29_.frame;
         }
         if(_loc20_)
         {
            _loc8_ = ItemVoManager.getIns().getFashionVoById(_loc36_);
            if(_loc8_ && _loc8_.originalFashionId)
            {
               param5.fashions.push(_loc8_);
            }
         }
         param5.currEqiups = [_loc14_,_loc36_];
         var _loc11_:int = -1;
         var _loc16_:int = 1;
         _loc20_ = false;
         if(param5.getShowMoEquip())
         {
            if(param3 && param3.weaponMo)
            {
               _loc11_ = param3.weaponMo.id;
               _loc32_ = ItemVoManager.getIns().getEquipmentVoById(_loc11_).resourceId;
               _loc29_ = ResourceManager.getIns().getResourcesByID(_loc32_);
               _loc16_ = _loc29_.frame;
            }
            else if(param3 && param3.weaponTwoMo)
            {
               _loc11_ = param3.weaponTwoMo.id;
               _loc32_ = ItemVoManager.getIns().getEquipmentVoById(_loc11_).resourceId;
               _loc29_ = ResourceManager.getIns().getResourcesByID(_loc32_);
               _loc16_ = _loc29_.frame;
            }
         }
         else if(param3 && param3.weapon)
         {
            _loc11_ = param3.weapon.id;
            _loc32_ = ItemVoManager.getIns().getEquipmentVoById(_loc11_).resourceId;
            _loc29_ = ResourceManager.getIns().getResourcesByID(_loc32_);
            _loc16_ = _loc29_.frame;
         }
         else if(param3 && param3.weaponTwo)
         {
            _loc11_ = param3.weaponTwo.id;
            _loc32_ = ItemVoManager.getIns().getEquipmentVoById(_loc11_).resourceId;
            _loc29_ = ResourceManager.getIns().getResourcesByID(_loc32_);
            _loc16_ = _loc29_.frame;
         }
         if(param3 && param3.fashionWeapon && param5.getShowFashioin())
         {
            _loc11_ = param3.fashionWeapon.id;
            _loc32_ = ItemVoManager.getIns().getFashionVoById(_loc11_).resourceId;
            _loc29_ = ResourceManager.getIns().getResourcesByID(_loc32_);
            _loc16_ = _loc29_.frame;
            _loc20_ = true;
         }
         if(param5.equipments["wardRobeWeapon" + _loc19_] && param5.equipments["wardRobeWeapon" + _loc19_] > 0)
         {
            _loc11_ = int(param5.equipments["wardRobeWeapon" + _loc19_]);
            _loc20_ = Boolean(ItemVoManager.getIns().getFashionVoById(_loc11_));
            if(_loc20_)
            {
               _loc32_ = ItemVoManager.getIns().getFashionVoById(_loc11_).resourceId;
            }
            else
            {
               _loc32_ = ItemVoManager.getIns().getEquipmentVoById(_loc11_).resourceId;
            }
            _loc29_ = ResourceManager.getIns().getResourcesByID(_loc32_);
            _loc16_ = _loc29_.frame;
         }
         if(_loc20_)
         {
            _loc8_ = ItemVoManager.getIns().getFashionVoById(_loc11_);
            if(_loc8_ && _loc8_.originalFashionId)
            {
               param5.fashions.push(_loc8_);
            }
         }
         param5.currEqiups.push(_loc16_,_loc11_);
         if(param3 && param3.yfFrame == _loc14_ && param3.wqFrame == _loc16_ && param7 == false)
         {
            SimpleTextLog.getIns().logErr("eq check=",param3.yfFrame,_loc14_,param3.wqFrame,_loc16_,param5.name,_loc11_,_loc36_);
            return;
         }
         if(1 == _loc14_ && 1 == _loc16_)
         {
         }
         if(_loc21_)
         {
         }
         var _loc31_:Number = getTimer();
         var _loc17_:Array = _acLink[param2];
         if(!_loc17_)
         {
            return;
         }
         var _loc24_:Array = ActionState.NAMES;
         if(param4)
         {
            _loc24_ = ["idle","walk"];
         }
         if(param5.charID == 2010)
         {
            _loc24_ = _loc24_.concat(ActionState.NAMES_BLM2);
            _loc17_ = _loc17_.concat(ActionState.NAMES_BLM2);
         }
         else if(param5.charID == 2006)
         {
            _loc24_ = _loc24_.concat(ActionState.NAMES_WK2);
            _loc17_ = _loc17_.concat(ActionState.NAMES_WK2);
         }
         if(param5.isPk)
         {
         }
         _loc30_ = 0;
         for(; _loc30_ < _loc24_.length; _loc30_++)
         {
            _loc25_ = _loc24_[_loc30_];
            if(_loc17_.indexOf(_loc25_) >= 0)
            {
               if(_loc21_)
               {
                  _loc26_ = _resourceMC[param2][_loc25_];
                  if(!_loc26_)
                  {
                     continue;
                  }
                  _loc33_ = _loc26_.draw_man || [];
                  SimpleTextLog.getIns().log2("1m.draw_man-" + _loc25_ + "=",_loc33_);
                  if(_loc33_.length == 0 && _resourceRole[_loc10_]["ac_draw_man"][_loc25_])
                  {
                     continue;
                  }
                  SimpleTextLog.getIns().log2("2m.draw_man-" + _loc25_);
               }
               _loc26_ = new _resourceClass[param2][_loc25_]();
               _loc26_.name = _loc25_ + "_manid=" + param2;
               _loc26_.gotoAndStop(1);
               changeFashion(_loc26_,_loc14_,"fashion_yf");
               changeFashion(_loc26_,_loc16_,"fashion_wq");
               if(_loc21_)
               {
                  _loc23_ = Boolean(_resourceRole[_loc10_]["ac_draw_man"][_loc25_]);
                  SimpleTextLog.getIns().log2("原来有画过完整的=" + _loc23_,_loc25_);
               }
               _loc13_ = _resourceRole[_loc10_]["ac"][_loc25_];
               if(_loc13_)
               {
                  _loc9_ = Texture.drawMcToTextures(_loc26_,false,1,1,false,_loc23_ ? _loc26_.draw_man : null,param2 == 2002 || param2 == 2003 || param2 == 2004 || param2 == 2008 || param2 == 2009 || param2 == 2011 || param2 == 2012 || param2 == 2013 || param2 == 2014 || param2 == 2015 || param2 == 20011,{
                     "charId":param2,
                     "part":{
                        "fashion_yf1":[2004,2009,2014,2015,20011],
                        "fashion_yf3":[2002,2012,2003,2008,2013],
                        "fashion_yf4":[2002,2012,2003,2008,2013],
                        "fashion_yf6":[2002,2012,2004,2009,2014],
                        "fashion_yf7":[2004,2009,2014],
                        "fashion_yf8":[2003,2008,2013,2011]
                     }
                  },"high",GlobalData.getOpenBitmapReal(param2));
                  if(_loc23_)
                  {
                     SimpleTextLog.getIns().log2("ts.length=" + _loc9_.length,"ots.length=" + _loc13_.length);
                     _loc35_ = 0;
                     while(_loc35_ < _loc26_.draw_man.length)
                     {
                        if(typeof _loc26_.draw_man[_loc35_] == "object")
                        {
                           _loc34_ = 0;
                           while(_loc34_ < _loc26_.draw_man[_loc35_].length)
                           {
                              _loc15_ = _loc26_.draw_man[_loc35_][0] - 1;
                              _loc22_ = _loc26_.draw_man[_loc35_][_loc34_] - 1;
                              _loc13_[_loc22_] = _loc9_[_loc15_];
                              _loc34_++;
                           }
                        }
                        else if(typeof _loc26_.draw_man[_loc35_] == "number")
                        {
                           _loc18_ = _loc22_ = _loc26_.draw_man[_loc35_] - 1;
                           if(_loc22_ < 0)
                           {
                              _loc12_ = _loc35_ + _loc26_.draw_man[_loc35_];
                              _loc18_ = int(_loc26_.draw_man[_loc12_]);
                              _loc22_ = _loc18_ - _loc26_.draw_man[_loc35_];
                              _loc22_--;
                              _loc18_--;
                           }
                           _loc13_[_loc22_] = _loc9_[_loc18_];
                        }
                        _loc35_++;
                     }
                  }
                  else
                  {
                     _loc13_.splice(0,_loc13_.length);
                     _loc27_ = 0;
                     while(_loc27_ < _loc9_.length)
                     {
                        _loc13_.push(_loc9_[_loc27_]);
                        _loc27_++;
                     }
                  }
               }
               else
               {
                  _loc9_ = Texture.drawMcToTextures(_loc26_,false,1,1,false,null,param2 == 2002 || param2 == 2003 || param2 == 2004 || param2 == 2008 || param2 == 2009 || param2 == 2011 || param2 == 2012 || param2 == 2013 || param2 == 2014 || param2 == 2015 || param2 == 20011,{
                     "charId":param2,
                     "part":{
                        "fashion_yf1":[2004,2009,2014,2015,20011],
                        "fashion_yf3":[2002,2012,2003,2008,2013],
                        "fashion_yf4":[2002,2012,2003,2008,2013],
                        "fashion_yf6":[2002,2012,2004,2009,2014],
                        "fashion_yf7":[2004,2009,2014],
                        "fashion_yf8":[2003,2008,2013,2011]
                     }
                  },"high",GlobalData.getOpenBitmapReal(param2));
                  _resourceRole[_loc10_]["ac"][_loc25_] = _loc9_;
               }
               _resourceRole[_loc10_]["ac_draw_man"][_loc25_] = _loc9_;
            }
         }
         if(param3)
         {
            param3.yfFrame = _loc14_;
            param3.wqFrame = _loc16_;
         }
      }
      
      private function okFash(param1:Vector.<Texture>, param2:Vector.<Texture>) : void
      {
         var _loc3_:int = 0;
         param1.splice(0,param1.length);
         _loc3_ = 0;
         while(_loc3_ < param2.length)
         {
            param1.push(param2[_loc3_]);
            _loc3_++;
         }
      }
      
      public function buildResourceByRoleInBattle(param1:Number, param2:Number, param3:Equipment, param4:UserVO, param5:Boolean, param6:Boolean) : void
      {
         var _loc9_:int = 0;
         var _loc10_:ResourceVO = null;
         var _loc11_:String = null;
         var _loc8_:AssetItem = null;
         if(!_resource[param2])
         {
            _loc9_ = ManModelManager.getIns().getManById(param2,null).resourcesId;
            _loc10_ = ResourceManager.getIns().getResourcesByID(_loc9_);
            _loc11_ = _loc10_.getManBattleURLS()[0];
            _loc8_ = AssetManager.getIns().getAsset(_loc11_);
            buildResourceByMan(param2,_loc8_,true);
         }
         var _loc7_:Boolean = false;
         if(param4 && param4.isTown)
         {
            _loc7_ = true;
         }
         if(GameData.uid == 100 && false && param2 == 2003)
         {
            buildResourceByRole(param1,param2,param3,_loc7_,param4,param5,param6);
         }
         else
         {
            buildResourceByRole(param1,param2,param3,_loc7_,param4,param5,param6);
         }
      }
      
      public function buildResourceByRoleInBattleShowFashion(param1:Number, param2:Number, param3:Equipment, param4:UserVO, param5:Boolean, param6:Boolean) : void
      {
         var _loc11_:int = 0;
         var _loc9_:ResourceVO = null;
         var _loc15_:Boolean = false;
         var _loc8_:FashionVo = null;
         _loc8_ = null;
         var _loc7_:Boolean = false;
         if(param4 && param4.isTown)
         {
            _loc7_ = true;
         }
         var _loc14_:String = "";
         if(param4 && UserModelManager.isProfession2(param4.charID))
         {
            _loc14_ = "Two";
         }
         param4.fashions = [];
         var _loc16_:int = -1;
         var _loc12_:int = 1;
         if(param4.getShowMoEquip())
         {
            if(param3 && param3.armorMo)
            {
               _loc16_ = param3.armorMo.id;
               _loc11_ = ItemVoManager.getIns().getEquipmentVoById(_loc16_).resourceId;
               _loc9_ = ResourceManager.getIns().getResourcesByID(_loc11_);
               _loc12_ = _loc9_.frame;
            }
         }
         else if(param3 && param3.armor)
         {
            _loc16_ = param3.armor.id;
            _loc11_ = ItemVoManager.getIns().getEquipmentVoById(_loc16_).resourceId;
            _loc9_ = ResourceManager.getIns().getResourcesByID(_loc11_);
            _loc12_ = _loc9_.frame;
         }
         if(param3 && param3.suit && param4.getShowFashioin())
         {
            _loc16_ = param3.suit.id;
            _loc11_ = ItemVoManager.getIns().getFashionVoById(_loc16_).resourceId;
            _loc9_ = ResourceManager.getIns().getResourcesByID(_loc11_);
            _loc12_ = _loc9_.frame;
            _loc15_ = true;
         }
         if(param4.equipments["wardRobeArmor" + _loc14_] && param4.equipments["wardRobeArmor" + _loc14_] > 0)
         {
            _loc16_ = int(param4.equipments["wardRobeArmor" + _loc14_]);
            _loc15_ = Boolean(ItemVoManager.getIns().getFashionVoById(_loc16_));
            if(_loc15_)
            {
               _loc11_ = ItemVoManager.getIns().getFashionVoById(_loc16_).resourceId;
            }
            else
            {
               _loc11_ = ItemVoManager.getIns().getEquipmentVoById(_loc16_).resourceId;
            }
            _loc9_ = ResourceManager.getIns().getResourcesByID(_loc11_);
            _loc12_ = _loc9_.frame;
         }
         if(_loc15_)
         {
            _loc8_ = ItemVoManager.getIns().getFashionVoById(_loc16_);
            if(_loc8_ && _loc8_.originalFashionId)
            {
               param4.fashions.push(_loc8_);
            }
         }
         var _loc10_:int = -1;
         var _loc13_:int = 1;
         _loc15_ = false;
         if(param4.getShowMoEquip())
         {
            if(param3 && param3.weaponMo)
            {
               _loc10_ = param3.weaponMo.id;
               _loc11_ = ItemVoManager.getIns().getEquipmentVoById(_loc10_).resourceId;
               _loc9_ = ResourceManager.getIns().getResourcesByID(_loc11_);
               _loc13_ = _loc9_.frame;
            }
            else if(param3 && param3.weaponTwoMo)
            {
               _loc10_ = param3.weaponTwoMo.id;
               _loc11_ = ItemVoManager.getIns().getEquipmentVoById(_loc10_).resourceId;
               _loc9_ = ResourceManager.getIns().getResourcesByID(_loc11_);
               _loc13_ = _loc9_.frame;
            }
         }
         else if(param3 && param3.weapon)
         {
            _loc10_ = param3.weapon.id;
            _loc11_ = ItemVoManager.getIns().getEquipmentVoById(_loc10_).resourceId;
            _loc9_ = ResourceManager.getIns().getResourcesByID(_loc11_);
            _loc13_ = _loc9_.frame;
         }
         else if(param3 && param3.weaponTwo)
         {
            _loc10_ = param3.weaponTwo.id;
            _loc11_ = ItemVoManager.getIns().getEquipmentVoById(_loc10_).resourceId;
            _loc9_ = ResourceManager.getIns().getResourcesByID(_loc11_);
            _loc13_ = _loc9_.frame;
         }
         if(param3 && param3.fashionWeapon && param4.getShowFashioin())
         {
            _loc10_ = param3.fashionWeapon.id;
            _loc11_ = ItemVoManager.getIns().getFashionVoById(_loc10_).resourceId;
            _loc9_ = ResourceManager.getIns().getResourcesByID(_loc11_);
            _loc13_ = _loc9_.frame;
            _loc15_ = true;
         }
         if(param4.equipments["wardRobeWeapon" + _loc14_] && param4.equipments["wardRobeWeapon" + _loc14_] > 0)
         {
            _loc10_ = int(param4.equipments["wardRobeWeapon" + _loc14_]);
            _loc15_ = Boolean(ItemVoManager.getIns().getFashionVoById(_loc10_));
            if(_loc15_)
            {
               _loc11_ = ItemVoManager.getIns().getFashionVoById(_loc10_).resourceId;
            }
            else
            {
               _loc11_ = ItemVoManager.getIns().getEquipmentVoById(_loc10_).resourceId;
            }
            _loc9_ = ResourceManager.getIns().getResourcesByID(_loc11_);
            _loc13_ = _loc9_.frame;
         }
         if(_loc15_)
         {
            _loc8_ = ItemVoManager.getIns().getFashionVoById(_loc10_);
            if(_loc8_ && _loc8_.originalFashionId)
            {
               param4.fashions.push(_loc8_);
            }
         }
      }
      
      public function buildResourceByRoleInTown(param1:Number, param2:Number, param3:Equipment, param4:UserVO) : void
      {
         buildResourceByRole(param1,param2,param3,true,param4,false,false);
      }
      
      private function changeFashion(param1:MovieClip, param2:int, param3:String) : void
      {
         var _loc6_:int = 0;
         var _loc4_:MovieClip = null;
         var _loc5_:String = null;
         if(param3 == "fashion_cb")
         {
            return;
         }
         _loc6_ = 0;
         while(_loc6_ < param1.numChildren)
         {
            _loc4_ = param1.getChildAt(_loc6_) as MovieClip;
            if(_loc4_)
            {
               _loc5_ = getQualifiedClassName(_loc4_);
               if(_loc5_.indexOf(param3) > -1)
               {
                  _loc4_.gotoAndStop(param2);
               }
            }
            _loc6_++;
         }
      }
      
      private function buildRemain(param1:Array, param2:AssetItem, param3:int) : void
      {
         var _loc6_:Class = null;
         var _loc8_:MovieClip = null;
         var _loc5_:* = undefined;
         var _loc4_:* = undefined;
         var _loc9_:int = 0;
         var _loc7_:String = null;
         _loc9_ = 0;
         for(; _loc9_ < param1.length; _loc9_++)
         {
            _loc7_ = param1[_loc9_];
            if(!(_loc7_ == "ride" || _loc7_.indexOf("fashion_") > -1))
            {
               if(!(_loc7_.indexOf("mc_") > -1 || _loc7_.indexOf("cb_") > -1))
               {
                  _loc6_ = param2.loaderInfo.applicationDomain.getDefinition(_loc7_) as Class;
                  try
                  {
                     _loc8_ = new _loc6_();
                  }
                  catch(error:Error)
                  {
                     _resource[param3]["ac"][_loc7_] = _loc6_;
                     continue;
                  }
                  if(param3 == 2010 || param3 == 2006)
                  {
                     _resourceClass[param3][_loc7_] = _loc6_;
                  }
                  _loc8_.name = _loc7_ + "_manid=" + param3;
                  if(_loc7_.indexOf("ab_") == 0 || _loc7_.indexOf("hb_") == 0)
                  {
                     _loc5_ = Texture.drawMcToTextures(_loc8_,false,1,1,true,null,false,null,"low");
                  }
                  else
                  {
                     _loc5_ = Texture.drawMcToTextures(_loc8_,false);
                  }
                  if(_loc7_.indexOf("ab_") == 0)
                  {
                     _resourceMC[param3][_loc7_] = _loc8_;
                     _loc7_ = _loc7_.substr(3);
                     _loc4_ = Texture.drawMcToTextures(_loc8_,false,-1,1,true,null,false,null,"low");
                     _resource[param3]["ab"][_loc7_] = [_loc5_,_loc4_];
                  }
                  else if(_loc7_.indexOf("hb_") == 0)
                  {
                     _loc7_ = _loc7_.substr(3);
                     _loc4_ = Texture.drawMcToTextures(_loc8_,false,-1,1,true,null,false,null,"low");
                     _resource[param3]["hb"][_loc7_] = [_loc5_,_loc4_];
                     Debug.log("------------------------------------------","hb_" + _loc7_,"manid=" + param3);
                  }
                  else
                  {
                     _resource[param3]["ac"][_loc7_] = _loc5_;
                  }
               }
            }
         }
      }
      
      private function remove(param1:Array, param2:String) : *
      {
         var _loc3_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            if(param1[_loc3_] == param2)
            {
               return param1.splice(_loc3_,1);
            }
            _loc3_++;
         }
         return -1;
      }
      
      public function getResourceByManId(param1:int) : Dictionary
      {
         return _resource[param1];
      }
      
      public function getRideByCharIdDragon(param1:String, param2:UserVO, param3:WearComponent) : Armature
      {
         var _loc4_:NativeFactory = DragonResourceManager.getIns().getFactory(param1);
         var _loc5_:Armature = DragonResourceManager.getIns().getArmature(param1,"ride");
         wear(_loc5_,param2.equipments,param2,null,param3);
         return _loc5_;
      }
      
      public function getRideByCharId(param1:int, param2:AssetItem, param3:String, param4:UserVO) : MovieClip
      {
         var _loc9_:MovieClip = null;
         var _loc5_:Class = null;
         var _loc8_:int = 0;
         var _loc6_:ResourceVO = null;
         var _loc13_:Boolean = false;
         if(_ride[param1])
         {
            _loc9_ = _ride[param1];
         }
         else
         {
            try
            {
               _loc5_ = param2.loaderInfo.applicationDomain.getDefinition("ride") as Class;
               _loc9_ = new _loc5_();
               _loc9_.name = "ride_manid=" + param1;
            }
            catch(error:Error)
            {
               return null;
            }
         }
         var _loc12_:String = "";
         if(UserModelManager.isProfession2(param4.charID))
         {
            _loc12_ = "Two";
         }
         var _loc15_:Equipment = param4.equipments;
         var _loc14_:int = -1;
         var _loc10_:int = 1;
         if(param4.getShowMoEquip())
         {
            if(_loc15_ && _loc15_.armorMo)
            {
               _loc14_ = _loc15_.armorMo.id;
               _loc8_ = ItemVoManager.getIns().getEquipmentVoById(_loc14_).resourceId;
               _loc6_ = ResourceManager.getIns().getResourcesByID(_loc8_);
               _loc10_ = _loc6_.frame;
            }
         }
         else if(_loc15_ && _loc15_.armor)
         {
            _loc14_ = _loc15_.armor.id;
            _loc8_ = ItemVoManager.getIns().getEquipmentVoById(_loc14_).resourceId;
            _loc6_ = ResourceManager.getIns().getResourcesByID(_loc8_);
            _loc10_ = _loc6_.frame;
         }
         if(_loc15_ && _loc15_.suit && param4.getShowFashioin())
         {
            _loc14_ = _loc15_.suit.id;
            _loc8_ = ItemVoManager.getIns().getFashionVoById(_loc14_).resourceId;
            _loc6_ = ResourceManager.getIns().getResourcesByID(_loc8_);
            _loc10_ = _loc6_.frame;
         }
         if(param4.equipments["wardRobeArmor" + _loc12_] && param4.equipments["wardRobeArmor" + _loc12_] > 0)
         {
            _loc14_ = int(param4.equipments["wardRobeArmor" + _loc12_]);
            _loc13_ = Boolean(ItemVoManager.getIns().getFashionVoById(_loc14_));
            if(_loc13_)
            {
               _loc8_ = ItemVoManager.getIns().getFashionVoById(_loc14_).resourceId;
            }
            else
            {
               _loc8_ = ItemVoManager.getIns().getEquipmentVoById(_loc14_).resourceId;
            }
            _loc6_ = ResourceManager.getIns().getResourcesByID(_loc8_);
            _loc10_ = _loc6_.frame;
         }
         param4.currEqiups = [_loc10_,_loc14_];
         var _loc7_:int = -1;
         var _loc11_:int = 1;
         if(param4.getShowMoEquip())
         {
            if(_loc15_ && _loc15_.weaponMo)
            {
               _loc7_ = _loc15_.weaponMo.id;
               _loc8_ = ItemVoManager.getIns().getEquipmentVoById(_loc7_).resourceId;
               _loc6_ = ResourceManager.getIns().getResourcesByID(_loc8_);
               _loc11_ = _loc6_.frame;
            }
            else if(_loc15_ && _loc15_.weaponTwoMo)
            {
               _loc7_ = _loc15_.weaponTwoMo.id;
               _loc8_ = ItemVoManager.getIns().getEquipmentVoById(_loc7_).resourceId;
               _loc6_ = ResourceManager.getIns().getResourcesByID(_loc8_);
               _loc11_ = _loc6_.frame;
            }
         }
         else if(_loc15_ && _loc15_.weapon)
         {
            _loc7_ = _loc15_.weapon.id;
            _loc8_ = ItemVoManager.getIns().getEquipmentVoById(_loc7_).resourceId;
            _loc6_ = ResourceManager.getIns().getResourcesByID(_loc8_);
            _loc11_ = _loc6_.frame;
         }
         else if(_loc15_ && _loc15_.weaponTwo)
         {
            _loc7_ = _loc15_.weaponTwo.id;
            _loc8_ = ItemVoManager.getIns().getEquipmentVoById(_loc7_).resourceId;
            _loc6_ = ResourceManager.getIns().getResourcesByID(_loc8_);
            _loc11_ = _loc6_.frame;
         }
         if(_loc15_ && _loc15_.fashionWeapon && param4.getShowFashioin())
         {
            _loc7_ = _loc15_.fashionWeapon.id;
            _loc8_ = ItemVoManager.getIns().getFashionVoById(_loc7_).resourceId;
            _loc6_ = ResourceManager.getIns().getResourcesByID(_loc8_);
            _loc11_ = _loc6_.frame;
         }
         if(param4.equipments["wardRobeWeapon" + _loc12_] && param4.equipments["wardRobeWeapon" + _loc12_] > 0)
         {
            _loc7_ = int(param4.equipments["wardRobeWeapon" + _loc12_]);
            _loc13_ = Boolean(ItemVoManager.getIns().getFashionVoById(_loc7_));
            if(_loc13_)
            {
               _loc8_ = ItemVoManager.getIns().getFashionVoById(_loc7_).resourceId;
            }
            else
            {
               _loc8_ = ItemVoManager.getIns().getEquipmentVoById(_loc7_).resourceId;
            }
            _loc6_ = ResourceManager.getIns().getResourcesByID(_loc8_);
            _loc11_ = _loc6_.frame;
         }
         param4.currEqiups.push(_loc11_,_loc7_);
         changeFashion(_loc9_,_loc10_,"fashion_yf");
         changeFashion(_loc9_,_loc11_,"fashion_wq");
         changeFashion(_loc9_,-1,"fashion_cb");
         _ride[param1] = _loc9_;
         return _loc9_;
      }
      
      public function getResourceByRoleId(param1:Number, param2:int) : Dictionary
      {
         var _loc3_:String = param1 + "_" + param2;
         return _resourceRole[_loc3_];
      }
      
      public function destroy() : void
      {
         if(UserModelManager.getIns().playerUserVo1)
         {
            UserModelManager.getIns().playerUserVo1.ReSetEq();
         }
         if(UserModelManager.getIns().playerUserVo2)
         {
            UserModelManager.getIns().playerUserVo2.ReSetEq();
         }
         removeM();
         removeR();
         DragonResourceManager.getIns().destroy();
      }
      
      public function clearMonster(param1:int) : void
      {
         var _loc7_:* = undefined;
         var _loc2_:Object = null;
         var _loc8_:int = 0;
         for(var _loc6_:String in _resource)
         {
            if(_loc6_ == param1.toString())
            {
               _loc7_ = _resource[_loc6_];
               for(var _loc3_:String in _loc7_)
               {
                  _loc2_ = _loc7_[_loc3_];
                  if(_loc3_ == "ac" || _loc3_ == "ef")
                  {
                     for each(var _loc5_:Object in _loc2_)
                     {
                        replace(_loc5_);
                     }
                  }
                  else
                  {
                     for each(var _loc4_:Object in _loc2_)
                     {
                        _loc8_ = 0;
                        while(_loc8_ < _loc4_.length)
                        {
                           replace(_loc4_[_loc8_]);
                           _loc8_++;
                        }
                     }
                  }
               }
               delete _resource[_loc6_];
               delete _resourceClass[_loc6_];
               delete _resourceMC[_loc6_];
            }
         }
      }
      
      private function removeR() : void
      {
         var _loc6_:* = undefined;
         var _loc1_:Object = null;
         var _loc7_:int = 0;
         for(var _loc5_:String in _resourceRole)
         {
            _loc6_ = _resourceRole[_loc5_];
            for(var _loc2_:String in _loc6_)
            {
               _loc1_ = _loc6_[_loc2_];
               if(_loc2_ == "ac" || _loc2_ == "ef")
               {
                  for each(var _loc4_:Object in _loc1_)
                  {
                     dispose(_loc4_);
                  }
               }
               else
               {
                  for each(var _loc3_:Object in _loc1_)
                  {
                     if(_loc2_ == "actionSkillFactory")
                     {
                        if(_loc3_.fac)
                        {
                           _loc3_.fac.dispose();
                        }
                     }
                     else
                     {
                        _loc7_ = 0;
                        while(_loc7_ < _loc3_.length)
                        {
                           dispose(_loc3_[_loc7_]);
                           _loc7_++;
                        }
                     }
                  }
               }
            }
            delete _resourceRole[_loc5_];
         }
      }
      
      public function removeM() : void
      {
         var _loc3_:* = null;
         var _loc7_:* = undefined;
         var _loc1_:Object = null;
         var _loc8_:int = 0;
         for(var _loc6_:String in _resource)
         {
            _loc7_ = _resource[_loc6_];
            for(var _loc2_:String in _loc7_)
            {
               _loc1_ = _loc7_[_loc2_];
               if(_loc2_ == "ac" || _loc2_ == "ef")
               {
                  for each(var _loc5_:Object in _loc1_)
                  {
                     dispose(_loc5_);
                  }
               }
               else if(_loc2_ == "actionSkillFactory")
               {
                  for each(_loc3_ in _loc1_)
                  {
                     if(_loc3_.fac)
                     {
                        _loc3_.fac.dispose();
                     }
                  }
               }
               else
               {
                  for each(var _loc4_:Object in _loc1_)
                  {
                     if(_loc4_ && _loc4_.hasOwnProperty("length"))
                     {
                        _loc8_ = 0;
                        while(_loc8_ < _loc4_.length)
                        {
                           dispose(_loc4_[_loc8_]);
                           _loc8_++;
                        }
                     }
                  }
               }
            }
            _loc7_.deleted = true;
            delete _resource[_loc6_];
            delete _resourceClass[_loc6_];
            delete _resourceMC[_loc6_];
         }
      }
      
      public function disposeMonster(param1:int) : void
      {
         var _loc7_:* = undefined;
         var _loc2_:Object = null;
         var _loc8_:int = 0;
         for(var _loc6_:String in _resource)
         {
            if(_loc6_ == param1.toString() || param1 == -1)
            {
               if(!UserModelManager.getIns().isRoleAndMonster(int(_loc6_)))
               {
                  _loc7_ = _resource[_loc6_];
                  for(var _loc3_:String in _loc7_)
                  {
                     _loc2_ = _loc7_[_loc3_];
                     if(_loc3_ == "ac" || _loc3_ == "ef")
                     {
                        for each(var _loc5_:Object in _loc2_)
                        {
                           dispose(_loc5_);
                        }
                     }
                     else
                     {
                        for each(var _loc4_:Object in _loc2_)
                        {
                           if(_loc4_)
                           {
                              _loc8_ = 0;
                              while(_loc8_ < _loc4_.length)
                              {
                                 dispose(_loc4_[_loc8_]);
                                 _loc8_++;
                              }
                           }
                        }
                     }
                  }
                  _loc7_.deleted = true;
                  if(_resource[_loc6_]["armature"])
                  {
                     DragonResourceManager.getIns().dispose(_resource[_loc6_]["armature"]);
                  }
                  delete _resource[_loc6_];
               }
            }
         }
      }
      
      private function replace(param1:Object) : void
      {
         var _loc3_:int = 0;
         var _loc2_:Vector.<Texture> = param1 as Vector.<Texture>;
         if(!_loc2_)
         {
            return;
         }
         _loc3_ = 0;
         while(_loc3_ < _loc2_.length)
         {
            _loc2_[_loc3_].bd = BitmapUtils.EMPTY;
            _loc3_++;
         }
      }
      
      private function dispose(param1:Object) : void
      {
         var _loc3_:int = 0;
         var _loc2_:Vector.<Texture> = param1 as Vector.<Texture>;
         if(!_loc2_)
         {
            return;
         }
         _loc3_ = 0;
         while(_loc3_ < _loc2_.length)
         {
            _loc2_[_loc3_].bd.dispose();
            _loc3_++;
         }
         _loc2_.length = 0;
      }
      
      public function getMcByCharId(param1:int, param2:String) : MovieClip
      {
         return _resourceMC[param1][param2];
      }
      
      public function setMcByCharId(param1:int, param2:String, param3:MovieClip) : void
      {
         _resourceMC[param1][param2] = param3;
      }
      
      public function destroyByPkBoss(param1:String) : void
      {
         var _loc7_:* = undefined;
         var _loc2_:Object = null;
         var _loc8_:int = 0;
         removeM();
         for(var _loc6_:String in _resourceRole)
         {
            if(_loc6_ != param1)
            {
               _loc7_ = _resourceRole[_loc6_];
               for(var _loc3_:String in _loc7_)
               {
                  _loc2_ = _loc7_[_loc3_];
                  if(_loc3_ == "ac" || _loc3_ == "ef")
                  {
                     for each(var _loc5_:Object in _loc2_)
                     {
                        dispose(_loc5_);
                     }
                  }
                  else
                  {
                     for each(var _loc4_:Object in _loc2_)
                     {
                        _loc8_ = 0;
                        while(_loc8_ < _loc4_.length)
                        {
                           dispose(_loc4_[_loc8_]);
                           _loc8_++;
                        }
                     }
                  }
               }
               delete _resourceRole[_loc6_];
            }
         }
      }
      
      public function destroy2() : void
      {
         var _loc15_:String = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc7_:* = undefined;
         var _loc1_:Object = null;
         var _loc5_:Object = null;
         _loc7_ = undefined;
         _loc1_ = null;
         var _loc11_:* = null;
         var _loc8_:int = 0;
         var _loc14_:String = UserModelManager.getIns().getCurretPlayerInfo().userId + "_" + UserModelManager.getIns().playerUserVo1.charID;
         var _loc12_:String = UserModelManager.getIns().getCurretPlayerInfo().userId + "_" + (UserModelManager.getIns().playerUserVo1.charID + 5);
         var _loc13_:String = UserModelManager.getIns().getCurretPlayerInfo().userId + "_" + (UserModelManager.getIns().playerUserVo1.charID + 10);
         if(UserModelManager.getIns().getCurretPlayerInfo().pMode == 2)
         {
            _loc15_ = UserModelManager.getIns().getCurretPlayerInfo().userId + "_" + UserModelManager.getIns().playerUserVo2.charID;
            _loc3_ = UserModelManager.getIns().getCurretPlayerInfo().userId + "_" + (UserModelManager.getIns().playerUserVo2.charID + 5);
            _loc4_ = UserModelManager.getIns().getCurretPlayerInfo().userId + "_" + (UserModelManager.getIns().playerUserVo2.charID + 10);
         }
         for(var _loc6_:String in _resourceRole)
         {
            if(!(_loc6_ == _loc14_ || _loc6_ == _loc15_ || _loc6_ == _loc12_ || _loc6_ == _loc3_ || _loc6_ == _loc13_ || _loc6_ == _loc4_))
            {
               _loc7_ = _resourceRole[_loc6_];
               for(var _loc9_:String in _loc7_)
               {
                  _loc1_ = _loc7_[_loc9_];
                  if(_loc9_ == "ac")
                  {
                     for(var _loc10_:String in _loc1_)
                     {
                        if(_loc10_ == "idle" || _loc10_ == "walk")
                        {
                           _loc5_ = _loc1_[_loc10_];
                           dispose(_loc5_);
                        }
                     }
                  }
               }
               delete _resourceRole[_loc6_];
            }
         }
         _loc14_ = UserModelManager.getIns().playerUserVo1.charID.toString();
         _loc12_ = UserModelManager.getIns().playerUserVo1.charID + 5 + "";
         _loc13_ = UserModelManager.getIns().playerUserVo1.charID + 10 + "";
         if(UserModelManager.getIns().getCurretPlayerInfo().pMode == 2)
         {
            _loc15_ = "" + UserModelManager.getIns().playerUserVo2.charID;
            _loc3_ = UserModelManager.getIns().playerUserVo2.charID + 5 + "";
            _loc4_ = UserModelManager.getIns().playerUserVo2.charID + 10 + "";
         }
         for(_loc6_ in _resource)
         {
            if(!(_loc6_ == _loc14_ || _loc6_ == _loc15_ || _loc6_ == _loc12_ || _loc6_ == _loc3_ || _loc6_ == _loc13_ || _loc6_ == _loc4_))
            {
               if(UserModelManager.getIns().isRole(int(_loc6_)))
               {
                  _loc7_ = _resource[_loc6_];
                  for(_loc9_ in _loc7_)
                  {
                     _loc1_ = _loc7_[_loc9_];
                     if(_loc9_ == "ac" || _loc9_ == "ef")
                     {
                        for each(_loc5_ in _loc1_)
                        {
                           dispose(_loc5_);
                        }
                     }
                     else if(_loc9_ == "actionSkillFactory")
                     {
                        for each(_loc11_ in _loc1_)
                        {
                           if(_loc11_.fac)
                           {
                              _loc11_.fac.dispose();
                           }
                        }
                        _loc7_[_loc9_] = null;
                     }
                     else
                     {
                        for each(var _loc2_:Object in _loc1_)
                        {
                           _loc2_ ||= [];
                           _loc8_ = 0;
                           while(_loc8_ < _loc2_.length)
                           {
                              dispose(_loc2_[_loc8_]);
                              _loc8_++;
                           }
                        }
                     }
                  }
                  if(_loc7_["armature"])
                  {
                     DragonResourceManager.getIns().dispose(_loc7_["armature"]);
                  }
                  delete _loc7_["armature"];
                  delete _resource[_loc6_];
               }
            }
         }
      }
      
      public function wear(param1:Armature, param2:Object, param3:UserVO, param4:Entity, param5:WearComponent = null) : void
      {
         var _loc9_:String = null;
         var _loc15_:String = null;
         var _loc14_:int = 0;
         var _loc10_:ResourceVO = null;
         var _loc19_:Boolean = false;
         var _loc7_:FashionVo = null;
         _loc7_ = null;
         var _loc11_:int = 0;
         var _loc6_:Bone = null;
         var _loc12_:WearComponent = null;
         var _loc18_:String = "";
         if(UserModelManager.isProfession2(param3.charID))
         {
            _loc18_ = "Two";
         }
         param3.fashions = [];
         var _loc20_:int = -1;
         var _loc16_:int = 1;
         if(param3.getShowMoEquip())
         {
            if(param2 && param2.armorMo)
            {
               _loc20_ = int(param2.armorMo.id);
               _loc14_ = ItemVoManager.getIns().getEquipmentVoById(_loc20_).resourceId;
               _loc10_ = ResourceManager.getIns().getResourcesByID(_loc14_);
               _loc16_ = _loc10_.frame;
               _loc15_ = _loc10_.getfashionUrl(param3.charID);
            }
         }
         else if(param2 && param2.armor)
         {
            _loc20_ = int(param2.armor.id);
            _loc14_ = ItemVoManager.getIns().getEquipmentVoById(_loc20_).resourceId;
            _loc10_ = ResourceManager.getIns().getResourcesByID(_loc14_);
            _loc16_ = _loc10_.frame;
            _loc15_ = _loc10_.getfashionUrl(param3.charID);
         }
         if(param2 && param2.suit && param3.getShowFashioin())
         {
            _loc20_ = int(param2.suit.id);
            _loc14_ = ItemVoManager.getIns().getFashionVoById(_loc20_).resourceId;
            _loc10_ = ResourceManager.getIns().getResourcesByID(_loc14_);
            _loc16_ = _loc10_.frame;
            _loc19_ = true;
            _loc15_ = _loc10_.getfashionUrl(param3.charID);
         }
         if(param3.equipments["wardRobeArmor" + _loc18_] && param3.equipments["wardRobeArmor" + _loc18_] > 0)
         {
            _loc20_ = int(param3.equipments["wardRobeArmor" + _loc18_]);
            _loc19_ = Boolean(ItemVoManager.getIns().getFashionVoById(_loc20_));
            if(_loc19_)
            {
               _loc14_ = ItemVoManager.getIns().getFashionVoById(_loc20_).resourceId;
            }
            else
            {
               _loc14_ = ItemVoManager.getIns().getEquipmentVoById(_loc20_).resourceId;
            }
            _loc10_ = ResourceManager.getIns().getResourcesByID(_loc14_);
            _loc16_ = _loc10_.frame;
            _loc15_ = _loc10_.getfashionUrl(param3.charID);
         }
         if(_loc19_)
         {
            _loc7_ = ItemVoManager.getIns().getFashionVoById(_loc20_);
            if(_loc7_ && _loc7_.originalFashionId)
            {
               param3.fashions.push(_loc7_);
            }
         }
         param3.currEqiups = [_loc16_,_loc20_];
         var _loc13_:int = -1;
         var _loc17_:int = 1;
         _loc19_ = false;
         if(param2 && param3.getShowMoEquip())
         {
            if(param2 && param2.weaponMo)
            {
               _loc13_ = int(param2.weaponMo.id);
               _loc14_ = ItemVoManager.getIns().getEquipmentVoById(_loc13_).resourceId;
               _loc10_ = ResourceManager.getIns().getResourcesByID(_loc14_);
               _loc17_ = _loc10_.frame;
               _loc9_ = _loc10_.getfashionUrl(param3.charID);
            }
            else if(param2 && param2.weaponTwoMo)
            {
               _loc13_ = int(param2.weaponTwoMo.id);
               _loc14_ = ItemVoManager.getIns().getEquipmentVoById(_loc13_).resourceId;
               _loc10_ = ResourceManager.getIns().getResourcesByID(_loc14_);
               _loc17_ = _loc10_.frame;
               _loc9_ = _loc10_.getfashionUrl(param3.charID);
            }
         }
         else if(param2 && param2.weapon)
         {
            _loc13_ = int(param2.weapon.id);
            _loc14_ = ItemVoManager.getIns().getEquipmentVoById(_loc13_).resourceId;
            _loc10_ = ResourceManager.getIns().getResourcesByID(_loc14_);
            _loc17_ = _loc10_.frame;
            _loc9_ = _loc10_.getfashionUrl(param3.charID);
         }
         else if(param2 && param2.weaponTwo)
         {
            _loc13_ = int(param2.weaponTwo.id);
            _loc14_ = ItemVoManager.getIns().getEquipmentVoById(_loc13_).resourceId;
            _loc10_ = ResourceManager.getIns().getResourcesByID(_loc14_);
            _loc17_ = _loc10_.frame;
            _loc9_ = _loc10_.getfashionUrl(param3.charID);
         }
         if(param2 && param2.fashionWeapon && param3.getShowFashioin())
         {
            _loc13_ = int(param2.fashionWeapon.id);
            _loc14_ = ItemVoManager.getIns().getFashionVoById(_loc13_).resourceId;
            _loc10_ = ResourceManager.getIns().getResourcesByID(_loc14_);
            _loc17_ = _loc10_.frame;
            _loc9_ = _loc10_.getfashionUrl(param3.charID);
            _loc19_ = true;
         }
         if(param3.equipments["wardRobeWeapon" + _loc18_] && param3.equipments["wardRobeWeapon" + _loc18_] > 0)
         {
            _loc13_ = int(param3.equipments["wardRobeWeapon" + _loc18_]);
            _loc19_ = Boolean(ItemVoManager.getIns().getFashionVoById(_loc13_));
            if(_loc19_)
            {
               _loc14_ = ItemVoManager.getIns().getFashionVoById(_loc13_).resourceId;
            }
            else
            {
               _loc14_ = ItemVoManager.getIns().getEquipmentVoById(_loc13_).resourceId;
            }
            _loc10_ = ResourceManager.getIns().getResourcesByID(_loc14_);
            _loc17_ = _loc10_.frame;
            _loc9_ = _loc10_.getfashionUrl(param3.charID);
         }
         if(_loc19_)
         {
            _loc7_ = ItemVoManager.getIns().getFashionVoById(_loc13_);
            if(_loc7_ && _loc7_.originalFashionId)
            {
               param3.fashions.push(_loc7_);
            }
         }
         SimpleTextLog.getIns().log2("wqId=" + _loc13_,"yfId=" + _loc20_,"wframe=" + _loc17_,"yframe=" + _loc16_);
         param3.currFashions = [_loc17_,_loc20_,_loc13_,_loc20_,_loc9_,_loc15_];
         param3.currEqiups.push(_loc17_,_loc13_);
         if(param4 && param4.wearComponent)
         {
            param4.wearComponent.reSet();
         }
         if(param5)
         {
            param5.reSet();
         }
         var _loc8_:Vector.<Bone> = param1.getBones();
         _loc11_ = 0;
         while(_loc11_ < _loc8_.length)
         {
            _loc6_ = _loc8_[_loc11_];
            if(_loc6_.childArmature)
            {
               if(_loc6_.name.indexOf("wq") > -1)
               {
                  if(_loc6_.childArmature.animation.hasAnimation(_loc17_ + ""))
                  {
                     _loc6_.childArmature.animation.gotoAndStop(_loc17_ + "",0);
                     _loc6_.childArmature.advanceTime(0);
                  }
               }
               else if(_loc6_.childArmature.animation.hasAnimation(_loc16_ + ""))
               {
                  _loc6_.childArmature.animation.gotoAndStop(_loc16_ + "",0);
                  _loc6_.childArmature.advanceTime(0);
               }
            }
            _loc11_++;
         }
         if(param4)
         {
            _loc12_ = param4.wearComponent;
         }
         else if(param5)
         {
            _loc12_ = param5;
         }
         if(!_loc12_)
         {
            _loc12_ = WearComponent.getComponent();
            if(param4)
            {
               param4.wearComponent = _loc12_;
            }
         }
         _loc12_.init(param3,param1,_loc17_,_loc16_,_loc9_,_loc15_);
      }
      
      public function getEquipURLs(param1:UserVO) : Array
      {
         var _loc3_:String = null;
         var _loc8_:String = null;
         var _loc7_:int = 0;
         var _loc4_:ResourceVO = null;
         var _loc12_:Boolean = false;
         var _loc2_:FashionVo = null;
         var _loc14_:Object = param1.equipments;
         var _loc11_:String = "";
         if(UserModelManager.isProfession2(param1.charID))
         {
            _loc11_ = "Two";
         }
         param1.fashions = [];
         var _loc13_:int = -1;
         var _loc9_:int = 1;
         if(param1.getShowMoEquip())
         {
            if(_loc14_ && _loc14_.armorMo)
            {
               _loc13_ = int(_loc14_.armorMo.id);
               _loc7_ = ItemVoManager.getIns().getEquipmentVoById(_loc13_).resourceId;
               _loc4_ = ResourceManager.getIns().getResourcesByID(_loc7_);
               _loc9_ = _loc4_.frame;
               _loc8_ = _loc4_.getfashionUrl(param1.charID);
            }
         }
         else if(_loc14_ && _loc14_.armor)
         {
            _loc13_ = int(_loc14_.armor.id);
            _loc7_ = ItemVoManager.getIns().getEquipmentVoById(_loc13_).resourceId;
            _loc4_ = ResourceManager.getIns().getResourcesByID(_loc7_);
            _loc9_ = _loc4_.frame;
            _loc8_ = _loc4_.getfashionUrl(param1.charID);
         }
         if(_loc14_ && _loc14_.suit && param1.getShowFashioin())
         {
            _loc13_ = int(_loc14_.suit.id);
            _loc7_ = ItemVoManager.getIns().getFashionVoById(_loc13_).resourceId;
            _loc4_ = ResourceManager.getIns().getResourcesByID(_loc7_);
            _loc9_ = _loc4_.frame;
            _loc12_ = true;
            _loc8_ = _loc4_.getfashionUrl(param1.charID);
         }
         if(param1.equipments["wardRobeArmor" + _loc11_] && param1.equipments["wardRobeArmor" + _loc11_] > 0)
         {
            _loc13_ = int(param1.equipments["wardRobeArmor" + _loc11_]);
            _loc12_ = Boolean(ItemVoManager.getIns().getFashionVoById(_loc13_));
            if(_loc12_)
            {
               _loc7_ = ItemVoManager.getIns().getFashionVoById(_loc13_).resourceId;
            }
            else
            {
               _loc7_ = ItemVoManager.getIns().getEquipmentVoById(_loc13_).resourceId;
            }
            _loc4_ = ResourceManager.getIns().getResourcesByID(_loc7_);
            _loc9_ = _loc4_.frame;
            _loc8_ = _loc4_.getfashionUrl(param1.charID);
         }
         if(_loc12_)
         {
            _loc2_ = ItemVoManager.getIns().getFashionVoById(_loc13_);
            if(_loc2_ && _loc2_.originalFashionId)
            {
               param1.fashions.push(_loc2_);
            }
         }
         param1.currEqiups = [_loc9_,_loc13_];
         var _loc5_:int = -1;
         var _loc10_:int = 1;
         _loc12_ = false;
         if(param1.getShowMoEquip())
         {
            if(_loc14_ && _loc14_.weaponMo)
            {
               _loc5_ = int(_loc14_.weaponMo.id);
               _loc7_ = ItemVoManager.getIns().getEquipmentVoById(_loc5_).resourceId;
               _loc4_ = ResourceManager.getIns().getResourcesByID(_loc7_);
               _loc10_ = _loc4_.frame;
               _loc3_ = _loc4_.getfashionUrl(param1.charID);
            }
            else if(_loc14_ && _loc14_.weaponTwoMo)
            {
               _loc5_ = int(_loc14_.weaponTwoMo.id);
               _loc7_ = ItemVoManager.getIns().getEquipmentVoById(_loc5_).resourceId;
               _loc4_ = ResourceManager.getIns().getResourcesByID(_loc7_);
               _loc10_ = _loc4_.frame;
               _loc3_ = _loc4_.getfashionUrl(param1.charID);
            }
         }
         else if(_loc14_ && _loc14_.weapon)
         {
            _loc5_ = int(_loc14_.weapon.id);
            _loc7_ = ItemVoManager.getIns().getEquipmentVoById(_loc5_).resourceId;
            _loc4_ = ResourceManager.getIns().getResourcesByID(_loc7_);
            _loc10_ = _loc4_.frame;
            _loc3_ = _loc4_.getfashionUrl(param1.charID);
         }
         else if(_loc14_ && _loc14_.weaponTwo)
         {
            _loc5_ = int(_loc14_.weaponTwo.id);
            _loc7_ = ItemVoManager.getIns().getEquipmentVoById(_loc5_).resourceId;
            _loc4_ = ResourceManager.getIns().getResourcesByID(_loc7_);
            _loc10_ = _loc4_.frame;
            _loc3_ = _loc4_.getfashionUrl(param1.charID);
         }
         if(_loc14_ && _loc14_.fashionWeapon && param1.getShowFashioin())
         {
            _loc5_ = int(_loc14_.fashionWeapon.id);
            _loc7_ = ItemVoManager.getIns().getFashionVoById(_loc5_).resourceId;
            _loc4_ = ResourceManager.getIns().getResourcesByID(_loc7_);
            _loc10_ = _loc4_.frame;
            _loc3_ = _loc4_.getfashionUrl(param1.charID);
            _loc12_ = true;
         }
         if(param1.equipments["wardRobeWeapon" + _loc11_] && param1.equipments["wardRobeWeapon" + _loc11_] > 0)
         {
            _loc5_ = int(param1.equipments["wardRobeWeapon" + _loc11_]);
            _loc12_ = Boolean(ItemVoManager.getIns().getFashionVoById(_loc5_));
            if(_loc12_)
            {
               _loc7_ = ItemVoManager.getIns().getFashionVoById(_loc5_).resourceId;
            }
            else
            {
               _loc7_ = ItemVoManager.getIns().getEquipmentVoById(_loc5_).resourceId;
            }
            _loc4_ = ResourceManager.getIns().getResourcesByID(_loc7_);
            _loc10_ = _loc4_.frame;
            _loc3_ = _loc4_.getfashionUrl(param1.charID);
         }
         var _loc6_:Array = [];
         if(_loc3_)
         {
            _loc6_.push(_loc3_);
         }
         if(_loc8_)
         {
            _loc6_.push(_loc8_);
         }
         return _loc6_;
      }
      
      public function getAssetUrls(param1:int, param2:String, param3:int = 0) : Object
      {
         var _loc6_:int = 0;
         var _loc5_:ResourceVO = null;
         var _loc8_:MagicweaponVo = null;
         var _loc10_:String = null;
         var _loc7_:RoleConfigVO = null;
         _loc10_ = null;
         _loc7_ = null;
         _loc10_ = null;
         _loc10_ = null;
         var _loc9_:Object = null;
         var _loc4_:Object = {
            "swf":[],
            "byte":[],
            "dragon":[],
            "resvo":null
         };
         if(param2 == "magicWeapon")
         {
            _loc8_ = ItemVoManager.getIns().getMagicweaponVoById(param1);
            if(!_loc8_)
            {
               _loc8_ = ItemVoManager.getIns().getSwordVoById(param1);
            }
            if(_loc8_)
            {
               _loc6_ = _loc8_.resourceId;
            }
            if(_loc6_ == 0 && param3 > 0)
            {
               _loc6_ = param3;
            }
            if(_loc6_ > 0)
            {
               _loc5_ = ResourceManager.getIns().getResourcesByID(_loc6_);
               _loc4_.resvo = _loc5_;
               _loc10_ = _loc5_.getManBattleURL();
               if(_loc5_.resourceType == 13)
               {
                  _loc10_ = _loc5_.getManNormalURL();
                  if(_loc5_.normal1)
                  {
                     _loc10_ = _loc5_.getManNormal1URL();
                  }
               }
               if(_loc10_.indexOf(".swf") > -1)
               {
                  _loc4_.swf.push(_loc10_.slice(0,-4));
               }
            }
         }
         if(param2 == "monster")
         {
            _loc7_ = ManModelManager.getIns().getManById(param1,param2);
            if(_loc7_)
            {
               _loc6_ = _loc7_.resourcesId;
               _loc5_ = ResourceManager.getIns().getResourcesByID(_loc6_);
               _loc4_.resvo = _loc5_;
               _loc10_ = _loc5_.getManBattleURL();
               if(_loc10_.indexOf(".swf") > -1)
               {
                  _loc4_.swf.push(_loc10_.slice(0,-4));
               }
               if(!_loc5_.battle)
               {
                  _loc10_ = _loc5_.getManNormalURL();
                  if(_loc10_.indexOf(".swf") > -1)
                  {
                     _loc4_.swf.push(_loc10_.slice(0,-4));
                  }
               }
            }
         }
         else if(param2 == ManType.HORSE || param2 == "pet" || param2 == "role" || param2 == "npc")
         {
            _loc7_ = ManModelManager.getIns().getManById(param1,param2);
            if(_loc7_)
            {
               _loc6_ = _loc7_.resourcesId;
               _loc5_ = ResourceManager.getIns().getResourcesByID(_loc6_);
               _loc4_.resvo = _loc5_;
               _loc10_ = _loc5_.getManNormalURL();
               if(_loc10_.indexOf(".swf") > -1)
               {
                  _loc4_.swf.push(_loc10_.slice(0,-4));
               }
            }
         }
         else if(param2 == "MAGIC_WEAPON2Yi")
         {
            _loc6_ = param3;
            _loc5_ = ResourceManager.getIns().getResourcesByID(_loc6_);
            _loc4_.resvo = _loc5_;
            _loc10_ = _loc5_.getManNormalURL();
            if(_loc10_.indexOf(".swf") > -1)
            {
               _loc4_.swf.push(_loc10_.slice(0,-4));
            }
         }
         if(_loc5_ && _loc5_.resourceType == 12)
         {
            _loc10_ = _loc5_.getManBattleURL();
            if(_loc10_.indexOf(".swf") > -1)
            {
               _loc10_ = _loc10_.slice(0,-4);
            }
            _loc4_.dragon.push(_loc10_);
         }
         else if(_loc5_ && _loc5_.resourceType == 13)
         {
            _loc10_ = _loc5_.getManBattleURL();
            _loc4_.dragon.push(_loc10_);
            if(_loc5_.isItem)
            {
               _loc9_ = _loc5_.getItemBattle2URL();
            }
            else
            {
               _loc9_ = _loc5_.getManBattle2URL();
            }
            if(_loc9_)
            {
               for each(_loc10_ in _loc9_)
               {
                  _loc4_.dragon.push(_loc10_);
               }
            }
         }
         return _loc4_;
      }
      
      public function getResources() : Dictionary
      {
         return _resource;
      }
      
      public function addDisposeBattleByCharId(param1:*, param2:String, param3:int = 0) : void
      {
         _battles.push({
            "id":param1,
            "type":param2,
            "resourceId":param3
         });
      }
      
      public function disposeBattle() : void
      {
         var _loc1_:int = 0;
         if(!_battles)
         {
            _battles = [];
         }
         _loc1_ = 0;
         while(_loc1_ < _battles.length)
         {
            disposeMan(_battles[_loc1_]);
            _loc1_++;
         }
         _battles.length = 0;
      }
      
      public function disposeMan(param1:*) : void
      {
         var _loc11_:int = 0;
         var _loc12_:* = undefined;
         var _loc3_:Object = null;
         var _loc4_:Boolean = false;
         _loc11_ = 0;
         var _loc14_:* = param1.id;
         var _loc10_:String = param1.type;
         if(!SimpleTextLog.Close)
         {
            SimpleTextLog.getIns().log2("disposeMan=" + _loc14_);
         }
         var _loc2_:Object = getAssetUrls(_loc14_,_loc10_,param1.resourceId);
         var _loc6_:Array = _loc2_.swf;
         var _loc8_:Array = _loc2_.dragon;
         _loc11_ = 0;
         while(_loc11_ < _loc6_.length)
         {
            AssetManager.getIns().addBattleByUrl(_loc6_[_loc11_] + ".swf");
            _loc11_++;
         }
         _loc11_ = 0;
         while(_loc11_ < _loc8_.length)
         {
            AssetManager.getIns().addBattleByUrl(_loc8_[_loc11_] + ".swf");
            DragonResourceManager.getIns().addBattleDisposeUrl(_loc8_[_loc11_]);
            _loc11_++;
         }
         var _loc9_:* = _resource[_loc14_];
         if(!_loc9_)
         {
            return;
         }
         for(var _loc13_:String in _loc9_)
         {
            _loc3_ = _loc9_[_loc13_];
            if(_loc13_ == "ac" || _loc13_ == "ef")
            {
               for each(var _loc7_:Object in _loc3_)
               {
                  dispose(_loc7_);
               }
               _loc9_[_loc13_] = null;
            }
            else if(_loc13_ == "actionSkillFactory")
            {
               for each(_loc12_ in _loc3_)
               {
                  if(_loc12_.fac)
                  {
                     _loc12_.fac.dispose();
                  }
               }
               _loc9_[_loc13_] = null;
            }
            else
            {
               _loc4_ = false;
               for each(var _loc5_:Object in _loc3_)
               {
                  if(_loc5_ && _loc5_.hasOwnProperty("length"))
                  {
                     _loc11_ = 0;
                     while(_loc11_ < _loc5_.length)
                     {
                        dispose(_loc5_[_loc11_]);
                        _loc4_ = true;
                        _loc11_++;
                     }
                  }
               }
               if(_loc4_)
               {
                  _loc9_[_loc13_] = null;
               }
            }
         }
         if(_loc9_["armature"])
         {
            DragonResourceManager.getIns().dispose(_loc9_["armature"]);
         }
         delete _loc9_["armature"];
         for(_loc12_ in _loc9_)
         {
         }
         delete _resource[_loc14_];
      }
   }
}

