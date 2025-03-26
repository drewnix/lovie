-- lib/sceneManager.lua
-- Enhanced version with debugging output

local SceneManager = {
    scenes = {},
    current = nil,
    history = {},
    debug = true  -- Set to true to enable debug output
}

-- Debug print function
local function debugPrint(...)
    if SceneManager.debug then
        print("[SceneManager]", ...)
    end
end

-- Initialize the scene manager with a collection of scenes
function SceneManager.init(scenes)
    debugPrint("Initializing with scenes:", table.concat(getTableKeys(scenes or {}), ", "))
    SceneManager.scenes = scenes or {}
    SceneManager.current = nil
    SceneManager.history = {}
end

-- Switch to a specific scene by name
function SceneManager.switchTo(sceneName)
    debugPrint("Switch request to scene:", sceneName)

    if not SceneManager.scenes[sceneName] then
        debugPrint("ERROR: Scene '" .. sceneName .. "' does not exist!")
        debugPrint("Available scenes:", table.concat(getTableKeys(SceneManager.scenes), ", "))
        return
    end

    -- Log history for back navigation
    if SceneManager.current then
        table.insert(SceneManager.history, SceneManager.current)
    end

    debugPrint("Calling exit on current scene:", SceneManager.current)
    -- Call exit on current scene if it exists
    if SceneManager.current and 
       SceneManager.scenes[SceneManager.current] and 
       SceneManager.scenes[SceneManager.current].exit then

        SceneManager.scenes[SceneManager.current].exit()
    end

    -- Update current scene
    local oldScene = SceneManager.current
    SceneManager.current = sceneName
    debugPrint("Scene changed from", oldScene, "to", sceneName)

    -- Call enter on new scene if it exists
    debugPrint("Calling enter on new scene:", sceneName)
    if SceneManager.scenes[sceneName].enter then
        local success, err = pcall(function()
            SceneManager.scenes[sceneName].enter()
        end)
        if not success then
            debugPrint("ERROR in scene enter():", err)
        end
    end
end

-- Go back to the previous scene
function SceneManager.goBack()
    local previousScene = table.remove(SceneManager.history)
    debugPrint("Going back to previous scene:", previousScene)
    if previousScene then
        SceneManager.switchTo(previousScene)
    else
        debugPrint("No previous scene available")
    end
end

-- Pass through all LÖVE events to the current scene
function SceneManager.update(dt)
    if SceneManager.current and 
       SceneManager.scenes[SceneManager.current] and 
       SceneManager.scenes[SceneManager.current].update then
        local success, err = pcall(function()
            SceneManager.scenes[SceneManager.current].update(dt)
        end)
        if not success then
            debugPrint("ERROR in scene update():", err)
        end
    end
end

function SceneManager.draw()
    if SceneManager.current and 
       SceneManager.scenes[SceneManager.current] and 
       SceneManager.scenes[SceneManager.current].draw then
        local success, err = pcall(function()
            SceneManager.scenes[SceneManager.current].draw()
        end)
        if not success then
            debugPrint("ERROR in scene draw():", err)
        end
    end
end

function SceneManager.keypressed(key)
    debugPrint("Forwarding keypressed", key, "to scene:", SceneManager.current)
    if SceneManager.current and 
       SceneManager.scenes[SceneManager.current] and 
       SceneManager.scenes[SceneManager.current].keypressed then
        SceneManager.scenes[SceneManager.current].keypressed(key)
    end
end

function SceneManager.keyreleased(key)
    if SceneManager.current and 
       SceneManager.scenes[SceneManager.current] and 
       SceneManager.scenes[SceneManager.current].keyreleased then
        SceneManager.scenes[SceneManager.current].keyreleased(key)
    end
end

function SceneManager.mousepressed(x, y, button)
    if SceneManager.current and 
       SceneManager.scenes[SceneManager.current] and 
       SceneManager.scenes[SceneManager.current].mousepressed then
        SceneManager.scenes[SceneManager.current].mousepressed(x, y, button)
    end
end

function SceneManager.mousereleased(x, y, button)
    if SceneManager.current and 
       SceneManager.scenes[SceneManager.current] and 
       SceneManager.scenes[SceneManager.current].mousereleased then
        SceneManager.scenes[SceneManager.current].mousereleased(x, y, button)
    end
end

-- Get the name of the current scene
function SceneManager.getCurrentSceneName()
    return SceneManager.current
end

-- Get all scene names
function SceneManager.getAllSceneNames()
    return getTableKeys(SceneManager.scenes)
end

-- Helper function to get table keys
function getTableKeys(tbl)
    local keys = {}
    for name, _ in pairs(tbl) do
        table.insert(keys, name)
    end
    return keys
end

-- Enable/disable debug output
function SceneManager.setDebug(enabled)
    SceneManager.debug = enabled
end

debugPrint("Module loaded successfully!")
return SceneManager