defmodule Hangman.LiveWeb.HangmanLive do
  use Hangman.LiveWeb, [:live_view, :aliases]

  import HangmanComponents

  @impl LV
  @spec mount(LV.unsigned_params(), map, Socket.t()) :: {:ok, Socket.t()}
  def mount(_params, _session, socket) do
    if connected?(socket) do
      {:ok, Live.new_game(socket)}
    else
      {:ok, Live.init_game(socket)}
    end
  end

  @impl LV
  @spec render(Socket.assigns()) :: Rendered.t()
  def render(assigns) do
    ~H"""
    <.game_field header="Welcome to Hangman!!">
      <.grid keyup="keyup">
        <.word_letters update="replace">
          <.word_letter
            :for={{letter, index} <- Enum.with_index(@letters)}
            id={to_string(index)}
            letter={letter}
          />
        </.word_letters>
        <.guess_letters update="replace">
          <.guess_letter
            :for={byte <- ?a..?z}
            id={<<byte>>}
            click="click"
            letter={<<byte>>}
            disabled={<<byte>> in @guesses}
            good_guess={<<byte>> in @letters}
            game_over={@game_state in [:lost, :won]}
          />
        </.guess_letters>
        <.turns_left turns_left={@turns_left} />
        <.message game_state={@game_state} guess={@guess} />
        <.drawing turns_left={@turns_left} />
        <.new_game_button click="new-game" />
      </.grid>
    </.game_field>
    """
  end

  @impl LV
  @spec handle_event(event :: binary, LV.unsigned_params(), Socket.t()) ::
          {:noreply, Socket.t()}
  def handle_event("new-game", _params, socket) do
    :ok = Live.end_game(socket)
    {:noreply, Live.new_game(socket)}
  end

  def handle_event("click", %{"guess" => guess}, socket),
    do: {:noreply, Live.make_move(socket, guess)}

  def handle_event("keyup", %{"key" => <<byte>> = key}, socket)
      when byte in ?a..?z,
      do: {:noreply, Live.make_move(socket, key)}

  def handle_event("keyup", %{"key" => key}, socket) do
    IO.inspect(key, label: "::: key ignored ::")
    {:noreply, socket}
  end

  @impl LV
  @spec terminate(term, Socket.t()) :: :ok
  def terminate(reason, socket), do: :ok = Live.terminate(reason, socket)
end
