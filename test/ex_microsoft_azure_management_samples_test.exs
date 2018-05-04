defmodule ExMicrosoftAzureManagementSamplesTest do
  use ExUnit.Case

  test "list resource groups" do
    val = Sample.resource_groups_list() |> Enum.join(" ")

    IO.puts("Resource groups: #{val}")
  end

  test "list VM sizes" do
    val = Sample.virtual_machine_sizes_list() |> Enum.join(" ")

    IO.puts("VM Sizes: #{val}")
  end
end
