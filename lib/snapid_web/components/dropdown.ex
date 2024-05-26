defmodule SnapidWeb.Components.Dropdown do
  use Phoenix.Component

  attr :title, :string, default: "Title", doc: "Title of the dropdown"
  attr :items, :list, default: [], doc: "List of items"
  attr :wrapper_class, :string, default: ""
  attr :row_id, :string
  attr :rest, :global, default: %{}

  slot :title_icon, required: true

  def dropdown(assigns) do
    ~H"""
    <div class={"block #{@wrapper_class}"} x-data="{ options_open: false }">
      <button
        x-on:click="options_open = !options_open"
        type="button"
        class="flex items-center bg-transparent border-none"
        id={"menu-button-#{@row_id}"}
        aria-expanded="true"
        aria-haspopup="true"
      >
        <%= render_slot(@title_icon) %>
      </button>
      <!--
        Dropdown menu, show/hide based on menu state.

        Entering: "transition ease-out duration-100"
          From: "transform opacity-0 scale-95"
          To: "transform opacity-100 scale-100"
        Leaving: "transition ease-in duration-75"
          From: "transform opacity-100 scale-100"
          To: "transform opacity-0 scale-95"
      -->
      <div
        x-show="options_open"
        x-transition
        x-on:click.away="options_open = false"
        class="bg-white dark:bg-brand-800 absolute right-0 z-10 mt-2 w-56 origin-top-right rounded-md shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none"
        role="menu"
        aria-orientation="vertical"
        aria-labelledby="menu-button"
        tabindex="-1"
      >
        <div class="py-1" role="none">
          <.link
            :for={{item, index} <- Enum.with_index(@items)}
            :if={item.is_shown}
            x-on:click="options_open = false"
            navigate={item.href}
            phx-click={item.phx_click}
            phx-value-id={item.phx_value_id}
            data-confirm={item.data_confirm}
            target={item.target}
            class={"text-left text-brand-700 dark:text-brand-300 block px-4 py-2 text-sm hover:bg-brand-100 dark:hover:bg-brand-900 #{item.class}"}
            role="menuitem"
            tabindex="-1"
            id={"menu-item-#{@row_id}-#{index}"}
          >
            <%= item.title %>
          </.link>
        </div>
      </div>
    </div>
    """
  end
end
