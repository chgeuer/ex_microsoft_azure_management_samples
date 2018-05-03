defmodule ExMicrosoftAzureManagementSamplesTest do
  use ExUnit.Case

  test "list resource groups" do
    ExMicrosoftAzureManagementSamples.list_resource_groups()
    |> Enum.join("\n")
    |> IO.puts()
  end

  test "list VM sizes" do
    ExMicrosoftAzureManagementSamples.list_vm_sizes()
    |> Enum.join("\n")
    |> IO.puts()
  end
end
