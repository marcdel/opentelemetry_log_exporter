defmodule OpenTelemetryLogExporter do
  @moduledoc """
  Implements the [:otel_exporter](https://github.com/open-telemetry/opentelemetry-erlang/blob/3bf392bf4efbbc93fcbf780fc13ee884475b2e20/apps/opentelemetry/src/otel_exporter.erl#L18) behavior
  """
  require Logger

  alias OpenTelemetryLogExporter.Span

  def init(config) do
    {:ok, config}
  end

  def shutdown(_), do: :ok

  def export(_traces, spans_table_id, _resource, _config) do
    spans_list = :ets.tab2list(spans_table_id)
    Enum.each(spans_list, &log_span/1)

    :ok
  end

  defp log_span(span_record) do
    span_record
    |> generate_message()
    |> Logger.info()
  end

  def generate_message(span_record) do
    span = Span.new(span_record)
    attr_string = attr_csv(span.attributes)

    "[span] #{span.duration_ms}ms \"#{span.name}\" #{attr_string}"
  end

  defp attr_csv(attr_map) do
    Enum.map_join(attr_map, " ", fn {k, v} -> "#{k}=#{attribute_value(v)}" end)
  end

  defp attribute_value(value) when is_binary(value), do: value
  defp attribute_value(value), do: inspect(value)
end
