import sys
import os
import re
import json
import argparse
import xml.etree.ElementTree as ET


# default paths for EmuDeck - we may need to edit those for compatibility with other setups

def_output = './manifest.json'
def_gamelist_root = '/home/deck/.emulationstation/gamelists'
def_srm_userdata = '/home/deck/.config/steam-rom-manager/userData'


# no edits should be required below this line
# -------------------------------------------

def log(type, message, quiet = False):
    if not quiet:
        print(f'[{type}] {message}')

# empty config, to be filled
cfg = {}

# say hello
print('<SRM manifest.json generator 0.3 (c) 2023 d0k3>')

# parse arguments
parser = argparse.ArgumentParser()
parser.add_argument('-c', '--config', type=str, help='specify configuration to load')
parser.add_argument('-s', '--srm-userdata', type=str, default=def_srm_userdata, help='specify SRM userData path')
parser.add_argument('-r', '--roms-root', type=str, help='specify roms root path')
parser.add_argument('-g', '--gamelist-root', type=str, default=def_gamelist_root, help='specify gamelist root path (can be same as roms root)')
parser.add_argument('-o', '--output', type=str, default=def_output, help='specify output destination for manifest.json')
parser.add_argument('-d', '--dump-config', type=str, help='dump config to specied destination and exit')
parser.add_argument('-p', '--pause', help='wait after finishing process', action='store_true')
parser.add_argument('-q', '--quiet', help='suppress most on screen output', action='store_true')
args = parser.parse_args()

# take over config from arguments
if args.config:
    with open(args.config, 'r', encoding = 'utf-8') as fp:
        cfg = json.load(fp)
if args.roms_root:
    cfg['roms_root'] = args.roms_root
if args.gamelist_root:
    cfg['gamelist_root'] = args.gamelist_root
output_path = args.output

# if specified: take over manifest templates from SRM userConfigurations.json
if args.srm_userdata and not args.config:
    retroarchPath = ''
    raCoresDirectory = ''
    with open(os.path.join(args.srm_userdata, 'userSettings.json'), 'r', encoding = 'utf-8') as fp:
        srmset = json.load(fp)
        srmenv = srmset['environmentVariables']
        retroarchPath = srmenv['retroarchPath']
        raCoresDirectory = srmenv['raCoresDirectory']
        cfg['roms_root'] = srmenv['romsDirectory']
        
    with open(os.path.join(args.srm_userdata, 'userConfigurations.json'), 'r', encoding = 'utf-8') as fp:
        srmconfig = json.load(fp)
        cfg['manifest_templates'] = {}
        for p in srmconfig:
            s = re.search('\${romsdirglobal}\/([^\/]+)', p['romDirectory'])
            if not p['executableArgs'] or not s:
                # most likely not an emulator
                continue
            e = {}
            e['subdir'] = s.group(1)
            e['emulator'] = p ['executable']['path'].replace('${retroarchpath}', retroarchPath)
            e['args'] = p['executableArgs'].replace('${racores}', raCoresDirectory)
            cfg['manifest_templates'][p['configTitle']] = e
                
# sanity check
if not (('roms_root' in cfg) and cfg['roms_root']):
    parser.print_help()
    sys.exit(0)

# missing gamelist root? take it over from roms_root
if not (('gamelist_root' in cfg) and cfg['gamelist_root']):
    cfg['gamelist_root'] = cfg['roms_root']

# config summary
log('config', f'{cfg["roms_root"]} (roms root)', args.quiet)
log('config', f'{cfg["gamelist_root"]} (gamelist root)', args.quiet)
log('config', f'{len(cfg["manifest_templates"])} manifest templates loaded', args.quiet)

# dump config if specified
if args.dump_config:
    with open(args.dump_config, 'w', encoding = 'utf-8') as fp:
        json.dump(cfg, fp, indent = 4)
    log('config', f'config dumped to {args.dump_config}')
    sys.exit(0)

manifests = [] # one entry per game
processed_subddirs = [] # used to keep track of already processed subdirs
for system in cfg["manifest_templates"]:
    # basic parameters
    template = cfg["manifest_templates"][system]
    subdir = template['subdir']
    emulator = template['emulator']
    options = template['args']
    if subdir in processed_subddirs:
        continue
    cfaves = 0
    log(f'{subdir}', f'System: {system}', args.quiet)
    
    # fetch gamelist (with a workaround for non standard compliant XML files)
    gamelist = []
    try:
        gamelist_path = os.path.join(cfg['gamelist_root'], subdir, 'gamelist.xml')
        with open(gamelist_path, mode = 'r', encoding = 'utf-8') as fp:
            fp.readline()
            gamelist = ET.fromstring('<?xml version="1.0"?>\n<root>' + fp.read() + '\n</root>').find('gameList').findall('game')
    except Exception as e:
        pass    
    if not gamelist:
        log(f'{subdir}', 'missing or bad gamelist.xml', args.quiet)
        continue
        
    # process favourites
    for entry in gamelist:
        glfav = entry.find('favorite')
        glpath = entry.find('path')
        if (glpath is None) or (glfav is None) or (glfav.text != 'true'):
            continue
        filename = os.path.basename(glpath.text)
        filepath = os.path.normpath(os.path.join(cfg['roms_root'], subdir, filename))
        title = re.sub("\(.*?\)|\[.*?\]","", os.path.splitext(filename)[0]).strip()
        log(f'{subdir}', f'{title}', args.quiet)
        m = {}
        m['title'] = title
        m['target'] = emulator
        m['startIn'] = os.path.dirname(emulator)
        m['launchOptions'] = options.replace('${filePath}', filepath)
        manifests.append(m)
        cfaves = cfaves + 1

    log(f'{subdir}', f'{cfaves} favorites found', args.quiet and not cfaves)
    processed_subddirs.append(subdir)
    
# write JSON file
with open(output_path, 'w', encoding = 'utf-8', newline = '') as fp:
    json.dump(manifests, fp, indent = 4)
log('finished', f'write {output_path} done')

if args.pause:
    input('\npress key to continue...')
    
