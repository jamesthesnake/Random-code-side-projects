using Javis

function ground(args...)
    background("white")
    sethue("black")
end

astar(args...) = star(O, 50)
acirc(args...) = circle(Point(100, 100), 50)

vid = Video(500, 500)
action_list = [
    BackgroundAction(1:100, ground),
    Action(1:100, morph(astar, acirc; action = :fill)),
]

javis(vid, action_list, pathname = "morph.gif")

