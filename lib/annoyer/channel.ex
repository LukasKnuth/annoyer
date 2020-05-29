defmodule Annoyer.Channel do

  @doc "Imports any necessary modules for simple usage."
  defmacro __using__(_opts) do
    quote do
      import Annoyer.Channel

      # Save filters and outgoings in module attributes
      @filters []
      @outgoings []

      # Generate the final "__process_channel__"-method
      @before_compile Annoyer.Channel

      # Todo code-style: Create behaviour for Outgoing and Filter! says "Filter accepts map of arguemnts"
    end
  end

  defmacro filter(implementation, parameters \\ []) do
    quote location: :keep do
      case Code.ensure_loaded(unquote(implementation)) do
        {:error, reason} -> raise "The specified module couldn't be loaded: #{reason}"
        _ -> :ok # Wonderful.
      end
      unless function_exported?(unquote(implementation), :filter, 2) do
         raise "The specified module does not have the required filter/2 function!"
      end

      # Prepend this filter (Note: No = sign!)
      # This is reversed below, since prepend is O(1) while append is O(n)
      @filters [{unquote(implementation), unquote(parameters)} | @filters]
    end
  end

  defmacro outgoing(implementation, parameters \\ []) do
    quote location: :keep do
      case Code.ensure_loaded(unquote(implementation)) do
        {:error, reason} -> raise "The specified module couldn't be loaded: #{reason}"
        _ -> :ok # Wonderful.
      end
      unless function_exported?(unquote(implementation), :output, 2) do
        raise "The specified module does not have the required output/2 function!"
      end

      @outgoings [{unquote(implementation), unquote(parameters)} | @outgoings]
    end
  end

  # After defining all filters and outgoings, this finally creates the execute()-method to run everything
  @doc false
  defmacro __before_compile__(_env) do
    quote location: :keep do
      @filters_reversed Enum.reverse(@filters)

      def __process_channel__(annoyence) do
        # Execute all filters
        filtered = Enum.reduce(@filters_reversed, annoyence, fn {filter, params}, acc -> filter.filter(params, acc) end)
        # Execute all outgoings
        Enum.each(@outgoings, fn {out, params} -> out.output(params, filtered) end)
      end
    end
  end

end