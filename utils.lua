-- Utility functions used numerous times in the project
local utils = {}

-- Returns the distance between two given points
-- Params: (x1, y1) , (x2, y2)
function utils.dist(x1, y1, x2, y2)
  return math.sqrt((x2 - x1)^2 + (y2 - y1)^2 )
end


-- Returns, in degrees, the rotation 
-- Params: (x1, y1) , (x2, y2)
function utils.rotationTo(x1, y1, x2, y2, currentRotation)
  local newRotation = math.atan2(y1 - y2, x1 - x2)

  local changeInRotation = currentRotation - newRotation
  if( changeInRotation > math.pi) then
    changeInRotation = changeInRotation - (2 * math.pi)
  elseif changeInRotation < -math.pi then
    changeInRotation = changeInRotation + (2 * math.pi)
  end

  return changeInRotation
end

-- Finds the point 'distance' away from (x1, y1) on the line formed by 
-- points 1: (x1, y1), 2: (x2, y2)
-- Distance should be less than the distance between point 1 and 2
function utils.getPointBetween(x1, y1, x2, y2, distance) 
  

  local distBetweenPoints = utils.dist(x1, y1, x2, y2)
  if distBetweenPoints < distance then
    distance = distBetweenPoints
  end
  print(distance)
  -- Calculate the slope of the line created by points (x1, y1), (x2, y2)
  local slope = (y2 - y1) / (x2 - x1)

  -- Draw a circle around (x1, y2) with radius distance
  -- xp1 and xp2 are the 2 intersection points on the line
  local xp1 = x1 + distance / math.sqrt(1 + slope^2)
  local xp2 = x1 - distance / math.sqrt(1 + slope^2)
  -- Calculate the y coordinates of the two above x coordinates
  local yp1 = slope * (xp1 - x1) + y1
  local yp2 = slope * (xp2 - x1) + y1

  -- Find the point that is closer to point 2
  local dist1 = utils.dist(x1, y1, xp1, yp1)
  local dist2 = utils.dist(x1, y1, xp2, yp2)
  
  if utils.dist(x2, y2, xp1, yp1) + dist1 == distBetweenPoints then
    return {x=xp1, y=yp1}
  else
    return {x=xp2, y=yp2}
  end 

end

return utils