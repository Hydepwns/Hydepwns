defmodule HydepwnsLiveviewWeb.UserRegistrationController do
  use HydepwnsLiveviewWeb, :controller

  alias HydepwnsLiveview.Accounts

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        token = Accounts.generate_user_session_token(user)
        conn
        |> put_session(:user_token, token)
        |> put_flash(:info, "Account created and logged in successfully.")
        |> redirect(to: "/")
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Registration failed. Please check your input.")
        |> redirect(to: "/users/register")
    end
  end
end
