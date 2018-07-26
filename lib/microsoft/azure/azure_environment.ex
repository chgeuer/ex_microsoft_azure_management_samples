defmodule Microsoft.Azure.AzureEnvironment do
  @moduledoc """
  A collection of currently available Microsoft Azure Cloud Environments.
  """

  defstruct [
    :name,
    :management_portal_url,
    :publish_settings_url,
    :service_management_endpoint,
    :resource_manager_endpoint,
    :active_directory_endpoint,
    :active_directory_tenant_suffix,
    :gallery_endpoint,
    :keyvault_endpoint,
    :graph_endpoint,
    :storage_dns_suffix,
    :sqldatabase_dns_suffix,
    :trafficmanager_dns_suffix,
    :keyvault_dns_suffix,
    :servicebus_dns_suffix
  ]

  @doc """
  Returns the cloud environment's endpoints.

  ## Examples

  iex> AzureEnvironment.get(:azure_cloud).storage_dns_suffix
  "core.windows.net"

  iex> AzureEnvironment.get(:azure_german_cloud).management_portal_url
  "http://portal.microsoftazure.de"

  """
  def get(:azure), do: get(:azure_cloud)
  def get(:public), do: get(:azure_cloud)
  def get(:com), do: get(:azure_cloud)
  def get(:worldwide), do: get(:azure_cloud)
  def get(:azure_cloud), do: azure_cloud()

  def get(:us), do: get(:azure_usgovernment_cloud)
  def get(:usgov), do: get(:azure_usgovernment_cloud)
  def get(:fairfax), do: get(:azure_usgovernment_cloud)
  def get(:azure_gov), do: get(:azure_usgovernment_cloud)
  def get(:azure_usgovernment_cloud), do: azure_usgovernment_cloud()

  def get(:cn), do: get(:azure_china_cloud)
  def get(:china), do: get(:azure_china_cloud)
  def get(:mooncake), do: get(:azure_china_cloud)
  def get(:azure_china), do: get(:azure_china_cloud)
  def get(:azure_china_cloud), do: azure_china_cloud()

  def get(:de), do: get(:azure_german_cloud)
  def get(:germany), do: get(:azure_german_cloud)
  def get(:blackforest), do: get(:azure_german_cloud)
  def get(:azure_germany), do: get(:azure_german_cloud)
  def get(:azure_germany_cloud), do: get(:azure_german_cloud)
  def get(:azure_german_cloud), do: azure_german_cloud()

  defp azure_cloud do
    %__MODULE__{
      name: "AzurePublicCloud",
      management_portal_url: "manage.windowsazure.com",
      publish_settings_url: "https://manage.windowsazure.compublishsettings/index",
      service_management_endpoint: "management.core.windows.net",
      resource_manager_endpoint: "management.azure.com",
      active_directory_endpoint: "login.microsoftonline.com",
      active_directory_tenant_suffix: "onmicrosoft.com",
      gallery_endpoint: "gallery.azure.com",
      keyvault_endpoint: "vault.azure.net",
      graph_endpoint: "graph.windows.net",
      storage_dns_suffix: "core.windows.net",
      sqldatabase_dns_suffix: "database.windows.net",
      trafficmanager_dns_suffix: "trafficmanager.net",
      keyvault_dns_suffix: "vault.azure.net",
      servicebus_dns_suffix: "servicebus.azure.com"
    }
  end

  defp azure_usgovernment_cloud do
    %__MODULE__{
      name: "AzureUSGovernmentCloud",
      management_portal_url: "manage.windowsazure.us",
      publish_settings_url: "https://manage.windowsazure.us/publishsettings/index",
      service_management_endpoint: "management.core.usgovcloudapi.net",
      resource_manager_endpoint: "management.usgovcloudapi.net",
      active_directory_endpoint: "login.microsoftonline.com",
      active_directory_tenant_suffix: "onmicrosoft.com",
      gallery_endpoint: "gallery.usgovcloudapi.net",
      keyvault_endpoint: "vault.usgovcloudapi.net",
      graph_endpoint: "graph.usgovcloudapi.net",
      storage_dns_suffix: "core.usgovcloudapi.net",
      sqldatabase_dns_suffix: "database.usgovcloudapi.net",
      trafficmanager_dns_suffix: "usgovtrafficmanager.net",
      keyvault_dns_suffix: "vault.usgovcloudapi.net",
      servicebus_dns_suffix: "servicebus.usgovcloudapi.net"
    }
  end

  defp azure_china_cloud do
    %__MODULE__{
      name: "AzureChinaCloud",
      management_portal_url: "manage.chinacloudapi.com",
      publish_settings_url: "https://manage.chinacloudapi.com/publishsettings/index",
      service_management_endpoint: "management.core.chinacloudapi.cn",
      resource_manager_endpoint: "management.chinacloudapi.cn",
      active_directory_endpoint: "login.chinacloudapi.cn/?api-version=1.0",
      active_directory_tenant_suffix: "onmschina.cn",
      gallery_endpoint: "gallery.chinacloudapi.cn",
      keyvault_endpoint: "vault.azure.cn",
      graph_endpoint: "graph.chinacloudapi.cn",
      storage_dns_suffix: "core.chinacloudapi.cn",
      sqldatabase_dns_suffix: "database.chinacloudapi.cn",
      trafficmanager_dns_suffix: "trafficmanager.cn",
      keyvault_dns_suffix: "vault.azure.cn",
      servicebus_dns_suffix: "servicebus.chinacloudapi.net"
    }
  end

  defp azure_german_cloud do
    %__MODULE__{
      name: "AzureGermanCloud",
      management_portal_url: "portal.microsoftazure.de",
      publish_settings_url: "https://manage.microsoftazure.de/publishsettings/index",
      service_management_endpoint: "management.core.cloudapi.de",
      resource_manager_endpoint: "management.microsoftazure.de",
      active_directory_endpoint: "login.microsoftonline.de",
      active_directory_tenant_suffix: "onmicrosoft.de",
      gallery_endpoint: "gallery.cloudapi.de",
      keyvault_endpoint: "vault.microsoftazure.de",
      graph_endpoint: "graph.cloudapi.de",
      storage_dns_suffix: "core.cloudapi.de",
      sqldatabase_dns_suffix: "database.cloudapi.de",
      trafficmanager_dns_suffix: "azuretrafficmanager.de",
      keyvault_dns_suffix: "vault.microsoftazure.de",
      servicebus_dns_suffix: "servicebus.cloudapi.de"
    }
  end
end
