print(" -- Starting Logging Process -- ")
task.wait(3)

local logFileName = "JBRemoteLog.txt"
writefile(logFileName, "")

local function appendToLog(line)
    appendfile(logFileName, line .. "\n")
end

local loggedRemotes = {}
local visitedTables = {}

local function logRemote(name, source, funcInfo)
    appendToLog(name .. " {")
    appendToLog("Source: " .. source)
    appendToLog("Function: " .. funcInfo)
    appendToLog("}")
    appendToLog("")
end

local function checkFunction(func)
    local info = debug.getinfo(func)
    if info.what == "Lua" then
        local constants = debug.getconstants(func)
        for _, constant in ipairs(constants) do
            if constant == "FireServer" then
                local remoteName = tostring(info.name or "Unnamed Remote")
                local source = tostring(info.source or "N/A")
                local funcInfo = (info.short_src or "N/A") .. ", Line: " .. tostring(info.currentline)

                if not loggedRemotes[remoteName] then
                    logRemote(remoteName, source, funcInfo)
                    loggedRemotes[remoteName] = true
                end
                break
            end
        end
    end
end

local function searchTable(tbl, depth)
    if visitedTables[tbl] or depth > 50 then return end
    visitedTables[tbl] = true

    for key, value in pairs(tbl) do
        if typeof(value) == "function" then
            checkFunction(value)
        elseif typeof(value) == "table" then
            searchTable(value, depth + 1)
        elseif typeof(value) == "Instance" and value:IsA("RemoteEvent") then
            local remoteName = tostring(value.Name)
            if not loggedRemotes[remoteName] then
                logRemote(remoteName, "N/A", "From a Table")
                loggedRemotes[remoteName] = true
            end
        end
    end
end

for _, obj in ipairs(getgc(true)) do
    if typeof(obj) == "function" then
        checkFunction(obj)
    elseif typeof(obj) == "table" then
        searchTable(obj, 0)
    elseif typeof(obj) == "Instance" and obj:IsA("RemoteEvent") then
        local remoteName = tostring(obj.Name or "Unnamed Remote")
        if not loggedRemotes[remoteName] then
            logRemote(remoteName, "N/A", "Direct Remote Instance")
            loggedRemotes[remoteName] = true
        end
    end
end

print("RemoteEvent log written to: " .. logFileName)
print(" -- Completed. -- ")
