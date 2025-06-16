defmodule HydepwnsLiveview.Accounts.User do
  @moduledoc """
  Ecto schema for users.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :password_hash, :string
    field :role, :string, default: "user"
    field :active, :boolean, default: true
    field :email_confirmed_at, :naive_datetime
    field :password_reset_token, :string
    field :password_reset_sent_at, :naive_datetime
    field :confirmed_at, :naive_datetime

    timestamps()
  end

  @doc """
  Changeset for user creation/updates.
  """
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password, :role, :active])
    |> validate_required([:name, :email, :password])
    |> validate_format(:email, ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/)
    |> validate_length(:password, min: 6)
    |> validate_inclusion(:role, ["admin", "editor", "viewer"])
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  @doc """
  Changeset for user registration.
  """
  def registration_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> cast(attrs, [:password, :password_confirmation])
    |> validate_required([:password, :password_confirmation])
    |> validate_length(:password, min: 6)
    |> validate_confirmation(:password)
    |> put_password_hash()
  end

  @doc """
  Changeset for user login.
  """
  def login_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_format(:email, ~r/@/)
  end

  @doc """
  Changeset for password change.
  """
  def password_change_changeset(user, attrs) do
    user
    |> cast(attrs, [:password, :password_confirmation])
    |> validate_required([:password, :password_confirmation])
    |> validate_length(:password, min: 6)
    |> validate_confirmation(:password)
    |> put_password_hash()
  end

  @doc """
  Changeset for password reset.
  """
  def password_reset_changeset(user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> validate_format(:email, ~r/@/)
  end

  @doc """
  Changeset for password reset confirmation.
  """
  def password_reset_confirmation_changeset(user, attrs, _token) do
    user
    |> cast(attrs, [:password, :password_confirmation])
    |> validate_required([:password, :password_confirmation])
    |> validate_length(:password, min: 6)
    |> validate_confirmation(:password)
    |> put_password_hash()
  end

  @doc """
  Changeset for email confirmation.
  """
  def email_confirmation_changeset(user, attrs, _token) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_format(:email, ~r/@/)
  end

  @doc """
  Changeset for email change.
  """
  def email_change_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_format(:email, ~r/@/)
  end

  @doc """
  Changeset for security settings.
  """
  def security_changeset(user, attrs) do
    user
    |> cast(attrs, [:password, :password_confirmation])
    |> validate_required([:password, :password_confirmation])
    |> validate_length(:password, min: 6)
    |> validate_confirmation(:password)
    |> put_password_hash()
  end

  @doc """
  Changeset for user settings.
  """
  def settings_changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/@/)
  end

  @doc """
  Changeset for user profile.
  """
  def profile_changeset(user, attrs) do
    user
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  @doc """
  Changeset for user preferences.
  """
  def preferences_changeset(user, attrs) do
    user
    |> cast(attrs, [:role])
    |> validate_inclusion(:role, ["admin", "editor", "viewer"])
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Bcrypt.Base.hash_pwd_salt(password))
      _ ->
        changeset
    end
  end
end 