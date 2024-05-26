defmodule SnapidWeb.SnapLive.CommentSection do
  use SnapidWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="flex flex-col w-full">
      <%!-- Previous Comments --%>
      <%!-- New Comments --%>
      <div id="new-comment-trigger" class="border-t border-brand-200 dark:border-brand-400 pt-4">
        <span
          phx-click={
            JS.toggle_class("hidden",
              to: ["#new-comment-trigger", "#new-comment"]
            )
          }
          class="cursor-pointer text-gray-200 dark:text-gray-400"
        >
          Add a comment here...
        </span>
      </div>

      <.new_comment id="new-comment" />
    </div>
    """
  end

  attr :id, :string

  def new_comment(assigns) do
    ~H"""
    <div id={@id} class="hidden w-full border-t border-brand-200 dark:border-brand-400 pb-4 min-h-28">
      <div class="flex flex-col border-t border-x border-brand-200 dark:border-brand-400 mt-4">
        <div
          id="trix-toolbar-wrapper"
          class="!p-0 md:!p-2 !m-0 w-full border-b border-brand-200 dark:border-brand-400 z-50 bg-white dark:bg-brand-500"
          phx-update="ignore"
        >
          <trix-toolbar id="trix-toolbar-1"></trix-toolbar>
        </div>
        <div
          id="trix-editor-wrapper"
          class="border-b border-brand-200 dark:border-brand-400"
          phx-update="ignore"
        >
          <trix-editor
            toolbar="trix-toolbar-1"
            autofocus
            input="content"
            class="!mx-0 !my-1 border-0 px-4 !py-2 trix-content"
            placeholder="Write your comment here.."
          >
          </trix-editor>
        </div>
      </div>
      <div class="flex justify-between mt-4">
        <.button
          class="!bg-secondary-500 hover:!bg-secondary-600 text-sm !py-1 !px-2"
          type="button"
          phx-click={
            JS.toggle_class("hidden",
              to: ["#new-comment-trigger", "#new-comment"]
            )
          }
        >
          Cancel
        </.button>
        <.button
          class="!bg-primary-600 hover:!bg-primary-700 text-sm !py-1 !px-2"
          type="submit"
          phx-disable-with="Saving..."
        >
          Add this comment
        </.button>
      </div>
    </div>
    """
  end

  @impl true
  def update(%{} = assigns, socket) do
    socket =
      socket
      |> assign(assigns)

    {:ok, socket}
  end

  @impl true
  def handle_event("add_new_comment", _, socket) do
    show(%JS{}, "#new-comment")
    hide(%JS{}, "#new-comment-trigger")

    {:noreply, socket}
  end
end
