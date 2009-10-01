#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Copyright (C) 2009  Kevin Brown

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import os

homedir = os.path.expanduser('~')
pconf = homedir+ "/.darkice.cfg" 

def config():
    print "necesitamos informacion minimo para contectar a un servidor"
    print "para usar los valores predeterminados, entre '[]' teclas intro"

    server = raw_input('servidor [localhost]: ')
    if server is not '':
        S = server
    else:
        S = 'localhost'
     
    port = raw_input('puerto [8000]: ')
    if port is not '':
        P = port
    else:
        P = '8000'
        
    passwd = raw_input('contraseña [hackme]: ')
    if passwd is not '':
        PS = passwd
    else:
        PS = 'hackme'

    mount = raw_input('punto de montaje [flujos.ogg]: ')
    if mount is not '':
        M = mount
    else:
        M = 'flujos.ogg'
    os.system('clear')
    check_details(S,P,PS,M)

def check_details(server, port, passwd, mount):
    print """   los detales del configuracion son:
                ---------------------------------
                
                servidor: %s
                puerto: %s 
                contraseña: %s
                punto de montaje: %s 
                ---------------------------------
        """ % (server, port, passwd, mount)
    val = raw_input("¿te gustaria editar alguna parte del configuración? [s/n]: ")
    if val == 'n':
        writeconf(server, port, passwd, mount) 
    else:
        config()

def writeconf(server, port, passwd, mount):
    tpl = """[general]
duration        = 0
bufferSecs      = 5
reconnect       = yes
[input]
device          = jack 
sampleRate      = 22050
bitsPerSample   = 16
channel         = 2
[icecast2-0]
bitrateMode     = vbr
format          = vorbis
quality         = 0.1
name            = flujos.org
description     = transmission de flujos
url             = http://live.flujos.org
genre           = libre
public          = yes"""

    tpl += """
server          = %s
port            = %s
password        = %s
mountPoint      = %s
""" % (server, port, passwd, mount)
    
    conf = open(pconf,'w')
    conf.write(tpl)
    conf.close()

def opciones():
    os.system('clear')
    print """
            ahora tienes el opcion de:
            1) arrancar el transmision con los valores predeterminados
            2) editar el configuracion de darkice para cambiar algun detalle
            3) leer el manual de configuracion de darkice
            4) salir
            """
    val = input('[1|2|3|4]: ')        

    print ""
    if val == 4:
        os.system('clear') 
        print "saliendo"
        print "puedes empezar de transmitir despues haciendo:"
        print "darkice -c", pconf
    elif val == 3:
        os.system('man darkice.cfg')
        opciones()
    elif val == 2: 
        cmd = "nano "+ pconf 
        os.system(cmd)
        opciones()
    else:    
        print "ahorra voy a arrancar el stream. la puedes parrar con ctrl-c"
        print ""
        cmd = "/usr/bin/darkice -c "+ pconf
        os.system(cmd)


def main():
    os.system('clear')
    config()
    opciones()

if __name__ == '__main__':
            main()
