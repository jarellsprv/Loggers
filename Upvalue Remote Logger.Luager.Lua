print(" -- Starting Logging Process -- ")
for count = 0, 4 do
    local logFileName = "JBTestLog" .. tostring(count) .. ".txt"
    writefile(logFileName, "")

    local function appendToLog(line)
        appendfile(logFileName, line .. "\n")
    end

    local loggedFunctions = {}

    for _, search in pairs(getgc(true)) do
        if typeof(search) == "function" then
            local info = debug.getinfo(search)
            if info.what == "Lua" then
                local functionKey = info.name or "anonymous"

                if loggedFunctions[functionKey] then
                    continue
                end

                local upvalues = debug.getupvalues(search)
                local hasRemoteEvent = false

                for _, value in pairs(upvalues) do
                    if typeof(value) == "Instance" and value:IsA("RemoteEvent") then
                        hasRemoteEvent = true
                        break
                    end
                end

                if not hasRemoteEvent then
                    continue
                end

                appendToLog("Function name: " .. tostring(info.name or "nil") .. " (Script: " .. tostring(info.source) .. ") {")

                -- Log upvalues
                appendToLog("Upvalues:")
                for index, value in pairs(upvalues) do
                    appendToLog(index .. ": " .. tostring(value) .. " (" .. typeof(value) .. ")")
                end

                -- Log constants
                local consts = debug.getconstants(search)
                appendToLog("Constants:")
                for index, value in pairs(consts) do
                    appendToLog(index .. ": " .. tostring(value) .. " (" .. typeof(value) .. ")")
                end

                appendToLog("}")
                appendToLog("")

                loggedFunctions[functionKey] = true
            end
        end
    end

    print("RemoteEvent log written to: " .. logFileName)
    task.wait(300)
end

print(" -- Completed. --")
