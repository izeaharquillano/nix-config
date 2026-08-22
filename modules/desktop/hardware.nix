{ ... }:

{
  # Laptop-specific settings (battery, power management, backlight)
  # Override this module in hosts that don't need it (e.g. desktops)
  services.tlp.enable = true;
}
