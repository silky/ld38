lume = require 'lib.lume'

class Planet
    new: (image, x, y, ox, oy, radius, mass) =>
        @image = image
        @x = x
        @y = y
        @ox = ox
        @oy = oy
        @radius = radius / 2
        @mass = mass
        @dx = 0
        @dy = 0
        @rot = lume.random(0, 2 * math.pi)

    draw: =>
        love.graphics.draw(@image, @x, @y, @rot, 1, 1, @ox, @oy)

    update: (dt) =>
        len = lume.distance(@dx, @dy, 0, 0)
        if len > 0.0
            @dx -= 20.0 * dt * @dx / len
            @dy -= 20.0 * dt * @dy / len

        @x += dt * @dx
        @y += dt * @dy
        if @x < 754 + @radius
            @dx *= -0.9
            @x = 754 + @radius
            return true
        if @x > 3790 - @radius
            @dx *= -0.9
            @x = 3790 - @radius
            return true
        if @y < 583 + @radius
            @dy *= -0.9
            @y = 583 + @radius
            return true
        if @y > 2910 - @radius
            @dy *= -0.9
            @y = 2910 - @radius
            return true
        false

export class PlanetType
    new: (filename, radius, mass) =>
        @image = love.graphics.newImage(filename)
        @ox, @oy = @image\getWidth() / 2, @image\getHeight() / 2
        @radius = radius
        @mass = 1--mass

    create: (x, y) =>
        Planet(@image, x, y, @ox, @oy, @radius, @mass)

