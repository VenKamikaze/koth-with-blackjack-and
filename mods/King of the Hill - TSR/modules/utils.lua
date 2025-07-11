
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