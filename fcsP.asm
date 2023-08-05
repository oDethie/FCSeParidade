
# THIAGO ZANGIACOMI DIAS / GUILHERME ALVES PAULINO

.data
    file: .asciiz "C:/Users/zandi/OneDrive/Desktop/projetoFinal/dados.txt" #Quando copiar o caminho do FILE, troque o '\' por '/', pois poderá ocorrer problema na leitura do arquivo.
    									  #e saída ficara zerada.
    B1: .space 256
    B2: 
    	.align 0
    	.space 256
    zero: .asciiz "0"
    um: .asciiz "1"
    arq: .asciiz "Conteúdo de B1: "
    msg_xor: .asciiz "\nResultado final do cálculo do FCS: "
    pl: .asciiz "\n"
    paridade_b2: .asciiz "Paridade calculada:\n"
    
.text
    main:
        # Abrir o arquivo
        li $v0, 13           # Código do serviço de abertura de arquivo
        la $a0, file         # Endereço da string com o nome do arquivo
        li $a1, 0            # Modo de leitura (0 para leitura)
        syscall              # Executa o serviço

        move $s0, $v0        # Salva o descritor de arquivo em $s0

        # Ler o conteúdo do arquivo
        li $v0, 14           # Código do serviço de leitura de arquivo
        move $a0, $s0        # Move o descritor de arquivo para $a0
        la $a1, B1     # Endereço do buffer de leitura
        li $a2, 256         # Tamanho máximo a ser lido
        syscall              # Executa o serviço
        
        # Fechar o arquivo
        li $v0, 16
        move $a0, $s0       
        syscall
        
        jal zeraReg
        
        jal imprime_b1
        
        li $v0, 4
        la $a0, pl    
        syscall
        
        jal zeraReg
        jal calcula_xor
        
        li $v0, 4
        la $a0, pl    
        syscall
        
        jal zeraReg
        
        la $a1, B1
        jal paridade
            
	li $v0, 10
	syscall
	
zeraReg:
	li $t0, 0
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t6, 0
	li $t7, 0
	
	jr $ra

imprime_b1:
	li $v0, 4 
        la $a0, arq 
        syscall              
    b1: lb $t1, B1($t0)
	beq $t2, 256, fim_imprime
	li $v0, 11
	move $a0, $t1
	syscall
	addi $t0, $t0, 1
	addi $t2, $t2, 1
	j b1
fim_imprime: jr $ra

calcula_xor:
	lb $t1, B1($t0)
	beq $t2, 256, fim_xor
	
	
	xor $t3, $t3, $t1
	addi $t0, $t0, 1
	addi $t2, $t2, 1
	j calcula_xor
	
fim_xor:
	li $v0, 4
	la $a0, msg_xor
	syscall
	
	li $v0, 1
	move $a0, $t3
	syscall
	
	jr $ra

paridade:
	li $v0, 4
        la $a0, paridade_b2
        syscall

p:  lb $t1, 0($a1)      # Lê o próximo caractere do buffer
    beq $t2, 256, fim_paridade   # Se chegar ao final do buffer, sai do loop

    # Calcula a paridade do caractere
    move $t4, $t1        # Salva o valor do caractere em $t4
    li $t5, 0           # Inicializa o contador de bits 1 em 0

    calc_paridade:
        
         andi $t6, $t4, 1     # valor Binario de $t4 AND 00000001
         add $t5, $t5, $t6    # Soma o valor do bit ao contador de bits 1
         srl $t4, $t4, 1     # Desloca o caractere para a direita
         bnez $t4, calc_paridade  # Se o caractere ainda tiver bits, continua o loop -> Se não for 00000000, ele volta para calc
         andi $t5, $t5, 1    # Obtém o bit menos significativo do contador de bits 1 -> Faz o AND 00000001 com o numero que ficou em $t5
     	 
     	 beq $t5, $zero, salva_b2_zero
         bne $t5, $zero, salva_b2_um
         
         addi $a1, $a1, 1
         j paridade
        
fim_paridade: jr $ra

salva_b2_zero:
	li $v0, 1
	move $a0, $t5
	syscall
	lb $s0, zero
	sb $s0, B2($t0)
	addi $a1, $a1, 1
	addi $t0, $t0, 1
	addi $t2, $t2, 1
	addi $t7, $t7, 1
	addi $t3, $t3, 1
	beq $t3, 64, pl_p
	beq $t7, 8, espaco
        j p
        
salva_b2_um:
	li $v0, 1
	move $a0, $t5
	syscall
	lb $s0, um
	sb $s0, B2($t0)
	addi $a1, $a1, 1
	addi $t0, $t0, 1
	addi $t2, $t2, 1
	addi $t7, $t7, 1
	addi $t3, $t3, 1
	beq $t3, 64, pl_p
	beq $t7, 8, espaco
        j p

espaco:
	li $v0, 11
	la $a0, ' '
	syscall
	li $t7, 0
	j p

pl_p:
	li $v0, 4
	la $a0, pl
	syscall
	li $t3, 0
	li $t7, 0
	j p
