defmodule Tesla.Middleware.XMLRPC.Client.Failure.Test do
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog

  import Tesla.Mock

  alias Tesla.Middleware.XMLRPC.Test.Client

  setup do
    mock(fn
      %{method: :post, url: "http://localhost:8080/RPC2"} ->
        %Tesla.Env{
          status: 401,
          headers: [
            {"www-authenticate", "Basic realm=\"localhost\""},
            {"content-type", "text/html"}
          ],
          body:
            "<HTML><HEAD><TITLE>Error 401</TITLE></HEAD><BODY><H1>Error 401</H1><P>Unauthorized</P><p></BODY></HTML>"
        }
    end)

    :ok
  end

  describe "call/3" do
    test "handles unauthorized response" do
      assert capture_log(fn ->
               assert {:error, {:unauthorized, 401, "Unauthorized"}} = Client.call("foo", ["bar"])
             end) =~ "-> 401"
    end
  end
end
