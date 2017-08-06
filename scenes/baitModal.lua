-- Modal Scene
-- Popup for the modal when a user catches a fish

-- Imports
local composer = require( "composer" )
local fishInfo = require("data.fishInfo")
local widget = require("widget")
local utils = require("utils")

-- Set up DB
local newDB = require("database.db").create
local db = newDB()

-- This scene
local scene = composer.newScene()

-- Local pieces of modal
local modalBox
local title
local closeButton
local valueText
local bigPicture
local description
local timeDisplay
local useButton
local buyButton
local baitButtons = {}
local totalCoins
local timeLeft
local baitTimerId

-- Current location
local location

-- Display group
local modalGroup

-- Get bait info
local baitInfo = require("data.baitInfo")

-- Selected bait
local selectedBait = 1

-- Function to update time remaining
local function updateTimeRemaining(bait)
  -- Set time remaining
  local t = os.date('*t')
  -- Bait Start time
  local startTime = os.time(t)
  local time = math.round(((bait.endTime - startTime) / 60)*10)*0.1
  timeLeft.text = "Time remaining for " .. bait.baitType ..": " .. time .. " min";
end

-- Function to handle changing the top display to the selected bait
local function changeBait()
  -- Change title
  title.text = baitInfo[selectedBait].name .. " x" .. db:getRows("StoreItems")[1][baitInfo[selectedBait].dbName]

  -- Set big picture image
  bigPicture = display.newImage("images/baits/" .. string.lower(baitInfo[selectedBait].name) .."_large.png", -150, -200)
  modalGroup:insert(bigPicture)

  -- Set description text
  description.text = "Description:\n" .. baitInfo[selectedBait].description

  -- Set time effictiveness text
  timeDisplay.text = "Time Effectiveness:\n" .. baitInfo[selectedBait].time .. " minutes"

  -- Change total coin text
  totalCoins.text = ("Total Coins:\n" .. db:getRows("StoreItems")[1].coins)

  -- Check if the buy button needs to be changed
  buyButton:setLabel("Buy for " .. baitInfo[selectedBait].cost)
  if (baitInfo[selectedBait].cost > db:getRows("StoreItems")[1].coins) then
    -- grey out buy button
    buyButton:setFillColor(.8, .8, .8)
    buyButton:setEnabled(false)
  else 
    buyButton:setFillColor(utils.hexToRGB("660000"))
    buyButton:setEnabled(true)
  end
  
  -- Check if the use button needs to be changed
  if (db:getRows("StoreItems")[1][baitInfo[selectedBait].dbName] <= 0) and (useButton:getLabel() == "Use") then
    useButton:setFillColor(.8, .8, .8)
    useButton:setEnabled(false)
  else
    useButton:setFillColor(utils.hexToRGB("007F00"))
    useButton:setEnabled(true)
  end

  -- Check if the use button needs to be changed
  local baits = db:getRows("baitUsages")
  if (#baits == 0) then
    timeLeft.text = ""
    if (baitTimerId) then
      timer.cancel(baitTimerId)
    end
  end
  for i=1,#baits do
    if (baits[i].location == location) then
      useButton:setLabel("Clear Chum")
      useButton:setFillColor(utils.hexToRGB("007F00"))
      useButton:setEnabled(true)

      -- Set time remaining
      local t = os.date('*t')
      -- Bait Start time
      local startTime = os.time(t)
      local time = math.round(((baits[i].endTime - startTime) / 60)*10)*0.1
      timeLeft.text = "Time remaining for " .. baits[i].baitType ..": " .. time .. " min";

      baitTimerId = timer.performWithDelay(10000, function()
        updateTimeRemaining(baits[i])
      end, 0)
      
      break
    else
      useButton:setLabel("Use")
      timeLeft.text = ""
    end
  end
end

-- Function to handle close button
local function handleButtonEventClose(event)
  if (event.phase == "ended") then
    composer.hideOverlay(true, "fade", 400)
  end
end

-- Function to handle buy button
local function handleButtonEventBuy(event)
  if (event.phase == "ended") then
    -- Subtract coins
    local insert = [[UPDATE StoreItems SET coins=]] .. db:getRows("StoreItems")[1].coins - baitInfo[selectedBait].cost .. [[;]]
    db:update(insert)

    -- Add one to bait count
    insert = [[UPDATE StoreItems SET ]] .. baitInfo[selectedBait].dbName .. [[=]] .. db:getRows("StoreItems")[1][baitInfo[selectedBait].dbName] + 1 .. [[;]]
    db:update(insert)
    db:print()

    -- Update button text
    changeBait()
  end
end

-- Function to handle use button
local function handleButtonEventUse(event)
  if (event.phase == "ended") then
    -- Check if this location already has an active bait
    local baits = db:getRows("baitUsages")
    local duplicate = false
    for i=1,#baits do
      if (baits[i].location == location) then
        duplicate = true
        break
      end
    end
    
    if (duplicate == false) then
      -- get table of current date and time
      local t = os.date('*t')
      -- Bait Start time
      local startTime = os.time(t)
      -- Calculate end time based on bait
      t.min = t.min + baitInfo[selectedBait].time
      local endTime = os.time(t)
      -- Add entry to DB
      local insert = [[INSERT INTO BaitUsages VALUES (']] .. location .. [[', ']] .. baitInfo[selectedBait].name .. [[', ']] .. 
        startTime .. [[', ']] .. endTime .. [[');]] 
      db:update(insert)

      -- Subtract one from count
      insert = [[UPDATE StoreItems SET ]] .. baitInfo[selectedBait].dbName .. [[=]] .. db:getRows("StoreItems")[1][baitInfo[selectedBait].dbName] - 1 .. [[;]]
      db:update(insert)
      db:print()

      -- Set label
      useButton:setLabel("Clear Bait")
    else 
      -- Clear bait
      local insert = [[DELETE FROM BaitUsages WHERE location = ']] .. location .. [[';]]
      db:update(insert)
      db:print()
      useButton:setLabel("Use")
    end

    -- Update button if necessary
    changeBait()

    -- TODO: Set up a push notification
  end
end

-- Reset button color
local function resetButton(event)
  -- Reset all buttons
  for i=1, #baitButtons do
    baitButtons[i]:setFillColor(utils.hexToRGB("660000"))
  end

  -- Set button to be 'pressed'
  event:setFillColor(utils.hexToRGB("a36666"))
end

-- Function to handle use button
local function handleButtonEventBait(event)
  if (event.phase == "ended") then
    selectedBait = event.target.id
    changeBait()
    resetButton(event.target)
  end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create(event)
  local sceneGroup = self.view
   -- New display group to add modal too
  modalGroup = display.newGroup()
  sceneGroup:insert(modalGroup)

  -- Place the group
	modalGroup.x = display.contentWidth / 2
	modalGroup.y = display.contentHeight / 2

  -- Set the location
  location = event.params.location

  -- Code here runs when the scene is first created but has not yet appeared on screen
  -- Background
	modalBox = display.newRoundedRect(0, 0, display.contentWidth / 1.25, display.contentHeight, 12)
	modalBox:setFillColor( 255 )
	modalBox:setStrokeColor(78, 179, 211)
	modalBox.strokeWidth = 4
	modalGroup:insert(modalBox)

  -- Options for title text
	local options = {
	   text = baitInfo[selectedBait].name,
     x = -260,
     y = -450,
	   fontSize = 50,
     align = "right"
	}
	title = display.newText(options)
  title.anchorX = 0
	title:setFillColor(0)
	modalGroup:insert(title)

  timeLeft = display.newText({
    text = "",
    x = -260,
    y = -380,
	  fontSize = 35,
    align = "right"
  })
  timeLeft.anchorX = 0
  timeLeft:setFillColor(0)
  modalGroup:insert(timeLeft)

  -- Create the close button
  closeButton = widget.newButton({
    label = "X",
    fontSize = 40,
    labelColor = {default={utils.hexToRGB("000000")}, over={utils.hexToRGB("FFFFFF")}},
    onEvent = handleButtonEventClose,
    emboss = false,
    -- Properties for a rounded rectangle button
    shape = "roundedRect",
    width = 75,
    height = 75,
    cornerRadius = 12,
    fillColor = {default={utils.hexToRGB("FFFFFF")}, over={utils.hexToRGB("000000")}},
    strokeColor = {default={utils.hexToRGB("000000")}, over={utils.hexToRGB("FFFFFF")}},
    strokeWidth = 4
  })
  -- Center the button
  closeButton.x = modalGroup.width / 3
  closeButton.y = -450
  
  -- Insert the button
  modalGroup:insert(closeButton)

  -- Get info
  local descriptionString = baitInfo[selectedBait].description
  local timeString = baitInfo[selectedBait].time

  -- Set up selected bait area
  -- big picture
  bigPicture = display.newImage("images/baits/" .. string.lower(baitInfo[selectedBait].name) .."_large.png", -150, -200)
	modalGroup:insert(bigPicture)

  -- description
  description = display.newText({
    text = "Description:\n" .. descriptionString,
    x = 150,
    y = -310,
    width = display.contentWidth / 2.5,
    fontSize = 35,
    align = "center"
  })
  description:setFillColor(0)
	modalGroup:insert(description)

  -- time display
  timeDisplay = display.newText({
    text = "Time Effectiveness:\n" .. timeString .. " minutes",
    x = 150,
    y = -260 + description.height,
    width = display.contentWidth / 2,
    fontSize = 35,
    align = "center"
  })
  timeDisplay:setFillColor(0)
	modalGroup:insert(timeDisplay)

  -- Total coin display
  totalCoins = display.newText({
    text = "Coins:\n" .. db:getRows("StoreItems")[1].coins,
    x = 150,
    y = -220 + description.height + timeDisplay.height,
    width = display.contentWidth / 2,
    fontSize = 35,
    align = "center"
  })
  totalCoins:setFillColor(0)
  modalGroup:insert(totalCoins)

  -- use button
  useButton = widget.newButton({
    label = "Use",
    fontSize = 40,
    labelColor = {default={utils.hexToRGB("FFFFFF")}, over={utils.hexToRGB("000000")}},
    onEvent = handleButtonEventUse,
    emboss = false,
    -- Properties for a rounded rectangle button
    shape = "roundedRect",
    width = 250,
    height = 75,
    cornerRadius = 25,
    fillColor = {default={utils.hexToRGB("007F00")}, over={utils.hexToRGB("66b266")}},
    strokeColor = {default={utils.hexToRGB("66b266")}, over={utils.hexToRGB("007F00")}},
    strokeWidth = 4
  })
  -- Center the button
  useButton.x = -150
  useButton.y = 50
  
  -- Insert the button
  modalGroup:insert(useButton)

  -- buy button
  buyButton = widget.newButton({
    label = "Buy",
    fontSize = 40,
    labelColor = {default={utils.hexToRGB("FFFFFF")}, over={utils.hexToRGB("000000")}},
    onEvent = handleButtonEventBuy,
    emboss = false,
    -- Properties for a rounded rectangle button
    shape = "roundedRect",
    width = 250,
    height = 75,
    cornerRadius = 25,
    fillColor = {default={utils.hexToRGB("660000")}, over={utils.hexToRGB("a36666")}},
    strokeColor = {default={utils.hexToRGB("a36666")}, over={utils.hexToRGB("660000")}},
    strokeWidth = 4
  })
  -- Center the button
  buyButton.x = 150
  buyButton.y = 50
  
  -- Insert the button
  modalGroup:insert(buyButton)

  -- Create widgets for all the different kinds of baits
  -- TODO: Fix placement
  local xCounter = 0
  local yCounter = 0
  for i=1, #baitInfo do
    baitButtons[i] = widget.newButton({
      label = baitInfo[i].name,
      fontSize = 40,
      labelColor = {default={utils.hexToRGB("FFFFFF")}, over={utils.hexToRGB("000000")}},
      onEvent = handleButtonEventBait,
      emboss = false,
      -- Properties for a rounded rectangle button
      shape = "roundedRect",
      width = 250,
      height = 75,
      cornerRadius = 25,
      fillColor = {default={utils.hexToRGB("660000")}, over={utils.hexToRGB("a36666")}},
      strokeColor = {default={utils.hexToRGB("a36666")}, over={utils.hexToRGB("660000")}},
      strokeWidth = 4,
      id = i
    })
    baitButtons[i].x = -150 + ((xCounter) * 300)
    baitButtons[i].y = 175 + (yCounter * 100)

    -- Increase the counters
    xCounter = xCounter + 1

    -- Reset counters if necessary
    if (xCounter > 1) then 
      xCounter = 0
      yCounter = yCounter + 1
    end

    modalGroup:insert(baitButtons[i])
  end

  -- Finally call resetButton to set the button to be already pressed
  resetButton(baitButtons[selectedBait])
  changeBait()
end

-- show()
function scene:show( event )
  local sceneGroup = self.view
  local phase = event.phase
  if ( phase == "will" ) then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
    local baits = db:getRows("baitUsages")
    for i=1, #baits do
      if (baits[i].location == location) then
        local name = baits[i].baitType
        for i=1, #baitButtons do
          if (name == baitButtons[i]:getLabel()) then
            selectedBait = i
            break
          end
        end
        break
      end
    end
    resetButton(baitButtons[selectedBait])
    changeBait()
  elseif ( phase == "did" ) then
    -- Code here runs when the scene is entirely on screen
  end
end

-- hide()
function scene:hide(event)
  local sceneGroup = self.view
  local phase = event.phase
  local parent = event.parent  -- Reference to the parent scene object

  if ( phase == "will" ) then
    -- Code here runs when the scene is on screen (but is about to go off screen)
    parent:resumeGame()
  elseif ( phase == "did" ) then
    -- Code here runs immediately after the scene goes entirely off screen
  end
end

-- destroy()
function scene:destroy( event )
  local sceneGroup = self.view
  -- Code here runs prior to the removal of scene's view
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)
-- -----------------------------------------------------------------------------------

return scene