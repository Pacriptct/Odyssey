-- src/shared/UI/Primitives/GridPack.luau
--
-- First-fit bin packer for DayZ-style inventory grids. Given entries (each with
-- a W x H footprint) and a fixed column count, assigns every entry a top-left
-- cell so footprints tile without overlapping, growing downward as needed.
-- Positions are derived (not persisted) -- deterministic for a given order.

local GridPack = {}

local function fits(occupied, x, y, w, h, columns)
	if x + w > columns then
		return false
	end
	for cy = y, y + h - 1 do
		local row = occupied[cy]
		if row then
			for cx = x, x + w - 1 do
				if row[cx] then
					return false
				end
			end
		end
	end
	return true
end

local function mark(occupied, x, y, w, h)
	for cy = y, y + h - 1 do
		occupied[cy] = occupied[cy] or {}
		for cx = x, x + w - 1 do
			occupied[cy][cx] = true
		end
	end
end

-- entries: { { Key, W, H, ... }, ... }. Returns placements
-- { { entry, x, y, w, h }, ... } (0-based cells) and the total row count.
function GridPack.pack(entries: { any }, columns: number)
	columns = math.max(1, math.floor(columns))
	local occupied = {}
	local placements = {}
	local rows = 0

	for _, entry in ipairs(entries) do
		local w = math.clamp(math.floor(tonumber(entry.W) or 1), 1, columns)
		local h = math.max(1, math.floor(tonumber(entry.H) or 1))

		local y = 0
		local placed = false
		while not placed do
			for x = 0, columns - w do
				if fits(occupied, x, y, w, h, columns) then
					mark(occupied, x, y, w, h)
					table.insert(placements, { entry = entry, x = x, y = y, w = w, h = h })
					rows = math.max(rows, y + h)
					placed = true
					break
				end
			end
			if not placed then
				y += 1
				if y > 256 then
					break -- safety valve
				end
			end
		end
	end

	return placements, rows
end

return GridPack
