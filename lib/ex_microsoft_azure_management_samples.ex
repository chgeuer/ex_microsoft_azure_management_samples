defmodule ExMicrosoftAzureManagementSamples do
  alias Microsoft.Azure.Management.Connection, as: AzureManagementClient
  alias Microsoft.Azure.Management.Resources.Api.ResourceGroups
  alias Microsoft.Azure.Management.Compute.Api.VirtualMachineSizes

  @moduledoc """
  Showcases the Azure management API.
  """

  def connection() do
    token()
    |> AzureManagementClient.new()
  end

  def subscription_id() do
    Application.get_env(:ex_microsoft_azure_management_samples, :subscription_id)
  end

  def tenant_id() do
    Application.get_env(:ex_microsoft_azure_management_samples, :tenant_id)
  end

  def token() do
    %{"accessToken" => token} =
      System.user_home!()
      |> Path.absname()
      |> Path.join(".azure")
      |> Path.join("accessTokens.json")
      |> File.read!()
      |> Poison.decode!()
      |> Enum.filter(&(&1["_authority"] == "https://login.microsoftonline.com/" <> tenant_id()))
      |> List.last()

    token
  end

  def list_resource_groups() do
    conn = connection()

    api_version = "2018-02-01"

    {:ok, %{value: groups}} =
      conn
      |> ResourceGroups.resource_groups_list(
        api_version,
        subscription_id()
      )

    groups
    |> Enum.map(&(&1 |> Map.get(:name)))
  end

  def list_vm_sizes() do
    conn = connection()
    api_version = "2017-12-01"
    location = "westeurope"

    {:ok, %{value: sizes}} =
      conn
      |> VirtualMachineSizes.virtual_machine_sizes_list(
        location,
        api_version,
        subscription_id()
      )

    sizes
    |> Enum.map(&(&1 |> Map.get(:name)))
  end
end
