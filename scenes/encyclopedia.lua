-- Modal Scene
-- Popup for the modal when a user catches a fish

-- Imports
local composer = require("composer")
local widget = require("widget")
local utils = require("utils")
local fishInfo = require("data.fishInfo")
local riverInfo = require("data.river")

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
local riverFishImages = {}
local riverPlaques = {}

-- Things
local title
local scrollView
local backButton

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

local function redrawPictures(sortedFish, locationInfo, images, plaques, group, y1, y2)
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

      if (images[i]) then
        images[i]:removeSelf()
      end
      if (plaques[i]) then
        plaques[i]:removeSelf()
      end

      x = 225 + ((xCounter) * display.contentWidth / 2)
      y =  y1 + (yCounter * 275) + y2
      -- Draw plaque
      plaques[i] = display.newImage("assets/plaque.png", x , y)
      plaques[i].xScale = 0.6
      plaques[i].yScale = 0.6
      group:insert(plaques[i])

      -- Redraw image
      images[i] =
        widget.newButton(
        {
          defaultFile = "assets/fish/" .. image .. "_large.png",
          overFile = "assets/fish/" .. image .. "_large.png",
          width = 360,
          height = 180,
          onEvent = handleButtonEventPlaque,
          id = locationInfo.fish[i].fid
        }
      )

      images[i].x = x
      images[i].y = y

      -- Increase the counters
      xCounter = xCounter + 1

      -- Reset counters if necessary
      if (xCounter >= 2) then
        xCounter = 0
        yCounter = yCounter + 1
      end

      -- Insert the button
      group:insert(images[i])
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
      top = 200,
      left = 50,
      width = display.contentWidth,
      height = display.contentHeight,
      scrollHeight = 4000,
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
  redrawPictures(riverInfo.fish, riverInfo, riverFishImages, riverPlaques, riverGroup, 200, 0)

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
    redrawPictures(riverInfo.fish, riverInfo, riverFishImages, riverPlaques, riverGroup, 200, 0)
    
  end
end

local function moveBG(event)
  yOffset = 2

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

Runtime:addEventListener("enterFrame", moveBG)

-- -----------------------------------------------------------------------------------

return scene
