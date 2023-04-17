# OpenTelemetryLogExporter

Sometimes you just wanna look at your spans 🤷🏻‍♂️

Inspired by ~~shamelessly stolen from~~ [otel_exporter_stdout](https://github.com/open-telemetry/opentelemetry-erlang/blob/main/apps/opentelemetry/src/otel_exporter_stdout.erl) and [circleci/ex](https://github.com/circleci/ex/blob/main/o11y/honeycomb/formatter.go). Span definition was pulled from [here](https://github.com/open-telemetry/opentelemetry-erlang/blob/main/apps/opentelemetry/include/otel_span.hrl#L19).

Example output:
```shell
[info] [span] 22ms "/teams/log_in" http.client_ip=127.0.0.1 http.flavor=:"1.1" http.method=GET http.scheme=http http.target=/teams/log_in net.host.name=localhost net.host.port=4000 net.peer.port=56526 net.sock.host.addr=127.0.0.1 net.sock.peer.addr=127.0.0.1 net.transport=:"IP.TCP" http.status_code=200 http.route=/teams/log_in phoenix.action=:new phoenix.plug=Phoenix.LiveView.Plug
[info] [span] 0ms "PearsWeb.TeamLoginLive.mount" name=nil
[info] [span] 0ms "pears.repo.query" source=nil db.instance=pears_dev db.statement=CREATE TABLE IF NOT EXISTS "schema_migrations" ("version" bigint, "inserted_at" timestamp(0), PRIMARY KEY ("version")) db.type=:sql db.url=ecto://localhost total_time_microseconds=597 decode_time_microseconds=1 idle_time_microseconds=997829 query_time_microseconds=201 queue_time_microseconds=394
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

