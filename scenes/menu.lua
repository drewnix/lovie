-- scenes/menu.lua
-- Enhanced menu scene with categories, scrolling, and pagination for many scenes

-- Use the global SceneManager and SceneLoader to avoid circular dependencies
local SceneManager = _G.SceneManager
local SceneLoader = _G.SceneLoader
local Button = require('lib.components.button')
local Utils = require('lib.utils')

local Menu = {}

local title = "Lövie"
local subtitle = "Löve Showcase"

-- Menu UI configuration
local buttonHeight = 50
local buttonWidth = 300
local buttonSpacing = 10
local categorySpacing = 30
local columnSpacing = 50
local columnWidth = buttonWidth + columnSpacing
local maxColumns = 3 -- Maximum number of columns to use

-- Scroll configuration
local scrollY = 0
local scrollSpeed = 400
local scrollableArea = {
    x = 0,
    y = 200,
    width = 0, -- Set at runtime
    height = 0  -- Set at runtime
}
local contentHeight = 0
local scrollbarWidth = 10
local isScrolling = false
local scrollbarGrabbed = false
local scrollGrabOffset = 0

-- Load categories from config
local categories = {}
local categoryMap = {}
local sceneColors = {}

-- Visual elements
local buttons = {}
local categorizedButtons = {}
local logoRotation = 0
local backgroundPattern = {}
local fadeInAlpha = 0
local lastMouseX, lastMouseY = 0, 0
local mouseParticles = nil

-- Search functionality
local searchText = ""
local searchActive = false
local searchResults = {}
local searchFont = nil

function Menu.enter()
    print("Menu.enter() called")

    -- Load config
    local config = SceneLoader.loadConfig()
    categories = config.categories
    categoryMap = config.sceneCategories
    sceneColors = config.sceneColors

    -- Initialize menu and visuals
    initializeMenu()
    initializeVisuals()
    updateScrollableArea()

    -- Start with fade-in effect
    fadeInAlpha = 0
    scrollY = 0

    -- Scrollable area initialized

    -- Initialize font for search
    searchFont = love.graphics.newFont(16)
end

function initializeMenu()
    -- Clear old buttons
    buttons = {}
    categorizedButtons = {}

    -- Get all scene names
    local sceneNames = SceneManager.getAllSceneNames()
    table.sort(sceneNames)

    -- Initialize category structure
    for _, category in ipairs(categories) do
        categorizedButtons[category.name] = {
            name = category.name,
            color = category.color,
            buttons = {}
        }
    end

    -- Categorize each scene
    for _, sceneName in ipairs(sceneNames) do
        -- Skip the menu itself
        if sceneName ~= "menu" then
            local displayName = sceneName:gsub("_", " ")
            displayName = displayName:gsub("^%l", string.upper) -- Capitalize first letter

            -- Get category from the scene or from the category map
            local scene = SceneManager.scenes[sceneName]
            -- First check if scene has category, then check categoryMap, then default to Debug
            local categoryName = "Debug"
            if scene and scene.category then
                categoryName = scene.category
            elseif categoryMap[sceneName] then
                categoryName = categoryMap[sceneName]
            end
            -- Debug output to help diagnose why scene doesn't appear in the category
            if categoryName == "Basics" then
                print("Adding scene to Basics:", sceneName, "Category:", categoryName)
            end

            -- Create button for the scene
            local button = Button.new(
                0, 0, -- Position will be set later
                buttonWidth,
                buttonHeight,
                displayName,
                {
                    onClick = function()
                        print("Switching to scene: " .. sceneName)
                        SceneManager.switchTo(sceneName)
                    end,
                    color = generateColorForScene(sceneName)
                }
            )

            -- Add to overall buttons list and categorized list
            table.insert(buttons, button)
            table.insert(categorizedButtons[categoryName].buttons, {
                button = button,
                sceneName = sceneName,
                displayName = displayName
            })
        end
    end

    -- Position all buttons according to categories
    positionButtons()
end

function positionButtons()
    local windowWidth = love.graphics.getWidth()

    -- Calculate how many columns we can fit
    local availableWidth = windowWidth - 100  -- 50px margin on each side
    local numColumns = math.min(maxColumns, math.floor(availableWidth / columnWidth))
    numColumns = math.max(1, numColumns)  -- At least 1 column

    -- Calculate starting X position for the columns
    local startX = (windowWidth - (numColumns * columnWidth - columnSpacing)) / 2

    -- Start at the top of the scrollable area to fix visibility issues
    local y = scrollableArea.y

    -- For each category
    for _, category in ipairs(categories) do
        local categoryButtons = categorizedButtons[category.name]

        -- Skip empty categories
        if #categoryButtons.buttons > 0 then
            -- Debug output
            if category.name == "Basics" then
                print("Basics category has", #categoryButtons.buttons, "buttons")
                for i, btnInfo in ipairs(categoryButtons.buttons) do
                    print("  Button", i, ":", btnInfo.sceneName)
                end
            end

            -- Add space for category header (affects all columns)
            y = y + 60  -- More space for category headers

            -- Remember category header position for drawing
            categoryButtons.headerY = y - 40

            -- Track column heights for this category
            local columnHeights = {}
            for i = 1, numColumns do
                columnHeights[i] = 0
            end

            -- Position each button in the category
            for i, buttonInfo in ipairs(categoryButtons.buttons) do
                -- Determine which column to place this button in
                local columnIndex = ((i-1) % numColumns) + 1

                -- Calculate button position
                local x = startX + (columnIndex-1) * columnWidth
                local localY = y + columnHeights[columnIndex]

                -- Position the button
                buttonInfo.button:setPosition(x, localY)

                -- Update the height of this column
                columnHeights[columnIndex] = columnHeights[columnIndex] + buttonHeight + buttonSpacing
            end

            -- Find the tallest column in this category
            local maxColumnHeight = 0
            for i = 1, numColumns do
                maxColumnHeight = math.max(maxColumnHeight, columnHeights[i])
            end

            -- Update y based on the tallest column
            y = y + maxColumnHeight

            -- Add space after the category
            y = y + categorySpacing
        end
    end

    -- Set content height for scrolling
    contentHeight = y

    -- Debug complete
end

function updateScrollableArea()
    -- Update scrollable area dimensions based on window size
    scrollableArea.width = love.graphics.getWidth()
    scrollableArea.height = love.graphics.getHeight() - scrollableArea.y - 80 -- Leave space for footer
end

function initializeVisuals()
    -- Initialize background pattern
    backgroundPattern = {}
    for i = 1, 30 do
        table.insert(backgroundPattern, {
            x = math.random() * love.graphics.getWidth(),
            y = math.random() * love.graphics.getHeight(),
            size = math.random(5, 15),
            speed = math.random(10, 30),
            color = {
                math.random(0.2, 0.3),
                math.random(0.2, 0.3),
                math.random(0.3, 0.4),
                math.random(0.5, 0.8)
            }
        })
    end

    -- Initialize mouse particles
    mouseParticles = love.graphics.newParticleSystem(love.graphics.newImage(createCircleImage()), 100)
    mouseParticles:setParticleLifetime(0.5, 1.5)
    mouseParticles:setEmissionRate(10)
    mouseParticles:setSizeVariation(0.5)
    mouseParticles:setLinearAcceleration(-20, -20, 20, 20)
    mouseParticles:setColors(
        1, 1, 1, 0.8,     -- White
        0.5, 0.5, 1, 0.4, -- Light blue
        0, 0, 0, 0        -- Fade out
    )
    mouseParticles:setSizes(0.5, 0.3, 0.1)

    -- Store initial mouse position
    lastMouseX, lastMouseY = love.mouse.getPosition()
end

function Menu.update(dt)
    -- Update logo rotation
    logoRotation = logoRotation + dt * 0.2

    -- Update background pattern
    for _, item in ipairs(backgroundPattern) do
        item.y = item.y + item.speed * dt
        if item.y > love.graphics.getHeight() then
            item.y = -item.size
            item.x = math.random() * love.graphics.getWidth()
        end
    end

    -- Update fade-in effect
    if fadeInAlpha < 1 then
        fadeInAlpha = math.min(1, fadeInAlpha + dt * 2)
    end

    -- Update mouse particles
    local mouseX, mouseY = love.mouse.getPosition()
    if math.abs(mouseX - lastMouseX) > 3 or math.abs(mouseY - lastMouseY) > 3 then
        mouseParticles:setPosition(mouseX, mouseY)
        mouseParticles:emit(1)
    end
    lastMouseX, lastMouseY = mouseX, mouseY
    mouseParticles:update(dt)

    -- Update scrolling
    updateScrolling(dt)

    -- Update buttons visibility based on scroll position
    for _, button in ipairs(buttons) do
        local x, y = button:getPosition()
        local visible = (y + scrollY >= scrollableArea.y - buttonHeight) and
                        (y + scrollY <= scrollableArea.y + scrollableArea.height)
        button:setVisible(visible)

        -- Update button's rendered position based on scroll
        button:setRenderOffset(0, scrollY)
    end

    -- Update buttons
    for _, button in ipairs(buttons) do
        button:update(dt)
    end

    -- If we're searching, filter and position results
    if searchActive then
        updateSearchResults()
    end
end

function updateScrolling(dt)
    -- If scrollbar is being dragged
    if scrollbarGrabbed then
        local mouseY = love.mouse.getY()
        local scrollbarHeight = (scrollableArea.height / contentHeight) * scrollableArea.height
        local maxScroll = scrollableArea.height - scrollbarHeight
        local normalizedPosition = (mouseY - scrollGrabOffset - scrollableArea.y) / maxScroll

        -- Set scroll position based on scrollbar
        scrollY = -normalizedPosition * (contentHeight - scrollableArea.height)

        -- Clamp scroll position
        scrollY = math.max(-(contentHeight - scrollableArea.height), math.min(0, scrollY))
    end
end

function Menu.draw()
    -- Reset color and blend mode for safety
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode("alpha")

    -- Draw background pattern
    for _, item in ipairs(backgroundPattern) do
        love.graphics.setColor(item.color)
        love.graphics.circle("fill", item.x, item.y, item.size)
    end

    -- Draw header
    drawHeader()

    -- Set up the scissor for the scrollable area
    love.graphics.setScissor(
        scrollableArea.x,
        scrollableArea.y,
        scrollableArea.width,
        scrollableArea.height
    )

    if searchActive then
        -- Draw search results
        drawSearchResults()
    else
        -- Draw categories and buttons
        drawCategoriesAndButtons()
    end

    -- Reset scissor
    love.graphics.setScissor()

    -- Draw scrollbar if needed
    if contentHeight > scrollableArea.height then
        drawScrollbar()
    end

    -- Draw search bar
    drawSearchBar()

    -- Draw footer
    drawFooter()

    -- Draw mouse particles
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(mouseParticles)

    -- Reset font and color
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.setColor(1, 1, 1)
end

function drawHeader()
    -- Draw decorative header bar
    local headerGradient = {
        0.2, 0.3, 0.4, 1,
        0.3, 0.4, 0.5, 1
    }
    drawGradientBox(0, 0, love.graphics.getWidth(), 120, headerGradient, "vertical")

    -- Draw LÖVE logo
    drawLoveLogo(love.graphics.getWidth() - 80, 60, 50, logoRotation)

    -- Draw title with shadow
    love.graphics.setColor(0, 0, 0, 0.3)
    local titleFont = love.graphics.newFont(32)
    love.graphics.setFont(titleFont)
    love.graphics.printf(title, 3, 33, love.graphics.getWidth(), "center")

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(title, 0, 30, love.graphics.getWidth(), "center")

    -- Draw subtitle
    local subtitleFont = love.graphics.newFont(18)
    love.graphics.setFont(subtitleFont)
    love.graphics.setColor(0.9, 0.9, 1, 0.8)
    love.graphics.printf(subtitle, 0, 80, love.graphics.getWidth(), "center")

    -- Draw section header
    love.graphics.setColor(0.7, 0.8, 1, 0.8)
    love.graphics.setFont(love.graphics.newFont(20))
    love.graphics.printf("Available Demos", 0, 160, love.graphics.getWidth(), "center")
end

function drawCategoriesAndButtons()
    -- Draw each category with its buttons
    for _, category in ipairs(categories) do
        local categoryButtons = categorizedButtons[category.name]

        -- Skip empty categories
        if #categoryButtons.buttons > 0 and categoryButtons.headerY then
            local headerY = categoryButtons.headerY + scrollY

            -- Category is visible if within scrollable area

            -- Only draw if the category header is visible
            if headerY >= scrollableArea.y - 40 and headerY <= scrollableArea.y + scrollableArea.height then
                -- Draw category header
                love.graphics.setColor(category.color[1], category.color[2], category.color[3], 0.9)
                love.graphics.setFont(love.graphics.newFont(22))
                love.graphics.printf(
                    category.name,
                    scrollableArea.x,
                    headerY,
                    scrollableArea.width,
                    "center"
                )

                -- Draw a line under the category header
                love.graphics.setColor(category.color[1], category.color[2], category.color[3], 0.5)
                love.graphics.setLineWidth(2)
                love.graphics.line(
                    scrollableArea.x + scrollableArea.width * 0.3,
                    headerY + 30,
                    scrollableArea.x + scrollableArea.width * 0.7,
                    headerY + 30
                )
            end
        end
    end

    -- Draw buttons with fade-in effect
    love.graphics.setColor(1, 1, 1, fadeInAlpha)
    for _, button in ipairs(buttons) do
        if button:isVisible() then
            button:draw() -- Draw the button
        end
    end
end

function drawSearchResults()
    if #searchResults == 0 then
        -- No results
        love.graphics.setColor(1, 1, 1, 0.8)
        love.graphics.setFont(searchFont)
        love.graphics.printf(
            "No results found for '" .. searchText .. "'",
            0,
            scrollableArea.y + 40,
            love.graphics.getWidth(),
            "center"
        )
    else
        -- Draw search result title
        love.graphics.setColor(0.7, 0.8, 1, 0.9)
        love.graphics.setFont(searchFont)
        love.graphics.printf(
            "Search results for '" .. searchText .. "':",
            0,
            scrollableArea.y + 10,
            love.graphics.getWidth(),
            "center"
        )

        -- Draw each search result button
        love.graphics.setColor(1, 1, 1, fadeInAlpha)
        for _, resultInfo in ipairs(searchResults) do
            if resultInfo.button:isVisible() then
                resultInfo.button:draw()
            end
        end
    end
end

function drawScrollbar()
    -- Calculate scrollbar dimensions
    local scrollbarHeight = (scrollableArea.height / contentHeight) * scrollableArea.height
    local scrollbarY = scrollableArea.y + (-scrollY / contentHeight) * scrollableArea.height

    -- Draw scrollbar track
    love.graphics.setColor(0.2, 0.2, 0.3, 0.5)
    love.graphics.rectangle(
        "fill",
        scrollableArea.x + scrollableArea.width - scrollbarWidth,
        scrollableArea.y,
        scrollbarWidth,
        scrollableArea.height
    )

    -- Draw scrollbar thumb
    love.graphics.setColor(0.4, 0.5, 0.7, 0.8)
    love.graphics.rectangle(
        "fill",
        scrollableArea.x + scrollableArea.width - scrollbarWidth,
        scrollbarY,
        scrollbarWidth,
        scrollbarHeight
    )
end

function drawSearchBar()
    -- Draw search bar background
    love.graphics.setColor(0.2, 0.2, 0.3, 0.7)
    love.graphics.rectangle(
        "fill",
        (love.graphics.getWidth() - 300) / 2,
        130,
        300,
        30
    )

    -- Draw search text
    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.setFont(searchFont)

    local displayText = searchText
    if #displayText == 0 then
        love.graphics.setColor(0.7, 0.7, 0.8, 0.7)
        displayText = "Search scenes..."
    end

    love.graphics.printf(
        displayText,
        (love.graphics.getWidth() - 280) / 2,
        134,
        280,
        "left"
    )

    -- Draw cursor if search is active
    if searchActive and (love.timer.getTime() % 1 < 0.5) then
        local textWidth = searchFont:getWidth(searchText)
        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.rectangle(
            "fill",
            (love.graphics.getWidth() - 280) / 2 + textWidth + 5,
            134,
            2,
            22
        )
    end
end

function drawFooter()
    -- Calculate footer position
    local footerY = love.graphics.getHeight() - 80

    -- Draw footer bar
    local footerGradient = {
        0.2, 0.3, 0.4, 1,
        0.3, 0.4, 0.5, 1
    }
    drawGradientBox(0, footerY, love.graphics.getWidth(), 80, footerGradient, "vertical")

    -- Draw footer text
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.printf(
        "Press 'M' at any time to return to this menu",
        0,
        footerY + 20,
        love.graphics.getWidth(),
        "center"
    )

    -- Draw keyboard shortcuts
    love.graphics.setColor(0.9, 0.9, 1, 0.7)
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.printf(
        "Scroll: Mouse wheel or Page Up/Down | Search: Start typing",
        0,
        footerY + 40,
        love.graphics.getWidth(),
        "center"
    )

    -- Draw version info
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.printf(
        "LÖVE " .. love._version,
        0,
        footerY + 60,
        love.graphics.getWidth() - 20,
        "right"
    )
end

function Menu.mousepressed(x, y, button)
    -- Check if we're clicking on the scrollbar
    if isPointInScrollbar(x, y) then
        scrollbarGrabbed = true

        -- Calculate grab offset
        local scrollbarHeight = (scrollableArea.height / contentHeight) * scrollableArea.height
        local scrollbarY = scrollableArea.y + (-scrollY / contentHeight) * scrollableArea.height
        scrollGrabOffset = y - scrollbarY

        return
    end

    -- Check if we're clicking in the search bar
    if x >= (love.graphics.getWidth() - 300) / 2 and
       x <= (love.graphics.getWidth() + 300) / 2 and
       y >= 130 and y <= 160 then
        searchActive = true
        return
    else
        -- If we click outside the search bar and it's active, deactivate it
        if searchActive then
            searchActive = false
            -- If we had search results, reset them
            if #searchText > 0 then
                searchText = ""
                searchResults = {}
                initializeMenu()
            end
        end
    end

    -- Check if we're clicking on a button
    for _, btn in ipairs(buttons) do
        if btn:isVisible() and btn:mousepressed(x, y, button) then
            return
        end
    end
end

function Menu.mousereleased(x, y, button)
    -- Release scrollbar grab
    if scrollbarGrabbed then
        scrollbarGrabbed = false
        return
    end

    -- Check button releases
    for _, btn in ipairs(buttons) do
        if btn:isVisible() and btn:mousereleased(x, y, button) then
            return
        end
    end
end

function Menu.wheelmoved(x, y)
    -- Vertical scrolling with mouse wheel
    if not searchActive or #searchResults > 0 then
        scrollY = scrollY + y * 30

        -- Clamp scroll position
        local minScroll = math.min(0, -(contentHeight - scrollableArea.height))
        scrollY = math.max(minScroll, math.min(0, scrollY))
    end
end

function Menu.keypressed(key)
    -- Handle search input
    if searchActive then
        if key == "escape" then
            searchActive = false
            searchText = ""
            searchResults = {}
            initializeMenu()
        elseif key == "backspace" then
            searchText = searchText:sub(1, -2)
            updateSearchResults()
        elseif key == "return" then
            searchActive = false
            -- If we have exactly one result, navigate to it
            if #searchResults == 1 then
                local sceneName = searchResults[1].sceneName
                print("Navigating to search result: " .. sceneName)
                SceneManager.switchTo(sceneName)
            end
        end
    else
        -- Special keys for navigation when not searching
        if key == "pageup" then
            -- Scroll up a page
            scrollY = scrollY + scrollableArea.height * 0.8
            scrollY = math.min(0, scrollY)
        elseif key == "pagedown" then
            -- Scroll down a page
            scrollY = scrollY - scrollableArea.height * 0.8
            local minScroll = math.min(0, -(contentHeight - scrollableArea.height))
            scrollY = math.max(minScroll, scrollY)
        elseif key == "home" then
            -- Scroll to top
            scrollY = 0
        elseif key == "end" then
            -- Scroll to bottom
            scrollY = -(contentHeight - scrollableArea.height)
            scrollY = math.max(scrollY, -(contentHeight - scrollableArea.height))
        elseif key:len() == 1 and key:match("[%w]") then
            -- Start search on alphanumeric key press
            searchActive = true
            searchText = key
            updateSearchResults()
        end
    end
end

function Menu.textinput(text)
    if searchActive then
        searchText = searchText .. text
        updateSearchResults()
    end
end

function Menu.resize(w, h)
    -- Update scrollable area
    updateScrollableArea()

    -- Update button positions
    positionButtons()

    -- Update search results positioning if active
    if searchActive and #searchResults > 0 then
        positionSearchResults()
    end
end

function Menu.mousemoved(x, y, dx, dy)
    lastMouseX, lastMouseY = x, y
end

-- Utility Functions

function updateSearchResults()
    -- Clear previous results
    searchResults = {}

    -- Skip if search text is empty
    if #searchText == 0 then
        initializeMenu()
        return
    end

    -- Search through all buttons
    local searchPattern = searchText:lower()

    for _, category in pairs(categorizedButtons) do
        for _, buttonInfo in ipairs(category.buttons) do
            local sceneName = buttonInfo.sceneName
            local displayName = buttonInfo.displayName:lower()

            -- Check if the display name or scene name contains the search text
            if displayName:find(searchPattern) or sceneName:find(searchPattern) then
                table.insert(searchResults, {
                    button = buttonInfo.button,
                    sceneName = sceneName,
                    displayName = buttonInfo.displayName
                })
            end
        end
    end

    -- Position the search results
    positionSearchResults()
end

function positionSearchResults()
    -- Calculate columns for search results
    local windowWidth = love.graphics.getWidth()

    -- Calculate how many columns we can fit
    local availableWidth = windowWidth - 100  -- 50px margin on each side
    local numColumns = math.min(maxColumns, math.floor(availableWidth / columnWidth))
    numColumns = math.max(1, numColumns)  -- At least 1 column

    -- Calculate starting X position for the columns
    local startX = (windowWidth - (numColumns * columnWidth - columnSpacing)) / 2

    -- Start position for search results
    local y = scrollableArea.y + 60  -- Start below the search results title

    -- Track column heights
    local columnHeights = {}
    for i = 1, numColumns do
        columnHeights[i] = 0
    end

    -- Position each search result in columns
    for i, resultInfo in ipairs(searchResults) do
        -- Determine which column to place this button in
        local columnIndex = ((i-1) % numColumns) + 1

        -- Calculate button position
        local x = startX + (columnIndex-1) * columnWidth
        local localY = y + columnHeights[columnIndex] - scrollY

        -- Position the button
        resultInfo.button:setPosition(x, localY)

        -- Update the height of this column
        columnHeights[columnIndex] = columnHeights[columnIndex] + buttonHeight + buttonSpacing
    end

    -- Find the tallest column
    local maxColumnHeight = 0
    for i = 1, numColumns do
        maxColumnHeight = math.max(maxColumnHeight, columnHeights[i])
    end

    -- Set content height for scrolling
    contentHeight = math.max(scrollableArea.height, y + maxColumnHeight - scrollableArea.y)
end

function isPointInScrollbar(x, y)
    -- Only check if we need a scrollbar
    if contentHeight <= scrollableArea.height then
        return false
    end

    -- Check if point is inside scrollbar area
    return x >= scrollableArea.x + scrollableArea.width - scrollbarWidth and
           x <= scrollableArea.x + scrollableArea.width and
           y >= scrollableArea.y and
           y <= scrollableArea.y + scrollableArea.height
end

-- Helper function to generate a unique color for each scene
function generateColorForScene(sceneName)
    -- First check if scene has a specific color
    if sceneColors[sceneName] then
        return sceneColors[sceneName]
    end

    -- Fall back to category color
    local categoryName = categoryMap[sceneName] or "Debug"
    for _, category in ipairs(categories) do
        if category.name == categoryName then
            return category.color
        end
    end

    -- Default color if nothing found
    return {0.4, 0.5, 0.6}
end

-- Helper function to draw a gradient box
function drawGradientBox(x, y, width, height, colors, direction)
    direction = direction or "horizontal"

    -- Check if we have enough color components
    if #colors < 8 then
        -- Add default values if not enough colors provided
        for i = #colors + 1, 8 do
            colors[i] = colors[i - 4] or 1
        end
    end

    if direction == "horizontal" then
        -- Horizontal gradient
        for i = 0, width - 1 do
            local ratio = i / width
            local r = lerp(colors[1], colors[5], ratio)
            local g = lerp(colors[2], colors[6], ratio)
            local b = lerp(colors[3], colors[7], ratio)
            local a = lerp(colors[4], colors[8], ratio)

            love.graphics.setColor(r, g, b, a)
            love.graphics.rectangle("fill", x + i, y, 1, height)
        end
    else
        -- Vertical gradient
        for i = 0, height - 1 do
            local ratio = i / height
            local r = lerp(colors[1], colors[5], ratio)
            local g = lerp(colors[2], colors[6], ratio)
            local b = lerp(colors[3], colors[7], ratio)
            local a = lerp(colors[4], colors[8], ratio)

            love.graphics.setColor(r, g, b, a)
            love.graphics.rectangle("fill", x, y + i, width, 1)
        end
    end
end

-- Linear interpolation helper
function lerp(a, b, t)
    return a + (b - a) * t
end

-- Draw a stylized LÖVE logo
function drawLoveLogo(x, y, size, rotation)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(rotation)

    -- Draw heart shape
    love.graphics.setColor(1, 0.3, 0.3, 0.9)
    love.graphics.circle("fill", -size / 4, -size / 4, size / 4)
    love.graphics.circle("fill", size / 4, -size / 4, size / 4)
    love.graphics.polygon("fill",
        -size / 2, -size / 4,
        size / 2, -size / 4,
        0, size / 2
    )

    love.graphics.pop()
end

-- Create a circle image for particles
function createCircleImage()
    local size = 32
    local imageData = love.image.newImageData(size, size)

    for y = 0, size - 1 do
        for x = 0, size - 1 do
            local dx = x - size / 2
            local dy = y - size / 2
            local distance = math.sqrt(dx * dx + dy * dy)

            if distance < size / 2 then
                -- White circle with soft edges
                local alpha = 1 - (distance / (size / 2))
                imageData:setPixel(x, y, 1, 1, 1, alpha)
            else
                -- Transparent outside
                imageData:setPixel(x, y, 0, 0, 0, 0)
            end
        end
    end

    return imageData
end

return Menu