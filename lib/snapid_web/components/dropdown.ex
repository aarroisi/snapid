defmodule SnapidWeb.Components.Dropdown do
  use Phoenix.Component

  attr :title, :string, default: "Title", doc: "Title of the dropdown"
  attr :items, :list, default: [], doc: "List of items"
  attr :row_id, :string

  slot :title_icon

  def dropdown(assigns) do
    ~H"""
    <div class="relative inline-block text-left" x-data="{ options_open: false }">
      <div>
        <button
          x-on:click="options_open = !options_open"
          type="button"
          class="inline-flex w-full justify-center gap-x-1.5 rounded-md px-3 py-2 text-sm font-semibold text-brand-900 dark:text-brand-100 shadow-sm ring-1 ring-inset ring-brand-300 hover:bg-brand-50 dark:hover:bg-brand-950"
          id={"menu-button-#{@row_id}"}
          aria-expanded="true"
          aria-haspopup="true"
        >
          <%= render_slot(@title_icon) %>
          <svg
            class="-mr-1 h-5 w-5 text-black dark:text-white"
            viewBox="0 0 20 20"
            fill="currentColor"
            aria-hidden="true"
          >
            <path
              fill-rule="evenodd"
              d="M5.23 7.21a.75.75 0 011.06.02L10 11.168l3.71-3.938a.75.75 0 111.08 1.04l-4.25 4.5a.75.75 0 01-1.08 0l-4.25-4.5a.75.75 0 01.02-1.06z"
              clip-rule="evenodd"
            />
          </svg>
        </button>
      </div>
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
            x-on:click="options_open = false"
            navigate={item.href}
            phx-click={item.phx_click}
            phx-value-id={item.phx_value_id}
            data-confirm={item.data_confirm}
            class={"text-brand-700 dark:text-brand-300 block px-4 py-2 text-sm hover:bg-brand-100 dark:hover:bg-brand-900 #{item.class}"}
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
