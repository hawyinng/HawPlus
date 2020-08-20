local grouptype="party"

--print(GetNumGroupMembers())
if GetNumGroupMembers()>5 then  
   grouptype="raid";
else grouptype="party"; 
end

if grouptype=="raid" then
   num3 = 60000
end
if grouptype=="party" then
   num3 = 60000
end

if msICS("player","禅悟冥想,净化矩阵") then
   return
end

if msICS("focus","扭曲的映像,吸取生命") then 
   msR("/cast [target=focus]分筋错骨\n/cast 分筋错骨")
end

if msICS("target","扭曲的映像,吸取生命") then 
   msR("/cast [target=target]分筋错骨\n/cast 分筋错骨")
end

if msGHP("player")<80 and msTalentInfo("金创药") and msISC("金创药") then
   msR("金创药")
end

if msGHP("player")<50 and msISC("星界治疗药水") then
   msR("星界治疗药水", "player")
end

if msGHP("player")<70 and msISC("移花接木") then
   msR("移花接木")
end

if msGHP("player")<30 and IsEquippedItem("罪邪角斗士的纹章") and msGCD("罪邪角斗士的纹章")==0 then
   msR("罪邪角斗士的纹章")
end

if not UnitExists("target") or UnitIsDeadOrGhost("target") then
   msR("/startattack")
end

--[[if UnitAffectingCombat("player") and msISC("误导") then
   msR("/cast [target=pet] 误导")
end]]

--[[if msGCD("清创生血")==0 then msDecursive()
end]]

if flag==1 then
   baofa()
end

if flag==2 then
   aoe()
   return
end

if flag==3 and msISC("扫堂腿") then
   tui()
   return
end

--轻度醉拳数值
local num1, num2 = msGBN("124275", "player")
--print(num1,num2)

if msGHP("player")<30 and not msGUB("躯不坏") and msISC("壮胆酒") then
   msR("壮胆酒")
end

if msGHP("player")<60 and msTalentInfo("金钟罩") and msISC("金钟罩") then
   msR("金钟罩")
end

if UnitExists("target") then
   --[[if msGHP("player")<80 and num2>num3 and msGSC("活血酒")==0 and msTalentInfo("玄牛酒") and msISC("玄牛酒") then
      msR("玄牛酒")
   end]]
   
   if msGHP("player")<80 and num2>num3 and msISC("活血酒") then
      msR("活血酒")
   end
   
   if msGUB("中度醉拳,重度醉拳") and msGHP("player")<80 and msGSC("活血酒")==0 and msTalentInfo("金钟罩") and msISC("金钟罩") then
      msR("金钟罩")
   end
   
   if msGUB("中度醉拳") and msGHP("player")<90 and msISC("活血酒") then
      msR("活血酒")
   end
   
   if msGUB("中度醉拳") and msGHP("player")<60 and not msGUB("金钟罩") and msGSC("活血酒")==0 and msTalentInfo("玄牛酒") and msISC("玄牛酒") then
      msR("玄牛酒")
   end
   
   if msGUB("重度醉拳") and msGSC("活血酒")==0 and msTalentInfo("玄牛酒") and msISC("玄牛酒") then
      msR("玄牛酒")
   end
   
   if msGUB("重度醉拳") and msISC("活血酒") then
      msR("活血酒")
   end
   
   if UnitAffectingCombat("player") and not msUTIP ("target") and msGSC("铁骨酒")>1 and msGBT("铁骨酒")<1 and msISC("铁骨酒") then
      msR("铁骨酒")
   end
   
   if UnitAffectingCombat("player") and msUTIP ("target") and msGBT("铁骨酒")<1 and msISC("铁骨酒") then
      msR("铁骨酒")
   end
   
   if msGFD()<8 and msGBT("碧玉疾风")<=1 and msTalentInfo("碧玉疾风") and msISC("碧玉疾风") then
      msR("碧玉疾风")
   end
   
   if msGFD()<8 and msISC("火焰之息") then
      msR("火焰之息")
   end
   
   if UnitAffectingCombat("target") and msGCD("火焰之息")>1 and msISC("醉酿投") then
      msR("醉酿投")
   end
   
   if msISC("醉酿投") then
      msR("醉酿投")
   end
   
   if msISC("幻灭猛击") then
      msR("幻灭猛击")
   end
   
   if msGPP("player")>40 and msISC("猛虎掌") then
      msR("猛虎掌")
   end
end
