# -*- coding: utf-8 -*-
#-------------------------------------------------------------------------#
#   Copyright (C) 2023 by Christoph Thelen                                #
#   doc_bacardi@users.sourceforge.net                                     #
#                                                                         #
#   This program is free software; you can redistribute it and/or modify  #
#   it under the terms of the GNU General Public License as published by  #
#   the Free Software Foundation; either version 2 of the License, or     #
#   (at your option) any later version.                                   #
#                                                                         #
#   This program is distributed in the hope that it will be useful,       #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of        #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
#   GNU General Public License for more details.                          #
#                                                                         #
#   You should have received a copy of the GNU General Public License     #
#   along with this program; if not, write to the                         #
#   Free Software Foundation, Inc.,                                       #
#   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             #
#-------------------------------------------------------------------------#


#----------------------------------------------------------------------------
#
# Set up the Muhkuh Build System.
#
SConscript('mbs/SConscript')
Import('atEnv')

# Create a build environment for the ARM9 based netX chips.
#env_arm9 = atEnv.DEFAULT.CreateEnvironment(['gcc-arm-none-eabi-4.7', 'asciidoc'])
#env_arm9.CreateCompilerEnv('NETX500', ['arch=armv5te'])
#env_arm9.CreateCompilerEnv('NETX56', ['arch=armv5te'])
#env_arm9.CreateCompilerEnv('NETX50', ['arch=armv5te'])
#env_arm9.CreateCompilerEnv('NETX10', ['arch=armv5te'])

# Create a build environment for the Cortex-R7 and Cortex-A9 based netX chips.
#env_cortexR7 = atEnv.DEFAULT.CreateEnvironment(['gcc-arm-none-eabi-4.9', 'asciidoc'])
#env_cortexR7.CreateCompilerEnv('NETX4000', ['arch=armv7', 'thumb'], ['arch=armv7-r', 'thumb'])

# Create a build environment for the Cortex-M4 based netX chips.
env_cortexM4 = atEnv.DEFAULT.CreateEnvironment(['gcc-arm-none-eabi-4.9', 'asciidoc'])
env_cortexM4.CreateCompilerEnv('NETX90', ['arch=armv7', 'thumb'], ['arch=armv7e-m', 'thumb'])

# Build the platform libraries.
SConscript('platform/SConscript')

import os


#----------------------------------------------------------------------------
#
# Get the source code version from the VCS.
#
atEnv.DEFAULT.Version('targets/version/version.h', 'templates/version.h')


#----------------------------------------------------------------------------
#
# Build all sub-projects.
#
SConscript('example_option_files/SConscript')
Import('example_option_file_netx90_activat_console')

SConscript('netx_reset/SConscript')
Import('netx_reset_netx90')
Import('netx_reset_lua')


#----------------------------------------------------------------------------
#
# Build the documentation.
#

# Get the default attributes.
#aAttribs = atEnv.DEFAULT['ASCIIDOC_ATTRIBUTES']
# Add some custom attributes.
#aAttribs.update(dict({
#    # Use ASCIIMath formulas.
#    'asciimath': True,
#
#    # Embed images into the HTML file as data URIs.
#    'data-uri': True,
#
#    # Use icons instead of text for markers and callouts.
#    'icons': True,
#
#    # Use numbers in the table of contents.
#    'numbered': True,
#
#    # Generate a scrollable table of contents on the left of the text.
#    'toc2': True,
#
#    # Use 4 levels in the table of contents.
#    'toclevels': 4
#}))
#tDoc = atEnv.DEFAULT.Asciidoc('targets/doc/org.muhkuh.tests.bootpins.html', 'README.asciidoc', ASCIIDOC_BACKEND='html5', ASCIIDOC_ATTRIBUTES=aAttribs)


#----------------------------------------------------------------------------
#
# Build the artifact.
#
strGroup = PROJECT_GROUP
strModule = PROJECT_MODULE

# Split the group by dots.
aGroup = strGroup.split('.')
# Build the path for all artifacts.
strModulePath = 'targets/jonchki/repository/%s/%s/%s' % ('/'.join(aGroup), strModule, PROJECT_VERSION)

# Set the name of the artifact.
strArtifact0 = 'netx_reset'

tArcList0 = atEnv.DEFAULT.ArchiveList('zip')
tArcList0.AddFiles('netx/',
    netx_reset_netx90)
tArcList0.AddFiles('lua/',
    netx_reset_lua,
    'lua/test_class_netx_reset.lua')
tArcList0.AddFiles('templates/',
    'lua/test.lua')
#tArcList0.AddFiles('doc/',
#    tDoc)
tArcList0.AddFiles('example_option_files/netx90',
    example_option_file_netx90_activat_console)
tArcList0.AddFiles('',
    'installer/jonchki/install.lua',
    'installer/jonchki/install_testcase.lua')

tArtifact0 = atEnv.DEFAULT.Archive(os.path.join(strModulePath, '%s-%s.zip' % (strArtifact0, PROJECT_VERSION)), None, ARCHIVE_CONTENTS = tArcList0)
tArtifact0Hash = atEnv.DEFAULT.Hash('%s.hash' % tArtifact0[0].get_path(), tArtifact0[0].get_path(), HASH_ALGORITHM='md5,sha1,sha224,sha256,sha384,sha512', HASH_TEMPLATE='${ID_UC}:${HASH}\n')
tConfiguration0 = atEnv.DEFAULT.Version(os.path.join(strModulePath, '%s-%s.xml' % (strArtifact0, PROJECT_VERSION)), 'installer/jonchki/%s.xml' % strModule)
tConfiguration0Hash = atEnv.DEFAULT.Hash('%s.hash' % tConfiguration0[0].get_path(), tConfiguration0[0].get_path(), HASH_ALGORITHM='md5,sha1,sha224,sha256,sha384,sha512', HASH_TEMPLATE='${ID_UC}:${HASH}\n')
tArtifact0Pom = atEnv.DEFAULT.ArtifactVersion(os.path.join(strModulePath, '%s-%s.pom' % (strArtifact0, PROJECT_VERSION)), 'installer/jonchki/pom.xml')
