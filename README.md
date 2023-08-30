## Promela
### Tarefa: exercícios sobre verificação de propriedades
- Nesta tarefa você resolverá alguns exercícios introdutórios sobre veriicação de propriedades com PROMELA e SPIN. Para realizá-los, você deve se basear no capítulo sobre verificação de propriedades.

Roteiro para compilação:

Gerar o pan.c do enquadramento e arq:
```
./spin -a enq.pml
```
Depois é só gerar o pan.c do pml desejado, compilá-lo e executar:
```
gcc -o pan pan.c
./pan -a
```
### Questão 1:
- ARQ:
- Se uma mensagem for transmitida, ela será recebida em algum momento.

Sentença LTL definida:
```
ltl rcv_msg{![]((transmissor@envia_data) -> <>(receptor:confirma==true))}
```
Explicação:

Para melhorar a análise da sentença, foi acrescentado uma label no processo *transmissor* em seu estado ocioso, nomeada como *envia_data*, onde ela só é acionada quando há o envio do data. Além disso, também foi adicionada uma variável booleana para auxiliar no processor *receptor*, chamada de *confirma*, o que retorna *true* quando a sequência de recebimento for igual a encaminhada pelo transmissor.

Neste caso, o operador always negado *(![])*, significa que "em algum momento, nem sempre é verdade". Depois, a subexpressão *(transmissor@envia_data)*, está indicando que o processo transmissor está enviando uma mensagem no momento atual. Já a subexpressão *<>(receptor:confirma==true)* usa o operador "eventualmente"(<>), indicando que, em algum momento no futuro, o receptor recebe uma confirmação *(confirma==true)*. E a *->* consiste em uma implicação entre duas subexpressões.

Analisando como um todo, a sentença quer dizer que: não é verdade que, em todos os momentos, se o transmissor está no estado 'envia_data', então eventualmente o receptor terá a variável 'confirma' igual a 'true'. Essa sentença está verificando se há alguma situação no sistema em que o transmissor envia uma mensagem, mas o receptor nunca confirma o recebimento dessa mensagem. Se essa propriedade for verdadeira, significa que em algum momento uma mensagem é transmitida, mas não é recebida.

Resultado: 

No resultado da execução, observa-se 1 erro dentro da profundida atingidade de 219, além de um *acceptance cycle* indicando que a propriedade é satisfeita, como mostra abaixo:
```
pan:1: acceptance cycle (at depth 156)
pan: wrote quest1.pml.trail


(Spin Version 6.5.2 -- 30 May 2023)
Warning: Search not completed
	+ Partial Order Reduction


Full statespace search for:
	never claim         	+ (rcv_msg)
	assertion violations	+ (if within scope of claim)
	acceptance   cycles 	+ (fairness disabled)
	invalid end states	- (disabled by never claim)


State-vector 52 byte, depth reached 219, errors: 1
      122 states, stored (123 visited)
       25 states, matched
      148 transitions (= visited+matched)
        0 atomic steps
hash conflicts:         0 (resolved)


Stats on memory usage (in Megabytes):
    0.009	equivalent memory usage for states (stored*(State-vector + overhead))
    0.286	actual memory usage for states
  128.000	memory used for hash table (-w24)
    0.534	memory used for DFS stack (-m10000)
  128.730	total actual memory usage
pan: elapsed time 0 seconds
```
- Uma nova mensagem é transmitida somente se a mensagem anterior for confirmada.
```
ltl ack_msg {[]((transmissor@envia_data && (receptor:confirma==true)) && [](transmissor@rcv_ack) -> (transmissor@envia_data))}
```
Explicação:

Nesse caso, também foi criada uma nova label no processo transmissor, *rcv_ack*, onde é acionada toda vez que o transmissor receber um ack de confirmação correto.

Com isso, a sentença verifica se, é sempre verdade *([])* que o processo transmissor envia uma mensagem de dados *(transmissor@envia_data)* e o processo receptor confirma o recebimento *(receptor:confirma==true)*, o processo transmissor deve receber uma mensagem de reconhecimento *(transmissor@rcv_ack)*, o que vai resultar em um envio de outra mensagem de dados *(transmissor@envia_data)*.

Portanto, a propriedade "ack_msg" especifica que, em todos os estados do sistema, se o evento transmissor@envia_data ocorrer simultaneamente com a variável receptor:confirma sendo igual a true, e em algum momento futuro o evento transmissor@rcv_ack ocorrer, então o evento transmissor@envia_data deve ocorrer novamente.

Resultado: 

Pelo resultado da execução, como mostra abaixo, com uma profundidade de 239, não houve indicação de erro na verificação dessa sentença:
```
(Spin Version 6.5.2 -- 30 May 2023)
	+ Partial Order Reduction

Full statespace search for:
	never claim         	+ (ack_msg)
	assertion violations	+ (if within scope of claim)
	acceptance   cycles 	+ (fairness disabled)
	invalid end states	- (disabled by never claim)

State-vector 52 byte, depth reached 239, errors: 0
      264 states, stored
       89 states, matched
      353 transitions (= stored+matched)
        0 atomic steps
hash conflicts:         0 (resolved)

Stats on memory usage (in Megabytes):
    0.020	equivalent memory usage for states (stored*(State-vector + overhead))
    0.288	actual memory usage for states
  128.000	memory used for hash table (-w24)
    0.534	memory used for DFS stack (-m10000)
  128.730	total actual memory usage


unreached in proctype transmissor
	quest1.pml:31, state 10, "printf('transmissor recebeu ack incorreto: %d\n',!(seq))"
	quest1.pml:37, state 18, "-end-"
	(2 of 18 states)
unreached in proctype receptor
	quest1.pml:59, state 16, "-end-"
	(1 of 16 states)
unreached in claim ack_msg
	_spin_nvr.tmp:8, state 10, "((transmissor._p==rcv_ack))"
	_spin_nvr.tmp:10, state 13, "-end-"
	(2 of 13 states)

pan: elapsed time 0 seconds
```
### Questão 2:
- Enquadramento:
- Quadros que excedam o tamanho máximo são descartados pelo receptor.

Sentença LTL definida:
```
ltl limite {![]((fram_rx@estado_ocioso) U (fram_rx:verifica==true))}
```
Explicação:

Como anteriormente, foi criada uma variável auxilair para fazer a análise, que nesse caso, é chamada de *verifica*, onde foi criada no processo *fram_rx*, no *estado_rx*, para facilitar na interpretação. Quando ela é acionada, seu valor fica igual a true.

No contexto do código fornecido, essa sentença busca verificar se o estado_ocioso não é alcançado até que a variável verifica de fram_rx seja igual a true. Portanto, a sentença LTL busca verificar se é sempre falso que o estado_ocioso é alcançado até que a condição fram_rx:verifica==true seja satisfeita. Se a verificação falhar, isso indicaria que o estado estado_ocioso é alcançado antes que verifica seja true, o que significa que a propriedade desejada não é satisfeita.

Resultado:

Como pode-se observar abaixo, o resultado mostrou-se sem erro ao fazer a verificação da setença, nem violações de assertiva durante a análise do espaço de estados:
```
(Spin Version 6.5.2 -- 30 May 2023)
	+ Partial Order Reduction

Full statespace search for:
	never claim         	+ (limite)
	assertion violations	+ (if within scope of claim)
	acceptance   cycles 	+ (fairness disabled)
	invalid end states	- (disabled by never claim)

State-vector 48 byte, depth reached 8, errors: 0
        7 states, stored
        0 states, matched
        7 transitions (= stored+matched)
        0 atomic steps
hash conflicts:         0 (resolved)

Stats on memory usage (in Megabytes):
    0.001	equivalent memory usage for states (stored*(State-vector + overhead))
    0.285	actual memory usage for states
  128.000	memory used for hash table (-w24)
    0.534	memory used for DFS stack (-m10000)
  128.730	total actual memory usage


unreached in proctype fram_tx
	quest2.pml:17, state 5, "cnt = (cnt+1)"
	quest2.pml:19, state 7, "tx!data"
	quest2.pml:20, state 8, "cnt = (cnt+1)"
	quest2.pml:23, state 12, "tx!flag"
	quest2.pml:26, state 15, "tx!flag"
	quest2.pml:29, state 20, "-end-"
	(6 of 20 states)
unreached in proctype fram_rx
	quest2.pml:50, state 14, "cnt = (cnt+1)"
	quest2.pml:60, state 25, "verifica = 1"
	quest2.pml:68, state 33, "cnt = (cnt+1)"
	quest2.pml:77, state 44, "-end-"
	(4 of 44 states)
unreached in claim limite
	_spin_nvr.tmp:10, state 13, "-end-"
	(1 of 13 states)

pan: elapsed time 0 seconds
```
