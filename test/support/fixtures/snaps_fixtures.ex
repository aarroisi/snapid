defmodule Snapid.SnapsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Snapid.Snaps` context.
  """

  @doc """
  Generate a snap.
  """
  def snap_fixture(attrs \\ %{}) do
    {:ok, snap} =
      attrs
      |> Enum.into(%{
        body: "some body",
        title: "some title"
      })
      |> Snapid.Snaps.create_snap()

    snap
  end
end
