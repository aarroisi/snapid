defmodule SnapidWeb.SnapLive.FormComponent do
  use SnapidWeb, :live_component
  alias Snapid.Snaps

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="snap-form"
        top_actions_class="mb-4"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <:top_actions>
          <div class="flex justify-between z-50 -mx-6 sm:-mx-10 -mt-8 sm:-mt-12 md:mx-auto md:-mt-6 md:!w-full !mb-6 md:!mb-0 border-b md:border-none border-brand-200 dark:border-brand-400 sticky top-0 !p-3 md:!px-0 bottom-0 w-screen bg-white dark:bg-brand-500">
            <.button
              class="!bg-secondary-500 hover:!bg-secondary-600 text-sm !py-1 !px-2"
              type="button"
              phx-click={JS.navigate(@patch)}
            >
              Cancel
            </.button>
            <.button
              class="!bg-primary-600 hover:!bg-primary-700 text-sm !py-1 !px-2"
              type="submit"
              phx-disable-with="Saving..."
            >
              Save Snap
            </.button>
          </div>
          <hr class="hidden md:block !m-0 border-brand-200 dark:border-brand-400" />
        </:top_actions>

        <.input
          field={@form[:title]}
          is_show_error={false}
          wrapper_class="!m-0"
          class="!bg-transparent !text-2xl md:!text-3xl font-bold border-none p-0 !m-0 placeholder-[#C0C0C0]"
          type="text"
          placeholder="Enter title here..."
        />
        <.input
          id="content"
          wrapper_class="!m-0 hidden"
          field={@form[:body]}
          type="text"
          phx-hook="TrixHooks"
        />
        <div
          id="trix-toolbar-wrapper"
          class="w-full !m-0 !mt-4 !pb-[10px] border-y border-brand-200 dark:border-brand-400 sticky top-[56px] md:top-0 z-50 bg-white dark:bg-brand-500"
          phx-update="ignore"
        >
          <trix-toolbar id="trix-toolbar-1" class="mt-[10px]"></trix-toolbar>
        </div>
        <div id="trix-editor-wrapper" class="!mt-[2.2px] md:!mt-[5.4px]" phx-update="ignore">
          <trix-editor
            toolbar="trix-toolbar-1"
            autofocus
            input="content"
            class="!mx-0 !my-2 border-0 !px-0 !py-2 trix-content"
            placeholder="Write your best ideas here.."
          >
          </trix-editor>
        </div>
        <hr class="!m-0 border-brand-200 dark:border-brand-400" />
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{snap: snap} = assigns, socket) do
    changeset = Snaps.change_snap(snap)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"snap" => snap_params}, socket) do
    changeset =
      socket.assigns.snap
      |> Snaps.change_snap(snap_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"snap" => snap_params}, socket) do
    save_snap(socket, socket.assigns.action, snap_params)
  end

  defp save_snap(socket, :edit, snap_params) do
    snap_params =
      snap_params
      |> Map.put("user_id", socket.assigns.current_user.id)

    case Snaps.update_snap(socket.assigns.snap, snap_params) do
      {:ok, snap} ->
        notify_parent({:saved, snap})

        {:noreply,
         socket
         |> push_navigate(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_snap(socket, :new, snap_params) do
    snap_params =
      snap_params
      |> Map.put("user_id", socket.assigns.current_user.id)

    case Snaps.create_snap(snap_params) do
      {:ok, snap} ->
        notify_parent({:saved, snap})

        {:noreply,
         socket
         |> push_navigate(to: ~p"/snaps/#{snap}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
