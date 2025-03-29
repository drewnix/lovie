-- conf.lua
-- Configuration for the LÖVE application

function love.conf(t)
    t.title = "Lövie - LÖVE Framework Showcase"
    t.version = "11.4"  -- The LÖVE version this game was made for
    t.console = true    -- Attach a console for debugging

    -- Window settings
    t.window.width = 1200
    t.window.height = 800
    t.window.resizable = true
    t.window.vsync = 1

    -- Disable modules we don't need
    t.modules.joystick = false
    t.modules.touch = false
    t.modules.video = false

    -- Enable modules we do need
    t.modules.audio = true
    t.modules.data = true
    t.modules.event = true
    t.modules.font = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.physics = true
    t.modules.sound = true
    t.modules.system = true
    t.modules.thread = true
    t.modules.timer = true
    t.modules.window = true
end