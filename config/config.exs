import Config

config :task_pipeline, Oban,
  engine: Oban.Engines.Basic,
  notifier: Oban.Notifiers.Postgres,
  queues: [default: 100],
  repo: TaskPipeline.Repo

config :task_pipeline,
  ecto_repos: [TaskPipeline.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configure the endpoint
config :task_pipeline, TaskPipelineWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: TaskPipelineWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: TaskPipeline.PubSub,
  live_view: [signing_salt: "R3r7F9Z7"]

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
