/* webapp NAME URL: one website in its own frameless window, like Chromium's
 * --app windows, on the WebKitGTK the system already has (renCal).
 *
 * NAME (a-z, 0-9, '-') keeps each app's logins and storage apart under
 * $XDG_DATA_HOME/webapps/NAME and makes the Wayland app_id webapp.NAME,
 * which the app's .desktop file names as StartupWMClass. Launching a running
 * app raises its window instead of starting a second copy.
 *
 * Links that open a new tab go to the default browser; pages navigate
 * freely otherwise (logins on other domains) and script popups (OAuth) get
 * their own window. Keys: Ctrl+R/F5 reload, Alt+Left/Right back/forward,
 * Ctrl+=/-/0 zoom, Ctrl+L copy the page's address. */
#include <gtk/gtk.h>
#include <webkit2/webkit2.h>

static const char *name, *start_url;

static GtkWidget *new_window(GtkApplication *app, WebKitWebView *view);

static void on_title(WebKitWebView *view, GParamSpec *pspec, GtkWindow *win) {
    const char *title = webkit_web_view_get_title(view);
    gtk_window_set_title(win, title && *title ? title : name);
}

static gboolean on_decide_policy(WebKitWebView *view, WebKitPolicyDecision *decision,
                                 WebKitPolicyDecisionType type, gpointer data) {
    if (type == WEBKIT_POLICY_DECISION_TYPE_NEW_WINDOW_ACTION) {
        WebKitNavigationAction *action = webkit_navigation_policy_decision_get_navigation_action(
            WEBKIT_NAVIGATION_POLICY_DECISION(decision));
        /* A clicked target=_blank link: the browser, not a popup */
        if (webkit_navigation_action_get_navigation_type(action) ==
            WEBKIT_NAVIGATION_TYPE_LINK_CLICKED) {
            WebKitURIRequest *request = webkit_navigation_action_get_request(action);
            g_app_info_launch_default_for_uri(webkit_uri_request_get_uri(request), NULL, NULL);
            webkit_policy_decision_ignore(decision);
            return TRUE;
        }
    } else if (type == WEBKIT_POLICY_DECISION_TYPE_RESPONSE) {
        /* Files the page can't show are downloaded (to ~/Downloads) */
        if (!webkit_response_policy_decision_is_mime_type_supported(
                WEBKIT_RESPONSE_POLICY_DECISION(decision))) {
            webkit_policy_decision_download(decision);
            return TRUE;
        }
    }
    return FALSE;
}

static void on_ready_to_show(WebKitWebView *view, GtkWidget *win) {
    gtk_widget_show_all(win);
}

static GtkWidget *on_create(WebKitWebView *view, WebKitNavigationAction *action,
                            GtkApplication *app) {
    WebKitWebView *popup = WEBKIT_WEB_VIEW(webkit_web_view_new_with_related_view(view));
    GtkWidget *win = new_window(app, popup);
    gtk_window_set_default_size(GTK_WINDOW(win), 600, 700);
    g_signal_connect(popup, "ready-to-show", G_CALLBACK(on_ready_to_show), win);
    return GTK_WIDGET(popup);
}

static void on_close(WebKitWebView *view, GtkWidget *win) {
    gtk_widget_destroy(win);
}

/* Notifications are what web apps are for (chat, mail); camera, microphone
 * and location stay off. */
static gboolean on_permission(WebKitWebView *view, WebKitPermissionRequest *request,
                              gpointer data) {
    if (WEBKIT_IS_NOTIFICATION_PERMISSION_REQUEST(request))
        webkit_permission_request_allow(request);
    else
        webkit_permission_request_deny(request);
    return TRUE;
}

static gboolean on_key(GtkWidget *win, GdkEventKey *event, WebKitWebView *view) {
    guint mods = event->state & gtk_accelerator_get_default_mod_mask();
    gdouble zoom = webkit_web_view_get_zoom_level(view);

    if ((mods == GDK_CONTROL_MASK && event->keyval == GDK_KEY_r) || event->keyval == GDK_KEY_F5)
        webkit_web_view_reload(view);
    else if (mods == GDK_MOD1_MASK && event->keyval == GDK_KEY_Left)
        webkit_web_view_go_back(view);
    else if (mods == GDK_MOD1_MASK && event->keyval == GDK_KEY_Right)
        webkit_web_view_go_forward(view);
    else if (mods == GDK_CONTROL_MASK && (event->keyval == GDK_KEY_equal ||
                                          event->keyval == GDK_KEY_plus))
        webkit_web_view_set_zoom_level(view, zoom + 0.1);
    else if (mods == GDK_CONTROL_MASK && event->keyval == GDK_KEY_minus)
        webkit_web_view_set_zoom_level(view, zoom > 0.3 ? zoom - 0.1 : zoom);
    else if (mods == GDK_CONTROL_MASK && event->keyval == GDK_KEY_0)
        webkit_web_view_set_zoom_level(view, 1.0);
    else if (mods == GDK_CONTROL_MASK && event->keyval == GDK_KEY_l)
        gtk_clipboard_set_text(gtk_clipboard_get(GDK_SELECTION_CLIPBOARD),
                               webkit_web_view_get_uri(view), -1);
    else
        return FALSE;
    return TRUE;
}

static GtkWidget *new_window(GtkApplication *app, WebKitWebView *view) {
    GtkWidget *win = gtk_application_window_new(app);
    gtk_window_set_title(GTK_WINDOW(win), name);
    /* GTK 3 ignores river's server-side decorations and would draw its own
     * title bar; river's border is the frame */
    gtk_window_set_decorated(GTK_WINDOW(win), FALSE);
    gtk_container_add(GTK_CONTAINER(win), GTK_WIDGET(view));
    g_signal_connect(view, "notify::title", G_CALLBACK(on_title), win);
    g_signal_connect(view, "decide-policy", G_CALLBACK(on_decide_policy), NULL);
    g_signal_connect(view, "create", G_CALLBACK(on_create), app);
    g_signal_connect(view, "close", G_CALLBACK(on_close), win);
    g_signal_connect(view, "permission-request", G_CALLBACK(on_permission), NULL);
    g_signal_connect(win, "key-press-event", G_CALLBACK(on_key), view);
    return win;
}

static void activate(GtkApplication *app, gpointer data) {
    GList *windows = gtk_application_get_windows(app);
    if (windows) { /* already running */
        gtk_window_present(windows->data);
        return;
    }

    char *dir = g_build_filename(g_get_user_data_dir(), "webapps", name, NULL);
    char *cache = g_build_filename(g_get_user_cache_dir(), "webapps", name, NULL);
    char *cookies = g_build_filename(dir, "cookies.sqlite", NULL);
    g_mkdir_with_parents(dir, 0700);

    WebKitWebsiteDataManager *storage = webkit_website_data_manager_new(
        "base-data-directory", dir, "base-cache-directory", cache, NULL);
    WebKitWebContext *context = webkit_web_context_new_with_website_data_manager(storage);
    webkit_cookie_manager_set_persistent_storage(webkit_web_context_get_cookie_manager(context),
                                                 cookies,
                                                 WEBKIT_COOKIE_PERSISTENT_STORAGE_SQLITE);

    WebKitWebView *view = WEBKIT_WEB_VIEW(webkit_web_view_new_with_context(context));
    WebKitSettings *settings = webkit_web_view_get_settings(view);
    webkit_settings_set_enable_developer_extras(settings, TRUE); /* right click > Inspect */
    webkit_settings_set_javascript_can_access_clipboard(settings, TRUE);

    GtkWidget *win = new_window(app, view);
    gtk_window_set_default_size(GTK_WINDOW(win), 1200, 800);
    webkit_web_view_load_uri(view, start_url);
    gtk_widget_show_all(win);

    g_free(dir);
    g_free(cache);
    g_free(cookies);
}

int main(int argc, char **argv) {
    if (argc != 3) {
        fprintf(stderr, "usage: webapp NAME URL\n");
        return 2;
    }
    name = argv[1];
    start_url = argv[2];

    char *id = g_strconcat("webapp.", name, NULL);
    if (!g_application_id_is_valid(id)) {
        fprintf(stderr, "webapp: invalid NAME '%s' (use a-z, 0-9 and '-', starting with a letter)\n",
                name);
        return 2;
    }
    g_set_prgname(id); /* GTK 3 takes the Wayland app_id from here */

    /* WebKit's DMA-BUF renderer fails on NVIDIA's driver (Wayland protocol
     * error, no window); renCal does the same check */
    if (g_file_test("/proc/driver/nvidia/version", G_FILE_TEST_EXISTS))
        g_setenv("WEBKIT_DISABLE_DMABUF_RENDERER", "1", FALSE);
    GtkApplication *app = gtk_application_new(id, G_APPLICATION_DEFAULT_FLAGS);
    g_signal_connect(app, "activate", G_CALLBACK(activate), NULL);
    char *args[] = {argv[0], NULL};
    int status = g_application_run(G_APPLICATION(app), 1, args);
    g_object_unref(app);
    return status;
}
