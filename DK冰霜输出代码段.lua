--增益BUFF
local shown21, unit21, spell21, stack21, time21 = msTMW(2,1) --晕
local shown22, unit22, spell22, stack22, time22 = msTMW(2,2) --减速
local shown25, unit25, spell25, stack25, time25 = msTMW(2,5) --递减
local shown26, unit26, spell26, stack26, time26 = msTMW(2,6) --减伤
local shown27, unit27, spell27, stack27, time27 = msTMW(2,7) --爆发BUFF
local shown28, unit28, spell28, stack28, time28 = msTMW(2,8) --免疫

local group=false
if GetNumGroupMembers()<=5 and UnitHealthMax("target")>1000000 then
   grouptype="party";
   group=true
elseif (GetNumGroupMembers()>5 and UnitHealthMax("target")>3000000) or UnitHealthMax("target")>30000000 then 
   grouptype="raid"; 
   group=true
end

if not num then
   num=1
end

if not num2 then
   num2=1
end

if msGUB("296971") then
   return
end

if msICS("player","聚能艾泽里特射线") then
   return
end

if flag==1 and msISC("枯萎凋零") then
   flag=1
   kuwei()
   return
end

if msruninspell() then
end

if msGHP("player")<50 and not msGUB("207777","target") and msTalentInfo("飘忽不定") and msISC("佯攻") then
   msR("佯攻")
   return
end

if msGHP("player")<50 and msISC("治疗石") then
   msR("治疗石", "player")
end

--if msGHP("player")<50 and msISC("海滨治疗药水") then
--msR("海滨治疗药水", "player")
--end

if not UnitExists("target") or UnitIsDeadOrGhost("target") then
   msR("/startattack")
end

local class = false
if UnitClass("target")=="潜行者" or UnitClass("target")=="战士" or UnitClass("target")=="死亡骑士" or UnitClass("target")=="猎人" or UnitClass("target")=="武僧" or UnitClass("target")=="圣骑士" or UnitClass("target")=="恶魔猎手" then
   class = true
end

--免疫攻击
if (shown28 and time28>0) and UnitIsPlayer("target") then
   return
end

if msTalentInfo("冰龙吐息") and msGUB("冰龙吐息") and msISC("符文武器增效") then
   msR("符文武器增效")
   return
end

if msGUB("符文武器增效") and msISC("冰霜之柱") then
   msR("冰霜之柱")
   return
end

if msGUB("符文武器增效") and msRuneNumber()>=5 and msISC("湮灭","target") then
   --msR("湮灭","target")
end

if msGFD("target")<10 and msGUB("冰霜之柱") and msISC("仇敌之血") then
   msR("仇敌之血")
   return
end

if msGFD("target")<10 and msGUB("符文武器增效") and msISC("仇敌之血") then
   msR("仇敌之血")
   return
end

if msGHP("target")>95 and UnitPower("player")<80 and msISC("符文武器增效") then
   if msRuneNumber()<2 then
      return
   end
   if msRuneNumber()>=2 and msISC("湮灭","target") then
      msR("湮灭","target")
   end
   return
end

if flag==2 and (msISC("符文刃舞") or (IsEquippedItem("罪邪角斗士的勋章") and msISC("罪邪角斗士的勋章"))) then
   flag=2
   renwu()
   return
end

if flag==2 and (msISC("符文刃舞") or (IsEquippedItem("模块化的白金外壳") and msISC("模块化的白金外壳"))) then
   flag=2
   renwu()
   return
end

if flag==3 and msISC("死亡之握") then
   flag=3
   laren()
   return
end

if flag==4 and msISC("窒息","target") then
   flag=4
   zhixi()
   return
end

if flag==5 and (msGCD("符文武器增效")>1 and msGCD("符文武器增效")<25 and msGCD("冰霜之柱")>1 and msGCD("冰霜之柱")<20) then
   flag=8
end

if flag==5 and (msGCD("符文武器增效")>1 and msGCD("符文武器增效")<25 and msISC("冰霜之柱")) then
   flag=8
end

if flag==5 and (msGCD("符文武器增效")>=20 and msISC("冰霜之柱")) then
   flag=7
end

if flag==5 and (msISC("符文武器增效") and msGCD("冰霜之柱")>1 and msGCD("冰霜之柱")<20) then
   flag=8
end

if flag==5 and (msISC("符文武器增效") and (msISC("冰霜之柱") or msGCD("冰霜之柱")>=20)) then
   flag=5
   baofa()
   return
end

if (UnitAffectingCombat("target") or GetUnitName("target")=="训练假人" or GetUnitName("target")=="团队副本训练假人") then
   if msGBT("宿敌","player")>=1 and msISC("反魔法护罩") then
      msR("反魔法护罩")
      return
   end
   
   if msGUB("燃烧","target") and msISC("反魔法护罩") then
      msR("反魔法护罩")
      return
   end
   
   if msGBT("肾击,正中眉心","player")>=5 and msISC("角斗士勋章") then
      msR("角斗士勋章")
      return
   end
   
   if msGBT("肾击,正中眉心","player")>=5 and msISC("巫妖之躯") then
      msR("巫妖之躯")
      return
   end
   
   if msGBT("邪能爆发","player")>=3 and msISC("角斗士勋章") then
      msR("角斗士勋章")
      return
   end
   
   if msGFD("target")<15 and msUTIP("target") and (msGBT("还击,闪避,剑在人在","target")>=1 or (shown27 and time27>1)) then 
      if (IsEquippedItem("罪邪角斗士的纹章") and msISC("罪邪角斗士的纹章")) then
         msR("罪邪角斗士的纹章")
         return   
      end
      
      if (IsEquippedItem("罪邪角斗士的勋章") and msISC("罪邪角斗士的勋章")) then
         msR("罪邪角斗士的勋章")
         return
      end
   end
   
   if msGFD("target")<15 and msUTIP("target") and (not msGUB("角斗士纹章")) and ((shown27 and time27>1) or msGBT("宿敌,冲动,暗影之刃","player")>=1) and msISC("巫妖之躯") then
      msR("巫妖之躯")
      return
   end
   
   --恶魔变形
   if msGFD("target")<15 and msUTIP("target") and (not msGUB("角斗士纹章")) and msGBT("162264","target")>=10 and msISC("巫妖之躯") then
      msR("巫妖之躯")
      return
   end
   
   if msICS("target","混乱之箭,恐惧,变形术,冰川尖刺,强效炎爆术,眼棱",true) and msGCST("target")<1 then
      if msGFD("target")<15 and msISC("心灵冰冻","target") then
         msR("心灵冰冻","target")
         return
      end
   end
   
   if (msGHP("target")<=30 or msGBT("狂怒回复","target")>=1) and IsEquippedItem("罪邪角斗士的咒徽") and msISC("罪邪角斗士的咒徽") then
      msR("罪邪角斗士的咒徽")
      return
   end
   
   if msUTIP("target") and msGHP("player")<60 and IsEquippedItem("罪邪角斗士的纹章") and msISC("罪邪角斗士的纹章") then
      msR("罪邪角斗士的纹章")
      return
   end
   
   if msGFD("target")<5 and msGHP("player")<70 and msISC("鲜血灌注") then
      msR("鲜血灌注", "player")
      return
   end
   
   if not msGUB("天灾契约") and msGUB("鲜血灌注") and msISC("灵界打击","target") then
      msR("灵界打击","target")
   end
   
   if shown25 then
      num3=1
   end
   
   if num3==1 and (not shown25) and msISC("复活") then
      num3=2
      msR("复活")
   end
   
   if msGHP("player")<=25 and msISC("巫妖之躯") then
      msR("巫妖之躯", "player")
      return
   end
   
   if msGHP("player")<45 and msISC("天灾契约") then
      msR("天灾契约", "player")
      return
   end
   
   --减伤
   if (shown26 and time26>1) then
      if msISC("脓疮打击","target") then
         msR("脓疮打击","target")
      end
      if msRuneNumber()<2 then
         return
      end
   end
   
   if not msGUB("冰龙吐息") and UnitHealthMax("target")>1000000 and msISC("火红烈焰","target") then
      msR("火红烈焰","target")
   end
   
   --[[if not msGUB("冰龙吐息") and group and msISC("295258","target") then
      msR("295258","target")
   end]]
   
   if group and not msGUB("303568","target") and IsEquippedItem("艾什凡的锋锐珊瑚") and msISC("艾什凡的锋锐珊瑚") then
      msR("艾什凡的锋锐珊瑚")
      return
   end
   
   if msGHP("player")<40 and msISC("天灾契约") then
      msR("天灾契约", "player")
      return
   end
   
   if (UnitAffectingCombat("target") or GetUnitName("target")=="训练假人" or GetUnitName("target")=="团队副本训练假人" or GetUnitName("target")=="地下城训练假人") and msGBT("冰霜疫病","target","player")<5 and msISC("凛风冲击","target") then
      msR("/startattack")
      msR("凛风冲击","target")
   end
   
   if msGUB("黑暗援助") and msISC("灵界打击","target") then
      msR("灵界打击","target")
   end
   
   if (group or UnitIsPlayer("target")) and flag==7 and msGFD("target")<3 and msISC("冰霜之柱") then
      msR("冰霜之柱")
   end
   
   if msGUB("冰霜之柱") and msGBC("303568","target","player")>=5 and IsEquippedItem("艾什凡的锋锐珊瑚") and msISC("艾什凡的锋锐珊瑚") then
      msR("艾什凡的锋锐珊瑚")
      return
   end
   
   if not msGUB("冰龙吐息") and msGBC("冷酷之心")==20 and msISC("寒冰锁链","target") then
      msR("寒冰锁链","target")
   end
   
   if not msGUB("冰龙吐息") and msGFD("target")<8 and msISC("冷酷严冬","target") then
      msR("冷酷严冬","target")
   end
   
   if msGUB("冰龙吐息") and msRuneNumber()<2 and msGUB("白霜") and msISC("凛风冲击","target") then
      msR("凛风冲击","target")
   end
   
   if num~=2 and not msGUB("冰龙吐息") and msGUB("白霜") and msISC("凛风冲击","target") then
      msR("凛风冲击","target")
   end
   
   if flag==6 then
      num2=1
      if msGBC("303568","target","player")>=3 and IsEquippedItem("艾什凡的锋锐珊瑚") and msISC("艾什凡的锋锐珊瑚") then
         msR("艾什凡的锋锐珊瑚")
         return
      end
      
      if (group or UnitIsPlayer("target"))and msGFD("target")<6 and msISC("冰霜之柱") then
         msR("冰霜之柱")
      end
      
      if num==2 and msISC("冰霜打击","target") then
         num=1
         msR("冰霜打击","target")
      end
      
      if msGFD("target")<6 and msGUB("杀戮机器") and msISC("冰霜之镰","target") then
         num=2
         msR("冰霜之镰","target")
      end
      
      if msGFD("target")<6 and msISC("冰霜之镰","target") then
         msR("冰霜之镰","target")
      end
   end
   
   if num2~=2 and not msGUB("冰龙吐息") and UnitPower("player")>=90 and msISC("冰霜打击","target") then
      num=1
      msR("冰霜打击","target")      
   end
   
   if flag~=6 and msGUB("冰霜疫病","target","player") and msRuneNumber()>=2 and msISC("湮灭","target") then
      num=1
      msR("湮灭","target")
   end
   
   if flag==8 and msTalentInfo("冰龙吐息") and msGCD("符文武器增效")>1 and msGCD("符文武器增效")<=8 and msISC("冰霜之柱") then
      num2=2
      return
   end
   
   if flag==8 and msTalentInfo("冰龙吐息") and msISC("符文武器增效") and msGCD("冰霜之柱")>1 and msGCD("冰霜之柱")<=8 then
      num2=2
      return
   end
   
   if num2~=2 and not msGUB("冰龙吐息") and msRuneNumber()<2 and UnitPower("player")>=30 and msISC("冰霜打击","target") then
      num=1
      msR("冰霜打击","target")      
   end
   
end
