defmodule OpenTelemetryLogExporterTest do
  use ExUnit.Case
  import ExUnit.CaptureLog
  require OpenTelemetry.Tracer, as: Tracer

  setup do
    ExUnit.CaptureLog.capture_log(fn -> :application.stop(:opentelemetry) end)

    :application.set_env(:opentelemetry, :tracer, :otel_tracer_default)

    :application.set_env(:opentelemetry, :processors, [
      {:otel_batch_processor, %{scheduled_delay_ms: 1}}
    ])

    :application.start(:opentelemetry)

    :otel_batch_processor.set_exporter(Elixir.OpenTelemetryLogExporter, [])

    on_exit(fn ->
      :application.stop(:opentelemetry)
      :application.unload(:opentelemetry)
    end)
  end

  test "logs emitted spans" do
    log =
      capture_log(fn ->
        Tracer.with_span "span-1" do
          1 + 1 == 2
        end

        # Seems like this might be flaky 😞
        Process.sleep(100)
      end)

    assert log =~ "[span] 1ms \"span-1\""
  end
end
