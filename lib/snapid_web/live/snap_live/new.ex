defmodule SnapidWeb.SnapLive.New do
  use SnapidWeb, :live_view
  alias Snapid.Snaps.Snap

  @impl true
  def render(assigns) do
    ~H"""
    <.live_component
      module={SnapidWeb.SnapLive.FormComponent}
      id={:new}
      title={@page_title}
      snap={@snap}
      action={@live_action}
      patch={~p"/snaps"}
    />
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "New Snap")
     |> assign(:snap, %Snap{})}
  end
end
