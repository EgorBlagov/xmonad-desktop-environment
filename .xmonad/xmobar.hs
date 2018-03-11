Config { 
    bgColor = "{{backgroundColor}}",
    fgColor = "{{mainThemeColor}}",
    lowerOnStart = True,
    position =  Static { xpos = 0 , ypos = 0, width = {{screenWidth}}, height = {{barHeight}} },
    commands = [        
          Run Date "%d.%m.%y %H:%M:%S" "date" 10
        , Run Kbd [ ("us", "US")
                  , ("ru", "RU")
                  ]
        , Run Com "/bin/bash" ["-c", "{{path}}/.xmonad/volume.sh"] "vol" 1
        , Run Battery [ "--template" , "BAT:<left><fc={{activeThemeColor}}>%</fc><acstatus>"
                      , "--Low"      , "10"        -- units: %
                      , "--High"     , "80"        -- units: %
                      , "--low"      , "red"
                      , "--normal"   , "orange"
                      , "--high"     , "green"
                      , "--"         
                      , "-O"         , "^"
                      , "-o"         , " "
                      , "-i"         , " "
                      ] 50 
        , Run StdinReader
    ],
    sepChar = "%",
    alignSep = "}{",
    template = "%StdinReader% }{<fc={{activeThemeColor}}>%kbd%</fc> %battery% VOL:%vol% <fc={{mainThemeColor}}>%date%</fc> "
}

