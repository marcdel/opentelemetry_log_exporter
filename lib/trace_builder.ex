defmodule OpenTelemetryLogExporter.TraceBuilder do
  def build([]), do: []

  def build(spans) do
    groups = Enum.group_by(spans, & &1.parent_span_id)
    root_spans = top_level_spans(groups)
    Enum.map(root_spans, &associate_children(&1, 0, groups))
  end

  defp top_level_spans(groups) do
    groups[nil] || groups |> Map.values() |> List.flatten()
  end

  defp associate_children(span, indent_level, groups) do
    children = groups[span.span_id] || []
    associated_children = Enum.map(children, &associate_children(&1, indent_level + 1, groups))

    Map.merge(span, %{indent_level: indent_level, children: associated_children})
  end
end
