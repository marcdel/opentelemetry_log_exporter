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
        Tracer.with_span "PearsWeb.TeamLoginLive.mount" do
          Tracer.set_attribute("beep", "boop")

          Tracer.with_span "pears.repo.query" do
            Tracer.set_attribute("attr1", "value1")
            Tracer.set_attributes([{"attr2", 37}])
            Span.record_exception(Tracer.current_span_ctx(), %RuntimeError{message: "farts"})
            Span.set_status(Tracer.current_span_ctx(), OpenTelemetry.status(:error))

            Tracer.with_span "pears.repo.query:schema_migrations" do
              Tracer.set_attribute("attr3", "value3")
            end

            Tracer.with_span "/teams/log_in" do
              Tracer.set_attribute("beep", "boop")
              Tracer.set_attribute("foo", "bar")

              Tracer.with_span "PearsWeb.TeamLoginLive.mount" do
                Tracer.set_attribute("some_map", inspect(%{x: 12}))
              end
            end
          end
        end

        # Seems like this might be flaky 😞
        Process.sleep(100)
      end)

    IO.puts(log)

    assert log =~ "[span]"
    assert log =~ "PearsWeb.TeamLoginLive.mount"
  end

  describe "generate_trace_messages/1" do
    test "logs name and attributes" do
      attributes = :otel_attributes.new([{"attr1", "value1"}, {"attr2", "37"}], 128, :infinity)

      root_span =
        span(
          name: "grilled_spam",
          span_id: 321,
          parent_span_id: 1234,
          start_time: -576_460_751_228_864_375,
          end_time: -576_460_751_126_766_291,
          attributes: attributes
        )
        |> OpenTelemetryLogExporter.Span.new()

      message = OpenTelemetryLogExporter.generate_trace_messages(root_span)

      assert ["[span] 102ms  ├─  321  \"grilled_spam\" attr1=value1 attr2=37"] = message
    end
  end
end
