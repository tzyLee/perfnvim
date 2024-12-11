local log = require "perfnvim.log"
local utils = require "perfnvim.utils"

local client = {}

function client.buildP4Command(command, option)
    -- Build command
    local cmd = { "p4" }
    local optStr = table.concat(option or {}, " ")
    if optStr ~= '' then
        table.insert(cmd, optStr)
    end
    table.insert(cmd, command)

    return table.concat(cmd, " ")
end

function client.getP4CommandTable(command, option)
    option = option or {}
    table.insert(option, "-ztag")
    local cmdStr = client.buildP4Command(command, option)
    -- Execute the 'p4 info' command and capture the output as table
    local result = {}
    local p = io.popen(cmdStr)
    if p == nil then
        log.warn(string.format("Failed to run p4 command: '%s'.", cmdStr))
        return result
    end
    while true do
        local l = p:read("*l")
        if l == nil then
            break
        end
        if l ~= '' then
            local k, v = string.match(l, "%.%.%. ([^%s]+) ([^%s]+)")
            result[k] = v
        end
    end
    p:close()
    return result
end

function client.runP4CommandArray(command, option)
    local cmdStr = client.buildP4Command(command, option)
    -- Execute the 'p4 info' command and capture the output as array of strings
    local result = {}
    local p = io.popen(cmdStr)
    if p == nil then
        log.warn(string.format("Failed to run p4 command: '%s'.", cmdStr))
        return result
    end
    while true do
        local l = p:read("*l")
        if l == nil then
            break
        end
        table.insert(result, l)
    end
    p:close()
    return result
end

function client.runP4CommandOutput(command, option)
    local cmdStr = client.buildP4Command(command, option)
    -- Execute the 'p4 info' command and capture the output as array of strings
    local p = io.popen(cmdStr)
    if p == nil then
        log.warn(string.format("Failed to run p4 command: '%s'.", cmdStr))
        return ''
    end
    local result = p:read("*a")
    p:close()
    return result
end

function client.getClientRoot()
    local result = next(client.runP4CommandArray("info", { "-ztag", "-F", "%clientRoot%" }))
    if result == nil then
        log.warn "Failed to obtain client root from p4 info."
        return ''
    end
    return result
end

function client.getClientName()
    local result = next(client.runP4CommandArray("info", { "-ztag", "-F", "%clientName%" }))
    if result == nil then
        log.warn "Failed to obtain client name from p4 info."
        return ''
    end
    return result
end

function client.getClientStream()
    local result = next(client.runP4CommandArray("info", { "-ztag", "-F", "%clientStream%" }))
    if result == nil then
        log.warn "Failed to obtain client stream from p4 info."
        return ''
    end
    return result
end

function client.getOpenedFiles(localPath)
    localPath = localPath or false
    local result = client.runP4CommandArray("opened", { "-ztag", "-F", "%clientFile%" })
    if next(result) == nil then
        log.warn "Failed to obtain opened files."
        return {}
    end
    if localPath then
        local clientInfo = client.getP4CommandTable("info")
        local clientRoot = clientInfo["clientRoot"]
        local clientName = clientInfo["clientName"]
        if clientInfo == nil or clientName == nil then
            log.warn "Failed to obtain client info."
            return {}
        end
        local pattern = "//" .. utils.quote(clientName)
        for i, v in ipairs(result) do
            result[i] = v:gsub(pattern, clientRoot, 1)
        end
    end
    return result
end

return client
