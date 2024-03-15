defmodule Hangman.LiveWeb.ErrorJSONTest do
  use Hangman.LiveWeb.ConnCase, async: true

  test "renders 404" do
    assert Hangman.LiveWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert Hangman.LiveWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
