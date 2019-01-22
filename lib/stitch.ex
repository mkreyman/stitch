defmodule Stitch do
  @moduledoc """
  Documentation for Stitch.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Stitch.hello()
      :world

  """

  @opts1 [separator: ?,, headers: [:name, :amount], strip_fields: true]
  @opts2 [separator: ?,, headers: [:name, :address], strip_fields: true]
  @matching @opts1[:headers] |> List.first()
  @additional @opts2[:headers] |> List.last()

  def hello do
    :world
  end

  def main(argv) do
    [file1, file2] = parse_args(argv)
    
    stream1 =
      file1
      |> stream(@opts1)

    stream2 =
      file2
      |> stream(@opts2)
      |> Stream.filter(fn row -> row[@matching] in index(stream1) end)

    list_of_maps =
      stream1
      |> Stream.concat(stream2)
      |> Enum.to_list()
      |> Enum.group_by(& &1[@matching])
      |> Map.values()
      |> Enum.map(fn [map1 | [map2 | []]] ->
        put_in(map1, [@additional], map2[@additional])
      end)
      |> IO.inspect()
  end

  defp stream(file, opts) do
    ".."
    |> Path.expand(__DIR__)
    |> Path.join(file)
    |> File.stream!()
    |> CSV.decode!(opts)
  end

  defp index(stream) do
    stream
    |> Enum.map(fn row -> row[@matching] end)
    |> Enum.to_list()
    |> Enum.sort()
  end

  defp parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [])
    case parse do
      {_, [file1, file2], _} ->
        [file1, file2]
      _ ->
        IO.puts("Argument(s) missing.\nPlease provide a path to each csv file, relative to current directory.")
        System.halt(0)
    end
  end
end
