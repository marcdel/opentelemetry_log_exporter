defmodule OpenTelemetryLogExporter.SpanTest do
  # References:
  # - https://github.com/open-telemetry/opentelemetry-erlang/blob/main/test/otel_tests.exs
  # - https://github.com/open-telemetry/opentelemetry-erlang/blob/main/apps/opentelemetry_exporter/test/opentelemetry_exporter_SUITE.erl

  use ExUnit.Case
  alias OpenTelemetryLogExporter.Span

  require Record
  @fields Record.extract(:span, from_lib: "opentelemetry/include/otel_span.hrl")
  Record.defrecordp(:span, @fields)

  test "can extract data from a span" do
    # {:span, 111381682121931666101286450812795486209, 4936807097972812557, [],
    # :undefined, "span-1", :internal, -576460751213930208, -576460751212172542,
    # {:attributes, 128, :infinity, 0, %{}}, {:events, 128, 128, :infinity, 0, []},
    # {:links, 128, 128, :infinity, 0, []}, :undefined, 1, false, :undefined}

    attributes =
      :otel_attributes.new([{"attr-1", "value-1"}, {"attr-2", "value-2"}], 128, :infinity)

    otel_span =
      span(
        name: "grilled_spam",
        attributes: attributes,
        start_time: -576_460_751_228_864_375,
        end_time: -576_460_751_126_766_291
      )

    span = Span.new(otel_span)

    assert span.name == "grilled_spam"
    assert span.duration_ms == 102
    assert span.attributes == %{"attr-1" => "value-1", "attr-2" => "value-2"}
  end
end
