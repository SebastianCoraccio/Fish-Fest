-- Modal Scene
-- Popup for the modal when a user catches a fish

-- Imports
local composer = require("composer")
local widget = require("widget")
local utils = require("utils")
local tips = require("data.tips")

-- This scene
local scene = composer.newScene()

-- Set up DB
local newDB = require("database.db").create
local db = newDB()

-- Local things
local mainGroup
local bgGroup1 = nil
local bgGroup2 = nil
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

local function changeLocation()
  -- Change title
  locationTitleText.text = locationInfo[selectedlocation]

  -- Set big picture image
  bigPicture =
    display.newImage("assets/locations/" .. string.lower(locationInfo[selectedLocation].name) .. ".png", 220, 350)
  locationGroup:insert(bigPicture)

  -- Set description text
  description.text = "Description:\n" .. locationInfo[selectedLocation].description
end

-- Reset button color
local function resetButton(event)
  -- Reset all buttons
  for i = 1, #locationButtons do
    locationButtons[i]:setFillColor(utils.hexToRGB("660000"))
  end

  -- Set button to be 'pressed'
  event:setFillColor(utils.hexToRGB("a36666"))
end

-- Function to handle use button
local function handleButtonEventLocation(event)
  if (event.phase == "ended") then
    selectedLocation = event.target.id
    changeLocation()
    resetButton(event.target)
  end
end

-- Go to title
local function handleButtonEventBack(event)
  if (event.phase == "ended") then
    composer.gotoScene("scenes.title", {effect = "slideRight", time = 800, params = {}})
  end
end

-- Function to handle buy button
local function handleButtonEventTravel(event)
  if (event.phase == "ended") then
    composer.gotoScene(
      "scenes.game",
      {params = {location = locationInfo[selectedLocation].dbName}, effect = "fade", time = 400}
    )
  end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create(event)
  local sceneGroup = self.view
  -- New display group
  mainGroup = display.newGroup()
  bgGroup1 = display.newGroup()
  bgGroup2 = display.newGroup()
  sceneGroup:insert(bgGroup2)
  sceneGroup:insert(bgGroup1)
  sceneGroup:insert(mainGroup)

  bgGroup1 = display.newImage(bgGroup1, "assets/backgrounds/bg_travel.png")
  bgGroup1.anchorX = 0
  bgGroup1.anchorY = 0
  bgGroup1.x = display.contentWidth / 2

  bgGroup2 = display.newImage(bgGroup2, "assets/backgrounds/bg_travel.png")
  bgGroup2.anchorX = 0
  bgGroup2.anchorY = 0
  bgGroup2.x = -display.contentWidth / 2

  -- Title text
  title =
    display.newText(
    {
      text = "Locations",
      x = 450,
      y = 90,
      fontSize = 128,
      align = "left",
      font = "LilitaOne-Regular.ttf"
    }
  )
  title:setFillColor(0)
  mainGroup:insert(title)

  backButton =
    widget.newButton(
    {
      x = 90,
      y = 90,
      width = 100,
      height = 100,
      defaultFile = "assets/buttons/back-button.png",
      overFile = "assets/buttons/back-button-pressed.png",
      onEvent = handleButtonEventBack
    }
  )
  mainGroup:insert(backButton)

  locationGroup = display.newGroup()
  mainGroup:insert(locationGroup)

  locationsBox =
    display.newRoundedRect(
    display.contentWidth / 2,
    display.contentHeight / 2.4,
    display.contentWidth / 1.1,
    display.contentHeight / 1.5,
    12
  )
  locationsBox:setFillColor(utils.hexToRGB("#dbc397"))
  locationsBox:setStrokeColor(utils.hexToRGB("#000000"))
  locationsBox.strokeWidth = 4
  locationGroup:insert(locationsBox)

  tipBox =
    display.newRoundedRect(
    display.contentWidth / 2,
    display.contentHeight / 1.14,
    display.contentWidth / 1.1,
    display.contentHeight / 5,
    12
  )
  tipBox:setFillColor(utils.hexToRGB("#dbc397"))
  tipBox:setStrokeColor(utils.hexToRGB("#000000"))
  tipBox.strokeWidth = 4
  locationGroup:insert(tipBox)

  tipsText =
    display.newText(
    {
      text = "Tips and Hints",
      x = display.contentWidth / 2.8,
      y = display.contentHeight / 1.23,
      width = 700,
      fontSize = 100,
      align = "center",
      font = "LilitaOne-Regular.ttf"
    }
  )
  tipsText:setFillColor(0)
  locationGroup:insert(tipsText)

  randomTip = tips[math.random(#tips)]

  tip =
    display.newText(
    {
      text = randomTip,
      x = display.contentWidth / 2,
      y = display.contentHeight / 1.12,
      width = display.contentWidth - 120,
      fontSize = 48,
      align = "center",
      font = "LilitaOne-Regular.ttf"
    }
  )
  tip:setFillColor(0)
  locationGroup:insert(tip)

  -- Options for location text
  options = {
    text = locationInfo[selectedLocation].name,
    x = 210,
    y = 230,
    fontSize = 110,
    align = "right",
    font = "LilitaOne-Regular.ttf"

  }
  locationTitleText = display.newText(options)
  locationTitleText:setFillColor(0)  
  locationGroup:insert(locationTitleText)

  -- Get info
  local descriptionString = locationInfo[selectedLocation].description

  -- Set up selected location area
  bigPicture =
    display.newImage("assets/locations/" .. string.lower(locationInfo[selectedLocation].name) .. ".png", 240, 450)
  locationGroup:insert(bigPicture)

  description =
    display.newText(
    {
      text = descriptionString,
      x = 700,
      y = 440,
      width = display.contentWidth / 2,
      fontSize = 48,
      align = "center",
      font = "LilitaOne-Regular.ttf"
    }
  )
  description:setFillColor(0)
  locationGroup:insert(description)

  moreSoonText =
    display.newText(
    {
      text = "More locations coming soon!",
      x = display.contentWidth / 2,
      y = display.contentHeight / 2,
      width = display.contentWidth / 1.5,
      fontSize = 100,
      align = "center",
      font = "LilitaOne-Regular.ttf"
    }
  )
  moreSoonText:setFillColor(0)
  locationGroup:insert(moreSoonText)

  goFishText =
    display.newText(
    {
      text = "Go fish!",
      x = display.contentWidth / 3 * 2,
      y = display.contentHeight / 1.42,
      width = display.contentWidth / 2.5,
      fontSize = 100,
      align = "center",
      font = "LilitaOne-Regular.ttf"
    }
  )
  goFishText:setFillColor(0)
  locationGroup:insert(goFishText)


  travelButton =
    widget.newButton(
    {
      x = display.contentWidth / 1.15,
      y = display.contentHeight / 1.42,
      width = 100,
      height = 100,
      defaultFile = "assets/buttons/back-button.png",
      overFile = "assets/buttons/back-button-pressed.png",
      onEvent = handleButtonEventTravel
    }
  )
  mainGroup:insert(backButton)
  travelButton.rotation = 180
  locationGroup:insert(travelButton)

end

-- show()
function scene:show(event)
  local sceneGroup = self.view
  local phase = event.phase
  if (phase == "will") then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
  elseif (phase == "did") then
  -- Code here runs when the scene is entirely on screen
  end
end

-- hide()
function scene:hide(event)
  local sceneGroup = self.view
  local phase = event.phase

  if (phase == "will") then
    -- Code here runs when the scene is on screen (but is about to go off screen)
  elseif (phase == "did") then
  -- Code here runs immediately after the scene goes entirely off screen
  end
end

-- destroy()
function scene:destroy(event)
  local sceneGroup = self.view
  -- Code here runs prior to the removal of scene's view
end

local function moveBG(event)
  xOffset = 3

  if (bgGroup1.x + xOffset) > display.contentWidth then
    bgGroup1.x = -display.contentWidth + xOffset
  else
    bgGroup1.x = bgGroup1.x + xOffset
  end
  if (bgGroup2.x + xOffset) > display.contentWidth then
    bgGroup2.x = -display.contentWidth + xOffset
  else
    bgGroup2.x = bgGroup2.x + xOffset
  end
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

Runtime:addEventListener("enterFrame", moveBG)
-- -----------------------------------------------------------------------------------

return scene
