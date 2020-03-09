--增益BUFF
local shown21, unit21, spell21, stack21, time21 = msTMW(2,1)  --晕
local shown22, unit22, spell22, stack22, time22 = msTMW(2,2) --减速
local shown25, unit25, spell25, stack25, time25 = msTMW(2,5) -- 递减
local shown26, unit26, spell26, stack26, time26 = msTMW(2,6) -- 减伤
local shown27, unit27, spell27, stack27, time27 = msTMW(2,7) --爆发BUFF
local shown28, unit28, spell28, stack28, time28 = msTMW(2,8) -- 免疫

flag=4

function zhixi()
   flag=4
   
   --鲜血
   if GetSpecialization()==1 then
      if not shown21 and not shown28 and ((not shown25) or (shown25 and stack25>=50)) 
      and not msGUB("227847,46924,闪避,还击,48792,287081,118038","target") then
         if msISC("窒息","target") then
            msR("窒息","target")
            return
         end
      end
   end
   
   --冰霜
   if GetSpecialization()==2 then
      if not shown21 and not shown28 and ((not shown25) or (shown25 and stack25>=50)) 
      and not msGUB("227847,46924,闪避,还击,48792,287081,118038","target") then
         if msISC("窒息","target") then
            msR("窒息","target")
            return
         end
      end
   end
   
   --邪恶
   if GetSpecialization()==3 then
      if not shown21 and not shown28 and ((not shown25) or (shown25 and stack25>=50)) 
      and not msGUB("227847,46924,闪避,还击,48792,287081,118038","target") then
         if msISC("窒息","target") then
            msR("窒息","target")
            return
         end
      end
   end
end
