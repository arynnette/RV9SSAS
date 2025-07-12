local Utils = {}

function Utils.split(inputstr: string, sep: string): { number }
	-- if sep is null, set it as space
	if sep == nil then
		sep = "%s"
	end
	-- define an array
	local t = {}
	-- split string based on sep
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		-- insert the substring in table
		table.insert(t, str)
	end
	-- return the array
	return t
end

function Utils.findDesiredLineIndex(lines: string, search_for: string): number
	local foundindex = nil
	for index, line in pairs(lines) do
		if string.find(line, search_for) ~= nil then -- search for is regex
			foundindex = index
			break
		end
	end
	return foundindex
end

function Utils.objectCountOf(lines): number
	local count = 0

	local hit_objects_line_index = Utils.findDesiredLineIndex(lines, "%[HitObjects%]")

	for i = hit_objects_line_index, #lines do
		count += 1
	end
	return count - 1
end

function Utils.correctFilepath(filepath: string)
	return string.gsub(filepath, "\\", "/")
end

return Utils
