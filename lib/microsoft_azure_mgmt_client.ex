defmodule MicrosoftAzureMgmtClient do
  use Tesla

  # plug Tesla.Middleware.BaseUrl, "https://management.azure.com"
  plug(Tesla.Middleware.Headers, %{"User-Agent" => "Elixir"})
  plug(Tesla.Middleware.EncodeJson)
  adapter(:ibrowse)

  @scopes [
    # impersonate your user account
    "user_impersonation"
  ]

  def new_azure_public(token), do: "https://management.azure.com" |> new(token)
  def new_azure_germany(token), do: "https://management.microsoftazure.de" |> new(token)
  def new_azure_china(token), do: "https://management.chinacloudapi.cn" |> new(token)
  def new_azure_government(token), do: "https://management.usgovcloudapi.net" |> new(token)

  defp new(base_url, token_fetcher) when is_function(token_fetcher) do
    new(base_url, token_fetcher.(@scopes))
  end

  defp new(base_url, token) when is_binary(token) do
    Tesla.build_client([
      {Tesla.Middleware.BaseUrl, base_url},
      {Tesla.Middleware.Headers, %{"Authorization" => "Bearer #{token}"}}
      # {Tesla.Middleware.Opts, proxy_host: '127.0.0.1', proxy_port: 8888}
    ])
  end

  def use_fiddler(client = %Tesla.Client{}), do: client |> set_proxy("127.0.0.1", 8888)

  def set_proxy(client = %Tesla.Client{}, proxy_host, proxy_port) do
    new_pre =
      case client.pre |> Enum.find_index(&(Tesla.Middleware.Opts == elem(&1, 0))) do
        nil ->
          [
            {Tesla.Middleware.Opts, :call,
             [[proxy_host: proxy_host |> String.to_charlist(), proxy_port: proxy_port]]}
            | client.pre
          ]

        idx ->
          [opts] = client.pre |> Enum.at(idx) |> elem(2)

          opts =
            opts
            |> Keyword.put(:proxy_host, String.to_charlist(proxy_host))
            |> Keyword.put(:proxy_port, proxy_port)
            |> IO.inspect()

          client.pre |> List.replace_at(idx, {Tesla.Middleware.Opts, :call, opts})
      end

    %Tesla.Client{client | pre: new_pre}
  end
end
