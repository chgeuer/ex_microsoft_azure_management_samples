defmodule ExMicrosoftAzureManagementSamples do
  alias Microsoft.Azure.Management.Connection, as: AzureManagementClient
  alias Microsoft.Azure.Management.Resources.Api.ResourceGroups
  alias Microsoft.Azure.Management.Compute.Api.VirtualMachineSizes

  @moduledoc """
  Showcases the Azure management API.
  """

  def connection() do
    token()
    # |> AzureManagementClient.new()
    |> MicrosoftAzureMgmtClient.new_azure_public()
    |> MicrosoftAzureMgmtClient.use_fiddler()
  end

  def subscription_id() do
    Application.get_env(:ex_microsoft_azure_management_samples, :subscription_id)
  end

  def tenant_id() do
    Application.get_env(:ex_microsoft_azure_management_samples, :tenant_id)
  end

  @doc """
  Steals a valid `access_token` from the user's 'az cli' directory (~/.azure/accessTokens.json).

  If the token is expired, run an operation like `az vm list` to re-fresh the token cache.

  Returns the value of the `access_token`.
  """
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

  def export_rg() do
    conn = connection()
    api_version = "2017-12-01"
    resource_group_name = "longterm"
    parameters = %{}

    conn
    |> ResourceGroups.resource_groups_export_template(
      resource_group_name,
      parameters,
      api_version,
      subscription_id()
    )
  end
end
