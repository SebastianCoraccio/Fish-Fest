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
local fids = {}
 
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
 
local function redrawPictures(sortedFish, locationInfo, plaques, group, y1, y2)
  local xCounter = 0
  local yCounter = 0
  table.sort(sortedFish, compare)
  for i=1, #sortedFish do
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
      plaques[i] = widget.newButton({
        width = 240,
        height = 120,
        defaultFile = "images/fish/" .. image .. "_large.png",
        overFile = "images/fish/" .. image .. "_large.png",
        onEvent = handleButtonEventPlaque,
        id = locationInfo.fish[i].fid
      })
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
  -- New display group
  riverGroup = display.newGroup()
  scrollView:insert(riverGroup)
 
  -- The text for the top of the section
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
 
  -- Get all the fids that the user has caught
  local caught = db:getRows("FishCaught")
  for i=1, #caught do
    fids[i] = caught[i].fid
  end
 
  -- Look at all the fish caught in the river sorted by fid
  redrawPictures(riverInfo.fish, riverInfo, riverPlaques, riverGroup, 125, 0)
 
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
 
  redrawPictures(atlanticInfo.fish, atlanticInfo, atlanticPlaques, atlanticGroup, 125, riverGroup.height)
 
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
 
  redrawPictures(reefInfo.fish, reefInfo, reefPlaques, reefGroup, 100, riverGroup.height)
 
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
 
  redrawPictures(icecapInfo.fish, icecapInfo, icecapPlaques, icecapGroup, -350, atlanticGroup.height + reefGroup.height + riverGroup.height)
end
 
-- show()
function scene:show( event )
  local sceneGroup = self.view
  local phase = event.phase
  if ( phase == "will" ) then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
    local caught = db:getRows("FishCaught")
    for i=1, #caught do
      fids[i] = caught[i].fid
    end
  elseif ( phase == "did" ) then
    -- Code here runs when the scene is entirely on screen
    redrawPictures(riverInfo.fish, riverInfo, riverPlaques, riverGroup, 125, 0)
    redrawPictures(atlanticInfo.fish, atlanticInfo, atlanticPlaques, atlanticGroup, 125, 820)
    redrawPictures(reefInfo.fish, reefInfo, reefPlaques, reefGroup, 100, riverGroup.height)
    redrawPictures(icecapInfo.fish, icecapInfo, icecapPlaques, icecapGroup, -350, atlanticGroup.height + reefGroup.height + riverGroup.height)
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