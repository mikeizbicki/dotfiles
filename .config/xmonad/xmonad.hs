import XMonad
-- import XMonad.Actions.Volume
import XMonad.Actions.SpawnOn
import XMonad.Util.Dzen
import XMonad.Config.Mate
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.NoBorders
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import System.IO

main = do
    xmproc <- spawnPipe "/usr/bin/xmobar /home/user/.xmobarrc"
    --spawnPipe "trayer --edge top --align right --width 150 --widthtype pixel --height 18 --tint 0 --alpha 255 --transparent true"
    xmonad $ docks $ def
        { terminal = "gnome-terminal"
        , startupHook = composeAll
            [ spawnOn "1" "gnome-terminal"
            ]
        , manageHook = composeAll
            [ manageDocks 
            , isFullscreen --> doFullFloat
            , manageHook def
            ]
			<+> manageDocks
        , layoutHook = avoidStruts $ smartBorders $ layoutHook def
        , modMask = mod4Mask     -- Rebind Mod to the Windows key
        , logHook = dynamicLogWithPP xmobarPP
            { ppOutput = hPutStrLn xmproc
            , ppTitle = xmobarColor "green" "" . shorten 50
            }
        }
        `additionalKeys`
        [ ((0, xK_Print), spawn "mkdir -p img && scrot -fsz ~/img/%FT%H:%M:%S.png")
        ]
