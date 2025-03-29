-- scenes/audio.lua
-- Demonstrates audio capabilities in LÖVE

local Button = require('lib.components.button')
local Utils = require('lib.utils')

local Audio = {
    title = "Audio Demo",
    description = "Demonstrates audio playback and manipulation in LÖVE",
    category = "Audio & Input"
}

-- Audio sources
local sources = {}
local buttons = {}
local sliders = {}
local volumeLevel = 1.0
local pitchLevel = 1.0

-- Slider component
local Slider = {}
Slider.__index = Slider

function Slider.new(x, y, width, height, min, max, value, onChange, label)
    local self = setmetatable({}, Slider)

    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.min = min or 0
    self.max = max or 1
    self.value = value or (min + max) / 2
    self.onChange = onChange
    self.label = label or ""
    self.isDragging = false

    return self
end

function Slider:update(dt)
    if self.isDragging then
        local mx = love.mouse.getX()
        local percentage = (mx - self.x) / self.width
        percentage = Utils.clamp(percentage, 0, 1)

        local newValue = self.min + percentage * (self.max - self.min)

        if newValue ~= self.value then
            self.value = newValue
            if self.onChange then
                self.onChange(self.value)
            end
        end
    end
end

function Slider:mousepressed(x, y, button)
    if button == 1 and Utils.pointInRect(x, y, self.x, self.y, self.width, self.height) then
        self.isDragging = true

        -- Initial value update
        local percentage = (x - self.x) / self.width
        percentage = Utils.clamp(percentage, 0, 1)

        local newValue = self.min + percentage * (self.max - self.min)

        if newValue ~= self.value then
            self.value = newValue
            if self.onChange then
                self.onChange(self.value)
            end
        end

        return true
    end
    return false
end

function Slider:mousereleased(x, y, button)
    if button == 1 and self.isDragging then
        self.isDragging = false
        return true
    end
    return false
end

function Slider:draw()
    -- Draw track
    love.graphics.setColor(0.3, 0.3, 0.4)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- Draw handle
    local percentage = (self.value - self.min) / (self.max - self.min)
    local handleX = self.x + percentage * self.width

    love.graphics.setColor(0.7, 0.7, 0.8)
    love.graphics.rectangle("fill", handleX - 5, self.y - 5, 10, self.height + 10)

    -- Draw label
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.printf(self.label, self.x, self.y - 25, self.width, "left")

    -- Draw value
    love.graphics.printf(string.format("%.2f", self.value), self.x, self.y - 25, self.width, "right")
end

function Audio.enter()
    -- Create sources (normally we'd load audio files, but for this demo we'll generate them)
    sources = {
        {
            name = "Sine Wave",
            frequency = 440, -- A4 note
            generate = function(freq)
                local sampleRate = 44100
                local duration = 1 -- 1 second
                local soundData = love.sound.newSoundData(sampleRate * duration, sampleRate, 16, 1)

                for i = 0, soundData:getSampleCount() - 1 do
                    local t = i / sampleRate
                    local sample = math.sin(2 * math.pi * freq * t) * 0.5
                    soundData:setSample(i, sample)
                end

                return love.audio.newSource(soundData)
            end,
            source = nil
        },
        {
            name = "Square Wave",
            frequency = 330, -- E4 note
            generate = function(freq)
                local sampleRate = 44100
                local duration = 1 -- 1 second
                local soundData = love.sound.newSoundData(sampleRate * duration, sampleRate, 16, 1)

                for i = 0, soundData:getSampleCount() - 1 do
                    local t = i / sampleRate
                    local cycle = (t * freq) % 1
                    local sample = cycle < 0.5 and 0.5 or -0.5
                    soundData:setSample(i, sample)
                end

                return love.audio.newSource(soundData)
            end,
            source = nil
        },
        {
            name = "Sawtooth Wave",
            frequency = 523, -- C5 note
            generate = function(freq)
                local sampleRate = 44100
                local duration = 1 -- 1 second
                local soundData = love.sound.newSoundData(sampleRate * duration, sampleRate, 16, 1)

                for i = 0, soundData:getSampleCount() - 1 do
                    local t = i / sampleRate
                    local cycle = (t * freq) % 1
                    local sample = (cycle * 2 - 1) * 0.5
                    soundData:setSample(i, sample)
                end

                return love.audio.newSource(soundData)
            end,
            source = nil
        },
        {
            name = "Noise",
            frequency = 0,
            generate = function(_)
                local sampleRate = 44100
                local duration = 1 -- 1 second
                local soundData = love.sound.newSoundData(sampleRate * duration, sampleRate, 16, 1)

                for i = 0, soundData:getSampleCount() - 1 do
                    local sample = (math.random() * 2 - 1) * 0.3
                    soundData:setSample(i, sample)
                end

                return love.audio.newSource(soundData)
            end,
            source = nil
        }
    }

    -- Generate all sources
    for i, source in ipairs(sources) do
        source.source = source.generate(source.frequency)
        source.source:setLooping(true)
    end

    -- Set up buttons
    buttons = {}
    local buttonY = 150
    local buttonSpacing = 70

    for i, source in ipairs(sources) do
        -- Play button
        local playButton = Button.new(
            100,
            buttonY,
            120,
            50,
            "Play " .. source.name,
            {
                onClick = function()
                    source.source:play()
                end
            }
        )
        table.insert(buttons, playButton)

        -- Stop button
        local stopButton = Button.new(
            240,
            buttonY,
            120,
            50,
            "Stop " .. source.name,
            {
                onClick = function()
                    source.source:stop()
                end
            }
        )
        table.insert(buttons, stopButton)

        buttonY = buttonY + buttonSpacing
    end

    -- Volume slider
    local volumeSlider = Slider.new(
        500,
        200,
        200,
        20,
        0,
        1,
        volumeLevel,
        function(value)
            volumeLevel = value
            for _, source in ipairs(sources) do
                source.source:setVolume(volumeLevel)
            end
        end,
        "Volume"
    )
    table.insert(sliders, volumeSlider)

    -- Pitch slider
    local pitchSlider = Slider.new(
        500,
        280,
        200,
        20,
        0.5,
        2,
        pitchLevel,
        function(value)
            pitchLevel = value
            for _, source in ipairs(sources) do
                source.source:setPitch(pitchLevel)
            end
        end,
        "Pitch"
    )
    table.insert(sliders, pitchSlider)

    -- Apply initial values
    for _, source in ipairs(sources) do
        source.source:setVolume(volumeLevel)
        source.source:setPitch(pitchLevel)
    end
end

function Audio.exit()
    -- Stop all audio when leaving the scene
    for _, source in ipairs(sources) do
        if source.source and source.source:isPlaying() then
            source.source:stop()
        end
    end
end

function Audio.update(dt)
    -- Update buttons
    for _, button in ipairs(buttons) do
        button:update(dt)
    end

    -- Update sliders
    for _, slider in ipairs(sliders) do
        slider:update(dt)
    end
end

function Audio.draw()
    -- Draw background
    love.graphics.setColor(0.2, 0.2, 0.3)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- Draw title and description
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf(Audio.title, 0, 20, love.graphics.getWidth(), "center")

    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.printf(Audio.description, 0, 60, love.graphics.getWidth(), "center")

    -- Draw buttons
    for _, button in ipairs(buttons) do
        button:draw()
    end

    -- Draw sliders
    for _, slider in ipairs(sliders) do
        slider:draw()
    end

    -- Draw waveform visualizers
    local visualizerX = 500
    local visualizerY = 350
    local visualizerWidth = 200
    local visualizerHeight = 100

    love.graphics.setColor(0.3, 0.3, 0.4)
    love.graphics.rectangle("fill", visualizerX, visualizerY, visualizerWidth, visualizerHeight)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.printf("Waveform Visualization", visualizerX, visualizerY - 20, visualizerWidth, "center")

    -- Draw currently active source waveform
    local activeSource = nil
    for _, source in ipairs(sources) do
        if source.source and source.source:isPlaying() then
            activeSource = source
            break
        end
    end

    if activeSource then
        love.graphics.setColor(0, 1, 0)
        love.graphics.printf(activeSource.name, visualizerX, visualizerY + visualizerHeight + 10, visualizerWidth, "center")

        -- Draw the waveform
        love.graphics.setColor(0, 1, 0)
        love.graphics.setLineWidth(2)

        local points = {}
        local segments = 40

        for i = 0, segments do
            local x = visualizerX + (i / segments) * visualizerWidth
            local t = love.timer.getTime() * 5 + (i / segments)
            local y = visualizerY + visualizerHeight / 2

            if activeSource.name == "Sine Wave" then
                y = y + math.sin(t * activeSource.frequency * 0.1) * (visualizerHeight / 3)
            elseif activeSource.name == "Square Wave" then
                local cycle = (t * activeSource.frequency * 0.1) % 1
                y = y + (cycle < 0.5 and -1 or 1) * (visualizerHeight / 3)
            elseif activeSource.name == "Sawtooth Wave" then
                local cycle = (t * activeSource.frequency * 0.1) % 1
                y = y + (cycle * 2 - 1) * (visualizerHeight / 3)
            elseif activeSource.name == "Noise" then
                y = y + (math.random() * 2 - 1) * (visualizerHeight / 3)
            end

            table.insert(points, x)
            table.insert(points, y)
        end

        love.graphics.line(points)
        love.graphics.setLineWidth(1)
    else
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.printf("No sound playing", visualizerX, visualizerY + visualizerHeight / 2 - 10, visualizerWidth, "center")
    end

    -- Draw code example
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.rectangle("fill", 100, 450, 270, 120)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(12))

    local codeExample = [[
-- Loading and playing audio
local sound = love.audio.newSource("sound.ogg", "static")
sound:setVolume(0.8)  -- 0.0 to 1.0
sound:setPitch(1.2)   -- Pitch multiplier
sound:play()          -- Start playback
sound:pause()         -- Pause playback
sound:stop()          -- Stop completely
    ]]

    love.graphics.printf(codeExample, 110, 460, 250, "left")

    -- Reset font and color
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.setColor(1, 1, 1)
end

function Audio.mousepressed(x, y, button)
    -- Pass to buttons
    for _, btn in ipairs(buttons) do
        if btn:mousepressed(x, y, button) then
            return
        end
    end

    -- Pass to sliders
    for _, slider in ipairs(sliders) do
        if slider:mousepressed(x, y, button) then
            return
        end
    end
end

function Audio.mousereleased(x, y, button)
    -- Pass to buttons
    for _, btn in ipairs(buttons) do
        if btn:mousereleased(x, y, button) then
            return
        end
    end

    -- Pass to sliders
    for _, slider in ipairs(sliders) do
        if slider:mousereleased(x, y, button) then
            return
        end
    end
end

function Audio.keypressed(key)
    -- No special key handling for this demo
end

return Audio