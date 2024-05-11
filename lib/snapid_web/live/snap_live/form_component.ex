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
        actions_class="bg-white fixed p-4 md:p-0 md:relative bottom-0 left-0 md:left-auto md:bottom-auto w-full"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@form[:title]}
          is_show_error={false}
          class="!text-2xl md:!text-3xl font-bold border-none p-0 !m-0 placeholder-[#C0C0C0]"
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
        <div id="trix-editor-wrapper" class="!mt-[2.2px] md:!mt-[5.4px]" phx-update="ignore">
          <trix-toolbar id="trix-toolbar-1"></trix-toolbar>
          <trix-editor
            toolbar="trix-toolbar-1"
            autofocus
            input="content"
            class="!mx-0 !my-2 border-0 !px-0 !py-2 trix-content"
            placeholder="Write your best ideas here.."
          >
          </trix-editor>
        </div>

        <hr class="!m-0" />
        <:actions>
          <.button class="!bg-secondary-500" type="button" phx-click={JS.navigate(@patch)}>
            Cancel
          </.button>
          <.button class="!bg-primary-600" type="submit" phx-disable-with="Saving...">
            Save Snap
          </.button>
        </:actions>
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
