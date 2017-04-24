lume = require 'lib/lume'
flux = require 'lib/flux'
require 'lib/TEsound'
require 'planet'
require 'score'

local transformMouse

gravConstant = 2000000.0

export class PlayState
    new: (tm, setState, states, background) =>
        @hitSounds = ['assets/sound/hit' .. i .. '.wav' for i = 0,22]
        TEsound.playLooping('assets/sound/blackHole2.wav', 'blackHole', nil, 0.0)

        @background = background

        @setState = setState
        @states = states

        @blackHoleShader = love.graphics.newShader("shaders/blackHole.frag")
        @canvas = love.graphics.newCanvas()
        @time = 0

        transformMouse = tm

        @planetTypes = {
            PlanetType('assets/planet1_final.png', 115, 2)
            PlanetType('assets/planet2_final.png', 125, 2.5)
            --planet3: PlanetType('assets/planet3_final.png', 30, 1)
            PlanetType('assets/planet4_final.png', 170, 3)
            PlanetType('assets/planet5_final.png', 50, 1.5)
            PlanetType('assets/planet6_final.png', 90, 1.75)
            PlanetType('assets/planet7_final.png', 150, 2.75)
            PlanetType('assets/planet8_final.png', 100, 1.9)
            PlanetType('assets/planet9_final.png', 175, 3.5)
        }

        @dots = {
            love.graphics.newImage('assets/dot1.png')
            love.graphics.newImage('assets/dot2.png')
            love.graphics.newImage('assets/dot3.png')
            love.graphics.newImage('assets/dot4.png')
            love.graphics.newImage('assets/dot5.png')
            love.graphics.newImage('assets/dot6.png')
        }
        @redDots = {
            love.graphics.newImage('assets/dotRed1.png')
            love.graphics.newImage('assets/dotRed2.png')
            love.graphics.newImage('assets/dotRed3.png')
            love.graphics.newImage('assets/dotRed4.png')
            love.graphics.newImage('assets/dotRed5.png')
            love.graphics.newImage('assets/dotRed6.png')
        }

        self\reset()

        @scoreDisplay = ScoreDisplay()

    spawnPlanets: =>
        for i = 2, @spawnNumber + 1--_, planet in pairs(@planetTypes)
            planet = lume.randomchoice(@planetTypes)
            x, y = @blackHole.x, @blackHole.y
            intersecting = false
            while lume.distance(x, y, @blackHole.x, @blackHole.y) < 1000 or intersecting
                x = lume.random(planet.radius + 754, 3790 - planet.radius)
                y = lume.random(planet.radius + 583, 2910 - planet.radius)
                intersecting = false
                for _, other in pairs(@planets)
                    if lume.distance(x, y, other.x, other.y) < planet.radius + other.radius
                        intersecting = true
                        break

            @planets[i] = planet\create(x, y)

    reset: =>
        star = PlanetType('assets/player_final.png', 115, 5)

        blackHole = PlanetType('assets/blackHole_final.png', 290, 10)
        blackHole.mass = 3

        @blackHole = blackHole\create(4208 / 2, 3146 / 2)

        x, y = @blackHole.x, @blackHole.y
        while lume.distance(x, y, @blackHole.x, @blackHole.y) < 1000
            x = lume.random(star.radius * 2 + 902, 3954 - star.radius)
            y = lume.random(star.radius * 2 + 715, 3003 - star.radius)
        @star = star\create(x, y)
        @planets = {@star}

        
        @spawnNumber = 3
        self\spawnPlanets()

        @score = 0
        if @scoreTween != nil
            @scoreTween\stop()
        @scoreTween = nil
        @scoreTarget = 0

        @state = 'aiming'
        @simulation = false

    draw: =>
        love.graphics.setCanvas(@canvas)
        love.graphics.clear(255, 255, 255)
        love.graphics.draw(@background)

        for _, planet in pairs(@planets)
            planet\draw()
        @blackHole\draw()

        switch @state
            when 'aiming'
                copy = lume.clone(self)
                copy.planets = {}
                for id, planet in pairs(@planets)
                    copy.planets[id] = lume.clone(planet)
                    setmetatable(copy.planets[id], getmetatable(planet))
                copy.scoreTween = nil
                copy.star = copy.planets[1]
                copy.simulation = true
                copy.state = 'running'
                copy.numPlanetsThisTurn = 0

                x, y = transformMouse(love.mouse.getPosition())
                dist = lume.distance(x, y, @star.x, @star.y)
                if dist > @star.radius
                    dx, dy = x - copy.star.x, y - copy.star.y
                    if dist > 750
                        dx, dy = 750 * dx / dist, 750 * dy / dist
                        dist = 750
                    d = dist - copy.star.radius
                    factor = d / dist
                    dx, dy = dx * factor, dy * factor
                    copy.star.dx, copy.star.dy = dx, dy

                for i = 1,50
                    for _ = 0,40
                        self.update(copy, 0.0025)
                    
                    for id, planet in pairs(@planets)
                        copyPlanet = copy.planets[id]
                        if copyPlanet != null
                            x, y = copyPlanet.x, copyPlanet.y
                            if lume.distance(x, y, planet.x, planet.y) > planet.radius
                                local dot
                                if id == 1
                                    dot = @redDots[(i % 6) + 1]
                                else
                                    dot = @dots[(i % 6) + 1]
                                love.graphics.draw(dot, x, y, 0, 1, 1,
                                    dot\getWidth() / 2, dot\getHeight() / 2)

        @scoreDisplay\draw(math.floor(@score), 825, 2722)

        love.graphics.pop()
        love.graphics.setCanvas()
        width, height = love.graphics.getDimensions()
        @blackHoleShader\send('aspect', width / height)
        love.graphics.setShader(@blackHoleShader)
        love.graphics.draw(@canvas)
        love.graphics.setShader()
        love.graphics.push()


    update: (dt) =>
        @time += dt
        @blackHoleShader\send('time', @time)

        if @state == 'running'
            times = 1
            if not @simulation
                dt /= 3.0
                times = 9
            for _ = 1,times
                toRemove = {}
                done = true

                blackHoleVolume = 0.0
                for id, planet in pairs(@planets)
                    dist = lume.distance(planet.x, planet.y, @blackHole.x, @blackHole.y)
                    if dist < 1000
                        blackHoleVolume = math.max(1 - dist / 1000, blackHoleVolume)
                    if dist < 75
                        toRemove[#toRemove + 1] = id
                    k = 1
                    if id == 1
                        k = 2
                    accel = k * dt * @blackHole.mass * gravConstant / (dist * dist)
                    planet.dx += accel * (@blackHole.x - planet.x) / dist
                    planet.dy += accel * (@blackHole.y - planet.y) / dist

                    if planet\update(dt) and not @simulation
                        TEsound.play(@hitSounds)

                    if not (math.abs(planet.dx) < 1 and math.abs(planet.dy) < 1)
                        done = false

                if not @simulation
                    TEsound.volume('blackHole', blackHoleVolume)

                if done
                    num = 0
                    for _, _ in pairs(@planets)
                        num += 1
                    if num == 1 and not @simulation
                        @spawnNumber += 3
                        self\spawnPlanets()
                    @state = 'aiming'
                    if @numPlanetsThisTurn == 0
                        if @scoreTarget >= 300
                            if @scoreTween != nil
                                @scoreTween\stop()
                            @scoreTarget -= 300
                            @scoreTween = flux.to(self, 2, { score: @scoreTarget })\ease('circout')


                for _, id in ipairs(toRemove)
                    if id == 1 and not @simulation
                        @states['gameOver'].score = 0
                        flux.to(@states['gameOver'], 3, { score: @scoreTarget })\ease('circout')
                        @setState('gameOver')
                        --TEsound.play({'assets/sound/die0.ogg', 'assets/sound/die1.ogg'}, '',
                        --    0.5)
                        return
                    else
                        if @scoreTween != nil
                            @scoreTween\stop()
                        @scoreTarget += 1000 * math.pow(3, @numPlanetsThisTurn)
                        @scoreTween = flux.to(self, 2, { score: @scoreTarget })\ease('circout')
                        @numPlanetsThisTurn += 1
                    @planets[id] = nil

                for idA, a in pairs(@planets)
                    for idB, b in pairs(@planets)
                        if idA > idB
                            dist = lume.distance(a.x, a.y, b.x, b.y)
                            if dist < a.radius + b.radius
                                totalMass = a.mass + b.mass

                                dota = (a.dx - b.dx) * (a.x - b.x) + (a.dy - b.dy) * (a.y - b.y)
                                adx = a.dx - (2 * b.mass / totalMass) * (dota / (dist * dist)) *
                                    (a.x - b.x)
                                ady = a.dy - (2 * b.mass / totalMass) * (dota / (dist * dist)) *
                                    (a.y - b.y)
                                dotb = (b.dx - a.dx) * (b.x - a.x) + (b.dy - a.dy) * (b.y - a.y)
                                bdx = b.dx - (2 * a.mass / totalMass) * (dotb / (dist * dist)) *
                                    (b.x - a.x)
                                bdy = b.dy - (2 * a.mass / totalMass) * (dotb / (dist * dist)) *
                                    (b.y - a.y)
                                a.dx, a.dy, b.dx, b.dy = adx, ady, bdx, bdy

                                d = a.radius + b.radius - dist + 1
                                dxx, dyy = a.x - b.x, a.y - b.y
                                a.x += d / 2 * dxx / dist
                                a.y += d / 2 * dyy / dist
                                b.x -= d / 2 * dxx / dist
                                b.y -= d / 2 * dyy / dist

                                if not @simulation
                                    TEsound.play(@hitSounds)
        else
            TEsound.volume('blackHole', 0)

    keypressed: (key) =>
        nil

    mousepressed: (x, y, button) =>
        switch @state
            when 'aiming'
                dist = lume.distance(x, y, @star.x, @star.y)
                if dist > @star.radius
                    dx, dy = x - @star.x, y - @star.y
                    if dist > 750
                        dx, dy = 750 * dx / dist, 750 * dy / dist
                        dist = 750
                    d = dist - @star.radius
                    factor = d / dist
                    dx, dy = dx * factor, dy * factor
                    @star.dx, @star.dy = dx, dy
                    @numPlanetsThisTurn = 0
                    TEsound.play(@hitSounds)
                    @state = 'running'

