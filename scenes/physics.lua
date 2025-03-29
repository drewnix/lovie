-- scenes/physics.lua
-- Demonstrates physics capabilities in LÖVE

local Physics = {
    title = "Physics Demo",
    description = "Demonstrates Box2D physics integration in LÖVE",
    category = "Systems"
}

-- Physics world and objects
local world
local objects = {}
local walls = {}
local selectedObject = 1
local objectTypes = {"circle", "rectangle", "polygon"}

function Physics.enter()
    -- Create a new physics world with gravity
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 9.81 * 64, true)

    -- Create objects
    objects = {}
    walls = {}

    -- Create walls to contain the objects
    local wallThickness = 20
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    -- Ground
    local ground = {}
    ground.body = love.physics.newBody(world, screenWidth / 2, screenHeight - wallThickness / 2, "static")
    ground.shape = love.physics.newRectangleShape(screenWidth, wallThickness)
    ground.fixture = love.physics.newFixture(ground.body, ground.shape)
    ground.fixture:setFriction(0.8)
    table.insert(walls, ground)

    -- Left wall
    local leftWall = {}
    leftWall.body = love.physics.newBody(world, wallThickness / 2, screenHeight / 2, "static")
    leftWall.shape = love.physics.newRectangleShape(wallThickness, screenHeight)
    leftWall.fixture = love.physics.newFixture(leftWall.body, leftWall.shape)
    table.insert(walls, leftWall)

    -- Right wall
    local rightWall = {}
    rightWall.body = love.physics.newBody(world, screenWidth - wallThickness / 2, screenHeight / 2, "static")
    rightWall.shape = love.physics.newRectangleShape(wallThickness, screenHeight)
    rightWall.fixture = love.physics.newFixture(rightWall.body, rightWall.shape)
    table.insert(walls, rightWall)

    -- Add a platform in the middle
    local platform = {}
    platform.body = love.physics.newBody(world, screenWidth / 2, screenHeight / 2 + 50, "static")
    platform.shape = love.physics.newRectangleShape(200, 20)
    platform.fixture = love.physics.newFixture(platform.body, platform.shape)
    platform.fixture:setFriction(0.8)
    table.insert(walls, platform)

    -- Add an angled platform
    local angleRamp = {}
    angleRamp.body = love.physics.newBody(world, screenWidth / 2 - 150, screenHeight / 2 + 100, "static")
    angleRamp.body:setAngle(math.rad(20))
    angleRamp.shape = love.physics.newRectangleShape(200, 20)
    angleRamp.fixture = love.physics.newFixture(angleRamp.body, angleRamp.shape)
    angleRamp.fixture:setFriction(0.8)
    table.insert(walls, angleRamp)
end

-- Function to create a new physics object
function Physics.createObject(x, y, objectType)
    local object = {}
    object.body = love.physics.newBody(world, x, y, "dynamic")
    object.color = {math.random(), math.random(), math.random()}

    if objectType == "circle" then
        local radius = 25
        object.shape = love.physics.newCircleShape(radius)
        object.fixture = love.physics.newFixture(object.body, object.shape, 1)
        object.fixture:setRestitution(0.7) -- Bounciness
        object.draw = function(self)
            love.graphics.setColor(self.color)
            love.graphics.circle("fill", self.body:getX(), self.body:getY(), radius)

            -- Draw a line to show rotation
            local angle = self.body:getAngle()
            love.graphics.line(
                self.body:getX(),
                self.body:getY(),
                self.body:getX() + radius * math.cos(angle),
                self.body:getY() + radius * math.sin(angle)
            )
        end
    elseif objectType == "rectangle" then
        local width, height = 50, 50
        object.shape = love.physics.newRectangleShape(width, height)
        object.fixture = love.physics.newFixture(object.body, object.shape, 1.5)
        object.fixture:setRestitution(0.5) -- Medium bounce
        object.draw = function(self)
            love.graphics.setColor(self.color)

            love.graphics.push()
            love.graphics.translate(self.body:getX(), self.body:getY())
            love.graphics.rotate(self.body:getAngle())
            love.graphics.rectangle("fill", -width/2, -height/2, width, height)
            love.graphics.pop()
        end
    elseif objectType == "polygon" then
        local radius = 30
        local points = {}
        local sides = 5 -- Pentagon

        for i = 1, sides do
            local angle = (i - 1) * math.pi * 2 / sides
            table.insert(points, radius * math.cos(angle))
            table.insert(points, radius * math.sin(angle))
        end

        object.shape = love.physics.newPolygonShape(unpack(points))
        object.fixture = love.physics.newFixture(object.body, object.shape, 2)
        object.fixture:setRestitution(0.3) -- Low bounce
        object.draw = function(self)
            love.graphics.setColor(self.color)

            love.graphics.push()
            love.graphics.translate(self.body:getX(), self.body:getY())
            love.graphics.rotate(self.body:getAngle())
            love.graphics.polygon("fill", points)
            love.graphics.pop()
        end
    end

    object.fixture:setFriction(0.5)

    return object
end

function Physics.update(dt)
    world:update(dt)

    -- Check if any objects are below the screen and destroy them
    for i = #objects, 1, -1 do
        if objects[i].body:getY() > love.graphics.getHeight() + 100 then
            objects[i].body:destroy()
            table.remove(objects, i)
        end
    end
end

function Physics.draw()
    -- Draw background
    love.graphics.setColor(0.2, 0.2, 0.3)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- Draw title and description
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf(Physics.title, 0, 20, love.graphics.getWidth(), "center")

    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.printf(Physics.description, 0, 60, love.graphics.getWidth(), "center")

    -- Draw walls
    love.graphics.setColor(0.5, 0.5, 0.5)
    for _, wall in ipairs(walls) do
        love.graphics.push()
        love.graphics.translate(wall.body:getX(), wall.body:getY())
        love.graphics.rotate(wall.body:getAngle())

        if wall.shape:getType() == "CircleShape" then
            love.graphics.circle("fill", 0, 0, wall.shape:getRadius())
        elseif wall.shape:getType() == "PolygonShape" then
            local points = {wall.shape:getPoints()}
            love.graphics.polygon("fill", points)
        end

        love.graphics.pop()
    end

    -- Draw objects
    for _, object in ipairs(objects) do
        object:draw()
    end

    -- Draw UI
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.rectangle("fill", 10, 100, 200, 150)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.printf("Controls:", 10, 110, 200, "center")
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.printf("Click - Add object", 10, 140, 200, "left")
    love.graphics.printf("1/2/3 - Change object type", 10, 160, 200, "left")
    love.graphics.printf("Space - Add random force", 10, 180, 200, "left")
    love.graphics.printf("R - Reset scene", 10, 200, 200, "left")

    -- Show selected object type
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Current: " .. objectTypes[selectedObject], 10, 220, 200, "center")

    -- Show object count
    love.graphics.printf("Objects: " .. #objects, 10, 240, 200, "center")

    -- Reset font and color
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.setColor(1, 1, 1)
end

function Physics.mousepressed(x, y, button)
    if button == 1 then
        -- Create new object at mouse position
        local newObject = Physics.createObject(x, y, objectTypes[selectedObject])
        table.insert(objects, newObject)
    end
end

function Physics.keypressed(key)
    if key == "1" or key == "2" or key == "3" then
        selectedObject = tonumber(key)
    elseif key == "space" then
        -- Apply random force to all objects
        for _, object in ipairs(objects) do
            local force = 5000
            object.body:applyForce(
                math.random(-force, force),
                math.random(-force, 0)
            )
        end
    elseif key == "r" then
        -- Reset scene
        Physics.enter()
    end
end

return Physics