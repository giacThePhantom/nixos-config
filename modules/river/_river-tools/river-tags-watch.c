/* Print "OUTPUT TAGS CHANGED" (e.g. "DP-1 4 1") each time an output's focused
 * tags change, until river exits. Each output's state at startup is printed
 * too, with CHANGED 0, so readers know every monitor's tags from the start.
 * Feeds the tag preview (scripts/tag-preview.sh). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <wayland-client.h>
#include "river-status-unstable-v1-client-protocol.h"

struct output {
	struct wl_output *wl_output;
	char name[64];
	uint32_t tags;
	int known; /* tags received at least once */
};

static struct zriver_status_manager_v1 *status_manager;

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

static void focused_tags(void *data, struct zriver_output_status_v1 *status, uint32_t tags)
{
	struct output *output = data;
	if (output->name[0] != '\0' && !(output->known && tags == output->tags)) {
		printf("%s %u %d\n", output->name, tags, output->known);
		fflush(stdout);
	}
	output->tags = tags;
	output->known = 1;
}

static const struct zriver_output_status_v1_listener output_status_listener = {
	.focused_tags = focused_tags,
	.view_tags = (void *)noop,
	.urgent_tags = (void *)noop,
	.layout_name = (void *)noop,
	.layout_name_clear = (void *)noop,
};

static void watch(struct output *output)
{
	struct zriver_output_status_v1 *status =
		zriver_status_manager_v1_get_river_output_status(status_manager, output->wl_output);
	zriver_output_status_v1_add_listener(status, &output_status_listener, output);
}

/* Outputs announced before the status manager wait here */
static struct output *pending[16];
static int npending;

static void registry_global(void *data, struct wl_registry *registry, uint32_t name,
		const char *interface, uint32_t version)
{
	if (strcmp(interface, wl_output_interface.name) == 0 && version >= 4) {
		struct output *output = calloc(1, sizeof *output);
		output->wl_output = wl_registry_bind(registry, name, &wl_output_interface, 4);
		wl_output_add_listener(output->wl_output, &output_listener, output);
		if (status_manager != NULL)
			watch(output); /* plugged in later */
		else if (npending < 16)
			pending[npending++] = output;
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
		fputs("river-tags-watch: cannot connect to the Wayland display\n", stderr);
		return 1;
	}

	struct wl_registry *registry = wl_display_get_registry(display);
	wl_registry_add_listener(registry, &registry_listener, NULL);
	wl_display_roundtrip(display); /* globals */
	if (status_manager == NULL) {
		fputs("river-tags-watch: not running under river\n", stderr);
		return 1;
	}
	for (int i = 0; i < npending; i++)
		watch(pending[i]);

	while (wl_display_dispatch(display) != -1)
		;
	return 0;
}
