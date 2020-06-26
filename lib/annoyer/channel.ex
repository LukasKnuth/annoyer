defmodule Annoyer.Channel do
  @doc "Imports any necessary modules for simple usage."
  defmacro __using__(_opts) do
    quote do
      import Annoyer.{Channel, Annoyence, Transform, Outgoing, Incoming}
      require Logger

      # Save transforms and outgoings in module attributes
      @topics []
      @configs []
      @outgoings []
      @transforms []

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

  defmacro transform(implementation, parameters \\ []) do
    quote location: :keep do
      unquoted_impl = unquote(implementation)

      with {:error, reason} <- Code.ensure_compiled(unquoted_impl) do
        raise "The specified transform module #{unquoted_impl} couldn't be loaded: #{reason}"
      end

      unless function_exported?(unquote(implementation), :transform, 2) do
        raise "The specified transform module #{unquoted_impl} does not have the required transform/2 function!"
      end

      # Prepend this transform (Note: No = sign!)
      # This is reversed below, since prepend is O(1) while append is O(n)
      @transforms [{unquoted_impl, unquote(parameters)} | @transforms]
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

  # After behaviour, this finally creates the execute()-method to run everything
  @doc false
  defmacro __before_compile__(_env) do
    quote location: :keep do
      @transforms_reversed Enum.reverse(@transforms)

      def __subscribed_topics__ do
        @topics
      end

      def __configure_channel__ do
        Enum.each(@configs, fn {incoming, params} -> incoming.configure(params) end)
      end

      def __process_channel__(annoyence) do
        # Execute all transforms
        transformed =
          Enum.reduce_while(@transforms_reversed, [annoyence], fn {transform, params}, acc ->
            transformed = Enum.reduce(acc, [], fn e, acc ->
              case transform.transform(params, e) do
                {:ok, result} when is_list(result) -> result ++ acc
                {:ok, result} -> [result | acc]
                :drop ->
                  Logger.info("#{transform} dropped annoyence on \"#{e.topic}\" topic")
                  acc
              end
            end)
            if Enum.empty?(transformed), do: {:halt, []}, else: {:cont, transformed}
          end)

        # Execute all outgoings if annoyence wasn't dropped
        Enum.each(@outgoings, fn {out, params} -> Enum.each(transformed, &out.output(params, &1)) end)
      end
    end
  end
end
