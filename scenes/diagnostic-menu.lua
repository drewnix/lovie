-- diagnostic-menu.lua
-- Ultra-simple menu with error handling

local DiagnosticMenu = {}

function DiagnosticMenu.enter()
    print("DiagnosticMenu.enter() called")

    -- Get SceneManager from _G (global table) to avoid circular dependency
    local scenes = _G.SceneManager.getAllSceneNames()
    print("Available scenes: " .. table.concat(scenes, ", "))
end

function DiagnosticMenu.update(dt)
    -- Nothing to update
end

function DiagnosticMenu.draw()
    -- Use pcall to catch any errors
    local success, errorMsg = pcall(function()
        -- Clear screen with solid color
        love.graphics.setColor(0.1, 0.1, 0.2)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

        -- Draw title
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(32))
        love.graphics.print("Diagnostic Menu", 50, 50)

        -- Draw subtitle
        love.graphics.setFont(love.graphics.newFont(18))
        love.graphics.print("Choose a demo scene", 50, 100)

        -- Draw simple clickable areas
        love.graphics.setFont(love.graphics.newFont(16))
        local scenes = { "basic_drawing", "animations", "physics", "particles", "audio", "documentation",
            "camera_systems", "resolution_management", "shaders" }

        local y = 150

        for i, sceneName in ipairs(scenes) do
            -- Draw button background (alternate colors)
            if i % 2 == 0 then
                love.graphics.setColor(0.3, 0.3, 0.6)
            else
                love.graphics.setColor(0.4, 0.4, 0.7)
            end
            love.graphics.rectangle("fill", 50, y, 300, 40)

            -- Draw button text
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(sceneName:gsub("_", " "):gsub("^%l", string.upper), 70, y + 10)

            -- Store position for click detection
            scenes[i] = {
                name = sceneName,
                x = 50,
                y = y,
                width = 300,
                height = 40
            }

            y = y + 50
        end

        -- Draw instruction
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.print("Click on a scene to view it, press 'M' to return to menu", 50, y + 20)

        -- Store the scene data for click handling
        DiagnosticMenu.scenes = scenes
    end)

    -- If there was an error, show error information
    if not success then
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

        love.graphics.setColor(1, 0, 0)
        love.graphics.setFont(love.graphics.newFont(20))
        love.graphics.print("Error in menu drawing:", 50, 50)
        love.graphics.print(tostring(errorMsg), 50, 80)

        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(16))
        love.graphics.print("Press ESC to quit", 50, 150)
    end
end

function DiagnosticMenu.mousepressed(x, y, button)
    -- Only process if we have scenes stored
    if not DiagnosticMenu.scenes then return end

    -- Check if click was on a scene button
    if button == 1 then
        for _, scene in ipairs(DiagnosticMenu.scenes) do
            if x >= scene.x and x <= scene.x + scene.width and
                y >= scene.y and y <= scene.y + scene.height then
                print("Clicked on scene: " .. scene.name)

                -- Try to switch scenes
                local success, errorMsg = pcall(function()
                    _G.SceneManager.switchTo(scene.name)
                end)

                if not success then
                    print("Error switching to scene: " .. tostring(errorMsg))
                end

                return true
            end
        end
    end

    return false
end

function DiagnosticMenu.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

return DiagnosticMenu
