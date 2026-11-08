--[[
    Infinite Admin V4 (Mobile Responsive) — Executor Build
    Press RIGHT SHIFT (or tap top right on mobile) to toggle. Console: ;command [arg]
]]

if not game or not game.Players then
    return warn("[IA4] Not in a Roblox environment.")
end

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UIS              = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")
local HttpService      = game:GetService("HttpService")
local TeleportService  = game:GetService("TeleportService")
local VirtualUser      = game:GetService("VirtualUser")
local Workspace        = workspace
local SoundService     = game:GetService("SoundService")
local TextChatService  = game:GetService("TextChatService")
local StarterGui       = game:GetService("StarterGui")
local Stats            = game:GetService("Stats")
local LP               = Players.LocalPlayer

local function getGuiParent()
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then
        local probe = Instance.new("Folder")
        local ok2 = pcall(function() probe.Parent = cg end)
        probe:Destroy()
        if ok2 then return cg end
    end
    return LP:WaitForChild("PlayerGui")
end
local GuiParent = getGuiParent()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "InfiniteAdminV4"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999

pcall(function()
    local protector = (syn and syn.protect_gui) or protect_gui or gethui
    if protector then
        if protector == gethui then
            ScreenGui.Parent = protector()
        else
            protector(ScreenGui)
            ScreenGui.Parent = GuiParent
        end
    end
end)
if not ScreenGui.Parent then ScreenGui.Parent = GuiParent end

pcall(function()
    local prev = GuiParent:FindFirstChild("InfiniteAdminV4")
    if prev and prev ~= ScreenGui then prev:Destroy() end
end)

local T = {
    Bg=Color3.fromRGB(15,15,20), Bg2=Color3.fromRGB(22,22,30),
    Surface=Color3.fromRGB(30,30,40), Surface2=Color3.fromRGB(40,40,54),
    Accent=Color3.fromRGB(99,102,241), Text=Color3.fromRGB(240,240,248),
    Sub=Color3.fromRGB(150,150,168), Success=Color3.fromRGB(52,211,153),
    Danger=Color3.fromRGB(248,113,113), Warn=Color3.fromRGB(251,191,36),
    Stroke=Color3.fromRGB(55,55,72),
}
local function New(c,p) local o=Instance.new(c); for k,v in pairs(p or {}) do o[k]=v end; return o end
local function Corner(r) return New("UICorner",{CornerRadius=UDim.new(0,r or 8)}) end
local function Stroke(c,t) return New("UIStroke",{Color=c or T.Stroke,Thickness=t or 1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border}) end
local function Tween(o,t,p,s,d) return TweenService:Create(o,TweenInfo.new(t or .18,s or Enum.EasingStyle.Quint,d or Enum.EasingDirection.Out),p) end
local function Safe(fn) return function(...) local ok,e=pcall(fn,...); if not ok then warn("[IA4]",e) end return ok end end

local function GetChar() return LP.Character or LP.CharacterAdded:Wait() end
local function GetHum()  local c=LP.Character; return c and c:FindFirstChildOfClass("Humanoid") end
local function GetRoot() local c=LP.Character; return c and c:FindFirstChild("HumanoidRootPart") end

local Blur = New("BlurEffect",{Size=0,Parent=Lighting})

local function Notify(msg, kind)
    kind = kind or "info"
    local color = kind=="ok" and T.Success or kind=="err" and T.Danger or kind=="warn" and T.Warn or T.Accent
    local holder = ScreenGui:FindFirstChild("Notifications")
    if not holder then
        holder = New("Frame",{Name="Notifications",Size=UDim2.new(0,280,0,300),Position=UDim2.new(1,-300,1,-320),BackgroundTransparency=1,Parent=ScreenGui})
        New("UIListLayout",{Padding=UDim.new(0,6),VerticalAlignment=Enum.VerticalAlignment.Bottom,SortOrder=Enum.SortOrder.LayoutOrder,Parent=holder})
    end
    local n = New("Frame",{Size=UDim2.new(1,0,0,42),BackgroundColor3=T.Surface,BackgroundTransparency=1,Parent=holder})
    Corner(8)
    local s = Stroke(color,1.5); s.Transparency=1; s.Parent=n
    New("Frame",{Size=UDim2.new(0,3,1,0),BackgroundColor3=color,BorderSizePixel=0,Parent=n}); Corner(2)
    New("TextLabel",{Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,14,0,0),BackgroundTransparency=1,Text=msg,TextColor3=T.Text,Font=Enum.Font.GothamMedium,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,Parent=n})
    Tween(n,.25,{BackgroundTransparency=0}); Tween(s,.25,{Transparency=0})
    task.delay(2.2,function() Tween(n,.25,{BackgroundTransparency=1}); Tween(s,.25,{Transparency=1}); task.wait(.3); n:Destroy() end)
end

-- =========================================================
-- GUI SHELL (RESPONSIVE)
-- =========================================================
local viewport = Workspace.CurrentCamera.ViewportSize
local isMobile = UIS.TouchEnabled and not UIS.MouseEnabled

local W = isMobile and math.min(viewport.X - 40, 600) or 680
local H = isMobile and math.min(viewport.Y - 40, 480) or 480
local sidebarW = isMobile and 70 or 170

local Main = New("Frame",{
    Size=UDim2.new(0, W, 0, H),
    Position=UDim2.new(.5, -W/2, .5, -H/2),
    BackgroundColor3=T.Bg, BorderSizePixel=0, Parent=ScreenGui,
})
Corner(14); Stroke(T.Stroke,1).Parent = Main
Tween(Blur,.3,{Size=6})

local function resizeUI()
    local vp = Workspace.CurrentCamera.ViewportSize
    local nW = isMobile and math.min(vp.X - 40, 600) or 680
    local nH = isMobile and math.min(vp.Y - 40, 480) or 480
    Main.Size = UDim2.new(0, nW, 0, nH)
    Main.Position = UDim2.new(.5, -nW/2, .5, -nH/2)
    W, H = nW, nH
end
Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resizeUI)

local TopBar = New("Frame",{Size=UDim2.new(1,0,0,48),BackgroundColor3=T.Bg2,BorderSizePixel=0,Parent=Main}); Corner(14)
New("Frame",{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,1,-14),BackgroundColor3=T.Bg2,BorderSizePixel=0,Parent=TopBar})
New("Frame",{Size=UDim2.new(0,18,0,18),Position=UDim2.new(0,14,.5,-9),BackgroundColor3=T.Accent,BackgroundTransparency=.7,BorderSizePixel=0,Parent=TopBar}); Corner(9)
New("Frame",{Size=UDim2.new(0,10,0,10),Position=UDim2.new(0,18,.5,-5),BackgroundColor3=T.Accent,BorderSizePixel=0,Parent=TopBar}); Corner(5)
New("TextLabel",{Size=UDim2.new(0,240,1,0),Position=UDim2.new(0,38,0,0),BackgroundTransparency=1,Text="Infinite Admin  •  V4",TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,Parent=TopBar})
local CmdCount = New("TextLabel",{Size=UDim2.new(0,120,1,0),Position=UDim2.new(0,240,0,0),BackgroundTransparency=1,Text="",TextColor3=T.Accent,Font=Enum.Font.GothamMedium,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=TopBar})
local StatusDot = New("Frame",{Size=UDim2.new(0,8,0,8),Position=UDim2.new(1,-120,.5,-4),BackgroundColor3=T.Success,BorderSizePixel=0,Parent=TopBar}); Corner(4)
local StatusLbl = New("TextLabel",{Size=UDim2.new(0,80,1,0),Position=UDim2.new(1,-108,0,0),BackgroundTransparency=1,Text="Ready",TextColor3=T.Sub,Font=Enum.Font.GothamMedium,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=TopBar})
local function SetStatus(txt,ok)
    StatusLbl.Text=txt; StatusLbl.TextColor3=ok and T.Success or T.Danger; StatusDot.BackgroundColor3=ok and T.Success or T.Danger
    task.delay(1.5,function() StatusLbl.Text="Ready"; StatusLbl.TextColor3=T.Sub; StatusDot.BackgroundColor3=T.Success end)
end
local CloseBtn = New("TextButton",{Size=UDim2.new(0,30,0,30),Position=UDim2.new(1,-42,.5,-15),BackgroundColor3=T.Surface,Text="✕",TextColor3=T.Sub,Font=Enum.Font.GothamBold,TextSize=13,AutoButtonColor=false,Parent=TopBar}); Corner(8)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible=false; Blur.Size=0 end)

local Sidebar = New("Frame",{Size=UDim2.new(0,sidebarW,1,-58),Position=UDim2.new(0,10,0,52),BackgroundColor3=T.Bg2,BorderSizePixel=0,Parent=Main}); Corner(10)
New("UIListLayout",{Padding=UDim.new(0,3),SortOrder=Enum.SortOrder.LayoutOrder,Parent=Sidebar})
New("UIPadding",{PaddingTop=UDim.new(0,8),PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),PaddingBottom=UDim.new(0,8),Parent=Sidebar})

local Content = New("Frame",{Size=UDim2.new(1,-(sidebarW+20),1,-100),Position=UDim2.new(0,sidebarW+10,0,52),BackgroundTransparency=1,Parent=Main})
local SearchWrap = New("Frame",{Size=UDim2.new(1,0,0,38),BackgroundColor3=T.Bg2,BorderSizePixel=0,Parent=Content}); Corner(9); Stroke(T.Stroke,1).Parent = SearchWrap
New("TextLabel",{Size=UDim2.new(0,34,1,0),BackgroundTransparency=1,Text="🔍",TextSize=14,TextColor3=T.Sub,Parent=SearchWrap})
local SearchBox = New("TextBox",{Size=UDim2.new(1,-42,1,0),Position=UDim2.new(0,36,0,0),BackgroundTransparency=1,Text="",PlaceholderText="Search commands...",PlaceholderColor3=T.Sub,TextColor3=T.Text,Font=Enum.Font.GothamMedium,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,Parent=SearchWrap})
local Scroll = New("ScrollingFrame",{Size=UDim2.new(1,0,1,-48),Position=UDim2.new(0,0,0,46),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=4,ScrollBarImageColor3=T.Accent,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,Parent=Content})
New("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder,Parent=Scroll})

local ConsoleBar = New("Frame",{Size=UDim2.new(1,-(sidebarW+20),0,38),Position=UDim2.new(0,sidebarW+10,1,-48),BackgroundColor3=T.Bg2,BorderSizePixel=0,Parent=Main}); Corner(9); Stroke(T.Accent,1).Parent = ConsoleBar
New("TextLabel",{Size=UDim2.new(0,26,1,0),BackgroundTransparency=1,Text="›",TextColor3=T.Accent,Font=Enum.Font.GothamBold,TextSize=20,Parent=ConsoleBar})
local ConsoleBox = New("TextBox",{Size=UDim2.new(1,-30,1,0),Position=UDim2.new(0,24,0,0),BackgroundTransparency=1,Text="",PlaceholderText=";command arg",PlaceholderColor3=T.Sub,TextColor3=T.Text,Font=Enum.Font.Code,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,Parent=ConsoleBar})

-- =========================================================
-- COMMAND REGISTRY + HELPERS
-- =========================================================
local Commands = {}
local byName = {}
local function C(tab,name,desc,fn)
    local c = {tab=tab,name=name,desc=desc,exec=fn}
    table.insert(Commands,c); byName[name:lower()] = c
end

local function ws(v) local h=GetHum(); if h then h.WalkSpeed=v end end
local function jp(v) local h=GetHum(); if h then h.UseJumpPower=true; h.JumpPower=v end end
local function jh(v) local h=GetHum(); if h then h.UseJumpPower=false; h.JumpHeight=v end end
local function hip(v) local h=GetHum(); if h then h.HipHeight=v end end
local function god() local h=GetHum(); if h then h.MaxHealth=math.huge; h.Health=math.huge end end
local function ungod() local h=GetHum(); if h then h.MaxHealth=100; h.Health=100 end end
local function tp(pos) local r=GetRoot(); if r then r.CFrame=CFrame.new(pos) end end
local function tpPlr(plr)
    if not plr or not plr.Character then return end
    local rr = plr.Character:FindFirstChild("HumanoidRootPart"); local r = GetRoot()
    if rr and r then r.CFrame = rr.CFrame * CFrame.new(0,0,3) end
end
local function anchor(a) local r=GetRoot(); if r then r.Anchored=a end end
local function setInvis(v)
    local c = LP.Character; if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then p.Transparency = v and 1 or 0
        elseif p:IsA("Decal") or p:IsA("Texture") then p.Transparency = v and 1 or 0 end
    end
end
local function nearestPlayer()
    local r = GetRoot(); if not r then return end
    local best,d = nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local rr = p.Character:FindFirstChild("HumanoidRootPart")
            if rr then local dd=(rr.Position-r.Position).Magnitude; if dd<d then d=dd; best=p end end
        end
    end
    return best
end
local function allOthers(fn) for _,p in ipairs(Players:GetPlayers()) do if p ~= LP then fn(p) end end end
local function nearestPart()
    local r=GetRoot(); if not r then return end
    local best,d = nil,math.huge
    for _,v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsDescendantOf(LP.Character) then
            local dd=(v.Position-r.Position).Magnitude
            if dd<d then d=dd; best=v end
        end
    end
    return best
end
local function humOf(p) return p.Character and p.Character:FindFirstChildOfClass("Humanoid") end
local function rootOf(p) return p.Character and p.Character:FindFirstChild("HumanoidRootPart") end
local function giveTool(name, target)
    target = target or LP
    local bp = target:FindFirstChild("Backpack")
    if not bp then return end
    local t = Instance.new("Tool", bp); t.Name = name; t.RequiresHandle = true
    local h = Instance.new("Part", t); h.Name = "Handle"; h.Size = Vector3.new(1,2,1)
    h.Transparency = 0; h.Color = Color3.fromRGB(120,120,120)
end

local function raycastFromViewport(x, y)
    local cam = Workspace.CurrentCamera
    local ray = cam:ViewportPointToRay(x, y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LP.Character, cam }
    local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
    if not result then return nil end
    return result.Instance, result.Position, result.Normal
end

local function httpGet(url)
    if typeof(game.HttpGet) == "function" then
        local ok, res = pcall(function() return game:HttpGet(url) end)
        if ok and type(res) == "string" then return res end
    end
    local req = syn and syn.request or fluxus and fluxus.request or http_request or request
    if req then
        local ok, res = pcall(req, { Url = url, Method = "GET" })
        if ok and res and res.Body then return res.Body end
    end
    local ok, res = pcall(function() return HttpService:GetAsync(url) end)
    if ok and type(res) == "string" then return res end
    return nil
end

-- =========================================================
-- HOME
-- =========================================================
local function hop()
    local body = httpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
    if not body then Notify("HttpGet failed","warn") return end
    local ok, res = pcall(function() return HttpService:JSONDecode(body) end)
    if ok and res and res.data then
        for _,s in ipairs(res.data) do
            if s.id ~= game.JobId and s.playing < s.maxPlayers then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LP); return
            end
        end
    end
    Notify("No servers","warn")
end
for _,c in ipairs({
    {"Rejoin","Rejoin current server", function() TeleportService:Teleport(game.PlaceId,LP) end},
    {"Server Hop","Join another server", hop},
    {"Respawn","Reset character", function() GetChar():BreakJoints() end},
    {"Full Health","Restore HP", function() local h=GetHum(); if h then h.Health=h.MaxHealth end end},
    {"Copy Place ID","Copy PlaceId", function() if setclipboard then setclipboard(tostring(game.PlaceId)) end Notify("Copied","ok") end},
    {"Copy Job ID","Copy JobId", function() if setclipboard then setclipboard(game.JobId) end Notify("Copied","ok") end},
    {"Copy User ID","Copy your UserId", function() if setclipboard then setclipboard(tostring(LP.UserId)) end Notify("Copied","ok") end},
    {"Copy Game Link","Copy game URL", function() if setclipboard then setclipboard("https://www.roblox.com/games/"..game.PlaceId) end Notify("Copied","ok") end},
    {"Ping","Show ping", function() Notify("Ping "..math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()).."ms","info") end},
    {"FPS Counter","Print FPS", function() local t=os.clock(); for _=1,30 do RunService.RenderStepped:Wait() end Notify("FPS "..math.floor(30/(os.clock()-t)),"info") end},
    {"Hide GUI","Hide window", function() Main.Visible=false; Blur.Size=0 end},
    {"Anti-AFK","Prevent AFK kick", function()
        LP.Idled:Connect(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)
        Notify("Anti-AFK on","ok")
    end},
    {"Print Players","Print all players", function()
        for _,p in ipairs(Players:GetPlayers()) do print(p.Name, p.UserId) end
        Notify("Printed "..#Players:GetPlayers(),"ok")
    end},
    {"Print Place Info","Print place info", function() print("PlaceId:",game.PlaceId,"JobId:",game.JobId,"Creator:",game.CreatorId) Notify("Printed","ok") end},
    {"Print Game Name","Print game name", function() print(game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name) Notify("Printed","ok") end},
    {"Server Time","Print server time", function() Notify(os.date("%X"),"info") end},
    {"Cursor Pos","Show cursor", function() local m=UIS:GetMouseLocation(); Notify("Cursor "..math.floor(m.X)..","..math.floor(m.Y),"info") end},
    {"Camera Info","Print camera", function() Notify(tostring(Workspace.CurrentCamera.CFrame.Position),"info") end},
    {"Clear Output","Clear print line", function() print("\n\n") end},
    {"Dump JobId","Copy JobId", function() if setclipboard then setclipboard(game.JobId) end Notify("Dumped","ok") end},
    {"Player Count","Print player count", function() Notify(#Players:GetPlayers().." players","info") end},
    {"Kick Log","Log joins/leaves", function()
        Players.PlayerAdded:Connect(function(p) print("[JOIN]",p.Name) end)
        Players.PlayerRemoving:Connect(function(p) print("[LEAVE]",p.Name) end)
        Notify("Logging","ok")
    end},
    {"Chat Log","Log chat messages", function()
        for _,p in ipairs(Players:GetPlayers()) do
            p.Chatted:Connect(function(m) print("["..p.Name.."]",m) end)
        end
        Notify("Chat logging","ok")
    end},
}) do C("Home", c[1], c[2], Safe(c[3])) end

-- =========================================================
-- PLAYER
-- =========================================================
local playerActions = {
    {"God Mode", god}, {"Ungod", ungod},
    {"Invisible", function() setInvis(true) end},
    {"Visible", function() setInvis(false) end},
    {"Kill Self", function() GetChar():BreakJoints() end},
    {"Reset HP", function() local h=GetHum(); if h then h.Health=h.MaxHealth end end},
    {"Freeze", function() anchor(true) end},
    {"Unfreeze", function() anchor(false) end},
    {"Sit", function() local h=GetHum(); if h then h.Sit=true end end},
    {"Stand", function() local h=GetHum(); if h then h.Sit=false; h.Jump=true end end},
    {"Jump", function() local h=GetHum(); if h then h.Jump=true end end},
    {"Dance", function() local h=GetHum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end},
    {"Swim", function() local h=GetHum(); if h then h:ChangeState(Enum.HumanoidStateType.Swimming) end end},
    {"Climb", function() local h=GetHum(); if h then h:ChangeState(Enum.HumanoidStateType.Climbing) end end},
    {"Fall", function() local h=GetHum(); if h then h:ChangeState(Enum.HumanoidStateType.Freefall) end end},
    {"Ragdoll", function() local h=GetHum(); if h then h.PlatformStand=true; task.wait(1.2); h.PlatformStand=false end end},
    {"Equip First Tool", function() local bp=LP:FindFirstChild("Backpack"); local t=bp and bp:GetChildren()[1]; if t and t:IsA("Tool") then GetHum():EquipTool(t) end end},
    {"Unequip Tool", function() local h=GetHum(); if h then h:UnequipTools() end end},
    {"Drop All Tools", function()
        local bp=LP:FindFirstChild("Backpack"); if bp then for _,t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then t.Parent=Workspace end end end
    end},
    {"No Clip", function() for _,p in ipairs(GetChar():GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end},
    {"Restore Collision", function() for _,p in ipairs(GetChar():GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end},
    {"Big Head", function() local h=GetChar():FindFirstChild("Head"); if h then h.Size = h.Size * 2 end end},
    {"Small Head", function() local h=GetChar():FindFirstChild("Head"); if h then h.Size = h.Size * 0.5 end end},
    {"Random Colors", function() for _,c in ipairs(GetChar():GetChildren()) do if c:IsA("BasePart") then c.Color=Color3.new(math.random(),math.random(),math.random()) end end end},
    {"Neon Body", function() for _,p in ipairs(GetChar():GetDescendants()) do if p:IsA("BasePart") then p.Material=Enum.Material.Neon end end end},
    {"Force Field", function() if GetChar() then Instance.new("ForceField",GetChar()) end end},
    {"Fire Aura", function() local r=GetRoot(); if r then local f=Instance.new("Fire",r); f.Size=8; f.Heat=10 end end},
    {"Sparkles Aura", function() local r=GetRoot(); if r then local s=Instance.new("Sparkles",r); s.SparkleColor=Color3.new(1,1,0) end end},
    {"Smoke Aura", function() local r=GetRoot(); if r then Instance.new("Smoke",r) end end},
    {"Remove Effects", function()
        local c=GetChar(); if not c then return end
        for _,v in ipairs(c:GetDescendants()) do
            if v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("Smoke") or v:IsA("ForceField") then v:Destroy() end
        end
    end},
    {"Heal All", function() for _,p in ipairs(Players:GetPlayers()) do local h=humOf(p); if h then h.Health=h.MaxHealth end end end},
    {"Kill All", function() for _,p in ipairs(Players:GetPlayers()) do if p~=LP then local h=humOf(p); if h then h.Health=0 end end end end},
    {"Bring All", function()
        local r=GetRoot(); if not r then return end
        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= LP then local rr=rootOf(p); if rr then rr.CFrame = r.CFrame * CFrame.new(math.random(-4,4),0,math.random(-4,4)) end end
        end
    end},
    {"Kill Nearest", function() local p=nearestPlayer(); local h=p and humOf(p); if h then h.Health=0 end end},
    {"Bring Nearest", function() tpPlr(nearestPlayer()) end},
    {"Heal Nearest", function() local p=nearestPlayer(); local h=p and humOf(p); if h then h.Health=h.MaxHealth end end},
    {"Spectate Nearest", function() local p=nearestPlayer(); if p and p.Character then Workspace.CurrentCamera.CameraSubject = p.Character:FindFirstChildOfClass("Humanoid") end end},
    {"Restore Camera", function() Workspace.CurrentCamera.CameraSubject = GetHum() end},
    {"Show Nametag", function() for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChildOfClass("Humanoid"); if h then h.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.Viewer; h.NameDisplayDistance=10000 end end end end},
    {"Anti Fling", function()
        RunService.Heartbeat:Connect(function()
            local r=GetRoot(); if not r then return end
            local av=r:FindFirstChildOfClass("BodyAngularVelocity"); if av then av:Destroy() end
        end)
        Notify("Anti-Fling on","ok")
    end},
}
for _,a in ipairs(playerActions) do C("Player", a[1], "Player: "..a[1], Safe(a[2])) end

-- =========================================================
-- MOVEMENT
-- =========================================================
for _,v in ipairs({8,16,25,32,40,50,60,75,100,125,150,200,250,300,400,500,750,1000}) do
    C("Movement","WalkSpeed "..v, "Set WalkSpeed "..v, Safe(function() ws(v) end))
end
for _,v in ipairs({50,60,75,100,125,150,200,300,500,1000}) do
    C("Movement","JumpPower "..v, "Set JumpPower "..v, Safe(function() jp(v) end))
end
for _,v in ipairs({5,10,15,20,30,50,100}) do
    C("Movement","JumpHeight "..v, "Set JumpHeight "..v, Safe(function() jh(v) end))
end
for _,v in ipairs({-4,-2,0,1,2,3,5,10}) do
    C("Movement","HipHeight "..v, "Set HipHeight "..v, Safe(function() hip(v) end))
end
for _,c in ipairs({
    {"Infinite Jump ON","Enable inf jump", function()
        _G._infJump=true
        UIS.JumpRequest:Connect(function() if _G._infJump then local h=GetHum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end)
    end},
    {"Infinite Jump OFF","Disable inf jump", function() _G._infJump=false end},
    {"Fly (WASD)","Fly with WASD", function()
        local r=GetRoot(); if not r then return end
        local bv=Instance.new("BodyVelocity",r); bv.MaxForce=Vector3.new(1e5,1e5,1e5); bv.Velocity=Vector3.zero
        local bg=Instance.new("BodyGyro",r); bg.MaxTorque=Vector3.new(1e5,1e5,1e5); bg.P=9e4
        local cam=Workspace.CurrentCamera
        local conn; conn=RunService.RenderStepped:Connect(function()
            if not r.Parent then bv:Destroy(); bg:Destroy(); conn:Disconnect(); return end
            local d=Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then d+=cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then d-=cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then d-=cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then d+=cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then d+=Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then d-=Vector3.new(0,1,0) end
            bv.Velocity=d*50; bg.CFrame=cam.CFrame
        end)
        Notify("Fly on","ok")
    end},
    {"Fly Up","Rise 50 studs", function() local r=GetRoot(); if r then r.CFrame=r.CFrame+Vector3.new(0,50,0) end end},
    {"Fly Down","Drop 50 studs", function() local r=GetRoot(); if r then r.CFrame=r.CFrame-Vector3.new(0,50,0) end end},
    {"Floor TP","Teleport to floor", function() local r=GetRoot(); if r then r.CFrame=CFrame.new(r.Position.X,0,r.Position.Z) end end},
    {"Random TP","Random teleport", function() local r=GetRoot(); if r then r.CFrame=r.CFrame*CFrame.new(math.random(-100,100),math.random(0,20),math.random(-100,100)) end end},
    {"Reset Speed","Reset WalkSpeed", function() ws(16) end},
    {"Reset Jump","Reset JumpPower", function() jp(50) end},
    {"Reset All","Reset movement", function() ws(16); jp(50); hip(2) end},
    {"Sprint Toggle","Toggle sprint", function()
        _G._sprint = not _G._sprint
        ws(_G._sprint and 32 or 16)
        Notify("Sprint "..tostring(_G._sprint),"info")
    end},
    {"Crouch","Lower HipHeight", function() hip(-1) end},
    {"Stand Up","Reset HipHeight", function() hip(2) end},
    {"Super Slide","Slide forward", function()
        local r=GetRoot(); if not r then return end
        local bv=Instance.new("BodyVelocity",r); bv.MaxForce=Vector3.new(1e5,1e5,1e5); bv.Velocity=r.CFrame.LookVector*200
        task.delay(.5,function() bv:Destroy() end)
    end},
    {"Backflip","Jump backwards", function()
        local r=GetRoot(); if not r then return end
        local bv=Instance.new("BodyVelocity",r); bv.MaxForce=Vector3.new(1e5,1e5,1e5); bv.Velocity=(r.CFrame.LookVector*-1+Vector3.new(0,50,0))*10
        task.delay(.5,function() bv:Destroy() end)
    end},
    {"Wall Hop","Vault up", function() local r=GetRoot(); if r then r.CFrame=r.CFrame+Vector3.new(0,15,0) end end},
    {"Auto Jump","Jump every 0.5s", function()
        task.spawn(function() for i=1,20 do local h=GetHum(); if h then h.Jump=true end; task.wait(.5) end end)
    end},
    {"Auto Walk","Push forward", function()
        local r=GetRoot(); if not r then return end
        local bv=Instance.new("BodyVelocity",r); bv.MaxForce=Vector3.new(1e5,1e5,1e5); bv.Velocity=r.CFrame.LookVector*20
        task.delay(3,function() bv:Destroy() end)
    end},
    {"Stop Body Velocity","Clear body velocity", function()
        local r=GetRoot(); if r then local bv=r:FindFirstChildOfClass("BodyVelocity"); if bv then bv:Destroy() end end
    end},
}) do C("Movement", c[1], c[2], Safe(c[3])) end

-- =========================================================
-- COMBAT
-- =========================================================
for _,c in ipairs({
    {"Aimbot Basic","Aim at nearest head", function()
        local conn; conn=RunService.RenderStepped:Connect(function()
            local p=nearestPlayer(); if not p or not p.Character then return end
            local hd=p.Character:FindFirstChild("Head")
            if hd then Workspace.CurrentCamera.CFrame=CFrame.new(Workspace.CurrentCamera.CFrame.Position,hd.Position) end
        end)
        task.wait(3); conn:Disconnect()
    end},
    {"Lock On","Track nearest", function()
        _G._lockOn=true
        task.spawn(function() while _G._lockOn do
            local p=nearestPlayer(); if p and p.Character then
                local hd=p.Character:FindFirstChild("Head")
                if hd then Workspace.CurrentCamera.CFrame=CFrame.new(Workspace.CurrentCamera.CFrame.Position,hd.Position) end
            end
            RunService.RenderStepped:Wait()
        end end)
    end},
    {"Unlock","Disable lock-on", function() _G._lockOn=false end},
    {"Aim Head","Snap to nearest head", function()
        local p=nearestPlayer(); if p and p.Character then
            local hd=p.Character:FindFirstChild("Head")
            if hd then Workspace.CurrentCamera.CFrame=CFrame.new(Workspace.CurrentCamera.CFrame.Position,hd.Position) end
        end
    end},
    {"Hitbox Expander","Enlarge hitboxes", function()
        allOthers(function(p) if p.Character then local r=rootOf(p); if r then r.Size=Vector3.new(10,10,10); r.Transparency=.5 end end end)
        Notify("Expanded","ok")
    end},
    {"Restore Hitboxes","Restore hitbox size", function()
        allOthers(function(p) if p.Character then local r=rootOf(p); if r then r.Size=Vector3.new(2,2,1); r.Transparency=1 end end end)
    end},
    {"Fling Nearest","Fling nearby player", function()
        local p=nearestPlayer(); if not p or not p.Character then return end
        local r=rootOf(p)
        if r then local bv=Instance.new("BodyAngularVelocity",r); bv.AngularVelocity=Vector3.new(9999,9999,9999); bv.MaxTorque=Vector3.new(1e9,1e9,1e9) end
    end},
    {"Fling All","Fling every player", function()
        allOthers(function(p) local r=rootOf(p); if r then local bv=Instance.new("BodyAngularVelocity",r); bv.AngularVelocity=Vector3.new(9999,9999,9999); bv.MaxTorque=Vector3.new(1e9,1e9,1e9) end end)
    end},
    {"Damage Aura","Damage nearby", function()
        local r=GetRoot(); if not r then return end
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP then local rr=rootOf(p); if rr and (rr.Position-r.Position).Magnitude<20 then local h=humOf(p); if h then h:TakeDamage(10) end end end
        end
    end},
    {"Loop Damage Aura","Continuous damage", function()
        _G._dmgAura=true
        task.spawn(function() while _G._dmgAura do
            local r=GetRoot(); if r then
                for _,p in ipairs(Players:GetPlayers()) do
                    if p~=LP then local rr=rootOf(p); if rr and (rr.Position-r.Position).Magnitude<20 then local h=humOf(p); if h then h:TakeDamage(5) end end end
                end
            end
            task.wait(1)
        end end)
    end},
    {"Stop Damage Aura","Disable aura", function() _G._dmgAura=false end},
    {"Push Nearest","Push nearby", function()
        local p=nearestPlayer(); local r=p and rootOf(p)
        if r then local bv=Instance.new("BodyVelocity",r); bv.MaxForce=Vector3.new(1e5,1e5,1e5); bv.Velocity=Vector3.new(0,0,-100); task.wait(.5); bv:Destroy() end
    end},
    {"Push All","Push every player", function()
        allOthers(function(p) local r=rootOf(p); if r then local bv=Instance.new("BodyVelocity",r); bv.MaxForce=Vector3.new(1e5,1e5,1e5); bv.Velocity=Vector3.new(math.random(-100,100),50,math.random(-100,100)); task.delay(.5,function() bv:Destroy() end) end end)
    end},
    {"Ragdoll All","Ragdoll every player", function()
        allOthers(function(p) local h=humOf(p); if h then h.PlatformStand=true; task.delay(1.2,function() if h then h.PlatformStand=false end end) end end)
    end},
    {"Explode All","Explosion at every player", function()
        allOthers(function(p) local r=rootOf(p); if r then local e=Instance.new("Explosion",Workspace); e.Position=r.Position; e.BlastRadius=4; e.BlastPressure=0 end end)
    end},
    {"Punch Nearest","Deal 50 damage", function() local p=nearestPlayer(); local h=p and humOf(p); if h then h:TakeDamage(50) end end},
    {"Kill Aura","Kill within 15 studs", function()
        _G._killAura=true
        task.spawn(function() while _G._killAura do
            local r=GetRoot(); if r then
                for _,p in ipairs(Players:GetPlayers()) do
                    if p~=LP then local rr=rootOf(p); if rr and (rr.Position-r.Position).Magnitude<15 then local h=humOf(p); if h then h.Health=0 end end end
                end
            end
            task.wait(1)
        end end)
    end},
    {"Stop Kill Aura","Disable", function() _G._killAura=false end},
    {"Sword Aura","Auto swing", function()
        _G._sword=true
        task.spawn(function() while _G._sword do
            local h=GetHum(); if h then local tool=h:FindFirstChildOfClass("Tool"); if tool then tool:Activate() end end
            task.wait(.15)
        end end)
    end},
    {"Stop Sword Aura","Disable", function() _G._sword=false end},
    {"TP Behind Nearest","Teleport behind", function()
        local p=nearestPlayer(); local rr=p and rootOf(p); local r=GetRoot()
        if rr and r then r.CFrame=rr.CFrame*CFrame.new(0,0,4) end
    end},
    {"TP Above Nearest","Above player", function()
        local p=nearestPlayer(); local rr=p and rootOf(p)
        if rr then local r=GetRoot(); if r then r.CFrame=rr.CFrame*CFrame.new(0,15,0) end end
    end},
    {"Force Field On","Add force field", function() if GetChar() then Instance.new("ForceField",GetChar()) end end},
    {"Damage Self","Take 25 damage", function() local h=GetHum(); if h then h:TakeDamage(25) end end},
    {"Fling Self","Fling yourself", function()
        local r=GetRoot(); if not r then return end
        local bv=Instance.new("BodyAngularVelocity",r); bv.AngularVelocity=Vector3.new(9999,9999,9999); bv.MaxTorque=Vector3.new(1e9,1e9,1e9)
    end},
    {"Stun Nearest","Stun player", function()
        local p=nearestPlayer(); local h=p and humOf(p)
        if h then h.PlatformStand=true; task.delay(2,function() if h then h.PlatformStand=false end end) end
    end},
    {"Trap Nearest","Freeze player in place", function()
        local p=nearestPlayer(); local r=p and rootOf(p)
        if r then r.Anchored=true; task.delay(3,function() if r then r.Anchored=false end end) end
    end},
    {"Yeet All","Fling everyone up", function()
        allOthers(function(p) local r=rootOf(p); if r then r.AssemblyLinearVelocity=Vector3.new(math.random(-100,100),500,math.random(-100,100)) end end)
    end},
    {"Black Hole","Pull nearby players", function()
        _G._bh=true
        task.spawn(function() while _G._bh do
            local r=GetRoot(); if r then
                for _,p in ipairs(Players:GetPlayers()) do
                    if p~=LP then local rr=rootOf(p); if rr and (rr.Position-r.Position).Magnitude<30 then
                        local dir=(r.Position-rr.Position).Unit
                        rr.AssemblyLinearVelocity=dir*100
                    end end
                end
            end
            RunService.Heartbeat:Wait()
        end end)
    end},
    {"Stop Black Hole","Disable", function() _G._bh=false end},
}) do C("Combat", c[1], c[2], Safe(c[3])) end

-- =========================================================
-- WORLD
-- =========================================================
for _,g in ipairs({0,5,10,20,30,40,50,60,80,100,150,200,196.2}) do
    C("World","Gravity "..g, "Set gravity "..g, Safe(function() Workspace.Gravity=g end))
end
for _,tt in ipairs({0,1,3,6,9,12,15,18,21,23}) do
    C("World","Clock "..tt..":00", "Set time "..tt..":00", Safe(function() Lighting.ClockTime=tt end))
end
for _,c in ipairs({
    {"Fullbright","Brighten world", function() Lighting.Brightness=3; Lighting.ClockTime=12; Lighting.GlobalShadows=false; Lighting.FogEnd=1e6 end},
    {"Fog Clear","Remove fog", function() Lighting.FogEnd=1e6 end},
    {"Fog Thick","Thick fog", function() Lighting.FogEnd=50 end},
    {"Fog Red","Red fog", function() Lighting.FogColor=Color3.new(1,0,0); Lighting.FogEnd=100 end},
    {"Fog Blue","Blue fog", function() Lighting.FogColor=Color3.new(0,0,1); Lighting.FogEnd=100 end},
    {"Shadows Off","Disable shadows", function() Lighting.GlobalShadows=false end},
    {"Shadows On","Enable shadows", function() Lighting.GlobalShadows=true end},
    {"FPS Boost","Low graphics", function() settings().Rendering.QualityLevel=1 end},
    {"Graphics Max","Max graphics", function() settings().Rendering.QualityLevel=10 end},
    {"Delete Kill Bricks","Remove kill bricks", function()
        for _,v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and (v.Name:lower():find("kill") or v.Name:lower():find("lava")) then v:Destroy() end
        end
    end},
    {"Anchor All","Anchor everything", function()
        for _,v in ipairs(Workspace:GetDescendants()) do if v:IsA("BasePart") and v ~= GetRoot() then v.Anchored=true end end
    end},
    {"Unanchor All","Unanchor everything", function()
        for _,v in ipairs(Workspace:GetDescendants()) do if v:IsA("BasePart") then v.Anchored=false end end
    end},
    {"Remove Doors","Destroy doors", function()
        for _,v in ipairs(Workspace:GetDescendants()) do if v:IsA("BasePart") and v.Name:lower():find("door") then v:Destroy() end end
    end},
    {"Break Joints All","Kill everyone", function() for _,p in ipairs(Players:GetPlayers()) do if p.Character then p.Character:BreakJoints() end end end},
    {"Show Hidden Parts","Reveal transparency", function()
        for _,v in ipairs(Workspace:GetDescendants()) do if v:IsA("BasePart") then v.Transparency=0 end end
    end},
    {"Rainbow Workspace","Cycle colors", function()
        _G._rainbowWS=true
        task.spawn(function() while _G._rainbowWS do
            local col=Color3.fromHSV((tick()%5)/5,1,1)
            for _,v in ipairs(Workspace:GetChildren()) do if v:IsA("BasePart") then v.Color=col end end
            task.wait(.1)
        end end)
    end},
    {"Stop Rainbow","Disable", function() _G._rainbowWS=false end},
    {"Kill Sounds","Mute all audio", function() SoundService.Volume=0 end},
    {"Unmute Sounds","Restore audio", function() SoundService.Volume=1 end},
    {"Disable Chat","Hide chat", function()
        local ok = pcall(function() TextChatService.ChatWindowConfiguration.Enabled=false end)
        if not ok then StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat,false) end
    end},
    {"Enable Chat","Show chat", function()
        local ok = pcall(function() TextChatService.ChatWindowConfiguration.Enabled=true end)
        if not ok then StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat,true) end
    end},
}) do C("World", c[1], c[2], Safe(c[3])) end

-- =========================================================
-- VISUAL
-- =========================================================
for _,f in ipairs({40,60,70,80,90,100,110,120,140}) do
    C("Visual","FOV "..f, "Set FOV "..f, Safe(function() Workspace.CurrentCamera.FieldOfView=f end))
end
for _,c in ipairs({
    {"Fullbright Light","Add camera light", function() local l=Instance.new("PointLight",GetRoot() or Workspace.CurrentCamera); l.Brightness=3; l.Range=500 end},
    {"Remove Blur","Destroy blur", function() for _,e in ipairs(Lighting:GetChildren()) do if e:IsA("BlurEffect") then e:Destroy() end end end},
    {"Remove Bloom","Destroy bloom", function() for _,e in ipairs(Lighting:GetChildren()) do if e:IsA("BloomEffect") then e:Destroy() end end end},
    {"Remove DOF","Destroy DOF", function() for _,e in ipairs(Lighting:GetChildren()) do if e:IsA("DepthOfFieldEffect") then e:Destroy() end end end},
    {"Remove All Effects","Destroy post-effects", function() for _,e in ipairs(Lighting:GetChildren()) do if e:IsA("PostEffect") then e:Destroy() end end end},
    {"Add Bloom","Add bloom", function() local b=Instance.new("BloomEffect",Lighting); b.Intensity=1.5 end},
    {"Add Blur","Add blur", function() local b=Instance.new("BlurEffect",Lighting); b.Size=8 end},
    {"Add ColorCorrection","Add CC", function() local c=Instance.new("ColorCorrectionEffect",Lighting); c.Saturation=.5 end},
    {"Add DOF","Add DOF", function() local d=Instance.new("DepthOfFieldEffect",Lighting); d.FarIntensity=1 end},
    {"Add Sun Rays","Add sunrays", function() local s=Instance.new("SunRaysEffect",Lighting); s.Intensity=.3 end},
    {"Invert Colors","Invert", function() local c=Instance.new("ColorCorrectionEffect",Lighting); c.TintColor=Color3.fromRGB(255,200,200); c.Contrast=1 end},
    {"Green Vision","Green tint", function() local c=Instance.new("ColorCorrectionEffect",Lighting); c.TintColor=Color3.fromRGB(100,255,100) end},
    {"Red Vision","Red tint", function() local c=Instance.new("ColorCorrectionEffect",Lighting); c.TintColor=Color3.fromRGB(255,100,100) end},
    {"Freeze Camera","Lock camera", function() Workspace.CurrentCamera.CameraType=Enum.CameraType.Scriptable end},
    {"Unfreeze Camera","Unlock camera", function() Workspace.CurrentCamera.CameraType=Enum.CameraType.Custom end},
    {"FPV Camera","First person", function() LP.CameraMode=Enum.CameraMode.LockFirstPerson end},
    {"TPV Camera","Third person", function() LP.CameraMode=Enum.CameraMode.Classic end},
    {"See Through Walls","Reduce alpha", function()
        for _,v in ipairs(Workspace:GetDescendants()) do if v:IsA("BasePart") and not v:IsDescendantOf(LP.Character) then v.LocalTransparencyModifier=.5 end end
    end},
    {"Reset Camera","Reset camera", function()
        Workspace.CurrentCamera.CameraType=Enum.CameraType.Custom
        Workspace.CurrentCamera.CameraSubject=GetHum()
        Workspace.CurrentCamera.FieldOfView=70
    end},
    {"Show Chat","Enable chat GUI", function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat,true) end},
    {"Hide Chat","Disable chat GUI", function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat,false) end},
    {"Hide Playerlist","Hide playerlist", function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList,false) end},
    {"Show Playerlist","Show playerlist", function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList,true) end},
    {"Hide Backpack","Hide backpack GUI", function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false) end},
    {"Show Backpack","Show backpack GUI", function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,true) end},
    {"Hide Health","Hide health GUI", function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health,false) end},
    {"Show Health","Show health GUI", function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health,true) end},
    {"Hide Emotes","Hide emotes GUI", function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu,false) end},
}) do C("Visual", c[1], c[2], Safe(c[3])) end

-- =========================================================
-- TELEPORT
-- =========================================================
C("Teleport","Spawn","TP to spawn",Safe(function()
    local sp = Workspace:FindFirstChildOfClass("SpawnLocation")
    if sp then tp(sp.Position+Vector3.new(0,3,0)) else Notify("No spawn","warn") end
end))
for _,p in ipairs(Players:GetPlayers()) do
    if p ~= LP then C("Teleport","TP to "..p.Name, "TP to "..p.Name, Safe(function() tpPlr(p) end)) end
end
Players.PlayerAdded:Connect(function(p)
    C("Teleport","TP to "..p.Name, "TP to "..p.Name, Safe(function() tpPlr(p) end))
end)
for i=1,15 do
    C("Teleport","Random TP "..i,"Random teleport #"..i, Safe(function()
        local r=GetRoot(); if r then r.CFrame=r.CFrame*CFrame.new(math.random(-200,200),math.random(5,50),math.random(-200,200)) end
    end))
end
for i,off in ipairs({Vector3.new(10,0,0),Vector3.new(-10,0,0),Vector3.new(0,0,10),Vector3.new(0,0,-10),Vector3.new(0,20,0),Vector3.new(0,-10,0),Vector3.new(50,0,0),Vector3.new(-50,0,0),Vector3.new(0,0,50),Vector3.new(0,0,-50)}) do
    C("Teleport","Offset "..i, "TP by offset", Safe(function()
        local r=GetRoot(); if r then r.CFrame=r.CFrame+off end
    end))
end
for _,c in ipairs({
    {"TP Origin","TP to 0,0,0", function() tp(Vector3.new(0,5,0)) end},
    {"TP Up","TP 100 up", function() local r=GetRoot(); if r then r.CFrame=r.CFrame+Vector3.new(0,100,0) end end},
    {"TP Down","TP 100 down", function() local r=GetRoot(); if r then r.CFrame=r.CFrame-Vector3.new(0,100,0) end end},
    {"TP to Nearest Part","TP to nearest base part", function() local p=nearestPart(); if p then tp(p.Position+Vector3.new(0,3,0)) end end},
    {"TP to Highest Part","TP to highest part", function()
        local best,by = nil,-math.huge
        for _,v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Position.Y>by and not v:IsDescendantOf(LP.Character) then by=v.Position.Y; best=v end
        end
        if best then tp(best.Position+Vector3.new(0,3,0)) end
    end},
    {"TP to Cursor","TP to mouse target", function()
        local m=UIS:GetMouseLocation()
        local part = raycastFromViewport(m.X, m.Y)
        if part then tp(part.Position+Vector3.new(0,3,0)) else Notify("No hit","warn") end
    end},
}) do C("Teleport", c[1], c[2], Safe(c[3])) end

-- =========================================================
-- VEHICLES
-- =========================================================
for _,c in ipairs({
    {"Unanchor Vehicles","Unanchor vehicle seats", function() for _,v in ipairs(Workspace:GetDescendants()) do if v:IsA("VehicleSeat") then v.Anchored=false end end end},
    {"Anchor Vehicles","Anchor vehicle seats", function() for _,v in ipairs(Workspace:GetDescendants()) do if v:IsA("VehicleSeat") then v.Anchored=true end end end},
    {"Eject All","Unseat everyone", function()
        for _,v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("VehicleSeat") then for _,w in ipairs(v:GetChildren()) do if w:IsA("Weld") then w:Destroy() end end end
        end
    end},
    {"Drive Nearest","Enter nearest vehicle", function()
        local r=GetRoot(); if not r then return end
        local best,d=nil,math.huge
        for _,v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("VehicleSeat") then local dd=(v.Position-r.Position).Magnitude; if dd<d then d=dd; best=v end end
        end
        if best then local h=GetHum(); if h then h.Sit=true; best:Sit(h) end end
    end},
    {"Vehicle Speed +","Boost speed", function() for _,v in ipairs(Workspace:GetDescendants()) do if v:IsA("VehicleSeat") then v.MaxSpeed=(v.MaxSpeed or 0)+50 end end end},
    {"Vehicle Speed -","Reduce speed", function() for _,v in ipairs(Workspace:GetDescendants()) do if v:IsA("VehicleSeat") then v.MaxSpeed=math.max(0,(v.MaxSpeed or 0)-50) end end end},
    {"Vehicle Torque +","Boost torque", function() for _,v in ipairs(Workspace:GetDescendants()) do if v:IsA("VehicleSeat") then v.Torque=(v.Torque or 0)+10 end end end},
    {"Vehicle Torque -","Reduce torque", function() for _,v in ipairs(Workspace:GetDescendants()) do if v:IsA("VehicleSeat") then v.Torque=math.max(0,(v.Torque or 0)-10) end end end},
    {"Count Vehicles","Notify count", function() local n=0; for _,v in ipairs(Workspace:GetDescendants()) do if v:IsA("VehicleSeat") then n=n+1 end end Notify("Vehicles: "..n,"info") end},
    {"Move All Vehicles","TP vehicles to you", function()
        local r=GetRoot(); if not r then return end
        for _,v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("VehicleSeat") then v.CFrame=r.CFrame*CFrame.new(math.random(-6,6),0,math.random(-6,6)) end
        end
    end},
    {"Sink Vehicles","Push down", function() for _,v in ipairs(Workspace:GetDescendants()) do if v:IsA("VehicleSeat") then v.CFrame=v.CFrame-Vector3.new(0,20,0) end end end},
    {"Float Vehicles","Lift up", function() for _,v in ipairs(Workspace:GetDescendants()) do if v:IsA("VehicleSeat") then v.CFrame=v.CFrame+Vector3.new(0,20,0) end end end},
    {"Delete All Vehicles","Destroy vehicles", function() for _,v in ipairs(Workspace:GetDescendants()) do if v:IsA("VehicleSeat") then v.Parent:Destroy() end end end},
    {"Break All Vehicle Welds","Remove all welds", function()
        for _,v in ipairs(Workspace:GetDescendants()) do if v:IsA("VehicleSeat") then for _,w in ipairs(v:GetChildren()) do if w:IsA("Weld") or w:IsA("Motor6D") then w:Destroy() end end end end
    end},
}) do C("Vehicles", c[1], c[2], Safe(c[3])) end

-- =========================================================
-- FUN
-- =========================================================
for i=1,10 do
    local spd=i*0.5
    C("Fun","Spin "..i.."x", "Spin speed "..spd, Safe(function()
        local r=GetRoot(); if r then for _=1,60 do r.CFrame=r.CFrame*CFrame.Angles(0,spd*0.1,0); RunService.RenderStepped:Wait() end end
    end))
end
for _,c in ipairs({
    {"Rainbow Trail","Rainbow trail", function()
        local conn; conn=RunService.Heartbeat:Connect(function()
            local r=GetRoot(); if not r then return end
            local p=Instance.new("Part",Workspace); p.Anchored=true; p.CanCollide=false; p.Size=Vector3.new(1,1,1)
            p.CFrame=r.CFrame; p.Color=Color3.fromHSV((tick()%5)/5,1,1); p.Material=Enum.Material.Neon; p.Shape=Enum.PartType.Ball
            task.delay(.7,function() p:Destroy() end)
        end)
        task.wait(3); conn:Disconnect()
    end},
    {"Firework","Launch firework", function()
        local r=GetRoot(); if not r then return end
        local p=Instance.new("Part",Workspace); p.Anchored=true; p.CanCollide=false; p.Size=Vector3.new(2,2,2)
        p.CFrame=r.CFrame+Vector3.new(0,20,0); p.Material=Enum.Material.Neon; p.Color=Color3.new(1,0,0)
        task.delay(1,function() p:Destroy() end)
    end},
    {"Confetti","Burst confetti", function()
        local r=GetRoot(); if not r then return end
        for _=1,30 do
            local p=Instance.new("Part",Workspace); p.Anchored=false; p.CanCollide=false; p.Size=Vector3.new(.3,.3,.3)
            p.CFrame=r.CFrame+Vector3.new(math.random(-5,5),5,math.random(-5,5))
            p.Color=Color3.new(math.random(),math.random(),math.random()); p.Material=Enum.Material.Neon
            task.delay(3,function() p:Destroy() end)
        end
    end},
    {"Wear Hat","Attach hat", function()
        local h=GetChar():FindFirstChild("Head"); if not h then return end
        local p=Instance.new("Part",GetChar()); p.Size=Vector3.new(2,1,2); p.Color=Color3.new(1,0.5,0)
        local w=Instance.new("Weld",p); w.Part0=p; w.Part1=h; w.C0=CFrame.new(0,1.5,0)
    end},
    {"Remove Hats","Destroy accessories", function()
        local c=GetChar(); if not c then return end
        for _,v in ipairs(c:GetDescendants()) do if v:IsA("Accessory") then v:Destroy() end end
    end},
    {"Random Skin","Random colors", function() for _,c in ipairs(GetChar():GetChildren()) do if c:IsA("BasePart") then c.Color=Color3.new(math.random(),math.random(),math.random()) end end end},
    {"Giant","Scale up", function()
        local s=GetChar():FindFirstChild("Humanoid")
        if s then s.BodyDepthScale.Value=3; s.BodyHeightScale.Value=3; s.BodyWidthScale.Value=3 end
    end},
    {"Tiny","Scale down", function()
        local s=GetChar():FindFirstChild("Humanoid")
        if s then s.BodyDepthScale.Value=0.5; s.BodyHeightScale.Value=0.5; s.BodyWidthScale.Value=0.5 end
    end},
    {"Reset Size","Reset scale", function()
        local s=GetChar():FindFirstChild("Humanoid")
        if s then s.BodyDepthScale.Value=1; s.BodyHeightScale.Value=1; s.BodyWidthScale.Value=1 end
    end},
    {"Float On","Float in place", function() local r=GetRoot(); if r then local b=Instance.new("BodyPosition",r); b.MaxForce=Vector3.new(1e5,1e5,1e5); b.Position=r.Position+Vector3.new(0,10,0) end end},
    {"Float Off","Stop floating", function() local r=GetRoot(); if r then local b=r:FindFirstChildOfClass("BodyPosition"); if b then b:Destroy() end end end},
    {"Summon Box","Spawn a box", function()
        local r=GetRoot(); if not r then return end
        local p=Instance.new("Part",Workspace); p.Size=Vector3.new(4,4,4); p.CFrame=r.CFrame*CFrame.new(0,0,-5); p.Anchored=true
    end},
    {"Summon Ball","Spawn a ball", function()
        local r=GetRoot(); if not r then return end
        local p=Instance.new("Part",Workspace); p.Shape=Enum.PartType.Ball; p.Size=Vector3.new(3,3,3); p.CFrame=r.CFrame*CFrame.new(0,0,-5); p.Anchored=true
    end},
    {"Morph Ball","Become ball", function()
        local c=GetChar(); if not c then return end
        for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.Transparency=1 end end
        local r=c:FindFirstChild("HumanoidRootPart")
        if r then local m=Instance.new("SpecialMesh",r); m.MeshType=Enum.MeshType.Sphere end
    end},
    {"Reset Morph","Restore body", function()
        local c=GetChar(); if not c then return end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.Transparency=0; local m=p:FindFirstChildOfClass("SpecialMesh"); if m then m:Destroy() end end
        end
    end},
    {"Screen Shake","Shake screen", function()
        local cam=Workspace.CurrentCamera; local orig=cam.CFrame
        for _=1,20 do cam.CFrame=orig*CFrame.new(math.random(-1,1)/10,math.random(-1,1)/10,0); RunService.RenderStepped:Wait() end
        cam.CFrame=orig
    end},
    {"Camera Tilt","Tilt camera", function() local cam=Workspace.CurrentCamera; cam.CFrame=cam.CFrame*CFrame.Angles(0,0,0.3) end},
    {"Rainbow Body","Cycle body colors", function()
        _G._rainbowBody=true
        task.spawn(function() while _G._rainbowBody do
            local c=GetChar(); if c then
                local col=Color3.fromHSV((tick()%5)/5,1,1)
                for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.Color=col end end
            end
            task.wait(.1)
        end end)
    end},
    {"Stop Rainbow Body","Disable", function() _G._rainbowBody=false end},
    {"Sky Dive","Jump super high", function()
        local r=GetRoot(); if r then r.AssemblyLinearVelocity=Vector3.new(0,1000,0) end
    end},
    {"Spin Cam","Spin camera", function()
        local cam=Workspace.CurrentCamera; local orig=cam.CFrame
        for i=1,60 do cam.CFrame=orig*CFrame.Angles(0,i*0.1,0); RunService.RenderStepped:Wait() end
    end},
    {"Confetti Rain","Confetti from sky", function()
        _G._confettiRain=true
        task.spawn(function() while _G._confettiRain do
            local r=GetRoot(); if r then
                for _=1,5 do
                    local p=Instance.new("Part",Workspace); p.Anchored=false; p.CanCollide=false; p.Size=Vector3.new(.3,.3,.3)
                    p.CFrame=r.CFrame+Vector3.new(math.random(-20,20),20,math.random(-20,20))
                    p.Color=Color3.new(math.random(),math.random(),math.random()); p.Material=Enum.Material.Neon
                    task.delay(5,function() p:Destroy() end)
                end
            end
            task.wait(.1)
        end end)
    end},
    {"Stop Confetti","Disable", function() _G._confettiRain=false end},
}) do C("Fun", c[1], c[2], Safe(c[3])) end

-- =========================================================
-- MISC
-- =========================================================
for _,c in ipairs({
    {"Print Workspace","Print workspace info", function() print("Children:", #Workspace:GetChildren()) Notify("Printed","ok") end},
    {"Print Backpack","Print tools", function()
        local bp=LP:FindFirstChild("Backpack")
        if bp then for _,t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then print(t.Name) end end end
    end},
    {"Give Sword","Give a sword", function() giveTool("Sword") Notify("Gave sword","ok") end},
    {"Give Sword All","Sword to all", function()
        for _,p in ipairs(Players:GetPlayers()) do giveTool("Sword", p) end
        Notify("Gave all","ok")
    end},
    {"Give Wooden Sword","Give wooden sword", function()
        local bp=LP:FindFirstChild("Backpack")
        if not bp then return end
        local t=Instance.new("Tool",bp); t.Name="Wooden Sword"; t.RequiresHandle=true
        local h=Instance.new("Part",t); h.Name="Handle"; h.Size=Vector3.new(1,1,4); h.Color=Color3.fromRGB(150,90,50)
    end},
    {"Give Stone Sword","Stone sword", function() giveTool("Stone Sword") end},
    {"Give Iron Sword","Iron sword", function() giveTool("Iron Sword") end},
    {"Give Gold Sword","Gold sword", function() giveTool("Gold Sword") end},
    {"Give Diamond Sword","Diamond sword", function() giveTool("Diamond Sword") end},
    {"Give Netherite Sword","Netherite sword", function() giveTool("Netherite Sword") end},
    {"Clear Backpack","Clear tools", function() local bp=LP:FindFirstChild("Backpack"); if bp then for _,t in ipairs(bp:GetChildren()) do t:Destroy() end end end},
    {"Clear Other Backpacks","Clear everyone", function() allOthers(function(p) local bp=p:FindFirstChild("Backpack"); if bp then for _,t in ipairs(bp:GetChildren()) do t:Destroy() end end end) end},
    {"Dump Players","Print players+IDs", function() for _,p in ipairs(Players:GetPlayers()) do print(p.Name, p.UserId) end end},
    {"Print My Char","Print character info", function()
        local c=LP.Character
        if c then local h=c:FindFirstChildOfClass("Humanoid"); print("Char:", c.Name, "HP:", h and h.Health) end
    end},
    {"Show Cursor","Print cursor", function() local m=UIS:GetMouseLocation(); Notify("Cursor "..math.floor(m.X)..","..math.floor(m.Y),"info") end},
    {"Toggle Fullscreen","Fullscreen GUI", function()
        Main.Size=UDim2.fromScale(1,1); Main.Position=UDim2.fromScale(0,0)
    end},
    {"Reset Window","Reset size", function()
        Main.Size=UDim2.new(0,W,0,H); Main.Position=UDim2.new(.5,-W/2,.5,-H/2)
    end},
    {"Enable Shift Lock","Force shiftlock", function() LP.DevEnableMouseLock=true end},
    {"Disable Shift Lock","Disable shiftlock", function() LP.DevEnableMouseLock=false end},
    {"Enable Zoom","Allow zoom", function() LP.CameraMaxZoomDistance=128 end},
    {"Max Zoom","Zoom far", function() LP.CameraMaxZoomDistance=500 end},
    {"Reset Zoom","Reset zoom", function() LP.CameraMaxZoomDistance=128 end},
    {"Reset All Commands","Reset everything", function()
        ws(16); jp(50); hip(2); ungod()
        Workspace.Gravity=196.2
        for _,e in ipairs(Lighting:GetChildren()) do
            if e:IsA("PostEffect") or e:IsA("BlurEffect") then e:Destroy() end
        end
        Notify("Reset done","ok")
    end},
    {"Emergency Reset","Break + reset", function()
        LP.Character:BreakJoints(); ws(16); jp(50); Workspace.Gravity=196.2
    end},
    {"Dump Lighting","Print lighting", function() print("Brightness:",Lighting.Brightness,"ClockTime:",Lighting.ClockTime) end},
    {"Dump Gravity","Print gravity", function() print("Gravity:",Workspace.Gravity) end},
    {"Dump Camera FOV","Print FOV", function() print("FOV:",Workspace.CurrentCamera.FieldOfView) end},
    {"Print Ping","Ping", function() Notify("Ping "..math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()).."ms","info") end},
    {"Kill Sound","Mute all", function() SoundService.Volume=0 end},
    {"Restore Sound","Restore audio", function() SoundService.Volume=1 end},
    {"Drop All","Drop all tools", function()
        local bp=LP:FindFirstChild("Backpack")
        if bp then for _,t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then t.Parent=Workspace end end end
    end},
    {"Print Game Version","Print version", function() print("Version:", game.PlaceVersion) end},
}) do C("Misc", c[1], c[2], Safe(c[3])) end

-- =========================================================
-- BUILD SIDEBAR + CONTENT
-- =========================================================
local TabOrder = {"Home","Player","Movement","Combat","World","Visual","Teleport","Vehicles","Fun","Misc"}
local TabIcons = {Home="🏠",Player="👤",Movement="🏃",Combat="⚔️",World="🌍",Visual="🎨",Teleport="✈️",Vehicles="🚗",Fun="🎮",Misc="⚙️"}
local ActiveTab = "Home"
local TabButtons = {}

local function RefreshList()
    for _,c in ipairs(Scroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local q = (SearchBox.Text or ""):lower()
    local i = 0
    for _,cmd in ipairs(Commands) do
        local matches = (SearchBox.Text ~= "" and (cmd.name:lower():find(q,1,true) or cmd.desc:lower():find(q,1,true)))
            or (SearchBox.Text == "" and cmd.tab == ActiveTab)
        if matches then
            i += 1
            local row = New("TextButton",{Size=UDim2.new(1,-6,0,42),BackgroundColor3=T.Surface,Text="",AutoButtonColor=false,LayoutOrder=i,Parent=Scroll})
            Corner(9)
            local s = Stroke(T.Stroke,1); s.Parent = row
            New("TextLabel",{Size=UDim2.new(1,-30,0,20),Position=UDim2.new(0,14,0,4),BackgroundTransparency=1,Text=cmd.name,TextColor3=T.Text,Font=Enum.Font.GothamSemibold,TextSize=12.5,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
            New("TextLabel",{Size=UDim2.new(1,-30,0,16),Position=UDim2.new(0,14,0,22),BackgroundTransparency=1,Text=cmd.desc,TextColor3=T.Sub,Font=Enum.Font.Gotham,TextSize=10.5,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
            local arrow = New("TextLabel",{Size=UDim2.new(0,20,1,0),Position=UDim2.new(1,-28,0,0),BackgroundTransparency=1,Text="›",TextColor3=T.Sub,Font=Enum.Font.GothamBold,TextSize=18,Parent=row})
            row.MouseEnter:Connect(function() Tween(row,.15,{BackgroundColor3=T.Surface2}); Tween(s,.15,{Color=T.Accent}); Tween(arrow,.15,{TextColor3=T.Accent}) end)
            row.MouseLeave:Connect(function() Tween(row,.15,{BackgroundColor3=T.Surface}); Tween(s,.15,{Color=T.Stroke}); Tween(arrow,.15,{TextColor3=T.Sub}) end)
            row.MouseButton1Click:Connect(function()
                local ok2,err = pcall(cmd.exec)
                SetStatus(ok2 and "✓ Done" or "✗ Error", ok2)
                if not ok2 then warn("[IA4]",err) end
            end)
        end
    end
end

local function SelectTab(name)
    ActiveTab = name
    for n,btn in pairs(TabButtons) do
        local active = n == name
        Tween(btn,.2,{BackgroundColor3=active and T.Accent or T.Surface})
        local lbl = btn:FindFirstChild("TabLabel")
        if lbl then Tween(lbl,.2,{TextColor3=active and T.Text or T.Sub}) end
    end
    RefreshList()
end

for i,tab in ipairs(TabOrder) do
    local count = 0
    for _,c in ipairs(Commands) do if c.tab == tab then count = count + 1 end end
    local Btn = New("TextButton",{Size=UDim2.new(1,0,0,30),BackgroundColor3=T.Surface,Text="",AutoButtonColor=false,LayoutOrder=i,Parent=Sidebar})
    Corner(8)
    New("TextLabel",{Size=UDim2.new(0,24,1,0),Position=UDim2.new(0,6,0,0),BackgroundTransparency=1,Text=TabIcons[tab] or "•",TextSize=13,Parent=Btn})
    
    -- Only render the text label on desktop (mobile sidebar is icon-only)
    if not isMobile then
        New("TextLabel",{Name="TabLabel",Size=UDim2.new(1,-56,1,0),Position=UDim2.new(0,28,0,0),BackgroundTransparency=1,Text=tab,TextColor3=T.Sub,Font=Enum.Font.GothamMedium,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,Parent=Btn})
        New("TextLabel",{Size=UDim2.new(0,24,1,0),Position=UDim2.new(1,-28,0,0),BackgroundTransparency=1,Text=tostring(count),TextColor3=T.Accent,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Right,Parent=Btn})
    end

    Btn.MouseEnter:Connect(function() if ActiveTab ~= tab then Tween(Btn,.15,{BackgroundColor3=T.Surface2}) end end)
    Btn.MouseLeave:Connect(function() if ActiveTab ~= tab then Tween(Btn,.15,{BackgroundColor3=T.Surface}) end end)
    Btn.MouseButton1Click:Connect(function() SelectTab(tab) end)
    TabButtons[tab] = Btn
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(RefreshList)

ConsoleBox.FocusLost:Connect(function(enter)
    if not enter then return end
    local text = ConsoleBox.Text:gsub("^;%s*",""):gsub("^%s+","")
    ConsoleBox.Text = ""
    if text == "" then return end
    local parts = {}
    for w in text:gmatch("%S+") do table.insert(parts,w) end
    local name = table.remove(parts,1)
    local cmd = byName[name:lower()]
    if not cmd then
        for _,c in ipairs(Commands) do
            if c.name:lower():sub(1,#name) == name:lower() then cmd = c; break end
        end
    end
    if cmd then
        local ok,err = pcall(cmd.exec)
        Notify((ok and "✓ " or "✗ ")..cmd.name, ok and "ok" or "err")
        if not ok then warn(err) end
    else
        Notify("Unknown: "..name,"err")
    end
end)

local dragging, dragInput, startPos, startMouse
TopBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging=true; startMouse=i.Position; startPos=Main.Position
        i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging=false end end)
    end
end)
TopBar.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then dragInput=i end
end)
UIS.InputChanged:Connect(function(i)
    if i == dragInput and dragging then
        local d = i.Position - startMouse
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
    end
end)

UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
        if Main.Visible then
            Main.Size=UDim2.new(0,0,0,0)
            Tween(Main,.28,{Size=UDim2.new(0,W,0,H)},Enum.EasingStyle.Back)
            Tween(Blur,.25,{Size=6})
        else
            Blur.Size=0
        end
    end
end)

CmdCount.Text = "• "..#Commands.." commands"
SelectTab("Home")

-- ▼ Mobile Toggle Button — because phones don't have RSHIFT.
if isMobile then
    local toggleBtn = New("TextButton",{
        Size=UDim2.new(0, 50, 0, 50),
        Position=UDim2.new(1, -70, 0, 70),
        BackgroundColor3=T.Accent,
        Text="☰",
        TextColor3=T.Text,
        Font=Enum.Font.GothamBold,
        TextSize=24,
        Parent=ScreenGui
    })
    Corner(25)
    toggleBtn.MouseButton1Click:Connect(function()
        Main.Visible = not Main.Visible
        if Main.Visible then
            Main.Size=UDim2.new(0,0,0,0)
            Tween(Main,.28,{Size=UDim2.new(0,W,0,H)},Enum.EasingStyle.Back)
            Tween(Blur,.25,{Size=6})
        else
            Blur.Size=0
        end
    end)
end

print("[InfiniteAdminV4] Loaded — "..#Commands.." commands. RSHIFT (or ☰) toggles.")
