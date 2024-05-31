defmodule SnapidWeb.SnapLive.Show do
  use SnapidWeb, :live_view
  alias Snapid.Snaps
  alias SnapidWeb.Endpoint
  alias Snapid.Snaps.Comment
  alias SnapidWeb.SnapLive.CommentThread
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
      <div class="mt-8 mb-2 font-semibold">Comments (<%= @total_comments_count %>)</div>
      <%!-- Previous Comments --%>
      <div
        :if={@loaded_comments_number < @total_comments_count}
        class="flex text-xs sm:text-sm md:text-base items-center align-midde w-full h-16 rounded bg-primary-50 dark:bg-brand-600 mb-2"
      >
        <span phx-click="load_more" class="mx-auto text-center cursor-pointer ">
          See previous comments (<%= (@total_comments_count - @loaded_comments_number) |> min(25) %>)
        </span>
      </div>
      <div
        id="comments-container"
        class="flex !w-full flex-col border-b border-brand-200 dark:border-brand-400"
        phx-update="stream"
      >
        <.live_component
          :for={{dom_id, comment} <- @streams.comments}
          id={dom_id}
          module={CommentThread}
          current_user={@current_user}
          comment={comment}
          snap={@snap}
          }
        />
      </div>
      <%!-- New Comments --%>
      <div :if={not @add_comment} id="new-comment-trigger" class="pt-4 min-h-48">
        <span
          phx-click="show_add_comment"
          phx-value-id="editor-comment-new-comment"
          class="cursor-pointer text-gray-400"
        >
          Add a comment here...
        </span>
      </div>
      <.new_comment :if={@add_comment} id="new-comment" form={@form} snap_id={@snap.id} />
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
    total_comments_count = Snaps.total_comments_count(snap.id) || 0
    comments = Snaps.list_comments(snap.id)

    last_id =
      if length(comments) > 0 do
        Enum.at(comments, 0).id
      else
        0
      end

    changeset = Snaps.change_comment(%Comment{})

    if connected?(socket) do
      Endpoint.subscribe("snap:#{snap.id}")
    end

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action, snap.title))
     |> assign(:og_description, snap.description)
     |> assign(:snap, snap)
     |> assign(:add_comment, false)
     |> assign(:last_id, last_id)
     |> assign(:total_comments_count, total_comments_count)
     |> assign(:loaded_comments_number, Enum.count(comments))
     |> stream(:comments, comments)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("add_comment", %{"comment" => comment_params}, socket) do
    save_comment(socket, :new, comment_params)
  end

  def handle_event("show_add_comment", %{"id" => id}, socket) do
    {:noreply,
     assign(socket, :add_comment, true)
     |> push_event("scroll_to_view", %{"id" => id})}
  end

  def handle_event("cancel_add_comment", _params, socket) do
    {:noreply, assign(socket, :add_comment, false)}
  end

  def handle_event("load_more", _params, socket) do
    snap = socket.assigns.snap
    last_id = socket.assigns.last_id
    comments = Snaps.list_comments(snap.id, %{last_id: last_id})
    loaded_comments_number = socket.assigns.loaded_comments_number

    last_id =
      if length(comments) > 0 do
        Enum.at(comments, 0).id
      else
        0
      end

    {:noreply,
     socket
     |> assign(:last_id, last_id)
     |> assign(:loaded_comments_number, loaded_comments_number + Enum.count(comments))
     |> stream(:comments, Enum.reverse(comments), at: 0)}
  end

  @impl true
  def handle_info(%{event: "new_comment", payload: %{comment: comment}}, socket) do
    total_comments_count = socket.assigns.total_comments_count
    loaded_comments_number = socket.assigns.loaded_comments_number

    {:noreply,
     socket
     |> stream_insert(:comments, comment, at: 0)
     |> assign(:total_comments_count, total_comments_count + 1)
     |> assign(:loaded_comments_number, loaded_comments_number + 1)}
  end

  def handle_info(%{event: "new_reply", payload: %{comment: comment}}, socket) do
    if not is_nil(comment.parent_comment_id) do
      send_update(CommentThread,
        id: "comments-#{comment.parent_comment_id}",
        reply: comment
      )
    end

    {:noreply, socket}
  end

  def save_comment(socket, :new, comment_params) do
    comment_params =
      comment_params
      |> Map.put("user_id", socket.assigns.current_user.id)
      |> Map.put("snap_id", socket.assigns.snap.id)

    case Snaps.create_comment(comment_params) do
      {:ok, _} ->
        changeset = Snaps.change_comment(%Comment{})

        {:noreply,
         socket
         |> assign(:add_comment, false)
         |> assign_form(changeset)}

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
