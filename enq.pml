mtype = {flag, esc, data}

chan tx = [1] of {byte}

int max_size=32

active proctype fram_tx() {
  int cnt

inicio:
  tx!flag
  cnt = 0

  do
  :: cnt < max_size ->
     if
     :: tx!data -> cnt++
     :: tx!esc ->
        tx!data
        cnt++
     fi
  :: cnt > 0 ->
     tx!flag
     goto inicio
  :: else ->
     tx!flag
     goto inicio
  od
}

active proctype fram_rx() {
  int cnt
  mtype octeto
  bool verifica

estado_ocioso:

  cnt = 0

  do
  :: tx?flag -> goto estado_rx
  :: tx?data -> skip // ignora 
  :: tx?esc -> skip // ignora
  :: tx?octeto -> skip // simula erro de recepção
  od

estado_rx:

  do 
  :: tx?data -> cnt++
  :: tx?esc ->
     perda_sinc1: 
     goto estado_esc
  :: tx?flag -> 
     if
     :: cnt == 0 -> skip
     :: else -> goto estado_ocioso
     fi
  :: cnt > max_size -> 
     verifica = true
     goto estado_ocioso
  :: tx?octeto -> skip // simula erro de recepcao
  od

estado_esc:
  do
  :: tx?data -> 
     cnt++
     goto estado_rx
  :: tx?flag -> // erro ... não deveria receber flag
     perda_sinc2:
     goto estado_ocioso
  :: tx?esc -> // erro ... não deveria receber esc
    goto estado_ocioso
  :: tx?octeto -> skip // simula erro de recepcao
  od
}

// teste limite max_size

ltl limite {![]((fram_rx@estado_ocioso) U (fram_rx:verifica==true))}
//ltl limite {!<>(fram_rx@estado_rx U (frame_rx:cnt > max_size))}
//ltl limite {[]((fram_rx:cnt > max_size) -> <>(fram_rx@estado_ocioso))}

// testes perda de sincronismo

//ltl perda_sinc {<>(fram_rx@perda_sinc1) -> <>(fram_rx@perda_sinc2)}
