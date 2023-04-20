defmodule OpenTelemetryLogExporter.TraceBuilder do
  def build(spans) do
    groups = Enum.group_by(spans, & &1.parent_span_id)
    Enum.map(groups[nil], &associate_children(&1, 0, groups))
  end

  defp associate_children(span, indent_level, groups) do
    children =
      Enum.map(groups[span.span_id] || [], &associate_children(&1, indent_level + 1, groups))

    Map.merge(span, %{indent_level: indent_level, children: children})
    # Map.put(span, :children, children)
  end
end
