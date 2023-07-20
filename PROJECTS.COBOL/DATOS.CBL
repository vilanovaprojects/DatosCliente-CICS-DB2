      *************************************************                 
      *  PROGRAMA DE PRUEBA DE CICS-COBOL                               
      ******************************************************            
       IDENTIFICATION DIVISION.                                         
       PROGRAM-ID. DATOS.                                               
       ENVIRONMENT DIVISION.                                            
       DATA DIVISION.                                                   
       WORKING-STORAGE SECTION.                                         
      *==============================================================   
      * LA COPY MAPA GENERADO                                           
      *==============================================================   
       COPY MENU00.                                                     
       COPY MENU01.                                                     
       COPY MENU02.                                                     
       COPY MENU03.                                                     
      *==============================================================   
      * FIN DE LA COPY DEL MAPA GENERADO                                
      *==============================================================   
       01 MSG-FIN-SESION  PIC X(13) VALUE 'FIN DE SESION'.              
       01 MI-COMMAREA.                                                  
         05 DATAMENU            PIC X(6).                               
         05 DATANUM             PIC 999.                                
         05 FINCURSOR           PIC X(1).                               
             88 FIN-CURSOR      VALUE 'Y'.                              
             88 NFIN-CURSOR     VALUE 'N'.                              
      *                                                                 
       01 FILLER PIC X(20) VALUE 'TABLA678901234567890'.                
           EXEC SQL                                                     
                INCLUDE USRDATOS                                        
           END-EXEC.                                                    
      *                                                                 
       01 FILLER PIC X(20) VALUE 'SQLCA678901234567890'.                
           EXEC SQL                                                     
                INCLUDE SQLCA                                           
           END-EXEC.                                                    
      *============================================================     
      * DECLARAMOS TABLA Y CURSOR                                      
      *============================================================    
       01 TABLA.                                                       
         02 TABLAFILA OCCURS 10 TIMES.                                 
           03 COLCIF          PIC X(9).                                
           03 COLNOM          PIC X(20).                               
           03 COLDIR          PIC X(35).                               
           03 COLTLF          PIC X(9).                                
      *01 FINCURSOR           PIC X(1).                                
      *    88 FIN-CURSOR      VALUE 'Y'.                               
      *    88 NFIN-CURSOR     VALUE 'N'.                               
       01 F                   PIC 99.                                  
                                                                       
           EXEC SQL                                                    
               DECLARE CURS1 CURSOR WITH    RETURN FOR                 
                   SELECT CIF                                          
                        , NOMBRE                                       
                        , DIRECCION                                    
                        , TLF                                          
                   FROM USRDATOS                                       
                   ORDER BY CIF                                        
           END-EXEC.                                                   
                                                                       
      * CAMPOS PARA ERROR DE DB2                                       
       01 FILLER PIC X(20) VALUE 'SQLER678901234567890'.               
       01  DB2-ERR.                                                    
           03  DB2-SQLCODE                PIC S9(9).                   
           03  DB2-SQLCODE-Z              PIC -ZZZZZZZZ9.              
           03  DB2-ERROR.                                              
               05  DB2-ERR-MSG            PIC X(50).                   
               05  DB2-ERR-CODE           PIC X(20).                   
      *                                                                
       01  RESPUESTA                      PIC S9(8)  COMP.             
      *============================================================    
      * COPIAMOS AYUDAS DE BMS PARA HACER BONITO EL TERMINAL           
      *============================================================    
       COPY DFHAID.                                                     
       COPY DFHBMSCA.                                                   
      *                                                                 
       LINKAGE SECTION.                                                 
      *                                                                 
       01 DFHCOMMAREA.                                                  
          05 LK-DATA PIC X(6).                                          
          05 LK-NUM  PIC 9(3).                                          
          05 LK-CUR  PIC X(1).                                          
      *                                                                 
       PROCEDURE DIVISION.                                              
      *                                                                 
      * EXCEPTIONES SQL DB2                                             
           EXEC SQL                                                     
                WHENEVER  SQLERROR    CONTINUE                          
           END-EXEC                                                     
      *                                                                 
           EXEC SQL                                                     
                WHENEVER  SQLWARNING  CONTINUE                          
           END-EXEC                                                     
      *                                                                 
           EXEC SQL                                                     
                WHENEVER  NOT FOUND   CONTINUE                          
           END-EXEC                                                     
      *                                                                 
           MOVE DFHCOMMAREA TO MI-COMMAREA.                             
                                                                        
           IF EIBCALEN = 0                                              
              MOVE LOW-VALUES TO MAP0I                                  
              PERFORM MANDAR-MAPONLY                                    
              MOVE 'MENU00' TO MI-COMMAREA                              
              PERFORM RETORNO-TRANS                                     
           ELSE                                                         
             EVALUATE DATAMENU                                          
               WHEN 'MENU00'                                            
               PERFORM MENU00                                           
               WHEN 'MENU01'                                           
               PERFORM MENU01                                          
               WHEN 'MENU02'                                           
               PERFORM MENU02                                          
               WHEN 'MENU03'                                           
               PERFORM MENU03                                          
               WHEN OTHER                                              
               PERFORM FALLO-MAPA                                      
             END-EVALUATE                                              
           END-IF.                                                     
      *============================================================    
      * -----------MENU00-----------------------------------------     
      *============================================================    
       MENU00.                                                         
           EXEC CICS RECEIVE MAP('MENU00')                             
                   INTO(MAP0I)                                         
                   NOHANDLE                                            
              END-EXEC.                                                
           IF EIBAID = DFHPF3                                          
              PERFORM FIN-SESION                                       
              EXEC CICS RETURN                                         
              END-EXEC                                                 
           END-IF.                                                     
           EVALUATE EIBRESP                                            
                    WHEN DFHRESP(NORMAL)                               
           CONTINUE                                                    
                    WHEN DFHRESP(MAPFAIL)                              
                    PERFORM FALLO-MAPA                                 
           END-EVALUATE.                                               
                                                                       
           EVALUATE OPCI                                               
                   WHEN '1'                                            
                   PERFORM NUEVOREG                                    
                   MOVE 'MENU01' TO DATAMENU                           
                   PERFORM RETORNO-TRANS                               
                   WHEN '2'                                            
                   PERFORM BUSCAREG                                     
                   MOVE 'MENU02' TO DATAMENU                            
                   PERFORM RETORNO-TRANS                                
                   WHEN '3'                                             
                   PERFORM LISTAREG                                     
                   MOVE 'MENU03' TO DATAMENU                            
                   PERFORM RETORNO-TRANS                                
                   WHEN OTHER                                           
                   PERFORM FALLO-MAPA                                   
           END-EVALUATE.                                                
           PERFORM RETORNO-TRANS.                                       
      *============================================================     
      * TRATAMIENTO DE LOS DATOS                                        
      *============================================================     
                                                                        
      *============================================================     
      * RESPUESTA AL MAPA                                               
      *============================================================     
                                                                        
      *============================================================     
      * PROCEDIMIENTO DEL PSEUDO-CONVERSACIONAL                         
      *============================================================     
       RETORNO-TRANS.                                                   
               EXEC CICS RETURN                                         
                     TRANSID(EIBTRNID)                                  
                     COMMAREA(MI-COMMAREA)                              
                     LENGTH(LENGTH OF MI-COMMAREA)                      
               END-EXEC.                                                
               GOBACK.                                                  
      *============================================================     
      * ENVIO DE LOS MAPAS DE MENU                                      
      *============================================================     
       MANDAR-MAPONLY.                                                  
               EXEC CICS SEND MAP('MENU00')                             
                     MAPONLY                                            
                     ERASE                                              
                     NOHANDLE                                          
               END-EXEC.                                               
       NUEVOREG.                                                       
               EXEC CICS SEND MAP('MENU01')                            
                     MAPONLY                                           
                     ERASE                                             
                     NOHANDLE                                          
               END-EXEC.                                               
       BUSCAREG.                                                       
               EXEC CICS SEND MAP('MENU02')                            
                     MAPONLY                                           
                     ERASE                                             
                     NOHANDLE                                          
               END-EXEC.                                               
      *                                                                
       LISTAREG.                                                       
               EXEC CICS SEND MAP('MENU03')                            
                     MAPONLY                                           
                     ERASE                                             
                     NOHANDLE                                          
               END-EXEC.                                               
      *        EXEC SQL OPEN CURS1 END-EXEC.                           
      *        MOVE 1 TO F.                                            
      *        PERFORM READCURS UNTIL FIN-CURSOR OR F EQUAL 11.        
      *        EXEC SQL CLOSE CURS1 END-EXEC.                          
      *                                                                
      *        PERFORM LOADLIST.                                       
      *                                                                
      *        EXEC CICS SEND MAP('MENU03')                            
      *                       ERASE                                    
      *                       FROM(MAP3O)                              
      *                       NOHANDLE                                 
      *                   END-EXEC.                                    
      *        PERFORM RETORNO-TRANS.                                  
      *                                                                
       FALLO-MAPA.                                                     
           MOVE DFHBLINK TO ERRMSGH.                                    
           MOVE 'INTRODUZCA UN VALOR DEL 1 AL 3' TO ERRMSGO.            
               EXEC CICS SEND MAP('MENU00')                             
                     ERASE                                              
                     FROM(MAP0O)                                        
                     NOHANDLE                                           
               END-EXEC.                                                
           PERFORM RETORNO-TRANS.                                       
      *                                                                 
       FIN-SESION.                                                      
           EXEC CICS                                                    
               SEND TEXT FROM(MSG-FIN-SESION)                           
                         ERASE                                          
                         FREEKB                                         
           END-EXEC.                                                    
      *============================================================     
      * -----------MENU01-----------------------------------------      
      *============================================================     
       MENU01.                                                          
           EXEC CICS RECEIVE MAP('MENU01')                              
                   INTO(MAP1I)                                          
                   NOHANDLE                                             
              END-EXEC.                                                 
           EVALUATE TRUE                                                
               WHEN EIBAID = DFHENTER                                   
           CONTINUE                                                     
               WHEN EIBAID = DFHPF3                                     
                 MOVE LOW-VALUES TO MAP0I                               
                 PERFORM MANDAR-MAPONLY                                 
                 MOVE 'MENU00' TO DATAMENU                              
                 PERFORM RETORNO-TRANS                                  
           END-EVALUATE.                                                
                                                                        
           MOVE CIF1I    TO DC-CIF.                                     
           MOVE NOM1I    TO DC-NOMBRE.                                  
           MOVE DIR1I    TO DC-DIRECCION.                               
           MOVE TLF1I    TO DC-TLF.                                     
           MOVE COR1I    TO DC-CORREO.                                  
                                                                        
           EXEC SQL                                                     
             INSERT                                                     
               INTO USRDATOS(                                           
                    CIF                                                 
                  , NOMBRE                                              
                  , DIRECCION                                           
                  , TLF                                                 
                  , CORREO)                                             
               VALUES(                                                  
                    :DC-CIF                                             
                  , :DC-NOMBRE                                          
                  , :DC-DIRECCION                                       
                  , :DC-TLF                                             
                  , :DC-CORREO)                                         
           END-EXEC.                                                    
           IF SQLCODE = 0                                               
             MOVE 'GUARDADO CORRECTAMENTE.' TO ERRMSG1O                 
           ELSE                                                         
             MOVE 'ERROR AL GUARDAR.' TO ERRMSG1O                       
           END-IF.                                                      
                                                                        
           MOVE SPACE TO CIF1O                                          
                         NOM1O                                          
                         DIR1O                                          
                         TLF1O                                          
                         COR1O                                          
                                                                        
           EXEC CICS SEND MAP('MENU01')                                 
                          DATAONLY                                      
                          FROM(MAP1O)                                   
                      END-EXEC.                                         
           PERFORM RETORNO-TRANS.                                       
                                                                        
      *============================================================     
      * -----------MENU02-----------------------------------------      
      *============================================================     
       MENU02.                                                          
           EXEC CICS RECEIVE MAP('MENU02')                              
                   INTO(MAP2I)                                          
                   NOHANDLE                                             
              END-EXEC.                                                 
                                                                        
           EVALUATE TRUE                                                
               WHEN EIBAID = DFHENTER                                   
           CONTINUE                                                     
               WHEN EIBAID = DFHPF3                                     
                 MOVE LOW-VALUES TO MAP0I                               
                 PERFORM MANDAR-MAPONLY                                 
                 MOVE 'MENU00' TO DATAMENU                              
                 PERFORM RETORNO-TRANS                                  
           END-EVALUATE.                                                
                                                                        
           MOVE CIF2I TO DC-CIF.                                        
           EXEC CICS ENTER TRACEID(3) END-EXEC                          
           EXEC SQL                                                     
                SELECT                                                  
                     CIF                                                
                   , NOMBRE                                             
                   , DIRECCION                                          
                   , TLF                                                
                   , CORREO                                             
                INTO                                                    
                     :DC-CIF                                            
                   , :DC-NOMBRE                                         
                   , :DC-DIRECCION                                      
                   , :DC-TLF                                            
                   , :DC-CORREO                                         
                FROM USRDATOS                                           
                WHERE CIF = :DC-CIF                                     
           END-EXEC.                                                    
           IF SQLCODE = 0                                               
               MOVE 'REGISTRO ENCONTRADO'  TO ERRMSG2O                  
               MOVE DC-NOMBRE     TO NOM2O                              
               MOVE DC-DIRECCION  TO DIR2O                              
               MOVE DC-TLF        TO TLF2O                              
               MOVE DC-CORREO     TO COR2O                              
           ELSE                                                         
               PERFORM FALLO-FICHERO                                    
           END-IF.                                                      
                                                                        
           EXEC CICS SEND MAP('MENU02')                                 
                          DATAONLY                                      
                          FROM(MAP2O)                                   
                      END-EXEC.                                         
           PERFORM RETORNO-TRANS.                                       
      *============================================================     
      * -----------MENU03-----------------------------------------      
      *============================================================     
       MENU03.                                                          
           MOVE LOW-VALUES TO MAP3I.                                    
           MOVE SPACES     TO TABLA.                                    
                                                                        
      *    EXEC SQL OPEN CURS1 END-EXEC.                                
           EVALUATE TRUE                                                
               WHEN EIBAID = DFHENTER                                   
           CONTINUE                                                     
               WHEN EIBAID = DFHPF11                                    
                 IF NFIN-CURSOR                                         
                   ADD 10 TO DATANUM                                    
                 END-IF                                                 
      *          PERFORM SIGUIENTES                                     
               WHEN EIBAID = DFHPF10                                    
                 IF DATANUM > 0                                         
                   SUBTRACT 10 FROM DATANUM GIVING DATANUM              
                 END-IF                                                 
      *          PERFORM SIGUIENTES                                     
               WHEN EIBAID = DFHPF3                                     
      *          EXEC SQL CLOSE CURS1 END-EXEC                          
                 MOVE LOW-VALUES TO MAP0I                               
                 PERFORM MANDAR-MAPONLY                                 
                 MOVE 'MENU00' TO DATAMENU                              
                 PERFORM RETORNO-TRANS                                  
           END-EVALUATE.                                                
           EXEC SQL OPEN CURS1 END-EXEC.                                
           PERFORM DATANUM TIMES                                        
           EXEC SQL FETCH FROM CURS1 INTO :DC-CIF, :DC-NOMBRE           
                    , :DC-DIRECCION , :DC-TLF                           
           END-EXEC                                                     
           END-PERFORM.                                                 
      *    EXEC SQL OPEN CURS1 END-EXEC.                                
           MOVE 1 TO F.                                                 
           SET NFIN-CURSOR     TO TRUE.                                 
      *    INITIALIZE TABLA.                                            
           PERFORM READCURS UNTIL FIN-CURSOR OR F EQUAL 11.             
           EXEC SQL CLOSE CURS1 END-EXEC.                               
                                                                        
           PERFORM LOADLIST.                                            
                                                                        
           EXEC CICS SEND MAP('MENU03')                                 
                          DATAONLY                                      
                          FROM(MAP3O)                                   
                      END-EXEC.                                         
           PERFORM RETORNO-TRANS.                                       
                                                                        
      *SIGUIENTES.                                                      
      *    PERFORM DATANUM TIMES                                        
      *    EXEC SQL FETCH FROM CURS1 INTO :DC-CIF, :DC-NOMBRE           
      *             , :DC-DIRECCION , :DC-TLF                           
      *    END-EXEC                                                     
      *    END-PERFORM.                                                 
       READCURS.                                                        
           INITIALIZE DC-CIF                                            
                      DC-NOMBRE                                         
                      DC-DIRECCION                                      
                      DC-TLF.                                           
                                                                        
           EXEC SQL                                                     
             FETCH FROM CURS1                                           
               INTO :DC-CIF                                             
                  , :DC-NOMBRE                                          
                  , :DC-DIRECCION                                       
                  , :DC-TLF                                             
           END-EXEC.                                                    
                                                                        
                                                                        
           MOVE DC-CIF         TO COLCIF(F).                            
           MOVE DC-NOMBRE      TO COLNOM(F).                            
           MOVE DC-DIRECCION   TO COLDIR(F).                            
           MOVE DC-TLF         TO COLTLF(F).                            
           ADD 1 TO F.                                                  
                                                                        
           EVALUATE SQLCODE                                             
               WHEN 0                                                   
                    SET NFIN-CURSOR     TO TRUE                         
               WHEN 100                                                 
                    SET FIN-CURSOR      TO TRUE                         
           END-EVALUATE.                                                
                                                                        
       LOADLIST.                                                        
           MOVE TABLAFILA(1)  TO FILA1O.                                
           MOVE TABLAFILA(2)  TO FILA2O.                                
           MOVE TABLAFILA(3)  TO FILA3O.                                
           MOVE TABLAFILA(4)  TO FILA4O.                                
           MOVE TABLAFILA(5)  TO FILA5O.                                
           MOVE TABLAFILA(6)  TO FILA6O.                                
           MOVE TABLAFILA(7)  TO FILA7O.                                
           MOVE TABLAFILA(8)  TO FILA8O.                                
           MOVE TABLAFILA(9)  TO FILA9O.                                
           MOVE TABLAFILA(10) TO FILA0O.                                
                                                                        
      *                                                                 
       FALLO-FICHERO.                                                   
                                                                        
           IF SQLCODE = +100                                            
               MOVE 'LA EMPRESA NO EXISTE.' TO ERRMSG2O                 
               MOVE SPACE TO NOM2O                                      
                             DIR2O                                      
                             TLF2O                                      
                             COR2O                                      
           ELSE                                                         
      * RECUPERAR POSIBLE ERROR DE DB2                                  
               EXEC CICS ENTER TRACEID(5) END-EXEC                      
               PERFORM G999-ERROR-DB2                                   
               EXEC CICS ENTER TRACEID(6) END-EXEC                      
           END-IF.                                                      
      *                                                                 
       FIN-PGM.                                                         
               EXEC CICS RETURN                                         
               END-EXEC.                                                
               GOBACK.                                                  
      *                                                                 
       G999-ERROR-DB2.                                                  
           EXEC CICS ENTER TRACEID(99) END-EXEC                         
           MOVE SQLCODE        TO DB2-SQLCODE                           
           MOVE DB2-SQLCODE    TO DB2-SQLCODE-Z                         
           MOVE DB2-SQLCODE-Z  TO DB2-ERR-CODE                          
           MOVE SQLERRMC       TO DB2-ERR-MSG                           
           MOVE DB2-ERROR      TO ERRMSG2O.                             