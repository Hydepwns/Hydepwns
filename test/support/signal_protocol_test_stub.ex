defmodule SignalProtocol do
  @moduledoc """
  Test-specific SignalProtocol module that provides stub implementations
  for all signal_nif functions to eliminate undefined function warnings.
  """

  use GenServer

  # Client API

  @doc """
  Starts a new Signal Protocol session manager (stub).
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: Keyword.get(opts, :name, __MODULE__))
  end

  @doc """
  Stub for generate_identity_key_pair/0
  """
  def generate_identity_key_pair do
    {:ok, {"stub_public_key", "stub_signature"}}
  end

  @doc """
  Stub for generate_pre_key/1
  """
  def generate_pre_key(_key_id) do
    {:ok, {1, "stub_pre_key"}}
  end

  @doc """
  Stub for generate_signed_pre_key/2
  """
  def generate_signed_pre_key(_identity_key, _key_id) do
    {:ok, {1, "stub_signed_pre_key", "stub_signature"}}
  end

  @doc """
  Stub for create_session/2
  """
  def create_session(_local_identity_key, _remote_identity_key) do
    {:ok, make_ref()}
  end

  @doc """
  Stub for process_pre_key_bundle/2
  """
  def process_pre_key_bundle(_session, _bundle) do
    :ok
  end

  @doc """
  Stub for encrypt_message/2
  """
  def encrypt_message(_session, _message) do
    {:ok, "stub_encrypted_message"}
  end

  @doc """
  Stub for decrypt_message/2
  """
  def decrypt_message(_session, _ciphertext) do
    {:ok, "stub_decrypted_message"}
  end

  # Server Callbacks

  @impl true
  def init(_opts) do
    {:ok, %{}}
  end

  @impl true
  def handle_call(:generate_identity_key_pair, _from, state) do
    result = generate_identity_key_pair()
    {:reply, result, state}
  end

  @impl true
  def handle_call({:generate_pre_key, key_id}, _from, state) do
    result = generate_pre_key(key_id)
    {:reply, result, state}
  end

  @impl true
  def handle_call({:generate_signed_pre_key, identity_key, key_id}, _from, state) do
    result = generate_signed_pre_key(identity_key, key_id)
    {:reply, result, state}
  end

  @impl true
  def handle_call({:create_session, local_identity_key, remote_identity_key}, _from, state) do
    result = create_session(local_identity_key, remote_identity_key)
    {:reply, result, state}
  end

  @impl true
  def handle_call({:process_pre_key_bundle, session, bundle}, _from, state) do
    result = process_pre_key_bundle(session, bundle)
    {:reply, result, state}
  end

  @impl true
  def handle_call({:encrypt_message, session, message}, _from, state) do
    result = encrypt_message(session, message)
    {:reply, result, state}
  end

  @impl true
  def handle_call({:decrypt_message, session, ciphertext}, _from, state) do
    result = decrypt_message(session, ciphertext)
    {:reply, result, state}
  end
end 