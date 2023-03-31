defmodule Tesla.Middleware.XMLRPC.Client.Fault.Test do
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
          <fault>
          <value><struct>
          <member><name>faultCode</name>
          <value><i4>-502</i4></value></member>
          <member><name>faultString</name>
          <value><string>Format string requests 2 items from array, but array has only 1 items.</string></value></member>
          </struct></value>
          </fault>
          </methodResponse>
          """
        }
    end)

    :ok
  end

  describe "call/3" do
    test "handles fault response" do
      assert {:error,
              {:fault, -502,
               "Format string requests 2 items from array, but array has only 1 items."}} =
               Client.call("blah", [""])
    end
  end
end
