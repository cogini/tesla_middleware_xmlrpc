defmodule Tesla.Middleware.XMLRPC.Test.Client do
  @moduledoc false

  use Tesla

  plug(Tesla.Middleware.BaseUrl, "http://localhost:8080/")
  plug(Tesla.Middleware.XMLRPC)
  plug(Tesla.Middleware.Logger)

  def call(method_name, params, opts \\ []) do
    body = %XMLRPC.MethodCall{method_name: method_name, params: params}

    case post("/RPC2", body, opts) do
      {:ok, %{status: 200, body: %XMLRPC.MethodResponse{param: result}}} ->
        {:ok, result}

      {:ok, %{status: 200, body: %XMLRPC.Fault{fault_code: code, fault_string: reason}}} ->
        {:error, {:fault, code, reason}}

      {:ok, %{status: 401 = code}} ->
        {:error, {:unauthorized, code, "Unauthorized"}}

      {:ok, response} ->
        {:error, {:unexpected_response, response}}

      {:error, _reason} = error ->
        error
    end
  end
end
