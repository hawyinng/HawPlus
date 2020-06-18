# HawPlus
World of Warcraft 8.0版本，自动输出脚本插件。

HawPlus：World of Warcraft Battle for Azeroth 8.0

HawPlus_classic：World of Warcraft 怀旧服

解锁器unlocker：

https://winifix.github.io/

https://dark-rotations.slack.com


# 宏使用说明
msSCS后面写几个脚本名字，宏就自动勾选几个脚本，不用列表勾选。----->>>>> PVP is so easy...  

1.启动宏
#showtooltip 心灵冰冻  
/startattack  
/run msSCS("心灵冰冻,邪恶输出")  
/run msScriptList("start")  

2.停止宏
#showtooltip  
/stopcasting  
/run msScriptList("stop")  

3.挂机宏
/script F=CreateFrame("frame")if Y then Y=nil else SendChatMessage("Let's Go","party") Y=function()StaticPopup1Button1:Click()AcceptGroup() end end F:SetScript ("OnUpdate",Y)

# Screenshot of it working in wow
![image](https://github.com/hawyinng/HawPlus/blob/master/images/wow_dk_01.png) ![image](https://github.com/hawyinng/HawPlus/blob/master/images/wow_dk_02.png)


