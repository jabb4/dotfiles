#!/bin/bash
# AutoRaise launcher — runs the CLI binary inside the AutoRaise.app bundle
# with declarative args. No menubar, no Preferences GUI, no plist involvement.
# Args go into NSArgumentDomain and win over any persisted defaults.
# See: https://github.com/sbmpost/AutoRaise

options=(
    -pollMillis 20         # 20ms poll cadence (minimum). Lower = snappier, more CPU.
    -focusDelay 1          # focus hovered window on next poll (requires FOCUS_FIRST build)
    -delay 1               # raise hovered window on next poll (1 = no extra wait)
    -requireMouseStop false # don't wait for mouse to settle — react mid-motion
    -mouseDelta 0.0        # re-evaluate on every poll (no movement threshold)
    -disableKey control    # hold control to temporarily pause AutoRaise
)

# NOTE: must be Contents/Resources/AutoRaise (the CLI worker), NOT Contents/MacOS/AutoRaise
# (the GUI parent). The GUI parent ignores args and spawns its own worker from GUI state.
exec /Applications/AutoRaise.app/Contents/Resources/AutoRaise "${options[@]}"
