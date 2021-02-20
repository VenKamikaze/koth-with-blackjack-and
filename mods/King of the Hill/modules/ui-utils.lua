
--- Retrieves all the armies that are controlled by a player.
function FindPlayersUI()

	-- an army needs to be human controlled in order
	-- to be applicable.
	local armies = GetArmiesTable().armiesTable;
	local applicableArmies = { };
	for k, army in armies do
        if army.human then
            local information = {
                -- information to match the brain on the sim side
                name = army.name,
                color = army.color,
                nickname = army.nickname,
                faction = army.faction,
            }
			table.insert(applicableArmies, army);
		end
	end

	return applicableArmies;
end

--- Returns the index of the element in the table that matches the predicate or -1.
-- @param table The table to search through.
-- @param predicate The predicate that accepts one argument: an element from the table.
-- @return The index of the first element that matches the predicate or -1.
function FindByPredicate(table, predicate)
    if table then 
        for k, value in table do 
            if predicate(value) then 
                return k
            end
        end
    end

    return -1
end