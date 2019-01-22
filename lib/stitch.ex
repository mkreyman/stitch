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
  def hello do
    :world
  end

  def main([]) do
    IO.puts("Please provide a path to each csv file")
  end

  def main([file1 | [file2 | _]]) do
    stream_1 =
      file1
      |> Path.expand(__DIR__)
      |> File.stream!()
      |> decode!()

    stream_2 =
      file2
      |> Path.expand(__DIR__)
      |> File.stream!()
      |> decode!()
      |> Stream.filter(fn row -> row["name"] in index(stream_1) end)

    combined = Stream.concat(stream_1, stream_2)

    combined
    |> Enum.to_list()
    |> Enum.group_by(& &1["name"])
    |> Map.values()
    |> Enum.map(fn [
                     %{"amount" => amount, "name" => name}
                     | [%{"address" => address, "name" => name} | []]
                   ] ->
      %{"name" => name, "amount" => amount, "address" => address}
    end)
    |> IO.inspect()
  end

  defp index(stream) do
    stream
    |> Enum.map(fn row -> row["name"] end)
    |> Enum.to_list()
    |> Enum.sort()
  end

  defp decode!(stream) do
    stream
    |> CSV.decode!(separator: ?,, headers: true, strip_fields: true)
  end
end
