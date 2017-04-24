local scoreImage
numerals = {}

export class ScoreDisplay
    new: () =>
        if scoreImage == nil
            scoreImage = love.graphics.newImage('assets/score.png')
            for n = 0,9
                numerals[tostring(n)] = love.graphics.newImage('assets/numeral' .. n .. '.png')

    draw: (score, x, y) =>
        love.graphics.draw(scoreImage, x, y, -math.pi/2)

        score = tostring(score)

        x += scoreImage\getHeight() + 20
        for i = 1,#score
            c = score\sub(i, i)
            image = numerals[c]
            love.graphics.draw(image, x, y, -math.pi/2)

            x += image\getHeight()
