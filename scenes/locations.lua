-- Modal Scene
-- Popup for the modal when a user catches a fish

-- Imports
local composer = require("composer")
local widget = require("widget")
local utils = require("utils")
local tips = require("data.tips")
local locationInfo = require("data.locationInfo")

-- This scene
local scene = composer.newScene()

-- Set up DB
local newDB = require("database.db").create
local db = newDB()

-- Local things
local mainGroup
local bgGroup1 = nil
local bgGroup2 = nil
local selectedLocation = 1

local tip
local tipIndex = 0

local function handleButtonEventBack(event)
  -- Goes back to title screen
  if (event.phase == "ended") then
    composer.gotoScene("scenes.title", {effect = "slideRight", time = 800, params = {}})
  end
end

local function handleButtonEventTravel(event)
  if (event.phase == "ended") then
    composer.gotoScene(
      "scenes.game",
      {params = {location = locationInfo[selectedLocation].dbName}, effect = "fade", time = 400}
    )
  end
end

local function handleButtonEventTip(event)
  if (event.phase == "ended") then
    if(event.target.id == 'next') then
      tipIndex = tipIndex + 1
    else
      tipIndex = tipIndex - 1
    end

    -- Adding one to index because mod will return 0, but lua arrays are 0 indexed
    tip.text = tips[(tipIndex % #tips) + 1]
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


  -- Add two identical backgrounds for scrolling
  bgGroup1 = display.newImage(bgGroup1, "assets/backgrounds/bg_travel.png")
  bgGroup1.anchorX = 0
  bgGroup1.anchorY = 0
  bgGroup1.x = display.contentWidth / 2

  bgGroup2 = display.newImage(bgGroup2, "assets/backgrounds/bg_travel.png")
  bgGroup2.anchorX = 0
  bgGroup2.anchorY = 0
  bgGroup2.x = -display.contentWidth / 2

  pageTitle =
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
  pageTitle:setFillColor(0)
  mainGroup:insert(pageTitle)

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

  -- Options for location text
  options = {
    text = locationInfo[selectedLocation].name,
    x = 210,
    y = 230,
    fontSize = 110,
    align = "right",
    font = "LilitaOne-Regular.ttf"

  }
  locationTitle = display.newText(options)
  locationTitle:setFillColor(0)  
  locationGroup:insert(locationTitle)

  -- Set up selected location area
  locationImage =
    display.newImage("assets/locations/" .. string.lower(locationInfo[selectedLocation].name) .. ".png", 240, 450)
  locationGroup:insert(locationImage)

  locationDescription =
    display.newText(
    {
      text = locationInfo[selectedLocation].description,
      x = 700,
      y = 440,
      width = display.contentWidth / 2,
      fontSize = 48,
      align = "center",
      font = "LilitaOne-Regular.ttf"
    }
  )
  locationDescription:setFillColor(0)
  locationGroup:insert(locationDescription)

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

  --------------------------------------------------------------
  -- Tips
  --------------------------------------------------------------
  
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

  nextTip =
    widget.newButton(
    {
      id = 'next',
      x = display.contentWidth / 1.15,
      y = display.contentHeight / 1.23,
      width = 100,
      height = 100,
      defaultFile = "assets/buttons/back-button.png",
      overFile = "assets/buttons/back-button-pressed.png",
      onEvent = handleButtonEventTip
    }
  )
  mainGroup:insert(nextTip)
  nextTip.rotation = 180
  locationGroup:insert(nextTip)

  prevTip =
    widget.newButton(
    {
      id = 'prev',
      x = display.contentWidth / 1.35,
      y = display.contentHeight / 1.23,
      width = 100,
      height = 100,
      defaultFile = "assets/buttons/back-button.png",
      overFile = "assets/buttons/back-button-pressed.png",
      onEvent = handleButtonEventTip
    }
  )
  mainGroup:insert(prevTip)
  locationGroup:insert(prevTip)

  tip =
    display.newText(
    {
      text = tips[tipIndex + 1],
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

end

function scene:destroy(event)
  local sceneGroup = self.view
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
