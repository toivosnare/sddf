/*
 * Copyright 2024, UNSW
 * SPDX-License-Identifier: BSD-2-Clause
 */

#include <os/sddf.h>
#include <sddf/serial/queue.h>
#include <sddf/util/printf.h>

#define FLUSH_CHAR '\n'

static sddf_channel tx_ch;
static serial_queue_handle_t *tx_queue_handle;

static uint32_t local_tail;

/* Ensure to call serial_putchar_init during initialisation. Multiplexes output based on \n or when buffer is full. */
void _sddf_putchar(char character)
{
    if (serial_queue_full(tx_queue_handle, local_tail) || serial_queue_full(tx_queue_handle, local_tail + 1)) {
        return;
    }

    if (character == '\n') {
        serial_enqueue_local(tx_queue_handle, &local_tail, '\r');
    }
    serial_enqueue_local(tx_queue_handle, &local_tail, character);

    /* Make changes visible to virtualiser if character is flush or if queue is now filled */
    if (serial_queue_full(tx_queue_handle, local_tail) || serial_queue_full(tx_queue_handle, local_tail + 1)
        || character == FLUSH_CHAR) {
        serial_update_shared_tail(tx_queue_handle, local_tail);
        sddf_notify(tx_ch);
    }
}

void sddf_putchar_unbuffered(char character)
{
    if (serial_queue_full(tx_queue_handle, local_tail)) {
        return;
    }

    serial_enqueue_local(tx_queue_handle, &local_tail, character);
    serial_update_shared_tail(tx_queue_handle, local_tail);
    sddf_notify(tx_ch);
}

/* Initialise the serial putchar library. */
void serial_putchar_init(sddf_channel serial_tx_ch, serial_queue_handle_t *serial_tx_queue_handle)
{
    tx_ch = serial_tx_ch;
    tx_queue_handle = serial_tx_queue_handle;
    local_tail = serial_tx_queue_handle->queue->tail;
}
