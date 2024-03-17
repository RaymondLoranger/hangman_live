defmodule Hangman.LiveWeb.HangmanComponents do
  use Hangman.LiveWeb, [:html, :aliases]

  @spec game_field(Socket.assigns()) :: Rendered.t()
  def game_field(assigns) do
    ~H"""
    <.header inner_class="mb-6 md:mb-12 md:ml-24 text-center text-cool-gray-900 font-extrabold text-4xl">
      <%= @header %>
    </.header>

    <div id="game-field" class="mx-auto max-w-3xl text-center">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  def grid(assigns) do
    ~H"""
    <div
      id="grid"
      phx-window-keyup={@keyup}
      class="mb-4 grid grid-flow-row-dense grid-cols-1 gap-x-8 gap-y-5 md:grid-cols-2 md:gap-y-2"
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  def word_letters(assigns) do
    ~H"""
    <p
      id="word-letters"
      phx-update={@update}
      class="font-mono mb-4 h-10 text-3xl tracking-wide md:col-span-1 md:col-start-2"
    >
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  def word_letter(%{letter: letter} = assigns) do
    assigns =
      assign_new(assigns, :kind, fn ->
        case letter do
          "_" -> "masked"
          <<byte>> when byte in ?a..?z -> "guessed"
          _single_letter_list -> "unveiled"
        end
      end)

    ~H"""
    <span
      id={@id}
      masked={@kind == "masked"}
      guessed={@kind == "guessed"}
      unveiled={@kind == "unveiled"}
      class="guessed:text-blue-500 masked:text-gray-900 unveiled:opacity-30"
    >
      <%= @letter %>
    </span>
    """
  end

  def guess_letters(assigns) do
    ~H"""
    <div
      id="guess-letters"
      phx-update={@update}
      class="grid-cols-auto-fit grid items-center justify-items-center gap-x-1 gap-y-3 md:col-span-1 md:col-start-2 md:gap-x-2 md:gap-y-4"
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  def guess_letter(assigns) do
    ~H"""
    <button
      id={@id}
      phx-click="click"
      phx-value-guess={@letter}
      disabled={@disabled}
      good-guess={@good_guess}
      game-over={@game_over}
      class="h-10 w-10 rounded-full border-2 border-indigo-700 bg-transparent pb-1 font-semibold game-over:cursor-not-allowed good-guess:border-blue-500 hover:border-transparent hover:bg-indigo-500 hover:text-white hover:good-guess:animate-bounce disabled:cursor-not-allowed disabled:bg-indigo-700 disabled:text-white disabled:good-guess:bg-blue-500"
    >
      <%= @letter %>
    </button>
    """
  end

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

  def new_game_button(assigns) do
    ~H"""
    <div id="new-game">
      <button phx-click="new-game">New Game</button>
    </div>
    """
  end

  def message(assigns) do
    ~H"""
    <p id="message">
      <%= message(@game_state, @guess) %>
    </p>
    """
  end

  embed_templates "hangman/drawing.html"

  # attr :turns_left, :integer, required: true
  # attr :class, :string, required: true
  def drawing(assigns)

  ## Private functions

  # initializing, good guess, bad guess, already used, lost, won...
  @spec message(Game.state(), Game.letter() | nil) :: String.t() | HTML.safe()
  defp message(:initializing, _guess), do: "Good luck 😊❗"
  defp message(:good_guess, _guess), do: "Good guess 😊❗"

  defp message(:bad_guess, guess),
    do: HTML.raw("Letter <span>#{guess}</span> not in the word 😟❗")

  defp message(:already_used, guess),
    do: HTML.raw("Letter <span>#{guess}</span> already used 😮❗")

  defp message(:lost, _guess), do: HTML.raw("Sorry, <span>you lost</span> 😂❗")
  defp message(:won, _guess), do: HTML.raw("Bravo, <span>you won</span> 😇❗")

  # @spec guess_letter(boolean, boolean) :: String.t() | nil
  # defp guess_letter(correct, game_over)
  # defp guess_letter(false, false), do: nil
  # defp guess_letter(false, true), do: "game-over"
  # defp guess_letter(true, false), do: "correct"
  # defp guess_letter(true, true), do: "correct game-over"

  # rope, head, body, leg2, leg1, arm2, arm1
  @spec dim_if(boolean) :: String.t()
  defp dim_if(_dim? = true), do: "opacity-20"
  defp dim_if(_dim?), do: "opacity-100"
end
