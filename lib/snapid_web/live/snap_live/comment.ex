defmodule SnapidWeb.SnapLive.Comment do
  use Phoenix.Component
  alias Phoenix.LiveView.JS
  import SnapidWeb.CoreComponents
  import Phoenix.HTML, only: [raw: 1]

  attr :dom_id, :string
  attr :comment, Comment

  def comment(assigns) do
    ~H"""
    <div
      id={@dom_id}
      class="flex flex-col md:flex-row gap-x-2 md:gap-x-6 trix-content border-t border-brand-200 dark:border-brand-400 py-4"
    >
      <div class="flex text-xs sm:text-sm md:text-base flex-row md:flex-col gap-x-2 w-20 !min-w-20 font-extralight">
        <% {date, time} = Snapid.Util.date_string(@comment.inserted_at, "Asia/Jakarta") %>
        <div><%= date %></div>
        <div><%= time %></div>
      </div>
      <div class="flex flex-col gap-y-2 md:gap-y-1">
        <div class="font-semibold"><%= @comment.user["fullname"] %></div>
        <div><%= raw(@comment.body) %></div>
      </div>
    </div>
    """
  end

  attr :id, :string
  attr :snap_id, :integer
  attr :myself, :any
  attr :form, :any

  def new_comment(assigns) do
    ~H"""
    <div id={@id} class="py-4 w-full border-t border-brand-200 dark:border-brand-400 min-h-28">
      <.simple_form for={@form} id="comment" top_actions_class="mb-4" phx-submit="add_comment">
        <.input
          id="comment-content"
          wrapper_class="!m-0 hidden"
          field={@form[:body]}
          type="text"
          phx-hook="TrixHooks"
        />
        <div
          id="trix-toolbar-wrapper"
          class="!p-0 !m-0 w-full z-50 bg-white dark:bg-brand-500"
          phx-update="ignore"
        >
          <trix-toolbar id="trix-toolbar-1"></trix-toolbar>
        </div>
        <div
          id="trix-editor-wrapper"
          class="!mt-1 border border-brand-200 dark:border-brand-400"
          phx-update="ignore"
        >
          <trix-editor
            id="editor-comment"
            phx-hook="ScrollBottom"
            toolbar="trix-toolbar-1"
            autofocus
            input="comment-content"
            class="!mx-0 !my-1 border-0 px-4 !py-2 trix-content"
            placeholder="Write your comment here.."
          >
          </trix-editor>
        </div>
        <div class="flex justify-between mt-4">
          <.button
            class="!bg-secondary-500 hover:!bg-secondary-600 text-sm !py-1 !px-2"
            type="button"
            phx-click="cancel_add_comment"
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
      </.simple_form>
    </div>
    """
  end
end
