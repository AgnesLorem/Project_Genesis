import os
import json

roots = {
    "src/server": "game:GetService('ServerScriptService').Server",
    "src/client": "game:GetService('StarterPlayer').StarterPlayerScripts.Client",
    "src/shared": "game:GetService('ReplicatedStorage').Shared",
    "configs": "game:GetService('ServerStorage').Configs"
}

luau_script = """
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
getOrCreateFolder(game:GetService("ServerStorage"), "Configs")

"""

base_dir = r"f:\Project_Genesis"

for root_path, roblox_root in roots.items():
    abs_root = os.path.join(base_dir, root_path.replace("/", "\\"))
    for dirpath, dirnames, filenames in os.walk(abs_root):
        for filename in filenames:
            if filename.endswith(".luau"):
                full_path = os.path.join(dirpath, filename)
                rel_path = os.path.relpath(dirpath, abs_root).replace("\\", "/")
                if rel_path == ".":
                    rel_path = ""
                
                with open(full_path, "r", encoding="utf-8") as f:
                    content = f.read()
                
                # Because we are embedding in a lua string, we can use a long string [[ ]] but some files might contain ]]
                # So we use a unique separator
                sep = "===="
                safe_content = content
                luau_script += f"""
local p = ensurePath({roblox_root}, "{rel_path}")
getOrCreateModule(p, "{filename[:-5]}", [{sep}[
{safe_content}
]{sep}])
"""

luau_script += "\nreturn 'Restore complete!'"

with open(os.path.join(base_dir, "scratch", "restore_generated.luau"), "w", encoding="utf-8") as f:
    f.write(luau_script)

print("Generated restore_generated.luau")
