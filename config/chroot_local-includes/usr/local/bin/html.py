#!/usr/bin/python
# -*- coding: utf-8 -*-
# html script

# get and sort files
# http://stackoverflow.com/questions/168409/how-do-you-get-a-directory-listing-sorted-by-creation-date-in-python
 
import glob
import os

search_dir = "/home/radioplanton/Audios/acervo/"

def is_spx(file):
	if os.path.splitext(file)[1] == '.spx':
		return True

# remove anything from the list that is not a file (directories, symlinks)
# thanks to J.F. Sebastion for pointing out that the requirement was a list 
# of files (presumably not including directories)  
files = filter(os.path.isfile, glob.glob(search_dir + "*"))
files = filter(is_spx, files)
files.sort(key=lambda x: os.path.getmtime(x))

def format(file):
	file = os.path.split(file)[1]
	return file


def print_body(files):
 	str = '<div id="audios">'	
	str += '<h1>Ultimo Audio</h1>'
	for file in files[-1:]:
		file = format(file)
		try:
			str += '<h2><a href="acervo/%s">%s</a></h2>' % (file, file)
			str += '<span class="desc"><a target="_blank" href="http://es.wikipedia.org/wiki/Speex">¿Speex (.spx)?</a> </span>'
			# enable for html5 audio element
			#str +=  '<audio src="acervo/%s" autoplay="false" preload="false" autobuffer="false" controls="true">Tue navigador no esta chida. Actualizate a <a target="_blank" href="http://www.mozilla-europe.org/es/firefox/">firefox</a></audio>' % file
			#str += '<p><a href="acervo/">mas audios</a></p>'
			str += '<p>si la vas a editar la puedes descomprimir con un orden como lo siguiente:</p>'
			str += '<p class="code"><b>$</b> speexdec %s audio_descomprimido.wav</p>' % file
			str += '<p>y abrir el .wav en el editor que mas te late </p>' 

		except TypeError:
			pass

	str += '</div>'
	return str

head = """
`	<title>Radio Planton</title>
        <style type="text/css">

	body {background-color: #f4f4f4}
	img {border: none;}
	#plinks { 
		margin: 5px; 
		background-color: #000; 
		font-size: 10pt; 
		font-weight: bold; 
		width: 100% }
	.plink {float: left; margin: 0 5px;}
	audio {margin: 5px 10px;}
	#audios {float:left;clear: both;}
	.code {font-size: 12px; margin:10px; background-color: #fff; padding: 10px;}
	.desc {font-size: 12px; 
		margin: 0 20px;
		float: right;
		}
	h2 {margin: 5px;}
	</style>
	"""
banner = """
	<a href="http://radioplanton.linefeed.org" alt="Radio Planton"><img src="http://radioplanton.linefeed.org/files/radioplanton/images/nuevobannerr.gif" /></a>
	</div>
	<div id="plinks">

		<div class="plink">sitio de <a href="http://radioplanton.linefeed.org">radio planton</a>! |</div> 
		<div class="plink">checa los <a href="http://cnte22.ath.cx/acervo">audios del acervo de grabacion</a> |</div> 
		<div class="plink"><a href="http://acervo.org:8180">Escucha por Internet</a></div> 

	"""

tpl = """
	<html lang='en'><meta charset='utf-8'>
	<head>%s</head><body><div id="header">%s</div>%s
	<div id="files"><a href="acervo"></div>
	</body>
	</html>
	""" % (head, banner, print_body(files))

print tpl
