defmodule MicrosoftTest do
  alias Microsoft.Azure.Management.Connection, as: AzureManagementClient
  alias Microsoft.Azure.Management.Resources.Api.ResourceGroups
  alias Microsoft.Azure.Management.Compute.Api.VirtualMachineSizes

  use ExUnit.Case

  def subscription_id() do
    Application.get_env(:ex_microsoft_azure_management_samples, :subscription_id)
  end

  def token() do
    %{"accessToken" => token} =
      System.user_home!()
      |> Path.absname()
      |> Path.join(".azure")
      |> Path.join("accessTokens.json")
      |> File.read!()
      |> Poison.decode!()
      |> List.last()

    token
  end

  def connection() do
    token()
    |> AzureManagementClient.new()
  end

  test "list resource groups" do
    with conn <- connection(),
         api_version = "2018-02-01",
         {:ok, %{value: groups}} <-
           conn
           |> ResourceGroups.resource_groups_list(
             api_version,
             subscription_id()
           ),
         ids <- groups |> Enum.map(&(&1 |> Map.get(:id))) do
      ids |> Enum.join("\n") |> IO.puts()
    end
  end

  test "list VM sizes" do
    with conn <- connection(),
         api_version <- "2017-12-01",
         location <- "westeurope",
         {:ok, %{value: sizes}} <-
           conn
           |> VirtualMachineSizes.virtual_machine_sizes_list(
             location,
             api_version,
             subscription_id()
           ),
         names <- sizes |> Enum.map(&(&1 |> Map.get(:name))),
         str <- names |> Enum.join("\n") do
      str |> IO.puts()
    end
  end
end
