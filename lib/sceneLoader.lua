-- lib/sceneLoader.lua
-- Dynamic scene loading system that loads scenes from the scenes directory

local SceneLoader = {}

-- Load scene configuration
function SceneLoader.loadConfig()
    local success, config = pcall(function()
        return require('config.scenes')
    end)

    if not success or type(config) ~= "table" then
        print("Warning: Could not load scene configuration. Using default values.")
        -- Return default configuration
        return {
            categories = {
                { name = "Basics", color = {0.4, 0.6, 0.8} },
                { name = "Graphics", color = {0.8, 0.4, 0.6} },
                { name = "Audio & Input", color = {0.4, 0.7, 0.4} },
                { name = "Systems", color = {0.7, 0.5, 0.8} },
                { name = "Debug", color = {0.5, 0.5, 0.7} }
            },
            sceneCategories = {},
            sceneColors = {}
        }
    end

    return config
end

-- Get all scenes from the scenes directory
function SceneLoader.getAllScenes()
    local scenes = {}
    local config = SceneLoader.loadConfig()

    -- Use love.filesystem to get all Lua files in the scenes directory
    local files = love.filesystem.getDirectoryItems("scenes")

    for _, file in ipairs(files) do
        -- Only load Lua files
        if file:match("%.lua$") then
            local sceneName = file:gsub("%.lua$", "")

            -- Skip backup files and special files
            if not sceneName:match("%.backup$") and sceneName ~= "init" then
                print("Loading scene: " .. sceneName)
                local success, scene = pcall(function()
                    return require('scenes.' .. sceneName)
                end)

                if success and scene then
                    scenes[sceneName] = scene

                    -- Add metadata to the scene if it doesn't already have it
                    if not scene.category then
                        scene.category = config.sceneCategories[sceneName] or "Debug"
                    end

                    if not scene.color then
                        scene.color = config.sceneColors[sceneName] or {0.4, 0.5, 0.6}
                    end
                else
                    print("Error loading scene: " .. sceneName)
                    print(scene) -- Error message
                end
            end
        end
    end

    return scenes
end

-- Get all categories
function SceneLoader.getCategories()
    local config = SceneLoader.loadConfig()
    return config.categories
end

-- Get scene category
function SceneLoader.getSceneCategory(sceneName)
    local config = SceneLoader.loadConfig()
    return config.sceneCategories[sceneName] or "Debug"
end

-- Get scene color
function SceneLoader.getSceneColor(sceneName)
    local config = SceneLoader.loadConfig()
    return config.sceneColors[sceneName] or {0.4, 0.5, 0.6}
end

-- Add a new scene to the configuration
function SceneLoader.addSceneToConfig(sceneName, category)
    -- This function would be called by the make new-scene command
    -- It modifies the config file to add a new scene
    -- This is not used at runtime but is included here for reference
end

return SceneLoader