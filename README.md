# HawPlus
World of Warcraft 8.0版本，自动输出脚本插件。

HawPlus：World of Warcraft Battle for Azeroth 8.0

HawPlus_classic：World of Warcraft 怀旧服

解锁器unlocker：

https://winifix.github.io/

https://app.slack.com/client/TPXR92R35/CPWM037MY


# 宏使用说明
# 启动宏
#showtooltip 心灵冰冻

/startattack

/run msSCS("心灵冰冻,邪恶输出")

/run msScriptList("start")

# 停止宏
#showtooltip

/stopcasting

/run msScriptList("stop")

# 挂机宏
/script F=CreateFrame("frame")if Y then Y=nil else SendChatMessage("Let's Go","party") Y=function()StaticPopup1Button1:Click()AcceptGroup() end end F:SetScript ("OnUpdate",Y)

# Screenshot of it working in wow
屏幕快照 2020-03-10 上午12.26.40
