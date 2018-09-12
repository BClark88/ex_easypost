defmodule ExEasyPostTest do
  use ExUnit.Case, async: true

  @operation %ExEasyPost.Operation{http_method: :get, path: "foo"}

  setup do
    bypass = Bypass.open(port: 5555)

    on_exit(fn ->
      Bypass.down(bypass)
    end)

    %{bypass: bypass}
  end

  test "returns :ok when request is successful", %{bypass: bypass} do
    Bypass.expect(bypass, fn conn ->
      Plug.Conn.resp(conn, 200, ~s<{}>)
    end)

    assert {:ok, %{}} = @operation |> ExEasyPost.request()
  end

  test "converts params to a URL query string for GET requests", %{bypass: bypass} do
    operation = %ExEasyPost.Operation{
      http_method: :get,
      params: %{foo: "bar", hello: "world"},
      path: "foo"
    }

    Bypass.expect(bypass, fn conn ->
      assert "foo=bar&hello=world" == conn.query_string

      Plug.Conn.resp(conn, 200, ~s<{}>)
    end)

    operation |> ExEasyPost.request()
  end

  test "returns :error when request is not successful", %{bypass: bypass} do
    Bypass.expect(bypass, fn conn ->
      Plug.Conn.resp(conn, 400, ~s<{}>)
    end)

    assert {:error, _reason} = @operation |> ExEasyPost.request()
  end
end
