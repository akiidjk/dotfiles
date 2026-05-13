hl.layer_rule({
    match = {
        title = "vicinae"
    },
    ignore_alpha = 0,
    blur = true
})

hl.exec_cmd("vicinae server");

hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd("vicinae toggle"))
