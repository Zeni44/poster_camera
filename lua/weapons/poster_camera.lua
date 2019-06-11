local convar = CreateClientConVar("poster_size", "2", true, false, "The input number gets multiplied by your screen resolution")

--local SWEP = {Primary = {}, Secondary = {}}
SWEP.Base         = "gmod_camera"
SWEP.Author       = "Zeni"
SWEP.PrintName    = "Studio Camera"
SWEP.Instructions = "Takes HQ images and exports it as .png using the poster command"
SWEP.WorldModel   = "models/tools/camera/camera.mdl"
SWEP.Spawnable    = true
SWEP.Category     = "Other"

local function dbg(...)
	Msg("[Debug] ") print(...)
end

function SWEP:Initialize()
	self:SetHoldType("rpg")

	if CLIENT then
		self.worldmodel = ClientsideModel(self.WorldModel)
		self.worldmodel:SetNoDraw(true)
	end
end

function SWEP:PrimaryAttack()
	if SERVER and not game.SinglePlayer() then return end
	if not IsFirstTimePredicted() then return end

	local size = convar:GetInt()
	RunConsoleCommand("poster", size)
	self:GetOwner():PrintMessage(HUD_PRINTTALK, "Saving poster under: screenshots/" .. os.date("poster-%y-%m-%d %H-%M-%S.png"))

	self:DoShootEffect()
end

if CLIENT then
	--SWEP.WepSelectIcon = surface.GetTextureID("icon64/scap_camera")
	--SWEP.BounceWeaponIcon = false

	function SWEP:DrawWorldModel()
		if not self:IsValid() then return end

		local WorldModel = self.worldmodel
		if not WorldModel then return end

		local owner = self:GetOwner()
		local pos
		local ang

		if owner:IsValid() then
			local boneid = owner:LookupBone("ValveBiped.Bip01_R_Hand")
			if not boneid then return end

			pos, ang = owner:GetBonePosition(boneid)
			pos = pos + ang:Up() * -7.5
			pos = pos + ang:Forward() * 6.2
			pos = pos + ang:Right() * 3

			ang:RotateAroundAxis(ang:Forward(), 180)
		else
			pos = self:GetPos()
			ang = self:GetAngles()
		end

		WorldModel:SetPos(pos)
		WorldModel:SetAngles(ang)
		WorldModel:DrawModel()
	end

	function SWEP:DrawWeaponSelection(x, y, w, h, a)
		draw.SimpleText("RR", "creditslogo", x + w * 0.5, y, Color(255, 220, 0, a), TEXT_ALIGN_CENTER)
	end

	local w, h = ScrW() * 0.2, ScrH() * 0.15
	local size
	local isOpen
	local function OpenUI()
		if isOpen then return end
		isOpen = true

		local frame = vgui.Create("DFrame")
		frame:SetSize(w, h)
		frame:SetPos(ScrW() * 0.5 - (w * 0.5), ScrH() * 0.75)
		frame:SetTitle("Settings")
		frame.Paint = function(self, w, h)
			derma.SkinHook("Paint", "Frame", self, w, h)

			surface.SetFont("DermaDefault")
			local txt = "Current resolution: " .. math.floor(ScrW() * size) .. " x " .. math.floor(ScrH() * size)
			local x, y = surface.GetTextSize(txt)
			surface.SetTextPos(w * 0.5 - x * 0.5, h * 0.45)
			surface.SetTextColor(255, 255, 255, 180)
			surface.DrawText(txt)
		end
		frame.OnClose = function(self)
			isOpen = nil
		end
		frame:MakePopup()

		local numslide = vgui.Create("DNumSlider", frame)
		numslide:Dock(TOP)
		numslide:DockMargin(w * 0.1, 0, 0, 0)
		numslide:SetDecimals(1)
		numslide:SetMin(1)
		numslide:SetMax(7)
		numslide:SetConVar("poster_size")
		numslide:SetText("Poster size")
		numslide.OnValueChanged = function(self, val)
			size = val
		end

		local side_margin = w * 0.1
		local btn = vgui.Create("DButton", frame)
		btn:Dock(BOTTOM)
		btn:DockMargin(side_margin, side_margin * 0.1, side_margin, 0)
		btn:SetText("Close")
		btn.DoClick = function()
			frame:Close()
		end

		--[[local btn = vgui.Create("DButton", frame)
		btn:Dock(BOTTOM)
		btn:DockMargin(side_margin, side_margin * 0.1, side_margin, 0)
		btn:SetText("Reset camera")
		btn.DoClick = function()
			return self:_2()
		end]]

		local btn = vgui.Create("DButton", frame)
		btn:Dock(BOTTOM)
		btn:DockMargin(side_margin, 0, side_margin, 0)
		btn:SetText("collectgarbage")
		btn:SetTooltip("Collects current garbage by lua to free up as much memory as possible. (Required to take higher res images as memory is very limited.)")
		btn.DoClick = function(self)
			dbg("Old memory amount before clearing: " .. collectgarbage("count") / 1000 .. " MB")
			dbg("Clearing...")
			collectgarbage()
			collectgarbage() -- gmod is special

			dbg("New memory amount after clearing: " .. collectgarbage("count") / 1000 .. " MB")
		end
	end

	concommand.Add("poster_menu", OpenUI)
end

--weapons.Register(SWEP, "poster_camera")