# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: ethebaul <ethebaul@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/06/20 05:06:30 by ethebaul          #+#    #+#              #
#    Updated: 2025/08/04 19:33:42 by ethebaul         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

ISO_DIR				=	iso
NAME				=	$(ISO_DIR)/kernel.iso

BUILD_DIR			=	build
HEADERS_DIR			=	headers
SRCS_DIR			=	srcs

MKGENERATED			=	make/generated.mk
MKCOLOR				=	make/color.mk

CC					=	gcc
CFLAGS				=	-m64 -ffreestanding -fno-builtin -fno-stack-protector \
						-nostdlib -nostdinc -fno-pie -O2 \
						-Wall -Wextra -Werror -Wpedantic

AS					=	nasm
ASFLAGS				=	-felf64

LD					=	ld
LDFLAGS				=	-m elf_x86_64 -nostdlib --oformat binary -T srcs/linker.ld

all: $(MKGENERATED)
	@$(MAKE) --no-print-directory $(NAME)

.PHONY: $(MKGENERATED)
$(MKGENERATED):
	./configure

-include $(MKGENERATED) $(MKCOLOR)

.SILENT: $(NAME)
$(NAME): $(OBJS)
	@mkdir -p $(dir $@)
	echo -ne $(BLUE)$(NAME)$(RESET) " "
	$(LD) $(LDFLAGS) -o $(ISO_DIR)/kernel.bin $(OBJS)
	echo -e $(GREEN)Kernel Built Successfully$(RESET)

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
	rm -f $(MKGENERATED)

.PHONY: fclean
fclean: clean
	rm -f $(ISO_DIR)/kernel.bin
	rm -f $(NAME)

.SILENT: re
.PHONY: re
re: fclean
	$(MAKE) --no-print-directory all

.PHONY: run
run: all
	timeout -fs KILL 5.0s qemu-system-x86_64 -nographic iso/kernel.bin

.SILENT: compile_commands.json
compile_commands.json:
	@echo $(CC) $(CFLAGS) $(HEADERS) $(SRCS) | compiledb

-include $(DEPS)
