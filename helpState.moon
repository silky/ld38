export class HelpState
    new: (tm, setState, states, background) =>
        @background = background
        @setState = setState
        @states = states
        @image = love.graphics.newImage('assets/instructions.png')
        @button = love.graphics.newImage('assets/menuButton.png')

    draw: =>
        love.graphics.clear(255, 255, 255)
        love.graphics.draw(@background)
        love.graphics.draw(@image, 1732, 1127)

        love.graphics.draw(@button, 886, 759)

    update: (dt) =>
        TEsound.volume('blackHole', 0.0)

    keypressed: (key) =>
        nil
        --@states['play']\reset()
        --@setState('play')

    mousepressed: (x, y, button) =>
        TEsound.play('assets/sound/click.wav')
        @setState('mainMenu')
