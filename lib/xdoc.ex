defmodule XDoc do
  require Record

  Record.defrecord :xmlAttribute, Record.extract(:xmlAttribute, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl")

  defmodule ParseError do
    defexception message: "XML parse error"
  end

  def parse!(data), do: parse!(data, [])
  def parse!(data, opts) do
    case parse(data, opts) do
      {:ok, xdoc} -> xdoc
      {:error, reason} -> raise ParseError, message: "XML parse error. Reason: #{inspect(reason)}"
    end
  end

  def parse(data), do: parse(data, [])

  def parse(bin, opts) when is_binary(bin) do
    bin
    |> :binary.bin_to_list()
    |> parse(opts)
  end

  def parse(data, opts) when is_list(data) do
    opts = Keyword.put_new(opts, :namespace_conformant, true)
    {doc, []} = :xmerl_scan.string(data, opts)
    {:ok, doc}
  catch
    :exit, reason -> {:error, reason}
  end

  def all(node, path), do: xpath(node, path, [])
  def all(node, path, opts), do: xpath(node, path, opts)

  def first(node, path), do: first(node, path, [])
  def first(node, path, opts), do: node |> xpath(path, opts) |> take_one

  def take_one([head | _]), do: head
  def take_one(_), do: nil

  def node_name(nil), do: nil
  def node_name(node), do: elem(node, 1)

  def attr(node, name), do: node |> xpath('./@#{name}') |> extract_attr

  def int_attr(node, name) do
    attr(node, name) |> parse_integer
  end

  def float_attr(node, name) do
    attr(node, name) |> parse_float
  end

  def extract_attr([xmlAttribute(value: value)]), do: List.to_string(value)
  def extract_attr(_), do: nil

  def text(node), do: node |> xpath('./text()') |> extract_text
  def float(node) do
    case text(node) do
      nil -> nil
      v -> parse_float(v)
    end
  end

  def int(node) do
    case text(node) do
      nil -> nil
      v -> parse_integer(v)
    end
  end

  defp extract_text([xmlText(value: value)]), do: List.to_string(value)
  defp extract_text(_x), do: nil

  def xpath(nil, _), do: []
  def xpath(node, path), do: xpath(node, path, [])
  def xpath(node, path, opts), do: :xmerl_xpath.string(to_charlist(path), node, opts)

  defp parse_integer(value) do
    {integer, _} = Integer.parse(value)
    integer
  end

  defp parse_float(value) do
    {float, _} = Float.parse(value)
    float
  end
end
