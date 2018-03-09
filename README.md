# Xmonad theme
### Installation
```
git clone https://github.com/EgorBlagov/xmonad-desktop-environment.git
```
Take a look at ```CustomTheme.txt``` file to customize path, colors and other parameters
```
cd xmonad-desktop-environment
python3 install.py
```
 
### Tips
- Patched dmenu is required to adjust dmenu height. https://tools.suckless.org/dmenu/patches/line-heighte 
- Customized variables are replaced with variables from config ('CustomTheme.txt'). Script searches for mustaches (```{{varname}}```) in files and replaces all occurrences.
