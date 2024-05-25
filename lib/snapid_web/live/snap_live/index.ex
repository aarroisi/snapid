defmodule SnapidWeb.SnapLive.Index do
  use SnapidWeb, :live_view
  alias Snapid.Snaps

  @impl true
  def render(assigns) do
    ~H"""
    <div class="z-10 flex flex-row items-center space-x-6 justify-between md:justify-end bg-white z-50 -mx-6 sm:-mx-10 -mt-8 md:mx-auto sm:-mt-12 mb-6 border-b md:border-0 p-3 md:px-0 w-screen md:w-full">
      <%= if @current_user do %>
        <div class="text-[0.8125rem] leading-6 text-zinc-900">
          <%= @current_user.email %>
        </div>
        <div>
          <.link
            href={~p"/users/log_out"}
            method="delete"
            class="text-[0.8125rem] text-zinc-900 font-semibold hover:text-zinc-700"
          >
            Log out
          </.link>
        </div>
      <% end %>
    </div>

    <.header>
      Snaps
      <:actions>
        <.link patch={~p"/snaps/new"}>
          <.button class="!bg-primary-600 hover:!bg-primary-700">New Snap</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="snaps"
      rows={@streams.snaps}
      row_click={fn {_id, snap} -> JS.navigate(~p"/snaps/#{snap}") end}
    >
      <:col :let={{_id, snap}} label="Title"><%= snap.title %></:col>
      <:col :let={{_id, snap}} label="Created"><%= snap.inserted_at |> Timex.from_now() %></:col>
      <:action :let={{_id, snap}}>
        <.link navigate={~p"/snaps/#{snap}/edit"}>
          <.icon name="hero-pencil-square" class="w-5 h-5" />
        </.link>
      </:action>
      <:action :let={{id, snap}}>
        <.link
          phx-click={JS.push("delete", value: %{id: snap.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          <.icon name="hero-trash" class="text-red-600 w-5 h-5" />
        </.link>
      </:action>
    </.table>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :snaps, Snaps.list_snaps())}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "Snaps")
     |> assign(:snap, nil)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    snap = Snaps.get_snap!(id)
    {:ok, _} = Snaps.delete_snap(snap)

    {:noreply, stream_delete(socket, :snaps, snap)}
  end
end
