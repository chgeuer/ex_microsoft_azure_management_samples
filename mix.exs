defmodule ExMicrosoftAzureManagementSamples.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_microsoft_azure_management_samples,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ibrowse, "~> 4.4"},
      {:joken, "~> 1.5"},
      {:tesla, "~> 0.8"},
      {:poison, ">= 1.0.0"},
      {:uuid, "~> 1.1"},
      {:x509, "~> 0.1.1"},

      # {:ex_microsoft_azure_management, app: false, github: "chgeuer/ex_microsoft_azure_management", ref: "dae4e474fef90cd59e9cbad5c28580be8e0733a7"}
      {:ex_microsoft_azure_management_compute,
       path: "../ex_microsoft_azure_management/Microsoft.Azure.Management.Compute"},
      {:ex_microsoft_azure_management_resources,
       path: "../ex_microsoft_azure_management/Microsoft.Azure.Management.Resources"},
      {:ex_microsoft_azure_management_subscription,
       path: "../ex_microsoft_azure_management/Microsoft.Azure.Management.Subscription"},
      {:ex_microsoft_azure_management_storage,
       path: "../ex_microsoft_azure_management/Microsoft.Azure.Management.Storage"}
    ]
  end
end
