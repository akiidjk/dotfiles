-- Setup curves
hl.curve("wind", {
    points = {
        { 0.05, 0.9 },
        { 0.1,  1.05 }
    },
    type = "bezier"
})
hl.curve("winIn", {
    points = {
        { 0.1, 1.1 },
        { 0.1, 1.1 }
    },
    type = "bezier"
})
hl.curve("winOut", {
    points = {
        { 0.3, -0.3 },
        { 0,   1 }
    },
    type = "bezier"
})
hl.curve("liner", {
    points = {
        { 1, 1 },
        { 1, 1 }
    },
    type = "bezier"
})
hl.curve("almostLinear", {
    points = {
        { 0.5,  0.5 },
        { 0.75, 1 }
    },
    type = "bezier"
})


-- Setup animations
hl.animation({
    leaf = "windows",
    speed = 6,
    bezier = "wind",
    style = "slide",
    enabled = true
})

hl.animation({
    leaf = "windowsIn",
    speed = 6,
    bezier = "winIn",
    style = "slide",
    enabled = true
})

hl.animation({
    leaf = "windowsOut",
    speed = 5,
    bezier = "winOut",
    style = "slide",
    enabled = true
})

hl.animation({
    leaf = "windowsMove",
    speed = 5,
    bezier = "wind",
    style = "slide",
    enabled = true
})

hl.animation({
    leaf = "border",
    speed = 1,
    bezier = "liner",
    enabled = true
})

hl.animation({
    leaf = "borderangle",
    speed = 30,
    bezier = "liner",
    loop = true,
    enabled = true
})

hl.animation({
    leaf = "layers",
    speed = 6,
    bezier = "wind",
    style = "popin 90%",
    enabled = true
})

hl.animation({
    leaf = "layersIn",
    speed = 6,
    bezier = "winIn",
    style = "popin 90%",
    enabled = true
})

hl.animation({
    leaf = "layersOut",
    speed = 5,
    bezier = "winOut",
    style = "popin 90%",
    enabled = true
})

hl.animation({
    leaf = "workspaces",
    speed = 5,
    bezier = "wind",
    enabled = true
})



hl.animation({
    leaf = "fadeIn",
    speed = 1.73,
    bezier = "almostLinear",
    enabled = true
})

hl.animation({
    leaf = "fadeOut",
    speed = 1.46,
    bezier = "almostLinear",
    enabled = true
})

hl.animation({
    leaf = "fade",
    speed = 3.03,
    bezier = "almostLinear",
    enabled = true
})
