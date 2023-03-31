import Config

config :junit_formatter,
  report_file: "mix-test.xml",
  report_dir: "#{Mix.Project.build_path()}/junit-reports",
  automatic_create_dir?: true,
  print_report_file: true,
  # prepend_project_name?: true,
  include_filename?: true,
  include_file_line?: true

config :logger,
  level: :warning

config :logger, :console,
  level: :warning,
  format: "$time $metadata[$level] $message\n",
  metadata: [:mfa]

config :tesla, adapter: Tesla.Mock

config :tesla, Tesla.Middleware.Logger,
  # format: "$method $url ====> $status / time=$time",
  debug: true
