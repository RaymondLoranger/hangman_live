defmodule Hangman.LiveWeb.HangmanComponents do
  use Hangman.LiveWeb, [:html, :aliases]

  attr :header, :string, required: true
  slot :inner_block, required: true

  @spec game_field(Socket.assigns()) :: Rendered.t()
  def game_field(assigns) do
    ~H"""
    <.header inner_class="mb-6 md:mb-12 md:ml-24 text-center text-cool-gray-900 font-extrabold text-4xl">
      <%= @header %>
    </.header>

    <div id="game-field" class="text-center">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :keyup, :string, required: true
  slot :inner_block, required: true

  def grid(assigns) do
    ~H"""
    <div
      id="grid"
      phx-window-keyup={@keyup}
      class="mb-4 grid grid-flow-row-dense grid-cols-1 gap-x-14 gap-y-5 md:grid-cols-2 md:gap-y-3"
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :update, :string, required: true
  slot :inner_block, required: true

  def word_letters(assigns) do
    ~H"""
    <p
      id="word-letters"
      phx-update={@update}
      class="font-mono mb-4 h-auto text-3xl tracking-wide md:col-span-1 md:col-start-2"
    >
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  attr :id, :string, required: true
  attr :letter, :string, required: true, doc: "can be a single letter list too"

  def word_letter(%{letter: letter} = assigns) do
    assigns =
      assign(
        assigns,
        :variant,
        case letter do
          "_" -> "hide"
          <<byte>> when byte in ?a..?z -> "show"
          _single_letter_list -> "unveil"
        end
      )

    ~H"""
    <span
      id={@id}
      hide={@variant == "hide"}
      show={@variant == "show"}
      unveil={@variant == "unveil"}
      class="hide:text-gray-900 show:text-blue-500 unveil:opacity-30"
    >
      <%= @letter %>
    </span>
    """
  end

  attr :update, :string, required: true
  slot :inner_block, required: true

  def guess_letters(assigns) do
    ~H"""
    <div
      id="guess-letters"
      phx-update={@update}
      class={[
        "grid-cols-auto-fit grid items-center justify-items-center",
        "gap-x-1 gap-y-3",
        "md:col-span-1 md:col-start-2 md:gap-x-2 md:gap-y-4"
      ]}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :id, :string, required: true
  attr :click, :string, required: true
  attr :letter, :string, required: true
  attr :disabled, :boolean, required: true
  attr :good_guess, :boolean, required: true
  attr :bad_guess, :boolean, required: true

  def guess_letter(assigns) do
    ~H"""
    <button
      id={@id}
      phx-click={@click}
      phx-value-guess={@letter}
      disabled={@disabled}
      good-guess={@good_guess}
      bad-guess={@bad_guess}
      class={[
        "h-10 w-10 rounded-full pb-1 font-semibold",
        "border-2 border-indigo-700 bg-transparent",
        "bad-guess:bg-indigo-700 bad-guess:text-white",
        "hover:border-transparent hover:bg-indigo-500 hover:text-white",
        "hover:good-guess:animate-bounce",
        "good-guess:border-blue-500 good-guess:bg-blue-500",
        "focus:border-transparent focus:outline-none",
        "focus:ring-2 focus:ring-yellow-200",
        "active:ring-4 disabled:cursor-not-allowed"
      ]}
    >
      <%= @letter %>
    </button>
    """
  end

  attr :turns_left, :integer, required: true

  def turns_left(assigns) do
    ~H"""
    <p
      id="turns-left"
      last_turn={@turns_left == 1}
      class="my-auto py-2 font-semibold last_turn:bg-red-500 last_turn:text-white md:col-span-1 md:col-start-2"
    >
      Turns left: <%= @turns_left %>
    </p>
    """
  end

  attr :game_state, :atom, required: true
  attr :guess, :string, required: true

  def message(assigns) do
    ~H"""
    <p
      id="message"
      class="bg-blue-500 py-2 text-center font-semibold text-white md:col-span-1 md:col-start-2"
    >
      <%= message(@game_state, @guess) |> HTML.raw() %>
    </p>
    """
  end

  embed_templates "hangman/drawing.html"

  attr :turns_left, :integer, required: true

  def drawing(assigns)

  attr :click, :string, required: true

  def new_game_button(assigns) do
    ~H"""
    <div id="new-game" class="md:col-span-1 md:col-start-1">
      <button
        phx-click={@click}
        class={[
          "w-5/12 rounded bg-blue-500 px-4 py-2 font-semibold text-white",
          "hover:bg-blue-700",
          "focus:outline-none focus:ring-2 focus:ring-yellow-200",
          "active:ring-4"
        ]}
      >
        New Game
      </button>
    </div>
    """
  end

  ## Private functions

  # initializing, good guess, bad guess, already used, lost, won...
  @spec message(Game.state(), Game.letter() | nil) :: String.t()
  defp message(:initializing, _guess), do: "Good luck 😊❗"
  defp message(:good_guess, _guess), do: "Good guess 😊❗"

  defp message(:bad_guess, guess),
    do: "Letter #{span(guess)} not in the word 😟❗"

  defp message(:already_used, guess),
    do: "Letter #{span(guess)} already used 😮❗"

  defp message(:lost, _guess), do: "Sorry, #{span("you lost")} 😂❗"
  defp message(:won, _guess), do: "Bravo, #{span("you won")} 😇❗"

  @spec span(String.t()) :: String.t()
  defp span(text) do
    """
    <span class="ml-1.5 mr-2.5 rounded -pt-0.5 pb-1 font-medium tracking-widest bg-red-600 pl-2">
      #{text}
    </span>
    """
  end

  # rope, head, body, leg2, leg1, arm2, arm1
  @spec dim_if(boolean) :: String.t()
  defp dim_if(_dim? = true), do: "opacity-20"
  defp dim_if(_dim?), do: "opacity-100 transition-opacity duration-500"
end
