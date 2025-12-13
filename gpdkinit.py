#!/usr/bin/env python
import os
# import sys

cadence_pdks = '/comelec/softs/opt/opus_kits/CADENCE_PDKS'
pdk_paths = {
    'gpdk': os.path.join(cadence_pdks, 'gpdk045_v_4_0'),  # generic pdk
    'tpt_gpdk': os.path.join(cadence_pdks, 'tpt_gpdk045'),  # tpt configuration files 
}

_cdslib = '%(tpt_gpdk)s/setup/cds.lib' % pdk_paths
if not os.path.isfile('cds.lib'):
    os.system('cp  %s cds.lib' % _cdslib)
    print('creating cds.lib')
else:
    print('using existing cds.lib')

# models directory
_models = '%(tpt_gpdk)s/models/' % pdk_paths
if not os.path.isdir('models'):
    os.system('ln -s %s' % _models)
    print('creating models path')
else:
    print('using existing models path')

## assura tech save file
#_assura_tech_save = '%(gpdk)s/COMELEC/assura_tech.save' % pdk_paths
#if not os.path.isfile('.assura_tech.save'):
#    os.system('cp  %s .assura_tech.save' % _assura_tech_save)
#    print('creating .assura_tech.save')
#else:
#    print('using existing .assura_tech.save')

# drc last state file
_drc_last_state = '%(tpt_gpdk)s/setup/drc.Last.state' % pdk_paths
if not os.path.isfile('.drc.Last.state'):
    os.system('cp  %s .drc.Last.state' % _drc_last_state)
    print('creating .drc.Last.state')
else:
    print('using existing .drc.Last.state')

# lvs last state file
_lvs_last_state = '%(tpt_gpdk)s/setup/lvs.Last.state' % pdk_paths
if not os.path.isfile('.lvs.Last.state'):
    os.system('cp  %s .lvs.Last.state' % _lvs_last_state)
    print('creating .lvs.Last.state')
else:
    print('using existing .lvs.Last.state')

# lvs last state file
_qrc_last_state = '%(tpt_gpdk)s/setup/qrc.Last.state' % pdk_paths
if not os.path.isfile('.qrc.Last.state'):
    os.system('cp  %s .qrc.Last.state' % _qrc_last_state)
    print('creating .qrc.Last.state')
else:
    print('using existing .qrc.Last.state')


# .cdsenv file
_cdsenv = '%(tpt_gpdk)s/setup/.cdsenv' % pdk_paths
if not os.path.isfile('.cdsenv'):
    os.system('cp  %s .cdsenv' % _cdsenv)
    print('creating .cdsenv')
else:
    print('using existing .cdsenv')


# os.system(os.environ['SHELL'])
