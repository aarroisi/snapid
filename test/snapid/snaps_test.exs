defmodule Snapid.SnapsTest do
  use Snapid.DataCase

  alias Snapid.Snaps

  describe "snaps" do
    alias Snapid.Snaps.Snap

    import Snapid.SnapsFixtures

    @invalid_attrs %{title: nil, body: nil}

    test "list_snaps/0 returns all snaps" do
      snap = snap_fixture()
      assert Snaps.list_snaps() == [snap]
    end

    test "get_snap!/1 returns the snap with given id" do
      snap = snap_fixture()
      assert Snaps.get_snap!(snap.id) == snap
    end

    test "create_snap/1 with valid data creates a snap" do
      valid_attrs = %{title: "some title", body: "some body"}

      assert {:ok, %Snap{} = snap} = Snaps.create_snap(valid_attrs)
      assert snap.title == "some title"
      assert snap.body == "some body"
    end

    test "create_snap/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Snaps.create_snap(@invalid_attrs)
    end

    test "update_snap/2 with valid data updates the snap" do
      snap = snap_fixture()
      update_attrs = %{title: "some updated title", body: "some updated body"}

      assert {:ok, %Snap{} = snap} = Snaps.update_snap(snap, update_attrs)
      assert snap.title == "some updated title"
      assert snap.body == "some updated body"
    end

    test "update_snap/2 with invalid data returns error changeset" do
      snap = snap_fixture()
      assert {:error, %Ecto.Changeset{}} = Snaps.update_snap(snap, @invalid_attrs)
      assert snap == Snaps.get_snap!(snap.id)
    end

    test "delete_snap/1 deletes the snap" do
      snap = snap_fixture()
      assert {:ok, %Snap{}} = Snaps.delete_snap(snap)
      assert_raise Ecto.NoResultsError, fn -> Snaps.get_snap!(snap.id) end
    end

    test "change_snap/1 returns a snap changeset" do
      snap = snap_fixture()
      assert %Ecto.Changeset{} = Snaps.change_snap(snap)
    end
  end
end
