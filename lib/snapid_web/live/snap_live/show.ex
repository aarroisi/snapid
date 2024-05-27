defmodule SnapidWeb.SnapLive.Show do
  use SnapidWeb, :live_view

  alias Snapid.Snaps

  @impl true
  def render(assigns) do
    ~H"""
    <%= if @live_action == :show do %>
      <div class="md:hidden flex justify-between z-50 -mx-6 sm:-mx-10 -mt-8 sm:-mt-12 mb-6 border-b border-brand-200 dark:border-brand-400 sticky top-0 p-3 pl bottom-0 w-screen bg-white dark:bg-brand-500">
        <.back class="my-auto text-sm" navigate={~p"/snaps"}>Back to snaps</.back>
        <.link navigate={~p"/snaps/#{@snap}/edit"}>
          <.button class="!bg-primary-600 hover:!bg-primary-700 !px-2 !py-1 text-sm">
            Edit snap
          </.button>
        </.link>
      </div>
    <% end %>
    <%= if @live_action in [:show, :show_public] do %>
      <.header class="mb-6">
        <h1 class="text-2xl md:text-3xl font-bold"><%= @snap.title %></h1>
        <p class="text-sm mt-3">
          <%= if @snap.user["email"] do %>
            <%= @snap.user["email"] %> ·
          <% end %>
          <%= Timex.format!(@snap.inserted_at, "{D} {Mshort} {YYYY}") %>
        </p>
        <.link
          :if={@live_action == :show and not is_nil(@snap.slug)}
          target="_blank"
          navigate={~p"/p/#{@snap.slug}"}
          class="text-sm mt-3 underline"
        >
          /<%= @snap.slug %>
        </.link>
      </.header>
      <hr class="!m-0 border-brand-200 dark:border-brand-400" />
      <div class="!my-4 trix-content"><%= raw(@snap.body) %></div>
    <% end %>
    <%= if @live_action == :show do %>
      <hr class="hidden md:block !m-0 border-brand-200 dark:border-brand-400" />
      <div class="hidden md:flex flex-row justify-between md:p-0 md:relative w-full mt-8">
        <.back class="my-auto" navigate={~p"/snaps"}>Back to snaps</.back>
        <.link navigate={~p"/snaps/#{@snap}/edit"}>
          <.button class="!bg-primary-600 hover:!bg-primary-700">Edit snap</.button>
        </.link>
      </div>
    <% end %>
    <.live_component
      :if={@live_action == :show_public and assigns[:current_user]}
      module={SnapidWeb.SnapLive.CommentSection}
      id={"comment-section-#{@snap.id}"}
      current_user={@current_user}
    />

    <.live_component
      :if={@live_action == :edit}
      module={SnapidWeb.SnapLive.FormComponent}
      id={"form-#{@snap.id}"}
      current_user={@current_user}
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
    snap = Snaps.get_snap!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action, snap.title))
     |> assign(:og_description, snap.description)
     |> assign(:snap, snap)}
  end

  def handle_params(%{"slug" => slug}, _, socket) do
    snap = Snaps.get_snap_by_slug!(slug)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action, snap.title))
     |> assign(:og_description, snap.description)
     |> assign(:snap, snap)}
  end

  defp page_title(:show_public, title), do: title
  defp page_title(:show, title), do: title
  defp page_title(:edit, title), do: "Edit #{title}"
end
