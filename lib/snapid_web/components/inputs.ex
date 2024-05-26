defmodule SnapidWeb.Components.Inputs do
  use Phoenix.Component
  import SnapidWeb.CoreComponents, only: [input: 1]

  attr :label, :string, default: "Label"
  attr :addon, :string, default: "https://"
  attr :name, :string, default: ""
  attr :id, :string, default: ""
  attr :placeholder, :string, default: "www.example.com"
  attr :value, :string, default: ""

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  def input_overlap(assigns) do
    ~H"""
    <div class="relative">
      <label
        for={assigns[:name]}
        class="absolute -top-2 left-2 inline-block bg-white dark:bg-brand-500 px-1 text-xs font-medium text-gray-900 dark:text-gray-100"
      >
        <%= assigns[:label] %>
      </label>
      <.input
        type="text"
        field={@field}
        class="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-brand-200 dark:ring-brand-400 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-primary-600 sm:text-sm sm:leading-6 dark:bg-brand-500"
        placeholder={assigns[:placeholder]}
      />
    </div>
    """
  end

  def input_with_addon(assigns) do
    ~H"""
    <div class="relative flex rounded-md shadow-sm !w-full">
      <label
        for={assigns[:name]}
        class="absolute -top-2 left-2 inline-block bg-white dark:bg-brand-500 px-1 text-xs font-medium text-gray-900 dark:text-gray-100"
      >
        <%= assigns[:label] %>
      </label>
      <span class="inline-flex items-center rounded-l-md border border-r-0 border-brand-200 dark:border-brand-400 px-3 text-gray-500 dark:text-gray-400 sm:text-sm">
        <%= assigns[:addon] %>
      </span>
      <.input
        type="text"
        field={@field}
        wrapper_class="w-full"
        class="!block !w-full !min-w-0 !flex-1 !rounded-none !rounded-r-md !border-0 !py-1.5 !text-gray-900 dark:!text-gray-100 !ring-1 !ring-inset !ring-brand-200 dark:!ring-brand-400 placeholder:!text-gray-400 focus:!ring-2 focus:!ring-inset focus:!ring-primary-600 sm:!text-sm sm:!leading-6 dark:!bg-brand-500"
        placeholder={assigns[:placeholder]}
      />
    </div>
    """
  end

  def textarea_overlap(assigns) do
    ~H"""
    <div class="relative">
      <label
        for={assigns[:name]}
        class="absolute -top-2 left-2 inline-block bg-white dark:bg-brand-500 px-1 text-xs font-medium text-gray-900 dark:text-gray-100"
      >
        <%= assigns[:label] %>
      </label>
      <.input
        type="textarea"
        field={@field}
        rows="3"
        class="block w-full rounded-md border-0 py-1.5 text-gray-900 dark:text-gray-100 shadow-sm ring-1 ring-inset ring-brand-200 dark:ring-brand-400 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-primary-600 sm:text-sm sm:leading-6 dark:!bg-brand-500 !resize-none "
      />
    </div>
    """
  end
end
