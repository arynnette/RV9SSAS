local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local stdio = require("@lune/stdio")

local Utils = require("./ConversionUtils.luau")
local json = require("./json.luau")

local song_dir = Utils.getJSONFiles(Utils.CONVERSION_DIRECTORY_PATH)

local songs = roblox.Instance.new("Folder")
songs.Name = "Songs"

for index, song in pairs(song_dir) do
    local json_file = fs.readFile(song)
    local decoded_json = json.decode(json_file)

    stdio.write(string.format("Converting songs (%d/%d)\n", index, #song_dir))

    song_folder = roblox.Instance.new("Folder")
    song_folder.Name = string.format("[%s] %s - %s", index, decoded_json.AudioArtist, decoded_json.AudioFilename)
    song_folder:SetAttribute("ArtistName", decoded_json.AudioArtist)
    song_folder:SetAttribute("AudioID", 0)
    song_folder:SetAttribute("CharterName", decoded_json.AudioMapper)
    song_folder:SetAttribute("Difficulty", 0)
    song_folder:SetAttribute("Length", "0:00")
    song_folder:SetAttribute("ObjectCount", #decoded_json.HitObjects)
    song_folder:SetAttribute("SongName", decoded_json.AudioFilename)
    song_folder:SetAttribute("Volume", 1)

    local chart_stringval = roblox.Instance.new("StringValue")
    chart_stringval.Name = "ChartString"
    chart_stringval.Value = json_file
    chart_stringval.Parent = song_folder
    song_folder.Parent = songs
end

local model_file = roblox.serializeModel({ songs }, false)
fs.writeFile("./output/converted.rbxm", model_file)

stdio.write("-[DONE]-")