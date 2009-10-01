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

import sys, os
from time import sleep

homedir = os.path.expanduser('~')
pconf = homedir+ "/.darkice.cfg" 
music_lib = homedir+ "/Musica"

def app_is_not_running(app):
    """is application running"""
    a = os.system("pgrep %s" % app)
    return a

class music(object):

    def __init__(self, library):
        self.library = library

    def update_db(self):
        cmd = "sudo mpd --create-db"
        os.system(cmd)    

    def correct_perms(self, dirname):
        """correct permissions"""
        uid = os.getuid()
        for dirpath, dirs, files in os.walk(dirname):
            for filename in files:
                path=os.path.join(dirpath, filename)
                print path
                if not os.stat(path).st_uid == uid:
                    print "seting owner on %s" % path
                    cmd = 'sudo chown -Rc %s "%s"' % (str(uid), path)
                    os.system(cmd)
                if not os.access(path,os.R_OK):
                    print "setting mode on %s" % path
                    os.chmod(path, 0644)

    def menu(self):
        os.system('clear')
        print """  CONFIGURACION DE BIBLIOTECA DE AUDIO [MPD]


                1) validar biblioteca de musica
                2) actualizar biblioteca de musica
                3) reinicar daemon de musica
                4) control de musica
                S) salir
                """

        val = raw_input('[1|2|3|4|S]: ')
        if val == '1':
            print ""
            dir = raw_input('ruta a la biblioteca de audio [%s]: ' % self.library)
            self.correct_perms(dir)
            self.menu()
        if val == '2':
            print ""
            print "puede que tarda"
            self.update_db()
            self.menu()
        if val == '3':
            cmd = 'sudo /etc/init.d/jackd stop'
            os.system(cmd)
            cmd = 'sudo /etc/init.d/mpd stop'
            os.system(cmd)
            cmd = 'sudo /etc/init.d/jackd start'
            os.system(cmd)
            cmd = 'sudo /etc/init.d/mpd start'
            os.system(cmd)
            sleep(2)
            self.menu()
        if val == '4':
            cmd = 'ncmpc'
            os.system(cmd)
            self.menu()
        if val.lower() == 's':
            opciones()

### this should change to stream_config()
class config(object):
    """configuration object"""
    def __init__(self):
        self.data = {'server': 'localhost','port': '8000', 'passwd': 'hackme', 'mount': 'flujos.ogg', 'device': 'jack'}
        
#        self.data = [('server','localhost'),('port','8000'),('passwd','hackme'),('mount','flujos.ogg')]

    def save(self, var, val):
        self.data[var] = val

    def ask_user(self, var):
        config = self.data
        val = config[var]
        msg = "%s [%s]: " % (var, val)
        userval =  raw_input(msg)
        if userval is not '':
            self.data[var] = userval
    
    def sumerize_config(self, var='all'):
        
        config = self.data
        os.system('clear')
        if var == 'all':
            print "CONFIGURACION GENERAL DE FLUJO"
            print "------------------------"
            print "cambiar configuracion de:"
            print ""
            items = config.items()
            for i in config:
                print "[%s] %s: %s" % (items.index((i, config[i]))+1, i, config[i])
            print "------------"
            print "[S] o salir" 
            print "---------------------------"
            print "si no hay que cambiar nada, oprime [intro]"
            print ""
        self.change_config_option()
    
    def bye_bye(self):
        os.system('clear')
        print """


                                        besitos, bye

                    """ 
        sys.exit()

    def change_config_option(self):
        val = raw_input('[1|2|3|4|5|S|intro]: ')        
        print ""
        ask = self.ask_user 
        if val == '3':
            ask('mount')
        elif val == '1':
            ask('passwd')
        elif val == '4': 
            ask('port')
        elif val == '5':
            ask('server')
        elif val == '2':
           ask('device') 
        elif val == 'S':
            self.bye_bye()
        elif val == "":    
            config = self.data
            self.writeconf()
            opciones() 
        self.writeconf()
        self.sumerize_config() 

    def writeconf(self):
        tpl = """[general]
    duration        = 0
    bufferSecs      = 5
    reconnect       = yes
    [input]
    device          = %s 
    sampleRate      = 44100 
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
    public          = yes
    server          = %s
    port            = %s
    password        = %s
    mountPoint      = %s
    """ % (self.data['device'], self.data['server'], self.data['port'], self.data['passwd'], self.data['mount'])
        
        conf = open(pconf,'w')
        conf.write(tpl)
        conf.close()

def run_darkice():
    os.system('clear')
    print "#####"
    print "#####     ahora voy a comenzar el stream. lo puedes detener con ctrl-c"
    print "#####"
    print ""
    print ""
    cmd = "/usr/bin/darkice -c "+ pconf
    os.system(cmd)

#this will become a class darkice(object)
#and there will be a class mpd(object) which checks if mpd is running
#updates mpd db and verifies permissiones on music directory and has an opcion to open ncmpc
#mpd and darkice should connect via jack.plumbing
#and it may be useful to throw in a test wich downloads the stream and gives visual output via
#mplayer and  "jack.scope -n2 -s line"

def opciones():
    os.system('clear')

    print """OPCIONES GENERALES

            ahora tienes la opcion de:
            1|intro) arrancar la transmision con los valores predeterminados
            2) editar la configuracion de darkice para cambiar algun detalle
            3) leer el manual de configuracion de darkice
            4) control de volumen
            5) control de musica
            S) salir
            """
    val = raw_input('[1|2|3|4|5|S|intro]: ')        

    print ""
    x = config()
    y = music(music_lib)
    if val.lower() == 's':
        x.bye_bye    
    elif val == '4':
        os.system('alsamixer') 
        #print "saliendo"
        #print "puedes empezar a transmitir despues con la siguiente instruccion:"
        #print "darkice -c", pconf
        opciones()
    elif val == '3':
        os.system('man darkice.cfg')
        opciones()
    elif val == '2': 
        cmd = "nano "+ pconf 
        os.system(cmd)
        opciones()
    elif val == '5':
        y.menu()
    else:    
        #config = config.data
        #server = config[server]
        #if server == 'localhost' and app_is_running('icecast') and app_is_running('jackd'):
        #    cmd = "/usr/bin/darkice -c "+ pconf
        #    os.system(cmd)
        
        if x.data['server'] == 'localhost' and app_is_not_running('icecast'):
            print x.data['server'], 'icecast not running'
#            os.system('clear')
#            print """OPERACIONES DE SERVIDOR DE FLUJOS
#                    server: localhost
#                    el el configuraion indica que esta corriendo el servidor de streaming"
#                    en esta misma maquina [localhost]. pero no lo encontramos."
#                    --------------------------
#                    1) intentamos arrancar icecast
#                    2) cambia la configuracion del servidor
#
#                    """

            val = input('[1|2]: ')
            if val == 1:
                cmd = 'sudo /etc/init.d/icecast2 restart'
                os.system(cmd)
                sleep(2)
                opciones()
            elif val == 2:
                x.ask_user('server')
                x.writeconf()
                opciones()
        elif not app_is_not_running('jackd') and not app_is_not_running('mpd'):
            print "jackd esta corriendo"
            print "mpd esta corriendo"
            jp = homedir+ "/.jack.plumbing"
            jp_config = open(jp, "w")
            pipes = ['(connect "MPD:left" "darkice-[1-9].*:left")', '(connect "MPD:right" "darkice-[1-9].*:right")']
            for p in pipes:
                jp_config.write(p+"\n")
            jp_config.close()
            cmd = "jack.plumbing 1> /dev/null &"
            os.system(cmd)
            run_darkice()
        elif app_is_not_running('mpd'):
            print """
                    NO ESTA CORRIENDO MPD
                    al mejor hay que configurarla

                1) siguir como si nada
                2) menu de mpd"""
            
            userinput = input('[1|2]: ')
            if userinput == 1:
                run_darkice()
            elif userinput == 2:
                y.menu()
        else:    
            print """
                    NO ESTA CORRIENDO JACKD
                [1] arrancamos jackd 
                [2] reconfiguramos para utilizar alsa en lugar de jackd
                                """
            userinput = input('[1|2]: ')
            if userinput == 1:
                cmd = "/usr/bin/jackd -R -d alsa -d hw -r44100 2> /dev/null &"
                os.system(cmd)
                for i in range(5):
                    print i 
                    sleep(1)
                run_darkice() 
            else: 
                x.data['device'] = 'default'
                x.writeconf()
                x.save('device', 'default')
                run_darkice() 
       #elif server != 'localhost' and app_is_running('jackd'):
        #    cmd = "/usr/bin/darkice -c "+ pconf
        #    os.system(cmd)
       # elif server != 'localhost' and not app_is_running('jackd'):
       #     print "jackd is not running. we need to start it"
       #     cmd = "/usr/bin/jackd -R -d alsa -d hw 2> /dev/null &"
       #     os.system(cmd)
       #     print "ahora podemos arrncar darkice"
       #     cmd = "/usr/bin/darkice -c "+ pconf
       #     os.system(cmd)

def main():
    os.system('clear')
    x = config()
    defaults = x.data 
    for i in defaults:
        x.ask_user(i)
    x.sumerize_config()
#    x.change_config_option()
        
if __name__ == '__main__':
            main()

