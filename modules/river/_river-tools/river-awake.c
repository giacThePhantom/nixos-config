/* Keep the screen awake (no lock, no screens off) until killed.
 * river only honours an idle inhibitor whose surface is shown, so the
 * inhibitor sits on a 1x1 transparent layer surface below the windows,
 * which takes no input. Killing it ends the inhibitor with the connection. */
#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#include <wayland-client.h>
#include "idle-inhibit-unstable-v1-client-protocol.h"
#include "wlr-layer-shell-unstable-v1-client-protocol.h"

static struct wl_compositor *compositor;
static struct wl_shm *shm;
static struct zwlr_layer_shell_v1 *layer_shell;
static struct zwp_idle_inhibit_manager_v1 *inhibit_manager;
static struct wl_surface *surface;
static struct wl_buffer *buffer;
static int running = 1;

static void noop() {}

static void global(void *data, struct wl_registry *registry, uint32_t name,
		   const char *interface, uint32_t version)
{
	if (strcmp(interface, wl_compositor_interface.name) == 0)
		compositor = wl_registry_bind(registry, name, &wl_compositor_interface, 1);
	else if (strcmp(interface, wl_shm_interface.name) == 0)
		shm = wl_registry_bind(registry, name, &wl_shm_interface, 1);
	else if (strcmp(interface, zwlr_layer_shell_v1_interface.name) == 0)
		layer_shell = wl_registry_bind(registry, name, &zwlr_layer_shell_v1_interface, 1);
	else if (strcmp(interface, zwp_idle_inhibit_manager_v1_interface.name) == 0)
		inhibit_manager = wl_registry_bind(registry, name,
						   &zwp_idle_inhibit_manager_v1_interface, 1);
}

static const struct wl_registry_listener registry_listener = {
	.global = global,
	.global_remove = (void *)noop,
};

/* One transparent pixel: a fresh memfd is all zeroes, ARGB 0 */
static struct wl_buffer *transparent_pixel(void)
{
	int fd = memfd_create("river-awake", MFD_CLOEXEC);
	if (fd < 0 || ftruncate(fd, 4) < 0)
		return NULL;
	struct wl_shm_pool *pool = wl_shm_create_pool(shm, fd, 4);
	struct wl_buffer *pixel =
		wl_shm_pool_create_buffer(pool, 0, 1, 1, 4, WL_SHM_FORMAT_ARGB8888);
	wl_shm_pool_destroy(pool);
	close(fd);
	return pixel;
}

/* The surface is mapped (and the inhibitor counts) once it has a buffer */
static void configure(void *data, struct zwlr_layer_surface_v1 *layer_surface,
		      uint32_t serial, uint32_t width, uint32_t height)
{
	zwlr_layer_surface_v1_ack_configure(layer_surface, serial);
	wl_surface_attach(surface, buffer, 0, 0);
	wl_surface_commit(surface);
}

/* Its monitor went away */
static void closed(void *data, struct zwlr_layer_surface_v1 *layer_surface)
{
	running = 0;
}

static const struct zwlr_layer_surface_v1_listener layer_surface_listener = {
	.configure = configure,
	.closed = closed,
};

int main(void)
{
	struct wl_display *display = wl_display_connect(NULL);
	if (!display) {
		fprintf(stderr, "river-awake: no Wayland display\n");
		return 1;
	}
	struct wl_registry *registry = wl_display_get_registry(display);
	wl_registry_add_listener(registry, &registry_listener, NULL);
	wl_display_roundtrip(display);
	if (!compositor || !shm || !layer_shell || !inhibit_manager) {
		fprintf(stderr, "river-awake: the compositor lacks layer-shell or idle-inhibit\n");
		return 1;
	}
	buffer = transparent_pixel();
	if (!buffer) {
		perror("river-awake");
		return 1;
	}

	surface = wl_compositor_create_surface(compositor);
	struct wl_region *nothing = wl_compositor_create_region(compositor);
	wl_surface_set_input_region(surface, nothing); /* clicks go through */
	wl_region_destroy(nothing);
	struct zwlr_layer_surface_v1 *layer_surface = zwlr_layer_shell_v1_get_layer_surface(
		layer_shell, surface, NULL, ZWLR_LAYER_SHELL_V1_LAYER_BACKGROUND, "river-awake");
	zwlr_layer_surface_v1_set_size(layer_surface, 1, 1);
	zwlr_layer_surface_v1_set_anchor(layer_surface, ZWLR_LAYER_SURFACE_V1_ANCHOR_TOP |
								ZWLR_LAYER_SURFACE_V1_ANCHOR_LEFT);
	zwlr_layer_surface_v1_add_listener(layer_surface, &layer_surface_listener, NULL);
	zwp_idle_inhibit_manager_v1_create_inhibitor(inhibit_manager, surface);
	wl_surface_commit(surface);

	while (running && wl_display_dispatch(display) != -1)
		;
	wl_display_disconnect(display);
	return 0;
}
