import Config

config :maily, :rabbitmq,
  host: System.get_env("RABBITMQ_HOST", "localhost"),
  port: String.to_integer(System.get_env("RABBITMQ_PORT", "5672")),
  username: System.get_env("RABBITMQ_USER", "user"),
  password: System.get_env("RABBITMQ_PASSWORD", "password"),
  queue: System.get_env("RABBITMQ_QUEUE", "email"),
  prefetch: String.to_integer(System.get_env("PREFETCH_COUNT", "50")),
  concurrency: String.to_integer(System.get_env("PROCESSOR_CONCURRENCY", "10"))

config :maily, :smtp2go, api_key: System.get_env("SMTP2GO_KEY")
