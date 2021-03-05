-- ░█████╗░██╗░░░░░██╗███████╗███╗░░██╗████████╗
-- ██╔══██╗██║░░░░░██║██╔════╝████╗░██║╚══██╔══╝
-- ██║░░╚═╝██║░░░░░██║█████╗░░██╔██╗██║░░░██║░░░
-- ██║░░██╗██║░░░░░██║██╔══╝░░██║╚████║░░░██║░░░
-- ╚█████╔╝███████╗██║███████╗██║░╚███║░░░██║░░░
-- ░╚════╝░╚══════╝╚═╝╚══════╝╚═╝░░╚══╝░░░╚═╝░░░

local isSearching = false -- Determines if the player is searching a trashbin currently.
local hoboActivated = false -- This state is determined by running the hobomode command.

RegisterCommand( -- This will register the command for hobomode
	"hobomode",
	function()
		if hoboActivated then -- Checks to see if hoboActivated is true.
			hoboFalse() -- call this function.
		elseif not hoboActivated then -- If hoboActivated is == to false.
			hoboTrue() -- call this function.
		end
		return
	end
)

RegisterCommand( -- Registers a command
	"askmoney",
	function()
		if hoboActivated then -- If hobomode is set to true then execute the following.
			AskForMoney() -- Call this function
		else
		end
		return
	end
)

function hoboTrue()
	local player = PlayerPedId() -- This sets the value of var player to the players ped ID.
	local hoboanim = Config.hoboanim -- This is the animation dictionary
	RequestAnimSet(hoboanim) -- Requests the animation dictionary
	while not HasAnimSetLoaded(hoboanim) do -- While the dictionary is still loading wait
		Citizen.Wait(0)
	end
	hoboActivated = not hoboActivated -- The same thing as above, but in this case we are setting it to true..
	SetPedMovementClipset(player, hoboanim, 1) -- Set the peds movement style to the "hobo" style lol. | https://wiki.gtanet.work/index.php?title=Animations
	return
end

function hoboFalse()
	local player = PlayerPedId() -- This sets the value of var player to the players ped ID.
	ResetPedMovementClipset(player) -- Reset the players movement style. | https://docs.fivem.net/natives/?_0xAA74EC0CB0AAEA2C
	ResetPedWeaponMovementClipset(player)
	ResetPedStrafeClipset(player)
	hoboActivated = not hoboActivated -- Set the var to the opposite to the current bool. In this case its setting to false.
	return
end

function GetPedInFront() -- I found this function off the forums.. I am not sure where/I do not remember. If this is you're work please dm me and i will credit you!
	local plyPed = PlayerPedId() -- This sets the value of var player to the players ped ID.
	local plyPos = GetEntityCoords(plyPed, false) -- Gets the players coordinates and packs it into a cute little table.
	local plyOffset = GetOffsetFromEntityInWorldCoords(plyPed, 0.0, 1.3, 0.0)
	local rayHandle = StartShapeTestCapsule(plyPos.x, plyPos.y, plyPos.z, plyOffset.x, plyOffset.y, plyOffset.z, 1.0, 12, plyPed, 7)
	local _, _, _, _, ped = GetShapeTestResult(rayHandle)
	return ped -- Return the closest ped found
end

function AskForMoney() -- Function for asking money from the peds.
	local ped = GetPedInFront() -- Gets the ped infront of the player.
	local player = PlayerPedId() -- This sets the value of var player to the players ped ID.

	local adict = Config.adict -- The animation disctionary
	local anim = Config.anim -- The animation from the dictionary

	RequestAnimDict(adict) -- Requests the animation dictionary
	while not HasAnimDictLoaded(adict) do -- While the dictionary is still loading wait
		Citizen.Wait(0)
	end

	ClearPedTasksImmediately(player) -- Clear the peds animation/scenarios instantly.

	local money = CreateObject(GetHashKey("hei_prop_heist_cash_pile"), 0, 0, 0, true) -- Creates an entity and assigns it VAR money.
	AttachEntityToEntity(money, ped, GetPedBoneIndex(ped, 57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, 1, 0, 1, 0, 1) -- Attach the entity to the peds hand.

	TaskTurnPedToFaceEntity(player, ped, 5000) -- make the player face the ped.
	TaskTurnPedToFaceEntity(ped, player, 5000) -- make the ped face the player
	Citizen.Wait(3500) -- Just wait until they turned to each other

	TaskPlayAnim(player, adict, anim, 8.0, -8, -1, 49, 0, 0, 0, 0) -- Play the animation requested above
	TaskPlayAnim(ped, adict, anim, 8.0, -8, -1, 49, 0, 0, 0, 0) -- Play the animation requested above

	Citizen.Wait(1500) -- Wait for a smooth transition.
	DeleteEntity(money) -- Delete the entity money
	ClearPedTasksImmediately(player) -- Clear the players task so we are not in a loop of the animation.
	return
end

Citizen.CreateThread( -- This is the main thread.
	function()
		while true do -- While the state is true (basically infinite since we just put true.)
			local threadSleep = 800 -- Set the thread to sleep for 800ms for performanace.
			local player = PlayerPedId() -- This sets the value of var player to the players ped ID.
			local ploc = GetEntityCoords(player) -- Grabes the players location and puts it into a table. | https://docs.fivem.net/natives/?_0x1647F1CB
			
			if hoboActivated and not isSearching then -- Checks to see if the hoboActivated var is true and the searching var is false.
				for i, v in pairs(Config.Dumpsters) do -- For the index value("i") and the value of the index("v") in the table Config.Dumpsters do the following.
					local dump = GetClosestObjectOfType(ploc.x, ploc.y, ploc.z, 1.0, v, false, false, false) -- Gets the closest object type from the player using the variable V and sets that entity to the variable dump | https://docs.fivem.net/natives/?_0xE143FA2249364369

					if DoesEntityExist(dump) then -- Checks to see if the entity exists.
						threadSleep = 10 -- We need to lower the thread wait so we can execute with ease. Otherwise we would be spamming the keypress in order for it to work XD.

						if IsControlJustPressed(0, 74) then -- This defines if a certain key has been pressed. In this case we are using the key H | https://docs.fivem.net/docs/game-references/controls/
							isSearching = true -- Sets to searching to true to disable spamming.
							TaskStartScenarioInPlace(player, "PROP_HUMAN_BUM_BIN", 0, true) -- Make the ped play a scenario. | https://pastebin.com/6mrYTdQv
							local Item = Config.Items[math.random(#Config["Items"])] -- Gets a random value from a table and assigns it the variable Item.
							for i, v in pairs(Config.Weapons) do -- iterate through the weapons table to see if var Item matches anything here.
								if v == Item then -- if that item matches then execute the followin.
									GiveWeaponToPed(player, Item) -- Give the weapon to the player. Since we already have the model from var Item we just use that.
								else -- If it does not then we send them a notification with whatever else they found.
									print(Item)
								end
							end
							Citizen.Wait(5000) -- Waits for 5000ms(5 seconds)
							isSearching = false -- Sets the searching var to false.
							ClearPedTasks(player) -- Reset the ped tasks to clear the scenario in this case. | https://docs.fivem.net/natives/?_0xE1EF3C1216AFF2CD
						end
					end
				end
			end

			Citizen.Wait(threadSleep) -- Sleep for the current value depending on the users search status.
		end
	end
)