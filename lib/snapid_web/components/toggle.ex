defmodule SnapidWeb.Components.Toggle do
  use Phoenix.Component

  attr :title, :string, default: "Title"
  attr :subtitle, :string, default: "Subtitle"
  attr :value, :boolean, default: false
  attr :phx_click, :string, default: ""
  attr :phx_value_id, :integer, default: 0

  def toggle(assigns) do
    ~H"""
    <div class="flex items-center justify-between gap-x-4">
      <span class="flex flex-grow flex-col">
        <span
          class="text-sm font-medium leading-6 text-gray-900 dark:text-gray-100"
          id="availability-label"
        >
          <%= @title %>
        </span>
        <span class="text-sm text-gray-500 dark:text-gray-400" id="availability-description">
          <%= @subtitle %>
        </span>
      </span>
      <!-- Enabled: "bg-primary-600", Not Enabled: "bg-gray-200" -->
      <button
        type="button"
        phx-click={@phx_click}
        phx-value-id={@phx_value_id}
        class={[
          @value && "bg-primary-600",
          not @value && "bg-gray-200 dark:bg-gray-500",
          "relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-primary-600 dark:focus:ring-offset-brand-900 focus:ring-offset-2"
        ]}
        role="switch"
        aria-checked={if @value, do: "true", else: "false"}
        aria-labelledby="availability-label"
        aria-describedby="availability-description"
      >
        <!-- Enabled: "translate-x-5", Not Enabled: "translate-x-0" -->
        <span
          aria-hidden="true"
          class={[
            @value && "translate-x-5",
            not @value && "translate-x-0",
            "pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white dark:bg-brand-900 shadow ring-0 dark:ring-brand-500 transition duration-200 ease-in-out"
          ]}
        >
        </span>
      </button>
    </div>
    """
  end
end
