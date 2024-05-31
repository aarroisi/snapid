defmodule SnapidWeb.SnapLive.Index do
  use SnapidWeb, :live_view
  alias Snapid.Snaps
  import SnapidWeb.Components.Dropdown
  import SnapidWeb.Components.Toggle
  import SnapidWeb.Components.Inputs

  @impl true
  def render(assigns) do
    ~H"""
    <div class="z-10 flex flex-row items-center space-x-6 justify-between md:justify-end z-50 -mx-6 sm:-mx-10 -mt-8 md:mx-auto sm:-mt-12 mb-6 border-b border-brand-200 dark:border-brand-400 md:border-0 py-4 px-6 md:px-0 w-screen md:w-full">
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
      <:col :let={{_id, snap}} label="Created">
        <span class="dark:text-white"><%= snap.inserted_at |> Timex.from_now() %></span>
      </:col>
      <:col :let={{_id, snap}} label="Comments" label_class="!text-center">
        <div class="text-center dark:text-white"><%= Snaps.total_comments_count(snap.id) %></div>
      </:col>
      <:col :let={{_id, snap}} label_class="!text-center">
        <%= is_published_icon(%{snap: snap}) %>
      </:col>
      <:action :let={{id, snap}}>
        <.dropdown wrapper_class="ml-auto" title="Actions" items={get_actions(id, snap)} row_id={id}>
          <:title_icon><.icon name="hero-ellipsis-vertical-solid" class="w-6 h-6" /></:title_icon>
        </.dropdown>
      </:action>
    </.table>

    <.modal
      :if={@config_snap}
      id="modal-configure"
      show={true}
      focus_wrap_class="!px-4 sm:!px-6 md:!px-14"
    >
      <div class="flex flex-col gap-y-4">
        <.toggle
          title="Publish the snap"
          subtitle="If a snap is published, it can be accessed by anyone with the link."
          value={@config_snap.is_published}
          phx_click="publish_or_unpublish_snap"
          phx_value_id={@config_snap.id}
        />
        <hr class="!border-brand-200 dark:!border-brand-400" />
        <.simple_form for={@form} id="configure-snap" phx-submit="save_snap">
          <.input wrapper_class="hidden" type="text" field={@form[:id]} />
          <.input_overlap label="Title" field={@form[:title]} />
          <.input_with_addon label="Slug" field={@form[:slug]} addon="snapid.fly.dev/p/" />
          <.textarea_overlap label="Description" field={@form[:description]} />
          <div class="mt-2 flex justify-end">
            <button
              type="submit"
              class="inline-flex items-center rounded-md bg-primary-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-primary-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary-600"
            >
              Save
            </button>
          </div>
        </.simple_form>
      </div>
    </.modal>
    """
  end

  def is_published_icon(assigns) do
    ~H"""
    <div class="flex items-center justify-center">
      <%= if @snap.is_published do %>
        <.icon name="hero-check-circle-solid bg-green-500" class="h-5 w-5" />
      <% else %>
        <.icon name="hero-minus-circle-solid bg-yellow-500" class="h-5 w-5" />
      <% end %>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    current_user_id = socket.assigns.current_user.id

    socket =
      socket
      |> assign(:config_snap, nil)
      |> assign(:form, nil)
      |> stream(:snaps, Snaps.list_snaps(user_id: current_user_id))

    {:ok, socket}
  end

  defp get_actions(id, snap) do
    [
      %{
        is_shown: snap.is_published,
        href: ~p"/p/#{snap.slug}",
        title: "View",
        phx_click: nil,
        phx_value_id: nil,
        data_confirm: nil,
        class: nil,
        target: "_blank"
      },
      %{
        is_shown: true,
        href: nil,
        title: "Configure",
        phx_click: "configure_snap",
        phx_value_id: snap.id,
        data_confirm: nil,
        class: nil,
        target: nil
      },
      %{
        is_shown: true,
        href: ~p"/snaps/#{snap}/edit",
        title: "Edit",
        phx_click: nil,
        phx_value_id: nil,
        data_confirm: nil,
        class: nil,
        target: nil
      },
      %{
        is_shown: true,
        href: nil,
        title: "Delete",
        phx_click: JS.push("delete", value: %{id: snap.id}) |> hide("##{id}"),
        phx_value_id: nil,
        data_confirm: nil,
        class: "!text-red-600",
        target: nil
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

  def handle_event("configure_snap", %{"id" => id}, socket) do
    snap = Snaps.get_snap!(id)
    changeset = Snaps.change_snap(snap)

    socket =
      socket
      |> assign(:config_snap, snap)
      |> assign_form(changeset)
      |> push_event("open-modal", %{"id" => "modal-configure"})

    {:noreply, socket}
  end

  def handle_event("publish_or_unpublish_snap", %{"id" => id}, socket) do
    snap = Snaps.get_snap!(id)

    message =
      if snap.is_published do
        "Snap is successfully unpublished."
      else
        "Snap is successfully published."
      end

    params = %{"is_published" => not snap.is_published}

    {:noreply, save_snap(socket, snap, params, message)}
  end

  def handle_event("save_snap", %{"snap" => %{"id" => id} = params}, socket) do
    snap = Snaps.get_snap!(id)
    {:noreply, save_snap(socket, snap, params)}
  end

  defp save_snap(socket, snap, snap_params, message \\ "Snap is successfully saved.") do
    case Snaps.update_snap(snap, snap_params) do
      {:ok, snap} ->
        socket
        |> stream_insert(:snaps, snap, at: -1)
        |> push_event("close-modal", %{"id" => "modal-configure"})
        |> put_flash("info", message)

      {:error, changeset} ->
        assign_form(socket, changeset)
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
