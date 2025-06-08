local stdio = require("@lune/stdio")
local roblox = require("@lune/roblox")
local fs = require("@lune/fs")

local Chart = require("./Chart.luau")

stdio.write("Welcome to RV9SSAS!\n")

local map_id = stdio.prompt("text", "Enter the song id:")

local song_name = stdio.prompt("text", "Enter the song name:")
local artist_name = stdio.prompt("text", "Enter the artist name:")

local ranged_bpm = stdio.prompt("confirm", "Does the beatmap have a BPM range?")
local bpm = nil
if not ranged_bpm then
    bpm = stdio.prompt("text", "Enter the fixed map BPM:")
else
     local low = stdio.prompt("text", "Enter the MINIMUM value for the BPM range:")
     local high = stdio.prompt("text", "Enter the MAXIMUM value for the BPM range:")
     bpm = low .. " - " .. high
end

local audio_id = stdio.prompt("text", "Enter the audio ID (without rbxassetid):")
local charter_name = stdio.prompt("text", "Enter the charter name:")
local cover_id = stdio.prompt("text", "Enter the cover ID for the map (do NOT include rbxassetid):")
local map_length = stdio.prompt("text", "Enter the map length (m:ss):")
local map_new = stdio.prompt("confirm", "Is the map new? (was not included in rosu!mania v7):")
local preview_point = stdio.prompt("text", "Enter the time (in seconds) at which the song is previewed:")
local song_volume = stdio.prompt("text", "Enter the song volume:")

-- individual charts section
local charts = {}

local chart_count = tonumber(stdio.prompt("text", "How many charts exist for this song? (do NOT include rates):"))

stdio.write("\n")
for i = 1, chart_count do
    local chart_name = stdio.prompt("text", string.format("(%d/%d) Enter the chart/difficult name:", i, chart_count))
    local key_count = tonumber(stdio.prompt("text", "Enter the number of keys for this chart:"))
    local object_count = tonumber(stdio.prompt("text", "Enter the number of hit objects:"))
    local stars_difficulty = tonumber(stdio.prompt("text", "Enter the chart star difficulty:"))
    local map_string = stdio.prompt("text", "Enter the chart string (output from converter):")
    charts[i] = Chart.new(chart_name, key_count, object_count, stars_difficulty, map_string)
    stdio.write("\n")
end

stdio.write("-[CREATING MAP MODEL...]-")

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
    chart_str.Value = chart:getMapString()

    chart_str.Parent = chart_folder
    chart_folder.Parent = song_folder
end



local model_file = roblox.serializeModel({ song_folder })
fs.writeFile(string.format("./output/%s.rbxm", song_folder.Name), model_file)

stdio.write("-[DONE!]-")