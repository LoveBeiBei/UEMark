--[[
    说明：覆盖蓝图事件时，只需要在返回的table中声明 Receive{EventName}

    例如：
    function M:ReceiveBeginPlay()
    end

    除了蓝图事件可以覆盖，也可以直接声明 {FunctionName} 来覆盖Function。
    如果需要调用被覆盖的蓝图Function，可以通过 self.Overridden.{FunctionName}(self, ...) 来访问

    例如：
    function M:SayHi(name)
        self.Overridden.SayHi(self, name)
    end

    注意：这里不可以写成 self.Overridden:SayHi(name)
]] --

require "UnLua"

local Screen = require "Tutorials.Screen"

local M = Class()

function M:ReceiveBeginPlay()
    print("222------------------")

    local msg = self:SayHi("陌生人")
    print("333------------------")

    Screen.Print(msg)
end

-- function M:ReceiveTick()
--     print("111------------------")

-- end

function M:testHello()
    print("-testHello-----------------")
    self.Overridden.testHello()
end

function M:SayHi(name)
    print("444------------------"..name)

    local origin = name--self.Overridden.SayHi(self, name)
    print("555------------------"..name)
    return origin .. "\n\n" ..
        [[现在我们已经相互熟悉了，这是来自Lua的问候。

        —— 本示例来自 "Content/Script/Tutorials.02_OverrideBlueprintEvents.lua"
    ]]
end

return M
