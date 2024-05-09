defmodule SnapidWeb.SnapLive.Show do
  use SnapidWeb, :live_view

  alias Snapid.Snaps

  @impl true
  def render(assigns) do
    ~H"""
    <%= if @live_action == :show do %>
      <.header class="mb-6">
        <h1 class="text-2xl md:text-3xl font-bold"><%= @snap.title %></h1>
        <p class="text-sm mt-3"><%= Timex.format!(@snap.inserted_at, "{D} {Mshort} {YYYY}") %></p>
      </.header>
      <hr class="!m-0" />
      <div class="!my-4 trix-content"><%= raw(@snap.body) %></div>
      <hr class="!m-0" />
      <div class="w-full flex justify-between mt-8">
        <.back navigate={~p"/snaps"}>Back to snaps</.back>
        <.link navigate={~p"/snaps/#{@snap}/edit"}>
          <.button class="!bg-primary-600">Edit snap</.button>
        </.link>
      </div>
    <% end %>

    <.live_component
      :if={@live_action == :edit}
      module={SnapidWeb.SnapLive.FormComponent}
      id={@snap.id}
      title={@page_title}
      action={@live_action}
      snap={@snap}
      patch={~p"/snaps/#{@snap}"}
    />
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:snap, Snaps.get_snap!(id))}
  end

  defp page_title(:show), do: "Show Snap"
  defp page_title(:edit), do: "Edit Snap"
end
