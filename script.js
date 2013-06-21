
function mapas(URL) {
  day = new Date();
    id = day.getTime();
    eval("page" + id + " = window.open(URL, '" + id + "', 'toolbar=0,scrollbars=yes,location=0,statusbar=0,menubar=0,resizable=0,fullscreen=0,width=780,height=500,top=1,left=1');");
}   

function eje_cual(program)
{
  if(validar()=='s')
  {
    document.f1.action='/cer/'+program ;
      document.f1.submit();
  }
  else
  {
    return(false);
  }
}

function MM_openBrWindow(theURL,winName,features) { //v2.0
  window.open(theURL,winName,features);
}

function dias_mes(ano,mes){
  if(mes==1 || mes==3 || mes==5 || mes==7 || mes==8 || mes==10 || mes==12)
    return 31 ;
  else
    if(mes==4 || mes==6 || mes==9 || mes==11)
      return 30 ;
    else
      if(((ano % 4 == 0) && (ano % 100 != 0)) || (ano % 400==0))
        return 29; else return 28;
}

function creardias(){
  
    dia_act = 19 ;
    mes_act = 6 ;    
    ano_act = 2013 ;
    //  dia_act = 31; mes_act=1; ano_act=2000;
    dias_de_mes = dias_mes(ano_act, mes_act);
    dif_dias    = dias_de_mes - dia_act ;
    var objeto  = document.f1.df ;
    
    objeto.length=0;
    // @INC000000273294@INDRA.SCFID89.SDC@03/10/2011@INICIO
    // INICIO 41620 CERRF001: Corregir fecha búsqueda para que no muestre 00 como día anterior los días 01 de cada mees
    for (i = dia_act-1; i <= dia_act + dif_dias; i++){
      
        if ( i != 0){
          
            objeto.length++;
            x = objeto.length - 1 ;
            z = ''+i+'';
            z = (z.length==1) ? '0' + z : z ;
            mes_act_cad = ''+mes_act+'';
            mes_act_cad = (mes_act_cad.length==1) ? '0' + mes_act_cad : mes_act_cad ;
            objeto[x].text  = z + '/' + mes_act_cad + '/' + ano_act;
            objeto[x].value = ano_act + mes_act_cad + z ;
            
        }else{
          // Es el primer día del mes, se debe mostrar en la lista desplegable el día anterior, el último día del mes anterior
          if (mes_act != 1){
            // Es un mes distinto a Enero		  	  
            i = dias_mes(ano_act, mes_act-1);		  	  
              objeto.length++;
              x = objeto.length - 1 ;
              z = ''+i+'';
              z = (z.length==1) ? '0' + z : z ;
              mes_act_cad = ''+mes_act-1+'';
              mes_act_cad = (mes_act_cad.length==1) ? '0' + mes_act_cad : mes_act_cad ;
              objeto[x].text  = z + '/' + mes_act_cad + '/' + ano_act;
              objeto[x].value = ano_act + mes_act_cad + z ;
              
          }else{
            // Es el primer día del mes de enero, se debe mostrar el día anterior del mes anterior del año anterior	  	  	  
            anio_ant = ano_act-1;	  	  	  
              i = dias_mes(anio_ant, 12);
              objeto.length++;
              x = objeto.length - 1 ;
              z = ''+i+'';
              z = (z.length==1) ? '0' + z : z ;
              mes_act_cad = ''+12+'';
              objeto[x].text  = z + '/' + mes_act_cad + '/' + anio_ant;
              objeto[x].value = anio_ant + mes_act_cad + z ;	  	  	  
          }
          i = 0;	
        }
    }
  // FIN 41620 CERRF001
  // @INC000000273294@INDRA.SCFID89.SDC@03/10/2011@FIN 
  
    mes_sig = (mes_act==12) ? 1           : mes_act + 1  ;
    ano_sig = (mes_act==12) ? ano_act + 1 : ano_act      ;
    
    dias_mes_sig = dias_mes(ano_sig,mes_sig);
    
    if(dif_dias==0)
      mas_dias = 31 - dias_mes_sig ;
    else
      mas_dias = 31 - dif_dias;
        dias_fin = (dif_dias==0) ? dias_mes_sig : (mas_dias>dias_mes_sig) ? dias_mes_sig : mas_dias ;
        
        //Rellenar segundo mes en el caso de que haya que rellenarlo
        for(i=1;i<=dias_fin;i++){
          objeto.length++
            x = objeto.length - 1 ;
            z = ''+i+'';
            z = (z.length==1) ? '0' + z : z ;
            mes_sig_cad = ''+mes_sig+'';
            mes_sig_cad = (mes_sig_cad.length==1) ? '0' + mes_sig_cad : mes_sig_cad ;
            objeto[x].text  = z + '/' + mes_sig_cad + '/' + ano_sig;
            objeto[x].value = ano_sig + mes_sig_cad + z ;
        }
  //por si se da que se tienen que rellenar más de 2 meses
  if((dif_dias==0 && mas_dias != 0) || mas_dias>dias_mes_sig){
    mes_sig=(mes_sig==12) ?           1 : mes_sig + 1 ;
      ano_sig=(mes_sig==12) ? ano_act + 1 : ano_act     ;
      ultimos_dias = (mas_dias>dias_mes_sig) ? mas_dias - dias_mes_sig : mas_dias;
      for(i=1;i<=ultimos_dias-1;i++){
        objeto.length++
          x = objeto.length - 1 ;
          z = ''+i+'';
          z = (z.length==1) ? '0' + z : z ;
          mes_sig_cad = ''+mes_sig+'';
          mes_sig_cad = (mes_sig_cad.length==1) ? '0' + mes_sig_cad : mes_sig_cad ;
          objeto[x].text  = z + '/' + mes_sig_cad + '/' + ano_sig;
          objeto[x].value = ano_sig + mes_sig_cad + z ;
          
          
      }
  }
  //RNF09-CER001 RQ CERRF001 Introducir i18n en cercanías.
  
    //FIN RNF09-CER001 RQ CERRF001
    
    objeto[1].selected = true ;
}

function validar(){
  o=document.f1.o[document.f1.o.selectedIndex].value ;
    d=document.f1.d[document.f1.d.selectedIndex].value ;
    ho=document.f1.ho[document.f1.ho.selectedIndex].value ;
    hd=document.f1.hd[document.f1.hd.selectedIndex].value ;
    if((o!=d && o!='?' && d!='?') &&
        (ho<=hd)){
          //   document.f1.HD[document.f1.hd.selectedIndex].value = parseInt(hd) + 1 ;
          return 's';
        }else{
          if(ho>hd)
            alert('La Hora Salida debe ser menor que la Hora LLegada');
              if(o==d)
                alert('Elija Estación Origen y Estación Destino distintas');
              else
                if(o=='?')
                  alert('Elija alguna Estación Origen'); 
                else
                  if(d=='?')
                    alert('Elija alguna Estación Destino '); 
                      return 'n';
        }
}

//Funciones de Búsqueda según se teclea en una SELECT
var digitos=20 //cantidad de digitos buscados
  var puntero=0
var buffer=new Array(digitos) //declaración del array Buffer
  var cadena=""
  
  //Para Navegadores distintos de Internet Explorer
  /*if(navigator.appName.substr(0,1)!='M'){
    document.onkeydown = TeclaPulsada ;
    document.captureEvents(event.KEYDOWN) ;
    
    
  //Función para recoger la tecla para navegadores distintos de Internet Explorer
  function TeclaPulsada (tecla)
  {
  if(navigator.appName.substr(0,1)!='M'){
  var teclaCodigo = tecla.which ;
  teclaReal       = String.fromCharCode (teclaCodigo) ;
  }
  }*/
  
  //Función implementada para Explorer, ya que en los demás funciona de forma automática
  function buscar_op(obj,objfoco){
    
      if(navigator.appName.substr(0,1)=='M'){
        if(navigator.appName.substr(0,1)=='M')
          var letra = String.fromCharCode(event.keyCode);
        else
          var letra = teclaReal;
            if(puntero >= digitos){
              cadena="";
                puntero=0;
            }
        //si se presiona la tecla ENTER, borro el array de teclas presionadas y salto a otro objeto...
        if (letra == 13){
          borrar_buffer();
        }
        //sino busco la cadena tipeada dentro del combo...
        else{//Inicio(1)
          buffer[puntero]=letra;
            //guardo en la posicion puntero la letra tipeada
            cadena=cadena+buffer[puntero]; //armo una cadena con los datos que van ingresando al array
          puntero++;
            
            //barro todas las opciones que contiene el combo y las comparo la cadena...
            for (var opcombo=0;opcombo < obj.length;opcombo++){//Inicio(2)
              
                if(obj[opcombo].text.substr(0,puntero).toLowerCase()==cadena.toLowerCase()){
                  //alert(puntero+'--'+obj[opcombo].text.substr(0,puntero).toLowerCase() + '--' + cadena.toLowerCase());
                  obj.selectedIndex=opcombo;break;
                }
            }//Fin(2)
        }//Final(1)
        if(navigator.appName.substr(0,1)=='M')
          event.returnValue = false; //invalida la acción de pulsado de tecla para evitar busqueda del primer caracter
        
          //    event.preventDefault();
          //   else
      }
  }



//Funcion realizada para indicar en los dias 09/09/2006 y 10/09/2006 un mensaje por una incidencia por obras en la linea C-2 de Cercanias Bilbao
function comparar(){ 
  document.getElementById("TXTInfo").value="";
    var indiceFecha = document.f1.df.selectedIndex;
    var valorFecha = document.f1.df.options[indiceFecha].value;
    var txtFecha = document.f1.df.options[indiceFecha].text;
    
    if((valorFecha=='20060909'||valorFecha=='20060910')){
      var indiceORG = document.getElementById('o').selectedIndex;
        var valorORG = document.getElementById('o').options[indiceORG].value;
        
        var indiceDEST = document.getElementById('d').selectedIndex;
        var valorDEST = document.getElementById('d').options[indiceDEST].value ;
        
        if ((valorORG == '13507' || valorORG == '13509' || valorORG == '13508' || valorORG == '13506' || valorORG == '13505' || valorORG == '13504') ||
            (valorDEST == '13507' || valorDEST == '13509' || valorDEST == '13508' || valorDEST== '13506' || valorDEST == '13505' || valorDEST == '13504')){
              
                //RNF09-CER001 RQ CERRF001 Introducir i18n en cercanías.
                document.getElementById("TXTInfo").value = bundle.getString("texto.para.este.dia") 
                + "(" + txtFecha+ ")" + bundle.getString("texto.alteraciones.previstas");
                //FIN RNF09-CER001 RQ CERRF001
            }
    }
}


function borrar_buffer(){
  //inicializa la cadena buscada
  if(navigator.appName.substr(0,1)=='M'){
    cadena="";
      puntero=0;
  }
}

/*if (navigator.appName=="Microsoft Internet Explorer")
  document.write('<link rel="stylesheet" href="/cer/css/tren.css" type="text/css">')
  else
  document.write('<link rel="stylesheet" href="/cer/css/trennet.css" type="text/css">')*/

function MM_swapImgRestore() { //v3.0
  var i,x,a=document.MM_sr; for(i=0;a&&i<a.length&&(x=a[i])&&x.oSrc;i++) x.src=x.oSrc;
}

function MM_preloadImages() { //v3.0
  var d=document; if(d.images){ if(!d.MM_p) d.MM_p=new Array();
    var i,j=d.MM_p.length,a=MM_preloadImages.arguments; for(i=0; i<a.length; i++)
      if (a[i].indexOf("#")!=0){ d.MM_p[j]=new Image; d.MM_p[j++].src=a[i];}}
}

function MM_findObj(n, d) { //v3.0
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
    if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
      for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document); return x;
}

function MM_swapImage() { //v3.0
  var i,j=0,x,a=MM_swapImage.arguments; document.MM_sr=new Array; for(i=0;i<(a.length-2);i+=3)
    if ((x=MM_findObj(a[i]))!=null){document.MM_sr[j++]=x; if(!x.oSrc) x.oSrc=x.src; x.src=a[i+2];}
}

