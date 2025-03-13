#! /usr/bin/env elixir

# Find deprecated references script
# Helps identify references to deprecated modules in the codebase.
#
# Usage: 
#   mix run scripts/find_deprecated_references.exs
#   
# This script will search for references to deprecated modules and provide
# a report of files that need to be updated.

# Define deprecated modules and their replacements
deprecated_modules = %{
  "HydepwnsLiveview.Themes" => "HydepwnsLiveview.ThemeSystem",
  "HydepwnsLiveview.Themes.Theme" => "HydepwnsLiveview.ThemeSystem.Models.Theme",
  "HydepwnsLiveview.Performance.ResourceOptimizer" => "HydepwnsLiveview.Resources.PerformanceOptimizer"
}

defmodule DeprecationFinder do
  def scan_directory(dir, deprecated_modules) do
    if File.dir?(dir) do
      dir
      |> File.ls!()
      |> Enum.map(fn file -> Path.join(dir, file) end)
      |> Enum.flat_map(fn path ->
        cond do
          File.dir?(path) && !String.contains?(path, ["_build", "deps", ".git"]) ->
            scan_directory(path, deprecated_modules)
          String.ends_with?(path, [".ex", ".exs"]) ->
            scan_file(path, deprecated_modules)
          true ->
            []
        end
      end)
    else
      []
    end
  end

  def scan_file(path, deprecated_modules) do
    case File.read(path) do
      {:ok, content} ->
        deprecated_modules
        |> Enum.flat_map(fn {deprecated, replacement} ->
          if String.contains?(content, deprecated) do
            [%{
              file: path,
              deprecated: deprecated, 
              replacement: replacement,
              line_count: count_occurrences(content, deprecated)
            }]
          else
            []
          end
        end)
      _ -> 
        []
    end
  end

  defp count_occurrences(content, pattern) do
    content
    |> String.split("\n")
    |> Enum.filter(&String.contains?(&1, pattern))
    |> Enum.count()
  end
end

# Scan the lib, test, and config directories
IO.puts "\n🔍 Scanning for deprecated module references...\n"

findings = DeprecationFinder.scan_directory(".", deprecated_modules)

if Enum.empty?(findings) do
  IO.puts "✅ No deprecated module references found!"
else
  findings_by_file = Enum.group_by(findings, & &1.file)
  
  IO.puts "⚠️  Found #{Enum.count(findings)} deprecated module references in #{map_size(findings_by_file)} files:\n"
  
  findings_by_file
  |> Enum.sort_by(fn {_file, refs} -> Enum.count(refs) end, :desc)
  |> Enum.each(fn {file, references} ->
    IO.puts "📄 #{file} (#{Enum.count(references)} references)"
    
    references
    |> Enum.sort_by(& &1.line_count, :desc)
    |> Enum.each(fn %{deprecated: deprecated, replacement: replacement, line_count: count} ->
      IO.puts "   - Replace #{deprecated} with #{replacement} (#{count} occurrences)"
    end)
    
    IO.puts ""
  end)
  
  IO.puts "To fix these issues, edit the files listed above and replace the deprecated modules with their current versions."
  IO.puts "For more information, see docs/PRD/PROJECT_MANAGEMENT/CODE_CONSISTENCY.md"
end 