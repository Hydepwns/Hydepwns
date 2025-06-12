defmodule HydepwnsLiveviewWeb.TestTypeLive do
  use HydepwnsLiveviewWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Test",
       theme_class: "system-theme",
       string_value: "default",
       integer_value: 42,
       theme: "dark"
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <p>String value: {@string_value}</p>
      <p>Integer value: {@integer_value}</p>
      <p>Theme: {@theme}</p>
    </div>
    """
  end
end
