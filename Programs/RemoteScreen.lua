term.clear()
local w, h = term.getSize()
local box = require("pixelbox_lite").new(term.current())

for x = 1, w * 2, 1 do
    for y = 1, h * 3, 1 do
        local col
        if x % 2 == 1 and y % 2 == 0 then
            col = colors.white
        else
            col = colors.blue
        end
        box:set_pixel(x, y, col)
    end
end

box:render()

term.setTextColor(colors.white)
term.setCursorPos(1,18)
print("guhhhhhhhh")