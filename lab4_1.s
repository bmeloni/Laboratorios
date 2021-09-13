.data                                    # indica ao SPIM que as próximas linhas são dados
# formatação
pular: .asciiz "\n"
tab: .asciiz "\t"

# mensagens
msg1: .asciiz "Digite o valor para a matriz:\n"
msg2: .asciiz "O reultado da operacao de matrizes eh:\n"
msg3: .asciiz "Digite os valores para a primeira matriz:\n"
msg4: .asciiz "Digite os valores para a segunda matriz:\n"
msg5: .asciiz "Digite os valores para a terceira matriz:\n"

# dimensões da matriz
dimensoes: .byte 4

# inicializando matrizes
arrayx: .double 0.0, 0.0, 0.0, 0.0,
        .double 0.0, 0.0, 0.0, 0.0,
        .double 0.0, 0.0, 0.0, 0.0,
        .double 0.0, 0.0, 0.0, 0.0,

arrayy: .double 0.0, 0.0, 0.0, 0.0,
        .double 0.0, 0.0, 0.0, 0.0,
        .double 0.0, 0.0, 0.0, 0.0,
        .double 0.0, 0.0, 0.0, 0.0,

arrayz: .double 0.0, 0.0, 0.0, 0.0,
        .double 0.0, 0.0, 0.0, 0.0,
        .double 0.0, 0.0, 0.0, 0.0,
        .double 0.0, 0.0, 0.0, 0.0,

.text
.globl main
main:
    lb $t1, dimensoes             # $s4 recebe o valor de dimensoes da matriz

    la $a2, arrayx                # coloca em $a2 o endereco do arrayx
    li $v0, 4                     # Codigo SysCall p/ escrever strings
    la $a0, msg3                  # Parametro (string a ser escrita)
    syscall
    jal pega_valor                # chama o procedimento para pegar os valores da matriz

    la $a2, arrayy                # coloca em $a2 o endereco do arrayy
    li $v0, 4                     # Codigo SysCall p/ escrever strings
    la $a0, msg4                  # Parametro (string a ser escrita)
    syscall
    jal pega_valor                # chama o procedimento para pegar os valores da matriz

    la $a2, arrayz                # coloca em $a2 o endereco do arrayz
    li $v0, 4                     # Codigo SysCall p/ escrever strings
    la $a0, msg5                  # Parametro (string a ser escrita)
    syscall
    jal pega_valor                # chama o procedimento para pegar os valores da matriz

    la $t9, arrayx
    la $a1, arrayy
    la $a2, arrayz
    jal calcular

    la $t9, arrayx
    jal print                     # chama o procedimento para printar a matriz resultado

    li $v0, 10                    # Codigo SysCall p/ encerrar o programa
    syscall


pega_valor:                  # Pegar valores para as matriz
    li $s0, 0                # i = 0
    li $s1, 0                # j = 0
    add $t2, $zero, $zero    # $t2 = tera o offset da posicao [i][j]
    li $v0, 4                # Codigo SysCall p/ escrever strings
    la $a0, msg1             # Parametro (string a ser escrita)
    syscall

pega_valor_L1:
    li $s1, 0                # i = 0; reset do loop

pega_valor_L2:
    sll $t2, $s0, 2          # $t2 = i ($s0) * 4 (byte)
    addu $t2, $t2, $s1       # $t2 = i ($s0) * 4 (byte) + j ($s1)
    sll $t2, $t2, 3        # $t3 = j ($s1) * 4 (bytes)
    addu $t2, $a2, $t2       # $t2 = tem o offset da posicao [i][j]

    li $v0, 7                # Codigo SysCall p/ ler um float
    syscall

    s.d $f0, 0($t2)         # salva valor na matriz z[i][j]

    addiu $s1, $s1, 1                   # $i = i + 1
    bne $s1, $t1, pega_valor_L2         # if (i != 4) go to pega_valor_L2

    addiu $s0, $s0, 1                   # $j = j + 1
    bne $s0, $t1, pega_valor_L1         # if (j != 4) go to pega_valor_L2

    jal $ra

calcular:
    li $s0, 0                   # j = 0; restart 2nd for loop

calcular_L1:
    li $s1, 0                   # j = 0; restart 2nd for loop

calcular_L2:
    li $s2, 0                   # k = 0; restart 3rd for loop
    sll $t2, $s0, 2             # $t2 = i * 32 (size of row of x)
    addu $t2, $t2, $s1          # $t2 = i * size(row) + j
    sll $t2, $t2, 3             # $t2 = byte offset of [i][j]
    addu $t2, $t9, $t2          # $t2 = byte address of x[i][j]
    l.d $f4, 0($t2)             # $f4 = 8 bytes of x[i][j]

calcular_L3:
    sll $t0, $s2, 2             # $t0 = k * 32 (size of row of z)
    addu $t0, $t0, $s1          # $t0 = k * size(row) + j
    sll $t0, $t0, 3             # $t0 = byte offset of [k][j]
    addu $t0, $a2, $t0          # $t0 = byte address of z[k][j]
    l.d $f16, 0($t0)            # $f16 = 8 bytes of z[k][j]
    sll $t0, $s0, 2             # $t0 = i*32 (size of row of y)
    addu $t0, $t0, $s2          # $t0 = i*size(row) + k
    sll $t0, $t0, 3             # $t0 = byte offset of [i][k]
    addu $t0, $a1, $t0          # $t0 = byte address of y[i][k]
    l.d $f18, 0($t0)            # $f18 = 8 bytes of y[i][k]
    mul.d $f16, $f18, $f16      # $f16 = y[i][k] * z[k][j]
    add.d $f4, $f4, $f16        # f4=x[i][j] + y[i][k]*z[k][j]
    addiu $s2, $s2, 1           # $k k + 1
    bne $s2, $t1, calcular_L3   # if (k != 32) go to L3
    s.d $f4, 0($t2)             # x[i][j] = $f4
    addiu $s1, $s1, 1           # $j = j + 1
    bne $s1, $t1, calcular_L2   # if (j != 32) go to L2
    addiu $s0, $s0, 1           # $i = i + 1
    bne $s0, $t1, calcular_L1   # if (i != 32) go to L1

    jal $ra                     # chama o procedimento para calcular a soma e printar a matriz

print:                       # faz as somas e printa os valores
    li $v0, 4                # Codigo SysCall p/ escrever strings
    la $a0, msg2             # Parametro (string a ser escrita)
    syscall
    li $s0, 0                # i = 0
    li $s1, 0                # j = 0
    add $t2, $zero, $zero    # $t2 = tera o offset da posicao [i][j]

print_L1:
    li $s1, 0                # i = 0; initialize 1st for loop

print_L2:

    sll $t2, $s0, 2          # $t2 = i ($s0) * 4 (bytes)
    addu $t2, $t2, $s1       # $t2 = i ($s0) * 4 (bytes) + j ($s1)
    sll $t2, $t2, 3          # $t3 = j ($s1) * 4 (bytes)
    addu $t6, $t9, $t2       # $t6 = tem o offset da posicao x[i][j]

    l.d $f12, 0($t6)          # $f8 = valor de x[i][j]

    li $v0, 3                # Codigo SysCall p/ escrever o valor da conversao
    syscall

    li $v0, 4                   # Codigo SysCall p/ escrever strings
    la $a0, tab               # Parametro (string a ser escrita)
    syscall

    addiu $s1, $s1, 1          # $i = i + 1
    bne $s1, $t1, print_L2     # if (i != 4) go to print_L2

    li $v0, 4                   # Codigo SysCall p/ escrever strings
    la $a0, pular               # Parametro (string a ser escrita)
    syscall

    #add $s1, $zero, $zero
    addiu $s0, $s0, 1        # $j = j + 1
    bne $s0, $t1, print_L1     # if (j != 4) go to print_L1

    jal $ra

jal $ra