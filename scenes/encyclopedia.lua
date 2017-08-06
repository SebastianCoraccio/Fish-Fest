-- Modal Scene
-- Popup for the modal when a user catches a fish

-- Imports
local composer = require('composer')
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
    composer.gotoScene('scenes.fishDetails', {params={fid=event.target.id, previousScene="encyclopedia"}, 
                       effect="slideLeft", time=200})
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
    composer.gotoScene('scenes.title', {effect="fromTop", time=800, params={}})
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
  sceneGroup:insert(mainGroup)

  -- Title text
  title = display.newText({
    text = "Encyclopedia",
    x = 170,
    y = 0,
	  fontSize = 50,
    align = "left"
  })
  title:setFillColor(0)
  mainGroup:insert(title)

  -- Back button
  backButton = widget.newButton(
  {
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

  -- Scroll view
  scrollView = widget.newScrollView({
    top = 100,
    left = 00,
    -- width = display.contentWidth,
    -- height = display.contentHeight,
    -- scrollWidth = 0,
    backgroundColor = {0, 0.447, 0.737},
    horizontalScrollDisabled = true,
    -- listener = scrollListener
  })
  mainGroup:insert(scrollView)

  -- River
  riverGroup = display.newGroup()
  scrollView:insert(riverGroup)

  riverText = display.newText({
    text = "River Fish",
    x = 40,
    y = 25,
	  fontSize = 50,
    align = "left"
  })
  riverText.anchorX = 0
  riverText:setFillColor(0)
  riverGroup:insert(riverText)

  local xCounter = 0
  local yCounter = 0
  local sortedFish = riverInfo.fish
  table.sort(sortedFish, compare)
  for i=1, #sortedFish do
    if (riverInfo.fish[i].fid ~= 23) then
      riverPlaques[i] = widget.newButton({
        width = 240,
        height = 120,
        defaultFile = "images/fish/" .. riverInfo.fish[i].fid .. "_large.png",
        overFile = "images/fish/" .. riverInfo.fish[i].fid .. "_large.png",
        onEvent = handleButtonEventPlaque,
        id = riverInfo.fish[i].fid
      })
      riverPlaques[i].x = 125 + ((xCounter) * display.contentWidth / 3)
      riverPlaques[i].y = 125 + (yCounter * 175)

      -- Increase the counters
      xCounter = xCounter + 1

      -- Reset counters if necessary
      if (xCounter > 2) then 
        xCounter = 0
        yCounter = yCounter + 1
      end

      riverGroup:insert(riverPlaques[i])
    end
  end

  -- Atlantic
  atlanticGroup = display.newGroup()
  scrollView:insert(atlanticGroup)

  atlanticText = display.newText({
    text = "Atlantic Fish",
    x = 40,
    y = 75 + riverGroup.height,
    fontSize = 50,
    align = "left"
  })
  atlanticText.anchorX = 0
  atlanticText:setFillColor(0)
  riverGroup:insert(atlanticText)

  xCounter = 0
  yCounter = 0
  sortedFish = atlanticInfo.fish
  table.sort(sortedFish, compare)
  for i=1, #sortedFish do
    if (atlanticInfo.fish[i].fid ~= 23) then
      atlanticPlaques[i] = widget.newButton({
        width = 240,
        height = 120,
        defaultFile = "images/fish/" .. atlanticInfo.fish[i].fid .. "_large.png",
        overFile = "images/fish/" .. atlanticInfo.fish[i].fid .. "_large.png",
        onEvent = handleButtonEventPlaque,
        id = atlanticInfo.fish[i].fid
      })
      atlanticPlaques[i].x = 125 + ((xCounter) * display.contentWidth / 3)
      atlanticPlaques[i].y = (125 + (yCounter * 175)) + riverGroup.height

      -- Increase the counters
      xCounter = xCounter + 1

      -- Reset counters if necessary
      if (xCounter > 2) then 
        xCounter = 0
        yCounter = yCounter + 1
      end

      atlanticGroup:insert(atlanticPlaques[i])
    end
  end

  -- Reef
  reefGroup = display.newGroup()
  scrollView:insert(reefGroup)

  reefText = display.newText({
    text = "Reef Fish",
    x = 40,
    y = 150 + atlanticGroup.height + riverGroup.height,
	  fontSize = 50,
    align = "left"
  })
  reefText.anchorX = 0
  reefText:setFillColor(0)
  riverGroup:insert(reefText)

  xCounter = 0
  yCounter = 0
  sortedFish = reefInfo.fish
  table.sort(sortedFish, compare)
  for i=1, #sortedFish do
    if (reefInfo.fish[i].fid ~= 23) then
      reefPlaques[i] = widget.newButton({
        width = 240,
        height = 120,
        defaultFile = "images/fish/" .. reefInfo.fish[i].fid .. "_large.png",
        overFile = "images/fish/" .. reefInfo.fish[i].fid .. "_large.png",
        onEvent = handleButtonEventPlaque,
        id = reefInfo.fish[i].fid
      })
      reefPlaques[i].x = 125 + ((xCounter) * display.contentWidth / 3)
      reefPlaques[i].y = 100 + (yCounter * 175) + riverGroup.height

      -- Increase the counters
      xCounter = xCounter + 1

      -- Reset counters if necessary
      if (xCounter > 2) then 
        xCounter = 0
        yCounter = yCounter + 1
      end

      reefGroup:insert(reefPlaques[i])
    end
  end

  -- Ice cap
  icecapGroup = display.newGroup()
  scrollView:insert(icecapGroup)

  icecapText = display.newText({
    text = "Ice Cap Fish",
    x = 40,
    y = -500 + riverGroup.height + atlanticGroup.height + reefGroup.height,
	  fontSize = 50,
    align = "left"
  })
  icecapText.anchorX = 0
  icecapText:setFillColor(0)
  icecapGroup:insert(icecapText)

  xCounter = 0
  yCounter = 0
  sortedFish = icecapInfo.fish
  table.sort(sortedFish, compare)
  for i=1, #sortedFish do
    if (icecapInfo.fish[i].fid ~= 23) then
      icecapPlaques[i] = widget.newButton({
        width = 240,
        height = 120,
        defaultFile = "images/fish/" .. icecapInfo.fish[i].fid .. "_large.png",
        overFile = "images/fish/" .. icecapInfo.fish[i].fid .. "_large.png",
        onEvent = handleButtonEventPlaque,
        id = icecapInfo.fish[i].fid
      })
      icecapPlaques[i].x = 125 + ((xCounter) * display.contentWidth / 3)
      icecapPlaques[i].y = -350 + (yCounter * 175) + atlanticGroup.height + reefGroup.height + riverGroup.height

      -- Increase the counters
      xCounter = xCounter + 1

      -- Reset counters if necessary
      if (xCounter > 2) then 
        xCounter = 0
        yCounter = yCounter + 1
      end

      icecapGroup:insert(icecapPlaques[i])
    end
  end
end

-- show()
function scene:show( event )
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