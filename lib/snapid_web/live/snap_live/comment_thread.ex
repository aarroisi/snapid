defmodule SnapidWeb.SnapLive.CommentThread do
  use SnapidWeb, :live_component
  alias Snapid.Snaps
  alias Snapid.Snaps.Comment
  alias SnapidWeb.SnapLive.Show
  import SnapidWeb.SnapLive.Comment

  @impl true
  def render(assigns) do
    ~H"""
    <div
      id={@id}
      class="!w-full flex flex-col md:flex-row flex-1 gap-x-2 md:gap-x-6 trix-content border-b border-brand-200 dark:border-brand-400 py-4"
    >
      <div class="flex text-xs sm:text-sm md:text-base flex-row md:flex-col gap-x-2 w-20 !min-w-20 !max-w-20 font-extralight !leading-3 md:!leading-normal !mb-1">
        <% {date, time} = Snapid.Util.date_string(@comment.inserted_at, "Asia/Jakarta") %>
        <div><%= date %></div>
        <div><%= time %></div>
      </div>
      <div class="flex-grow gap-y-2 md:gap-y-1 min-w-0">
        <div class="font-semibold !pb-1"><%= @comment.user["fullname"] %></div>
        <div><%= raw(@comment.body) %></div>
        <div
          :if={@reply_count > 0 and @is_replys_loaded}
          id={"reply-container-#{@comment.id}"}
          class="!pt-4 !space-y-2"
          phx-update="stream"
        >
          <.reply :for={{dom_id, reply} <- @streams.replys} id={dom_id} comment={reply} />
        </div>
        <div
          :if={@reply_count > 0 and not @is_replys_loaded}
          class="flex text-xs !mt-4 sm:text-sm md:text-base items-center align-midde !w-full h-12 rounded bg-gray-50 dark:bg-brand-700 mb-2"
        >
          <span
            phx-click="load_replies"
            phx-target={@myself}
            class="mx-auto text-center cursor-pointer w-full"
          >
            See replies (<%= @reply_count %>)
          </span>
        </div>
        <div class="flex justify-start text-gray-400 !w-full !mt-1">
          <span
            :if={@add_comment_reply and (@reply_count == 0 or @is_replys_loaded)}
            class="cursor-pointer text-xs sm:text-sm md:text-base"
            phx-click="reply"
            phx-target={@myself}
            phx-value-comment_id={@comment.id}
          >
            Reply
          </span>

          <.new_comment
            :if={not @add_comment_reply}
            id="reply"
            class="!mt-4"
            form={@form}
            myself={@myself}
            snap_id={@snap.id}
            button_text="Add this reply"
            parent_comment_id={@comment.id}
          />
        </div>
      </div>
    </div>
    """
  end

  def reply(assigns) do
    ~H"""
    <div class="rounded-md bg-gray-50 dark:bg-brand-700 !p-4 !w-full flex flex-col gap-x-2 md:gap-x-6 trix-content py-4">
      <div class="flex text-xs sm:text-sm md:text-base flex-row gap-x-2 w-20 !min-w-20 !max-w-20 font-extralight !leading-3 !mb-1">
        <% {date, time} = Snapid.Util.date_string(@comment.inserted_at, "Asia/Jakarta") %>
        <div><%= date %></div>
        <div><%= time %></div>
      </div>
      <div class="font-semibold !pb-1"><%= @comment.user["fullname"] %></div>
      <div class="flex-grow gap-y-2 md:gap-y-1 min-w-0">
        <div><%= raw(@comment.body) %></div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket |> assign(:is_init, false)}
  end

  @impl true
  def update(%{reply: reply}, socket) do
    {:ok,
     socket
     |> assign(:add_comment_reply, true)
     |> stream_insert(:replys, reply)}
  end

  @impl true
  def update(assigns, socket) do
    socket =
      if not socket.assigns.is_init do
        changeset = Snaps.change_comment(%Comment{})
        reply_count = Snaps.total_comments_count(assigns.snap.id, assigns.comment.id) || 0

        socket
        |> assign_form(changeset)
        |> assign(:is_init, true)
        |> assign(:is_replys_loaded, false)
        |> stream(:replys, [])
        |> assign(:reply_count, reply_count)
        |> assign(:add_comment_reply, true)
      else
        socket
      end

    {:ok, socket |> assign(assigns)}
  end

  @impl true
  def handle_event("reply", _params, socket) do
    {:noreply,
     socket
     |> assign(:add_comment_reply, false)}
  end

  def handle_event("load_replies", _params, socket) do
    replys =
      Snaps.list_comments(socket.assigns.snap.id, %{parent_comment_id: socket.assigns.comment.id})

    {:noreply,
     socket
     |> assign(:is_replys_loaded, true)
     |> stream(:replys, replys)}
  end

  def handle_event("cancel_add_comment", _params, socket) do
    {:noreply,
     socket
     |> assign(:add_comment_reply, true)}
  end

  def handle_event("add_comment", %{"comment" => comment_params}, socket) do
    comment_params = Map.put(comment_params, "parent_comment_id", socket.assigns.comment.id)
    Show.save_comment(socket, :new, comment_params)
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
