local floor = math.floor
local format = string.format
local gmatch = string.gmatch
local concat = table.concat

local function gradient_text(text, start_colour, end_colour, colour_spaces)
	if type(text) ~= "string" or type(start_colour) ~= "table" or type(end_colour) ~= "table" then
		return ""
	end

	local start_r, start_g, start_b = start_colour[1], start_colour[2], start_colour[3]
	local end_r, end_g, end_b = end_colour[1], end_colour[2], end_colour[3]

	if
		type(start_r) ~= "number"
		or type(start_g) ~= "number"
		or type(start_b) ~= "number"
		or type(end_r) ~= "number"
		or type(end_g) ~= "number"
		or type(end_b) ~= "number"
	then
		return ""
	end

	local chars = {}
	local char_count = 0
	local visible_count = 0

	for char in gmatch(text, "[%z\1-\127\194-\244][\128-\191]*") do
		char_count = char_count + 1
		chars[char_count] = char

		if colour_spaces or char ~= " " then
			visible_count = visible_count + 1
		end
	end

	local parts = {}
	local part_count = 0
	local current = 0

	for i = 1, char_count do
		local char = chars[i]

		if not colour_spaces and char == " " then
			part_count = part_count + 1
			parts[part_count] = char
		else
			current = current + 1
			local t = visible_count <= 1 and 0 or (current - 1) / (visible_count - 1)

			part_count = part_count + 1
			parts[part_count] = format(
				"{#color(%d,%d,%d)}%s",
				floor(start_r + (end_r - start_r) * t),
				floor(start_g + (end_g - start_g) * t),
				floor(start_b + (end_b - start_b) * t),
				char
			)
		end
	end

	return concat(parts)
end

return gradient_text
