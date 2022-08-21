--[[---------------INFO-------------------- 
	CONTRIBUTOR(S): d_ytme, incapaz (hasProperty), thatTimothy (TableSort), stravant (Separate plugins in the same toolbar section work-around)
	CREATION DATE: 8/21/2022
	LAST EDIT DATE: 8/21/2022
	DETAILS: Distribute Parts Plugin script, fork of AnchorPointer
--]]---------------VARIABLES--------------- 

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")

local toolbar = game:FindFirstChild("SammyQOF")
if not toolbar then
	toolbar = plugin:CreateToolbar("Sammy's QOF")
	toolbar.Name = "SammyQOF"
	toolbar.Parent = game
end

local distributePartsButton = toolbar:CreateButton("Distribute Parts", "Spaces all selected parts at an equal distance.", "rbxassetid://10673105958")

-------------------FUNCTIONS--------------- 

local function has_property(instance, property)
	local clone = instance:Clone()
	clone:ClearAllChildren()

	return (pcall(function()
		return clone[property]
	end))
end

local function findFurthestParts(Parts)
	local furthestParts = {nil, nil, 0}
	for index,part in pairs(Parts) do -- For every part in the table
		for index,comparePart in pairs(Parts) do -- Take once again all parts inside the table
			local distance = (part.Position - comparePart.Position).Magnitude -- Check the distance between them
			if distance > furthestParts[3] then furthestParts = {part, comparePart, distance} end -- If it's bigger than the previous biggest number then modify furthestParts with the new ones
		end
	end
	
	return furthestParts
end

-- Actually does the distribution
local function Distribute()
	local selectedObjects = Selection:Get()
	if #selectedObjects == 0 then return end
	
	local ActiveElements = {} -- Everything that can actually influence the plugin.. If you have invalid objects selected it won't error out this way.
	for _,v in pairs(selectedObjects) do
		if has_property(v, "Position") then
			table.insert(ActiveElements, v)
		end
	end
	
	local toMoveParts = {} -- Parts that will actually move
	
	local furthestParts = findFurthestParts(ActiveElements)
	local C1, C2 = furthestParts[1], furthestParts[2] -- Corner1 and Corner2
	local C1P, C2P = C1.Position, C2.Position -- Respective positions
	
	local Region = Region3.new(C1.Position, C2.Position)
	local RS = Region.Size
	local incX, incY, incZ = math.abs(RS.X) / (#ActiveElements - 1), math.abs(RS.Y) / (#ActiveElements - 1), math.abs(RS.Z) / (#ActiveElements - 1) -- Calculates the increments for all axis
	
	local xM, yM, zM = 1, 1, 1 -- Multipliers for all 3 axis
	
	if C1P.X > C2P.X then xM = -1 end
	if C1P.Y > C2P.Y then yM = -1 end
	if C1P.Z > C2P.Z then zM = -1 end
	
	for _,v in pairs(ActiveElements) do
		if v ~= C1 and v ~= C2 then 
			table.insert(toMoveParts, v)
		end
	end
	
	ChangeHistoryService:SetWaypoint("DistributeParts - Distributing")
	-- Goes through all parts that actually move in the process
	for index,part in pairs(toMoveParts) do
		
		-- Calculates new positions for all axis
		local X = C1.Position.X + index*incX*xM
		local Y = C1.Position.Y + index*incY*yM
		local Z = C1.Position.Z + index*incZ*zM

		part.Position = Vector3.new(X, Y, Z)
	end
	ChangeHistoryService:SetWaypoint("DistributeParts - Distributing")	
end

-------------------STARTUP----------------- 

-------------------CONNECTIONS------------- 

distributePartsButton.Click:Connect(Distribute)

-------------------LOOP-------------------- 