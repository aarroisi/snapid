defmodule SnapidWeb.SnapLive.Comment do
  use Phoenix.Component
  import SnapidWeb.CoreComponents

  attr :id, :string
  attr :snap_id, :integer
  attr :parent_comment_id, :any
  attr :myself, :any
  attr :button_text, :string
  attr :class, :string, default: ""
  attr :form, :any

  def new_comment(assigns) do
    ~H"""
    <div id={@id} class={"flex py-4 !w-full min-h-28 #{@class}"}>
      <.simple_form
        for={@form}
        id={"comment-#{@id}"}
        top_actions_class="mb-4"
        phx-submit="add_comment"
        phx-target={assigns[:myself]}
        class="!w-full"
      >
        <.input
          id={"comment-content-#{@id}"}
          wrapper_class="!m-0 hidden"
          field={@form[:body]}
          type="text"
          phx-hook="TrixHooks"
        />
        <div
          id={"trix-toolbar-wrapper-#{@id}"}
          class="!p-0 !m-0 z-50 bg-white dark:bg-brand-500 !w-full"
          phx-update="ignore"
        >
          <trix-toolbar id={"trix-toolbar-1-#{@id}"}></trix-toolbar>
        </div>
        <div
          id={"trix-editor-wrapper-#{@id}"}
          phx-hook="ScrollBottom"
          class="!mt-1 border border-brand-200 dark:border-brand-400 !w-full"
          phx-update="ignore"
        >
          <trix-editor
            id={"editor-comment-#{@id}"}
            toolbar={"trix-toolbar-1-#{@id}"}
            autofocus
            input={"comment-content-#{@id}"}
            class="!mx-0 !my-1 border-0 !px-2 !py-1 trix-content !w-full"
            placeholder="Write your comment here.."
          >
          </trix-editor>
        </div>
        <div class="flex justify-between !mt-2">
          <.button
            class="!bg-secondary-500 hover:!bg-secondary-600 text-sm !py-1 !px-2"
            type="button"
            phx-target={assigns[:myself]}
            phx-click="cancel_add_comment"
          >
            Cancel
          </.button>
          <.button
            class="!bg-primary-600 hover:!bg-primary-700 text-sm !py-1 !px-2"
            type="submit"
            phx-disable-with="Saving..."
          >
            <%= assigns[:button_text] || "Add this comment" %>
          </.button>
        </div>
      </.simple_form>
    </div>
    """
  end
end
