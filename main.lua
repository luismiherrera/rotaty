function love.load()
    love.window.setTitle("Rotaty")
    love.mouse.setVisible(false)
    windowWidth = love.graphics.getWidth()
    windowHeight = love.graphics.getHeight()
    paddleWidth = 30
    paddleHeight = 10
    paddleX = windowWidth/2-paddleWidth/2
    initialPaddleY = windowHeight - 150
    paddleY = initialPaddleY
    paddleRot = 0
    oldRot = paddleRot
    pivotMoved = false
    offset = 1
    paddleXoffset = - paddleWidth
    paddleRotSpeed = 12
    initialPaddleYSpeed = 500
    paddleYSpeed = initialPaddleYSpeed
    paddleYSpeedDamp = paddleYSpeed*2.8
    paddleJumping = false
    stringRot = 0
    amplitude = 0.3

    paddleBBX = paddleX+((paddleRot/2)*((paddleWidth/2)+paddleHeight/2))
    paddleBBY = paddleY-paddleHeight*2 - ((math.cos(2*paddleRot-math.pi)*(paddleWidth/2)))
    paddleBBWidth = paddleWidth
    paddleBBHeight = paddleHeight*2.5 + ((math.cos(2*paddleRot-math.pi)*(paddleWidth/2)))
    
    balls = {
        {
            x = math.random(10, windowWidth - 10),
            y = -10,
            radius = 10,
            speed = math.random(50, 170)
        },
        {
            x = math.random(10, windowWidth - 10),
            y = -10,
            radius = 10,
            speed = math.random(50, 170)
        }
    }

    bullets = {}
    bulletTimerLimit = 0.1
    bulletTimer = bulletTimerLimit

    killed = love.audio.newSource("audio/goal.wav", "static")

    debugVisibility = false
end

function love.update(dt)
    input(dt)
    dtime = dt
    
    --jumping
    if paddleJumping == true then
        paddleY = paddleY - paddleYSpeed*dt
        if paddleYSpeed > 0 then 
            paddleYSpeed = paddleYSpeed - paddleYSpeedDamp*dt
        else 
            if paddleY < initialPaddleY then
                paddleYSpeed = paddleYSpeed - paddleYSpeedDamp*dt
            else
                paddleY = initialPaddleY
                paddleYSpeed = 0
                paddleJumping = false
                paddleYSpeed = initialPaddleYSpeed
            end
        end

        --string vibration
        stringY = initialPaddleY-20+paddleHeight/2 + math.cos(stringRot)*10 --amplitude
        if stringY < paddleY then stringY = paddleY end
        stringRot = stringRot + 18*dt --frequency
    end
    
    --"walking"
    if paddleX > windowWidth + paddleWidth then
        paddleX = -paddleWidth
    elseif paddleX < - paddleWidth then
        paddleX = windowWidth + paddleWidth
    end
    
    if paddleRot < 0 then
        paddleXoffset = 0
    else
        paddleXoffset = -paddleWidth
    end
    if paddleRot >= math.pi and pivotMoved == false then
        paddleX = paddleX + paddleWidth
        pivotMoved = true
        paddleRot = 0
        pivotMoved = false 
    elseif paddleRot <= -math.pi and pivotMoved == false then
        paddleX = paddleX - paddleWidth
        pivotMoved = true
        paddleRot = 0
        pivotMoved = false 
    end

    --paddle vibration
    if paddleRot == 0 then
        amplitude = amplitude - 0.001
        if amplitude < 0 then amplitude = 0 end
    else
        amplitude = 0.7
    end
    paddleY = paddleY + math.cos(stringRot)*amplitude
    stringRot = stringRot + 12*dt -- frequency

    --paddle bounding box
    paddleBBX = paddleX+((paddleRot/2)*((paddleWidth/2)+paddleHeight/2)) + 5
    paddleBBY = paddleY-paddleHeight*2 - (math.cos(2*paddleRot-math.pi)*(paddleWidth/2)) + 3
    paddleBBWidth = paddleWidth - 10
    paddleBBHeight = paddleHeight*2.5 + ((math.cos(2*paddleRot-math.pi)*(paddleWidth/2))) - 7

    --paddle second eye
    if paddleRot >= 0 then
        eyeX = paddleX + paddleWidth - (math.sin(paddleRot+math.pi/2))*paddleWidth
        eyeY = paddleY + (math.cos(paddleRot+math.pi/2))*paddleWidth
    else
        eyeX = paddleX - (math.sin(paddleRot-math.pi/2))*paddleWidth
        eyeY = paddleY - (math.cos(paddleRot+math.pi/2))*paddleWidth
    end

    --balls falling
    for ballIndex, ball in ipairs(balls) do
        ball.y = ball.y + ball.speed * dt

        -- checking collission
        if ball.y + ball.radius > paddleBBY and ball.y - ball.radius < paddleBBY + paddleBBHeight then
            if ball.x + ball.radius > paddleBBX and ball.x - ball.radius < paddleBBX + paddleBBWidth then
                collission = true
                love.audio.play(killed)
            end
        else
            collission = false
        end
        
        -- reseting vertical position when ball reaches the ground
        if ball.y + ball.radius > windowHeight or collission then
           -- delete ball
            ball.y = -10
            ball.x = math.random(10, windowWidth - 10)
        end
    end

    
    for bulletIndex = #bullets, 1, -1 do
        local bullet = bullets[bulletIndex]

        if bullet.x < 0 or bullet.x > windowWidth or bullet.y < 0 or bullet.y > windowHeight then--bullet.timeLeft <= 0 then
            table.remove(bullets, bulletIndex)
        else
            local bulletSpeed = 500
            if bullet.dir == "positive" then
                bullet.x = (bullet.x - math.cos(bullet.angle) * bulletSpeed * dt)
                bullet.y = (bullet.y - math.sin(bullet.angle) * bulletSpeed * dt)
            else
                bullet.x = (bullet.x + math.cos(bullet.angle) * bulletSpeed * dt)
                bullet.y = (bullet.y + math.sin(bullet.angle) * bulletSpeed * dt)
            end
        end
    end
end

function love.draw()
    --DEBUG
    --paddle debug collision rectangle
    if debugVisibility then
        love.graphics.setColor(1, 1, 1) 
        love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
        love.graphics.print("paddleRot: "..tostring(paddleRot), 10, 30)
        love.graphics.print("bullets: "..tostring(#bullets), 10, 50)

        love.graphics.setColor(0,1,0)
        love.graphics.rectangle("line",
                                paddleBBX,
                                paddleBBY,
                                paddleBBWidth, 
                                paddleBBHeight)
        love.graphics.setColor(1,1,1)
    end

    --STRING
    love.graphics.setColor(1,1,1)
    if paddleJumping == false then
        love.graphics.line(-100,initialPaddleY-20+paddleHeight/2,paddleBBX+15,paddleY+paddleHeight/2)
        love.graphics.line(paddleBBX+16,paddleY+paddleHeight/2,windowWidth+200,initialPaddleY-20+paddleHeight/2)
    else
        love.graphics.line(-100,initialPaddleY-20+paddleHeight/2,paddleBBX+15,stringY)
        love.graphics.line(paddleBBX+16,stringY,windowWidth+200,initialPaddleY-20+paddleHeight/2)
    end

    --PADDLE
    love.graphics.push()
    love.graphics.translate(paddleX - paddleXoffset,paddleY)
    love.graphics.setColor(1,0,0)
    love.graphics.circle("fill", 0,0,paddleHeight/3)
    love.graphics.push()
    love.graphics.rotate(paddleRot)
    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("fill",
                            paddleXoffset,
                            -paddleHeight/2, 
                            paddleWidth, 
                            paddleHeight,
                            paddleHeight/2,paddleHeight/2,5)
    love.graphics.pop()
    love.graphics.pop()

    love.graphics.setColor(1,0,0)
    love.graphics.circle("fill", eyeX, eyeY, 3)

    --BALLS
    for ballIndex, ball in ipairs(balls) do 
        love.graphics.setColor(1,1,1)
        love.graphics.circle("fill", ball.x, ball.y, ball.radius)
    end

    --BULLETS
    for bulletIndex, bullet in ipairs(bullets) do
        love.graphics.setColor(1, 0, 0)
        love.graphics.circle('fill', bullet.x, bullet.y, 3)
    end     
end

function input(dt)
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end

    noKeyDown = true

    if love.keyboard.isDown("right") or love.keyboard.isDown("l") then
        paddleRot = paddleRot + paddleRotSpeed*dt
        noKeyDown = false
    end

    if love.keyboard.isDown("left") or love.keyboard.isDown("j") then
        paddleRot = paddleRot - paddleRotSpeed*dt
        noKeyDown = false
    end

    if love.keyboard.isDown("up") or love.keyboard.isDown("i") and paddleJumping == false then
        paddleJumping = true
    end

    bulletTimer = bulletTimer + dt

    if love.keyboard.isDown("space") then
        if bulletTimer >= bulletTimerLimit then
            bulletTimer = 0
            if paddleRot > 0  or (paddleRot == 0 and oldRot < 0) then
                table.insert(bullets, {
                    x = paddleX + paddleWidth - (math.sin(paddleRot+math.pi/2))*paddleWidth,
                    y = paddleY + (math.cos(paddleRot+math.pi/2))*paddleWidth,
                    angle = paddleRot,
                    dir = "positive"
                })
            elseif paddleRot < 0 or (paddleRot == 0 and oldRot > 0) then
                table.insert(bullets, {
                    x = paddleX - (math.sin(paddleRot-math.pi/2))*paddleWidth,
                    y = paddleY - (math.cos(paddleRot+math.pi/2))*paddleWidth,
                    angle = paddleRot,
                    dir = "negative"
                })
            end
        end
    end

    if noKeyDown == true then
        if paddleRot > 0 then
            paddleRot = paddleRot + paddleRotSpeed*dt*0.5
            oldRot = paddleRot
        elseif paddleRot < 0 then
            paddleRot = paddleRot - paddleRotSpeed*dt*0.5
            oldRot = paddleRot
        elseif paddleRot == 0 and paddleJumping == true then
            if oldRot > 0 then
                paddleRot = paddleRot + paddleRotSpeed*dt*0.5
            elseif oldRot < 0 then
                paddleRot = paddleRot - paddleRotSpeed*dt*0.5
            end
        end
    end
end

function love.keypressed(key)
    if key == 'm' then
        if debugVisibility then
            debugVisibility = false
        else
            debugVisibility = true
        end
    end
    
    -- if key == 'space' then
    --     if paddleRot > 0  or (paddleRot == 0 and oldRot < 0) then
    --         table.insert(bullets, {
    --             x = paddleX + paddleWidth - (math.sin(paddleRot+math.pi/2))*paddleWidth,
    --             y = paddleY + (math.cos(paddleRot+math.pi/2))*paddleWidth,
    --             angle = paddleRot,
    --             dir = "positive"
    --         })
    --     elseif paddleRot < 0 or (paddleRot == 0 and oldRot > 0) then
    --         table.insert(bullets, {
    --             x = paddleX - (math.sin(paddleRot-math.pi/2))*paddleWidth,
    --             y = paddleY - (math.cos(paddleRot+math.pi/2))*paddleWidth,
    --             angle = paddleRot,
    --             dir = "negative"
    --         })
    --     end
    -- end
end