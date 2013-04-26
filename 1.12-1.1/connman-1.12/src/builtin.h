extern struct connman_plugin_desc __connman_builtin_loopback;
extern struct connman_plugin_desc __connman_builtin_ethernet;
extern struct connman_plugin_desc __connman_builtin_wifi;
extern struct connman_plugin_desc __connman_builtin_bluetooth_legacy;
extern struct connman_plugin_desc __connman_builtin_bluetooth;
extern struct connman_plugin_desc __connman_builtin_ofono;
extern struct connman_plugin_desc __connman_builtin_dundee;
extern struct connman_plugin_desc __connman_builtin_vpn;
extern struct connman_plugin_desc __connman_builtin_pacrunner;
extern struct connman_plugin_desc __connman_builtin_polkit;
extern struct connman_plugin_desc __connman_builtin_nmcompat;
extern struct connman_plugin_desc __connman_builtin_neard;

static struct connman_plugin_desc *__connman_builtin[] = {
  &__connman_builtin_loopback,
  &__connman_builtin_ethernet,
  &__connman_builtin_wifi,
  &__connman_builtin_bluetooth_legacy,
  &__connman_builtin_bluetooth,
  &__connman_builtin_ofono,
  &__connman_builtin_dundee,
  &__connman_builtin_vpn,
  &__connman_builtin_pacrunner,
  &__connman_builtin_polkit,
  &__connman_builtin_nmcompat,
  &__connman_builtin_neard,
  NULL
};
