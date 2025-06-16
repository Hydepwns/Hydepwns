defmodule HydepwnsLiveview.SignalProtocol do
  @moduledoc """
  Wrapper module for the Signal Protocol NIF functions.
  """

  @on_load :init

  def init do
    :ok = :libsignal_protocol_nif.init()
  end

  @doc """
  Generates a new identity key pair.
  """
  def generate_identity_key_pair do
    :libsignal_protocol_nif.generate_identity_key_pair()
  end

  @doc """
  Generates a new pre-key.
  """
  def generate_pre_key(identity_key) do
    :libsignal_protocol_nif.generate_pre_key(identity_key)
  end

  @doc """
  Generates a new signed pre-key.
  """
  def generate_signed_pre_key(identity_key, timestamp) do
    :libsignal_protocol_nif.generate_signed_pre_key(identity_key, timestamp)
  end

  @doc """
  Creates a new session.
  """
  def create_session(identity_key, pre_key_bundle) do
    :libsignal_protocol_nif.create_session(identity_key, pre_key_bundle)
  end

  @doc """
  Processes a pre-key bundle.
  """
  def process_pre_key_bundle(identity_key, pre_key_bundle) do
    :libsignal_protocol_nif.process_pre_key_bundle(identity_key, pre_key_bundle)
  end

  @doc """
  Encrypts a message.
  """
  def encrypt_message(session, message) do
    :libsignal_protocol_nif.encrypt_message(session, message)
  end

  @doc """
  Decrypts a message.
  """
  def decrypt_message(session, encrypted_message) do
    :libsignal_protocol_nif.decrypt_message(session, encrypted_message)
  end

  @doc """
  Gets cache statistics.
  """
  def get_cache_stats(session) do
    :libsignal_protocol_nif.get_cache_stats(session)
  end

  @doc """
  Resets cache statistics.
  """
  def reset_cache_stats(session) do
    :libsignal_protocol_nif.reset_cache_stats(session)
  end

  @doc """
  Sets cache size.
  """
  def set_cache_size(session, chain_key_size, root_key_size) do
    :libsignal_protocol_nif.set_cache_size(session, chain_key_size, root_key_size)
  end
end 