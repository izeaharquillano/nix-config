# Timezone Asia/Manila + en_US/en_PH locales.
{
  flake.modules.nixos.locale =
    _:

    {
      time = {
        timeZone = "Asia/Manila";
        hardwareClockInLocalTime = false;
      };

      i18n = {
        defaultLocale = "en_US.UTF-8";

        extraLocaleSettings = {
          LC_ADDRESS = "en_PH.UTF-8";
          LC_IDENTIFICATION = "en_PH.UTF-8";
          LC_MEASUREMENT = "en_PH.UTF-8";
          LC_MONETARY = "en_PH.UTF-8";
          LC_NAME = "en_PH.UTF-8";
          LC_NUMERIC = "en_PH.UTF-8";
          LC_PAPER = "en_PH.UTF-8";
          LC_TELEPHONE = "en_PH.UTF-8";
          LC_TIME = "en_PH.UTF-8";
        };
      };
    };
}
