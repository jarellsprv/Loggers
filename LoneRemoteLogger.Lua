print(" -- Starting Logging Process -- ")
task.wait(3)
local logFileName = "LoneRemoteLog"
writefile(logFileName,"")

function logInfo(info) 
    appendfile(logFileName, info .. "\n")
    appendfile(logFileName, "\n")
end

local LoggedRemotes = {}

for i, v in pairs(getgc(true)) do
    if typeof(v) == "Instance" and v:IsA("RemoteEvent") then
        local RemoteName = v.Name or "No name."
        if LoggedRemotes[RemoteName] then
            continue
        end
        logInfo(RemoteName)
        LoggedRemotes[RemoteName] = true
    end
end
print("RemoteEvent log written to: " .. logFileName)
print(" -- Completed. -- ")
