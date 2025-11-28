import Config

config :ex_cldr,
  default_locale: "en",
  json_library: Jason,
  default_backend: Maily.Cldr

config :ex_cldr_dates_times,
  default_backend: Maily.Cldr
