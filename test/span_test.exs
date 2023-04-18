defmodule OpenTelemetryLogExporter.SpanTest do
  # References:
  # - https://github.com/open-telemetry/opentelemetry-erlang/blob/main/test/otel_tests.exs
  # - https://github.com/open-telemetry/opentelemetry-erlang/blob/main/apps/opentelemetry_exporter/test/opentelemetry_exporter_SUITE.erl

  use ExUnit.Case
  alias OpenTelemetryLogExporter.Span

  require Record
  @fields Record.extract(:span, from_lib: "opentelemetry/include/otel_span.hrl")
  Record.defrecordp(:span, @fields)

  test "extracts name and attributes" do
    attributes =
      :otel_attributes.new([{"attr-1", "value-1"}, {"attr-2", "value-2"}], 128, :infinity)

    otel_span = span(name: "grilled_spam", attributes: attributes)

    span = Span.new(otel_span)

    assert span.name == "grilled_spam"
    assert span.attributes == %{"attr-1" => "value-1", "attr-2" => "value-2"}
  end

  test "extracts trace, span, and parent ids" do
    otel_span =
      span(
        trace_id: 141_947_240_853_973_535_602_059_278_503_659_962_369,
        span_id: 9_787_989_678_256_304_207,
        parent_span_id: 13_574_622_720_317_236_748
      )

    span = Span.new(otel_span)

    assert span.trace_id == 141_947_240_853_973_535_602_059_278_503_659_962_369
    assert span.span_id == 9_787_989_678_256_304_207
    assert span.parent_span_id == 13_574_622_720_317_236_748
  end

  test "undefined ids are set to nil" do
    otel_span =
      span(
        trace_id: :undefined,
        span_id: :undefined,
        parent_span_id: :undefined
      )

    span = Span.new(otel_span)

    assert span.trace_id == nil
    assert span.span_id == nil
    assert span.parent_span_id == nil
  end

  test "calculates duration in milliseconds" do
    otel_span = span(start_time: -576_460_751_228_864_375, end_time: -576_460_751_126_766_291)

    span = Span.new(otel_span)

    assert span.duration_ms == 102
  end

  test "handles unset, error, and ok statuses" do
    otel_span = span(status: {:status, :unset, ""})
    span = Span.new(otel_span)
    assert span.status == :unset

    otel_span = span(status: {:status, :error, "what goes in here?"})
    span = Span.new(otel_span)
    assert span.status == :error

    otel_span = span(status: {:status, :ok, "how do you set this?"})
    span = Span.new(otel_span)
    assert span.status == :ok
  end

  test "handles exception events" do
    exception_attrs =
      :otel_attributes.new(
        [
          {:"exception.type", "Elixir.RuntimeError"},
          {:"exception.message", "my error message"},
          {:"exception.stacktrace", "totally real stacktrace\nwith multiple lines and stuff\n"}
        ],
        128,
        :infinity
      )

    exception_event = {:event, -576_460_751_228_864_300, "exception", exception_attrs}
    events = {:events, 128, 128, :infinity, 0, [exception_event]}

    otel_span = span(events: events)

    span = Span.new(otel_span)

    assert [
             %{
               attributes: %{
                 "exception.type": "Elixir.RuntimeError",
                 "exception.message": "my error message",
                 "exception.stacktrace":
                   "totally real stacktrace\nwith multiple lines and stuff\n"
               },
               timestamp: _,
               type: "exception"
             }
           ] = span.events
  end
end
