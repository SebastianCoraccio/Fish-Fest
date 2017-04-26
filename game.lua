----------------------------------------------------------------------------------------------------
-- game.lua -- TNAC --
-- 
-- All of the game code.
--
-- David San Antonio
----------------------------------------------------------------------------------------------------
-- Require imports
local composer = require("composer")
local cast = require("cast")
local fish = require("fish")
local physics = require("physics")

-- Start the physics with no gravity
physics.start()
physics.setGravity(0, 0)

-- This scene
local scene = composer.newScene()

-- Bobber image
bobber = nil

-- Game timer
local gameLoopTimer

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    -- Create the bobber
    bobber = display.newCircle( display.contentCenterX, display.contentCenterY + 400, 25 )
    bobber:addEventListener( "touch", cast.doSwipe )
    physics.addBody(bobber, "dynamic")
    bobber.linearDamping = 1

    Runtime:addEventListener( "touch", cast.catch)

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
        -- Spawn initial fish
        for i=1,3 do
          fish.spawnFish()
        end
        -- Timer to spawn fish throughout
        -- TODO: Finalize time
        gameLoopTimer = timer.performWithDelay( 2500, fish.spawnFish, 0 )
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