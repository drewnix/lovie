-- config/scenes.lua
-- Scene configuration file - automatically updated by make new-scene

-- Scene categories
local categories = {
    { name = "Basics", color = {0.4, 0.6, 0.8} },
    { name = "Graphics", color = {0.8, 0.4, 0.6} },
    { name = "Audio & Input", color = {0.4, 0.7, 0.4} },
    { name = "Systems", color = {0.7, 0.5, 0.8} },
    { name = "Debug", color = {0.5, 0.5, 0.7} }
}

-- Scene category mapping
local sceneCategories = {
    -- Basics
    basic_drawing = "Basics",
    documentation = "Basics",

    -- Graphics
    animations = "Graphics",
    particles = "Graphics",
    shaders = "Graphics",

    -- Audio & Input
    audio = "Audio & Input",

    -- Systems
    physics = "Systems",
    camera_systems = "Systems",
    resolution_management = "Systems",

    -- Debug
    debug_scene = "Debug"
}

-- Scene colors (optional, will use category color if not specified)
local sceneColors = {
    basic_drawing = { 0.4, 0.6, 0.8 }, -- Blue
    animations = { 0.8, 0.4, 0.6 },  -- Pink
    physics = { 0.4, 0.7, 0.4 },     -- Green
    particles = { 0.7, 0.5, 0.8 },   -- Purple
    audio = { 0.8, 0.7, 0.3 },       -- Gold
    documentation = { 0.5, 0.5, 0.7 }, -- Slate blue
    camera_systems = { 0.6, 0.4, 0.2 }, -- Brown
    resolution_management = { 0.2, 0.6, 0.6 }, -- Teal
    shaders = { 0.7, 0.3, 0.7 }, -- Purple
    debug_scene = { 0.5, 0.5, 0.5 } -- Gray
}

return {
    categories = categories,
    sceneCategories = sceneCategories,
    sceneColors = sceneColors
}
