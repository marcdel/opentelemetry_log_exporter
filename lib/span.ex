defmodule OpenTelemetryLogExporter.Event do
  defstruct [:type, :timestamp, attributes: %{}]
end

defmodule OpenTelemetryLogExporter.Span do
  alias OpenTelemetryLogExporter.Event

  defstruct [
    :trace_id,
    :span_id,
    :parent_span_id,
    :name,
    :start_time,
    :end_time,
    :duration_ms,
    :status,
    indent_level: 0,
    attributes: %{},
    children: [],
    events: []
  ]

  def new(otel_span) do
    {
      :span,
      trace_id,
      span_id,
      _trace_state,
      parent_span_id,
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
      trace_id: undefined_to_nil(trace_id),
      span_id: undefined_to_nil(span_id),
      parent_span_id: undefined_to_nil(parent_span_id),
      name: span_name,
      start_time: start_time,
      end_time: end_time,
      duration_ms: duration(start_time, end_time),
      attributes: attributes(attributes),
      events: events(events),
      status: status(status)
    }
  end

  defp undefined_to_nil(:undefined), do: nil
  defp undefined_to_nil(value), do: value

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
