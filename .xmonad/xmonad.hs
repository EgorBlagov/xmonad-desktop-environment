-- Core
import XMonad
import qualified XMonad.StackSet as W
import qualified Data.Map as M
import System.Exit
import Graphics.X11.Xlib
import Graphics.X11.ExtraTypes.XF86
import System.IO (Handle, hPutStrLn)
import qualified System.IO
import XMonad.Actions.CycleWS
import Data.List
 


-- Prompts
import XMonad.Prompt
import XMonad.Prompt.Shell
 
-- Actions
import XMonad.Actions.MouseGestures
import XMonad.Actions.UpdatePointer
import XMonad.Actions.GridSelect
 
-- Utils
import XMonad.Util.Run (spawnPipe)
import XMonad.Util.Loggers
import XMonad.Util.EZConfig
import XMonad.Util.Scratchpad
-- Hooks
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.Place
import XMonad.Hooks.EwmhDesktops

-- Layouts
import XMonad.Layout.NoBorders
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.DragPane
import XMonad.Layout.LayoutCombinators hiding ((|||))
import XMonad.Layout.DecorationMadness
import XMonad.Layout.TabBarDecoration
import XMonad.Layout.IM
import XMonad.Layout.Grid
import XMonad.Layout.Spiral
import XMonad.Layout.Mosaic
import XMonad.Layout.LayoutHints

import Data.Ratio ((%))
import XMonad.Layout.ToggleLayouts
import XMonad.Layout.Spacing
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.Gaps
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.SetWMName


layoutChange = "{{path}}/.xmonad/layout.sh" 

dmenuRun = "dmenu_run -h " ++ show {{barHeight}} ++ " -nf " ++ show "{{inactiveThemeColor}}" ++ " -sb " ++ show "{{backgroundColor}}" ++ " -nb black -sf "  ++ show "{{activeThemeColor}}" ++ " -fn " ++ show "{{mainFontNoXftName}}"

customWorkspaces = [{{workspaces}}]

-- tab theme default
tabConfig = defaultTheme {
    activeColor         = "{{mainThemeColor}}"
  , activeBorderColor   = "{{mainThemeColor}}"
  , inactiveColor       = "{{backgroundColor}}"
  , inactiveBorderColor = "{{backgroundColor}}"
  , fontName            = "{{mainFontName}}"
 }

customLayoutHook = gaps [(U, {{barHeight}})] $ toggleLayouts (noBorders Full) $ smartBorders $ tiled ||| Mirror tiled ||| tabbed shrinkText tabConfig 
  where
    tiled = Tall nmaster delta ratio
    nmaster = 1
    delta = 1/100
    ratio = 3/5

xmobarCommand = "xmobar -f " ++ show "{{mainFontName}}" ++  " -B " ++ show "{{backgroundColor}}" ++
                " -F " ++ show "{{mainThemeColor}}" ++ " {{path}}/.xmonad/xmobar.hs"


layoutHard :: String -> String
layoutHard l_name | l_name == "Tall"  = "TL"
                  | l_name == "Mirror Tall" = "MT"
                  | take 6 l_name == "Tabbed" = "TB"
                  | otherwise = show l_name

workspaceFilter :: String -> String
workspaceFilter w_name | elem w_name customWorkspaces == True = w_name
                       | otherwise = ""

main = do
    xmproc <- spawnPipe xmobarCommand
    xmonad $ defaultConfig {
          modMask = mod4Mask
        , terminal = "urxvt"
        , focusFollowsMouse = False
        , borderWidth = 2
        , normalBorderColor = "{{backgroundColor}}"
        , focusedBorderColor = "{{mainThemeColor}}"
        , handleEventHook = fullscreenEventHook
        , layoutHook = customLayoutHook
        , startupHook = setWMName "LG3D"
        , workspaces = customWorkspaces
        
        , logHook = dynamicLogWithPP $ xmobarPP {
            ppOutput = hPutStrLn xmproc
          , ppTitle = xmobarColor "{{inactiveThemeColor}}" "" . shorten 100
          , ppCurrent = xmobarColor "{{activeThemeColor}}" "" . wrap "#" ""
          , ppHidden = xmobarColor "{{mainThemeColor}}" "" . wrap " " ""
          , ppHiddenNoWindows  = xmobarColor "{{inactiveThemeColor}}" "" . wrap " " "" . workspaceFilter
          , ppSep = " "
          , ppLayout = xmobarColor "{{mainThemeColor}}" "" . wrap ":" ":" . layoutHard 
        }

        } `additionalKeys` [
    	((mod4Mask, xK_p), spawn dmenuRun),
    	((mod1Mask, xK_Shift_L), spawn layoutChange),
      ((shiftMask, xK_Alt_L), spawn layoutChange),
      ((mod4Mask, xK_Right), nextWS),
      ((mod4Mask, xK_Left), prevWS),
      ((mod4Mask .|. shiftMask, xK_Right), shiftToNext >> nextWS),
      ((mod4Mask .|. shiftMask, xK_Left), shiftToPrev >> prevWS)]

