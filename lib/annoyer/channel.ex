defmodule Annoyer.Channel do
  @doc "Imports any necessary modules for simple usage."
  defmacro __using__(_opts) do
    quote do
      import Annoyer.{Channel, Annoyence, Filter, Outgoing}

      # Save filters and outgoings in module attributes
      @topics []
      @filters []
      @outgoings []

      # Generate the final "__process_channel__"-method
      @before_compile Annoyer.Channel
    end
  end

  defmacro topic(name) do
    quote location: :keep do
      @topics [unquote(name) | @topics]
    end
  end

  defmacro filter(implementation, parameters \\ []) do
    quote location: :keep do
      unless Code.ensure_loaded?(unquote(implementation)) do
        raise "The specified filter module couldn't be loaded"
      end

      unless function_exported?(unquote(implementation), :filter, 2) do
        raise "The specified filter module does not have the required filter/2 function!"
      end

      # Prepend this filter (Note: No = sign!)
      # This is reversed below, since prepend is O(1) while append is O(n)
      @filters [{unquote(implementation), unquote(parameters)} | @filters]
    end
  end

  defmacro outgoing(implementation, parameters \\ []) do
    quote location: :keep do
      unless Code.ensure_loaded?(unquote(implementation)) do
        raise "The specified outgoing module couldn't be loaded"
      end

      unless function_exported?(unquote(implementation), :output, 2) do
        raise "The specified outgoing module does not have the required output/2 function!"
      end

      @outgoings [{unquote(implementation), unquote(parameters)} | @outgoings]
    end
  end

  # After defining all filters and outgoings, this finally creates the execute()-method to run everything
  @doc false
  defmacro __before_compile__(_env) do
    quote location: :keep do
      @filters_reversed Enum.reverse(@filters)

      def __subscribed_topics__ do
        @topics
      end

      def __process_channel__(annoyence) do
        # Execute all filters
        filtered =
          Enum.reduce(@filters_reversed, annoyence, fn {filter, params}, acc ->
            filter.filter(params, acc)
          end)

        # Execute all outgoings
        Enum.each(@outgoings, fn {out, params} -> out.output(params, filtered) end)
      end
    end
  end
end
