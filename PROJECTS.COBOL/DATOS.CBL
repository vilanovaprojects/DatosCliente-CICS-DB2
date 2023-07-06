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
       COPY DATOSMP.                                                    
      *==============================================================   
      * FIN DE LA COPY DEL MAPA GENERADO                                
      *==============================================================   
       01 MSG-FIN-SESION  PIC X(13) VALUE 'FIN DE SESION'.              
       01 MI-COMMAREA.                                                  
       03 CAMPOINICIO                     PIC X(8).                     
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
           IF EIBCALEN = 0                                              
              MOVE LOW-VALUES TO DATOSMPI                               
              PERFORM MANDAR-MAPONLY                                    
              PERFORM RETORNO-TRANS                                     
           END-IF.                                                      
      *============================================================     
      * RECOGIDA DEL MAPA DEL USUARIO                                   
      *============================================================     
           EXEC CICS RECEIVE MAP('DATOSMP')                             
                   INTO(DATOSMPI)                                       
                   NOHANDLE                                             
              END-EXEC.                                                 
      *============================================================     
      * EVALUAMOS LA RESPUESTA DEL USUARIO                              
      *============================================================     
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
                    PERFORM RETORNO-TRANS                               
           END-EVALUATE.                                                
      *============================================================     
      * TRATAMIENTO DEL FICHERO                                         
      *============================================================     
           MOVE CIFI             TO DC-CIF.                             
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
           END-EXEC                                                     
      *                                                                 
           IF SQLCODE = 0                                               
               MOVE 'REGISTRO ENCONTRADO'  TO MSGO                      
               MOVE DC-NOMBRE     TO NOMO                               
               MOVE DC-DIRECCION  TO DIRO                               
               MOVE DC-TLF        TO TLFO                               
               MOVE DC-CORREO     TO CORO                               
           ELSE                                                         
              PERFORM FALLO-FICHERO                                     
           END-IF.                                                      
      *============================================================     
      * RESPUESTA AL MAPA                                               
      *============================================================     
           EXEC CICS SEND MAP('DATOSMP')                                
               DATAONLY                                                 
               FROM(DATOSMPO)                                           
           END-EXEC.                                                    
      *============================================================     
      * PROCEDIMIENTO DEL PSEUDO-CONVERSACIONAL                         
      *============================================================     
       RETORNO-TRANS.                                                   
               EXEC CICS RETURN                                         
                     TRANSID(EIBTRNID)                                  
                     COMMAREA(MI-COMMAREA)                              
                     LENGTH(8)                                          
               END-EXEC.                                                
               GOBACK.                                                  
      *============================================================     
      * RESTO DE PROCEDIMIENTOS                                         
      *============================================================     
       MANDAR-MAPONLY.                                                  
               EXEC CICS SEND MAP('DATOSMP')                            
                     MAPONLY                                            
                     ERASE                                              
                     NOHANDLE                                           
               END-EXEC.                                                
      *                                                                 
       FALLO-MAPA.                                                      
           MOVE DFHBLINK TO MSGH.                                       
           MOVE 'POR FAVOR, INTRODUZCA UN VALOR' TO MSGO.               
               EXEC CICS SEND MAP('DATOSMP')                            
                     ERASE                                              
                     FROM(DATOSMPO)                                     
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
      *                                                                 
       FALLO-FICHERO.                                                   
      *                                                                 
           IF SQLCODE = +100                                            
               MOVE 'LA EMPRESA NO EXISTE.' TO MSGO                     
               MOVE SPACE TO NOMO                                       
                             DIRO                                       
                             TLFO                                       
                             CORO                                       
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
           MOVE DB2-ERROR      TO MSGO.                                 
