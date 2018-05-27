-- Modal Scene
-- Popup for the modal when a user catches a fish

-- Imports
local composer = require("composer")
local widget = require("widget")
local utils = require("utils")
local fishInfo = require("data.fishInfo")
local riverInfo = require("data.river")
local atlanticInfo = require("data.atlantic")
local reefInfo = require("data.reef")
local icecapInfo = require("data.ice_cap")

-- Set up DB
local newDB = require("database.db").create
local db = newDB()

-- This scene
local scene = composer.newScene()

-- Local groups
local mainGroup
local fids = {}

-- Background
local bgGroup1
local bgGroup1 = nil
local bgGroup2 = nil

-- River
local riverGroup
local riverText
local riverFish
local riverPlaques = {}
-- Ocean
local atlanticGroup
local atlanticText
local atlanticFish
local atlanticPlaques = {}
-- Reef
local reefGroup
local reefText
local reefFish
local reefPlaques = {}
-- Ice Cap
local icecapGroup
local icecapText
local icecapFish
local icecapPlaques = {}

-- Things
local title
local coins
local scrollView
local backButton
local plaques = {}

local function compare(one, two)
  return one.fid < two.fid
end

local function scrollListener(event)
  if (event.phase == "moved") then
    display.getCurrentStage():setFocus()
    scrollView:takeFocus(event)
  end
end

local function handleButtonEventPlaque(event)
  if (event.phase == "ended") then
    composer.gotoScene(
      "scenes.fishDetails",
      {
        params = {fid = event.target.id, previousScene = "encyclopedia"},
        effect = "slideLeft",
        time = 200
      }
    )
  elseif (event.phase == "moved") then
    local dy = math.abs((event.y - event.yStart))
    if (dy > 10) then
      display.getCurrentStage():setFocus()
      scrollView:takeFocus(event)
    end
  end
end

local function handleButtonEventBack(event)
  if (event.phase == "ended") then
    composer.gotoScene("scenes.title", {effect = "fromTop", time = 800, params = {}})
  end
end

local function redrawPictures(sortedFish, locationInfo, plaques, group, y1, y2)
  local xCounter = 0
  local yCounter = 0
  table.sort(sortedFish, compare)
  for i = 1, #sortedFish do
    -- Skip over the trash item
    if (locationInfo.fish[i].fid ~= 23) then
      -- If fid is in this table, load image, otherwise load shadow
      local image = locationInfo.fish[i].fid
      if (table.indexOf(fids, image) == nil) then
        image = "unknown"
      end

      if (plaques[i]) then
        plaques[i]:removeSelf()
      end

      -- Redraw image
      plaques[i] =
        widget.newButton(
        {
          width = 360,
          height = 180,
          defaultFile = "assets/fish/" .. image .. "_large.png",
          overFile = "assets/fish/" .. image .. "_large.png",
          onEvent = handleButtonEventPlaque,
          id = locationInfo.fish[i].fid
        }
      )
      plaques[i].x = 125 + ((xCounter) * display.contentWidth / 3)
      plaques[i].y = y1 + (yCounter * 175) + y2

      -- Increase the counters
      xCounter = xCounter + 1

      -- Reset counters if necessary
      if (xCounter > 2) then
        xCounter = 0
        yCounter = yCounter + 1
      end

      -- Insert the button
      group:insert(plaques[i])
    end
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

  sceneGroup:toFront()
  -- Code here runs when the scene is first created but has not yet appeared on screen
  bgGroup1 = display.newImage(bgGroup1, "assets/backgrounds/enc_background.png")
  bgGroup1.anchorX = 0
  bgGroup1.anchorY = 0

  -- bgGroup1.x = display.contentWidth / 2 
  bgGroup1.y = display.contentHeight / 2
  
  -- Code here runs when the scene is first created but has not yet appeared on screen
  bgGroup2 = display.newImage(bgGroup2, "assets/backgrounds/enc_background.png")
  bgGroup2.anchorX = 0
  bgGroup2.anchorY = 0
  
  -- bgGroup2.x = - display.contentWidth / 2
  bgGroup2.y = - display.contentHeight / 2


  -- Title text
  title =
    display.newText(
    {
      text = "Encyclopedia",
      x = 540,
      y = 90,
      fontSize = 128,
      align = "left",
      font = "LilitaOne-Regular.ttf"
    }
  )
  title:setFillColor(0)
  mainGroup:insert(title)

  -- Back button
  backButton =
    widget.newButton(
    {
      x = 90,
      y = 90,
      width = 100,
      height = 100,
      defaultFile = "assets/buttons/back-button.png",
      overFile = "assets/buttons/back-button-pressed.png",
      onEvent = handleButtonEventBack,
    }
  )

  mainGroup:insert(backButton)

  -- Scroll view
  scrollView =
    widget.newScrollView(
    {
      top = 300,
      left = 50,
      width = display.contentWidth,
      height = display.contentHeight,
      -- scrollWidth = 0,
      hideBackground = true,
      horizontalScrollDisabled = true
      -- listener = scrollListener
    }
  )
  mainGroup:insert(scrollView)

  -- River
  -- New display group
  riverGroup = display.newGroup()
  scrollView:insert(riverGroup)

  -- The text for the top of the section
  riverText =
    display.newText(
    {
      text = "River Fish",
      x = 40,
      y = 25,
      fontSize = 72,
      align = "left",
      font = "LilitaOne-Regular.ttf"
    }
  )
  riverText.anchorX = 0
  riverText:setFillColor(0)
  riverGroup:insert(riverText)

  -- Get all the fids that the user has caught
  local caught = db:getRows("FishCaught")
  for i = 1, #caught do
    fids[i] = caught[i].fid
  end

  -- Look at all the fish caught in the river sorted by fid
  redrawPictures(riverInfo.fish, riverInfo, riverPlaques, riverGroup, 125, 0)

end

-- show()
function scene:show(event)
  local sceneGroup = self.view
  local phase = event.phase
  if (phase == "will") then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
    local caught = db:getRows("FishCaught")
    for i = 1, #caught do
      fids[i] = caught[i].fid
    end
  elseif (phase == "did") then
    -- Code here runs when the scene is entirely on screen
    redrawPictures(riverInfo.fish, riverInfo, riverPlaques, riverGroup, 125, 0)
    
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
  -- xOffset = 3
  yOffset = 3

  if (bgGroup1.y + yOffset ) > display.contentHeight then
    bgGroup1.y = - display.contentHeight + yOffset
  else
    bgGroup1.y = bgGroup1.y + yOffset
  end
  
  if (bgGroup2.y + yOffset ) > display.contentHeight then
    bgGroup2.y = - display.contentHeight + yOffset
  else
    bgGroup2.y = bgGroup2.y + yOffset
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
