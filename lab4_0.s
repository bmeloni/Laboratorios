# Traduzir o código baixo para o MIPS e executá-lo
# float f2c (float fahr) {
# return ((5.0/9.0)*(fahr - 32.0));}
# – fahr em $f12, resultado em $f0, literais no espaço global de memória



.data
# mensagens
	msg1: .asciiz "\nEntre a temperatura em Fahrenith: "
	msg2: .asciiz "\nTemperatura em Celsius: "

# constantes
	const5: .float 5.0
	const9: .float 9.0
	const32: .float 32.0

.text
.globl main

main:
	li $v0, 4								# Carrega instrução de printar string
	la $a0, msg1							# Carrega msg1
	syscall									# Chama print

	li $v0, 6 								# Carrega instrução para ler float
	syscall 								# Lê float para $f0

	la	$t3, const5							# Carrega endereço de const5 em t3
	l.s $f16, 0($t3)						# Carrega valor do float em f16

	la $t3, const9							# Carrega endereço de const9 em t3
	l.s $f18, 0($t3)						# Carrega valor do float em f18

	la $t3, const32							# Carrega endereço de const32 em t3
	l.s $f20, 0($t3)						# Carrega valor do float em f20

	jal f2c									# Pula para f2c

	li $v0, 4								# Carrega instrução de printar string
	la $a0, msg2							# Carrega endereço de msg2
	syscall									# Printa msg2

	add.s $f12, $f0, $f12					# Passa o que está em f0 para f12

	li $v0, 2 								# Carrega instrução para printar float (Printa o que está em f12)
	syscall									# Printa float

	li $v0, 10								# Carrega instrução para sair
	syscall									# Finaliza o programa

f2c:
  sub $sp, $sp, 4             #salva RA na stack
	sw $ra, 0($sp)

	div.s $f16, $f16, $f18					# Divide f16 por f18 e salva em f16
	sub.s $f18, $f0, $f20					# Subtrai f0 por f20 e salva em f18
	mul.s $f0, $f16, $f18					# Multiplica f16 por f18 e salva em f0

  lw $ra, 0($sp)
	add $sp, $sp, 4
    
	jr $ra 									# Retorna para main