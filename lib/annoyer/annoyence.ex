defmodule Annoyer.Annoyence do
  @type t :: %__MODULE__{
          topic: String.t(),
          content: String.t()
        }

  @enforce_keys [:topic, :content]
  defstruct [:topic, :content]
end
