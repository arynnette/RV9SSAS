local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local stdio = require("@lune/stdio")

local Chart = require("./Chart.luau")
local Utils = require("./Utils.luau")

stdio.write("Welcome to RV9SSAS!\n\n")

local map_id = stdio.prompt("text", "Song ID:", "136")

local song_collection_dir: string =
	stdio.prompt("text", "Song directory:", Utils.SAMPLE_DIRECTORY_PATH)
local map_files: { string } = Utils.getOsuFiles(song_collection_dir)

local osu_file_path: string = map_files[1]
local file_content: string = fs.readFile(osu_file_path)

local lines = Utils.split(file_content, "\n")

local metadata_index = Utils.findDesiredLineIndex(lines, "%[Metadata%]")

local song_name = string.sub(lines[metadata_index + 1], string.len("Title:") + 1)
local artist_name = string.sub(lines[metadata_index + 3], string.len("Artist:") + 1)
local charter_name = string.sub(lines[metadata_index + 5], string.len("Creator:") + 1)

local bpm = nil
local ranged_bpm = stdio.prompt("confirm", "BPM range?", false)
if not ranged_bpm then
	bpm = stdio.prompt("text", "BPM:", "250")
else
	local low = stdio.prompt("text", "MIN BPM:", "200")
	local high = stdio.prompt("text", "MAX BPM:", "250")
	bpm = low .. " - " .. high
end

local audio_id = stdio.prompt("text", "Audio ID (without rbxassetid):", "3137651463")
local cover_id = stdio.prompt("text", "Cover ID for the map (without rbxassetid):", "1")
local map_length = stdio.prompt("text", "Map length (m:ss):", "7:03")
local map_new = stdio.prompt("confirm", "New? (not included in rosu!mania v7):", false)
local preview_point = stdio.prompt("text", "Preview time (seconds):", "300")
local song_volume = stdio.prompt("text", "Volume:", "1")

-- individual charts
local charts = {}
local chart_count = #map_files
local _override = stdio.prompt("confirm", "override?")

stdio.write("\n")

for i = 1, chart_count do
	stdio.write(string.format("\n(%d/%d)\n", i, chart_count))
	local chart_path: string = nil
	if _override then
		chart_path = stdio.prompt("text", "Chart filepath:", Utils.DEFAULT_PATH)
	else
		chart_path = map_files[i]
	end

	local chart_file_content: string = fs.readFile(chart_path)
	local chartfile_lines = Utils.split(chart_file_content, "\n")

	local difficulty_index: number =
		Utils.findDesiredLineIndex(chartfile_lines, "%[Difficulty%]")

	local chart_name = string.sub(lines[metadata_index + 6], string.len("Version:") + 1)
	local key_count =
		tonumber(string.sub(lines[difficulty_index + 2], string.len("CircleSize:") + 1))
	local object_count = Utils.objectCountOf(chartfile_lines)
	local star_difficulty = tonumber(stdio.prompt("text", "Star difficulty:", "6.28"))
	local map_string = stdio.prompt("text", "Compressed string:", Utils.SAMPLE_MAP_STRING)

	charts[i] = Chart.new(chart_name, key_count, object_count, star_difficulty, map_string)
	stdio.write("obj count: " .. object_count .. "\n")
end

stdio.write("\n-[CREATING MAP MODEL]-\n")

local song_folder = roblox.Instance.new("Folder")
song_folder.Name = string.format("[%s] %s - %s", map_id, artist_name, song_name)
song_folder:SetAttribute("ArtistName", artist_name)
song_folder:SetAttribute("AudioId", audio_id)
song_folder:SetAttribute("BPM", bpm)
song_folder:SetAttribute("CharterName", charter_name)
song_folder:SetAttribute("CoverId", cover_id)
song_folder:SetAttribute("Length", map_length)
song_folder:SetAttribute("New", map_new)
song_folder:SetAttribute("PreviewPoint", preview_point)
song_folder:SetAttribute("SongName", song_name)
song_folder:SetAttribute("Volume", song_volume)

for i, chart in pairs(charts) do
	local chart_folder = roblox.Instance.new("Folder")
	chart_folder.Name = tostring(i)
	chart_folder:SetAttribute("ChartName", chart:getName())
	chart_folder:SetAttribute("Keys", chart:getKeys())
	chart_folder:SetAttribute("Objects", chart:getObjectCount())
	chart_folder:SetAttribute("Stars", chart:getStarDifficulty())

	local chart_str = roblox.Instance.new("StringValue")
	chart_str.Name = "Chart"
	chart_str.Value = chart:getMapString()

	chart_str.Parent = chart_folder
	chart_folder.Parent = song_folder
end

local model_file = roblox.serializeModel({ song_folder }, false)
fs.writeFile("./output/output.rbxm", model_file)

stdio.write("-[DONE]-")