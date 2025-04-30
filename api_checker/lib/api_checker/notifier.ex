defmodule ApiChecker.Notifier do
  @moduledoc """
  Handles sending email notifications for endpoint status changes.
  """

  alias ApiChecker.Endpoints.Endpoint
  alias ApiChecker.Endpoints.CheckResult
  alias ApiChecker.Mailer
  import Swoosh.Email

  require Logger

  @doc """
  Sends an email notification if the endpoint has an email configured.
  """
  def notify(endpoint = %Endpoint{}, message) do
    # Send email notification if configured
    if endpoint.notification_email do
      send_email(endpoint, message)
    end

    :ok
  end

  @doc """
  Sends an email notification.
  """
  def send_email(%Endpoint{url: url, name: name, notification_email: email}, message) do
    Logger.info("Preparing to send email to #{email} for endpoint #{url}")

    subject = "API Endpoint Status Alert: #{name || url}"

    try do
      email_struct =
        new()
        |> to([email])
        |> from({"API Checker", "checker@example.com"}) # Configure your sender email
        |> subject(subject)
        |> text_body(message)

      Logger.info("Email prepared, attempting to deliver...")

      case Mailer.deliver(email_struct) do
        {:ok, metadata} ->
          Logger.info("Successfully sent email notification for #{url} to #{email}. Metadata: #{inspect(metadata)}")
        {:error, reason} ->
          Logger.error("Failed to send email notification for #{url} to #{email}: #{inspect(reason)}")
          Logger.error(inspect(reason))
      end
    rescue
      e ->
        Logger.error("Error while sending email: #{inspect(e)}")
        Logger.error("Stacktrace: #{inspect(__STACKTRACE__)}")
    end
  end
end
