defmodule OpenTelemetryLogExporter.Span do
  defstruct [:name, :start_time, :end_time, :duration_ms, :attributes]

  def new(otel_span) do
    {
      :span,
      _trace_id,
      _span_id,
      _trace_state,
      _parent_span_id,
      span_name,
      _kind,
      start_time,
      end_time,
      {:attributes, _, :infinity, _, attrs},
      _events,
      _links,
      _status,
      _trace_flags,
      _is_recording,
      _instrumentation_scope
    } = otel_span

    %__MODULE__{
      name: span_name,
      start_time: start_time,
      end_time: end_time,
      duration_ms: duration(start_time, end_time),
      attributes: attrs
    }
  end

  defp duration(start_time, end_time, unit \\ :millisecond) do
    System.convert_time_unit(end_time - start_time, :native, unit)
  end
end
