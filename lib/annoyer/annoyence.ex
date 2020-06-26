defmodule Annoyer.Annoyence do
  @type t :: %__MODULE__{
          topic: String.t(),
          content: String.t(),
          meta: %{required(atom()) => any()},
          attachments: %{required(String.t()) => any()}
        }

  @enforce_keys [:topic, :content]
  @key_default %{}
  defstruct [:topic, :content, meta: @key_default, attachments: @key_default]

  @behaviour Access

  @impl Access
  def fetch(struct, key), do: Map.fetch(struct, key)

  def get(struct, key, default \\ nil) do
    case struct do
      %{^key => value} -> value
      _ -> default
    end
  end

  def put(struct, key, val) do
    if Map.has_key?(struct, key) do
      Map.put(struct, key, val)
    else
      struct
    end
  end

  def delete(struct, key) do
    if Enum.any?(@enforce_keys, key) do
      # There are no defaults for enforced keys, return original struct
      struct
    else
      put(struct, key, @key_default)
    end
  end

  @impl Access
  def get_and_update(struct, key, fun) when is_function(fun, 1) do
    current = get(struct, key)

    case fun.(current) do
      {get, update} ->
        {get, put(struct, key, update)}

      :pop ->
        {current, delete(struct, key)}

      other ->
        raise "the given function must return a two-element tuple or :pop, got: #{inspect(other)}"
    end
  end

  @impl Access
  def pop(struct, key, default \\ nil) do
    val = get(struct, key, default)
    updated = delete(struct, key)
    {val, updated}
  end

  defoverridable [fetch: 2, get: 3, put: 3, delete: 2,
    get_and_update: 3, pop: 3]
end
