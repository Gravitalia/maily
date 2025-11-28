defmodule Maily.Cldr do
  use Cldr,
    otp_app: :maily,
    default_locale: "en",
    precompile_number_formats: ["¤¤#,##0.##"],
    locales: ["en", "fr"],
    providers: [Cldr.Number, Cldr.DateTime, Cldr.Calendar],
    force_locale_download: Mix.env() == :prod
end
