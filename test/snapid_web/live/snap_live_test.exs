defmodule SnapidWeb.SnapLiveTest do
  use SnapidWeb.ConnCase

  import Phoenix.LiveViewTest
  import Snapid.SnapsFixtures

  @create_attrs %{title: "some title", body: "some body"}
  @update_attrs %{title: "some updated title", body: "some updated body"}
  @invalid_attrs %{title: nil, body: nil}

  defp create_snap(_) do
    snap = snap_fixture()
    %{snap: snap}
  end

  describe "Index" do
    setup [:create_snap]

    test "lists all snaps", %{conn: conn, snap: snap} do
      {:ok, _index_live, html} = live(conn, ~p"/snaps")

      assert html =~ "Listing Snaps"
      assert html =~ snap.title
    end

    test "saves new snap", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/snaps/new")

      assert index_live
             |> form("#snap-form", snap: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#snap-form", snap: @create_attrs)
             |> render_submit()

      html = render(index_live)
      assert html =~ "some title"
    end

    test "updates snap in listing", %{conn: conn, snap: snap} do
      {:ok, index_live, _html} = live(conn, ~p"/snaps")

      assert index_live |> element("#snaps-#{snap.id} a", "Edit") |> render_click() =~
               "Edit Snap"

      assert_patch(index_live, ~p"/snaps/#{snap}/edit")

      assert index_live
             |> form("#snap-form", snap: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#snap-form", snap: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/snaps")

      html = render(index_live)
      assert html =~ "some updated title"
    end

    test "deletes snap in listing", %{conn: conn, snap: snap} do
      {:ok, index_live, _html} = live(conn, ~p"/snaps")

      assert index_live |> element("#snaps-#{snap.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#snaps-#{snap.id}")
    end
  end

  describe "Show" do
    setup [:create_snap]

    test "displays snap", %{conn: conn, snap: snap} do
      {:ok, _show_live, html} = live(conn, ~p"/snaps/#{snap}")

      assert html =~ "Show Snap"
      assert html =~ snap.title
    end

    test "updates snap within modal", %{conn: conn, snap: snap} do
      {:ok, show_live, _html} = live(conn, ~p"/snaps/#{snap}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               snap.title

      assert_patch(show_live, ~p"/snaps/#{snap}/edit")

      assert show_live
             |> form("#snap-form", snap: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#snap-form", snap: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/snaps/#{snap}")

      html = render(show_live)
      assert html =~ "some updated title"
    end
  end
end
