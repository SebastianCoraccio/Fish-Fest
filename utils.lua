-- Utility functions used numerous times in the project
local utils = {}

-- Convert hex code to Corona RGB
function utils.hexToRGB(hexCode)
    local hexCode = hexCode:gsub("#","")
    return tonumber("0x"..hexCode:sub(1,2))/255,tonumber("0x"..hexCode:sub(3,4))/255,tonumber("0x"..hexCode:sub(5,6))/255;
end

-- Returns the distance between two given points
-- Params: (x1, y1) , (x2, y2)
function utils.dist(x1, y1, x2, y2)
  return math.sqrt((x2 - x1)^2 + (y2 - y1)^2 )
end

-- Returns, in degrees, the rotation 
-- Params: (x1, y1) , (x2, y2)
function utils.rotationTo(x1, y1, x2, y2, currentRotation)
  local newRotation = math.atan2(y1 - y2, x1 - x2) * (180/math.pi) + 90 
  if( math.abs(newRotation) > 180 ) then
    newRotation = (360 - math.abs(newRotation)) * ( -1 * newRotation / newRotation)
  end

  local changeInRotation = currentRotation - newRotation
  if (changeInRotation > 180) then
    newRotation = 360 - math.abs(newRotation)
  end

  return newRotation
end

-- Finds the point 'distance' away from (x1, y1) on the line formed by 
-- points 1: (x1, y1), 2: (x2, y2)
-- Distance should be less than the distance between point 1 and 2
function utils.getPointBetween(x1, y1, x2, y2, distance) 
  

  local distBetweenPoints = utils.dist(x1, y1, x2, y2)
--   if distBetweenPoints < distance then
--     distance = distBetweenPoints
--   end
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
  local dist1 = utils.dist(x2, y2, xp1, yp1)
  local dist2 = utils.dist(x2, y2, xp2, yp2)

  if math.min(dist1, dist2) == dist1 then
    return {x=xp1, y=yp1}
  else
    return {x=xp2, y=yp2}
  end 

end

return utils