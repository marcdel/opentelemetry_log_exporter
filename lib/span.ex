defmodule OpenTelemetryLogExporter.Event do
  defstruct [:type, :timestamp, attributes: %{}]
end

defmodule OpenTelemetryLogExporter.Span do
  alias OpenTelemetryLogExporter.Event

  defstruct [:name, :start_time, :end_time, :duration_ms, :status, attributes: %{}, events: []]

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
      attributes,
      events,
      _links,
      status,
      _trace_flags,
      _is_recording,
      _instrumentation_scope
    } = otel_span

    %__MODULE__{
      name: span_name,
      start_time: start_time,
      end_time: end_time,
      duration_ms: duration(start_time, end_time),
      attributes: attributes(attributes),
      events: events(events),
      status: status(status)
    }
  end

  defp duration(start_time, end_time, unit \\ :millisecond)

  defp duration(start_time, end_time, unit)
       when is_integer(start_time) and is_integer(end_time) do
    System.convert_time_unit(end_time - start_time, :native, unit)
  end

  defp duration(_, _, _), do: nil

  defp events({:events, _, _, _, _, events}), do: Enum.map(events, &event/1)
  defp events(_), do: []

  defp event({:event, timestamp, type, attributes}) do
    %Event{type: type, timestamp: timestamp, attributes: attributes(attributes)}
  end

  defp attributes({:attributes, _, _, _, attrs}), do: attrs
  defp attributes(_), do: %{}

  defp status({:status, :ok, _}), do: :ok
  defp status({:status, :error, _}), do: :error
  defp status({:status, :unset, _}), do: :unset
  defp status(_), do: :unset
end
