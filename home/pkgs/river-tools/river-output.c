/* Print the name of river's focused output (e.g. "HDMI-A-1"). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <wayland-client.h>
#include "river-status-unstable-v1-client-protocol.h"

struct output {
	struct wl_output *wl_output;
	char name[64];
	struct output *next;
};

static struct output *outputs;
static struct wl_seat *seat;
static struct zriver_status_manager_v1 *status_manager;
static struct wl_output *focused;

static void noop() {}

static void output_name(void *data, struct wl_output *wl_output, const char *name)
{
	struct output *output = data;
	snprintf(output->name, sizeof output->name, "%s", name);
}

static const struct wl_output_listener output_listener = {
	.geometry = (void *)noop,
	.mode = (void *)noop,
	.done = (void *)noop,
	.scale = (void *)noop,
	.name = output_name,
	.description = (void *)noop,
};

static void seat_focused_output(void *data, struct zriver_seat_status_v1 *status,
		struct wl_output *wl_output)
{
	focused = wl_output;
}

static const struct zriver_seat_status_v1_listener seat_status_listener = {
	.focused_output = seat_focused_output,
	.unfocused_output = (void *)noop,
	.focused_view = (void *)noop,
	.mode = (void *)noop,
};

static void registry_global(void *data, struct wl_registry *registry, uint32_t name,
		const char *interface, uint32_t version)
{
	if (strcmp(interface, wl_output_interface.name) == 0 && version >= 4) {
		struct output *output = calloc(1, sizeof *output);
		output->wl_output = wl_registry_bind(registry, name, &wl_output_interface, 4);
		wl_output_add_listener(output->wl_output, &output_listener, output);
		output->next = outputs;
		outputs = output;
	} else if (strcmp(interface, wl_seat_interface.name) == 0 && seat == NULL) {
		seat = wl_registry_bind(registry, name, &wl_seat_interface, 1);
	} else if (strcmp(interface, zriver_status_manager_v1_interface.name) == 0) {
		status_manager = wl_registry_bind(registry, name,
			&zriver_status_manager_v1_interface, 1);
	}
}

static const struct wl_registry_listener registry_listener = {
	.global = registry_global,
	.global_remove = (void *)noop,
};

int main(void)
{
	struct wl_display *display = wl_display_connect(NULL);
	if (display == NULL) {
		fputs("river-output: cannot connect to the Wayland display\n", stderr);
		return 1;
	}

	struct wl_registry *registry = wl_display_get_registry(display);
	wl_registry_add_listener(registry, &registry_listener, NULL);
	wl_display_roundtrip(display); /* globals */
	if (seat == NULL || status_manager == NULL) {
		fputs("river-output: not running under river\n", stderr);
		return 1;
	}

	struct zriver_seat_status_v1 *status =
		zriver_status_manager_v1_get_river_seat_status(status_manager, seat);
	zriver_seat_status_v1_add_listener(status, &seat_status_listener, NULL);
	wl_display_roundtrip(display); /* output names, focused output */

	for (struct output *output = outputs; output != NULL; output = output->next) {
		if (output->wl_output == focused) {
			puts(output->name);
			return 0;
		}
	}
	fputs("river-output: no focused output\n", stderr);
	return 1;
}
