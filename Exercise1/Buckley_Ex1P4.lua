inhabitants = 10^5

dam_start_volume = 5 * 10^9 
dam_max_volume = 5 * 10^9

water_volume_for_unit_kwh = 100

inhabitant_kwh_consumption_monthly = 10
energy_consumption_delta_quarterly = 1+(0.05/4)
energy_consumption_delta_monthly = 1+(0.05/12)

monthly_consumption = inhabitant_kwh_consumption_monthly*inhabitants*water_volume_for_unit_kwh

world = Cell{dam_volume = dam_start_volume,
		consumption = monthly_consumption,
        rainy_season_one_volume = 1 * 10^9, 
        rainy_season_two_volume = 0.75 * 10^9, 
}

print(world.dam_volume)


--[[
o = Observer{
    subject = world,
    type = "logfile",
    attributes = {"dam_volume","consumption"},
    separator = ",",
    file = "/Users/tbuckley/Documents/Modeling/testme.csv",
}
--]]

o = Observer{
    subject = world,
    type = "chart",
    attributes = {"dam_volume"}
}

t = Timer {
    Event {time = 1, period = 1, action = function()
        if world.dam_volume - world.consumption < 0 then
            world.dam_volume = 0
        else
            world.dam_volume = world.dam_volume - world.consumption
        end
    end},
    Event {time = 1, period = 1, action = function()
        world.consumption = world.consumption*(energy_consumption_delta_monthly)
    end},
    Event {time = 3.1, period = 12, action = function()
        if world.dam_volume + world.rainy_season_one_volume >= dam_max_volume then
            world.dam_volume = dam_max_volume
        else
            world.dam_volume = world.dam_volume + world.rainy_season_one_volume
        end
    end},
    Event {time = 4.1, period = 12, action = function()
        if world.dam_volume + world.rainy_season_one_volume >= dam_max_volume then
            world.dam_volume = dam_max_volume
        else
            world.dam_volume = world.dam_volume + world.rainy_season_one_volume
        end
    end},
    Event {time = 8.1, period = 12, action = function()
        if world.dam_volume + world.rainy_season_two_volume >= dam_max_volume then
            world.dam_volume = dam_max_volume
        else
            world.dam_volume = world.dam_volume + world.rainy_season_two_volume
        end
    end},
    Event {time = 9.1, period = 12, action = function()
        if world.dam_volume + world.rainy_season_two_volume >= dam_max_volume then
            world.dam_volume = dam_max_volume
        else
            world.dam_volume = world.dam_volume + world.rainy_season_two_volume
        end
    end},
    Event {time = 20*12, period = 1000, action = function()
        world.rainy_season_two_volume = world.rainy_season_two_volume/2
        world.rainy_season_one_volume = world.rainy_season_one_volume/2
    end},
    Event {time = 0, period = 1, action = function(e)
    	world:notify(e:getTime())
    end},
}

t:execute(630)
