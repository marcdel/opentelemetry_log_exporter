# OpenTelemetryLogExporter

Sometimes you just wanna look at your spans 🤷🏻‍♂️

Inspired by ~~shamelessly stolen from~~ the [otel_exporter_stdout](https://github.com/open-telemetry/opentelemetry-erlang/blob/main/apps/opentelemetry/src/otel_exporter_stdout.erl). Span definition was pulled from [here](https://github.com/open-telemetry/opentelemetry-erlang/blob/main/apps/opentelemetry/include/otel_span.hrl#L19).

## Installation

The package can be installed by adding `opentelemetry_log_exporter` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:opentelemetry_log_exporter, "~> 0.1.0"}
  ]
end
```

