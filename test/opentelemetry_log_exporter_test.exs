defmodule OpenTelemetryLogExporterTest do
  use ExUnit.Case

  import ExUnit.CaptureLog
  require OpenTelemetry.Tracer, as: Tracer
  require OpenTelemetry.Span, as: Span

  require Record
  @fields Record.extract(:span, from_lib: "opentelemetry/include/otel_span.hrl")
  Record.defrecordp(:span, @fields)

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
          Tracer.with_span "span-2" do
            Tracer.set_attribute("attr1", "value1")
            Tracer.set_attributes([{"attr2", 37}])
            Span.record_exception(Tracer.current_span_ctx(), %RuntimeError{message: "farts"})
            Span.set_status(Tracer.current_span_ctx(), OpenTelemetry.status(:error))

            Tracer.with_span "span-3" do
            end

            Tracer.with_span "span-4" do
              Tracer.with_span "span-5" do
              end
            end
          end
        end

        # Seems like this might be flaky 😞
        Process.sleep(100)
      end)

    IO.puts(log)

    assert log =~ "[span]"
    assert log =~ "span-1"
  end

  describe "log_span/1" do
    test "logs name and attributes" do
      attributes = :otel_attributes.new([{"attr1", "value1"}, {"attr2", "37"}], 128, :infinity)

      otel_span =
        span(
          name: "grilled_spam",
          span_id: 321,
          parent_span_id: 1234,
          start_time: -576_460_751_228_864_375,
          end_time: -576_460_751_126_766_291,
          attributes: attributes
        )

      message = OpenTelemetryLogExporter.generate_message(otel_span)

      assert message =~ "[span] 1234 |>  321 102ms \"grilled_spam\" attr1=value1 attr2=37"
    end
  end
end
