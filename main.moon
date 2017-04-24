lume = require 'lib/lume'
flux = require 'lib/flux'
scaleinator = require 'lib/scaleinator'
require 'lib/TEsound'

require 'playState'
require 'gameOverState'
require 'mainMenuState'
require 'helpState'

scale = scaleinator.create()
transformMouse = (x, y) ->
    bw, bh = scale\getBox()
    tx, ty = scale\getTranslation()
    (x - tx) * 4208 / bw, (y - ty) * 3146 / bh
states = {}
currentState = 'mainMenu'

setState = (_, state) ->
    print(state)
    currentState = state

love.load = ->
    math.randomseed(love.timer.getTime())

    --TEsound.playLooping('assets/sound/the-snow-is-dancing.mp3', 0.7)

    love.window.setFullscreen(true)

    scale\newMode("main", 1.33757, 1)
    width, height = love.graphics.getDimensions()
    scale\update(width, height)

    background = love.graphics.newImage('assets/desk.png')
    states['mainMenu'] = MainMenuState(transformMouse, setState, states, background)
    states['play'] = PlayState(transformMouse, setState, states, background)
    states['gameOver'] = GameOverState(transformMouse, setState, states, background)
    states['help'] = HelpState(transformMouse, setState, states, background)

love.resize = (w, h) ->
    scale\update(w, h)

love.draw = ->
    love.graphics.push()
    bw, bh = scale\getBox()
    tx, ty = scale\getTranslation()
    love.graphics.translate(tx, ty)
    love.graphics.scale(bw / 4208, bh / 3146)

    states[currentState]\draw()

    love.graphics.pop()

love.update = (dt) ->
    TEsound.cleanup()
    flux.update(dt)
    states[currentState]\update(dt)

love.keypressed = (key) ->
    states[currentState]\keypressed(key)

love.mousepressed = (x, y, button) ->
    x, y = transformMouse(x, y)
    states[currentState]\mousepressed(x, y, button)
