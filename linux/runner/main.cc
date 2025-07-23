#include "my_application.h"
#include <glib.h>
#include <string.h>

// Custom log handler to filter GDK critical messages
void custom_log_handler(const gchar *log_domain,
                        GLogLevelFlags log_level,
                        const gchar *message,
                        gpointer user_data) {
    // Suppress the specific GDK critical message
    if (g_strcmp0(log_domain, "Gdk") == 0 &&
        strstr(message, "gdk_device_get_source: assertion 'GDK_IS_DEVICE (device)' failed") != NULL) {
        return;
    }

    // Pass through all other messages to the default handler
    g_log_default_handler(log_domain, log_level, message, user_data);
}

int main(int argc, char** argv) {
  // Set the custom log handler
  g_log_set_default_handler(custom_log_handler, NULL);

  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
