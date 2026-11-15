/* Print a line each time monitors are plugged in or unplugged, and once at
 * startup, until the compositor exits. Feeds `monitors watch`
 * (scripts/monitors.sh), which then lays them out again.
 *
 * wlr-output-management announces a head per connected monitor and ends
 * every batch of changes with `done`. Only heads coming and going count:
 * a new mode, scale or position (our own wlr-randr calls) prints nothing, so
 * applying a layout can't trigger another one. Monitors re-created on resume
 * from suspend count as plugged in again. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <wayland-client.h>
#include "wlr-output-management-unstable-v1-client-protocol.h"

static int changed = 1; /* the heads present at startup are news too */

static void noop() {}

static void head_finished(void *data, struct zwlr_output_head_v1 *head)
{
	changed = 1;
	zwlr_output_head_v1_destroy(head);
}

/* Version 2 (bound below) sends exactly these events */
static const struct zwlr_output_head_v1_listener head_listener = {
	.name = (void *)noop,
	.description = (void *)noop,
	.physical_size = (void *)noop,
	.mode = (void *)noop, /* mode objects get no listener: their events are dropped */
	.enabled = (void *)noop,
	.current_mode = (void *)noop,
	.position = (void *)noop,
	.transform = (void *)noop,
	.scale = (void *)noop,
	.finished = head_finished,
	.make = (void *)noop,
	.model = (void *)noop,
	.serial_number = (void *)noop,
};

static void manager_head(void *data, struct zwlr_output_manager_v1 *manager,
			 struct zwlr_output_head_v1 *head)
{
	changed = 1;
	zwlr_output_head_v1_add_listener(head, &head_listener, NULL);
}

static void manager_done(void *data, struct zwlr_output_manager_v1 *manager, uint32_t serial)
{
	if (!changed)
		return;
	changed = 0;
	puts("changed");
	fflush(stdout);
}

static void manager_finished(void *data, struct zwlr_output_manager_v1 *manager)
{
	exit(0);
}

static const struct zwlr_output_manager_v1_listener manager_listener = {
	.head = manager_head,
	.done = manager_done,
	.finished = manager_finished,
};

static struct zwlr_output_manager_v1 *manager;

static void global(void *data, struct wl_registry *registry, uint32_t name,
		   const char *interface, uint32_t version)
{
	if (strcmp(interface, zwlr_output_manager_v1_interface.name) == 0)
		manager = wl_registry_bind(registry, name, &zwlr_output_manager_v1_interface, 2);
}

static const struct wl_registry_listener registry_listener = {
	.global = global,
	.global_remove = (void *)noop,
};

int main(void)
{
	struct wl_display *display = wl_display_connect(NULL);
	if (!display) {
		fputs("river-outputs-watch: no Wayland display\n", stderr);
		return 1;
	}
	struct wl_registry *registry = wl_display_get_registry(display);
	wl_registry_add_listener(registry, &registry_listener, NULL);
	wl_display_roundtrip(display);
	if (!manager) {
		fputs("river-outputs-watch: no wlr-output-management\n", stderr);
		return 1;
	}
	zwlr_output_manager_v1_add_listener(manager, &manager_listener, NULL);
	while (wl_display_dispatch(display) != -1)
		;
	return 0;
}
