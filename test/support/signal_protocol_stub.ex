defmodule HydepwnsLiveview.SignalProtocolStub do
  @moduledoc """
  Stub implementation of SignalProtocol for testing.

  This module provides stub implementations that redirect signal_nif calls
  to the SignalNifStub module to eliminate undefined function warnings.
  """

  # Alias the stub module
  alias SignalNifStub, as: SignalNif

  @doc """
  Stub for generate_identity_key_pair/0
  """
  def generate_identity_key_pair do
    case SignalNif.generate_identity_key_pair() do
      {:ok, keys} -> {:ok, keys}
      error -> error
    end
  end

  @doc """
  Stub for generate_pre_key/1
  """
  def generate_pre_key(key_id) do
    case SignalNif.generate_pre_key(key_id) do
      {:ok, pre_key} -> {:ok, pre_key}
      error -> error
    end
  end

  @doc """
  Stub for generate_signed_pre_key/2
  """
  def generate_signed_pre_key(identity_key, key_id) do
    case SignalNif.generate_signed_pre_key(identity_key, key_id) do
      {:ok, signed_pre_key} -> {:ok, signed_pre_key}
      error -> error
    end
  end

  @doc """
  Stub for create_session/2
  """
  def create_session(local_identity_key, remote_identity_key) do
    case SignalNif.create_session(local_identity_key, remote_identity_key) do
      {:ok, session} -> {:ok, session}
      error -> error
    end
  end

  @doc """
  Stub for process_pre_key_bundle/2
  """
  def process_pre_key_bundle(session, bundle) do
    case SignalNif.process_pre_key_bundle(session, bundle) do
      {:ok, updated_session} -> {:ok, updated_session}
      error -> error
    end
  end

  @doc """
  Stub for encrypt_message/2
  """
  def encrypt_message(session, message) do
    case SignalNif.encrypt_message(session, message) do
      {:ok, ciphertext} -> {:ok, ciphertext}
      error -> error
    end
  end

  @doc """
  Stub for decrypt_message/2
  """
  def decrypt_message(session, ciphertext) do
    case SignalNif.decrypt_message(session, ciphertext) do
      {:ok, message} -> {:ok, message}
      error -> error
    end
  end
end
