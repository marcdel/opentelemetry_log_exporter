# OpenTelemetryLogExporter

Sometimes you just wanna look at your spans 🤷🏻‍♂️

Inspired by ~~shamelessly stolen from~~ the [otel_exporter_stdout](https://github.com/open-telemetry/opentelemetry-erlang/blob/main/apps/opentelemetry/src/otel_exporter_stdout.erl). Span definition was pulled from [here](https://github.com/open-telemetry/opentelemetry-erlang/blob/main/apps/opentelemetry/include/otel_span.hrl#L19).

Example output:
```shell
[info] [span] 5ms "/teams/log_in" net.peer.port: 51497, net.sock.peer.addr: "127.0.0.1", net.transport: :"IP.TCP", http.method: "GET", http.status_code: 200, http.flavor: :"1.1", http.scheme: "http", http.target: "/teams/log_in", http.route: "/teams/log_in", http.client_ip: "127.0.0.1", net.host.name: "localhost", net.host.port: 4000, net.sock.host.addr: "127.0.0.1", phoenix.plug: Phoenix.LiveView.Plug, phoenix.action: :new
[info] [span] 1ms "PearsWeb.TeamLoginLive.mount" name: "nil"
[info] [span] 0ms "pears.repo.query" source: nil, db.statement: "CREATE TABLE IF NOT EXISTS \"schema_migrations\" (\"version\" bigint, \"inserted_at\" timestamp(0), PRIMARY KEY (\"version\"))", db.type: :sql, db.instance: "pears_dev", db.url: "ecto://localhost", total_time_microseconds: 669, decode_time_microseconds: 1, idle_time_microseconds: 674906, query_time_microseconds: 293, queue_time_microseconds: 374
```

## Installation

The package can be installed by adding `opentelemetry_log_exporter` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:opentelemetry_log_exporter, "~> 0.1.0"}
  ]
end
```

