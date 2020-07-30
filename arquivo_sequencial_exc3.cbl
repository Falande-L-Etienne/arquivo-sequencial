      $set sourceformat"free"

      *>Divisão de identificação do programa
       identification division.
       program-id. "arquivo_sequencial_exc3".
       author. "Falande Loiseau Etienne".
       installation. "PC".
       date-written. 24/07/2020.
       date-compiled. 24/07/2020.



      *>Divisão para configuração do ambiente
       environment division.
       configuration section.
           special-names. decimal-point is comma.

      *>-----Declaração dos recursos externos
       input-output section.
       file-control.

      *>   Declaração do arquivo
           select arqTemp assign to "arqTemp.txt"            *>assosiando arquivo lógico (nome dado ao arquivo dentro do pmg vom o arquivo fisico)
           organization is line sequential                   *>forma de organização dos dados
           access mode is sequential                         *>forma de acesso aos dados
           lock mode is automatic                            *>tratamento de dead lock - evita perda de dados em ambiemtes multi-usuários
           file status is ws-fs-arqTemp.                     *>file status (o status da ultima operação)


       i-o-control.

      *>Declaração de variáveis
       data division.

      *>----Variaveis de arquivos
       file section.
       fd arqTemp.
       01  fd-temperaturas.
           05 fd-temp                              pic s9(02)v99.

      *>----Variaveis de trabalho
       working-storage section.

       77  ws-fs-arqTemp                           pic 9(02).

       01 ws-temperaturas occurs 30.
          05 ws-temp                               pic s9(02)v99.

       01 ws-mensagens.
          05 ws-sair                               pic x(01).
          05 ws-msn-erro.
             10 ws-msn-erro-ofsset                 pic 9(04).
             10 filler                             pic x(01) value "-".
             10 ws-msn-erro-cod                    pic 9(02).
             10 filler                             pic x(01) value space.
             10 ws-msn-erro-text                   pic x(42).

       01 ws-uso-comum.
          05 ws-dia                                pic 9(02).
          05 ws-ind-temp                           pic 9(02).
          05 ws-media-temp                         pic s9(02)v99.
          05 ws-temp-total                         pic s9(03)v99.



      *>----Variaveis para comunicação entre programas
       linkage section.


      *>----Declaração de tela
       screen section.

      *>Declaração do corpo do programa
       procedure division.


           perform inicializa.
           perform processamento.
           perform finaliza.

      *>------------------------------------------------------------------------
      *>  Procedimentos de inicialização
      *>------------------------------------------------------------------------
       inicializa section.

           open input arqTemp.
           if ws-fs-arqTemp <> 0 then
               move 1                                to ws-msn-erro-ofsset
               move ws-fs-arqTemp                    to ws-msn-erro-cod
               move "Erro ao abrir arq. arqTemp " to ws-msn-erro-text
               perform finaliza-anormal
           end-if

           perform varying ws-ind-temp from 1 by 1 until ws-fs-arqTemp = 10
                                                     or ws-ind-temp > 30

               read arqTemp  into  ws-temp(ws-ind-temp)
               if  ws-fs-arqTemp <> 0
               and ws-fs-arqTemp <> 10 then
                   move 2                                to ws-msn-erro-ofsset
                   move ws-fs-arqTemp                    to ws-msn-erro-cod
                   move "Erro ao ler arq. arqTemp "      to ws-msn-erro-text
                   perform finaliza-anormal
               end-if


           end-perform

           close arqTemp.
           if ws-fs-arqTemp <> 0 then
               move 3                                 to ws-msn-erro-ofsset
               move ws-fs-arqTemp                     to ws-msn-erro-cod
               move "Erro ao fechar arq. arqTemp "    to ws-msn-erro-text
               perform finaliza-anormal
           end-if

           .
       inicializa-exit.
           exit.

      *>------------------------------------------------------------------------
      *>  Processamento principal
      *>------------------------------------------------------------------------
       processamento section.

      *>   chamando rotina de calculo da média de temp.
           perform calc-media-temp

      *>    menu do sistema
           perform until ws-sair = "S"
                      or ws-sair = "s"
               display erase

               display "Dia a ser testado: "
               accept ws-dia

               if  ws-dia >= 1
               and ws-dia <= 30 then
                   if ws-temp(ws-dia) > ws-media-temp then
                       display "A temperatura do dia " ws-dia " esta acima da media"
                   else
                   if ws-temp(ws-dia) < ws-media-temp then
                           display "A temperatura do dia " ws-dia " esta abaixo da media"
                   else
                           display "A temperatura esta na media"
                   end-if
                   end-if
               else
                   display "Dia fora do intervalo valido (1 - 30)"
               end-if

               display "'T'estar outra temperatura"
               display "'S'air"
               accept ws-sair
           end-perform
           .
       processamento-exit.
           exit.

      *>------------------------------------------------------------------------
      *>  Calculo da média de temperatura
      *>------------------------------------------------------------------------
       calc-media-temp section.

           move 0 to ws-temp-total
           perform varying ws-ind-temp from 1 by 1 until ws-ind-temp > 30
               compute ws-temp-total = ws-temp-total + ws-temp(ws-ind-temp)
           end-perform

           compute ws-media-temp = ws-temp-total/30

           .
       calc-media-temp-exit.
           exit.

      *>------------------------------------------------------------------------
      *>  Finalização  Anormal
      *>------------------------------------------------------------------------
       finaliza-anormal section.
           display erase
           display ws-msn-erro.
           Stop run
           .
       finaliza-anormal-exit.
           exit.

      *>------------------------------------------------------------------------
      *>  Finalização
      *>------------------------------------------------------------------------
       finaliza section.
           Stop run
           .
       finaliza-exit.
           exit.













