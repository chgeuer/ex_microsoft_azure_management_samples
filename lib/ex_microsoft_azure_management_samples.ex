defmodule ExMicrosoftAzureManagementSamples do
  @moduledoc """
  Documentation for ExMicrosoftAzureManagementSamples.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ExMicrosoftAzureManagementSamples.hello
      :world

  """
  def hello do
    :world
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
      |> IO.inspect()
      |> File.read!()
      |> Poison.decode!()
      |> Enum.filter(&( &1["_authority"] == "https://login.microsoftonline.com/" <>  tenant_id()))
      |> List.last()

    token
  end
end
