.data

# Matrizes de texto
# Uma matriz de texto � uma matriz em que cada elemento representa um tile de tiles_alfabeto.data, sendo usados
# para imprimir um nome geralmente curto na tela. Os labels est�o no formato matriz_texto_Y, onde Y � o texto
# que a matriz se refere

matriz_texto_atacar: .word 6, 1 
		     .byte 39,60,39,36,39,35
			
matriz_texto_defesa: .word 6, 1 
		       .byte 34,22,62,22,30,39

matriz_texto_item: .word 4, 1 
		     .byte 57,60,22,27
		     
matriz_texto_fugir: .word 5, 1 
		     .byte 62,40,61,57,35

matriz_texto_um: .word 3, 1 
		 .byte 40,69,77			# inclui espa�o no final
		     
matriz_texto_selvagem: .word 9, 1 
		     .byte 77,71,4,76,11,0,5,4,69	# inclui espa�o no come�o     	
		     
matriz_texto_apareceu: .word 9, 1 
		     .byte 0,9,0,70,4,2,4,73,74		# inclui exclama��o no final 

matriz_texto_escolha_o_seu_pokemon: .word 22, 1 		# inclui exclama��o no final 
		     .byte 22,71,2,8,76,6,0,77,8,77,71,4,73,77,24,25,26,29,27,25,28,74	
			
matriz_texto_escolhido: .word 11, 1 		# inclui espa�o no come�o e ponto no final
		.byte 77,4,71,2,8,76,6,78,3,8,54
		
matriz_texto_o_que_o: .word 8, 1 		# inclui espa�o no final
		.byte 25,77,10,73,4,77,8,77		

matriz_texto_vai: .word 4, 1 		# inclui espa�o no come�o
		.byte 77,11,0,78
		
matriz_texto_fazer: .word 6, 1 		# inclui interroga��o no final
		.byte 66,0,15,4,70,55

matriz_texto_tenta_fugir: .word 13, 1 		# inclui espa�o no come�o e exclama��o no final
		.byte 77,72,4,7,72,0,77,66,73,5,78,70,74
		
matriz_texto_tres_pontos: .word 2, 1 		# inclui espa�o no final
		.byte 65,77
		
matriz_texto_a_fuga_falhou: .word 14, 1 		# inclui ponto no final
		.byte 39,77,66,73,5,0,77,66,0,76,6,8,73,54
		
matriz_texto_a_fuga_funcionou: .word 17, 1 		# inclui exclama��o no final
		.byte 39,77,66,73,5,0,77,66,73,7,2,78,8,7,8,73,74
						
.text
		     			 			 
# ====================================================================================================== # 
# 						 COMBATE				                 #
# ------------------------------------------------------------------------------------------------------ #
# 													 #
# C�digo com os procedimentos necess�rios para renderizar e executar a logica das cenas de batalha	 # 
# do jogo.												 #
#												 	 # 
# ====================================================================================================== #

VERIFICAR_COMBATE:
	# Procedimento principal de combate.s, ele � chamado depois de cada procedimento de movimenta��o 
	# e verifica se: 1) o RED est� em um tile de grama e 2} de acordo com uma certa chance, verificar se 
	# esse tile vai iniciar um combate com um pokemon selvagem. Caso inicie o combate ele vai chamar
	# os outros procedimentos necess�rios

	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra
		
	lb t0, 0(s6)			# checa a posi��o do RED na matriz de movimenta��o (s6)
	li t1, 7			# 7 � codigo de um tile de grama
	bne t0, t1, FIM_VERIFICAR_COMBATE
	
	li a0, 5				# encontra um numero randomico entre 0 e 4
	call ENCONTRAR_NUMERO_RANDOMICO		
	bne a0, zero, FIM_VERIFICAR_COMBATE	# se o numero encontrado for 0 ent�o esse tile vai iniciar o
						# combate com um pokemon, desse modo o combate tem em teoria 
						# 1/5 chance de acontecer cada vez que o RED passa pela grama
		call EXECUTAR_COMBATE
	
	
	FIM_VERIFICAR_COMBATE:
	
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret 

# ====================================================================================================== #

EXECUTAR_COMBATE:
	# Procedimento que vai coordenar o combate do jogo, chamado todos os outros procedimentos necess�rios
	
	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra
		
	call INICIAR_TELA_DE_COMBATE		# inicia a tela de combate

	call INICIAR_POKEMON_INIMIGO	# imprime os sprites e outros elementos relacionados ao pokemon inimigo

	call INICIAR_POKEMON_RED	# imprime os sprites e outros elementos relacionados ao pokemon do RED

	LOOP_TURNOS_COMBATE:
	
		call TURNO_JOGADOR
		# como retorno a0 tem um numero especificando o que fazer (continuar, parar combate, etc)
		
		# se a0 == 1 o combate deve parar
		li t0, 1
		beq a0, t0, FIM_LOOP_TURNOS_COMBATE
			
		j LOOP_TURNOS_COMBATE
	
	FIM_LOOP_TURNOS_COMBATE:
	# indenpendente do que aconteceu no combate a �rea e o sprite do RED precisam ser impressos novamente
	# para que o jogo possa continuar
	
	call REIMPRIMIR_RED_E_AREA	
		
	FIM_EXECUTAR_COMBATE:
	
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret 	
	
# ====================================================================================================== #

INICIAR_TELA_DE_COMBATE:
	# Procedimento que vai imprimir um bal�o de exclama��o sobre o RED indicando que um combate vai acontecer,
	# e imprimir a tela de combate com todos os textos iniciais do menu de op��es

	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra

	# Espera alguns milisegundos	
		li a0, 800			# sleep 800 ms
		call SLEEP			# chama o procedimento SLEEP	

	# Imprimindo o bal�o de exclama��o sobre a cabe�a do RED no frame 0
	# O bal�o funciona que nem um tile normal, a diferen�a � que tem fundo transparente
	
	mv a0, s0			# calcula o endere�o de inicio do tile onde a cabe�a do RED est� (s0)
	call CALCULAR_ENDERECO_DE_TILE	# no frame 0
	
	# Imprimindo o bal�o de exclama��o no frame 0			
		la a0, balao_exclamacao		# carrega a imagem
		addi a0, a0, 8			# pula para onde come�a os pixels no .data
		# do retorno do procedimento CALCULAR_ENDERECO_DE_TILE a1 j� tem o endere�o de inicio 
		# do tile onde a cabe�a do RED est� 
		li a2, 16			# a2 = numero de colunas de um tile
		li a3, 16			# a3 = numero de linhas de um tile
		call PRINT_IMG

	# Espera alguns milisegundos	
		li a0, 1200			# sleep 1.2 s
		call SLEEP			# chama o procedimento SLEEP	

	call TROCAR_FRAME	# troca o frame sendo mostrado, mostrando o frame 1

	# De inicio � necess�rio imprimir alguns retangulos com a cor 190, isso porque os tiles do inventario
	# e combate s�o compartilhados para economizar memoria, ent�o especificamente os cantos da caixa
	# onde os dialogos e menu de a��o estar�o s�o transparentes, mas o ideal � que apare�a a cor do fundo
	# da tela de combate (190)

	# Calculando o endere�o de onde imprimir o primeiro retangulo
		li a1, 0xFF000000		# seleciona como argumento o frame 0
		li a2, 16 			# numero da coluna 
		li a3, 176			# numero da linha
		call CALCULAR_ENDERECO		
			
		mv a1, a0	# move o retorno para a1
			
		# Imprimindo o rentangulo com a cor
		li a0, 190		# a0 tem o valor do fundo do menu da tela do combate
		# a1 j� tem o endere�o de onde come�ar a impressao		
		li a2, 4		# numero de colunas da imagem da seta
		li a3, 48		# numero de linhas da imagem da seta			
		call PRINT_COR

		# Imprimindo o rentangulo com a cor
		li a0, 182		# a0 tem o valor do fundo do menu do inventario
		li a0, 190		# a0 tem o valor do fundo do menu da tela do combate
		li t0, -15075 		# -15075 = -48 * 320 + 285			
		add a1, a1, t0		# o proximo retangulo come�a a -48 linhas e 285 colunas de onde o ultimo
					# terminou de ser impresso
		li a2, 4		# numero de colunas da imagem da seta
		li a3, 48		# numero de linhas da imagem da seta			
		call PRINT_COR
		
	# Agora imprime a tela de combate no frame 0 com os textos necess�rios
		# Imprimindo a tela no frame 0
		la a0, matriz_tiles_tela_combate	# carrega a matriz de tiles
		la a1, tiles_combate_e_inventario	# carrega a imagem com os tiles
		li a2, 0xFF000000			# os tile ser�o impressos no frame indicado por t6
		call PRINT_TILES

		# Imprimindo os textos do menu de combate no frame 0
			# Calculando o endere�o de onde imprimir o primeiro texto (ATACAR) no frame 0
			li a1, 0xFF000000	# seleciona o frame 0
			li a2, 195		# numero da coluna 
			li a3, 185		# numero da linha
			call CALCULAR_ENDERECO	
			
			mv a1, a0		# move o retorno para a1
			
			# Imprime o texto com o ATACAR
			# a1 j� tem o endere�o de onde imprimir o texto
			la a4, matriz_texto_atacar 	
			call PRINT_TEXTO
			
			# Imprime o texto com o FUGIR
			addi a1, a1, 18		# pelo PRINT_TEXTO acima a1 ainda est� no ultimo endere�o onde
						# imprimiu o tile, de modo que est� a 18 colunas do proximo texto
			la a4, matriz_texto_fugir 	
			call PRINT_TEXTO
			
			# Imprime o texto com o DEFESA
			addi a1, a1, -95	# pelo PRINT_TEXTO acima a1 ainda est� no ultimo endere�o onde
			li t0, 5440		# imprimiu o tile, de modo que est� a -95 colunas e +17 linhas
			add a1, a1, t0		# do proximo texto (5440 = 17 * 320)
			la a4, matriz_texto_defesa 	
			call PRINT_TEXTO
			
			# Imprime o texto com o ITEM
			addi a1, a1, 18		# pelo PRINT_TEXTO acima a1 ainda est� no ultimo endere�o onde
						# imprimiu o tile, de modo que est� a 18 colunas do proximo texto
			la a4, matriz_texto_item 	
			call PRINT_TEXTO
												
	call TROCAR_FRAME	# troca o frame sendo mostrado, mostrando o frame 0

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret 

# ====================================================================================================== #																																			

INICIAR_POKEMON_INIMIGO:
	# Procedimento que atualiza o valor de s11 com o pokemon inimigo e imprime todos os sprites,
	# anima��es e textos relacionados a esse pokemon aparecendo na tela

	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra
	
	# Primeiro sorteia qual � o pokemon inimigo, atualiza os primeiros bits de s11 com o codigo correto,
	# e escolhe a matriz de texto correta com o nome do pokemon (t5)
	
	li a0, 5				# encontra um numero randomico entre 0 e 4
	call ENCONTRAR_NUMERO_RANDOMICO		
	
	# se a0 == 0 ent�o � pokemon inimigo ser� o BULBASAUR 
	li s11, BULBASAUR 			# codigo do BULBASAUR
	la t5, matriz_texto_bulbasaur		# carrega a matriz de texto do pokemon
	beq a0, zero, PRINT_TEXTO_POKEMON_INIMIGO
			
	# se a0 == 1 ent�o � pokemon inimigo ser� o CHARMANDER 
	li t0, 1	
	li s11, CHARMANDER 			# codigo do CHARMANDER	
	la t5, matriz_texto_charmander		# carrega a matriz de texto do pokemon	
	beq a0, t0, PRINT_TEXTO_POKEMON_INIMIGO
			
	# se a0 == 2 ent�o � pokemon inimigo ser� o SQUIRTLE 
	li t0, 2	
	li s11, SQUIRTLE 			# codigo do SQUIRTLE
	la t5, matriz_texto_squirtle		# carrega a matriz de texto do pokemon				
	beq a0, t0, PRINT_TEXTO_POKEMON_INIMIGO
										
	# se a0 == 3 ent�o � pokemon inimigo ser� o CATERPIE 
	li t0, 3	
	li s11, CATERPIE 			# codigo do CATERPIE	
	la t5, matriz_texto_caterpie		# carrega a matriz de texto do pokemon			
	beq a0, t0, PRINT_TEXTO_POKEMON_INIMIGO
	
	# se a0 == 4 ent�o � pokemon inimigo ser� o DIGLETT 
	li t0, 4	
	li s11, DIGLETT 			# codigo do DIGLETT
	la t5, matriz_texto_diglett		# carrega a matriz de texto do pokemon		
	
	PRINT_TEXTO_POKEMON_INIMIGO:
	
	mv t6, a0	# salva em t6 o numero do pokemon escolhido
	
	# Agora imprime o texto "Um YYY selvagem apareceu!", onde YYY � o nome do pokemon
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 1
	
		# Calculando o endere�o de onde imprimir o primeiro texto (Um) no frame 0
			li a1, 0xFF000000	# seleciona o frame 0
			li a2, 28		# numero da coluna 
			li a3, 185		# numero da linha
			call CALCULAR_ENDERECO	
			
			mv a1, a0		# move o retorno para a1

		# Imprime o texto com o 'Um '
		# a1 j� tem o endere�o de onde imprimir o texto
		la a4, matriz_texto_um 	
		call PRINT_TEXTO
		
		# Imprime o texto com o nome do Pokemon
		# pelo PRINT_TEXTO acima a1 ainda est� no ultimo endere�o onde imprimiu o tile,
		# de modo que est� na posi��o exata do proximo texto
		mv a4, t5		# a4 recebe a matriz de texto do pokemon decidido acima
		call PRINT_TEXTO

		# Imprime o texto com o ' selvagem'
		# pelo PRINT_TEXTO acima a1 ainda est� no ultimo endere�o onde imprimiu o tile,
		# de modo que est� na posi��o exata do proximo texto
		la a4, matriz_texto_selvagem 	
		call PRINT_TEXTO
		
		# Calculando o endere�o de onde imprimir o ultimo texto ('apareceu!') no frame 0
			li a1, 0xFF000000	# seleciona o frame 0
			li a2, 28		# numero da coluna 
			li a3, 201		# numero da linha
			call CALCULAR_ENDERECO	
			
			mv a1, a0		# move o retorno para a1		
					
		# Imprime o texto com o 'apareceu!'
		# a1 j� tem o endere�o de onde imprimir o texto					
		la a4, matriz_texto_apareceu 	
		call PRINT_TEXTO
			
		# Por fim, imprime uma pequena seta indicando que o jogador pode apertar ENTER para avan�ar
		# o dialogo						
			# Calculando o endere�o de onde imprimir a seta no frame 0
			li a1, 0xFF000000	# seleciona o frame 0
			li a2, 159		# numero da coluna 
			li a3, 207		# numero da linha
			call CALCULAR_ENDERECO											
			
			mv t3, a0		# move o retorno para t3		
						
			# Imprimindo a imagem da seta no frame 0
			la a0, seta_proximo_dialogo_combate		# carrega a imagem				
			mv a1, t3		# t3 tem o endere�o de onde imprimir a imagem
			lw a2, 0(a0)		# numero de colunas da imagem
			lw a3, 4(a0)		# numero de linhas da imagem
			addi a0, a0, 8		# pula para onde come�a os pixels no .data	
			call PRINT_IMG																							
																																																											
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 0
	
	# Espera o jogador apertar ENTER	
	LOOP_ENTER_POKEMON_INIMIGO:
		call VERIFICAR_TECLA
		
		li t0, 10		# 10 � o codigo do ENTER	
		bne a0, t0, LOOP_ENTER_POKEMON_INIMIGO
	
	# Limpa a caixa de dialogo no frame 0 somente para indicar que o n�o mais necess�rio apertar ENTER					
		# Para retirar a imagem da seta basta imprimir uma �rea de mesmo tamanho com a cor
		# de fundo do inventario
		li a0, 0xFF		# a0 tem o valor do fundo do menu da caixa de dialogo (branco)
		mv a1, t3		# t3 ainda tem o endere�o de onde a seta est�		
		li a2, 10		# numero de colunas da imagem da seta
		li a3, 6		# numero de linhas da imagem da seta	
		call PRINT_COR						
							
	# Agora renderiza o pokemon inimigo aparecendo na tela
		mv a0, t6		# t6 ainda tem o numero do pokemon escolhido
		li a5, 0		# a5 = 0 para renderizar o pokemon inimigo
		call RENDERIZAR_POKEMON
																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																						
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret 

# ====================================================================================================== #

INICIAR_POKEMON_RED:
	# Procedimento que atualiza o valor de s11 com o pokemon do RED e imprime todos os sprites,
	# anima��es e textos relacionados a esse pokemon aparecendo na tela

	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra

	# Replica o frame 0 no frame 1 para que os dois estejam iguais
	li a0, 0xFF000000	# copia o frame 0 no frame 1
	li a1, 0xFF100000
	li a2, 320		# numero de colunas a serem copiadas
	li a3, 240		# numero de linhas a serem copiadas
	call REPLICAR_FRAME

	call TROCAR_FRAME	# inverte o frame sendo mostrado, mostrando o frame 1

	# Primeiro limpa a caixa de dialogo	
		# Calculando o endere�o de onde come�ar a limpeza no frame 0
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 28		# numero da coluna 
		li a3, 185		# numero da linha
		call CALCULAR_ENDERECO	

		mv t5, a0		# move o retorno para t5

		# Imprimindo o rentangulo com a cor de fundo da caixa no frame 0
		li a0, 0xFF		# a0 tem o valor do fundo da caixa
		mv a1, t5		# t5 tem o endere�o de onde come�ar a impressao		
		li a2, 147		# numero de colunas da imagem da seta
		li a3, 30		# numero de linhas da imagem da seta			
		call PRINT_COR
					
	# Agora imprime o texto "Escolha o seu POK�MON!"
		mv a1, t5	# o texto ser� impresso no mesmo endere�o onde a limpeza foi feita acima
		la a4, matriz_texto_escolha_o_seu_pokemon 	
		call PRINT_TEXTO	

		# Por fim, imprime uma pequena seta indicando que o jogador pode apertar ENTER para avan�ar
		# o dialogo						
		# Calculando o endere�o de onde imprimir a seta no frame 0
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 159		# numero da coluna 
		li a3, 207		# numero da linha
		call CALCULAR_ENDERECO											
		
		mv t3, a0		# move o retorno para t3		
									
		# Imprimindo a imagem da seta no frame 0
		la a0, seta_proximo_dialogo_combate		# carrega a imagem				
		mv a1, t3 		# t3 tem o endere�o de onde imprimir a imagem
		lw a2, 0(a0)		# numero de colunas da imagem
		lw a3, 4(a0)		# numero de linhas da imagem
		addi a0, a0, 8		# pula para onde come�a os pixels no .data	
		call PRINT_IMG	

	call TROCAR_FRAME	# inverte o frame sendo mostrado, mostrando o frame 0

	# Espera o jogador apertar ENTER	
	LOOP_ENTER_ESCOLHER_POKEMON_RED:
		call VERIFICAR_TECLA
		
		li t0, 10		# 10 � o codigo do ENTER	
		bne a0, t0, LOOP_ENTER_ESCOLHER_POKEMON_RED
	
	# Antes � necess�rio preparar o frame 1 para mostrar o inventario
		# Limpa a caixa de dialogo no frame 0 somente para indicar que n�o mais necess�rio apertar ENTER					
		# Para retirar a imagem da seta basta imprimir uma �rea de mesmo tamanho com a cor
		# de fundo do inventario
		li a0, 0xFF		# a0 tem o valor do fundo do menu da caixa de dialogo (branco)
		mv a1, t3		# t3 ainda tem o endere�o de onde a seta est�		
		li a2, 10		# numero de colunas da imagem da seta
		li a3, 6		# numero de linhas da imagem da seta	
		call PRINT_COR	
	
		# De inicio copia o que acabou de ser impresso no frame 0 (o texto na caixa de dialogo) para
		# o frame 1
		mv a0, t5	# a copia se inicio no frame 0 no mesmo endere�o onde o texto foi impresso
		li t0, 0x00100000
		add a1, t5, t0	# a copia vai para o endere�o de a0, mas no frame 1
		li a2, 148		# numero de colunas a serem copiadas
		li a3, 32		# numero de linhas a serem copiadas
		call REPLICAR_FRAME	
		
		# Depois limpa algumas partes do frame de modo que s� o que vai aparecer � a caixa de dialogo
		# e o inventario
			# Calculando o endere�o de onde come�ar a limpeza no frame 1
			li a1, 0xFF100000	# seleciona o frame 1
			li a2, 32		# numero da coluna 
			li a3, 32		# numero da linha
			call CALCULAR_ENDERECO	

			mv a1, a0		# move o retorno para a1

			# Imprimindo o rentangulo com a cor de fundo da tela de combate no frame 1
			li a0, 190		# a0 tem o valor do fundo do menu da tela do combate
			# a1 j� tem o endere�o de onde come�ar a impressao		
			li a2, 128		# numero de colunas da area a ser impressa
			li a3, 4		# numero de linhas da area a ser impressa		
			call PRINT_COR	
						
			# Imprimindo o rentangulo com a cor de fundo da tela de combate no frame 1
			li a0, 190		# a0 tem o valor do fundo do menu da tela do combate
			# a1 j� tem o endere�o de onde come�ar a impressao		
			li a2, 26		# numero de colunas da area a ser impressa
			li a3, 28		# numero de linhas da area a ser impressa		
			call PRINT_COR
							
			# Imprimindo o rentangulo com a cor de fundo da tela de combate no frame 1
			li a0, 190		# a0 tem o valor do fundo do menu da tela do combate
			li t0, 21440		# 24017 = 67 * 320 
			add a1, a1, t0		# o proximo retangulo come�a a 75 linhas de 
						# onde o ultimo terminou de ser impresso
			li a2, 24		# numero de colunas da area a ser impressa
			li a3, 26		# numero de linhas da area a ser impressa		
			call PRINT_COR											

			# Imprimindo o rentangulo com a cor de fundo da tela de combate no frame 1
			li a0, 190		# a0 tem o valor do fundo do menu da tela do combate
			li t0, -28568		# -28568 = -90 * 320 + 232
			add a1, a1, t0		# o proximo retangulo come�a a -90 linhas e 232 colunas de 
						# onde o ultimo terminou de ser impresso
			li a2, 23		# numero de colunas da area a ser impressa
			li a3, 28		# numero de linhas da area a ser impressa	
			call PRINT_COR	
																																					
	li a5, 1		# a5 = 1 porque o inventario foi mostrado atrav�s do combate
	call MOSTRAR_INVENTARIO	

	# do retorno de MOSTRAR_INVENTARIO a0 tem um valor de 0 a 4 representando a op��o, e consequentemente,
	# qual pokemon o jogador escolheu

	mv t6, a0	# salva o numero do pokemon escolhido em t6

	# Primeiro encontra a matriz de texto correta com o nome do pokemon (t5) e atualiza o valor de s11
	# com o codigo do pokemon do RED

	# se a0 == 0 ent�o � pokemon escolhido � o BULBASAUR 
	la t5, matriz_texto_bulbasaur		# carrega a matriz de texto do pokemon
	li t1, BULBASAUR
	beq a0, zero, PRINT_TEXTO_POKEMON_RED
			
	# se a0 == 1 ent�o � pokemon escolhido � o CHARMANDER 
	li t0, 1	
	la t5, matriz_texto_charmander		# carrega a matriz de texto do pokemon	
	li t1, CHARMANDER	
	beq a0, t0, PRINT_TEXTO_POKEMON_RED
			
	# se a0 == 2 ent�o � pokemon escolhido � o SQUIRTLE 
	li t0, 2	
	la t5, matriz_texto_squirtle		# carrega a matriz de texto do pokemon	
	li t1, SQUIRTLE					
	beq a0, t0, PRINT_TEXTO_POKEMON_RED
										
	# se a0 == 3 ent�o � pokemon escolhido � o CATERPIE 
	li t0, 3	
	la t5, matriz_texto_caterpie		# carrega a matriz de texto do pokemon
	li t1, CATERPIE					
	beq a0, t0, PRINT_TEXTO_POKEMON_RED
	
	# se a0 == 4 ent�o � pokemon escolhido � o DIGLETT 
	la t5, matriz_texto_diglett		# carrega a matriz de texto do pokemon	
	li t1, DIGLETT							
	
	PRINT_TEXTO_POKEMON_RED:
	
	slli t1, t1, 11		# coloca o codigo do pokemon escolhido depois dos 11 bits do pokemon inimgo
	add s11, s11, t1	# em s11
	
	# Agora imprime o texto "O YYY foi escolhido.", onde YYY � o nome do pokemon
	
	# Limpa a caixa de dialogo	
		# Calculando o endere�o de onde come�ar a limpeza no frame 0
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 28		# numero da coluna 
		li a3, 185		# numero da linha
		call CALCULAR_ENDERECO	

		mv a1, a0		# move o retorno para t5

		# Imprimindo o rentangulo com a cor de fundo da caixa no frame 0
		li a0, 0xFF		# a0 tem o valor do fundo da caixa
		# a1 j� tem o endere�o de onde come�ar a impressao		
		li a2, 147		# numero de colunas da imagem da seta
		li a3, 30		# numero de linhas da imagem da seta			
		call PRINT_COR
	
	# Replica o frame 0 no frame 1 para que os dois estejam iguais
		li a0, 0xFF000000	# copia o frame 0 no frame 1
		li a1, 0xFF100000
		li a2, 320		# numero de colunas a serem copiadas
		li a3, 240		# numero de linhas a serem copiadas
		call REPLICAR_FRAME
			
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 1
	
		# Calculando o endere�o de onde imprimir o primeiro texto ('O ') no frame 0
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 28		# numero da coluna 
		li a3, 185		# numero da linha
		call CALCULAR_ENDERECO	
			
		mv a1, a0		# move o retorno para a1
	
		# Imprime o texto com o nome do Pokemon
		# a1 j� tem o endere�o de onde imprimir o texto
		mv a4, t5		# a4 recebe a matriz de texto do pokemon decidido acima
		call PRINT_TEXTO

		# Imprime o texto com o ('escolhido.')
		# pelo PRINT_TEXTO acima a1 ainda est� no ultimo endere�o onde imprimiu o tile,
		# de modo que est� na posi��o exata do proximo texto
		la a4, matriz_texto_escolhido 	
		call PRINT_TEXTO
			
	# Por fim, imprime uma pequena seta indicando que o jogador pode apertar ENTER para avan�ar
	# o dialogo						
		# Calculando o endere�o de onde imprimir a seta no frame 0
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 159		# numero da coluna 
		li a3, 207		# numero da linha
		call CALCULAR_ENDERECO											
			
		mv t3, a0		# move o retorno para t3		
						
		# Imprimindo a imagem da seta no frame 0
		la a0, seta_proximo_dialogo_combate		# carrega a imagem				
		mv a1, t3		# t3 tem o endere�o de onde imprimir a imagem
		lw a2, 0(a0)		# numero de colunas da imagem
		lw a3, 4(a0)		# numero de linhas da imagem
		addi a0, a0, 8		# pula para onde come�a os pixels no .data	
		call PRINT_IMG																							
																																																											
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 0
	
	# Espera o jogador apertar ENTER	
	LOOP_ENTER_POKEMON_ESCOLHIDO:
		call VERIFICAR_TECLA
		
		li t0, 10		# 10 � o codigo do ENTER	
		bne a0, t0, LOOP_ENTER_POKEMON_ESCOLHIDO
	
	# Limpa a caixa de dialogo no frame 0 somente para indicar que o n�o mais necess�rio apertar ENTER					
		# Para retirar a imagem da seta basta imprimir uma �rea de mesmo tamanho com a cor
		# de fundo do inventario
		li a0, 0xFF		# a0 tem o valor do fundo do menu da caixa de dialogo (branco)
		mv a1, t3		# t3 ainda tem o endere�o de onde a seta est�		
		li a2, 10		# numero de colunas da imagem da seta
		li a3, 6		# numero de linhas da imagem da seta	
		call PRINT_COR					
																																																																																																																		
	# Agora renderiza o pokemon do RED aparecendo na tela
		mv a0, t6		# t6 ainda tem o numero do pokemon escolhido
		li a5, 1		# a5 = 1 para renderizar o pokemon do RED
		call RENDERIZAR_POKEMON

	# Replica o frame 0 no frame 1 para que os dois estejam iguais
		li a0, 0xFF000000	# copia o frame 0 no frame 1
		li a1, 0xFF100000
		li a2, 320		# numero de colunas a serem copiadas
		li a3, 240		# numero de linhas a serem copiadas
		call REPLICAR_FRAME																								
																																																																								
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret 
																																																																																																																																																																																																																																																																																											
# ====================================================================================================== #

TURNO_JOGADOR:
	# Procedimento que coordena o turno do jogador, fazendo chamadas aos procedimentos de a��o 
	# (atacar, defender, item e fugir) de acordo com os inputs do jogador
	#
	# Retorno:
	# 	a0 = [ 0 ] se o combate deve continuar
	#	     [ 1 ] se o combate deve parar  

	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra
		
	# Primeiro encontra a matriz de texto com o nome do pokemon escolhido pelo RED
	srli t0, s11, 11	# os primeiros 11 bits de s11 s�o o codigo do pokemon inimigo e os proximos 11
				# s�o do pokemon do RED

	# Transforma o codigo do pokemon em uma matriz de texto
	la t6, matriz_texto_bulbasaur		# carrega a matriz de texto do pokemon
	li t1, BULBASAUR
	beq t0, t1, TURNO_JOGADOR_PRINT_TEXTO
			
	la t6, matriz_texto_charmander		# carrega a matriz de texto do pokemon	
	li t1, CHARMANDER	
	beq t0, t1, TURNO_JOGADOR_PRINT_TEXTO
			
	la t6, matriz_texto_squirtle		# carrega a matriz de texto do pokemon	
	li t1, SQUIRTLE				
	beq t0, t1, TURNO_JOGADOR_PRINT_TEXTO
										
	la t6, matriz_texto_caterpie		# carrega a matriz de texto do pokemon	
	li t1, CATERPIE		
	beq t0, t1, TURNO_JOGADOR_PRINT_TEXTO
	
	la t6, matriz_texto_diglett		# carrega a matriz de texto do pokemon	
	
	TURNO_JOGADOR_PRINT_TEXTO:
	
	# Agora imprime o texto "O que o YYY deve fazer?", onde YYY � o nome do pokemon
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 1

		# Primeiro limpa a caixa de dialogo	
		# Calculando o endere�o de onde come�ar a limpeza no frame 0
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 28		# numero da coluna 
		li a3, 185		# numero da linha
		call CALCULAR_ENDERECO	

		mv a1, a0		# move o retorno para a1

		# Imprimindo o rentangulo com a cor de fundo da caixa no frame 0
		li a0, 0xFF		# a0 tem o valor do fundo da caixa
		# a1 j� tem o endere�o de onde come�ar a impressao		
		li a2, 147		# numero de colunas da imagem da seta
		li a3, 30		# numero de linhas da imagem da seta			
		call PRINT_COR	
	
		# Replica o frame 0 no frame 1 para que os dois estejam iguais
		li a0, 0xFF000000	# copia o frame 0 no frame 1
		li a1, 0xFF100000
		li a2, 320		# numero de colunas a serem copiadas
		li a3, 240		# numero de linhas a serem copiadas
		call REPLICAR_FRAME
			
		# Calculando o endere�o de onde imprimir o primeiro texto ('O que o ') no frame 0
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 28		# numero da coluna 
		li a3, 185		# numero da linha
		call CALCULAR_ENDERECO	
			
		mv a1, a0		# move o retorno para a1

		# Imprime o texto com o 'O que o  '
		# a1 j� tem o endere�o de onde imprimir o texto
		la a4, matriz_texto_o_que_o 	
		call PRINT_TEXTO
		
		# Imprime o texto com o nome do Pokemon
		# pelo PRINT_TEXTO acima a1 ainda est� no ultimo endere�o onde imprimiu o tile,
		# de modo que est� na posi��o exata do proximo texto
		mv a4, t6		# a4 recebe a matriz de texto do pokemon decidido acima
		call PRINT_TEXTO

		# Imprime o texto com o ' vai'
		# pelo PRINT_TEXTO acima a1 ainda est� no ultimo endere�o onde imprimiu o tile,
		# de modo que est� na posi��o exata do proximo texto
		la a4, matriz_texto_vai	
		call PRINT_TEXTO
		
		# Calculando o endere�o de onde imprimir o ultimo texto ('fazer?') no frame 0
		li a1, 0xFF000000	# seleciona o frame 0
		li a2, 28		# numero da coluna 
		li a3, 201		# numero da linha
		call CALCULAR_ENDERECO	
			
		mv a1, a0		# move o retorno para a1
				
		# Imprime o texto com o ('fazer?')
		# a1 j� tem o endere�o de onde imprimir o texto					
		la a4, matriz_texto_fazer 	
		call PRINT_TEXTO
	
		call TROCAR_FRAME	# inverte o frame, mostrando o frame 0
			
	call RENDERIZAR_MENU_DE_COMBATE

	# Como retorno de RENDERIZAR_MENU_DE_COMBATE a0 tem o valor da op��o selecionada pelo jogador
	# Ent�o � decidido a partir de a0 qual procedimento do menu chamar
					
	li t0, 1
	bne a0, t0, FIM_TURNO_JOGADOR
		# se a op��o selecionada for 1 ent�o chama a a��o de fugir																																																																										
		call ACAO_FUGIR
		# como retorno a0 == 0 se o combate deve continuar e 1 caso contr�rio, esse retorno ser�
		# propagado para EXECUTAR_COMBATE
	
	FIM_TURNO_JOGADOR:

	# dos procedimentos de a��o do jogador chamados acima a0 teve ter um retorno especificando o que 
	# EXECUTAR_COMBATE deve fazer (continuar combate, terminar combate, etc)
																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																													
	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret	

# ------------------------------------------------------------------------------------------------------ #
# Abaixo seguem os procedimentos de a��o do jogador, esses procedimentos s�o chamados atrav�s do menu	 #
# de combate durante TURNO_JOGADOR									 #
# Todos os procedimentos tem o mesmo retorno, indicando se o combate deve continuar ou n�o		 #
# Al�m disso, todos devem terminar com o frame 0 e frame 1 iguais					 #
# ------------------------------------------------------------------------------------------------------ #

ACAO_FUGIR:
	# A a��o de fugir tem uma chance de 1/3 de n�o funcionar, caso funcione simplesmente termina o combate
	#
	# Retorno:
	# 	a0 = [ 0 ] se o combate deve continuar
	#	     [ 1 ] se o combate deve parar e voltar ao loop do jogo 
	
	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra
	
	# Primeiro limpa a caixa de dialogo no frame 1	
	# Calculando o endere�o de onde come�ar a limpeza no frame 1
	li a1, 0xFF000000	# seleciona o frame 1
	li a2, 28		# numero da coluna 
	li a3, 185		# numero da linha
	call CALCULAR_ENDERECO	

	mv t5, a0		# move o retorno para t5

	# Imprimindo o rentangulo com a cor de fundo da caixa no frame 1
	li a0, 0xFF		# a0 tem o valor do fundo da caixa
	mv a1, t5		# t5 tem o endere�o de onde come�ar a impressao		
	li a2, 147		# numero de colunas da imagem da seta
	li a3, 30		# numero de linhas da imagem da seta			
	call PRINT_COR	
		
	# Agora imprime o texto ('YYY tenta fugir!)', onde YYY � o nome do pokemon do RED		
	# Calculando o endere�o de onde imprimir o primeiro texto ('O ') no frame 1
	li a1, 0xFF100000	# seleciona o frame 1
	li a2, 28		# numero da coluna 
	li a3, 185		# numero da linha
	call CALCULAR_ENDERECO	
			
	mv a1, a0		# move o retorno para a1

	# Imprime o texto com o nome do Pokemon
	# a1 j� tem o endere�o de onde imprimir o texto
	mv a4, t6		# t6 ainda tem a matriz de texto do pokemon do RED 
	call PRINT_TEXTO

	# Imprime o texto com o ' tenta fugir!'
	# pelo PRINT_TEXTO acima a1 ainda est� no ultimo endere�o onde imprimiu o tile,
	# de modo que est� na posi��o exata do proximo texto
	la a4, matriz_texto_tenta_fugir	
	call PRINT_TEXTO			

	# Por fim, imprime uma pequena seta indicando que o jogador pode apertar ENTER para avan�ar
	# o dialogo						
	# Calculando o endere�o de onde imprimir a seta no frame 1
	li a1, 0xFF100000	# seleciona o frame 0
	li a2, 159		# numero da coluna 
	li a3, 207		# numero da linha
	call CALCULAR_ENDERECO											
		
	mv a1, a0		# move o retorno para a1		
									
	# Imprimindo a imagem da seta no frame 0
	la a0, seta_proximo_dialogo_combate		# carrega a imagem				
	# a1 j� tem o endere�o de onde imprimir a imagem
	lw a2, 0(a0)		# numero de colunas da imagem
	lw a3, 4(a0)		# numero de linhas da imagem
	addi a0, a0, 8		# pula para onde come�a os pixels no .data	
	call PRINT_IMG	
		
	call TROCAR_FRAME	# inverte o frame, mostrando o frame 1		

	# Replica a caixa de dialogo do frame 1 no frame 0 para que os dois estejam iguais	
	li t0, 0x00100000
	add a0, t5, t0		# a0 recebe o endere�o de t5 no frame 1		
	mv a1, t5		# t5 tem o endere�o da caixa no frame 0
	li a2, 264		# numero de colunas a serem copiadas
	li a3, 32		# numero de linhas a serem copiadas
	call REPLICAR_FRAME
														
	# Espera o jogador apertar ENTER	
	LOOP_ENTER_TENTA_FUGIR:
		call VERIFICAR_TECLA
		
		li t0, 10		# 10 � o codigo do ENTER	
		bne a0, t0, LOOP_ENTER_TENTA_FUGIR
			
	# Imprimindo o rentangulo com a cor de fundo da caixa no frame 1
	li a0, 0xFF		# a0 tem o valor do fundo da caixa
	mv a1, t5		# t5 ainda tem o endere�o de onde come�ar a impressao		
	li a2, 147		# numero de colunas da imagem da seta
	li a3, 15		# numero de linhas da imagem da seta			
	call PRINT_COR			
	
	# Agora imprime o texto ('... YYY)', onde YYY � a mensagem se a fuga foi bem sucedida ou nao	
	# Calculando o endere�o de onde imprimir o primeiro texto ('...') no frame 0
	li a1, 0xFF000000	# seleciona o frame 0
	li a2, 28		# numero da coluna 
	li a3, 185		# numero da linha
	call CALCULAR_ENDERECO	
			
	mv a1, a0		# move o retorno para a1

	# Imprime o texto ('...')
	# a1 j� tem o endere�o de onde imprimir o texto
	la a4, matriz_texto_tres_pontos
	call PRINT_TEXTO
	
	mv t2, a1		# pelo PRINT_TEXTO acima a1 ainda est� no ultimo endere�o onde imprimiu o tile,
				# de modo que est� na posi��o exata do proximo texto
			
	call TROCAR_FRAME	# inverte o frame, mostrando o frame 0	

	# Replica a caixa de dialogo do frame 0 no frame 1 para que os dois estejam iguais	
	mv a0, t5		# t5 tem o endere�o da caixa no frame 0		
	li t0, 0x00100000
	add a1, t5, t0		# a0 recebe o endere�o de t5 no frame 1		
	li a2, 264		# numero de colunas a serem copiadas
	li a3, 32		# numero de linhas a serem copiadas
	call REPLICAR_FRAME	

	call TROCAR_FRAME	# inverte o frame, mostrando o frame 1	
													
	# Espera o jogador apertar ENTER	
	LOOP_ENTER_ACAO_FUGIR_TRES_PONTOS:
		call VERIFICAR_TECLA
		
		li t0, 10		# 10 � o codigo do ENTER	
		bne a0, t0, LOOP_ENTER_ACAO_FUGIR_TRES_PONTOS
										
	# Escolhe um numero randomico de 0 a 2, se o numero for 0 ent�o a fuga nao foi bem sucedida
	li a0, 2
	call ENCONTRAR_NUMERO_RANDOMICO
		
	bne a0, zero, FUGA_FUNCIONOU

	# -------------------------------------------------------

	# A fuga falhou se a0 == 0

	# Imprime o texto com o ' a fuga falhou' no frame 0
	mv a1, t2	# pelo PRINT_TEXTO anterior t2 ainda tem salvo o endere�o onde o ultimo tile
			# foi impresso, de modo que est� na posi��o exata do proximo texto
	la a4, matriz_texto_a_fuga_falhou
	call PRINT_TEXTO	
	
	li t2, 0		# t2 recebe 0 para indicar que o combate deve continuar
	
	j FIM_ACAO_FUGA		
	
	# -------------------------------------------------------
	
	FUGA_FUNCIONOU:		
	
	# A fuga falhou se a0 != 0

	# Imprime o texto com o ' a fuga funcionou!' no frame 0
	mv a1, t2	# pelo PRINT_TEXTO anterior t2 ainda tem salvo o endere�o onde o ultimo tile
			# foi impresso, de modo que est� na posi��o exata do proximo texto
	la a4, matriz_texto_a_fuga_funcionou
	call PRINT_TEXTO
		
	li t2, 1		# t2 recebe 1 para indicar que o combate n�o deve continuar
													
	# -------------------------------------------------------
		
FIM_ACAO_FUGA:
	call TROCAR_FRAME	# inverte o frame, mostrando o frame 0
	
	# Espera o jogador apertar ENTER	
	LOOP_ENTER_ACAO_FUGIR_FALHOU:
		call VERIFICAR_TECLA
	
		li t0, 10		# 10 � o codigo do ENTER	
		bne a0, t0, LOOP_ENTER_ACAO_FUGIR_FALHOU	
			
	# Replica a caixa de dialogo do frame 0 no frame 1 para que os dois estejam iguais	
	mv a0, t5		# t5 tem o endere�o da caixa no frame 0		
	li t0, 0x00100000
	add a1, t5, t0		# a0 recebe o endere�o de t5 no frame 1		
	li a2, 264		# numero de colunas a serem copiadas
	li a3, 32		# numero de linhas a serem copiadas
	call REPLICAR_FRAME		

	mv a0, t2	# como retorno a0 recebe o valor de t2 decidido anteriormente, indicando se o combate
			# deve continuar ou n�o

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret																							
																																
# ====================================================================================================== #

RENDERIZAR_MENU_DE_COMBATE:
	# Procedimento que torna o menu de combate responsivo aos controles do jogador. Quando chamado o 
	# procedimento vai imprimir uma seta que pode ser movida pelo jogador entre as 4 op��es do menu,
	# e com ENTER essa ope��o pode ser selecionada.
	#
	# Retorno:
	#	a0 = n�mero de 0 a 3 representado a op��o que o jogador selecionou, onde
	#		[ 0 ] -> ATACAR 
	#		[ 1 ] -> FUGIR
	#		[ 2 ] -> DEFESA  
	#		[ 3 ] -> ITEM  			  

	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra
	
	li t4, 0		# o menu come�a com a primeira op��o selecionada (ATACAR)
	
	LOOP_SELECIONAR_OPCAO_MENU_DE_COMBATE:
		# Primeiro imprime uma imagem de uma seta indicando a op��o selecionada		
	   		# Calculando o endere�o de onde a seta ser� impressa
			li a1, 0xFF000000	# seleciona o frame 0
			li a2, 187		# numero da coluna onde a seta da primeira op��o est�
			li a3, 185		# numero da linha onde a seta da primeira op��o est�	
			
			# O numero da coluna e linha onde a seta ser� impressa � dependente da op��o selecionada
			li t0, 1
			beq t4, t0, COMBATE_SETA_OPCOES_1_3
			li t0, 3
			beq t4, t0, COMBATE_SETA_OPCOES_1_3
			j COMBATE_SETA_CHECAR_OPCAO_2_3
			
			COMBATE_SETA_OPCOES_1_3:
			# Caso a op��o selecionada for a 1 ou 3 ent�o a coluna � movida por +60 pixels		
			addi a2, a2, 60
			
			COMBATE_SETA_CHECAR_OPCAO_2_3: 
			li t0, 2
			blt t4, t0, COMBATE_SETA_CALCULAR_ENDERE�O
			
			# Caso a op��o selecionada for a 2 ou 3 ent�o a linha � movida por +17											
			addi a3, a3, 17
			
			COMBATE_SETA_CALCULAR_ENDERE�O:
			call CALCULAR_ENDERECO		
				
			mv t3, a0		# move o retorno para t3
			
			# Imprimindo a seta		
			la a0, tiles_alfabeto	
			addi a0, a0, 8		# pula para onde come�a os pixels no .data
			li t0, 6720		# a imagem dessa seta pode ser encontrada em tiles_alfabeto
			add a0, a0, t0		# a 6720 (8 (tamanho de uma linha da imagem) * 840 (numero da 
						# linha onde esse tile come�a)) pixels de distancia do come�o
			mv a1, t3		# t3 tem o endere�o de onde imprimir a seta
			li a2, 8		# numero de colunas da imagem 
			li a3, 15		# numero de linhas da imagem 	
			call PRINT_IMG	
		
		# Agora seleciona a op��o mudando os pixels do texto da op��o por pixels azuis
			# Via de regra o endere�o de onde o texto est� sempre fica a 9 colunas e 2 linhas 
			# de distancia da seta
			
			addi t5, t3, 649	# t5 recebe o endere�o de onde o texto est� a partir do 
						# endere�o da seta (t3)
						# 649 = (320 * 2 linhas) + 9 colunas
			
			# Selecionado a op��o
			li a0, 0		# a0 == 0 -> selecionar a op��o
			mv a1, t5		# t5 tem o endere�o de onde o texto est�
			li a2, 9		# numero de linhas de pixels do texto
			li a3, 41		# numero de colunas de pixels do texto
			call SELECIONAR_OPCAO_MENU
	
		LOOP_SELECIONAR_OPCAO_COMBATE:
		
		# Agora � incrementado ou decrementado o valor de t4 de acordo com o input do jogador
		call VERIFICAR_TECLA
		
		li t0, 'w'
		beq a0, t0, OPCAO_W_COMBATE
		
		li t0, 'a'
		beq a0, t0, OPCAO_A_COMBATE
		
		li t0, 's'
		beq a0, t0, OPCAO_S_COMBATE
		
		li t0, 'd'
		beq a0, t0, OPCAO_D_COMBATE	
		
		# Se o jogador apertar ENTER ele quer selecionar essa op��o
		li t0, 10		# 10 � o codigo do ENTER
		beq a0, t0, FIM_RENDERIZAR_MENU_DE_COMBATE																					
		
		j LOOP_SELECIONAR_OPCAO_COMBATE				
																				
		OPCAO_W_COMBATE:
		# se a op��o atual for 0 ou 1 ent�o n�o � possivel subir mais no menu
		li t0, 1
		ble t4, t0, LOOP_SELECIONAR_OPCAO_COMBATE
		addi t4, t4, -2			# passa t4 para a op��o acima 
		j OPCAO_TROCADA_COMBATE	
		
		OPCAO_A_COMBATE:
		# se a op��o atual for 0 ou 2 ent�o n�o � possivel ir mais para a esquerda no menu
		beq t4, zero, LOOP_SELECIONAR_OPCAO_COMBATE		
		li t0, 2
		beq t4, t0, LOOP_SELECIONAR_OPCAO_COMBATE
		addi t4, t4, -1			# passa t4 para a op��o a esquerda 
		j OPCAO_TROCADA_COMBATE
		
		OPCAO_S_COMBATE:
		# se a op��o atual for 2 ou 3 ent�o n�o � possivel descer mais no menu
		li t0, 2
		beq t4, t0, LOOP_SELECIONAR_OPCAO_COMBATE		
		li t0, 3
		beq t4, t0, LOOP_SELECIONAR_OPCAO_COMBATE
		addi t4, t4, 2			# passa t4 para a op��o abaixo 
		j OPCAO_TROCADA_COMBATE
				
		OPCAO_D_COMBATE:
		# se a op��o atual for 1 ou 3 ent�o n�o � possivel ir mais para a direita no menu
		li t0, 1
		beq t4, t0, LOOP_SELECIONAR_OPCAO_COMBATE		
		li t0, 3
		beq t4, t0, LOOP_SELECIONAR_OPCAO_COMBATE
		addi t4, t4, 1			# passa t4 para a op��o a direita

		OPCAO_TROCADA_COMBATE:
		# Se ocorreu uma troca de op��o � necess�rio retirar a sele��o da op��o atual e limpar a tela
			# Retirando a sele��o da op��o
			li a0, 1		# a0 == 1 -> retirar sele��o
			mv a1, t5		# t5 ainda tem o endere�o de onde o texto da ultima op��o
						# selecionada est�
			li a2, 9		# numero de linhas de pixels do texto
			li a3, 41		# numero de colunas de pixels do texto
			call SELECIONAR_OPCAO_MENU
			
			# Para retirar a imagem da seta basta imprimir uma �rea de mesmo tamanho com a cor
			# de fundo do menu
			li a0, 0xFF		# a0 tem o valor do fundo do menu
			addi a1, t5, -9		# volta o endere�o de t5 por 9 colunas de modo que a1
						# agora tem o endere�o de onde a seta est� e onde a limpeza
						# vai acontecer			
			li a2, 6		# numero de colunas da imagem da seta
			li a3, 11		# numero de linhas da imagem da seta			
			call PRINT_COR
					
			j LOOP_SELECIONAR_OPCAO_MENU_DE_COMBATE

	FIM_RENDERIZAR_MENU_DE_COMBATE:

	mv a0, t4		# como retorno move para a0 o valor da op��o selecioanada

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret	

# ====================================================================================================== #

RENDERIZAR_POKEMON:
	# Procedimento auxiliar a INICIAR_POKEMON_INIMIGO e INICIAR_POKEMON_RED que tem como objetivo
	# renderizar o sprite de um pokemon, o seu nome e sua barra de vida na tela de combate.
	# Dependendo do argumento a5 os elementos v�o ser impressos em posi��es diferentes na tela.
	#
	# Argumento:
	#	a0 = n�mero de 0 a 4 representando o pokemon a ser renderizado. 
	#	     [ 0 ] -> BULBASAUR
	#	     [ 1 ] -> CHARMANDER
	#	     [ 2 ] -> SQUIRTLE
	#	     [ 3 ] -> CATERPIE
	#	     [ 4 ] -> DIGLETT
	#	a5 = [ 0 ] -> renderiza o pok�mon inimigo
	#	     [ 1 ] -> renderiza o pok�mon do RED	
	
	addi sp, sp, -4		# cria espa�o para 1 word na pilha
	sw ra, (sp)		# empilha ra

	# Primeiro encontra a partir de a0 o endere�o da imagem do pokemon (t5) e a matriz de texto com
	# o nome do pokemon (t6)
	
	la t5, pokemons			# t5 tem o inicio da imagem do BULBASAUR
	addi t5, t5, 8			# pula para onde come�a os pixels no .data	
	li t0, 1482			# 1482 = 38 * 39 = tamanho de uma imagem de um pokemon, ou seja,
	mul t0, t0, a0			# passa o endere�o de t5 para a imagem do pokemon correto de acordo com a0
	add t5, t5, t0

	# se a0 == 0 ent�o � pokemon inimigo ser� o BULBASAUR 
	la t6, matriz_texto_bulbasaur		# carrega a matriz de texto do pokemon
	beq a0, zero, PRINT_POKEMON
			
	# se a0 == 1 ent�o � pokemon inimigo ser� o CHARMANDER 
	li t0, 1	
	la t6, matriz_texto_charmander		# carrega a matriz de texto do pokemon	
	beq a0, t0, PRINT_POKEMON
			
	# se a0 == 2 ent�o � pokemon inimigo ser� o SQUIRTLE 
	li t0, 2	
	la t6, matriz_texto_squirtle		# carrega a matriz de texto do pokemon				
	beq a0, t0, PRINT_POKEMON
										
	# se a0 == 3 ent�o � pokemon inimigo ser� o CATERPIE 
	li t0, 3	
	la t6, matriz_texto_caterpie		# carrega a matriz de texto do pokemon			
	beq a0, t0, PRINT_POKEMON
	
	# se a0 == 4 ent�o � pokemon inimigo ser� o DIGLETT 
	li t0, 4	
	la t6, matriz_texto_diglett		# carrega a matriz de texto do pokemon	
	
	PRINT_POKEMON:
																																																	
	# Imprime a imagem do pokemon aparecendo na tela no frame 0	
		# Calculando o endere�o de onde imprimir o pokemon dependendo de a5
		li a1, 0xFF000000	# seleciona o frame 0
		
		# Onde o pokemon inimigo deve ser impresso
		li a2, 204		# numero da coluna 
		li a3, 43		# numero da linha
		beq a5, zero, RENDERIZAR_POKEMON_PRINT_SPRITE
		
		# Onde o pokemon do RED deve ser impresso
		li a2, 76		# numero da coluna 
		li a3, 107		# numero da linha
				
		RENDERIZAR_POKEMON_PRINT_SPRITE:
		
		call CALCULAR_ENDERECO	
		
		mv t3, a0		# move o retorno para t3
		
		# Imprime a silhueta do pokemon		
		mv a0, t5	# t5 ainda tem a imagem do pokemon que foi decidido no inicio procedimento				
		mv a1, t3	# t3 tem o endere�o de onde imprimir a imagem
		li a2, 38	# numero de colunas da imagem
		li a3, 39	# numero de linhas da imagem
		mv a4, a5	# a5 j� tem o numero correto indicando se a silheta � invertida ou n�o
		call PRINT_POKEMON_SILHUETA
	
		# Espera alguns milisegundos	
		li a0, 800			# sleep 800 ms
		call SLEEP			# chama o procedimento SLEEP	
			
		# Imprime a imagem completa do pokemon		
		mv a0, t5	# t5 ainda tem a imagem do pokemon que foi decidido no inicio procedimento				
		mv a1, t3	# t3 tem o endere�o de onde imprimir a imagem
		li a2, 38	# numero de colunas da imagem
		li a3, 39	# numero de linhas da imagem
		
		# decide de acordo com a5 se o pokemon deve ser impresso de forma invertida ou n�o
		bne a5, zero, PRINT_POKEMON_INVERTIDO
				
		call PRINT_IMG
		j PRINT_INFORMACOES_DO_POKEMON
		
		PRINT_POKEMON_INVERTIDO:
				
		call PRINT_IMG_INVERTIDA
	
	PRINT_INFORMACOES_DO_POKEMON:
																	
	# Imprime a imagem da caixa com as informa��es do pokemon (nome, vida, etc) no frame 0
		# Calculando o endere�o de onde imprimir a caixa dependendo de a5
		li a1, 0xFF000000	# seleciona o frame 0
					
		# Onde imprimir a caixa do pokemon inimigo			
		li a2, 32		# numero da coluna 
		li a3, 32		# numero da linha
		beq a5, zero, RENDERIZAR_POKEMON_PRINT_CAIXA
				
		# Onde imprimir a caixa do pokemon do RED			
		li a2, 176		# numero da coluna 
		li a3, 112		# numero da linha	
		
		RENDERIZAR_POKEMON_PRINT_CAIXA:
				
		call CALCULAR_ENDERECO	
		
		mv a2, a0		# move o retorno para a2
		
		# Imprime a caixa do pokemon
		la a0, matriz_tiles_caixa_pokemon_combate	# carrega a matriz de tiles
		la a1, tiles_caixa_pokemon_combate		# carrega a imagem com os tiles
		# a2 j� tem o endere�o de onde imprimir os tiles
		call PRINT_TILES
	
		# Imprime uma pequena seta indicando a orienta��o dessa caixa 
		# Calculando o endere�o de onde imprimir a seta e a imagem da seta dependendo de a5
		li a1, 0xFF000000	# seleciona o frame 0
					
		# Onde imprimir a seta da caixa do pokemon inimigo			
		li a2, 154		# numero da coluna 
		li a3, 55		# numero da linha
		la t2, seta_direcao_caixa_pokemon_combate	# carrega a imagem
		addi t2, t2, 8					# pula para onde come�a os pixels no .data		
		beq a5, zero, RENDERIZAR_POKEMON_PRINT_SETA_DE_CAIXA
				
		# Onde imprimir a seta da caixa do pokemon do RED
		addi t2, t2, 135	# passa o endere�o de t2 para a proxima seta na imagem			
		li a2, 167		# numero da coluna 
		li a3, 135		# numero da linha	
		
		RENDERIZAR_POKEMON_PRINT_SETA_DE_CAIXA:
				
		call CALCULAR_ENDERECO	
		
		mv a1, a0		# move o retorno para a1
		
		# Imprime a seta 
		mv a0, t2	# t2 tem a imagem da seta correta		
		# a1 j� tem o endere�o de onde imprimir a imagem
		li a2, 15	# numero de colunas da imagem
		li a3, 9	# numero de linhas da imagem
		call PRINT_IMG

		# Imprime o nome do pokemon na caixa
		# Calculando o endere�o de onde imprimir o nome na caixa dependendo de a5
		li a1, 0xFF000000	# seleciona o frame 0
					
		# Onde imprimir o nome do pokemon inimigo			
		li a2, 37		# numero da coluna 
		li a3, 35		# numero da linha
		beq a5, zero, RENDERIZAR_POKEMON_PRINT_NOME
				
		# Onde imprimir o nome do pokemon do RED
		li a2, 181		# numero da coluna 
		li a3, 115		# numero da linha	
		
		RENDERIZAR_POKEMON_PRINT_NOME:
		
		call CALCULAR_ENDERECO	
		
		mv a1, a0		# move o retorno para a1
		
		# Imprime o texto com o nome do Pokemon
		# a1 tem o endere�o de onde imprimir o nome
		mv a4, t6	# a4 recebe a matriz de texto do pokemon decidido anteriormente no procedimento	
		call PRINT_TEXTO							

		# Imprime a barra de vida
		# Calculando o endere�o de onde imprimir a barra dependendo de a5
		li a1, 0xFF000000	# seleciona o frame 0
		
		# Onde imprimir a barra do pokemon inimigo			
		li a2, 48		# numero da coluna 
		li a3, 50		# numero da linha
		beq a5, zero, RENDERIZAR_POKEMON_PRINT_BARRA_DE_VIDA
						
		# Onde imprimir a barra do pokemon do RED
		li a2, 192		# numero da coluna 
		li a3, 130		# numero da linha	
		
		RENDERIZAR_POKEMON_PRINT_BARRA_DE_VIDA:		
		
		call CALCULAR_ENDERECO	
		
		mv a1, a0		# move o retorno para a1
		
		# Imprime a imagem da barra de vida
		la a0, combate_barra_de_vida	# carrega a imagem
		# a1 j� tem o endere�o de onde imprimir a imagem
		lw a2, 0(a0)	# numero de colunas da imagem
		lw a3, 4(a0)	# numero de linhas da imagem
		addi a0, a0, 8			# pula para onde come�a os pixels no .data								
		call PRINT_IMG		
		
		# Imprime a vida do pokemon
		# Todos os pokemons tem uma vida de 45 pontos
		
		# Calculando o endere�o de onde imprimir o primeiro numero (4) dependendo de a5
		li a1, 0xFF000000	# seleciona o frame 0
		
		# Onde imprimir a vida do pokemon inimigo			
		li a2, 122		# numero da coluna 
		li a3, 37		# numero da linha
		beq a5, zero, RENDERIZAR_POKEMON_PRINT_PONTOS_DE_VIDA
						
		# Onde imprimir a vida do pokemon do RED
		li a2, 266		# numero da coluna 
		li a3, 117		# numero da linha	
		
		RENDERIZAR_POKEMON_PRINT_PONTOS_DE_VIDA:			
		
		call CALCULAR_ENDERECO			
		
		mv a1, a0		# move o retorno para a1
		
		# O loop come�a imprimindo o numero 4
		la a0, tiles_numeros	
		addi a0, a0, 8		# pula para onde come�a os pixels no .data	
		addi a0, a0, 240 	# 240 = 60 (area de uma imagem de um numero) * 4, ou seja,
					# a0 passa para o inico do tile com o numero 4
					
		li t3, 5		# numero de simbolos a serem impressos 	
				
		LOOP_POKEMON_PRINT_VIDA:
		# Imprimindo o numero 
		# a0 j� tem o endere�o da imagem do numero (ou /)			
		# a1 j� tem o endere�o de onde imprimir o numero
		li a2, 6		# numero de colunas dos tiles a serem impressos
		li a3, 10		# numero de linhas dos tiles a serem impressos	
		call PRINT_IMG										

		addi t3, t3, -1		# decrementa o numero de simbolos restantes

		# Pelo PRINT_IMG o endere�o de a0 j� est� no inicio da imagem do 5
		# pelo PRINT_IMG acima a1 est� naturalmente a -10 linhas +7 colunas de onde imprimir o proximo
		# numero
		li t0, -3193		# -3193 = -10 * 320 + 7
		add a1, a1, t0	
		
		# Pelo PRINT_IMG o endere�o de a0 j� est� no inicio da imagem do 5				
		li t0, 4
		beq t3, t0, LOOP_POKEMON_PRINT_VIDA	# se t3 == 4 imprime o 5
		
		la a0, caractere_barra	
		addi a0, a0, 8		# pula para onde come�a os pixels no .data							
		li t0, 3		
		beq t3, t0, LOOP_POKEMON_PRINT_VIDA	# se t3 == 3 imprime uma imagem de uma barra (/)
			
		la a0, tiles_numeros	
		addi a0, a0, 8		# pula para onde come�a os pixels no .data	
		addi a0, a0, 240 	# 240 = 60 (area de uma imagem de um numero) * 4, ou seja,
					# a0 passa para o inico do tile com o numero 4
		li t0, 2
		beq t3, t0, LOOP_POKEMON_PRINT_VIDA	# se t3 == 2 imprime o 4	
				
		addi a0, a0, 60 	# Pelos calculos acima o endere�o de a0 est� a 60 pixels do inicio 
					# da imagem do 5
		bne t3, zero, LOOP_POKEMON_PRINT_VIDA	# se t3 == 1 imprime o 5
	
	# Espera alguns milisegundos	
		li a0, 800			# sleep 800 ms
		call SLEEP			# chama o procedimento SLEEP	

	lw ra, (sp)		# desempilha ra
	addi sp, sp, 4		# remove 1 word da pilha
	
	ret	
	
# ====================================================================================================== #
																																																																			
PRINT_POKEMON_SILHUETA:
	# Procedimento que imprime a silhueta de um pokemon na tela. Por silhueta entende-se uma imagem	
	# de um pokemon em pokemons.bmp, s� que ao inves de imprimir a imagem normalmente o pokemon ser�
	# impresso apenas com pixels rosa, imprimindo s� o "formato" do pokemon.
	# O procedimente tem suporte para imprimir a silheta de forma imvertida
	#
	# Argumentos: 
	# 	a0 = endere�o da imagem	do pokemon	
	# 	a1 = endere�o de onde, no frame escolhido, a imagem deve ser renderizada
	# 	a2 = numero de colunas da imagem
	#	a3 = numero de linhas da imagem
	#	a4 = [ 0 ] -> se a silhueta for impressa na orienta��o normal
	#	     [ 1 ] -> se a sulhueta deve ser impressa de forma invertida
	
	mul t0, a4, a2		# Caso a4 == 1 a imagem deve ser impressa de forma invertida ent�o o endere�o
	add a0, a0, t0		# de a0 deve estar no final da primeira linha
	li t0, -1
	mul t0, t0, a4
	add a0, a0, t0		# tamb�m � necessario voltar o endere�o por 1 coluna (por motivos desconhecidos)	
		
	PRINT_POKEMON_SILHUETA_LINHAS:
		mv t1, a2		# copia do numero de a2 para usar no loop de colunas
			
		PRINT_POKEMON_SILHUETA_COLUNAS:
			lbu t2, 0(a0)			# pega 1 pixel do .data e coloca em t2
			
			# Se o valor do pixel do .data (t2) for 0xC7 (pixel transparente), 
			# o novo pixel n�o � armazenado no bitmap, de modo que somente ser�o impressos os pixels
			# de cor t0 no lugar dos pixels que fazem parte da imagem do pokemon em si
			li t0, 0xC7		# cor do pixel transparente
			beq t2, t0, NAO_IMPRIMIR_PIXEL_DO_POKEMON
				li t0, 231		# t0 tem o valor da cor (rosa) que ser� usada para fazer a
							# impress�o do pokemon
				sb t0, 0(a1)		# pega o pixel de t0 (cor rosa) e coloca no bitmap
	
			NAO_IMPRIMIR_PIXEL_DO_POKEMON:
			addi t1, t1, -1			# decrementa o numero de colunas restantes

			addi a0, a0, 1			# vai para o pr�ximo pixel da imagem
									
			li t0, -2		# Caso a4 == 1 a imagem deve ser impressa de forma invertida 
			mul t0, a4, t0		# ent�o o endere�o de a0 precisa ser decrementado (-1)
			add a0, a0, t0		# (-2 porque foi somado 1 acima)		
			
			addi a1, a1, 1			# vai para o pr�ximo pixel do bitmap
			bne t1, zero, PRINT_POKEMON_SILHUETA_COLUNAS	# reinicia o loop se t1 != 0
				
		sub a1, a1, a2			# volta o ende�o do bitmap pelo numero de colunas impressas
		addi a1, a1, 320		# passa o endere�o do bitmap para a proxima linha

		mul t0, a4, a2		# Caso a4 == 1 a imagem deve ser impressa de forma invertida ent�o o
		add a0, a0, t0		# endere�o de a0 deve estar no final da proxima linha a ser impressa,
		add a0, a0, t0		# o que requer soma t0 duas vezes
				
		addi a3, a3, -1			# decrementando o numero de linhas restantes
				
		bne a3, zero, PRINT_POKEMON_SILHUETA_LINHAS	# reinicia o loop se a3 != 0
			
	ret
	
# ====================================================================================================== #
	
.data
	.include "../Imagens/combate/matriz_tiles_tela_combate.data"
	.include "../Imagens/combate/seta_proximo_dialogo_combate.data"				
	.include "../Imagens/combate/tiles_caixa_pokemon_combate.data"	
	.include "../Imagens/combate/matriz_tiles_caixa_pokemon_combate.data"					
	.include "../Imagens/combate/seta_direcao_caixa_pokemon_combate.data"									
	.include "../Imagens/combate/combate_barra_de_vida.data"																		
	.include "../Imagens/outros/caractere_barra.data"																		
