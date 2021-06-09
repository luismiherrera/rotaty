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
    paddleRotSpeed = 0.2
    initialPaddleYSpeed = 7
    paddleYSpeed = initialPaddleYSpeed
    paddleJumping = false
    stringRot = 0
    amplitude = 0.3
    
    balls = {
        {
            x = math.random(10, windowWidth - 10),
            y = -10,
            speed = math.random(50, 170)
        },
        {
            x = math.random(10, windowWidth - 10),
            y = -10,
            speed = math.random(50, 170)
        }
    }

    killed = love.audio.newSource("audio/goal.wav", "static")
end

function love.update(dt)
    input()
    
    --jumping
    if paddleJumping == true then
        paddleY = paddleY - paddleYSpeed
        if paddleYSpeed > 0 then 
            paddleYSpeed = paddleYSpeed - 0.3
        else 
            if paddleY < initialPaddleY then
                paddleYSpeed = paddleYSpeed - 0.3
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
        stringRot = stringRot + 0.3 --frequency
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
    stringRot = stringRot + 0.2 -- frequency

    --balls falling
    for ballIndex, ball in ipairs(balls) do
        ball.y = ball.y + ball.speed * dt

        -- checking collission
        if ball.y > paddleY and ball.y < paddleY + paddleHeight then
            if ball.x > paddleX and ball.x < paddleX + paddleWidth then
                collission = true
                love.audio.play(killed)
            end
        else
            collission = false
        end
        
        -- reseting vertical position when ball reaches the ground
        if ball.y > windowHeight or collission then
           -- delete ball
            ball.y = -10
            ball.x = math.random(10, windowWidth - 10)
        end
    end
end

function love.draw()
    --DEBUG
    love.graphics.print(tostring(paddleRot), 10, 10)
    love.graphics.print(tostring(amplitude), 10, 20)
    --floor
    --love.graphics.line(0,initialPaddleY+paddleHeight/2,windowWidth,initialPaddleY+paddleHeight/2)
    if paddleJumping == false then
        love.graphics.line(-100,initialPaddleY-20+paddleHeight/2,paddleX,paddleY+paddleHeight/2)
        love.graphics.line(paddleX,paddleY+paddleHeight/2,windowWidth+200,initialPaddleY-20+paddleHeight/2)
    else
        -- love.graphics.line(-100,initialPaddleY-20+paddleHeight/2,windowWidth,initialPaddleY-20+paddleHeight/2)
        love.graphics.line(-100,initialPaddleY-20+paddleHeight/2,paddleX,stringY)
        love.graphics.line(paddleX,stringY,windowWidth+200,initialPaddleY-20+paddleHeight/2)
    end

    -- paddle
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
    
    -- balls
    -- for ballIndex, ball in ipairs(balls) do 
    --     love.graphics.circle("fill", ball.x, ball.y, 10)
    -- end
end

function input()
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end

    noKeyDown = true

    if love.keyboard.isDown("right") then
        paddleRot = paddleRot + paddleRotSpeed
        noKeyDown = false
    end

    if love.keyboard.isDown("left") then
        paddleRot = paddleRot - paddleRotSpeed
        noKeyDown = false
    end

    if love.keyboard.isDown("up") and paddleJumping == false then
        paddleJumping = true
    end

    if noKeyDown == true then
        if paddleRot > 0 then
            paddleRot = paddleRot + paddleRotSpeed*0.5
            oldRot = paddleRot
        elseif paddleRot < 0 then
            paddleRot = paddleRot - paddleRotSpeed*0.5
            oldRot = paddleRot
        elseif paddleRot == 0 and paddleJumping == true then
            if oldRot > 0 then
                paddleRot = paddleRot + paddleRotSpeed*0.5
            elseif oldRot < 0 then
                paddleRot = paddleRot - paddleRotSpeed*0.5
            end
        end
    end
end