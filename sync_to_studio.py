import os
import json
import base64

files = {
    "StatCalculator": ("ReplicatedStorage.Genesis.Shared.utilities.StatCalculator", "src/shared/utilities/StatCalculator.luau"),
    "WorldScreen": ("StarterPlayer.StarterPlayerScripts.Genesis.Client.views.WorldScreen", "src/client/views/WorldScreen.luau"),
    "TowerChallengeController": ("StarterPlayer.StarterPlayerScripts.Genesis.Client.controllers.TowerChallengeController", "src/client/controllers/TowerChallengeController.luau"),
    "CombatScreen": ("StarterPlayer.StarterPlayerScripts.Genesis.Client.views.CombatScreen", "src/client/views/CombatScreen.luau"),
    "BattleResultModal": ("StarterPlayer.StarterPlayerScripts.Genesis.Client.views.BattleResultModal", "src/client/views/BattleResultModal.luau"),
    "CombatService": ("ServerScriptService.Genesis.Server.services.CombatService", "src/server/services/CombatService.luau"),
    "TowerChallengeService": ("ServerScriptService.Genesis.Server.services.TowerChallengeService", "src/server/services/TowerChallengeService.luau"),
    "SkillService": ("ServerScriptService.Genesis.Server.services.SkillService", "src/server/services/SkillService.luau"),
    "GameplaySimulator": ("StarterPlayer.StarterPlayerScripts.Genesis.Client.controllers.GameplaySimulator", "src/client/controllers/GameplaySimulator.luau"),
    "UISmokeTester": ("StarterPlayer.StarterPlayerScripts.Genesis.Client.controllers.UISmokeTester", "src/client/controllers/UISmokeTester.luau")
}

luau_code = """
local HttpService = game:GetService("HttpService")
local function resolvePath(pathStr)
    local parts = string.split(pathStr, ".")
    local curr = game
    for _, p in ipairs(parts) do
        curr = curr:FindFirstChild(p)
        if not curr then return nil end
    end
    return curr
end

local base64Decode = function(data)
    -- Roblox doesn't have a built-in base64 decode that is universally available in Edit mode unless we use some tricks.
    -- Wait, HttpService has JSONDecode but we can just pass strings via long brackets.
    return data
end
"""

# Let's just generate a script that sets the source using long strings.
# But long strings might contain ]] so we use [=[ ]=] or [==[ ]==].
def get_bracket(content):
    level = 0
    while True:
        bracket = f"[{'='*level}["
        close_bracket = f"]{'='*level}]"
        if close_bracket not in content:
            return bracket, close_bracket
        level += 1

out_luau = luau_code
for name, (path, local_path) in files.items():
    with open(local_path, "r", encoding="utf-8") as f:
        content = f.read()
    op, cl = get_bracket(content)
    out_luau += f"""
local obj = resolvePath("{path}")
if obj then
    obj.Source = {op}
{content}
{cl}
    print("Updated {name}")
else
    print("Failed to find {name}")
end
"""

with open("sync_temp.luau", "w", encoding="utf-8") as f:
    f.write(out_luau)

print("Generated sync_temp.luau")
