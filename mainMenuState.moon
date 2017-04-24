export class MainMenuState
    new: (tm, setState, states, background) =>
        @background = background
        @setState = setState
        @states = states
        @image = love.graphics.newImage('assets/mainMenu.png')
        @playButton = love.graphics.newImage('assets/playButton.png')
        @helpButton = love.graphics.newImage('assets/helpButton.png')
        @exitButton = love.graphics.newImage('assets/exitButton.png')

    draw: =>
        love.graphics.clear(255, 255, 255)
        love.graphics.draw(@background)
        love.graphics.draw(@image, 1732, 1127)

        love.graphics.draw(@playButton, 2113, 1622)
        love.graphics.draw(@helpButton, 2091, 1930)
        love.graphics.draw(@exitButton, 2063, 2156)

    update: (dt) =>
        TEsound.volume('blackHole', 0.0)

    keypressed: (key) =>
        nil
        --@states['play']\reset()
        --@setState('play')

    inButton: (x, y, button, xx, yy) =>
        xx > x and xx < x + button\getWidth() and yy > y and yy < y + button\getHeight()

    mousepressed: (x, y, button) =>
        if self\inButton(2113, 1622, @playButton, x, y)
            TEsound.play('assets/sound/click.wav')
            @setState('play')
        if self\inButton(2091, 1930, @helpButton, x, y)
            TEsound.play('assets/sound/click.wav')
            @setState('help')
        if self\inButton(2063, 2156, @exitButton, x, y)
            love.event.quit()
