defmodule Tesla.Middleware.XMLRPC.Client.Success.Test do
  use ExUnit.Case, async: true
  import Tesla.Mock

  alias Tesla.Middleware.XMLRPC.Test.Client

  setup do
    mock(fn
      %{method: :post, url: "http://localhost:8080/RPC2"} ->
        %Tesla.Env{
          status: 200,
          headers: [{"content-type", "text/xml"}],
          body: """
          <?xml version="1.0" encoding="UTF-8"?>
          <methodResponse>
          <params>
          <param><value><string>hello</string></value></param>
          </params>
          </methodResponse>
          """
        }
    end)

    :ok
  end

  describe "call/3" do
    test "handles valid response" do
      assert {:ok, "hello"} = Client.call("foo", ["bar"])
    end
  end
end
