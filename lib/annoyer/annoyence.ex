defmodule Annoyer.Annoyence do
  @type t :: %__MODULE__{
          topic: String.t(),
          content: String.t(),
          meta: %{required(atom()) => any()},
          attachments: %{required(String.t()) => any()}
        }

  @enforce_keys [:topic, :content]
  defstruct [:topic, :content, meta: {}, attachments: %{}]
end
