defmodule Annoyer.Channel do
  @doc "Imports any necessary modules for simple usage."
  defmacro __using__(_opts) do
    quote do
      import Annoyer.{Channel, Annoyence, Filter, Outgoing, Incoming}
      require Logger

      # Save filters and outgoings in module attributes
      @topics []
      @filters []
      @configs []
      @outgoings []

      # Generate the final "__process_channel__"-method
      @before_compile Annoyer.Channel
    end
  end

  defmacro configure(implementation, parameters \\ []) do
    quote location: :keep do
      unquoted_impl = unquote(implementation)
      with {:error, reason} <- Code.ensure_compiled(unquoted_impl) do
        raise "The specified incoming module #{unquoted_impl} couldn't be loaded: #{reason}"
      end

      unless function_exported?(unquoted_impl, :configure, 1) do
        raise "The specified incoming module #{unquoted_impl} does not have the required configure/1 function!"
      end

      @configs [{unquoted_impl, unquote(parameters)} | @configs]
    end
  end

  defmacro topic(name) do
    quote location: :keep do
      @topics [unquote(name) | @topics]
    end
  end

  defmacro filter(implementation, parameters \\ []) do
    quote location: :keep do
      unquoted_impl = unquote(implementation)
      with {:error, reason} <- Code.ensure_compiled(unquoted_impl) do
        raise "The specified filter module #{unquoted_impl} couldn't be loaded: #{reason}"
      end

      unless function_exported?(unquote(implementation), :filter, 2) do
        raise "The specified filter module #{unquoted_impl} does not have the required filter/2 function!"
      end

      # Prepend this filter (Note: No = sign!)
      # This is reversed below, since prepend is O(1) while append is O(n)
      @filters [{unquoted_impl, unquote(parameters)} | @filters]
    end
  end

  defmacro outgoing(implementation, parameters \\ []) do
    quote location: :keep do
      unquoted_impl = unquote(implementation)
      with {:error, reason} <- Code.ensure_compiled(unquoted_impl) do
        raise "The specified outgoing module #{unquoted_impl} couldn't be loaded: #{reason}"
      end

      unless function_exported?(unquote(implementation), :output, 2) do
        raise "The specified outgoing module #{unquoted_impl} does not have the required output/2 function!"
      end

      @outgoings [{unquoted_impl, unquote(parameters)} | @outgoings]
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

      def __configure_channel__ do
        Enum.each(@configs, fn {incoming, params} -> incoming.configure(params) end)
      end

      def __process_channel__(annoyence) do
        # Execute all filters
        filtered =
          Enum.reduce_while(@filters_reversed, annoyence, fn {filter, params}, acc ->
            case filter.filter(params, acc) do
              {:ok, result} -> {:cont, result}
              :drop -> 
                Logger.info("#{filter} dropped annoyence on \"#{annoyence.topic}\" topic")
                {:halt, nil}
            end
          end)

        # Execute all outgoings if annoyence wasn't dropped
        unless is_nil(filtered) do
          Enum.each(@outgoings, fn {out, params} -> out.output(params, filtered) end)
        end
      end
    end
  end
end
