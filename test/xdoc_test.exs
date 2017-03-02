defmodule XDocTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  @xml """
  <root>
    <a n="5" x="y">1</a>
    <b>3</b>
  </root>
  """

  @invalid_xml """
  <root>
    <a>3</x>
  </root>
  """

  @namespaced_xml """
  <root>
    <h:table xmlns:h="http://www.w3.org/TR/html4/">
      <h:tr>
        <h:td>Apples</h:td>
        <h:td>Bananas</h:td>
      </h:tr>
    </h:table>

    <f:table xmlns:f="https://www.w3schools.com/furniture">
      <f:name>African Coffee Table</f:name>
      <f:width>80</f:width>
      <f:length>120</f:length>
    </f:table>
  </root>
  """

  test "Parse invalid xml" do
    capture_log(fn ->
      {:error, _} = XDoc.parse(@invalid_xml)
    end)
  end

  test "Catch invalid xml exception" do
    assert_raise(XDoc.ParseError, fn ->
      capture_log(fn ->
        XDoc.parse!(@invalid_xml)
      end)
    end)
  end

  test "Parse node text" do
    {:ok, xdoc} = XDoc.parse(@xml)
    assert (XDoc.first(xdoc, ".//b") |> XDoc.text()) == "3"
  end

  test "Parse node as integer" do
    {:ok, xdoc} = XDoc.parse(@xml)
    assert (XDoc.first(xdoc, ".//b") |> XDoc.int()) == 3
  end

  test "Parse node as float" do
    {:ok, xdoc} = XDoc.parse(@xml)
    assert (XDoc.first(xdoc, ".//b") |> XDoc.float()) == 3.0
  end

  test "Parse attribute" do
    {:ok, xdoc} = XDoc.parse(@xml)
    assert (XDoc.first(xdoc, ".//a") |> XDoc.attr("n")) == "5"
  end

  test "Parse attribute as integer" do
    {:ok, xdoc} = XDoc.parse(@xml)
    assert (XDoc.first(xdoc, ".//a") |> XDoc.int_attr("n")) == 5
  end

  test "Parse namespaced xml" do
    xdoc = XDoc.parse!(@namespaced_xml, namespace_conformant: true)
    assert (XDoc.first(xdoc, ".//h:td") |> XDoc.text()) == "Apples"
  end
end
