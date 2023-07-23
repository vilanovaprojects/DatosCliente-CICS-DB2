# DatosCliente-CICS-DB2

### Requirements

- Mainframe with OS/390 (V2R10).
- Terminal 3270 (WX3270).
- COBOL.
- DB2 (Version 6).
- CICS (Version 5.3.0).

### Installation
- Prepare database with SPUFI, use the following order : (SPUFI1, SPUFI2, SPUFI3).

- Create DCLGEN with the previously created database (USRDATOS).
- Compile the menu maps with the JCL compiler (COMPIMAP).
  - Enter with "view" and aply the changes "C XXXXXX MENU0X ALL" before submited.
- Compile cobol program with the JCL compilar (CCICSDB2).
- Installation in CICS:
     - Define maps with CEDA
          - MENU00  -->  CEDA DEF MAP(MENU00) GROUP(DATOS)
          - MENU01  -->  CEDA DEF MAP(MENU01) GROUP(DATOS)
          - MENU02  -->  CEDA DEF MAP(MENU02) GROUP(DATOS)
          - MENU03  -->  CEDA DEF MAP(MENU03) GROUP(DATOS)
		  
     - Define program -->  CEDA DEF PROG(DATOS) GROUP(DATOS)
     - Define transaction -->  CEDA DEF TRANS(DATO) GROUP(DATOS)
	 
	 - Finally we have to associate the transaction to the program. Clear screeen with the "Pause" key and execute the transaction by typing "DATO" on terminal.


### Introduction

This is a CICS program executable with 3 different menus on witch we can insert, search and list the records. The records are saved in the DB2 databse that we sholud have connected to CICS. It is programed in COBOL in pseudoconversational mode so it is a good practice to program as in a real work enviroment. The program is typed in Spanish, but I hope it won't be a problem, in any case dont hesitate to contact me ;)

		 Main menu
![](https://i.postimg.cc/9FXT2TFY/MENU00.jpg)

Main menu screen. Only 3 options are allowed, otherwise an error will appear on "MSG:" box. with F3 on this screen the transaction is finished.

		 New record
![](https://i.postimg.cc/02tSyQzR/MENU01.jpg)

New registration screen. The variables have been previously declared with "NOT NULL" so it will report an error if the fields are not filled in. It will also report duplicate registration in the CIF. Finally pressing F3 will exit to the main menu.

		 Search record
![](https://i.postimg.cc/bY9b4L8v/MENU02.jpg)

Search screen. Searches for and returns values ​that match the CIF of the searched company. Any DB2 errors will also be displayed by "MSG:", as well as additional information to the user if the company does not exist in the database. Pressing F3 will exit to the main menu.

		 List records
![](https://i.postimg.cc/GmVsv5PX/MENU03.jpg)

Record list screen. Here the records will be listed in ascending CIF order. With "enter" the records are loaded and the next 10 can be loaded by pressing F10 and F11. Finally pressing F3 will exit to the main menu.



### Links


##### Youtube

`<link>` : <https://www.youtube.com/@VilanovaProjects-qf2wd>

##### Github

`<link>` : <https://github.com/vilanovaprojects>


