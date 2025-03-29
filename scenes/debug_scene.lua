-- scenes/debug_scene.lua
-- Debug scene for testing SceneManager integration

local Debug = {
    title = "Debug Scene",
    description = "Used to debug scene loading issues"
}

function Debug.enter()
    print("Debug.enter() called")
    local SceneManager = require('lib.sceneManager')

    -- Check if SceneManager is properly loaded
    print("SceneManager loaded:", SceneManager ~= nil)

    -- Check if scenes are registered
    local sceneCount = 0
    for name, _ in pairs(SceneManager.scenes) do
        sceneCount = sceneCount + 1
        print("Found scene:", name)
    end
    print("Total scenes:", sceneCount)

    -- Check global access
    print("Global SceneManager:", _G.SceneManager ~= nil)
    if _G.SceneManager then
        local globalSceneCount = 0
        for name, _ in pairs(_G.SceneManager.scenes) do
            globalSceneCount = globalSceneCount + 1
            print("Found global scene:", name)
        end
        print("Total global scenes:", globalSceneCount)
    end
end

function Debug.draw()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.2)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Debug Scene - Check console output", 50, 50)
end

function Debug.keypressed(key)
    if key == "space" then
        print("Attempting to show all scenes again:")
        local SceneManager = require('lib.sceneManager')
        local sceneNames = SceneManager.getAllSceneNames()
        for i, name in ipairs(sceneNames) do
            print("Scene", i, ":", name)
        end
    end
end

return Debug
