defmodule SnapidWeb.SnapLive.Show do
  use SnapidWeb, :live_view
  alias Snapid.Snaps
  alias Snapid.Snaps.Comment
  import SnapidWeb.SnapLive.Comment

  @impl true
  def render(assigns) do
    ~H"""
    <div :if={@live_action == :show} class="mb-4">
      <div class="flex justify-between z-50 -mx-6 sm:-mx-10 md:mx-auto -mt-8 sm:-mt-12 md:-mt-6 mb-6 md:mb-0 border-b md:border-none border-brand-200 dark:border-brand-400 sticky top-0 p-3 md:!px-0 pl bottom-0 w-screen md:w-full bg-white dark:bg-brand-500">
        <.back class="my-auto text-sm" navigate={~p"/snaps"}>Back to snaps</.back>
        <.link navigate={~p"/snaps/#{@snap}/edit"}>
          <.button class="!bg-primary-600 hover:!bg-primary-700 !px-2 !py-1 text-sm">
            Edit snap
          </.button>
        </.link>
      </div>
      <hr class="hidden md:block !m-0 border-brand-200 dark:border-brand-400" />
    </div>
    <%= if @live_action in [:show, :show_public] do %>
      <.header class="mb-5">
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

    <div
      :if={@live_action == :show_public and assigns[:current_user]}
      id={"comment-section-#{@snap.id}"}
      class="flex flex-col w-full"
    >
      <div class="mt-8 mb-2 font-semibold">Comments</div>
      <%!-- Previous Comments --%>
      <div id="comments-container" phx-update="stream">
        <.comment :for={{dom_id, comment} <- @streams.comments} dom_id={dom_id} comment={comment} />
      </div>
      <%!-- New Comments --%>
      <div
        id="new-comment-trigger"
        data-reset={
          JS.toggle_class("hidden",
            to: ["#new-comment-trigger", "#new-comment"]
          )
        }
        class="border-t border-brand-200 dark:border-brand-400 pt-4 min-h-36"
      >
        <span
          phx-click={
            JS.toggle_class("hidden",
              to: ["#new-comment-trigger", "#new-comment"]
            )
          }
          class="cursor-pointer text-gray-400"
        >
          Add a comment here...
        </span>
      </div>
      <.new_comment id="new-comment" form={@form} snap_id={@snap.id} />
    </div>

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
    comments = Snaps.list_comments(snap.id)
    changeset = Snaps.change_comment(%Comment{})

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action, snap.title))
     |> assign(:og_description, snap.description)
     |> assign(:snap, snap)
     |> stream(:comments, comments)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("add_comment", %{"comment" => comment_params}, socket) do
    save_comment(socket, :new, comment_params)
  end

  defp save_comment(socket, :new, comment_params) do
    comment_params =
      comment_params
      |> Map.put("user_id", socket.assigns.current_user.id)
      |> Map.put("snap_id", socket.assigns.snap.id)

    case Snaps.create_comment(comment_params) do
      {:ok, comment} ->
        changeset = Snaps.change_comment(%Comment{})

        {:noreply,
         socket
         |> stream_insert(:comments, comment)
         |> assign_form(changeset)
         |> push_event("reset_trix_editor", %{})
         |> push_event("reset", %{"id" => "new-comment-trigger"})}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp page_title(:show_public, title), do: title
  defp page_title(:show, title), do: title
  defp page_title(:edit, title), do: "Edit #{title}"
end
