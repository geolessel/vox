defmodule VoxTest do
  use ExUnit.Case
  doctest Vox

  describe "partial/2" do
    test "raises without a leading slash for the partial's path" do
      assert_raise RuntimeError, fn ->
        Vox.partial("improper-path.html.eex")
      end
    end

    test "renders a file with assigns" do
      result = Vox.partial("/partials/with-assigns.html.eex", title: "Hello, Vox!")
      assert result =~ "id=\"with-assigns\""
      assert result =~ "Hello, Vox!"
      refute result =~ "@title"
    end

    test "renders a file without assigns" do
      result = Vox.partial("/partials/without-assigns.html.eex")
      assert result =~ "id=\"without-assigns\""
    end
  end
end
