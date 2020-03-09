--增益BUFF
local shown21, unit21, spell21, stack21, time21 = msTMW(2,1) --晕
local shown22, unit22, spell22, stack22, time22 = msTMW(2,2) --减速
local shown23, unit23, spell23, stack23, time23 = msTMW(2,3) --HOT
local shown24, unit24, spell24, stack24, time24 = msTMW(2,4) --免疫魔法控制
local shown25, unit25, spell25, stack25, time25 = msTMW(2,5) --递减
local shown26, unit26, spell26, stack26, time26 = msTMW(2,6) --减伤
local shown27, unit27, spell27, stack27, time27 = msTMW(2,7) --爆发BUFF
local shown28, unit28, spell28, stack28, time28 = msTMW(2,8) --免疫

local group=false
if GetNumGroupMembers()<=5 and UnitHealthMax("target")>3000000 then
   grouptype="party";
   group=true
elseif GetNumGroupMembers()>5 and UnitHealthMax("target")>10000000 then 
   grouptype="raid"; 
   group=true
end

if not num then
   num=1
end

if not num3 then
   num3=1
end

if msGUB("296971") then
   return
end

if flag==1 and msISC("枯萎凋零") then
   flag=1
   kuwei()
   return
end

if IsCurrentSpell("枯萎凋零") then
   return
end

if msruninspell() then
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
if (UnitClass("target")=="萨满祭司" or UnitClass("target")=="德鲁伊" or UnitClass("target")=="圣骑士" or UnitClass("target")=="牧师" or UnitClass("target")=="武僧") and UnitPowerMax("target")>50000 then
   class = true
end

if UnitClass("target")=="死亡骑士" then
   class = true
end

--免疫攻击
if (shown28 and time28>0) and UnitIsPlayer("target") then
   return
end

if msGUB("时光护盾","target") and UnitIsPlayer("target") and msISC("死疽打击","target") then
   msR("/petfollow")
   msR("死疽打击","target")
   return
end

if UnitAffectingCombat("target") and UnitIsPlayer("target") and (not shown21) and (not shown24) and ((not shown22) or (shown22 and time22<=1)) and msGBT("寒冰锁链","target")<=1 and msGFD()<30 and msRuneNumber()>=1 and msISC("寒冰锁链","target") then
   msR("寒冰锁链","target")
end

--[[if msGHP("target")>=95 and (not UnitIsPlayer("target")) and msISC("275699") and msRuneNumber()>1 then
   if num==1 and msRuneNumber()>=2 and msISC("脓疮打击","target") then
      msR("脓疮打击","target")
   end
   if num==2 and msGBC("溃烂之伤","target","player")>=5 and msISC("天灾打击","target")  then
      msR("天灾打击","target")      
   end
   if msGBC("溃烂之伤","target","player")==0 then
      num=1
   end
   if msGBC("溃烂之伤","target","player")>=4 then
      num=2
   end
end]]

if not HasPetUI() and msISC("亡者复生") then
   msR("亡者复生")
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
end

if not UnitIsPlayer("target") and flag==5 and (msISC("275699") or msISC("邪恶狂乱")) then
   flag=5
   baofa()
   return
end

if flag==7 and (msISC("黑暗突变","target") or msISC("撕扯","target")) then
   flag=7
   tubian()
end

if msGFD("target")<3 and msGCD("275699")>30 and msTalentInfo("邪恶狂乱") and msISC("邪恶狂乱") then
   msR("邪恶狂乱")
end

if msGFD("target")<3 and msGUB("邪恶狂乱") and msISC("仇敌之血") then
   msR("仇敌之血")
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
   
   --UnitIsPlayer("target") 
   if msICS("target","混乱之箭,冰川尖刺,强效炎爆术",true) and msGCST("target")<1 then
      if msISC("撕扯","target") then
         msR("撕扯","target")
      end
   end
   
   if msICS("target","混乱之箭,冰川尖刺,强效炎爆术",true) and msGCST("target")<1.5 and msISC("黑暗突变") then
      if msISC("黑暗突变","pet") then
         msR("黑暗突变","pet")
         return
      end
      if msISC("跳跃","target") then
         msR("跳跃","target")
      end
   end
   
   if msICS("target","眼棱",true) then
      if msGFD("target")<15 and msISC("心灵冰冻","target") then
         msR("心灵冰冻","target")
         return
      end
   end
   
   if msICS("target","混乱之箭,恐惧,变形术,冰川尖刺,强效炎爆术",true) and msGCST("target")<1 then
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
   
   if UnitIsPlayer("target") and flag==5 and (msISC("275699") or msISC("邪恶狂乱")) then
      flag=5
      baofa()
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
   
   if UnitHealthMax("target")>1000000 and msISC("火红烈焰","target") then
      msR("火红烈焰","target")
   end
   
   if msGBT("狂怒回复,猩红之瓶,162264","target")>=1 and msRuneNumber()<1 and msISC("灵魂收割","target") then
      msR("灵魂收割","target")
   end
   
   if msGUB("黑暗援助") and msISC("灵界打击","target") then
      msR("灵界打击","target")
   end
   
   if UnitIsPlayer("target") and msGHP("player")<=70 and msISC("灵界打击","target") then
      msR("灵界打击","target")
   end
   
   if msGBT("狂怒回复,猩红之瓶,162264","target")>=1 and msISC("死疽打击","target") then
      msR("死疽打击","target")
   end
   
   if (class or (shown23 and time23>1)) and msISC("死疽打击","target") then
      msR("死疽打击","target") 
   end
   
   if group and not msGUB("303568","target") and IsEquippedItem("艾什凡的锋锐珊瑚") and msGCD("艾什凡的锋锐珊瑚")==0 then
      msR("艾什凡的锋锐珊瑚")
      return
   end
   
   if (UnitAffectingCombat("target") or GetUnitName("target")=="训练假人" or GetUnitName("target")=="团队副本训练假人") and (not shown24) and msGBT("恶性瘟疫","target","player")<5 and msISC("爆发","target") then
      msR("/startattack")
      msR("爆发","target")
   end
   
   if (not UnitIsPlayer("target") and  UnitHealthMax("target")>1000000) and msGUB("溃烂之伤","target","player") and msISC("黑暗突变") then
      msR("黑暗突变")
   end
   
   if flag==6 and UnitIsPlayer("target") and UnitPower("player")>=60 and msISC("传染") then
      msR("传染")
   end
   
   if msGUB("邪恶狂乱") and msGBC("溃烂之伤","target","player")>0 and msISC("天灾打击","target") then
      msR("天灾打击","target")
   end
   
   if msGBC("溃烂之伤","target","player")>0 and msGUB("枯萎凋零") and msISC("天灾打击","target") then
      msR("天灾打击","target")
   end
   
   if msGBT("溃烂之伤","target","player")>0 and msGBT("溃烂之伤","target","player")<=5 and msISC("天灾打击","target") then
      msR("天灾打击","target")
   end
   
   if flag~=6 and msGUB("末日突降") and msISC("凋零缠绕","target") then
      msR("凋零缠绕","target")
   end
   
   if msGUB("邪恶狂乱") and msGBC("溃烂之伤","target","player")==0 and msISC("脓疮打击","target") then
      msR("脓疮打击","target")
   end
   
   if flag~=6 and UnitPower("player")>=85 and msISC("凋零缠绕","target") then
      msR("凋零缠绕","target")
   end
   
   if msGCD("275699")>30 and num==1 and msGBC("溃烂之伤","target","player")<=3 and msGCD("脓疮打击")>1 and msTalentInfo("灵魂收割") and msISC("灵魂收割","target") then
      msR("灵魂收割","target")
   end
   
   if not UnitIsPlayer("target") and not msISC("天灾打击","target") and msGCD("脓疮打击")>1 and msTalentInfo("灵魂收割") and msISC("灵魂收割","target") then
      msR("灵魂收割","target")
   end
   
   if num==1 and flag~=6 and not msISC("脓疮打击","target") and msISC("凋零缠绕","target") then
      msR("凋零缠绕","target")
   end
   
   if flag~=6 and not msISC("天灾打击","target") and not msISC("脓疮打击","target") and msISC("凋零缠绕","target") then
      msR("凋零缠绕","target")
   end
   
   if flag~=6 and not msISC("天灾打击","target") and msGBC("溃烂之伤","target","player")==0 and msISC("凋零缠绕","target") then
      msR("凋零缠绕","target")
   end
   
   if flag==6 or UnitIsPlayer("target") then
      if msGBC("303568","target","player")>=3 and IsEquippedItem("艾什凡的锋锐珊瑚") and msGCD("艾什凡的锋锐珊瑚")==0 then
         msR("艾什凡的锋锐珊瑚")
         return
      end
      
      if msGBC("溃烂之伤","target","player")>0 and msGUB("枯萎凋零") and msISC("天灾打击","target") then
         msR("天灾打击","target")
      end
      
      if msGBC("溃烂之伤","target","player")==0 and msGUB("枯萎凋零") and msISC("脓疮打击","target") then
         msR("脓疮打击","target")
      end
      
      if msGBC("溃烂之伤","target","player")>0 and msRuneNumber()>=5 and msISC("天灾打击","target") then
         msR("天灾打击","target")
      end
      
      if flag==6 and (not UnitIsPlayer("target")) and UnitPower("player")>=40 and msISC("传染") then
         msR("传染")
      end
      
      if msGBC("溃烂之伤","target","player")>0 and msISC("天灾打击","target") then
         msR("天灾打击","target")
      end
      
      if msISC("脓疮打击","target") then
         msR("脓疮打击","target")
      end
   end
   
   if num==1 and msRuneNumber()>=2 and msISC("脓疮打击","target") then
      msR("脓疮打击","target")
   end
   
   if num==2 and msRuneNumber()>=1 and msISC("天灾打击","target")  then
      msR("天灾打击","target")      
   end
   
   if msGBC("溃烂之伤","target","player")==0 then
      num=1
   end
   
   if msGBC("溃烂之伤","target","player")>=4 then
      num=2
   end   
end
