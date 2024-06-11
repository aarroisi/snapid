defmodule SnapidWeb.UserLoginLive do
  use SnapidWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Log in to account
        <:subtitle>
          Don't have an account?
          <.link navigate={~p"/users/register"} class="font-semibold text-brand hover:underline">
            Sign up
          </.link>
          for an account now.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="login_form"
        action={~p"/users/log_in"}
        phx-update="ignore"
        actions_class="flex flex-col gap-y-4"
      >
        <.input
          class="dark:text-black dark:placeholder-gray-500"
          placeholder="Enter email here"
          field={@form[:email]}
          type="email"
          label="Email"
          required
        />
        <.input
          class="dark:text-black dark:placeholder-gray-500"
          placeholder="Enter password here"
          field={@form[:password]}
          type="password"
          label="Password"
          required
        />

        <:actions>
          <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
            Forgot your password?
          </.link>
        </:actions>
        <:actions>
          <.button phx-disable-with="Logging in..." class="w-full dark:bg-orange-600">
            Log in <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
