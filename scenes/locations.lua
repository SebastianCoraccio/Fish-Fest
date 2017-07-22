-- Modal Scene
-- Popup for the modal when a user catches a fish

-- Imports
local composer = require('composer')
local widget = require("widget")
local utils = require("utils")

-- This scene
local scene = composer.newScene()

-- Set up DB
local newDB = require("database.db").create
local db = newDB()

-- Local things
local mainGroup
local title
local game
local scrollView
local locationInfo = require("data.locationInfo")
local locationBox
local locationButtons = {}
local selectedLocation = 1
local bigPicture
local locationTitleText
local description
-- Keeps track of what scene to load based on the users swipe
local sceneToLoad
local slideDirection

local tutorial

-- Function to handle changing the top display to the selected bait
local function changeLocation()
  -- Change title
  locationTitleText.text = locationInfo[selectedlocation]

  -- Set big picture image
  bigPicture = display.newImage("images/locations/" .. string.lower(locationInfo[selectedLocation].name) ..".png",  220, 350)
  locationGroup:insert(bigPicture)

  -- Set description text
  description.text = "Description:\n" .. locationInfo[selectedLocation].description
end

-- Reset button color
local function resetButton(event)
  -- Reset all buttons
  for i=1, #locationButtons do
    locationButtons[i]:setFillColor(utils.hexToRGB("660000"))
  end

  -- Set button to be 'pressed'
  event:setFillColor(utils.hexToRGB("a36666"))
end

-- Function to handle use button
local function handleButtonEventLocation(event)
  if (event.phase == "ended") then
    print(event.target.id)
    selectedLocation = event.target.id
    changeLocation()
    resetButton(event.target)
  end
end

-- Go to title
local function handleButtonEventBack(event)
  if (event.phase == "ended") then
    composer.gotoScene('scenes.title', {effect="slideRight", time=800, params={}})
  end
end

-- Function to handle buy button
local function handleButtonEventTravel(event)
  if (event.phase == "ended") then
    composer.purgeScene('scenes.game')
    composer.gotoScene('scenes.game', {params = {location=locationInfo[selectedLocation].dbName, tutorial=tutorial}, effect="fade", time=400})
  end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create(event)

  tutorial = event.params.tutorial

  local sceneGroup = self.view
   -- New display group
  mainGroup = display.newGroup()
  sceneGroup:insert(mainGroup)

  -- Title text
  title = display.newText({
    text = "Locations",
    x = 150,
    y = 0,
	  fontSize = 50,
    align = "center"
  })
  title:setFillColor(0)
  mainGroup:insert(title)

  -- Back button
  backButton = widget.newButton({
    label = "Back",
    fontSize = 40,
    onEvent = handleButtonEventBack,
    emboss = false,
    -- Properties for a rounded rectangle button
    shape = "roundedRect",
    width = 150,
    height = 75,
    cornerRadius = 12,
    labelColor = {default={utils.hexToRGB("#ef4100")}, over={utils.hexToRGB("#00aeef")}},
    fillColor = {default={utils.hexToRGB("#00aeef")}, over={utils.hexToRGB("#ef4100")}},
    strokeColor = {default={0}, over={0}},
    strokeWidth = 3
  })
  -- Center the button
  backButton.x = display.contentWidth - 100
  backButton.y = 0
  mainGroup:insert(backButton)

 -- location group
  locationGroup = display.newGroup()
  mainGroup:insert(locationGroup)

  -- Background
  locationBox = display.newRoundedRect(50, 100, display.contentWidth - 100, 1000, 12)
  locationBox:setFillColor(.8, .8, .8)
  locationBox.anchorX = 0
  locationBox.anchorY = 0
  locationGroup:insert(locationBox)

  -- Options for location text
  options = {
    text = locationInfo[selectedLocation].name,
    x = 150,
    y = 150,
	fontSize = 50,
    align = "right"
	}
  locationTitleText = display.newText(options)
  locationGroup:insert(locationTitleText)

  -- Get info
  local descriptionString = locationInfo[selectedLocation].description

  -- Set up selected location area
  -- big picture
  bigPicture = display.newImage("images/locations/" .. string.lower(locationInfo[selectedLocation].name) ..".png",  220, 350)
  locationGroup:insert(bigPicture)

  -- description
  description = display.newText({
    text = "Description:\n" .. descriptionString,
    x = 550,
    y = 300,
    width = display.contentWidth / 2.5,
    fontSize = 35,
    align = "center"
  })
  description:setFillColor(0)
  locationGroup:insert(description)

  -- buy button
  travelButton = widget.newButton({
    label = "Travel",
    fontSize = 40,
    labelColor = {default={utils.hexToRGB("FFFFFF")}, over={utils.hexToRGB("000000")}},
    onEvent = handleButtonEventTravel,
    emboss = false,
    -- Properties for a rounded rectangle button
    shape = "roundedRect",
    width = 500,
    height = 75,
    cornerRadius = 25,
    fillColor = {default={utils.hexToRGB("660000")}, over={utils.hexToRGB("a36666")}},
    strokeColor = {default={utils.hexToRGB("a36666")}, over={utils.hexToRGB("660000")}},
    strokeWidth = 4
  })
  -- Center the button
  travelButton.x = 395
  travelButton.y = 600
  
  -- Insert the button
  locationGroup:insert(travelButton)

  -- Create widgets for all the different kinds of locations
  -- TODO: Fix placement
  local xCounter = 0
  local yCounter = 0
  for i=1, #locationInfo do
    locationButtons[i] = widget.newButton({
      label = locationInfo[i].name,
      fontSize = 40,
      labelColor = {default={utils.hexToRGB("FFFFFF")}, over={utils.hexToRGB("000000")}},
      onEvent = handleButtonEventLocation,
      emboss = false,
      -- Properties for a rounded rectangle button
      shape = "roundedRect",
      width = 250,
      height = 75,
      cornerRadius = 25,
      fillColor = {default={utils.hexToRGB("660000")}, over={utils.hexToRGB("a36666")}},
      strokeColor = {default={utils.hexToRGB("a36666")}, over={utils.hexToRGB("660000")}},
      strokeWidth = 4,
      id = i,
    })
    locationButtons[i].x = 225 + ((xCounter) * 325)
    locationButtons[i].y = 750 + (yCounter * 100)

    -- Increase the counters
    xCounter = xCounter + 1

    -- Reset counters if necessary
    if (xCounter > 1) then 
      xCounter = 0
      yCounter = yCounter + 1
    end

    locationGroup:insert(locationButtons[i])
  end

  -- Finally call resetButton to set the button to be already pressed
  resetButton(locationButtons[selectedLocation])
  changeLocation()
end

-- show()
function scene:show(event)
  local sceneGroup = self.view
  local phase = event.phase
  if ( phase == "will" ) then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
  elseif ( phase == "did" ) then
    -- Code here runs when the scene is entirely on screen
  end
end

-- hide()
function scene:hide(event)
  local sceneGroup = self.view
  local phase = event.phase

  if ( phase == "will" ) then
    -- Code here runs when the scene is on screen (but is about to go off screen)
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