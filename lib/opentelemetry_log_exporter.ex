defmodule OpenTelemetryLogExporter do
  @moduledoc """
  Implements the [:otel_exporter](https://github.com/open-telemetry/opentelemetry-erlang/blob/3bf392bf4efbbc93fcbf780fc13ee884475b2e20/apps/opentelemetry/src/otel_exporter.erl#L18) behavior
  """
  require Logger

  alias OpenTelemetryLogExporter.Span
  alias OpenTelemetryLogExporter.TraceBuilder

  def init(config) do
    {:ok, config}
  end

  def shutdown(_), do: :ok

  def export(_traces, span_table_id, _resource, _config) do
    try do
      do_export(span_table_id)
    rescue
      e -> Logger.error(Exception.format(:error, e, __STACKTRACE__))
    end

    :ok
  end

  defp do_export(span_table_id) do
    span_table_id
    |> :ets.tab2list()
    |> Enum.reverse()
    |> Enum.map(&Span.new/1)
    |> TraceBuilder.build()
    |> Enum.map(&generate_trace_messages/1)
    |> List.flatten()
    |> Enum.each(&Logger.info/1)
  end

  def generate_trace_messages(span) do
    id = truncate_and_pad_id(span.span_id)
    duration = String.pad_leading("#{span.duration_ms}", 3, " ")
    indentation = String.duplicate(" ", span.indent_level * 4)
    attr_string = attr_csv(span.attributes)

    ["[span] #{duration}ms #{indentation} ├─ #{id} \"#{span.name}\" #{attr_string}"] ++
      generate_event_messages(span) ++
      Enum.map(span.children, &generate_trace_messages/1)
  end

  def generate_event_messages(span) do
    span.events
    |> Enum.reverse()
    |> Enum.map(fn event ->
      duration = String.duplicate(" ", 3 + 2)
      indentation = String.duplicate(" ", (span.indent_level + 1) * 4)
      attr_string = attr_csv(event.attributes)

      "[event] #{duration} #{indentation}├─ \"#{event.type}\" #{attr_string}"
    end)
  end

  defp truncate_and_pad_id(nil), do: ""
  defp truncate_and_pad_id(:undefined), do: ""

  defp truncate_and_pad_id(id) do
    id
    |> Integer.digits()
    |> Enum.take(-4)
    |> Integer.undigits()
    |> Integer.to_string()
    |> then(fn str -> " #{str} " end)
  end

  defp attr_csv(attr_map) do
    Enum.map_join(attr_map, " ", fn {k, v} -> "#{k}=#{attribute_value(v)}" end)
  end

  defp attribute_value(value) when is_binary(value), do: value
  defp attribute_value(value), do: inspect(value)
end
