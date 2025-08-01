/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   kernel.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: ethebaul <ethebaul@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/07/31 23:28:50 by ethebaul          #+#    #+#             */
/*   Updated: 2025/08/01 01:33:18 by ethebaul         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "kernel.h"

static inline t_u8	vga_entry_color(t_vga_color fg, t_vga_color bg)
{
	return (fg | bg << 4);
}

static inline t_u16	vga_entry(t_u8 uc, t_u8 color)
{
	return ((t_u16) uc | (t_u16) color << 8);
}

static void	kprint(const char *str)
{
	t_u16	*vga_memory;
	t_u8	color;
	t_u64	i;

	i = 0;
	vga_memory = (t_u16 *) 0xB8000;
	while (i < (VGA_HEIGHT * VGA_WIDTH))
	{
		color = vga_entry_color(VGA_COLOR_WHITE, VGA_COLOR_BLACK);
		vga_memory[i] = vga_entry(' ', color);
		++i;
	}
	while (str[i])
	{
		color = vga_entry_color(VGA_COLOR_WHITE, VGA_COLOR_BLACK);
		vga_memory[i] = vga_entry(str[i], color);
		++i;
	}
}

void	kernel_entrypoint(void)
{
	kprint("Test");
	while (1)
	{
		__asm__("hlt");
	}
}
