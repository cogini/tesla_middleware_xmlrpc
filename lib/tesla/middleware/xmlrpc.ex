defmodule Tesla.Middleware.XMLRPC do
  @moduledoc """
  Encode requests and decode responses as [XML-RPC](http://wikipedia.org/wiki/XML-RPC).

  ## Examples

  ```
  defmodule FooClient do
    @api_url Application.compile_env(:foo_client, :api_url, "http://localhost:8080/")

    use Tesla

    plug Tesla.Middleware.BaseUrl, @api_url
    plug Tesla.Middleware.XMLRPC

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

  ## Options

  - `:xmlrpc_opts` - options passed to the XMLRPC encoder and decoder
  """

  @behaviour Tesla.Middleware

  @default_encode_content_type "text/xml"
  @default_content_types ["text/xml"]

  @impl Tesla.Middleware
  def call(env, next, opts) do
    opts = opts || []

    with {:ok, env} <- encode(env, opts),
         {:ok, env} <- Tesla.run(env, next) do
      decode(env, opts)
    end
  end

  # Encode request body as XML-RPC.
  @doc false
  def encode(env, opts) do
    with true <- encodable?(env),
         {:ok, body} <- encode_body(env.body, opts) do
      {:ok,
       env
       |> Tesla.put_body(body)
       |> Tesla.put_headers([{"content-type", encode_content_type(opts)}])}
    else
      false -> {:ok, env}
      error -> error
    end
  end

  @spec encode_body(XMLRPC.MethodCall.t(), keyword()) ::
          {:ok, iodata()} | {:ok, binary()} | {:error, {any, binary()}}
  defp encode_body(body, tesla_opts) do
    opts = tesla_opts[:xmlrpc_opts] || []
    XMLRPC.encode(body, opts)
  end

  defp encode_content_type(opts) do
    Keyword.get(opts, :encode_content_type, @default_encode_content_type)
  end

  defp encodable?(%{body: %XMLRPC.MethodCall{}}), do: true
  defp encodable?(_), do: false

  # Decode response body as XML-RPC.
  @doc false
  def decode(env, opts) do
    with true <- decodable?(env, opts),
         {:ok, body} <- decode_body(env.body, opts) do
      {:ok, %{env | body: body}}
    else
      false -> {:ok, env}
      error -> error
    end
  end

  @spec decode_body(iodata(), keyword()) ::
          {:ok, XMLRPC.Fault.t() | XMLRPC.MethodResponse.t()} | {:error, binary()}
  defp decode_body(body, tesla_opts) do
    opts = tesla_opts[:xmlrpc_opts] || []
    XMLRPC.decode(body, opts)
  end

  defp decodable?(env, opts), do: decodable_body?(env) && decodable_content_type?(env, opts)

  defp decodable_body?(env) do
    (is_binary(env.body) && env.body != "") || (is_list(env.body) && env.body != [])
  end

  defp decodable_content_type?(env, opts) do
    case Tesla.get_header(env, "content-type") do
      nil -> true
      content_type -> Enum.any?(content_types(opts), &String.starts_with?(content_type, &1))
    end
  end

  defp content_types(opts) do
    @default_content_types ++ Keyword.get(opts, :decode_content_types, [])
  end
end
