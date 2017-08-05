-- Modal Scene
-- Popup for the modal when a user catches a fish

-- Imports
local composer = require('composer')
local widget = require("widget")
local utils = require("utils")

-- Set up DB
local newDB = require("database.db").create
local db = newDB()

-- This scene
local scene = composer.newScene()

-- Local groups
local mainGroup
local rodGroup
local baitGroup

-- Things
local title
local coins
local scrollView
local advertisementButton
local backButton
local rodQuestionMark
local baitQuestionMark

-- Rod
local rodBox
local rodTitleText
local rodInfo = require("data.rodInfo")
local rodDescription
local rodPicture
local rodBuyButton

-- Get bait info
local baitInfo = require("data.baitInfo")
local baitBox
local baitButtons = {}
local selectedBait = 1
local bigPicture
local baitTitleText
local description

-- If the user swipes to the right
local returnToTitle = false

-- if true, activate tutorial
local tutorial
local tutorialComplete = false

-- Custom function for resuming the game (from pause state)
function scene:resumeGame(tutorial2)
  if (tutorial2) then
    -- Code to resume game
    tutorial = true
  else 
    tutorialComplete = true
  end
end

-- Function to handle changing the displays for the rod
local function changeRod()
  if (db:getRows("StoreItems")[1].currentRodUpgrade < #rodInfo) then 

    local nextRodUpgrade = rodInfo[db:getRows("StoreItems")[1].currentRodUpgrade + 1]
    -- Check if buy button needs to be changed
    rodBuyButton:setLabel("Buy for " .. nextRodUpgrade.cost)
    if (nextRodUpgrade.cost > db:getRows("StoreItems")[1].coins) then
      -- grey out buy button
      rodBuyButton:setFillColor(.8, .8, .8)
      rodBuyButton:setEnabled(false)
    else 
      rodBuyButton:setFillColor(utils.hexToRGB("660000"))
      rodBuyButton:setEnabled(true)
    end

    -- Upgrade title
    rodTitleText.text = nextRodUpgrade.name

    -- Upgrade description text
    rodDescription.text = nextRodUpgrade.description

    -- Set rod image
    -- Rod image
    rodPicture:removeSelf()
    rodPicture = display.newImage("images/items/" .. nextRodUpgrade.image, 350, 50)
    rodPicture.anchorX = 0
    rodPicture.anchorY = 0
    rodGroup:insert(rodPicture)
  else
    -- No more rod upgrades
    rodBuyButton:setFillColor(.8, .8, .8)
    rodBuyButton:setEnabled(false)
    rodBuyButton:setLabel("No more rod upgrades")
  end
end

-- Function to handle changing the top display to the selected bait
local function changeBait()
  -- Change title
  baitTitleText.text = baitInfo[selectedBait].name .. " x" .. db:getRows("StoreItems")[1][baitInfo[selectedBait].dbName]

  -- Set big picture image
  bigPicture:removeSelf()
  bigPicture = display.newImage("images/baits/" .. string.lower(baitInfo[selectedBait].name) .."_large.png",  175, 1000)
  baitGroup:insert(bigPicture)

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

  -- Set description text
  description.text = "Description:\n" .. baitInfo[selectedBait].description

  -- Set time effictiveness text
  timeDisplay.text = "Time Effectiveness:\n" .. baitInfo[selectedBait].time .. " minutes"
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

local function handleButtonEventAdvertisement(event)
  if (event.phase == "ended") then
    print("open advertisement")
  end
end

-- Function to handle use button
local function handleButtonEventBait(event)
  if (event.phase == "ended") then
    selectedBait = event.target.id
    changeBait()
    resetButton(event.target)
  end
end

-- Function to handle chum buy button
local function handleButtonEventBuy(event)
  if (event.phase == "ended") then
    -- Subtract coins
    local insert = [[UPDATE StoreItems SET coins=]] .. db:getRows("StoreItems")[1].coins - baitInfo[selectedBait].cost .. [[;]]
    db:update(insert)

    -- Add one to bait count
    insert = [[UPDATE StoreItems SET ]] .. baitInfo[selectedBait].dbName .. [[=]] .. 
      db:getRows("StoreItems")[1][baitInfo[selectedBait].dbName] + 1 .. [[;]]
    db:update(insert)
    db:print()

    -- Update total coin display
    coins.text = db:getRows("StoreItems")[1].coins

    -- Update button text
    changeBait()
  elseif (event.phase == "moved") then
    local dy = math.abs((event.y - event.yStart))
    if (dy > 10) then
      display.getCurrentStage():setFocus()
      scrollView:takeFocus(event)
    end
  end
end

-- Function to handle rod buy button
local function handleButtonEventRodBuy(event)
  if (event.phase == "ended") then
    -- Subtract coins
    local insert = [[UPDATE StoreItems SET coins=]] .. 
      db:getRows("StoreItems")[1].coins - rodInfo[db:getRows("StoreItems")[1].currentRodUpgrade + 1].cost .. [[;]]
    db:update(insert)

    -- Add one to bait count
    insert = [[UPDATE StoreItems SET currentRodUpgrade=]] .. db:getRows("StoreItems")[1].currentRodUpgrade + 1 .. [[;]]
    db:update(insert)
    db:print()
  
    -- Update total coin display
    coins.text = db:getRows("StoreItems")[1].coins

    -- Update button text
    changeRod()

    -- Check if that was for the tutorial
    if (tutorial) and (db:getRows("Flags")[1].watchedTutorial == 0) then
      tutorialComplete = true
      composer.showOverlay("scenes.tutorialModal", {params = {text = 
      [[Congratulations! You just bought your first fishing rod upgrade.
Hit next and try swiping back to the title screen.]]}, 
      effect="fade", time=800, isModal=true})
    end
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
    if (db:getRows("Flags")[1].watchedTutorial == 0) then
      composer.gotoScene('scenes.title', {effect="fromRight", time=800, params={tutorial="store"}})
    else
      composer.gotoScene('scenes.title', {effect="fromRight", time=800, params={}})
    end
  end
end

local function handleButtonEventQuestionMark(event)
  if (event.phase == "ended") then
    local str
    if (event.target.id == 0) then
      str = [[Each rod upgrade you buy gives you more time to catch a fish after it bites the bobber]]
    else
      str = [[Chums affect certain fish and give that fish a higher spawn chance. Only one chum can be active per location]]
    end
    composer.showOverlay("scenes.storeHelpModal", {params = {text=str}, isModal=true, effect="fade", time=200})
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

  -- check if in tutorial mode
  tutorial = event.params.tutorial

  -- Title text
  title = display.newText({
    text = "Shop",
    x = 150,
    y = 0,
	  fontSize = 50,
    align = "left"
  })
  title:setFillColor(0)
  mainGroup:insert(title)

  -- Coins
  coins = display.newText({
    text = db:getRows("StoreItems")[1].coins,
    x = display.contentCenterX,
    y = 0,
	  fontSize = 50,
    align = "right"
  })
  coins:setFillColor(0)
  mainGroup:insert(coins)

  -- Adertisement button
  advertisementButton = widget.newButton({
    label = '+',
    fontSize = 40,
    labelColor = {default={utils.hexToRGB("000000")}, over={utils.hexToRGB("FFFFFF")}},
    onEvent = handleButtonEventAdvertisement,
    emboss = false,
    isEnabled = false,
    -- Properties for a rounded rectangle button
    shape = "roundedRect",
    width = 65,
    height = 65,
    cornerRadius = 25,
    -- fillColor = {default={utils.hexToRGB("FFFFFF")}, over={utils.hexToRGB("000000")}},
    -- strokeColor = {default={utils.hexToRGB("000000")}, over={utils.hexToRGB("FFFFFF")}},
    fillColor = {default={0.8, 0.8, 0.8}, over={0.8,0.8,0.8}},
    strokeColor = {default={0.8,0.8,0.8}, over={0.8,0.8,0.8}},
    strokeWidth = 4
  })
  advertisementButton.x = coins.x + 115
  advertisementButton.y = 0
  mainGroup:insert(advertisementButton)

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

  -- Scroll view
  scrollView = widget.newScrollView({
    top = 100,
    left = 50,
    width = display.contentWidth - 100,
    height = 1000,
    scrollWidth = 0,
    backgroundColor = {0, 0.447, 0.737},
    horizontalScrollDisabled = true,
    listener = scrollListener
  })
  mainGroup:insert(scrollView)

  -- Rod group
  rodGroup = display.newGroup()
  scrollView:insert(rodGroup)

  -- Rod box
  rodBox = display.newRoundedRect(0, 0, display.contentWidth - 100, 700, 12)
  rodBox:setFillColor(.8, .8, .8)
  rodBox.anchorX = 0
  rodBox.anchorY = 0
  rodGroup:insert(rodBox)

  -- Title text for rod
  rodTitleText = display.newText({
    text = rodInfo[db:getRows("StoreItems")[1].currentRodUpgrade + 1].name,
    x = 180,
    y = 50,
	  fontSize = 50,
    align = "left"
  })
  rodGroup:insert(rodTitleText)

  -- Rod question mark
  rodQuestionMark = widget.newButton({
    label = '?',
    fontSize = 40,
    labelColor = {default={utils.hexToRGB("000000")}, over={utils.hexToRGB("FFFFFF")}},
    onEvent = handleButtonEventQuestionMark,
    emboss = false,
    -- Properties for a rounded rectangle button
    shape = "roundedRect",
    width = 65,
    height = 65,
    cornerRadius = 25,
    -- fillColor = {default={utils.hexToRGB("FFFFFF")}, over={utils.hexToRGB("000000")}},
    -- strokeColor = {default={utils.hexToRGB("000000")}, over={utils.hexToRGB("FFFFFF")}},
    fillColor = {default={0.8, 0.8, 0.8}, over={0.8,0.8,0.8}},
    strokeColor = {default={0}, over={1}},
    strokeWidth = 4,
    id = 0
  })
  rodQuestionMark.x = rodGroup.width - 50
  rodQuestionMark.y = 50
  rodGroup:insert(rodQuestionMark)

  -- Rod description
  rodDescription = display.newText({
    text = rodInfo[db:getRows("StoreItems")[1].currentRodUpgrade + 1].description,
    x = 25,
    y = 100,
    width = 325,
    fontSize = 40,
    align = "left"
  })
  rodDescription.anchorX = 0
  rodDescription.anchorY = 0
  rodGroup:insert(rodDescription)

  -- Rod image
  rodImageName = rodInfo[db:getRows("StoreItems")[1].currentRodUpgrade + 1].image
  rodPicture = display.newImage("images/items/" .. rodImageName, 350, 50)
  rodPicture.anchorX = 0
  rodPicture.anchorY = 0
  rodGroup:insert(rodPicture)

  -- Rod buy button
  rodBuyButton = widget.newButton({
    label = "Buy",
    fontSize = 40,
    labelColor = {default={utils.hexToRGB("FFFFFF")}, over={utils.hexToRGB("000000")}},
    onEvent = handleButtonEventRodBuy,
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
  rodBuyButton.anchorX = .5
  rodBuyButton.anchorY = .5
  rodBuyButton.x = rodBox.width / 2
  rodBuyButton.y = 500
  rodGroup:insert(rodBuyButton)

  -- Bait group
  baitGroup = display.newGroup()
  scrollView:insert(baitGroup)

  -- Background
	baitBox = display.newRoundedRect(0, 750, display.contentWidth - 100, 1000, 12)
	baitBox:setFillColor(.8, .8, .8)
  baitBox.anchorX = 0
  baitBox.anchorY = 0
	baitGroup:insert(baitBox)

  -- Options for bait text
  baitTitleText = display.newText({
	  text = baitInfo[selectedBait].name,
    x = 180,
    y = 800,
	  fontSize = 50,
    align = "right"
	})
	baitGroup:insert(baitTitleText)

  -- Rod question mark
  baitQuestionMark = widget.newButton({
    label = '?',
    fontSize = 40,
    labelColor = {default={utils.hexToRGB("000000")}, over={utils.hexToRGB("FFFFFF")}},
    onEvent = handleButtonEventQuestionMark,
    emboss = false,
    -- Properties for a rounded rectangle button
    shape = "roundedRect",
    width = 65,
    height = 65,
    cornerRadius = 25,
    -- fillColor = {default={utils.hexToRGB("FFFFFF")}, over={utils.hexToRGB("000000")}},
    -- strokeColor = {default={utils.hexToRGB("000000")}, over={utils.hexToRGB("FFFFFF")}},
    fillColor = {default={0.8, 0.8, 0.8}, over={0.8,0.8,0.8}},
    strokeColor = {default={0}, over={1}},
    strokeWidth = 4,
    id = 1
  })
  baitQuestionMark.x = baitGroup.width - 50
  baitQuestionMark.y = baitTitleText.y
  baitGroup:insert(baitQuestionMark)

  -- Get info
  local descriptionString = baitInfo[selectedBait].description
  local timeString = baitInfo[selectedBait].time

  -- Set up selected bait area
  -- big picture
	bigPicture = display.newImage("images/baits/" .. string.lower(baitInfo[selectedBait].name) .."_large.png",  175, 1000)
    -- bigPicture = display.newRoundedRect(-150, -200, display.contentWidth / 3, display.contentHeight / 3, 12)
	-- bigPicture:setFillColor(0)
	-- bigPicture:setStrokeColor(78, 179, 211)
	-- bigPicture.strokeWidth = 4
	baitGroup:insert(bigPicture)

  -- description
  description = display.newText({
    text = "Description:\n" .. descriptionString,
    x = 500,
    y = 890,
    width = display.contentWidth / 2.5,
    fontSize = 35,
    align = "center"
  })
  description:setFillColor(0)
	baitGroup:insert(description)

  -- time display
  timeDisplay = display.newText({
    text = "Time Effectiveness\n" .. timeString .. " minutes",
    x = 500,
    y = 1090,
    width = display.contentWidth / 2,
    fontSize = 35,
    align = "center"
  })
  timeDisplay:setFillColor(0)
	baitGroup:insert(timeDisplay)

  -- buy button
  buyButton = widget.newButton({
    label = "Buy",
    fontSize = 40,
    labelColor = {default={utils.hexToRGB("FFFFFF")}, over={utils.hexToRGB("000000")}},
    onEvent = handleButtonEventBuy,
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
  buyButton.x = rodBox.width / 2
  buyButton.y = 1250
  
  -- Insert the button
  baitGroup:insert(buyButton)

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
      id = i,
    })
    baitButtons[i].x = 175 + ((xCounter) * 325)
    baitButtons[i].y = 1375 + (yCounter * 100)

    -- Increase the counters
    xCounter = xCounter + 1

    -- Reset counters if necessary
    if (xCounter > 1) then 
      xCounter = 0
      yCounter = yCounter + 1
    end

    baitGroup:insert(baitButtons[i])
  end

  -- Finally call resetButton to set the button to be already pressed
  resetButton(baitButtons[selectedBait])
  changeBait()
  changeRod()
end

-- show()
function scene:show( event )
  local sceneGroup = self.view
  local phase = event.phase
  if ( phase == "will" ) then
    -- Code here runs when the scene is still off screen (but is about to come on screen)
    -- Update coins
    coins.text = db:getRows("StoreItems")[1].coins
  elseif ( phase == "did" ) then
    -- Code here runs when the scene is entirely on screen

    -- Make tutorial modal if needed
  if (tutorial) and (db:getRows("Flags")[1].watchedTutorial == 0) then
    composer.showOverlay("scenes.tutorialModal", {params = {text = 
      [[This is the store. Here is where you can buy different types of chum to attract more fish.]] .. 
      [[ Also you can upgrade your fishing rod to make catching fish easier.
Hit next to buy your first rod upgrade.]]}, 
      effect="fade", time=800, isModal=true})
  end
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