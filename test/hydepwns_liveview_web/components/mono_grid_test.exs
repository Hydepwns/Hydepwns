defmodule HydepwnsLiveviewWeb.Components.MonoGridTest do
  use HydepwnsLiveviewWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  alias HydepwnsLiveviewWeb.Components.MonoGrid

  describe "grid/1" do
    test "renders a basic grid" do
      html =
        render_component(&MonoGrid.grid/1, %{id: "test-grid", rows: 2, cols: 20})

      assert html =~ "test-grid"
      assert html =~ "mono-grid"
    end

    test "renders a grid with borders" do
      html =
        render_component(&MonoGrid.grid/1, %{id: "test-grid", rows: 2, cols: 20, bordered: true})

      assert html =~ "test-grid"
      assert html =~ "mono-grid"
      assert html =~ "mono-grid--bordered"
    end

    test "renders a grid with debug mode" do
      html =
        render_component(&MonoGrid.grid/1, %{id: "test-grid", rows: 2, cols: 20, debug: true})

      assert html =~ "test-grid"
      assert html =~ "mono-grid"
      assert html =~ "mono-grid--debug"
    end
  end

  describe "cell/1" do
    test "renders a cell with correct positioning" do
      html =
        render_component(&MonoGrid.cell/1, %{row: 1, col: 1, colspan: 10, rowspan: 1})

      assert html =~ "mono-grid__cell"
      assert html =~ "style="
      assert html =~ "grid-row: 1"
      assert html =~ "grid-column: 1 / span 10"
    end

    test "renders a cell with content" do
      html =
        render_component(&MonoGrid.cell/1, %{row: 1, col: 1, colspan: 10, rowspan: 1}, do: "Cell content")

      assert html =~ "mono-grid__cell"
      assert html =~ "Cell content"
    end

    test "renders a cell with alignment" do
      html =
        render_component(&MonoGrid.cell/1, %{row: 1, col: 1, colspan: 10, rowspan: 1, align: :center})

      assert html =~ "mono-grid__cell"
      assert html =~ "text-align: center"
    end
  end

  describe "grid with cells" do
    test "renders a complete grid with cells" do
      assigns = %{id: "test-grid", rows: 2, cols: 20}

      html =
        render_component(fn assigns ->
          ~H"""
          <MonoGrid.grid id={@id} rows={@rows} cols={@cols}>
            <MonoGrid.cell row={1} col={1} colspan={20}>
              Header
            </MonoGrid.cell>
            <MonoGrid.cell row={2} col={1} colspan={10}>
              Left
            </MonoGrid.cell>
            <MonoGrid.cell row={2} col={11} colspan={10}>
              Right
            </MonoGrid.cell>
          </MonoGrid.grid>
          """
        end, assigns)

      assert html =~ "test-grid"
      assert html =~ "mono-grid"
      assert html =~ "Header"
      assert html =~ "Left"
      assert html =~ "Right"
    end
  end
end 