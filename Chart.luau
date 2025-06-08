local Chart = {}
Chart.__index = Chart

function Chart.new(chart_name: string, keys: number, objects: number, stars: number, map_string: string)
    local chart = {
        ChartName = chart_name,
        Keys = keys,
        Objects = objects,
        Stars = stars,
        MapString = map_string
    }
    
    setmetatable(chart, Chart)
    return chart
end

function Chart:getName()
    return self.ChartName
end

function Chart:getKeys()
    return self.Keys
end

function Chart:getObjectCount()
    return self.Objects
end

function Chart:getStarDifficulty()
    return self.Stars
end

function Chart:getMapString()
    return self.MapString
end

return Chart