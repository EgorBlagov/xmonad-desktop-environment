import os
import sys
import shutil
import fileinput
import re
import subprocess

def files_in_dir(dirname='.'):
    result = []
    for entry in os.listdir(dirname):
        if os.path.isdir(entry):
            if entry == '.git':
                continue
            result += files_in_dir(entry)
        else:
            newentry = os.path.join(dirname,entry)
            if newentry.startswith('./'):
                newentry = newentry[2:]
            result.append(newentry)
    return result

def check_version():
    if sys.version_info.major < 3:
        raise Exception("Required python 3 or greater")

def check_required(required):
    all_good = True
    for soft in required:
        try:
            if len(shutil.which(soft)) != 0:
                print('\t%s is ok' % soft)
        except Exception as e: 
                print('\t%s is not installed' % soft)
                all_good = False
    if not all_good:
        raise Exception('Cannot continue')
    

def read_theme(theme_name):
    result = {}
    with open(theme_name, 'r') as file:
        for line in file:
            if line.isspace() or len(line) == 0:
                continue
            if line[0] == "#":
                #its a commment
                continue
            var = [x.strip() for x in line.split('=',1)]
            result[var[0]] = var[1]
    return result

def get_install_dir(config):
    return config['path'].replace('~', os.path.expanduser('~'))    

def cleanup(files_list, dest_dir):
    for file in files_list:
        destination = os.path.join(dest_dir, file)
        if os.path.exists(destination):
            os.remove(destination)

            if len(os.listdir(os.path.dirname(destination))) == 0:
                os.rmdir(os.path.dirname(destination))

def copy_files(files_list, dest_dir):
    for file in files_list:
        destination = os.path.join(dest_dir, file)
        if os.path.exists(destination):
            raise Exception('file %s already exists in installation path' % os.path.basename(file))

        if not os.path.exists(os.path.dirname(destination)):
            os.makedirs(os.path.dirname(destination))

        shutil.copy2(file, destination)

def preprocess(files_list, dest_dir, config):
    for file in files_list:
        if os.path.splitext(file)[1] in ['.' + ignored for ignored in ignore_preprocessing]:
            continue

        destination = os.path.join(dest_dir, file)
        if not os.path.exists(destination):
            raise Exception('Cannot preprocess file %s. It doesn\'t exists' % os.path.basename(file))

        with fileinput.FileInput(destination, inplace=True) as working_file:
            for line in working_file:        
                vars = re.findall("\{\{[^}]*\}\}", line)
                newline = line
                for var in vars:
                    if var[2:-2] not in config.keys():
                        raise Exception('found undeclared variable %s in %s' % (var, os.path.basename(file)))
                    newline = re.sub(var, config[var[2:-2]], newline)
                print(newline,end='')

def bash_exec(command, input_file=None):
    try:
        if input_file is not None:
            with open(input_file, 'rb') as input_data:
                print(subprocess.check_output(command.split(), input = input_data.read()).decode('UTF-8'), end='')            
        else:
            print(subprocess.check_output(command.split()).decode('UTF-8'), end='')
    except Exception as e:
        raise Exception('error during command %s\n%s ' % (command,e))

def dmenu_patched_install(patch_name):
    print('installing patched dmenu (patch adds height parameter')
    if not os.path.exists(patch_name):
        raise Exception('patch %s doesn\'t exists' % patch_name)

    curdir = os.path.dirname(os.path.abspath(__file__))
    temp = 'temp'
    if os.path.exists(temp):
        shutil.rmtree(temp)

    os.makedirs(temp)
    os.chdir(temp)
    bash_exec('git clone https://git.suckless.org/dmenu')
    os.chdir('dmenu')
    bash_exec('patch -p1','../../'+patch_name)
    print('need sudo to install dmenu')
    bash_exec('sudo make clean install')
    os.chdir(curdir)
    shutil.rmtree(temp)

#main
check_version()
print('python version ok')

script_name = os.path.basename(__file__)
theme_name = "CustomTheme.txt"
dmenu_patchname = 'dmenu-lineheight-4.7.diff'
required = ['xmonad', 'xmobar', 'compton', 'feh', 'urxvt']
ignore_copy = [script_name, theme_name, dmenu_patchname, 'README.md']
ignore_preprocessing = ['jpg', 'svg', 'png', 'ttf']

check_required(required)
print('required ok')

dmenu_patched_install(dmenu_patchname)

config = read_theme(theme_name)
print('theme read ok')

os.makedirs(get_install_dir(config), exist_ok=True)

files = list(filter(lambda file: os.path.basename(file) not in ignore_copy, files_in_dir()))

cleanup(files, get_install_dir(config))
print('cleanup ok')

copy_files(files, get_install_dir(config))
print('copy files ok')

preprocess(files, get_install_dir(config), config)
print('preprocess files ok')

print('start recompile')
bash_exec('xmonad --recompile')
print('restart')
print('need sudo to refresh font cache')
bash_exec('sudo fc-cache -fv ' + os.path.join(get_install_dir(config),'.fonts')) #reload fonts
bash_exec('xmonad --restart')
print('finished')
