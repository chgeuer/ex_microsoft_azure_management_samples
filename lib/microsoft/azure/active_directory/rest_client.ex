defmodule Microsoft.Azure.ActiveDirectory.RestClient do
  alias Microsoft.Azure.AzureEnvironment
  alias Microsoft.Azure.ActiveDirectory.Model.{DeviceCodeResponse, TokenResponse}

  use Tesla
  plug(Tesla.Middleware.FormUrlencoded)
  adapter(:ibrowse)

  @az_cli_clientid "04b07795-8ddb-461a-bbee-02f9e1bf7b46"
  # @az_cli_clientid "c7218025-d73c-46c2-bfbb-ef0a6d4b0c40"

  def proxy_middleware() do
    case System.get_env("http_proxy") do
      nil ->
        nil

      "" ->
        nil

      proxy_cfg ->
        proxy_cfg
        |> String.split(":")
        |> (fn [host, port] ->
              {Tesla.Middleware.Opts,
               [
                 proxy_host: host |> String.to_charlist(),
                 proxy_port: port |> String.to_integer()
               ]}
            end).()
    end
  end

  def new() do
    [
      proxy_middleware()
    ]
    |> Enum.filter(&(&1 != nil))
    |> Tesla.build_client()
  end

  def perform_request(context),
    do:
      context
      |> (&__MODULE__.request(__MODULE__.new(), &1)).()

  def add_header(request = %{headers: headers}, k, v) when headers != nil,
    do: request |> Map.put(:headers, headers |> Map.put(k, v))

  def add_header(request, k, v), do: request |> Map.put(:headers, %{k => v})

  def add_param(request, :form, name, value) do
    request
    |> Map.update(:body, %{name => value}, &(&1 |> Map.put(name, value)))
  end

  def clean_tenant_id(tenant_id, azure_environment) when is_atom(azure_environment) do
    %{active_directory_tenant_suffix: domain} = AzureEnvironment.get(azure_environment)

    cond do
      tenant_id == "common" -> tenant_id
      tenant_id |> String.ends_with?(".#{domain}") -> tenant_id
      tenant_id |> UUID.info() |> elem(0) == :ok -> tenant_id
      true -> "#{tenant_id}.#{domain}"
    end
  end

  def create_url(v = %{azure_environment: _, endpoint: :active_directory_endpoint, path: _}) do
    "https://#{AzureEnvironment.get_val(v.azure_environment, v.endpoint)}#{v.path}"
  end

  def url(%{} = context, options \\ []) do
    url =
      context
      |> Map.merge(
        options
        |> Enum.into(%{})
      )
      |> create_url()

    context
    |> Map.put(:url, url)
  end

  def service_principal_login(
        tenant_id,
        resource,
        client_id,
        client_secret,
        azure_environment
      )
      when is_atom(azure_environment) do
    response =
      %{}
      |> Map.put_new(:method, :post)
      |> Map.put(:azure_environment, azure_environment)
      |> url(
        endpoint: :active_directory_endpoint,
        path: "/#{tenant_id |> clean_tenant_id(azure_environment)}/oauth2/token?api-version=1.0"
      )
      |> add_param(:form, "resource", resource)
      |> add_param(:form, "grant_type", "client_credentials")
      |> add_param(:form, "client_id", client_id)
      |> add_param(:form, "client_secret", client_secret)
      |> Enum.into([])
      |> perform_request()

    case response do
      %{status: status} when 400 <= status and status < 500 -> {:error, response.body}
      %{status: 200} -> {:ok, response.body |> TokenResponse.new()}
    end
  end

  def discovery_document(tenant_id, azure_environment) when is_atom(azure_environment) do
    response =
      %{}
      |> Map.put_new(:method, :get)
      |> Map.put(:azure_environment, azure_environment)
      |> url(
        endpoint: :active_directory_endpoint,
        path:
          "/#{tenant_id |> clean_tenant_id(azure_environment)}/.well-known/openid-configuration"
      )
      |> Enum.into([])
      |> perform_request()

    case response do
      %{status: status} when 400 <= status and status < 500 -> {:error, response.body}
      %{status: 200} -> {:ok, response.body |> Poison.decode!()}
    end
  end

  def keys(tenant_id, azure_environment) when is_atom(azure_environment) do
    {:ok, %{"jwks_uri" => jwks_uri}} = tenant_id |> discovery_document(azure_environment)

    response =
      %{}
      |> Map.put_new(:method, :get)
      |> Map.put(:azure_environment, azure_environment)
      |> Map.put_new(:url, jwks_uri)
      |> Enum.into([])
      |> perform_request()

    case response do
      %{status: status} when 400 <= status and status < 500 ->
        {:error, response.body}

      %{status: 200} ->
        {:ok, response.body |> Poison.decode!() |> Map.get("keys") |> Enum.map(&JOSE.JWK.from/1)}
    end
  end

  def get_device_code(tenant_id, resource, azure_environment)
      when is_atom(azure_environment) do
    response =
      %{}
      |> Map.put_new(:method, :post)
      |> Map.put(:azure_environment, azure_environment)
      |> url(
        endpoint: :active_directory_endpoint,
        path:
          "/#{tenant_id |> clean_tenant_id(azure_environment)}/oauth2/devicecode?api-version=1.0"
      )
      |> add_param(:form, "resource", resource)
      |> add_param(:form, "client_id", @az_cli_clientid)
      |> Enum.into([])
      |> perform_request()

    case response do
      %{status: status} when 400 <= status and status < 500 -> {:error, response.body}
      %{status: 200} -> {:ok, response.body |> DeviceCodeResponse.new()}
    end
  end

  def fetch_device_code_token(resource, code, azure_environment)
      when is_binary(resource) and is_binary(code) and is_atom(azure_environment) do
    response =
      %{}
      |> Map.put_new(:method, :post)
      |> Map.put(:azure_environment, azure_environment)
      |> url(
        endpoint: :active_directory_endpoint,
        path: "/common/oauth2/token"
      )
      |> add_param(:form, "resource", resource)
      |> add_param(:form, "code", code)
      |> add_param(:form, "grant_type", "device_code")
      |> add_param(:form, "client_id", @az_cli_clientid)
      |> Enum.into([])
      |> perform_request()

    case response do
      %{status: status} when 400 <= status and status < 500 ->
        {:error, response.body |> Poison.decode!()}

      %{status: 200} ->
        {:ok, response.body |> TokenResponse.new()}
    end
  end

  def refresh_token(resource, refresh_token, azure_environment) when is_atom(azure_environment) do
    response =
      %{}
      |> Map.put_new(:method, :post)
      |> Map.put_new(:azure_environment, azure_environment)
      |> url(
        endpoint: :active_directory_endpoint,
        path: "/common/oauth2/token"
      )
      |> add_param(:form, "resource", resource)
      |> add_param(:form, "refresh_token", refresh_token)
      |> add_param(:form, "grant_type", "refresh_token")
      |> add_param(:form, "client_id", @az_cli_clientid)
      |> Enum.into([])
      |> perform_request()

    case response do
      %{status: status} when 400 <= status and status < 500 ->
        {:error, response.body |> Poison.decode!()}

      %{status: 200} ->
        {:ok, response.body |> TokenResponse.new()}
    end
  end
end
