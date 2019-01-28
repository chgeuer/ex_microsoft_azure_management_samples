defmodule MicrosoftAzureMgmtClient do
  use Tesla

  # adapter Tesla.Adapter.Ibrowse # https://github.com/teamon/tesla/wiki/0.x-to-1.0-Migration-Guide#dropped-aliases-support-159
  adapter(:ibrowse)

  # plug Tesla.Middleware.BaseUrl, "https://management.azure.com"
  # plug(Tesla.Middleware.Headers, [{"User-Agent", "Elixir"}])
  plug(Tesla.Middleware.EncodeJson)
  plug(Tesla.Middleware.JSON)

  @scopes [
    # impersonate your user account
    "user_impersonation"
  ]

  def new_azure_public(token), do: "https://management.azure.com" |> new(token)
  def new_azure_germany(token), do: "https://management.microsoftazure.de" |> new(token)
  def new_azure_china(token), do: "https://management.chinacloudapi.cn" |> new(token)
  def new_azure_government(token), do: "https://management.usgovcloudapi.net" |> new(token)

  defp new(base_url, token_fetcher) when is_function(token_fetcher) do
    token = token_fetcher.(@scopes)
    new(base_url, token)
  end

  defp new(base_url, token) when is_binary(token) do
    Tesla.build_client([
      Tesla.Middleware.KeepRequest,
      {Tesla.Middleware.BaseUrl, base_url},
      # https://github.com/teamon/tesla/wiki/0.x-to-1.0-Migration-Guide#headers-are-now-a-list-160
      {Tesla.Middleware.Headers, %{"Authorization" => "Bearer #{token}"}},
      Tesla.Middleware.EncodeJson,
      Tesla.Middleware.JSON,
      proxy_middleware()
    ])
  end

  def proxy_middleware() do
    IO.puts("proxy_mio")

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
                 proxy_port: port |> Integer.parse() |> elem(0)
               ]}
            end).()
    end
  end
end
