# DatosCliente-CICS-DB2

### Requisitos previos

- Mainframe con OS/390 (V2R10).
- Consola 3270 (WX3270).
- COBOL.
- DB2 (Versión 6).
- CICS.

### Instalación
- Preparar base de datos DB2 con SPUFI, con los archivos en ese orden: (SPUFI1, SPUFI2, SPUFI3).

- Crear DCLGEN con la base de datos creada anteriormente (USRDATOS).
- Compilar mapas de menú con el JCL compilador (COMPIMAP) .

- Compilar programa COBOL con el JCL compilador (CCICSDB2) .
- Instalación en CICS:
     - Definir los mapas con CEDA
          - MENU00  -->  CEDA DEF MAP(MENU00) GROUP(DATOS)
          - MENU01  -->  CEDA DEF MAP(MENU01) GROUP(DATOS)
          - MENU02  -->  CEDA DEF MAP(MENU02) GROUP(DATOS)
          - MENU03  -->  CEDA DEF MAP(MENU03) GROUP(DATOS)
		  
     - Definir el programa -->  CEDA DEF PROG(DATOS) GROUP(DATOS)
     - Definir la transacción -->  CEDA DEF TRANS(DATO) GROUP(DATOS)
	 
	 - Finalmente asociamos la transacción al programa. Limpiar pantalla con la tecla "Pausa" y ejecutar la transacción escribiendo "DATO" en el terminal.


### Introducción

El programa consta de un menú con 3 opciones (insertar, buscar y listar). Está programado en COBOL en modo pseudoconversacional con acceso a base de datos DB2 y con control de errores por mensaje.

		 Menú Principal
![](https://i.postimg.cc/9FXT2TFY/MENU00.jpg)

Pantalla de menú principal. Solo se amiten 3 opciones, de lo contrario saldrá error por "MSG:". Con F3 en esta pantala se finaliza la transacción.

		 Nuevo registro
![](https://i.postimg.cc/02tSyQzR/MENU01.jpg)

Pantalla de nuevo registro. Las variables se han declarado previamente con "NOT NULL" por lo que avisará e un error si no se rellenan los campos. También informará de regitro duplicao en el CIF. Por último pulsando F3 saldrá al menú principal.

		 Buscar registro
![](https://i.postimg.cc/bY9b4L8v/MENU02.jpg)

Pantalla de busqueda. Busca y devuelve valores que coincidan con el CIF de la empresa buscada. Lo errores que pueda haber de DB2 también se mostrarán por "MSG:", así como la información adicional al usuario si la empresa no existe en la base de datos. Pulsando F3 se saldrá al menú principal.

		 Listar registro
![](https://i.postimg.cc/GmVsv5PX/MENU03.jpg)

Pantalla de listado de registros. Aquí saldrán los registros listado por orden de CIF ascendente. Con "intro" se cargan los registros y se pueden cargar los 10 siguientes pulsando F10 y F11. Por último pulsando F3 saldrá al menú principal.



###Links


#####Youtube

`<link>` : <https://www.youtube.com/@VilanovaProjects-qf2wd>

#####Github

`<link>` : <https://github.com/vilanovaprojects>

