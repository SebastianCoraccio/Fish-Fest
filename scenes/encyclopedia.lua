-- Modal Scene
-- Popup for the modal when a user catches a fish

-- Imports
local composer = require('composer')
local widget = require("widget")
local utils = require("utils")
local fishInfo = require("data.fishInfo")

-- Set up DB
local newDB = require("database.db").create
local db = newDB()

-- This scene
local scene = composer.newScene()

-- Local groups
local mainGroup
local plaqueGroup

-- Things
local title
local coins
local scrollView
local backButton
local plaques = {}

local function scrollListener(event)
  if (event.phase == "moved") then
    display.getCurrentStage():setFocus()
    scrollView:takeFocus(event)
  end
end

local function handleButtonEventPlaque(event)
  if (event.phase == "ended") then
    composer.gotoScene('scenes.encyclopediaModal', {params={fid=event.target.id}, effect="slideLeft", time=200})
    -- print(fishInfo[event.target.id].name)
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

  -- Coins
  -- coins = display.newText({
  --   text = db:getRows("StoreItems")[1].coins,
  --   x = display.contentCenterX,
  --   y = 0,
	--   fontSize = 50,
  --   align = "right"
  -- })
  -- coins:setFillColor(0)
  -- mainGroup:insert(coins)

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
  scrollView = widget.newScrollView(
    {
      top = 100,
      left = 00,
      -- width = display.contentWidth,
      -- height = display.contentHeight,
      -- scrollWidth = 0,
      backgroundColor = {0, 0.447, 0.737},
      horizontalScrollDisabled = true,
      -- listener = scrollListener
    }
  )
  mainGroup:insert(scrollView)

  -- Rod group
  plaqueGroup = display.newGroup()
  scrollView:insert(plaqueGroup)

  -- Insert all the plaques
  local xCounter = 0
  local yCounter = 0
  for i=1,#fishInfo do
    -- plaques[i] = widget.newButton({
    --   label = fishInfo[i].fid,
    --   default = "images/fish/" .. fishInfo[i].fid .. "_large.png",
    --   over = "images/fish/" .. fishInfo[i].fid .. "_large.png",
    --   fontSize = 40,
    --   labelColor = {default={utils.hexToRGB("FFFFFF")}, over={utils.hexToRGB("000000")}},
    --   onEvent = handleButtonEventPlaque,
    --   -- emboss = false,
    --   -- Properties for a rounded rectangle button
    --   -- shape = "roundedRect",
    --   width = 200,
    --   height = 125,
    --   cornerRadius = 25,
    --   fillColor = {default={utils.hexToRGB("660000")}, over={utils.hexToRGB("a36666")}},
    --   strokeColor = {default={utils.hexToRGB("a36666")}, over={utils.hexToRGB("660000")}},
    --   strokeWidth = 4,
    --   id = i
    -- })
    plaques[i] = widget.newButton(
    {
        width = 240,
        height = 120,
        defaultFile = "images/fish/" .. fishInfo[i].fid .. "_large.png",
        overFile = "images/fish/" .. fishInfo[i].fid .. "_large.png",
        onEvent = handleButtonEventPlaque,
        id = i
    }
)
    plaques[i].x = 125 + ((xCounter) * display.contentWidth / 3)
    plaques[i].y = 125 + (yCounter * 175)

    -- Increase the counters
    xCounter = xCounter + 1

    -- Reset counters if necessary
    if (xCounter > 2) then 
      xCounter = 0
      yCounter = yCounter + 1
    end

    plaqueGroup:insert(plaques[i])
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