Config { 
    bgColor = "{{backgroundColor}}",
    fgColor = "{{mainThemeColor}}",
    lowerOnStart = True,
    position =  Static { xpos = 0 , ypos = 0, width = {{screenWidth}}, height = {{barHeight}} },
    commands = [        
          Run Date "%d.%m.%y %H:%M:%S" "date" 10
        , Run StdinReader
    ],
    sepChar = "%",
    alignSep = "}{",
    template = "%StdinReader% }{<fc={{activeThemeColor}}>%date%</fc> "
}

