defmodule Microsoft.Azure.ActiveDirectory.Model.DeviceCodeResponse do
  defstruct [
    :user_code,
    :device_code,
    :verification_url,
    :expires_in,
    :interval,
    :message
  ]

  def new(json) do
    json
    |> Poison.decode!(as: %__MODULE__{})
    |> Map.update!(:expires_in, &String.to_integer/1)
    |> Map.update!(:interval, &String.to_integer/1)
  end
end
