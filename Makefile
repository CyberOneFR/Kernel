# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ethebaul <ethebaul@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/06/20 05:06:30 by ethebaul          #+#    #+#              #
#    Updated: 2025/08/04 19:24:32 by ethebaul         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

BUILD_DIR			=	./build/
HEADERS_DIR			=	./headers/
SRCS_DIR			=	./srcs/

MKCONFIGURE			=	./make/configure.mk
MKGENERATED			=	./make/generated.mk
MKCOLOR				=	./make/color.mk

CC					=	gcc
AS					=	as
ld					=	ld
CCFLAGS				=	-m64 -ffreestanding -fno-builtin -fno-stack-protector \
						-nostdlib -nostdinc -fno-pie -no-pie \
						-std=gnu99 -O2 -Wall -Wextra -Werror
ASFLAGS				=	--64
LDFLAGS				=	-m elf_x86_64 -nostdlib -T kernel.ld

NAME				=	kernel

all: $(NAME)
	@echo -e $(GREEN)Kernel Built Successfully$(RESET)

-include $(MKCONFIGURE) $(MKGENERATED) $(MKCOLOR)

$(NAME): $(OBJS)
	@$(LD) $(LDFLAGS) -o $@ $(OBJS)
	@echo -e $(BLUE)$(NAME)$(RESET) compiling: $@

clangd:
	@rm -rf ./.cache
	@rm -rf compile_commands.json
	@echo $(CC) $(CCFLAGS) $(HEADERS) $(SRCS) | compiledb

clean:
	@rm -rf $(BUILD_DIR)

fclean: clean
	@rm -f $(NAME)

re: fclean all

-include $(DEPS)

.PHONY : all clean fclean re clangd