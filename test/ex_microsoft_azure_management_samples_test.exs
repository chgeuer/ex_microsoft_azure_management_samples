defmodule ExMicrosoftAzureManagementSamplesTest do
  use ExUnit.Case

  test "list resource groups" do
    ExMicrosoftAzureManagementSamples.resource_groups_list()
    |> Enum.join("\n")
    |> IO.puts()
  end

  test "list VM sizes" do
    ExMicrosoftAzureManagementSamples.virtual_machine_sizes_list()
    |> Enum.join("\n")
    |> IO.puts()
  end
end
