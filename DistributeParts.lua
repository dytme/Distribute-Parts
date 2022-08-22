--[[---------------INFO-------------------- 
	CONTRIBUTOR(S): d_ytme, incapaz (hasProperty), stravant (Separate plugins in the same toolbar section work-around), ROBLOX (ResetPivot)
	CREATION DATE: 8/21/2022
	LAST EDIT DATE: 8/21/2022
	DETAILS: Distribute Parts Plugin script, fork of AnchorPointer
--]]---------------VARIABLES--------------- 

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")
local DebrisService = game:GetService("Debris")

local toolbar = game:FindFirstChild("SammyQOF")
if not toolbar then
	toolbar = plugin:CreateToolbar("Sammy's QOF")
	toolbar.Name = "SammyQOF"
	toolbar.Parent = game
end

local distributePartsButton = toolbar:CreateButton("Distribute Parts", "Spaces all selected parts at an equal distance.", "rbxassetid://10673105958")

-------------------FUNCTIONS--------------- 

local function resetPivot(model)
	local boundsCFrame = model:GetBoundingBox()
	if model.PrimaryPart then
		model.PrimaryPart.PivotOffset = model.PrimaryPart.CFrame:ToObjectSpace(boundsCFrame)
	else
		model.WorldPivot = boundsCFrame
	end
end

local function has_property(instance, property)
	local clone = instance:Clone()
	clone:ClearAllChildren()

	return (pcall(function()
		return clone[property]
	end))
end

local function findFurthestParts(Objects)
	local furthestObjects = {nil, nil, nil, nil, 0}
	for index,object in pairs(Objects) do -- For every part in the table
		for index2,compareObject in pairs(Objects) do -- Take once again all Objects inside the table
			--print(index,index2)
			local distance = (object[2] - compareObject[2]).Magnitude -- Check the distance between them
			--print(distance, furthestParts[3], distance > furthestParts[3])
			if distance > furthestObjects[5] then furthestObjects = {object[1], object[2], compareObject[1], compareObject[2], distance} end -- If it's bigger than the previous biggest number then modify furthestObjects with the new ones
		end
	end
	
	return furthestObjects
end

-- Actually does the distribution
local function Distribute()
	local selectedObjects = Selection:Get()
	if #selectedObjects == 0 then return end
	
	local ActiveElements = {} -- Everything that can actually influence the plugin.. If you have invalid objects selected it won't error out this way.
	                          -- Will come in use later to check the distance between all selected objects. Kind of a work-around but this plugin was initially only for parts or meshes.
	for _,v in pairs(selectedObjects) do
		if has_property(v, "Position") then
			table.insert(ActiveElements, {v, v.Position})
		elseif v:IsA("Model") then
			resetPivot(v)
			table.insert(ActiveElements, {v, v.WorldPivot.Position})
		end
	end
	
	
	
	local furthestParts = findFurthestParts(ActiveElements)
	local C1, C2 = furthestParts[1], furthestParts[3] -- Corner1 and Corner2
	local C1P, C2P = furthestParts[2], furthestParts[4] -- Respective positions
	
	local Region = Region3.new(C1P, C2P)
	local RS = Region.Size
	local incX, incY, incZ = math.abs(RS.X) / (#ActiveElements - 1), math.abs(RS.Y) / (#ActiveElements - 1), math.abs(RS.Z) / (#ActiveElements - 1) -- Calculates the increments for all axis
	
	local xM, yM, zM = 1, 1, 1 -- Multipliers for all 3 axis
	
	if C1P.X > C2P.X then xM = -1 end
	if C1P.Y > C2P.Y then yM = -1 end
	if C1P.Z > C2P.Z then zM = -1 end
	
	local toMoveParts = {} -- Parts that will actually move
	for _,v in pairs(ActiveElements) do
		if v[1] ~= C1 and v[1] ~= C2 then 
			table.insert(toMoveParts, v[1])
		end
	end
	
	ChangeHistoryService:SetWaypoint("DistributeParts - Distributing")
	-- Goes through all parts that actually move in the process
	for index,obj in pairs(toMoveParts) do
		
		-- Calculates new positions for all axis
		if obj:IsA("Model") then
			
			--resetPivot(obj)
			
			--else
		end
			
		local X,Y,Z = 
			C1P.X + index*incX*xM,
			C1P.Y + index*incY*yM,
			C1P.Z + index*incZ*zM

		obj:PivotTo(CFrame.new(X, Y, Z) * obj.CFrame.Rotation)
			
		--end
		
	end
	ChangeHistoryService:SetWaypoint("DistributeParts - Distributing")	
end

-------------------STARTUP----------------- 

-------------------CONNECTIONS------------- 

distributePartsButton.Click:Connect(Distribute)

-------------------LOOP-------------------- 
