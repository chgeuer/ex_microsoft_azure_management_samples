defmodule Microsoft.Azure.ActiveDirectory.TokenStoreAgent do
  use Agent

  defstruct [
    :code,
    :access_token,
    :refresh_token
  ]

  def start_link() do
    Agent.start_link(fn -> %__MODULE__{} end)
  end

  def set_code(pid, code), do: pid |> set(:code, code)
  def set_access_token(pid, access_token), do: pid |> set(:access_token, access_token)

  def get_code(pid), do: pid |> get(:code)
  def get_access_token(pid), do: pid |> get(:access_token)

  defp get(pid, key) when is_atom(key) do
    pid
    |> Agent.get(fn state -> state |> Map.get(key) end)
  end

  defp set(pid, key, val) when is_atom(key) do
    pid
    |> Agent.update(fn state ->
      state |> Map.update!(key, fn _ -> val end)
    end)
  end
end
