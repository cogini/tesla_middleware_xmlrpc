![test workflow](https://github.com/cogini/tesla_middleware_xmlrpc/actions/workflows/test.yml/badge.svg)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)

# Tesla.Middleware.XMLRPC

Middleware for the [Tesla](https://hexdocs.pm/tesla/readme.html) HTTP client
that encodes and decodes [XML-RPC](http://wikipedia.org/wiki/XML-RPC).

It uses [xmlrpc](https://github.com/ewildgoose/elixir-xml_rpc) to do the actual encoding.

## Installation

Add `tesla_middleware_xmlrpc` to the list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tesla_middleware_xmlrpc, "~> 0.1.0"}
  ]
end
```

## Configuration

Add this middleware as a plug in your client.

```elixir
defmodule FooClient do
  @api_url Application.compile_env(:foo_client, :api_url, "http://localhost:8080/")

  use Tesla

  plug Tesla.Middleware.BaseUrl, @api_url
  plug Tesla.Middleware.XMLRPC
  plug Tesla.Middleware.Logger

  def call(method_name, params, opts \\ []) do
    body = %XMLRPC.MethodCall{method_name: method_name, params: params}
    case post("/RPC2", body, opts) do
      {:ok, %{status: 200, body: %XMLRPC.MethodResponse{param: result}}} ->
        {:ok, result}

      {:ok, %{status: 200, body: %XMLRPC.Fault{fault_code: code, fault_string: reason}}} ->
        {:error, {:fault, code, reason}}

      {:ok, response} ->
        {:error, {:unexpected_response, response}}

      {:error, _reason} = error  ->
        error
    end
  end
end
```

Documentation is here: https://hexdocs.pm/tesla_middleware_xmlrpc

This project uses the Contributor Covenant version 2.1. Check [CODE_OF_CONDUCT.md](/CODE_OF_CONDUCT.md) for more information.
