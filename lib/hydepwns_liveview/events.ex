defmodule HydepwnsLiveview.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias HydepwnsLiveview.Repo
  alias HydepwnsLiveview.Events.{Event, EventSettings, EventReminder}

  @doc """
  Returns the list of all events.
  """
  def list_events do
    Repo.all(Event)
  end

  @doc """
  Gets a single event.

  Raises `Ecto.NoResultsError` if the Event does not exist.
  """
  def get_event!(id), do: Repo.get!(Event, id)

  @doc """
  Creates an event.
  """
  def create_event(attrs \\ %{}) do
    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an event.
  """
  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an event.
  """
  def delete_event(%Event{} = event) do
    Repo.delete(event)
  end

  @doc """
  Returns a changeset for creating/updating an event.
  """
  def change_event(%Event{} = event, attrs \\ %{}) do
    Event.changeset(event, attrs)
  end

  @doc """
  Gets event statistics.
  """
  def get_event_statistics do
    total_events = Repo.aggregate(Event, :count)
    upcoming_events = Repo.aggregate(from(e in Event, where: e.date >= ^Date.utc_today()), :count)
    past_events = total_events - upcoming_events

    %{
      total: total_events,
      upcoming: upcoming_events,
      past: past_events
    }
  end

  @doc """
  Returns the list of past events.
  """
  def list_events_past do
    Event
    |> where([e], e.date < ^Date.utc_today())
    |> order_by([e], desc: e.date)
    |> Repo.all()
  end

  @doc """
  Returns the list of upcoming events.
  """
  def list_events_upcoming do
    Event
    |> where([e], e.date >= ^Date.utc_today())
    |> order_by([e], asc: e.date)
    |> Repo.all()
  end

  @doc """
  Returns a changeset for event notification template.
  """
  def change_event_notification_template(event \\ %Event{}, attrs \\ %{}) do
    Event.notification_template_changeset(event, attrs)
  end

  @doc """
  Returns a changeset for event settings.
  """
  def change_event_settings(settings \\ %EventSettings{}, attrs \\ %{}) do
    EventSettings.changeset(settings, attrs)
  end

  @doc """
  Gets the current event settings.
  """
  def get_event_settings do
    case Repo.get(EventSettings, 1) do
      nil -> %EventSettings{}
      settings -> settings
    end
  end

  @doc """
  Updates event settings.
  """
  def update_event_settings(%EventSettings{} = settings, attrs) do
    settings
    |> EventSettings.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns the list of available timezones.
  """
  def list_events_timezones do
    [
      "UTC",
      "America/New_York",
      "America/Chicago",
      "America/Denver",
      "America/Los_Angeles",
      "Europe/London",
      "Europe/Paris",
      "Europe/Berlin",
      "Asia/Tokyo",
      "Asia/Shanghai",
      "Australia/Sydney"
    ]
  end

  @doc """
  Returns a changeset for event reminder.
  """
  def change_event_reminder(reminder \\ %EventReminder{}, attrs \\ %{}) do
    EventReminder.changeset(reminder, attrs)
  end

  @doc """
  Creates an event reminder.
  """
  def create_event_reminder(attrs) do
    %EventReminder{}
    |> EventReminder.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a single event reminder.
  """
  def get_event_reminder!(id) do
    Repo.get!(EventReminder, id)
  end

  @doc """
  Returns the list of event reminders.
  """
  def list_events_reminders do
    Repo.all(EventReminder)
  end

  @doc """
  Deletes an event reminder.
  """
  def delete_event_reminder(%EventReminder{} = reminder) do
    Repo.delete(reminder)
  end

  @doc """
  Returns the list of events within a date range.
  """
  def list_events_by_date_range(start_date, end_date) do
    from(e in Event,
      where: e.start_time >= ^start_date and e.end_time <= ^end_date,
      order_by: [asc: e.start_time]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single event settings.

  Raises `Ecto.NoResultsError` if the EventSettings does not exist.
  """
  def get_event_settings!(id), do: Repo.get!(EventSettings, id)

  @doc """
  Gets event settings by event id.
  """
  def get_event_settings_by_event_id(event_id) do
    Repo.get_by(EventSettings, event_id: event_id)
  end

  @doc """
  Creates event settings.
  """
  def create_event_settings(attrs \\ %{}) do
    %EventSettings{}
    |> EventSettings.changeset(attrs)
    |> Repo.insert()
  end
end 