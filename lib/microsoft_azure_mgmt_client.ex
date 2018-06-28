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
      # {Tesla.Middleware.Opts, [proxy_host: '127.0.0.1', proxy_port: 8888]},
      # &use_fiddler/2,
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

  # def use_fiddler(env = %Tesla.Env{}, _stack) do
  #   env
  #   |> Tesla.put_opt(:proxy_host, '127.0.0.1')
  #   |> Tesla.put_opt(:proxy_port, 8888)
  # end

  # def use_fiddler(client = %Tesla.Client{}), do: client |> set_proxy("127.0.0.1", 8888)

  # def set_proxy(client = %Tesla.Client{}, proxy_host, proxy_port) do
  #   new_pre =
  #     case client.pre |> Enum.find_index(&(&1 |> elem(0) == Tesla.Middleware.Opts)) do
  #       nil ->
  #         client.pre ++
  #           [
  #             {Tesla.Middleware.Opts, :call,
  #              [[proxy_host: proxy_host |> String.to_charlist(), proxy_port: proxy_port]]}
  #           ]

  #       idx ->
  #         [opts] = client.pre |> Enum.at(idx) |> elem(2)

  #         opts =
  #           opts
  #           |> Keyword.put(:proxy_host, String.to_charlist(proxy_host))
  #           |> Keyword.put(:proxy_port, proxy_port)
  #           |> IO.inspect()

  #         client.pre |> List.replace_at(idx, {Tesla.Middleware.Opts, :call, [opts]})
  #     end

  #   %Tesla.Client{client | pre: new_pre}
  # end
end
