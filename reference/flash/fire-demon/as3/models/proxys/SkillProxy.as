package models.proxys
{
   import flash.utils.Dictionary;
   import models.managers.SkillModelManager;
   import models.vo.SkillConfigVO;
   
   public class SkillProxy extends BasicConfigProxy
   {
      
      public static const NAME:String = "SkillProxy";
      
      private var _skillDic:Dictionary = new Dictionary();
      
      public function SkillProxy()
      {
         super("SkillProxy");
      }
      
      public static function GetConfigById(param1:int, param2:*) : SkillConfigVO
      {
         var _loc4_:SkillConfigVO = null;
         var _loc5_:int = 0;
         var _loc3_:SkillConfigVO = null;
         if(param2)
         {
            _loc4_ = new SkillConfigVO();
            _loc4_.buildFormXML(param2);
            _loc4_.subs = new Vector.<SkillConfigVO>();
            _loc5_ = 0;
            while(_loc5_ < _loc4_.subSkillID.length)
            {
               _loc3_ = SkillModelManager.getIns().getSkillConfigVOByID(_loc4_.subSkillID[_loc5_]);
               _loc3_.parent = _loc4_;
               _loc4_.sub = _loc3_;
               _loc4_.subs.push(_loc3_);
               _loc5_++;
            }
            return _loc4_;
         }
         return null;
      }
      
      override protected function load(param1:String) : void
      {
         if(_dataItem)
         {
            if(!_dataItem.fzDictXmlObj["Skill.xml"])
            {
               parseAll(new XML(_dataItem.fzDict["Skill.xml"]));
            }
            else
            {
               _dataIsObject = true;
               parseJson(_dataItem.fzDict["Skill.xml"]);
               parseAll2(_dataItem.fzDict["Skill.xml"]);
            }
         }
         SkillModelManager.getIns().init(_skillDic);
      }
      
      private function parseAll2(param1:Object) : void
      {
         var _loc5_:int = 0;
         var _loc3_:SkillConfigVO = null;
         for each(var _loc4_ in param1)
         {
            parse(_loc4_);
         }
         for each(var _loc2_:SkillConfigVO in _skillDic)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc2_.subSkillID.length)
            {
               if(_loc2_.subSkillID[_loc5_] > 0)
               {
                  _loc2_.sub = _skillDic[_loc2_.subSkillID[_loc5_]];
                  _skillDic[_loc2_.subSkillID[_loc5_]].parent = _loc2_;
               }
               _loc5_++;
            }
         }
         for each(_loc2_ in _skillDic)
         {
            _loc2_.subs = new Vector.<SkillConfigVO>();
            _loc5_ = 0;
            while(_loc5_ < _loc2_.subSkillID.length)
            {
               _loc3_ = _skillDic[_loc2_.subSkillID[_loc5_]];
               _loc2_.subs.push(_loc3_);
               _loc3_.parent = _loc2_;
               _loc5_++;
            }
         }
      }
      
      override protected function onDataLoadComplete(... rest) : void
      {
         super.onDataLoadComplete(rest[0]);
      }
      
      override protected function parseAll(param1:XML) : void
      {
         var _loc6_:int = 0;
         var _loc3_:SkillConfigVO = null;
         this.data = param1;
         var _loc5_:int = 0;
         for each(var _loc4_:XML in param1.RECORD)
         {
            _loc5_++;
            parse(_loc4_);
         }
         for each(var _loc2_:SkillConfigVO in _skillDic)
         {
            _loc6_ = 0;
            while(_loc6_ < _loc2_.subSkillID.length)
            {
               if(_loc2_.subSkillID[_loc6_] > 0)
               {
                  _loc2_.sub = _skillDic[_loc2_.subSkillID[_loc6_]];
                  _skillDic[_loc2_.subSkillID[_loc6_]].parent = _loc2_;
               }
               _loc6_++;
            }
         }
         for each(_loc2_ in _skillDic)
         {
            _loc2_.subs = new Vector.<SkillConfigVO>();
            _loc6_ = 0;
            while(_loc6_ < _loc2_.subSkillID.length)
            {
               _loc3_ = _skillDic[_loc2_.subSkillID[_loc6_]];
               _loc2_.subs.push(_loc3_);
               _loc3_.parent = _loc2_;
               _loc6_++;
            }
         }
      }
      
      override protected function parse(param1:XML) : void
      {
         var _loc2_:SkillConfigVO = new SkillConfigVO();
         _loc2_.buildFormXML(param1);
         _skillDic[_loc2_.id] = _loc2_;
      }
      
      public function getSkillConfigVoById(param1:int) : SkillConfigVO
      {
         var _loc3_:SkillConfigVO = null;
         var _loc4_:* = undefined;
         var _loc5_:int = 0;
         var _loc2_:SkillConfigVO = null;
         if(dataIsObject)
         {
            _loc4_ = getData()[param1];
            if(_loc4_)
            {
               _loc3_ = new SkillConfigVO();
               _loc3_.buildFormXML(_loc4_);
               _loc3_.subs = new Vector.<SkillConfigVO>();
               _loc5_ = 0;
               while(_loc5_ < _loc3_.subSkillID.length)
               {
                  _loc2_ = getSkillConfigVoById(_loc3_.subSkillID[_loc5_]);
                  _loc2_.parent = _loc3_;
                  _loc3_.sub = _loc2_;
                  _loc3_.subs.push(_loc2_);
                  _loc5_++;
               }
               return _loc3_;
            }
         }
         return null;
      }
   }
}

