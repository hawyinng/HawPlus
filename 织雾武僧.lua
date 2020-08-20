--local shown, unit, spell, stack, time = msTMW(1,1)

--[[if msICS("focus","扭曲的映像,吸取生命,法力尖刺") and msISC("分筋错骨","focus",true) then 
   msR("/stopcasting\n/cast [target=focus]分筋错骨\n/cast 分筋错骨")
end]]

if msICS("player","精华之泉") then
   return
end

if msruninspell() then
end

if msICM("朱鹤赤精") then
end

if not count then
   count=1
end

local grouptype="party"
local num=3
local group = false

--print(GetNumGroupMembers())
if GetNumGroupMembers()>5 then  
   grouptype="raid";
   num=5;
else grouptype="party"; 
   num=3;
end

if GetNumGroupMembers()>30 then
   group = true
end

if msGHP("player")<50 and msISC("治疗石","player",true) then
   msR("治疗石", "player")
end

if msGHP("player")<70 and msTalentInfo("金创药") and msISC("金创药","player",true) then
   msR("金创药", "player")
end

if UnitAffectingCombat("player") and msGHP("player")<30 and msISC("壮胆酒","player",true) then
   msR("壮胆酒", "player")
end

if flag==3 and msISC("扫堂腿") then
   tui()
   return
end

--[[if not IsRatedOrIsArena() and grouptype=="raid" and HP>=95 and not msICS("player","精华之泉") then
   count=1
end

if IsRatedOrIsArena() and not group and HP>=95 and not msICS("player","精华之泉") then
   count=1
end]]

if GetUnitSpeed("player")>0 then
   count=1
end

if MT and msGUB("重伤",MT) and msGHP(MT)<90 and count==2 then
   local castq = "/castsequence [target=" .. MT .. "] reset=3 抚慰之雾,氤氲之雾"
   if msGUB("氤氲之雾",MT,"player") then
      count=1
      return
   end   
   if not msGUB("氤氲之雾",MT,"player") then
      msR(castq)
      return
   end
elseif MT and msGHP(MT)>=90 then
   count=1
end

if MT and not msGUB('死疽吐息,哀难,墨黑深渊',MT) and msGHP(MT)<75 and count==2 then
   local castq = "/castsequence [target=" .. MT .. "] reset=3 抚慰之雾,氤氲之雾"
   if msGUB("氤氲之雾",MT,"player") then
      count=1
      return
   end   
   if not msGUB("氤氲之雾",MT,"player") then
      msR(castq)
      return
   end
elseif MT and msGHP(MT)>=75 then
   count=1
end

if UnitAffectingCombat("player") and msGPP("player")<75 and not msGUB("法力茶") and msISC("清醒梦境之忆") then 
   msR("清醒梦境之忆"); 
   return
end

if msGPP("player")<10 and grouptype=="raid" and msICS("player","抚慰之雾") then
   return
end

local TANK = msFindUnit('(UnitGroupRolesAssigned(unit) == "TANK" or UnitName(unit)=="防御者鸥图") and not UnitIsDeadOrGhost(unit) and select(2,msGFD(unit))<=40',grouptype,true)
--local  mt, i, mt2= msGetMinS("msGFD(unit)<=40 and not msGUB('死疽吐息,哀难',unit) and not UnitIsDeadOrGhost(unit)","msGHP(unit)",TANK)
local mt, i= msGetMin("msGFD(unit)<=40 and not msGUB('死疽吐息,哀难,墨黑深渊',unit) and not UnitIsDeadOrGhost(unit)","msGHP(unit)",TANK)
if mt and i then
   if i<25 and msISC("作茧缚命",mt,true) then 
      msR("/stopcasting")
      msR("作茧缚命",mt)
   end
   if i<45 and msISC("雷光聚神茶") and not msICS("player","精华之泉") then 
      msR("雷光聚神茶") 
   end
   if i<45 and MT~=mt and msGUB("115175",MT,"player") then
      MT=mt
      count=2
      msR("/stopcasting")
      return
   end
   if i<45 and not msGUB("115175",mt,"player") and msISC("抚慰之雾",mt) then
      msR("抚慰之雾",mt)
   end
   if i<80 and not msGUB("115175",mt,"player") and not msGUB("氤氲之雾",mt,"player") and msISC("抚慰之雾",mt) then
      msR("抚慰之雾",mt)
   end
   if i<80 and msGUB("115175",mt,"player") and not msGUB("氤氲之雾",mt,"player") and msISC("氤氲之雾",mt,false) then 
      msR("氤氲之雾",mt); 
   end
   if UnitAffectingCombat("player") and i<95 and not msGUB("复苏之雾",mt,"player") and msISC("复苏之雾",mt,true) then 
      count=1
      msR("复苏之雾",mt);
   end
   if msTalentInfo("禅意波") and msISC("禅意波",mt,true) then 
      msR("禅意波",mt); 
   end
end

--[[if mt2 then
   if UnitAffectingCombat("player") and msGHP(mt2)<=100 and not msGUB("复苏之雾",mt2) and msISC("复苏之雾",mt2,true) then 
      msR("复苏之雾",mt2);
   end
end]]

local tuans = msFindUnit("msGFD(unit)<=40 and not UnitIsDeadOrGhost(unit)",grouptype,true)
if GetNumGroupMembers()>=2 then  
   if msISC("清创生血") and not msGUB("痛苦无常",sUnit) 
   then 
      msDecursive()
   end
   
   --"团刷"
   local result = {}
   if msTalentInfo("碧愈疾风") and msISC("碧愈疾风",nil,true) then
      result= msFindUnit("msGHP(unit)<=90 and not msGUB('死疽吐息,哀难,墨黑深渊',unit) and not UnitIsDeadOrGhost(unit) and msGFD(unit)<=10", grouptype, true)
      if result then 
         if  #result>=num then
            if msISC("碧愈疾风",nil,true) then 
               msR("碧愈疾风"); 
            end
         end
      end
   end
   
   if msISC("精华之泉",nil,true) then
      result= msFindUnit("msGHP(unit)<=70 and not msGUB('死疽吐息,哀难,墨黑深渊',unit) and not UnitIsDeadOrGhost(unit) and msGFD(unit)<30", grouptype, true)
      if result then 
         if  #result>=num then
            if msTalentInfo("法力茶") and msGPP("player")<60 and not msGUB("清醒梦境之忆") and msISC("法力茶") then
               count=1
               msR("法力茶"); 
               return
            end
            if msISC("精华之泉",nil,true) then
               count=1
               msR("精华之泉"); 
               return
            end
         end
      end
   end
   
   --重伤词缀
   local sUnit1, h= msGetMin("msGFD(unit)<=40 and msGUB('重伤',unit) and msGBC('重伤',unit)>=2 and not UnitIsDeadOrGhost(unit)","msGHP(unit)",tuans)
   if sUnit1 and h and not msGUB("哀难",sUnit1) then
      if h<30 and msISC("作茧缚命",sUnit1,true) then 
         msR("/stopcasting")
         msR("作茧缚命",sUnit1); 
      end
      
      if h<90 and MT~=sUnit1 and msGUB("115175",MT,"player") then
         MT=sUnit1
         count=2
         msR("/stopcasting")
         return
      end
      if not msGUB("115175",sUnit1,"player") and msISC("抚慰之雾",sUnit1) then
         msR("抚慰之雾",sUnit1)
      end
      
      if msTalentInfo("法力茶") and msGPP("player")<65 and not msGUB("清醒梦境之忆") and msISC("法力茶") then 
         msR("法力茶"); 
         return
      end
      
      if GetUnitSpeed("player")>0 then
         if h<=90 and not msGUB("复苏之雾",sUnit1,"player") and msGSC("复苏之雾")>=1 and msISC("复苏之雾",sUnit1,true) then
            msR("复苏之雾",sUnit1);
         end
         if h<=80 and msISC("精华之泉",nil,true) then 
            msR("精华之泉"); 
         end
      end
      
      if h<95 and not msGUB("复苏之雾",sUnit1,"player") and msGSC("复苏之雾")>=1 and msISC("复苏之雾",sUnit1,true) then 
         count=1
         msR("复苏之雾",sUnit1);
      end
      
      if grouptype=="party" then
      end
      
      if msGUB("115175",sUnit1,"player") then
         if h<90 and not msGUB("氤氲之雾",sUnit1,"player") and msISC("氤氲之雾",sUnit1,false) then 
            msR("氤氲之雾",sUnit1); 
         end   
         if h<90 and msISC("活血术",sUnit1,false) then 
            msR("活血术",sUnit1);
         end
      end
   end
   
   local sUnit, l, Unit2= msGetMinS("msGFD(unit)<=40 and not msGUB('死疽吐息,哀难,墨黑深渊',unit) and not UnitIsDeadOrGhost(unit)","msGHP(unit)",tuans)
   --print(sUnit, l, Unit2)
   result= msFindUnit("msGHP(unit)<85 and not msGUB('死疽吐息,哀难,墨黑深渊',unit) and not UnitIsDeadOrGhost(unit) and msGFD(unit)<=40", grouptype, true)
   if #result>=num and sUnit and l then
      if l<90 and not msGUB("复苏之雾",Unit2,"player") and msISC("复苏之雾",Unit2,true) then 
         count=1
         msR("复苏之雾",Unit2);
      end
      if l<90 and not msGUB("复苏之雾",sUnit,"player") and msISC("复苏之雾",sUnit,true) then 
         count=1
         msR("复苏之雾",sUnit);
      end
      
      if MT~=sUnit and msGUB("115175",MT,"player") then
         MT=sUnit
         count=2
         msR("/stopcasting")
         return
      end
      
      if msISC("雷光聚神茶") and not msICS("player","精华之泉") then 
         msR("雷光聚神茶")
      end
      
      if msTalentInfo("雷光凝聚") then
      end
      
      if msGUB("115175",sUnit,"player") then
         if l<40 and not msGUB("氤氲之雾",sUnit,"player") and msISC("氤氲之雾",sUnit,false) then 
            msR("氤氲之雾",sUnit); 
         end
         if msGUB("雷光聚神茶") and msISC("活血术",sUnit,false) then 
            msR("活血术",sUnit);
         end
         if l<60 and msISC("活血术",sUnit,false) then 
            msR("活血术",sUnit);
         end
      end
   end
   
   --单刷
   if sUnit and l and not msGUB("哀难",sUnit) then
      if l<25 and msISC("作茧缚命",sUnit,true) then 
         msR("/stopcasting")
         msR("作茧缚命",sUnit); 
      end
      
      if l<90 and MT~=sUnit and msGUB("115175",MT,"player") then
         MT=sUnit
         count=2
         msR("/stopcasting")
         return
      end
      if not msGUB("115175",sUnit,"player") and msISC("抚慰之雾",sUnit) then
         msR("抚慰之雾",sUnit)
      end
      
      if msTalentInfo("法力茶") and msGPP("player")<65 and msISC("法力茶") then 
         msR("法力茶"); 
         return
      end
      
      if GetUnitSpeed("player")>0 then
         if l<=90 and not msGUB("复苏之雾",sUnit,"player") and msGSC("复苏之雾")==2 and msISC("复苏之雾",sUnit,true) then
            msR("复苏之雾",sUnit);
         end
         if l<=60 and msISC("精华之泉",nil,true) then 
            msR("精华之泉"); 
         end
      end
      
      if l<85 and msTalentInfo("真气波") and msISC("真气波",sUnit,true) then msR("真气波",sUnit);
      end
      
      if l<95 and not msGUB("复苏之雾",sUnit,"player") and msGSC("复苏之雾")==2 and msISC("复苏之雾",sUnit,true) then 
         count=1
         msR("复苏之雾",sUnit);
      end
      
      if grouptype=="party" then
      end
      
      if msGUB("115175",sUnit,"player") then
         if l<75 and not msGUB("氤氲之雾",sUnit,"player") and msISC("氤氲之雾",sUnit,false) then 
            msR("氤氲之雾",sUnit); 
         end
         
         if l<85 and msISC("活血术",sUnit,false) then 
            msR("活血术",sUnit); 
         end
      end
   end
end
