----------------------------------------------------------------------------------------------------
-- game.lua -- TNAC --
-- 
-- Casting code and catching code.
--
-- David San Antonio
----------------------------------------------------------------------------------------------------
-- Your code here
local composer = require( "composer" )

-- This scene
local scene = composer.newScene()

-- Bobber image
local bobber

-- Function to to the catching
local function catch( event )
  if (event.phase == "ended" or event.phase == "cancelled") then
    transition.to( bobber, { x=display.contentCenterX, y=display.contentCenterY + 400, 
      transition=easing.outQuad, onComplete=caught() } )
  end
end

-- Function to be called when the player cast to bobber
local function casted()
  bobber._functionListeners = nil -- remove event listener
  bobber:addEventListener("touch", catch)
end

-- Function to do the cast
local function doSwipe( event )
  -- Set focus on the bobber
  if ( event.phase == "began" ) then
    display.getCurrentStage():setFocus( event.target )
  elseif ( event.phase == "moved" ) then
    if ( bobber.canBeSwiped == false ) then
      return
    end
  elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
    bobber.canBeSwiped = false

    -- Make sure the bobber cant be put off screen
    xLocation = event.x
    yLocation = event.y
    if (event.x <= 50) then
      xLocation = 50
    elseif (event.x >= display.contentWidth - 50) then
      xLocation = display.contentWidth - 50
    end

    if (event.y >= display.contentCenterY + 400) then
      -- Don't cast the bobber
      yLocation = display.contentCenterY + 400
      xLocation = display.contentCenterX
    elseif (event.y <= 50) then
      yLocation = 50
    end
    -- Move the bobber
    transition.to( bobber, { x=xLocation, y=yLocation, transition=easing.outQuad, 
      onComplete=casted() } )
  end
end

-- Function to be called when the player reeled in the bobber
function caught()
  bobber._functionListeners = nil -- remove event listener
  bobber:addEventListener("touch", doSwipe)
  bobber.canBeSwiped = true
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    -- Create the bobber
    bobber = display.newCircle( display.contentCenterX, display.contentCenterY + 400, 25 )
    
    -- Boolean to let bobber be cast
    bobber.canBeSwiped = true
    
end


-- show()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        -- Add listener on bobber
        bobber:addEventListener( "touch", doSwipe )
    end
end


-- hide()
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)

    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        -- Stop the music!

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
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene