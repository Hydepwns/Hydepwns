defmodule HydepwnsLiveviewWeb.HealthController do
  @moduledoc """
  Health check controller for monitoring application status.
  Used by CI/CD pipeline and monitoring systems.
  """

  use HydepwnsLiveviewWeb, :controller

  alias HydepwnsLiveview.Repo

  @doc """
  Basic health check endpoint.
  Returns 200 OK if the application is running.
  """
  def index(conn, _params) do
    conn
    |> put_resp_content_type("application/json")
    |> json(%{
      status: "healthy",
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      version: (Application.spec(:hydepwns_liveview, :vsn) || "unknown") |> to_string()
    })
  end

  @doc """
  Comprehensive health check including database connectivity.
  Returns detailed status information.
  """
  def detailed(conn, _params) do
    health_status = %{
      status: "healthy",
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      version: (Application.spec(:hydepwns_liveview, :vsn) || "unknown") |> to_string(),
      checks: %{
        database: check_database(),
        memory: check_memory(),
        disk: check_disk()
      }
    }

    # Determine overall status
    overall_status =
      if Enum.all?(Map.values(health_status.checks), fn check -> check.status == "ok" end) do
        "healthy"
      else
        "degraded"
      end

    status_code = if overall_status == "healthy", do: 200, else: 503

    conn
    |> put_status(status_code)
    |> put_resp_content_type("application/json")
    |> json(%{health_status | status: overall_status})
  end

  # Database connectivity check.
  defp check_database do
    case Repo.query("SELECT 1") do
      {:ok, _result} -> %{status: "ok", message: "connected"}
      {:error, error} -> %{status: "error", message: "disconnected: #{inspect(error)}"}
    end
  end

  defp check_memory do
    case :erlang.memory() do
      memory when is_list(memory) ->
        total = :erlang.memory(:total)
        process = :erlang.memory(:processes)
        usage_percent = process / total * 100

        if usage_percent < 90 do
          %{status: "ok", usage: "#{Float.round(usage_percent, 2)}%"}
        else
          %{status: "warning", usage: "#{Float.round(usage_percent, 2)}% (high)"}
        end

      _ ->
        %{status: "error", message: "unable to check memory"}
    end
  end

  defp check_disk do
    case File.stat(".") do
      {:ok, _stat} -> %{status: "ok", message: "accessible"}
      {:error, error} -> %{status: "error", message: "inaccessible: #{inspect(error)}"}
    end
  end

  @doc """
  Readiness check for Kubernetes.
  """
  def ready(conn, _params) do
    # Check if application is ready to receive traffic
    ready_status = %{
      ready: true,
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    }

    conn
    |> put_resp_content_type("application/json")
    |> json(ready_status)
  end

  @doc """
  Liveness check for Kubernetes.
  """
  def live(conn, _params) do
    # Check if application is alive and running
    live_status = %{
      alive: true,
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    }

    conn
    |> put_resp_content_type("application/json")
    |> json(live_status)
  end
end
