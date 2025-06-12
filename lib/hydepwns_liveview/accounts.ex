defmodule HydepwnsLiveview.Accounts do
  @moduledoc """
  The Accounts context.
  """

  alias HydepwnsLiveview.Repo
  alias HydepwnsLiveview.Accounts.User

  @doc """
  Creates a user.
  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Registers a user.
  """
  def register_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Logs in a user.
  """
  def login_user(attrs \\ %{}) do
    %User{}
    |> User.login_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Changes a user's password.
  """
  def change_password(user, attrs) do
    user
    |> User.password_change_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Requests a password reset.
  """
  def request_password_reset(attrs) do
    %User{}
    |> User.password_reset_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Resets a user's password.
  """
  def reset_password(attrs) do
    %User{}
    |> User.password_reset_confirmation_changeset(attrs, nil)
    |> Repo.insert()
  end

  @doc """
  Confirms a user's email.
  """
  def confirm_email(attrs) do
    %User{}
    |> User.email_confirmation_changeset(attrs, nil)
    |> Repo.insert()
  end

  @doc """
  Changes a user's email.
  """
  def change_email(user, attrs) do
    user
    |> User.email_change_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a user's security settings.
  """
  def update_security(user, attrs) do
    user
    |> User.security_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a user's settings.
  """
  def update_user_settings(user, attrs) do
    user
    |> User.settings_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a user's profile.
  """
  def update_profile(user, attrs) do
    user
    |> User.profile_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a user's preferences.
  """
  def update_preferences(user, attrs) do
    user
    |> User.preferences_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Gets a user by id.
  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a user by email.
  """
  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Lists all users.
  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Returns a changeset for changing the user's password.
  """
  def change_user_password(user, attrs \\ %{}) do
    User.password_change_changeset(user, attrs)
  end

  @doc """
  Resets the user's password.
  """
  def reset_user_password(user, attrs) do
    user
    |> User.password_reset_confirmation_changeset(attrs, nil)
    |> Repo.update()
  end

  @doc """
  Confirms the user's email.
  """
  def confirm_user_email(user, attrs) do
    user
    |> User.email_confirmation_changeset(attrs, nil)
    |> Repo.update()
  end

  @doc """
  Returns a changeset for creating/updating a user.
  """
  def change_user(user \\ %User{}, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
  Updates a user.
  """
  def update_user(user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.
  """
  def delete_user(user) do
    Repo.delete(user)
  end

  @doc """
  Updates user preferences.
  """
  def update_user_preferences(user, attrs) do
    update_preferences(user, attrs)
  end

  @doc """
  Updates user security settings.
  """
  def update_user_security(user, attrs) do
    update_security(user, attrs)
  end
end 