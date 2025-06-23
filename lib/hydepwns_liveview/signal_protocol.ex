unless Mix.env() == :test do
  defmodule HydepwnsLiveview.SignalProtocol do
    @moduledoc """
    Wrapper module for the Signal Protocol NIF functions.
    """

    # Temporarily disabled NIF loading to resolve compilation issues
    # @on_load :init

    # def init do
    #   :libsignal_protocol_nif.init()
    # end

    # Placeholder functions that return error when NIF is not available
    @doc """
    Generates a new identity key pair.
    """
    def generate_identity_key_pair do
      {:error, :nif_not_available}
    end

    @doc """
    Generates a new pre-key.
    """
    def generate_pre_key(_identity_key) do
      {:error, :nif_not_available}
    end

    @doc """
    Generates a new signed pre-key.
    """
    def generate_signed_pre_key(_identity_key, _timestamp) do
      {:error, :nif_not_available}
    end

    @doc """
    Creates a new session.
    """
    def create_session(_identity_key) do
      {:error, :nif_not_available}
    end

    @doc """
    Processes a pre-key bundle.
    """
    def process_pre_key_bundle(_identity_key, _pre_key_bundle) do
      {:error, :nif_not_available}
    end

    @doc """
    Encrypts a message.
    """
    def encrypt_message(_, _) do
      {:error, :nif_not_available}
    end

    @doc """
    Decrypts a message.
    """
    def decrypt_message(_, _) do
      {:error, :nif_not_available}
    end

    @doc """
    Gets cache statistics.
    """
    def get_cache_stats(_session) do
      {:error, :nif_not_available}
    end

    @doc """
    Resets cache statistics.
    """
    def reset_cache_stats(_session) do
      {:error, :nif_not_available}
    end

    @doc """
    Sets cache size.
    """
    def set_cache_size(_session, _chain_key_size, _root_key_size) do
      {:error, :nif_not_available}
    end
  end
end
