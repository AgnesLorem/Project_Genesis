$ErrorActionPreference = "Stop"

$baseDir = "f:\Project_Genesis\src"
$outPath = "f:\Project_Genesis\scratch\restore_generated.luau"

$scriptContent = @"
local function getOrCreateFolder(parent, name)
    local folder = parent:FindFirstChild(name)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = name
        folder.Parent = parent
    end
    return folder
end

local function getOrCreateModule(parent, name, source)
    local module = parent:FindFirstChild(name)
    if not module then
        module = Instance.new("ModuleScript")
        module.Name = name
        module.Parent = parent
    end
    module.Source = source
    return module
end

local function ensurePath(root, path)
    if path == "" then return root end
    local current = root
    for part in string.gmatch(path, "[^/]+") do
        current = getOrCreateFolder(current, part)
    end
    return current
end

-- Create root folders
getOrCreateFolder(game:GetService("ServerScriptService"), "Server")
getOrCreateFolder(game:GetService("StarterPlayer").StarterPlayerScripts, "Client")
getOrCreateFolder(game:GetService("ReplicatedStorage"), "Shared")

"@

$headerScript = $scriptContent
$currentScript = $headerScript
$fileIndex = 0
$moduleCount = 0

$roots = @{
    "server" = 'game:GetService("ServerScriptService").Server'
    "client" = 'game:GetService("StarterPlayer").StarterPlayerScripts.Client'
    "shared" = 'game:GetService("ReplicatedStorage").Shared'
}

foreach ($key in $roots.Keys) {
    $folderPath = Join-Path $baseDir $key
    $robloxRoot = $roots[$key]
    
    $files = Get-ChildItem -Path $folderPath -Filter "*.luau" -Recurse
    if ($null -ne $files) {
        foreach ($file in $files) {
            $fileContent = [IO.File]::ReadAllText($file.FullName)
            $relPath = $file.DirectoryName.ToLower().Replace($folderPath.ToLower(), "").Replace("\", "/")
            if ($relPath.StartsWith("/")) {
                $relPath = $relPath.Substring(1)
            }
            
            $fileName = $file.BaseName
            $sep = "===="
            
            $chunk = "local p = ensurePath($robloxRoot, `"$relPath`")`n"
            $chunk += "getOrCreateModule(p, `"$fileName`", [$sep[`n$fileContent`n]$sep])`n`n"
            
            $moduleCount++
            $currentScript += $chunk
            
            if ($moduleCount -ge 3) {
                $currentScript += "return 'Restore chunk $fileIndex complete!'"
                [IO.File]::WriteAllText("f:\Project_Genesis\scratch\restore_generated_$fileIndex.luau", $currentScript)
                Write-Host "Generated restore_generated_$fileIndex.luau"
                
                $fileIndex++
                $moduleCount = 0
                $currentScript = $headerScript
            }
        }
    }
}

if ($moduleCount -gt 0) {
    $currentScript += "return 'Restore chunk $fileIndex complete!'"
    [IO.File]::WriteAllText("f:\Project_Genesis\scratch\restore_generated_$fileIndex.luau", $currentScript)
    Write-Host "Generated restore_generated_$fileIndex.luau"
}
