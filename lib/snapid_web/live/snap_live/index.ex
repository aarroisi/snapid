defmodule SnapidWeb.SnapLive.Index do
  use SnapidWeb, :live_view
  alias Snapid.Snaps
  import SnapidWeb.Components.Dropdown

  @impl true
  def render(assigns) do
    ~H"""
    <div class="z-10 flex flex-row items-center space-x-6 justify-between md:justify-end z-50 -mx-6 sm:-mx-10 -mt-8 md:mx-auto sm:-mt-12 mb-6 border-b border-brand-600 dark:border-brand-400 md:border-0 p-3 md:px-0 w-screen md:w-full">
      <%= if @current_user do %>
        <div class="text-[0.8125rem] leading-6 text-brand-900 dark:text-brand-100">
          <%= @current_user.email %>
        </div>
        <div>
          <.link
            href={~p"/users/log_out"}
            method="delete"
            class="text-[0.8125rem] text-brand-900 dark:text-brand-100 font-semibold hover:text-brand-700 dark:hover:text-brand-300"
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
      show_actions_on_mobile={true}
      rows={@streams.snaps}
      row_click={fn {_id, snap} -> JS.navigate(~p"/snaps/#{snap}") end}
    >
      <:col :let={{_id, snap}} label="Title"><%= snap.title %></:col>
      <:col :let={{_id, snap}} label="Created"><%= snap.inserted_at |> Timex.from_now() %></:col>
      <:action :let={{id, snap}}>
        <.dropdown title="Actions" items={get_actions(id, snap)}>
          <:title_icon><.icon name="hero-pencil-square" class="w-5 h-5" /></:title_icon>
        </.dropdown>
      </:action>
    </.table>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    current_user_id = socket.assigns.current_user.id

    socket =
      socket
      |> stream(:snaps, Snaps.list_snaps(user_id: current_user_id))

    {:ok, socket}
  end

  defp get_actions(id, snap) do
    [
      %{
        href: ~p"/snaps/#{snap}/edit",
        title: "Edit",
        phx_click: nil,
        data_confirm: nil,
        class: nil
      },
      %{
        href: nil,
        title: "Delete",
        phx_click: JS.push("delete", value: %{id: snap.id}) |> hide("##{id}"),
        data_confirm: "Are you sure?",
        class: "!text-red-600"
      }
    ]
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
