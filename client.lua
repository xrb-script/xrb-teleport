-- XRB-Teleport Client Script
local TeleportLocations = {
    WeedLab1 = {
        name = "Weed Lab",
        entry = {
            coords = vector3(1066.14, -3183.56, -39.16), -- Coordinates of the entrance (where you teleport TO, inside)
            heading = 75.0,                          -- Heading after entering
            target = {
	coords = vec3(102.25, 176.5, 105.0),
	size = vec3(1, 2.0, 4.0),
	rotation = 75.0,
            }
        },
        exit = {
            coords = vector3(101.99, 175.09, 104.6),  -- Coordinates where you will return to (outside, usually same as entry.target.coords or near it)
            heading = 180.0,                           -- Heading after exiting
            target = {
                coords = vec3(1066.7, -3183.5, -39.0), -- Coordinates where the ox_target for leaving will be placed (inside)
                size = vec3(1, 2.0, 4.0),
                rotation = 0
            }
        }
    },
    --[[ You can add others here
    AnotherLocation = {
        name = "Another Spot",
        entry = {
            coords = vector3(x, y, z),
            heading = h,
            target = {
                coords = vector3(tx, ty, tz),
                size = { width = w, length = l, height = h_val }, -- h_val because h is used for heading
                rotation = r
            }
        },
        exit = {
            coords = vector3(ex, ey, ez),
            heading = eh,
            target = {
                coords = vector3(etx, ety, etz),
                size = { width = ew, length = el, height = eh_val },
                rotation = er
            }
        }
    }
    --]]
}


local lastEnteredFrom = {}

-- Function to create the targets
local function CreateTeleportTargets()
    for locationKey, locationData in pairs(TeleportLocations) do
        exports.ox_target:addBoxZone({
            coords = locationData.entry.target.coords,
            size = locationData.entry.target.size,
            rotation = locationData.entry.target.rotation,
            debug = false,
            options = {
                {
                    name = locationKey .. '_enter',
                    icon = 'fas fa-sign-in-alt',
                    label = 'Enter ' .. locationData.name,
                    onSelect = function()
                        local playerPed = PlayerPedId()
                        local currentCoords = GetEntityCoords(playerPed)
                        local currentHeading = GetEntityHeading(playerPed)

                        -- Store where the player is entering from
                        lastEnteredFrom[locationKey] = {
                            coords = currentCoords,
                            heading = currentHeading
                        }
                        
                        -- Teleport player
                        SetEntityCoords(playerPed, locationData.entry.coords.x, locationData.entry.coords.y, locationData.entry.coords.z, false, false, false, true)
                        SetEntityHeading(playerPed, locationData.entry.heading)
                    end
                }
            }
        })

        -- Create target for EXIT
        exports.ox_target:addBoxZone({
            coords = locationData.exit.target.coords,
            size = locationData.exit.target.size,
            rotation = locationData.exit.target.rotation,
            debug = false, 
            options = {
                {
                    name = locationKey .. '_leave',
                    icon = 'fas fa-sign-out-alt',
                    label = 'Leave ' .. locationData.name,
                    onSelect = function()
                        local playerPed = PlayerPedId()
                        
                        local returnCoords = locationData.exit.coords
                        local returnHeading = locationData.exit.heading

                        if lastEnteredFrom[locationKey] and lastEnteredFrom[locationKey].coords then
                            returnCoords = lastEnteredFrom[locationKey].coords
                            returnHeading = lastEnteredFrom[locationKey].heading
                            lastEnteredFrom[locationKey] = nil
                        end

                        SetEntityCoords(playerPed, returnCoords.x, returnCoords.y, returnCoords.z, false, false, false, true)
                        SetEntityHeading(playerPed, returnHeading)
                    end
                }
            }
        })
    end
    print("^2[XRB-Teleport]^7 Teleport targets created successfully!")
end

CreateTeleportTargets()


AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for locationKey, _ in pairs(TeleportLocations) do
            exports.ox_target:removeZone(locationKey .. '_enter')
            exports.ox_target:removeZone(locationKey .. '_leave')
        end
        print("^1[XRB-Teleport]^7 Teleport targets removed.")
    end
end)