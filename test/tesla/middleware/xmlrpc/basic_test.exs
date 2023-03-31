defmodule Tesla.Middleware.XMLRPC.BasicTest do
  use ExUnit.Case, async: true

  @method_struct %XMLRPC.MethodCall{method_name: "foo", params: ["bar"]}

  describe "encode/2" do
    test "does not encode empty body" do
      assert {:ok, %{body: ""}} = Tesla.Middleware.XMLRPC.encode(%Tesla.Env{body: ""}, [])
    end

    test "does not encode string body" do
      assert {:ok, %{body: "foo"}} = Tesla.Middleware.XMLRPC.encode(%Tesla.Env{body: "foo"}, [])
    end

    test "encodes XMLRPC.MethodCall struct" do
      expected =
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?><methodCall><methodName>foo</methodName><params><param><value><string>bar</string></value></param></params></methodCall>"

      assert {:ok, %{body: ^expected}} =
               Tesla.Middleware.XMLRPC.encode(%Tesla.Env{body: @method_struct}, [])
    end

    test "uses xmlrpc_options iodata true" do
      expected = [
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
        "<methodCall>",
        [
          "<methodName>",
          "foo",
          "</methodName>",
          "<params>",
          [["<param>", ["<value>", ["<string>", "bar", "</string>"], "</value>"], "</param>"]],
          "</params>"
        ],
        "</methodCall>"
      ]

      assert {:ok, %{body: ^expected}} =
               Tesla.Middleware.XMLRPC.encode(%Tesla.Env{body: @method_struct},
                 xmlrpc_opts: [iodata: true]
               )
    end

    test "uses xmlrpc_options true" do
      expected = [
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
        "<methodCall>",
        [
          "<methodName>",
          "foo",
          "</methodName>",
          "<params>",
          [["<param>", ["<value>", ["<string>", "bar", "</string>"], "</value>"], "</param>"]],
          "</params>"
        ],
        "</methodCall>"
      ]

      assert {:ok, %{body: ^expected}} =
               Tesla.Middleware.XMLRPC.encode(%Tesla.Env{body: @method_struct},
                 xmlrpc_opts: [iodata: true]
               )
    end
  end

  describe "decode/2" do
    test "handles empty response" do
      response = """
      """

      assert {:ok, %{body: ""}} = Tesla.Middleware.XMLRPC.decode(%Tesla.Env{body: response}, [])
    end

    test "handles response" do
      response = """
      <?xml version="1.0" encoding="UTF-8"?>
      <methodResponse>
      <params>
      <param><value><string>hello</string></value></param>
      </params>
      </methodResponse>
      """

      assert {:ok, %{body: %{param: "hello"}}} =
               Tesla.Middleware.XMLRPC.decode(%Tesla.Env{body: response}, [])
    end

    test "handles fault" do
      response = """
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

      assert {:ok,
              %{
                body: %XMLRPC.Fault{
                  fault_code: -502,
                  fault_string:
                    "Format string requests 2 items from array, but array has only 1 items."
                }
              }} = Tesla.Middleware.XMLRPC.decode(%Tesla.Env{body: response}, [])
    end
  end
end
