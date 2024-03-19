defmodule Hangman.LiveWeb.HangmanLive do
  use Hangman.LiveWeb, [:live_view, :aliases]

  import HangmanComponents

  @letters Enum.map(?a..?z, &<<&1>>)

  @impl LV
  @spec mount(LV.unsigned_params(), map, Socket.t()) :: {:ok, Socket.t()}
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> Live.new_game()
     |> stream_configure(:guess_letters, dom_id: & &1)
     |> stream(:guess_letters, @letters)}
  end

  @impl LV
  @spec render(Socket.assigns()) :: Rendered.t()
  def render(assigns) do
    ~H"""
    <.game_field header="Welcome to Hangman!!">
      <.focus_wrap id="game-focus-wrap">
        <.grid keyup="keyup">
          <.word_letters update="replace">
            <.word_letter
              :for={{letter, index} <- Enum.with_index(@letters)}
              id={to_string(index)}
              letter={letter}
            />
          </.word_letters>
          <.guess_letters update="stream">
            <.guess_letter
              :for={{id, letter} <- @streams.guess_letters}
              id={id}
              click="click"
              letter={letter}
              disabled={letter in @guesses}
              good_guess={letter in @letters}
              bad_guess={letter not in @letters and letter in @guesses}
            />
          </.guess_letters>
          <.turns_left turns_left={@turns_left} />
          <.message game_state={@game_state} guess={@guess} />
          <.drawing turns_left={@turns_left} />
          <.new_game_button click="new-game" />
        </.grid>
      </.focus_wrap>
    </.game_field>
    """
  end

  @impl LV
  @spec handle_event(event :: binary, LV.unsigned_params(), Socket.t()) ::
          {:noreply, Socket.t()}
  def handle_event("new-game", _params, socket) do
    :ok = Live.end_game(socket)
    {:noreply, Live.new_game(socket) |> LV.push_navigate(to: ~p"/hangman")}
  end

  def handle_event("click", %{"guess" => guess}, socket),
    do: {:noreply, make_move(socket, guess)}

  def handle_event("keyup", %{"key" => <<byte>> = key}, socket)
      when byte in ?a..?z,
      do: {:noreply, make_move(socket, key)}

  def handle_event("keyup", %{"key" => key}, socket) do
    IO.inspect(key, label: "::: key ignored ::")
    {:noreply, socket}
  end

  @impl LV
  @spec terminate(term, Socket.t()) :: :ok
  def terminate(reason, socket), do: :ok = Live.terminate(reason, socket)

  ## Private functions

  @spec make_move(Socket.t(), <<_::8>>) :: Socket.t()
  defp make_move(socket, guess),
    do: Live.make_move(socket, guess) |> stream_insert(:guess_letters, guess)

  #   defp update_stream(%Socket{assigns: %{game_state: game_state}} = socket) when game_state in [:lost, :won] do
  #  Enum.reduce(@letters, socket, fn letter, socket ->
  # stream_insert(socket, stream_insert(:guess_letters, letter))
  # end)
  #   end

  #   defp make_move(socket) do

  #   end
end
