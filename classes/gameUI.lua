-- gameUI library

-- Version 2.0 (updated for new audio API)
--
-- Copyright (C) 2010 Corona Labs Inc. All Rights Reserved.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in the
-- Software without restriction, including without limitation the rights to use, copy,
-- modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
-- and to permit persons to whom the Software is furnished to do so, subject to the
-- following conditions:
--
-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

module(..., package.seeall)

-- A general function for dragging physics bodies

-- Simple example:
-- 		local dragBody = gameUI.dragBody
-- 		object:addEventListener( "touch", dragBody )

local tempJointRemoved = false

function dragBobber(event, bobber, params)
	if (bobber.casting) then
		return
	end
	local body = event.target
	local phase = event.phase
	local stage = display.getCurrentStage()

	-- Bounds
	xMin = params.xMin
	yMin = params.yMin
	xMax = params.xMax
	yMax = params.yMax

	if (event.x < xMin or event.x > xMax or event.y < yMin or event.y > yMax) then
		stage:setFocus(body, nil)
		body.isFocus = false

		-- Remove the joint when the touch ends
		if (body.tempJoint and not tempJointRemoved) then
			tempJointRemoved = true
			body.tempJoint:removeSelf()
		end
		bobber.cast()
	end

	if "began" == phase then
		stage:setFocus(body, event.id)
		body.isFocus = true

		-- Create a temporary touch joint and store it in the object for later reference
		if params and params.center then
			-- drag the body from its center point
			tempJointRemoved = false
			body.tempJoint = physics.newJoint("touch", body, body.x, body.y)
		else
			-- drag the body from the point where it was touched
			tempJointRemoved = false
			body.tempJoint = physics.newJoint("touch", body, event.x, event.y)
		end

		-- Apply optional joint parameters
		if params then
			local maxForce, frequency, dampingRatio

			if params.maxForce then
				-- Internal default is (1000 * mass), so set this fairly high if setting manually
				body.tempJoint.maxForce = params.maxForce
			end

			if params.frequency then
				-- This is the response speed of the elastic joint: higher numbers = less lag/bounce
				body.tempJoint.frequency = params.frequency
			end

			if params.dampingRatio then
				-- Possible values: 0 (no damping) to 1.0 (critical damping)
				body.tempJoint.dampingRatio = params.dampingRatio
			end
		end
	elseif body.isFocus then
		if "moved" == phase then
			-- Update the joint to track the touch
			body.tempJoint:setTarget(event.x, event.y)
		elseif "ended" == phase or "cancelled" == phase then
			stage:setFocus(body, nil)
			body.isFocus = false

			-- Remove the joint when the touch ends
			if (body.tempJoint and not tempJointRemoved) then
				tempJointRemoved = true
				body.tempJoint:removeSelf()
			end
			bobber.cast()
		end
	end

	-- Stop further propagation of touch event
	return true
end
