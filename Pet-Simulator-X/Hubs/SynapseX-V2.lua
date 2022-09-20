---@diagnostic disable: undefined-global

local console = {}




local minecraftColors = {
    ['0'] = '\27[38;2;0;0;0m',
    ['1'] = '\27[38;2;0;0;170m',
    ['2'] = '\27[38;2;0;170;0m',
    ['3'] = '\27[38;2;0;170;170m',
    ['4'] = '\27[38;2;170;0;0m',
    ['5'] = '\27[38;2;170;0;170m',
    ['6'] = '\27[38;2;255;170;0m',
    ['7'] = '\27[38;2;170;170;170m',
    ['8'] = '\27[38;2;85;85;85m',
    ['9'] = '\27[38;2;85;85;255m',
    ['a'] = '\27[38;2;85;255;85m',
    ['b'] = '\27[38;2;85;255;255m',
    ['c'] = '\27[38;2;255;85;85m',
    ['d'] = '\27[38;2;255;85;255m',
    ['e'] = '\27[38;2;255;255;85m',
    ['f'] = '\27[38;2;255;255;255m',
    ['l'] = '\27[1m',
    ['m'] = '\27[9m',
    ['n'] = '\27[4m',
    ['o'] = '\27[3m',
    ['r'] = '\27[0m'
}

local colors = {
    -- misc
    bold     = '1',
    dim        = '2',
    underline  = '4',
    blink      = '5',
    reverse    = '7',
    hidden     = '8',
    strikethrough = '9',

    -- foreground
    black = '30',
    red = '31',
    green = '32',
    yellow = '33',
    blue = '34',
    magenta = '35',
    cyan = '36',
    white = '37',

    -- background
    bgBlack = '40',
    bgRed = '41',
    bgGreen = '42',
    bgYellow = '43',
    bgBlue = '44',
    bgMagenta = '45',
    bgCyan = '46',
    bgWhite = '47',
}

local metamethods = {
	__index = function(table, index)
		if(colors[index]) then
            if(table["ansi"]) then
                table["ansi"] = table["ansi"] .. string.char(27) .. '[' .. colors[index] .. 'm'
            else
                table["ansi"] = string.char(27) .. '[' .. colors[index] .. 'm'
            end
            return table
        end
		return nil
	end,
    __call = function(table, text, returnInsteadOfPrint)
        local ansiCopy = table["ansi"]
        table["ansi"] = ''
        if (ansiCopy) then
            if (returnInsteadOfPrint) then
                return ansiCopy .. text .. string.char(27) .. '[0m'
            else
                rconsoleprint(ansiCopy .. text .. string.char(27) .. '[0m')
            end
        else
            if (returnInsteadOfPrint) then
                return text
            else
                rconsoleprint(text)
            end
        end
    end
}


setmetatable(console, metamethods)

console.format = function(str, returnInsteadOfPrint)
    local splitted = str:split("&")
    local formatted = ""
    for _, v in ipairs(splitted) do
        color = minecraftColors[string.sub(v, 1, 1)]
        if color then
            formatted = formatted..color..string.sub(v, 2, #v)
        else
            formatted = formatted..v
        end
    end
    if (returnInsteadOfPrint) then
        return formatted
    else
        rconsoleprint(formatted)
    end
end

console.name = function(str)
    rconsolename(str)
end
console.log = function(str)
    rconsoleprint(tostring(str).."\n")
end
console.print = function(str)
    rconsoleprint(tostring(str))
end

console.color = {
    text = function(r, g, b)
        r = r or 0
        g = g or 0
        b = b or 0
        rconsoleprint("\27[38;2;"..r..";"..g..";"..b.."m")
    end,
    background = function(r, g, b)
        r = r or 0
        g = g or 0
        b = b or 0
        rconsoleprint("\27[48;2;"..r..";"..g..";"..b.."m")
        rconsoleclear()
    end,
    reset = function()
        rconsoleprint("\27[0m")
    end,
    textbackground = function(r, g, b)
        r = r or 0
        g = g or 0
        b = b or 0
        rconsoleprint("\27[48;2;"..r..";"..g..";"..b.."m")
    end,
}


console.backspace = function()
    rconsoleprint("\b \b")
end

console.clear = {
    line = function()
        rconsoleprint('\27[2K')
    end,
    all = function()
        rconsoleprint('\27[2J\27[H')
    end
}

console.reset = function()
    console.color.reset()
    rconsoleprint("\27c")
end

console.cursor = {
    hide = function()
        rconsoleprint("\27[?25l")
    end,
    show = function()
        rconsoleprint("\27[?25h")
    end,
    home = function()
        rconsoleprint("\27[H")
    end,
    up = function(count)
        for i = 1, (count or 1) do
            rconsoleprint("\27[A")
        end
    end,
    down = function(count)
        for i = 1, (count or 1) do
            rconsoleprint("\27[B")
        end
    end,
    right = function(count)
        for i = 1, (count or 1) do
            rconsoleprint("\27[C")
        end
    end,
    left = function(count)
        for i = 1, (count or 1) do
            rconsoleprint("\27[D")
        end
    end,
    move = function(x, y)
        rconsoleprint("\27["..x..";"..y.."H")
    end
}

console.n = function(count)
    count = count or 1
    for i = 1, count do
        rconsoleprint("\n")
    end
end
console.newline = console.n

console.input = function()
    return rconsoleinput()
end


--Table print
console.table = function(tbl, deepPrint)
    if (typeof(tbl) ~= 'table') then console.color.text(255, 0, 0) console.print("You didn't give me a table :(") console.color.reset() return end
    console.n()
    local strTbl = {}
    local indent = " - "
    local function Insert(s, l)
        strTbl[#strTbl + 1] = (indent:rep(l) .. s .. "\n")
    end
    local function AlphaKeySort(a, b)
        return (tostring(a.k) < tostring(b.k))
    end 
    local function PrintTable(t, lvl, lbl)
        Insert(lbl .. ":", lvl - 1)
        local nonTbls = {}
        local tbls = {}
        local keySpaces = 0
        for k,v in pairs(t) do
            if (type(v) == "table") then
                table.insert(tbls, {k = k, v = v})
            else
                table.insert(nonTbls, {k = k, v = "[" .. typeof(v) .. "] " .. tostring(v)})
            end
            local spaces = #tostring(k) + 1
            if (spaces > keySpaces) then
                keySpaces = spaces
            end
        end
        table.sort(nonTbls, AlphaKeySort)
        table.sort(tbls, AlphaKeySort)
        for _,v in ipairs(nonTbls) do
            Insert(tostring(v.k) .. ":" .. (" "):rep(keySpaces - #tostring(v.k)) .. v.v, lvl)
        end
        if (deepPrint) then
            for _,v in ipairs(tbls) do
                PrintTable(v.v, lvl + 1, tostring(v.k) .. (" "):rep(keySpaces - #tostring(v.k)) .. " [Table]")
            end
        else
            for _,v in ipairs(tbls) do
                Insert(tostring(v.k) .. ":" .. (" "):rep(keySpaces - #tostring(v.k)) .. "[Table]", lvl)
            end
        end
    end
    PrintTable(tbl, 1, tostring(tbl))
    console.white(table.concat(strTbl, ""))
    return true
end

local PNG = nil

console.png = function(data)
    if(PNG == nil) then
        PNG = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lve/StarvingArtistAuto/main/PNGDecode.lua"))()
    end
    
    local img = PNG.new(data)

    
    for i = 0, img.Height do
        for j = 0, img.Width do
            local c = img:GetPixel(j, i)
            console.color.textbackground(math.round(c.r * 255), math.round(c.g * 255), math.round(c.b * 255))
            console.print("  ")
        end
        console.n()
    end
    console.color.reset()
    console.n()
end

return console
