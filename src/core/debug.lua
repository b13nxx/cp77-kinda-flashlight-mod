function splitString(input, sep)
  local result = {}
  local start, last, nextStart = 1, 0, 0
  sep = sep or '%s'

  repeat
    last, nextStart = input:find(sep, start)

    if last ~= nil then
      table.insert(result, last == start and '' or input:sub(start, last - 1))
      start = nextStart + 1
    else
      table.insert(result, start > input:len() and '' or input:sub(start, input:len()))
    end
  until last == nil

  return result
end

function getTypeOf(value)
  local result = ''
  
  if type(value) == 'string' then
    result = 'str'
  elseif type(value) == 'number' then
    result = 'num'
  elseif type(value) == 'boolean' then
    result = 'bool'
  elseif type(value) == 'function' then
    result = 'func'
  elseif type(value) == 'table' then
    result = 'table'
  elseif type(value) == 'thread' then
    result = 'thrd'
  elseif type(value) == 'userdata' then
    result = 'usrdt'
  end

  return result
end

function getStringOf(value)
  local stringified = tostring(value)

  if stringified:find('function') ~= nil or stringified:find('userdata') ~= nil then
    stringified = splitString(stringified, ': ')[2]
  end

  return stringified
end

function tprint(t, s)
  for k, v in pairs(t) do
    local kfmt = '[' .. getTypeOf(k) .. ': ' .. (type(k) == 'string' and '"' or '') .. getStringOf(k) .. (type(k) == 'string' and '"' or '') .. ']'
    local vfmt = getTypeOf(v) .. ': ' .. (type(v) == 'string' and '"' or '') .. getStringOf(v) .. (type(v) == 'string' and '"' or '')

    if type(v) == 'table' then
      tprint(v, (s or '') .. kfmt)
    else
      print(getTypeOf(t) .. (s or '') .. kfmt ..' = '.. vfmt)
    end
  end
end
