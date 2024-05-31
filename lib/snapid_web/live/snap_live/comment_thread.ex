defmodule SnapidWeb.SnapLive.CommentThread do
  use SnapidWeb, :live_component
  alias Snapid.Snaps
  alias Snapid.Snaps.Comment
  alias SnapidWeb.Endpoint
  alias SnapidWeb.SnapLive.Show
  import SnapidWeb.SnapLive.Comment

  @impl true
  def render(assigns) do
    ~H"""
    <div class="!w-full flex flex-col md:flex-row flex-1 gap-x-2 md:gap-x-6 trix-content border-t border-brand-200 dark:border-brand-400 py-4">
      <div class="flex text-xs sm:text-sm md:text-base flex-row md:flex-col gap-x-2 w-20 !min-w-20 !max-w-20 font-extralight">
        <% {date, time} = Snapid.Util.date_string(@comment.inserted_at, "Asia/Jakarta") %>
        <div><%= date %></div>
        <div><%= time %></div>
      </div>
      <div class="flex-grow gap-y-2 md:gap-y-1 min-w-0">
        <div class="font-semibold !pb-1"><%= @comment.user["fullname"] %></div>
        <div><%= raw(@comment.body) %></div>
        <div id={"reply-container-#{@comment.id}"} class="!mt-4 gap-y-4" phx-update="stream">
          <.reply :for={{dom_id, reply} <- @streams.replys} id={dom_id} comment={reply} />
        </div>
        <div class="flex justify-end text-gray-400 !w-full">
          <span
            :if={@add_comment_reply}
            class="cursor-pointer"
            phx-click="reply"
            phx-target={@myself}
            phx-value-comment_id={@comment.id}
          >
            Add a reply
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
    <div class="bg-gray-50 !p-4 !w-full flex flex-col gap-x-2 md:gap-x-6 trix-content border-t border-brand-200 dark:border-brand-400 py-4">
      <div class="flex text-xs sm:text-sm md:text-base flex-row gap-x-2 w-20 !min-w-20 !max-w-20 font-extralight leading-4">
        <% {date, time} = Snapid.Util.date_string(@comment.inserted_at, "Asia/Jakarta") %>
        <div><%= date %></div>
        <div><%= time %></div>
      </div>
      <div class="flex-grow gap-y-2 md:gap-y-1 min-w-0">
        <div class="font-semibold !pb-1"><%= @comment.user["fullname"] %></div>
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
        replys = Snaps.list_comments(assigns.snap.id, %{parent_comment_id: assigns.comment.id})

        Endpoint.subscribe("comment:#{assigns.comment.id}")

        socket
        |> assign_form(changeset)
        |> stream(:replys, replys)
        |> assign(:is_init, true)
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
