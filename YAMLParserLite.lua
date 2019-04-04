YAMLParserLite = class("YAMLParserLite")

function YAMLParserLite:initialize()
end

-- 以上为项目已有结构

local schar = string.char
local ssub, gsub = string.sub, string.gsub
local sfind, smatch = string.find, string.match
local tinsert, tremove = table.insert, table.remove

-- help function

local function select(list, pred)
  local selected = {}
  for i = 0, #list do
    local v = list[i]
    if v and pred(v, i) then
      tinsert(selected, v)
    end
  end
  return selected
end

local function trim(str)
    return string.gsub(str, "^%s*(.-)%s*$", "%1")
end

local function ltrim(str)
  return smatch(str, "^%s*(.-)$")
end

local function rtrim(str)
  return smatch(str, "^(.-)%s*$")
end

local function isemptyline(line)
    return line == '' or sfind(line, '^%s*$') or sfind(line, '^%s*#')
end

-- implement function

local function parse_string(scalar)
    scalar = trim(scalar)
    local str = string.match(scalar, '%"(.+)%"')
    -- scalar = string.match(scalar, '%"(.+)%"')
    if nil ~= str then
        return str
    else
        str = string.match(scalar, '\'(.+)\'')
        return str
    end
end

local function parse_scalar(scalar)

    -- print("parse_scalar()", scalar)
    if scalar == '' or scalar == '~' then
        return nil
    end

    local s = parse_string(scalar)
    if s and s ~= scalar then
        return s
    end

    -- Special cases
    if sfind('\'"!$', ssub(scalar, 1, 1), 1, true) then
        error('unsupported line: '..scalar)
    end

    -- Regular unquoted string
    local v = scalar
    if v == 'null' or v == 'Null' or v == 'NULL'then
        return null
    elseif v == 'true' or v == 'True' or v == 'TRUE' then
        return true
    elseif v == 'false' or v == 'False' or v == 'FALSE' then
        return false
    elseif v == '.inf' or v == '.Inf' or v == '.INF' then
        return math.huge
    elseif v == '+.inf' or v == '+.Inf' or v == '+.INF' then
        return math.huge
    elseif v == '-.inf' or v == '-.Inf' or v == '-.INF' then
        return -math.huge
    elseif v == '.nan' or v == '.NaN' or v == '.NAN' then
        return 0 / 0
    elseif sfind(v, '^[%+%-]?[0-9]+$') or sfind(v, '^[%+%-]?[0-9]+%.$')then
        return tonumber(v)  -- : int
    elseif sfind(v, '^[%+%-]?[0-9]+%.[0-9]+$') then
        return tonumber(v)
    end
    return v

end

local function parse_key_value_pair(line)

    -- print("1. parse_key_value_pair()", line)
    line = trim(line)
    line = string.gsub(line, "%-%s*", "")
    -- print("2. parse_key_value_pair()", line)

    -- Attention: "- " (_ and a space) is necessary for yaml 
    local key, value = string.match(line, "(.+):%s(.+)")
    key = parse_scalar(key)
    value = parse_scalar(value)
    return key, value
end

local function parse_brace_line(line)

    -- print("1. parse_brace_line()", line)
    line = trim(line)
    line = string.gsub(line, "%-%s*", "")
    line = string.match(line, "%{(.+)%}")
    -- print("2. parse_brace_line()", line)

    local res = {}
    for pair in string.gmatch(line, "[^%,]+") do
        local key, value = parse_key_value_pair(pair)
        res[tostring(key)] = value
    end

    return res
end

local function parse_documents(lines)
    lines = select(lines, function(s) return not isemptyline(s) end)

    if sfind(lines[1], '^%%YAML') then 
        tremove(lines, 1)
    end

    local root = {}
    local in_document = false

    local is_single_table = false
    if #lines > 0 then
        local line = lines[1]
        if sfind(line, "%{.+%}") then
            is_single_table =  false
        else
            is_single_table = true
        end
    end

    if is_single_table then
        for i = 1, #lines do
            local line = lines[i]
            local key, value = parse_key_value_pair(line)
            root[tostring(key)] = value
        end
    else
        for i = 1, #lines do
            local line = lines[i]
            local tb = parse_brace_line(line)
            table.insert(root, tb)
        end
    end

    return root
end

function YAMLParserLite:parse(yaml)
    local lines = {}
    for line in string.gmatch(yaml..'\n', '(.-)\n') do
        table.insert(lines, line)
    end

    local docs = parse_documents(lines)
    if #docs == 1 then
        return docs[1]
    end
    return docs
end
