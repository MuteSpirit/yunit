-- -*- coding: utf-8 -*-
module(..., package.seeall);

--------------------------------------------------------------------------------------------------------------
function printTable(inTable, indent, retInsteadPrint)
--------------------------------------------------------------------------------------------------------------
    indent = indent or '';
    retInsteadPrint = retInsteadPrint or false;
    endLine = '\n';
    local out = endLine .. indent .. '{' .. endLine;
    
    for key, value in pairs(inTable) do
        out = out .. indent .. '  ["'..key..'"] = ';
        
        if 'table' == type(value) then
            addIndent = string.rep(' ', string.len('["'..key..'"] = ') + 1)
            out = out .. printTable(value, indent .. addIndent, true);
        else
            if 'string' == type(value) then 
                out = out .. '[=['..value..']=]';
            else
                out = out .. tostring(value);
            end
            out = out .. ',' .. endLine 
        end
    end
    out = out..indent..'},'..endLine;
    if retInsteadPrint then
        return out;
    else
        print(out);
    end
end


--------------------------------------------------------------------------------------------------------------
function findKey(inTable, inKey)
--------------------------------------------------------------------------------------------------------------
    for key, _ in pairs(inTable) do
        if key == inKey then
            return true;
        end
    end
    return false;
end


--------------------------------------------------------------------------------------------------------------
function findValue(inTable, inValue)
--------------------------------------------------------------------------------------------------------------
    for _, value in pairs(inTable) do
        if value == inValue then
            return true;
        end
    end
    return false;
end


--------------------------------------------------------------------------------------------------------------
function notFindValue(inTable, inValue)
--------------------------------------------------------------------------------------------------------------
    return not findValue(inTable, inValue);
end

--------------------------------------------------------------------------------------------------------------
function tableKeys(inTable)
--------------------------------------------------------------------------------------------------------------
    local keys = {};
    for key in pairs(inTable) do
        table.insert(keys, key);
    end
    return keys;
end

function table.empty(tableValue)
    return not next(tableValue);
end

--------------------------------------------------------------------------------------------------------------
function convertTextToRePattern(text)
--------------------------------------------------------------------------------------------------------------
    return string.gsub(text, '([%(%)%.%%%+%-%[%]%^%$%?%*])', '%%%1');
end

--------------------------------------------------------------------------------------------------------------
function string.split(str, delimiter)
--------------------------------------------------------------------------------------------------------------
    local parts = {};
    -- because 'delimiter' has a length, then we may not to control end position of founded 'delimiter'
    local lastDelimiterFoundedPos = 0;
    local delimPosBeg, delimPosEnd = string.find(str, delimiter, lastDelimiterFoundedPos + 1);
    while delimPosBeg and delimPosEnd do
        parts[#parts + 1] = string.sub(str, lastDelimiterFoundedPos + 1, delimPosBeg - 1);
        lastDelimiterFoundedPos = delimPosEnd;
        delimPosBeg, delimPosEnd = string.find(str, delimiter, lastDelimiterFoundedPos + 1);
    end
    -- add to 'parts' the tail of 'str', witch is after last 'delimiter'
    local length = string.len(str);
    parts[#parts + 1] = string.sub(str, lastDelimiterFoundedPos + 1, length);
    
    return parts;
end

--------------------------------------------------------------------------------------------------------------
function table.isEqual(lhs, rhs)
--------------------------------------------------------------------------------------------------------------
    if #lhs ~= #rhs then
        return false;
    end
    for kLhs, vLhs in pairs(lhs) do
        if 'table' ~= type(kLhs) then
            if not rhs[kLhs] then
                return false;
            end
            
            if 'table' ~= type(vLhs) then
                if vLhs ~= rhs[kLhs] then
                    return false;
                end
            else
                if not table.isEqual(vLhs, rhs[kLhs]) then
                    return false;
                end
            end
        else
            for kRhs, vRhs in pairs(rhs) do
                if table.isEqual(kLhs, kRhs) then
                    if 'table' ~= type(vLhs) then
                        if vLhs ~= vRhs then
                            return false;
                        else
                            break;
                        end
                    else
                        if not table.isEqual(vLhs, vRhs) then
                            return false;
                        else
                            break;
                        end
                    end
                end
            end
        end
    end
    
    return true;
end

--------------------------------------------------------------------------------------------------------------
function sleep(milliseconds)
    return os.execute('ping -4 -n ' .. milliseconds .. ' -w 1 127.0.0.1 > nul');
end