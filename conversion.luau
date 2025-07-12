local process = require("@lune/process")

local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local stdio = require("@lune/stdio")
local serde = require("@lune/serde")

local Utils = require("./utils.luau")
local json = require("./json.luau")

local compression = require("./compression.luau").Zlib

local BASE_DIR

for index, arg in process.args do
    local spl = string.split(arg, "=")

    local flag = spl[1]
    local value = spl[2]

    if flag == "--path" then
        BASE_DIR = value
    end

	print("Process argument #" .. tostring(index) .. ": " .. arg)
end

if not BASE_DIR then
    print("You did not provide a song directory.")
    return
end

local song_listing = fs.readDir(BASE_DIR)

local METADATA_FILE = "metadata.yml"
local HIT_OBJECTS_FILE = "objects.yml"

local function getFullDirectory(song, ext)
    return BASE_DIR .. "/" .. song .. "/" .. ext
end

local songs = roblox.Instance.new("Folder")
songs.Name = "Songs"

local function to_base64(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

for index, song in pairs(song_listing) do
    local suc, err = pcall(function()
        local metadata = serde.decode("yaml", fs.readFile(getFullDirectory(song, METADATA_FILE)))
        local hitObjects = serde.decode("yaml", fs.readFile(getFullDirectory(song, HIT_OBJECTS_FILE)))

        local difficulty = 0
        local length = 0

        if typeof(metadata.Difficulty) == "table" then
            for _, rateMetadata in metadata.Difficulty do
                if rateMetadata.Rate == 100 then
                    difficulty = rateMetadata.Overall
                    break
                end
            end
        else
            difficulty = metadata.Difficulty
        end

        local lastHitObject = hitObjects[#hitObjects]
        length = lastHitObject.Time + (if lastHitObject.Duration then lastHitObject.Duration else 0)

        stdio.write(string.format("Converting songs (%d/%d)\n", index, #song_listing))

        song_folder = roblox.Instance.new("Folder")
        song_folder.Name = string.format("[%s] %s - %s", index, metadata.Artist or "Unknown", metadata.Filename or "Unknown")
        song_folder:SetAttribute("ArtistName", metadata.Artist)
        song_folder:SetAttribute("AudioID", 0)
        song_folder:SetAttribute("CharterName", metadata.Mapper)
        song_folder:SetAttribute("Difficulty", difficulty or 0)
        song_folder:SetAttribute("Length", length)
        song_folder:SetAttribute("ObjectCount", #hitObjects)
        song_folder:SetAttribute("SongName", metadata.Filename)
        song_folder:SetAttribute("Volume", 1)

        local encodedNotes = serde.encode("json", hitObjects)

        local chart_stringval = roblox.Instance.new("StringValue")
        chart_stringval.Name = "ChartString"
        chart_stringval.Value = to_base64(compression.Compress(encodedNotes))
        chart_stringval.Parent = song_folder
        song_folder.Parent = songs
    end)

    if not suc then
        print(err)
    end
end

local model_file = roblox.serializeModel({ songs }, false)
fs.writeFile("./output/converted.rbxm", model_file)

stdio.write("-[DONE]-")