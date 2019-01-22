defmodule Stitch do
  @moduledoc """
  Documentation for Stitch.
  """

  @doc """
  Merge two CSV files together on a matching field to new combined file in the same directory.

  ## Examples

      $ mix escript.build
      $ ./stitch test/fixtures/file1.csv test/fixtures/file2.csv name

      iex> Stitch.main(["test/fixtures/file1.csv", "test/fixtures/file2.csv", "name"])
      :ok

  """
  def main(argv) do
    [file1, file2, match] = parse_args(argv)
    output_file = to_path(file1, :output)

    stream1 =
      file1
      |> stream()

    stream2 =
      file2
      |> stream()
      |> filter(stream1, match)

    stream1
    |> concat(stream2, match)
    |> to_csv(output_file)

    :ok
  end

  defp to_csv(list_of_maps, path) do
    file = File.open!(path, [:write, :utf8])

    list_of_maps
    |> CSV.encode(headers: true)
    |> Enum.each(&IO.write(file, &1))

    IO.puts("\nOutput CSV file:\n  #{path}")
  end

  defp concat(stream1, stream2, match) do
    new_headers = headers(stream2, match)

    stream1
    |> Stream.concat(stream2)
    |> Enum.to_list()
    |> Enum.group_by(& &1[match])
    |> Map.values()
    |> Enum.map(fn [map1 | [map2 | []]] ->
      Enum.reduce(new_headers, map1, fn x, acc ->
        put_in(acc, [x], map2[x])
      end)
    end)
  end

  defp headers(stream, match) do
    stream
    |> Enum.take(1)
    |> List.first()
    |> Map.keys()
    |> Enum.reject(fn h -> h == match end)
  end

  defp stream(file) do
    file
    |> to_path()
    |> File.stream!()
    |> CSV.decode!(separator: ?,, headers: true, strip_fields: true)
  end

  defp index(stream, match) do
    stream
    |> Enum.map(fn row -> row[match] end)
    |> Enum.to_list()
    |> Enum.sort()
  end

  defp filter(stream2, stream1, match) do
    Stream.filter(stream2, fn row -> row[match] in index(stream1, match) end)
  end

  defp to_path(file) do
    ".."
    |> Path.expand(__DIR__)
    |> Path.join(file)
  end

  defp to_path(file, :output) do
    file
    |> Path.dirname()
    |> Path.join("matched_" <> Path.basename(file))
    |> to_path()
  end

  defp parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [])

    case parse do
      {_, [file1, file2, match], _} ->
        [file1, file2, match]

      _ ->
        IO.puts(
          "Argument(s) missing.\nPlease provide a path to each csv file, relative to current directory."
        )

        System.halt(0)
    end
  end
end
