defmodule Samples do
  alias Microsoft.Azure.ActiveDirectory.{RestClient, DeviceAuthenticator}

  @azure_environment :azure_global
  @tenant_id "chgeuerfte"
  @azure_mgmt_endpoint "https://management.core.windows.net/"
  defp service_principal_app_id(), do: System.get_env("SAMPLE_SP_APPID")
  defp service_principal_key(), do: System.get_env("SAMPLE_SP_KEY")

  def device_login() do
    {:ok, pid} =
      DeviceAuthenticator.start(
        %{
          tenant_id: "common",
          resource: @azure_mgmt_endpoint,
          azure_environment: @azure_environment
        }
        # , [debug: [:trace]]
      )

    {:ok, %{message: message}} = pid |> DeviceAuthenticator.get_device_code()

    IO.puts(message)

    poll_token(pid)
  end

  defp poll_token(pid) do
    case pid |> DeviceAuthenticator.get_device_code() do
      {:ok, %{access_token: t}} ->
        t

      {:ok, %{message: _}} ->
        Process.sleep(500)
        pid |> poll_token()
    end
  end

  def sp_login(),
    do:
      RestClient.service_principal_login(
        @tenant_id,
        @azure_mgmt_endpoint,
        service_principal_app_id(),
        service_principal_key(),
        @azure_environment
      )
end
