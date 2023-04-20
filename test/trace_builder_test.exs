defmodule OpenTelemetryLogExporter.TraceBuilderTest do
  use ExUnit.Case
  alias OpenTelemetryLogExporter.TraceBuilder
  alias OpenTelemetryLogExporter.Span

  require Record
  @fields Record.extract(:span, from_lib: "opentelemetry/include/otel_span.hrl")
  Record.defrecordp(:span, @fields)

  describe "build/1" do
    test "associates a child with a parent" do
      spans = [
        Span.new(span(name: "span1", span_id: 1, parent_span_id: :undefined)),
        Span.new(span(name: "span2", span_id: 2, parent_span_id: 1))
      ]

      trace = TraceBuilder.build(spans)

      assert [%{span_id: 1, children: [%{span_id: 2}]}] = trace
    end

    test "handles spans at the same level" do
      spans = [
        Span.new(span(name: "span1", span_id: 1, parent_span_id: :undefined)),
        Span.new(span(name: "span2", span_id: 2, parent_span_id: 1)),
        Span.new(span(name: "span3", span_id: 3, parent_span_id: 1))
      ]

      trace = TraceBuilder.build(spans)

      assert [%{span_id: 1, children: [%{span_id: 2}, %{span_id: 3}]}] = trace
    end

    test "handles spans at multiple levels" do
      spans = [
        Span.new(span(name: "span1", span_id: 1, parent_span_id: :undefined)),
        Span.new(span(name: "span2", span_id: 2, parent_span_id: 1)),
        Span.new(span(name: "span3", span_id: 3, parent_span_id: 2)),
        Span.new(span(name: "span4", span_id: 4, parent_span_id: 3))
      ]

      trace = TraceBuilder.build(spans)

      assert [
               %{
                 span_id: 1,
                 indent_level: 1,
                 children: [
                   %{
                     span_id: 2,
                     indent_level: 2,
                     children: [
                       %{
                         span_id: 3,
                         indent_level: 3,
                         children: [
                           %{
                             span_id: 4,
                             indent_level: 4
                           }
                         ]
                       }
                     ]
                   }
                 ]
               }
             ] = trace
    end
  end
end
