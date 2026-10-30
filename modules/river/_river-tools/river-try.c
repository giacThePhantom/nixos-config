/*
 * river-try STEP [STEP...]: run river command steps in order, stopping at the
 * first one that works. A step is one or more commands separated by ";".
 *
 * A step works if it changes keyboard focus (to another view or output); a
 * step prefixed with "!" works if all its commands succeed instead. Exits 1
 * if no step worked. E.g.
 *   river-try "focus-view left" "focus-output left"
 *   river-try "!swap left" "send-to-output -current-tags left; focus-output left"
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <wayland-client.h>
#include "river-control-unstable-v1-client-protocol.h"
#include "river-status-unstable-v1-client-protocol.h"

static struct wl_seat *seat;
static struct zriver_status_manager_v1 *status_manager;
static struct zriver_control_v1 *control;
static int focus_changed;
static int command_failed;

static void noop() {}

static void focus_event()
{
	focus_changed = 1;
}

static const struct zriver_seat_status_v1_listener seat_status_listener = {
	.focused_output = (void *)focus_event,
	.unfocused_output = (void *)noop,
	.focused_view = (void *)focus_event,
	.mode = (void *)noop,
};

static void command_failure()
{
	command_failed = 1;
}

static const struct zriver_command_callback_v1_listener command_listener = {
	.success = (void *)noop,
	.failure = (void *)command_failure,
};

static void registry_global(void *data, struct wl_registry *registry, uint32_t name,
		const char *interface, uint32_t version)
{
	if (strcmp(interface, wl_seat_interface.name) == 0 && seat == NULL)
		seat = wl_registry_bind(registry, name, &wl_seat_interface, 1);
	else if (strcmp(interface, zriver_status_manager_v1_interface.name) == 0)
		status_manager = wl_registry_bind(registry, name,
			&zriver_status_manager_v1_interface, 1);
	else if (strcmp(interface, zriver_control_v1_interface.name) == 0)
		control = wl_registry_bind(registry, name, &zriver_control_v1_interface, 1);
}

static const struct wl_registry_listener registry_listener = {
	.global = registry_global,
	.global_remove = (void *)noop,
};

/* Run one command (space-separated words); returns 0 if river reports success. */
static int run_command(struct wl_display *display, char *command)
{
	int words = 0;
	for (char *arg = strtok(command, " "); arg != NULL; arg = strtok(NULL, " ")) {
		zriver_control_v1_add_argument(control, arg);
		words++;
	}
	if (words == 0)
		return 0;

	command_failed = 0;
	struct zriver_command_callback_v1 *callback =
		zriver_control_v1_run_command(control, seat);
	zriver_command_callback_v1_add_listener(callback, &command_listener, NULL);
	/* river runs the command and emits any focus events before it answers
	 * this roundtrip */
	wl_display_roundtrip(display);
	return command_failed;
}

int main(int argc, char *argv[])
{
	struct wl_display *display = wl_display_connect(NULL);
	if (display == NULL) {
		fputs("river-try: cannot connect to the Wayland display\n", stderr);
		return 2;
	}

	struct wl_registry *registry = wl_display_get_registry(display);
	wl_registry_add_listener(registry, &registry_listener, NULL);
	wl_display_roundtrip(display);
	if (seat == NULL || status_manager == NULL || control == NULL) {
		fputs("river-try: not running under river\n", stderr);
		return 2;
	}

	struct zriver_seat_status_v1 *status =
		zriver_status_manager_v1_get_river_seat_status(status_manager, seat);
	zriver_seat_status_v1_add_listener(status, &seat_status_listener, NULL);
	wl_display_roundtrip(display); /* swallow the initial state events */

	for (int i = 1; i < argc; i++) {
		int want_success = argv[i][0] == '!';
		char *step = strdup(argv[i] + want_success);
		char *rest = step;
		int failed = 0;
		focus_changed = 0;
		for (char *command = strsep(&rest, ";"); command != NULL && !failed;
				command = strsep(&rest, ";"))
			failed = run_command(display, command);
		free(step);

		if (want_success ? !failed : focus_changed)
			return 0;
	}
	return 1;
}
