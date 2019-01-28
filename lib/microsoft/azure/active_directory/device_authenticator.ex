defmodule Microsoft.Azure.ActiveDirectory.DeviceAuthenticator do
  alias Microsoft.Azure.ActiveDirectory.RestClient
  alias Microsoft.Azure.ActiveDirectory.Model.{DeviceCodeResponse, TokenResponse}

  use GenServer

  def start_azure_management(),
    do:
      %{
        tenant_id: "common",
        resource: "https://management.core.windows.net/",
        azure_environment: :azure_global
      }
      |> start()

  def start(%{tenant_id: _, resource: _, azure_environment: _} = state, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def get_state(pid), do: pid |> GenServer.call(:get_state)

  def get_device_code(pid, timeout \\ :infinity) do
    pid |> GenServer.call(:get_device_code, timeout)
  end

  def init(%{tenant_id: _, resource: _, azure_environment: _} = state) do
    new_state =
      state
      |> Map.put(:stage, :initialized)

    {:ok, new_state}
  end

  def handle_call(:get_state, _, state) do
    {:reply, {:ok, state}, state}
  end

  def handle_call(:get_device_code, _, state = %{stage: :initialized}) do
    case RestClient.get_device_code(state.tenant_id, state.resource, state.azure_environment) do
      {:ok, r = %DeviceCodeResponse{}} ->
        result = %{
          message: r.message,
          user_code: r.user_code,
          verification_url: r.verification_url
        }

        new_state =
          state
          |> Map.put(:device_code, r.device_code)
          |> Map.put(:expires_in, r.expires_in)
          |> Map.put(:interval, r.interval)
          |> Map.put(:stage, :polling)
          |> Map.put(:result, result)

        self() |> Process.send_after(:check_token, 1000 * r.interval)

        {:reply, {:ok, result}, new_state}

      {:error, body} ->
        {:reply, {:error, body}, state}
    end
  end

  def handle_call(:get_device_code, _, state = %{stage: polling_or_refreshing, result: result})
      when polling_or_refreshing == :polling or polling_or_refreshing == :refreshing do
    {:reply, {:ok, result}, state}
  end

  def handle_info(:check_token, state) do
    case RestClient.fetch_device_code_token(
           state.resource,
           state.device_code,
           state.azure_environment
         ) do
      {:ok, r = %TokenResponse{}} ->
        new_state =
          state
          |> Map.merge(r, fn _k, _v1, v2 -> v2 end)
          |> Map.put(:result, r)
          |> Map.put(:stage, :refreshing)

        self() |> Process.send_after(:refresh_token, 1000 * new_state.expires_in)
        {:noreply, new_state}

      {:error, _error_doc} ->
        self() |> Process.send_after(:check_token, 1000 * state.interval)
        {:noreply, state}
    end
  end

  def handle_info(:refresh_token, state) do
    case RestClient.refresh_token(state.resource, state.refresh_token, state.azure_environment) do
      {:ok, r = %TokenResponse{}} ->
        new_state =
          state
          |> Map.merge(r, fn _k, _v1, v2 -> v2 end)
          |> Map.put(:result, r)
          |> Map.put(:stage, :refreshing)

        refresh_time =
          cond do
            new_state.expires_in > 60 -> new_state.expires_in - 60
            true -> new_state.expires_in
          end

        self() |> Process.send_after(:refresh_token, 1000 * refresh_time)

        {:noreply, new_state}

      {:error, _error_doc} ->
        self() |> Process.send_after(:check_token, 1000 * state.interval)
        {:noreply, state}
    end
  end
end
