function playerMouseAngle(x1, y1, x2, y2)
    return math.atan2(y1 - y2, x1 - x2) + math.pi
end

function zombieAngle(x1, y1, x2, y2)
    return math.atan2(y1 - y2, x1 - x2)
end

function distanceBetween(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 -y1)^2)
end