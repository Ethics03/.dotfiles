-- Extended desktop: external display on the left, laptop on the right.
local laptop = "eDP-1"
local external = "HDMI-A-1"
local laptopScale = 1.5
local externalScale = 1.25

local function setExtended()
    hl.monitor({
        output = laptop,
        mode = "preferred",
        position = "auto-right",
        scale = laptopScale,
        mirror = "",
        disabled = false,
    })
    hl.monitor({
        output = external,
        mode = "preferred",
        position = "auto-left",
        scale = externalScale,
        mirror = "",
        disabled = false,
    })
end

setExtended()

-- Fallback for other displays.
hl.monitor({ output = "", mode = "preferred", position = "auto-left", scale = "auto" })

-- Bind workspaces to enabled desktops, using the sole desktop in mirror mode too.
local previousLaptopTarget, previousExternalTarget
local function updateWorkspaceRules()
    local desktops = {}
    local fallback
    for _, monitor in ipairs(hl.get_monitors()) do
        if not monitor.is_mirror then
            desktops[monitor.name] = true
            fallback = fallback or monitor.name
        end
    end
    fallback = desktops[laptop] and laptop or (desktops[external] and external or fallback)
    if not fallback then
        return
    end

    local laptopTarget = desktops[laptop] and laptop or fallback
    local externalTarget = desktops[external] and external or fallback
    if laptopTarget == previousLaptopTarget and externalTarget == previousExternalTarget then
        return
    end
    previousLaptopTarget, previousExternalTarget = laptopTarget, externalTarget

    for workspace = 1, 10 do
        hl.workspace_rule({
            workspace = tostring(workspace),
            monitor = workspace <= 5 and laptopTarget or externalTarget,
            default = workspace == 1 or (workspace == 6 and laptopTarget ~= externalTarget),
            persistent = true,
        })
    end
end

updateWorkspaceRules()
hl.on("hyprland.start", updateWorkspaceRules)
hl.on("monitor.layout_changed", updateWorkspaceRules)

-- Mirrored outputs live on the source monitor's mirrors list.
local function activeOutputs()
    local outputs = {}
    for _, monitor in ipairs(hl.get_monitors()) do
        outputs[monitor.name] = monitor
        for _, mirror in ipairs(monitor.mirrors) do
            outputs[mirror.name] = mirror
        end
    end
    return outputs
end

local function notify(text)
    hl.notification.create({ text = text, timeout = 3000 })
end

local function restoreOutputs()
    -- This build restores disabled outputs reliably when monitor rules reload.
    hl.exec_cmd("hyprctl reload")
end

hl.bind("SUPER + CTRL + M", function()
    local outputs = activeOutputs()
    if not outputs[laptop] or not outputs[external] then
        notify("All displays must be connected and enabled; restoring extended layout")
        restoreOutputs()
        return
    end

    if outputs[external].is_mirror then
        setExtended()
    else
        -- The mirrored image uses the source's scale, so match the external desktop.
        hl.monitor({ output = laptop, scale = externalScale })
        hl.monitor({
            output = external,
            mode = "preferred",
            position = "0x0",
            scale = externalScale,
            mirror = laptop,
        })
    end
end, { description = "Toggle external monitor mirroring" })

local function toggleOutput(output)
    local outputs = activeOutputs()
    if not outputs[output] then
        restoreOutputs()
        return
    end

    local hasOtherOutput = false
    for name in pairs(outputs) do
        if name ~= output then
            hasOtherOutput = true
            break
        end
    end
    if not hasOtherOutput then
        notify("Can't disable the last active display")
        return
    end

    if outputs[external] and outputs[external].is_mirror then
        setExtended()
    end
    hl.monitor({ output = output, disabled = true })
end

hl.bind("SUPER + CTRL + O", function()
    toggleOutput(external)
end, { description = "Disable or restore the external monitor" })

hl.bind("SUPER + CTRL + I", function()
    toggleOutput(laptop)
end, { description = "Disable or restore the laptop display" })
