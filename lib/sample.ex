defmodule Sample do
  alias Microsoft.Azure.Management.Resources.Api.ResourceGroups
  alias Microsoft.Azure.Management.Compute.Api.VirtualMachineSizes
  alias Microsoft.Azure.Management.Compute.Api.Disks
  alias Microsoft.Azure.Management.Resources.Api.Deployments
  alias Microsoft.Azure.Management.Subscription.Api.Subscriptions

  require Tesla

  @moduledoc """
  Showcases the Azure management API.
  """

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

  def connection() do
    token()
    |> Microsoft.Azure.Management.Resources.Connection.new()

    # |> Microsoft.Azure.Management.Connection.new()
    # |> MicrosoftAzureMgmtClient.new_azure_public()
    # |> MicrosoftAzureMgmtClient.use_fiddler()
  end

  def resource_groups_list() do
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

  def subscription_list() do
    conn = connection()
    api_version = "2016-06-01"

    {:ok, %{value: subs}} =
      conn
      |> Subscriptions.subscriptions_list(api_version)

    subs
    |> Enum.map(&%{subscriptionId: &1.subscriptionId, name: &1.displayName})
  end

  def resource_groups_create(resource_group_name) do
    conn = connection()
    api_version = "2018-02-01"
    location = "westeurope"

    conn
    |> ResourceGroups.resource_groups_create_or_update(
      resource_group_name,
      %{
        name: resource_group_name,
        location: location,
        tags: %{"elixir" => "rocks"}
      },
      api_version,
      subscription_id()
    )
    |> IO.inspect()
  end

  def resource_groups_delete(resource_group_name) do
    conn = connection()
    api_version = "2018-02-01"

    conn
    |> ResourceGroups.resource_groups_delete(resource_group_name, api_version, subscription_id())
    |> IO.inspect()
  end

  def virtual_machine_sizes_list() do
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

  def resources_list_by_resource_group() do
    # https://github.com/Azure/azure-rest-api-specs/blob/master/specification/resources/resource-manager/Microsoft.Resources/stable/2018-02-01/resources.json
    connection = connection()
    api_version = "2018-02-01"
    resource_group_name = "longterm"

    connection
    |> ResourceGroups.resources_list_by_resource_group(
      resource_group_name,
      api_version,
      subscription_id()
    )
  end

  def deployments_create_or_update() do
    # https://github.com/Azure/azure-rest-api-specs/blob/master/specification/resources/resource-manager/Microsoft.Resources/stable/2018-02-01/resources.json
    resource_group_name = "longterm"
    deployment_name = "fromelix"
    api_version = "2018-02-01"

    Deployments.deployments_create_or_update(
      connection(),
      resource_group_name,
      deployment_name,
      %{
        properties: %{
          mode: "Incremental",
          # %{ },
          parameters: nil,
          # parametersLink: %{ uri: "", contentVersion: "" },
          template: %{
            "$schema":
              "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
            contentVersion: "1.0.0.0",
            resources: []
          }
          # templateLink: %{ uri: "", contentVersion: "" },
          # onErrorDeployment: %{ type: "", deploymentName: "" },
          # debugSetting: %{detailLevel: ""},
        }
      },
      api_version,
      subscription_id()
    )
  end

  def deployments_list_by_resource_group() do
    # https://github.com/Azure/azure-rest-api-specs/blob/master/specification/resources/resource-manager/Microsoft.Resources/stable/2018-02-01/resources.json
    resource_group_name = "longterm"
    api_version = "2018-02-01"

    Deployments.deployments_list_by_resource_group(
      connection(),
      resource_group_name,
      api_version,
      subscription_id()
    )
  end

  def disks_create() do
    api_version = "2018-04-01"
    resource_group_name = "disk_demo"
    disk_name = "disk_in_zone_1"
    location = "westeurope"
    availability_zone = 1
    disk_size_GB = 128

    resource_group_name
    |> resource_groups_create()

    Disks.disks_create_or_update(
      connection(),
      subscription_id(),
      resource_group_name,
      disk_name,
      api_version,
      %{
        location: location,
        sku: %{ "name": "Premium_LRS" },
        zones: [ "#{availability_zone}" ],
        properties: %{
          diskSizeGB: disk_size_GB,
          creationData: %{
            createOption: "Empty"
          }
        }
      }
    )
  end
end
