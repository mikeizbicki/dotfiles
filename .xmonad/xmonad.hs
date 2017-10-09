import XMonad
-- import XMonad.Actions.Volume
import XMonad.Util.Dzen
import XMonad.Config.Mate
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import System.IO

main = do
    xmproc <- spawnPipe "/usr/bin/xmobar /home/user/.xmobarrc"
    xmonad $ docks $ def
        { terminal = "uxterm"
        , manageHook = composeAll
            [ manageDocks 
            , isFullscreen --> doFullFloat
            , manageHook def
            ]
        , layoutHook = avoidStruts  $  layoutHook def
        , modMask = mod4Mask     -- Rebind Mod to the Windows key
        , logHook = dynamicLogWithPP xmobarPP
            { ppOutput = hPutStrLn xmproc
            , ppTitle = xmobarColor "green" "" . shorten 50
            }
        }
        `additionalKeys`
        [ ((mod4Mask .|. shiftMask, xK_z), spawn "xscreensaver-command -lock")
        , ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s")
        , ((0, xK_Print), spawn "scrot")
--         , ((0, 0x1008ff11), spawn "amixer set Master 10%-" >>= alert)
--         , ((0, 0x1008ff13), spawn "amixer set Master 10%+" >>= alert)
--         , ((0, 0x1008ff12), spawn "amixer set Master toggle" >>= alert)
        ]

alert :: String -> X ()
alert = dzenConfig centered 
    where
        centered = onCurr (center 150 66)
               >=> font "-*-helvetica-*-r-*-*-64-*-*-*-*-*-*-*"
               >=> addArgs ["-fg", "#80c0ff"]
               >=> addArgs ["-bg", "#000040"]
