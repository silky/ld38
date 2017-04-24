require 'score'

export class GameOverState
    new: (tm, setState, states, background) =>
        @background = background
        @setState = setState
        @states = states
        @image = love.graphics.newImage('assets/gameOver.png')
        @clickToReplay = love.graphics.newImage('assets/clickToReplay.png')
        @button = love.graphics.newImage('assets/menuButton.png')
        @score = 0
        @scoreDisplay = ScoreDisplay()

    draw: =>
        love.graphics.clear(255, 255, 255)
        love.graphics.draw(@background)
        love.graphics.draw(@image, 2370, 1500, 0, 1, 1,
            @image\getWidth() / 2, @image\getHeight() / 2)
        love.graphics.draw(@clickToReplay, 2370, 2000, 0, 1, 1,
            @clickToReplay\getWidth() / 2, @clickToReplay\getHeight() / 2)
        love.graphics.draw(@button, 2140, 2612)
        @scoreDisplay\draw(math.floor(@score), 2150, 2557)

    update: (dt) =>
        alpha = dt * 1.0
        TEsound.volume('blackHole', TEsound.findVolume('blackHole') * (1 - alpha))

    keypressed: (key) =>
        nil
        --@states['play']\reset()
        --@setState('play')

    inButton: (x, y, button, xx, yy) =>
        xx > x and xx < x + button\getWidth() and yy > y and yy < y + button\getHeight()

    mousepressed: (x, y, button) =>
        TEsound.play('assets/sound/click.wav')
        if self\inButton(2140, 2612, @button, x, y)
            @states['play']\reset()
            @setState('mainMenu')
            return
        @states['play']\reset()
        @setState('play')
