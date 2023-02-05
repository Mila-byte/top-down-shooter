require("variables")
require("utils.math")

function love.load()
    math.randomseed(os.time())

    loadSprites()
    setPlayer()

    zombies = {}
    bullets = {}

    myFont = graphics.newFont(30)
    gameState = waiting
    score = 0
    maxTime = 2
    timer = maxTime
end

function love.update(dt)
    movePlayer(dt)
    moveZombie(dt)
    moveBullet(dt)
    deleteProjectiles(dt)
    killingZoblies()
    deleteZombiesAfterKilling()
    deleteBulletsAfterKilling()
end

function love.draw()
    graphics.draw(sprites.background, 0, 0)
    setBeginText()
    if player.injured == true then
        graphics.setColor(1, 0, 0)
    end
    graphics.draw(sprites.player, player.x, player.y, rotation, nil, nil, sprites.player:getWidth() / 2, sprites.player:getHeight() / 2)
    graphics.setColor(1, 1, 1)
    setZombies()
    setBullets()
    graphics.printf("Score: " .. score, 0, graphics.getHeight() - 100, graphics.getWidth(), "center")
end

function setBeginText()
    if gameState == waiting then
        graphics.setFont(myFont)
        graphics.printf("Click anywhere to begin!", 0, 50, graphics.getWidth(), "center")
    end
end

function love.mousepressed(x, y, button)
    if button == leftClick and gameState == playing then
        spawnBullet()
    elseif button == leftClick and gameState == waiting then
        gameState = playing
        maxTime = 2
        timer = maxTime
        score = 0
    end
end

function loadSprites()
    sprites = {}
    sprites.background = graphics.newImage('sprites/background.png')
    sprites.bullet = graphics.newImage('sprites/bullet.png')
    sprites.player = graphics.newImage('sprites/player.png')
    sprites.zombie = graphics.newImage('sprites/zombie.png')
end

function setPlayer()
    player = {}
    player.x = graphics.getWidth() / 2
    player.y = graphics.getHeight() / 2
    player.speed = 3 * fps
    player.injuredSpeed = 5 * fps
    player.injured = false

    rotation = 0
end

function setZombies()
    for i,enemy in ipairs(zombies) do
        graphics.draw(sprites.zombie, enemy.x, enemy.y, zombieAngle(player.x, player.y, enemy.x, enemy.y), nil, nil, sprites.zombie:getWidth() / 2, sprites.zombie:getHeight() / 2)
    end
end

function setBullets()
    for i,bullet in ipairs(bullets) do
        graphics.draw(sprites.bullet, bullet.x, bullet.y, nil, 0.5, 0.5, sprites.bullet:getWidth() / 2, sprites.bullet:getHeight() / 2)
    end
end

function movePlayer(dt)
    if player.injured then
        speed = player.injuredSpeed
    else
        speed = player.speed
    end

    if gameState == playing then
        -- right
        if keyboard.isDown("d") and player.x < graphics.getWidth() then
            player.x = player.x + speed * dt
        end
        -- left
        if keyboard.isDown("a") and player.x > 0 then
            player.x = player.x - speed * dt
        end
        -- up
        if keyboard.isDown("w") and player.y > 0 then
            player.y = player.y - speed * dt
        end
        -- down
        if keyboard.isDown("s") and player.y < graphics.getHeight() then
            player.y = player.y + speed * dt
        end
    end
    rotation = playerMouseAngle(player.x, player.y, mouse.getX(), mouse.getY())
end

function moveZombie(dt)
    for i,enemy in ipairs(zombies) do
        enemy.x = enemy.x + math.cos(zombieAngle(player.x, player.y, enemy.x, enemy.y)) * enemy.speed * dt
        enemy.y = enemy.y + math.sin(zombieAngle(player.x, player.y, enemy.x, enemy.y)) * enemy.speed * dt
        if distanceBetween(enemy.x, enemy.y, player.x, player.y) < sprites.player:getWidth() then
            if player.injured == true then
                for i,enemy in ipairs(zombies) do
                    zombies[i] = nil
                    gameState = waiting
                    player.x = graphics.getWidth() / 2
                    player.y = graphics.getHeight() / 2
                    player.injured = false
                end
            else
                player.injured = true
                enemy.dead = true
            end
        end
    end
end

function moveBullet(dt)
    for i,bullet in ipairs(bullets) do
        bullet.x = bullet.x + math.cos(bullet.direction) * bullet.speed * dt
        bullet.y = bullet.y + math.sin(bullet.direction) * bullet.speed * dt
    end
end

function deleteProjectiles(dt)
    for i=#bullets,1,-1 do
        local bullet = bullets[i]
        if bullet.x < 0 or bullet.y < 0 or bullet.x > graphics.getWidth() or bullet.y > graphics.getHeight() then
            table.remove(bullets, i)
        end
    end

    createZombies(dt)
end

function createZombies(dt)
    if gameState == playing then
        timer = timer - dt
        if timer <= 0 then
            spawnZombie()
            maxTime = 0.95 * maxTime
            timer = maxTime
        end
    end
end

function killingZoblies()
    for i,enemy in ipairs(zombies) do
        for j,bullet in ipairs(bullets) do
            if distanceBetween(enemy.x, enemy.y, bullet.x, bullet.y) < 20 then
                enemy.dead = true
                bullet.dead = true
                score = score + 1
            end
        end
    end
end

function deleteZombiesAfterKilling()
    for i=#zombies,1,-1 do
        local enemy = zombies[i]
        if enemy.dead == true then
            table.remove(zombies, i)
        end
    end
end

function deleteBulletsAfterKilling()
    for i=#bullets,1,-1 do
        local bullet = bullets[i]
        if bullet.dead == true then
            table.remove(bullets, i)
        end
    end
end

function spawnZombie()
    local zombie = {}
    zombie.x = 0
    zombie.y = 0
    zombie.speed = 2.3 * fps
    zombie.dead = false
    setRandomEnemyPosition(zombie)
    table.insert(zombies, zombie)
end

function setRandomEnemyPosition(zombie)
    local side = math.random(1, 4)
    local size = sprites.zombie:getWidth()
    if side == 1 then
        zombie.x = -size
        zombie.y = math.random(0, graphics.getHeight())
    elseif side == 2 then
        zombie.x = graphics.getWidth() + size
        zombie.y = math.random(0, graphics.getHeight())
    elseif side == 3 then
        zombie.x = math.random(0, graphics.getWidth())
        zombie.y = -size
    elseif side == 4 then
        zombie.x = math.random(0, graphics.getWidth())
        zombie.y = graphics.getHeight() + size
    end
end

function spawnBullet()
    local bullet = {}
    bullet.x = player.x
    bullet.y = player.y
    bullet.speed = 8 * fps
    bullet.dead = false
    bullet.direction = playerMouseAngle(player.x, player.y, mouse.getX(), mouse.getY())
    table.insert(bullets, bullet)
end