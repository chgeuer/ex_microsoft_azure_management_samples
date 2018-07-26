defmodule Microsoft.Azure.ActiveDirectory.Model.TokenResponse do
  defstruct [
    :access_token,
    :refresh_token,
    :id_token,
    :expires_in,
    :expires_on,
    :ext_expires_in,
    :not_before,
    :resource,
    :token_type,
    :scope
  ]

  def new(json) do
    json
    |> Poison.decode!(as: %__MODULE__{})
    |> Map.update!(:not_before, &(&1 |> String.to_integer() |> DateTime.from_unix!()))
    |> Map.update!(:expires_on, &(&1 |> String.to_integer() |> DateTime.from_unix!()))
    |> Map.update!(:expires_in, &String.to_integer/1)
    |> Map.update!(:ext_expires_in, &String.to_integer/1)
  end
end
