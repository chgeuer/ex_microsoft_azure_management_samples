defmodule Sample do
  alias Microsoft.Azure.Management.Resources.Api.ResourceGroups
  alias Microsoft.Azure.Management.Compute.Api.VirtualMachineSizes
  alias Microsoft.Azure.Management.Compute.Api.Disks
  alias Microsoft.Azure.Management.Resources.Api.Deployments
  alias Microsoft.Azure.Management.Subscription.Api.Subscriptions
  alias Microsoft.Azure.Management.Storage.Api.StorageAccounts

  require Tesla

  @moduledoc """
  Showcases the Azure management API.
  """

  @api_version %{
    :resource_groups => "2018-02-01",
    :subscription => "2016-06-01",
    :deployments => "2018-02-01",
    :virtual_machine => "2017-12-01",
    :disks => "2018-04-01",
    :storage => "2018-02-01"
  }

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

    # |> MicrosoftAzureMgmtClient.new_azure_public()

    # |> Microsoft.Azure.Management.Connection.new()
    # |> MicrosoftAzureMgmtClient.new_azure_public()
    # |> MicrosoftAzureMgmtClient.use_fiddler()
  end

  def do_raw_request(request) do
    connection()
    |> Microsoft.Azure.Management.Resources.Connection.request(request)
  end

  def resource_groups_list() do
    {:ok, %{value: groups}} =
      connection()
      |> ResourceGroups.resource_groups_list(
        @api_version.resource_groups,
        subscription_id()
      )

    groups
    |> Enum.map(&(&1 |> Map.get(:name)))
  end

  def subscription_list() do
    conn = connection()

    {:ok, %{value: subs}} =
      conn
      |> Subscriptions.subscriptions_list(@api_version.subscription)

    subs
    |> Enum.map(&%{subscriptionId: &1.subscriptionId, name: &1.displayName})
  end

  def resource_groups_create(resource_group_name) do
    location = "westeurope"

    connection()
    |> ResourceGroups.resource_groups_create_or_update(
      resource_group_name,
      %{
        name: resource_group_name,
        location: location,
        tags: %{"elixir" => "rocks"}
      },
      @api_version.resource_groups,
      subscription_id()
    )
    |> IO.inspect()
  end

  def resource_groups_delete(resource_group_name) do
    conn = connection()

    conn
    |> ResourceGroups.resource_groups_delete(
      resource_group_name,
      @api_version.resource_groups,
      subscription_id()
    )
    |> IO.inspect()
  end

  def virtual_machine_sizes_list() do
    location = "westeurope"

    {:ok, %{value: sizes}} =
      connection()
      |> VirtualMachineSizes.virtual_machine_sizes_list(
        location,
        @api_version.virtual_machine,
        subscription_id()
      )

    sizes
    # |> Enum.filter(&(&1.name == "Standard_M64"))
    # |> IO.inspect()
    |> Enum.map(&(&1 |> Map.get(:name)))
  end

  def resources_list_by_resource_group() do
    # https://github.com/Azure/azure-rest-api-specs/blob/master/specification/resources/resource-manager/Microsoft.Resources/stable/2018-02-01/resources.json
    resource_group_name = "longterm"

    connection()
    |> ResourceGroups.resources_list_by_resource_group(
      resource_group_name,
      @api_version.resource_groups,
      subscription_id()
    )
  end

  def resource_groups_export_template() do
    # https://docs.microsoft.com/en-us/rest/api/resources/resourcegroups/exporttemplate
    resource_group_name = "longterm"

    case ResourceGroups.resource_groups_export_template(
           connection(),
           resource_group_name,
           %{
             resources: ["*"],
             options: "IncludeComments"
           },
           @api_version.resource_groups,
           subscription_id()
         ) do
      {:ok,
       %{
         error: %{
           code: error_code,
           details: error_details,
           message: message
         },
         template: %{
           "parameters" => parameters,
           "resources" => resources,
           "variables" => variables
         }
       }} ->
        resources |> Poison.encode!()

      {:error, message} ->
        raise(message)
    end
  end

  # def resources_count_by_exporting() do
  #   Sample.resource_groups_export_template()
  #   |> elem(1)
  #   |> Map.get(:template)
  #   |> Dict.get("resources")
  #   |> Enum.count()
  # end

  def deployments_create_or_update() do
    # https://github.com/Azure/azure-rest-api-specs/blob/master/specification/resources/resource-manager/Microsoft.Resources/stable/2018-02-01/resources.json
    resource_group_name = "longterm"
    deployment_name = "fromelix"

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
      @api_version.deployment,
      subscription_id()
    )
  end

  def deployments_list_by_resource_group() do
    resource_group_name = "longterm"

    Deployments.deployments_list_by_resource_group(
      connection(),
      resource_group_name,
      @api_version.deployment,
      subscription_id()
    )
  end

  def storage_accounts_list() do
    StorageAccounts.storage_accounts_list(
      connection(),
      @api_version.storage,
      subscription_id()
    )
  end

  def storage_accounts_list_keys(resource_group_name, account_name) do
    StorageAccounts.storage_accounts_list_keys(
      connection(),
      resource_group_name,
      account_name,
      @api_version.storage,
      subscription_id()
    )
  end

  def disks_create() do
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
      @api_version.disks,
      %{
        location: location,
        sku: %{name: "Premium_LRS"},
        zones: ["#{availability_zone}"],
        properties: %{
          diskSizeGB: disk_size_GB,
          creationData: %{
            createOption: "Empty"
          }
        }
      }
    )
  end

  defmodule Client do
    use Tesla

    adapter(:ibrowse)
    plug(Tesla.Middleware.BaseUrl, "https://management.azure.com")
    plug(Tesla.Middleware.EncodeJson)
    plug(Tesla.Middleware.JSON)

    def new() do
      Tesla.build_client([])
    end

    def raw_request(request) do
      new() |> Client.request(request)
    end
  end

  def quota() do
    location = "westeurope"
    provider = "Microsoft.Compute"
    # "2018-04-01"
    apiversion = "2014-04"

    [
      method: :get,
      # url: "/subscriptions/#{subscription_id()}/providers/#{provider}/locations/#{location}/usages",
      url: "/subscriptions/#{subscription_id()}/locations",
      query: ["api-version": apiversion],
      headers: %{
        "Content-Type" => "application\json",
        "Authorization" => "Bearer #{token()}"
      }
    ]
    |> Client.raw_request()
  end
end
