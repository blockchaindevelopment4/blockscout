defmodule Explorer.Chain.Hash.Inscription do
  @moduledoc """
  The inscription hash can have a variable byte count, unlike addresses which are fixed at 20 bytes.
  It can also be null.
  """

  alias Explorer.Chain.Hash

  use Ecto.Type
  @behaviour Hash

  @impl Hash
  def byte_count(data \\ nil) do
    case data do
      nil ->
        # Default byte count if no data is provided
        32

      "0x" <> hex_string ->
        # Calculate byte count based on the length of the hexadecimal string
        String.length(hex_string) |> div(2)

      binary when is_binary(binary) ->
        # Calculate byte count based on the length of the binary
        byte_size(binary)

      _ ->
        # Fallback to a default value
        32
    end
  end

  @typedoc """
  A variable-length hash for inscriptions, which can also be null.
  """
  @type t :: %Hash{byte_count: non_neg_integer(), bytes: binary()} | nil

  @doc """
  Casts `term` to `t:t/0`.

  If the `term` is already in `t:t/0`, then it is returned.

      iex> Explorer.Chain.Hash.Inscription.cast(
      ...>   %Explorer.Chain.Hash{
      ...>     byte_count: 32,
      ...>     bytes: <<0x9fc76417374aa880d4449a1f7f31ec597f00b1f6f3dd2d66f4c9c6c445836d8b :: big-integer-size(32)-unit(8)>>
      ...>   }
      ...> )
      {
        :ok,
        %Explorer.Chain.Hash{
          byte_count: 32,
          bytes: <<0x9fc76417374aa880d4449a1f7f31ec597f00b1f6f3dd2d66f4c9c6c445836d8b :: big-integer-size(32)-unit(8)>>
        }
      }

  If the `term` is `nil`, it is returned as `nil`.

      iex> Explorer.Chain.Hash.Inscription.cast(nil)
      {:ok, nil}

  If the `term` is a `String.t` that starts with `0x`, it is converted to binary.

      iex> Explorer.Chain.Hash.Inscription.cast("0x9fc76417374aa880d4449a1f7f31ec597f00b1f6f3dd2d66f4c9c6c445836d8b")
      {
        :ok,
        %Explorer.Chain.Hash{
          byte_count: 32,
          bytes: <<0x9fc76417374aa880d4449a1f7f31ec597f00b1f6f3dd2d66f4c9c6c445836d8b :: big-integer-size(32)-unit(8)>>
        }
      }

  If the `term` is invalid, `:error` is returned.

      iex> Explorer.Chain.Hash.Inscription.cast("0xinvalid")
      :error
  """
  @impl Ecto.Type
  @spec cast(term()) :: {:ok, t()} | :error
  def cast(term) do
    case term do
      nil ->
        {:ok, nil}

      %Hash{byte_count: byte_count, bytes: bytes} when is_binary(bytes) and byte_size(bytes) == byte_count ->
        {:ok, %Hash{byte_count: byte_count, bytes: bytes}}

      "0x" <> hex_string ->
        case Base.decode16(hex_string, case: :mixed) do
          {:ok, binary} ->
            byte_count = byte_size(binary)
            {:ok, %Hash{byte_count: byte_count, bytes: binary}}

          :error ->
            :error
        end

      _ ->
        :error
    end
  end

  @doc """
  Dumps the binary hash to `:binary` (`bytea`) format used in the database.

  If the field from the struct is `t:t/0`, then it succeeds.

      iex> Explorer.Chain.Hash.Inscription.dump(
      ...>   %Explorer.Chain.Hash{
      ...>     byte_count: 32,
      ...>     bytes: <<0x9fc76417374aa880d4449a1f7f31ec597f00b1f6f3dd2d66f4c9c6c445836d8b :: big-integer-size(32)-unit(8)>>
      ...>   }
      ...> )
      {:ok, <<0x9fc76417374aa880d4449a1f7f31ec597f00b1f6f3dd2d66f4c9c6c445836d8b :: big-integer-size(32)-unit(8)>>}

  If the field from the struct is `nil`, it is returned as `nil`.

      iex> Explorer.Chain.Hash.Inscription.dump(nil)
      {:ok, nil}

  If the field from the struct is an incorrect format, `:error` is returned.

      iex> Explorer.Chain.Hash.Inscription.dump("invalid")
      :error
  """
  @impl Ecto.Type
  @spec dump(term()) :: {:ok, binary() | nil} | :error
  def dump(term) do
    case term do
      nil ->
        {:ok, nil}

      %Hash{bytes: bytes} when is_binary(bytes) ->
        {:ok, bytes}

      _ ->
        :error
    end
  end

  @doc """
  Loads the binary hash from the database.

  If the binary hash is valid, it is returned as `t:t/0`.

      iex> Explorer.Chain.Hash.Inscription.load(
      ...>   <<0x9fc76417374aa880d4449a1f7f31ec597f00b1f6f3dd2d66f4c9c6c445836d8b :: big-integer-size(32)-unit(8)>>
      ...> )
      {
        :ok,
        %Explorer.Chain.Hash{
          byte_count: 32,
          bytes: <<0x9fc76417374aa880d4449a1f7f31ec597f00b1f6f3dd2d66f4c9c6c445836d8b :: big-integer-size(32)-unit(8)>>
        }
      }

  If the binary hash is `nil`, it is returned as `nil`.

      iex> Explorer.Chain.Hash.Inscription.load(nil)
      {:ok, nil}

  If the binary hash is invalid, `:error` is returned.

      iex> Explorer.Chain.Hash.Inscription.load("invalid")
      :error
  """
  @impl Ecto.Type
  @spec load(term()) :: {:ok, t()} | :error
  def load(term) do
    case term do
      nil ->
        {:ok, nil}

      bytes when is_binary(bytes) ->
        byte_count = byte_size(bytes)
        {:ok, %Hash{byte_count: byte_count, bytes: bytes}}

      _ ->
        :error
    end
  end

  @doc """
  The underlying database type: `binary`. `binary` is used because the byte count is variable.
  """
  @impl Ecto.Type
  @spec type() :: :binary
  def type, do: :binary

  @doc """
  Validates a hexadecimal encoded string to see if it conforms to an inscription hash.

  ## Error Descriptions

  * `:invalid_characters` - String used non-hexadecimal characters
  * `:invalid_length` - String length is not even (hexadecimal pairs)

  ## Example

      iex> Explorer.Chain.Hash.Inscription.validate("0x9fc76417374aa880d4449a1f7f31ec597f00b1f6f3dd2d66f4c9c6c445836d8b")
      {:ok, "0x9fc76417374aa880d4449a1f7f31ec597f00b1f6f3dd2d66f4c9c6c445836d8b"}

      iex> Explorer.Chain.Hash.Inscription.validate("0xinvalid")
      {:error, :invalid_characters}

      iex> Explorer.Chain.Hash.Inscription.validate(nil)
      {:ok, nil}
  """
  @spec validate(String.t() | nil) :: {:ok, String.t() | nil} | {:error, :invalid_length | :invalid_characters}
  def validate("0x" <> hash) do
    with {:length, true} <- {:length, rem(String.length(hash), 2) == 0},
         {:hex, true} <- {:hex, hex?(hash)} do
      {:ok, "0x" <> hash}
    else
      {:length, false} ->
        {:error, :invalid_length}

      {:hex, false} ->
        {:error, :invalid_characters}
    end
  end

  def validate(nil), do: {:ok, nil}

  @spec hex?(String.t()) :: boolean()
  defp hex?(hash) do
    case Regex.run(~r/^[0-9a-fA-F]*$/, hash) do
      nil -> false
      [_] -> true
    end
  end
end
