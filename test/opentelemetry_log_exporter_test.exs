defmodule OpenTelemetryLogExporterTest do
  use ExUnit.Case
  doctest OpentelemetryLogExporter

  test "greets the world" do
    assert OpentelemetryLogExporter.hello() == :world
  end
end
