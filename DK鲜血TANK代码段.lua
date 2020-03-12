--增益BUFF
local shown21, unit21, spell21, stack21, time21 = msTMW(2,1) --递减
local shown22, unit22, spell22, stack22, time22 = msTMW(2,2) --减速
local shown25, unit25, spell25, stack25, time25 = msTMW(2,5) --晕
local shown26, unit26, spell26, stack26, time26 = msTMW(2,6) --减伤
local shown27, unit27, spell27, stack27, time27 = msTMW(2,7) --爆发BUFF
local shown28, unit28, spell28, stack28, time28 = msTMW(2,8) --免疫

if not num then
   num=1
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

if msICS("target","恐惧咆哮,毒性新星,恶毒臭气") and msISC("心灵冰冻","target") then
   msR("心灵冰冻","target")
   return
end

if msGHP("player")<50 and msISC("治疗石") then
   msR("治疗石", "player")
end

--if msGHP("player")<50 and msISC("海滨治疗药水") then
--msR("海滨治疗药水", "player")
--end

if msruninspell() then
end

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

if flag==2 and (msISC("符文刃舞") or (IsEquippedItem("杰斯的咆哮") and msISC("杰斯的咆哮"))) then
   flag=2
   renwu()
   return
end

if flag==2 and (msISC("符文刃舞") or (IsEquippedItem("罪邪角斗士的徽章") and msISC("罪邪角斗士的徽章"))) then
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

if UnitAffectingCombat("player") then 
   if msGHP("player")<90 and msISC("火红烈焰","player") then
      msR("火红烈焰","player")
   end
   
   if msGHP("player")<75 and not msGUB("吸血鬼之血") and IsEquippedItem("罪邪角斗士的纹章") and msISC("罪邪角斗士的纹章") then
      msR("罪邪角斗士的纹章")
      return
   end
   
   if msGHP("player")<85 and msTalentInfo("符文分流") and not msGUB("墓石,278543,冰封之韧") and msRuneNumber()>=1 and msGBT("符文分流")<=1 and msISC("符文分流") then
      msR("符文分流")
   end
   
   if msGHP("player")<80 and msTalentInfo("墓石") and not msGUB("55233,278543") and msGBC("白骨之盾")>=5 and msISC("墓石") then
      msR("墓石")
   end
   
   if msGHP("player")<75 and msTalentInfo("白骨风暴") and UnitPower("player")>=80 and msISC("白骨风暴","target") then
      msR("白骨风暴","target")
   end
   
   if msGHP("player")<75 and msTalentInfo("白骨风暴") and UnitPower("player")<80 and msGBC("白骨之盾")>0 and msISC("心脏打击","target") then
      msR("心脏打击","target")
   end
   
   if msGUB("吸血鬼之血") and msISC("深渊之护") then
      msR("深渊之护")
   end
   
   if msGHP("player")<60 and not msGUB("白骨风暴,219809") and msISC("吸血鬼之血") then
      msR("吸血鬼之血", "player")
      return
   end
   
   if msGHP("player")<40 and msISC("吸血鬼之血") then
      msR("吸血鬼之血", "player")
      return
   end
   
   if msGHP("player")<30 and not msGUB("白骨风暴,219809,55233") and msISC("冰封之韧") then
      msR("冰封之韧")
      return
   end
   
   --符文刃舞
   if msGUB("278543") then
      if msGBC("白骨之盾")<5 and msISC("骨髓分裂","target") then
         msR("骨髓分裂","target")
         return
      end
      if msISC("心脏打击","target") then
         msR("心脏打击","target")
      end
   end
   
   if msTalentInfo("白骨风暴") and not msGUB("白骨风暴") and msGHP("player")<90 and msGCD("白骨风暴")>5 and UnitPower("player")>=45 and msISC("灵界打击","target") then
      msR("灵界打击","target")
      return
   end
   
   if UnitAffectingCombat("target") and msGFD("target")>8 and not msGUB("血之疫病","target") and msISC("死神的抚摩","target") then
      msR("死神的抚摩","target")
   end
   
   if msGBC("白骨之盾")<5 and msRuneNumber()>=2 and msISC("骨髓分裂","target") then
      msR("/startattack")
      msR("骨髓分裂","target")
   end
   
   if msGFD("target")<10 and msISC("血液沸腾") then
      msR("血液沸腾")
   end
   
   if msTalentInfo("鲜血印记") and not msGUB("鲜血印记","target") and msISC("鲜血印记","target") then
      msR("鲜血印记","target")
   end
   
   if msTalentInfo("符文打击") and msRuneNumber()<4 and msISC("符文打击","target") then
      msR("符文打击","target")
   end
   
   if UnitPower("player")>=90 and msISC("灵界打击","target") then
      msR("灵界打击","target")
   end
   
   if not msTalentInfo("白骨风暴") and msGHP("player")<90 and msISC("灵界打击","target") then
      msR("灵界打击","target")
   end
   
   if msTalentInfo("白骨风暴") and not msGUB("白骨风暴") and ((msGHP("player")>=80 and msGHP("player")<90) or msGCD("白骨风暴")>5) and UnitPower("player")>=45 and msISC("灵界打击","target") then
      msR("灵界打击","target")
   end
   
   if msTalentInfo("符文打击") and msRuneNumber()<4 and msISC("符文打击","target") then
      msR("符文打击","target")
   end
   
   if msGUB("白骨风暴") and msGBC("白骨之盾")>0 and msISC("心脏打击") then
      msR("心脏打击","target")      
   end
   
   if msTalentInfo("符文分流") and msGBC("白骨之盾")>=4 and msRuneNumber()>2 and msISC("心脏打击","target") then
      msR("心脏打击","target")
   end
   
   if not msTalentInfo("符文分流") and msGBC("白骨之盾")>=4 and msRuneNumber()>1 and msISC("心脏打击","target") then
      msR("心脏打击","target")      
   end
   
   if msRuneNumber()>=3 and msISC("心脏打击","target") then
      msR("心脏打击","target")
   end
end
