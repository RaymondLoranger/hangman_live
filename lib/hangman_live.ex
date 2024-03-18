defmodule Hangman.Live do
  use Hangman.LiveWeb, [:html, :aliases]

  require Logger

  @init_tally Game.new("", "") |> Game.tally()

  @spec init_game(Socket.t()) :: Socket.t()
  def init_game(socket),
    do: assign(socket, @init_tally) |> assign(guess: nil)

  @spec end_game(Socket.t()) :: :ok
  def end_game(%Socket{assigns: %{game_name: game_name}} = _socket) do
    :ok = Logger.info("Ending game #{game_name}...")
    :ok = Engine.end_game(game_name)
  end

  @spec new_game(Socket.t()) :: Socket.t()
  def new_game(socket) do
    game_name = Game.random_name()
    :ok = Logger.info("Starting game #{game_name}...")
    {:ok, _game_pid} = Engine.new_game(game_name)
    tally = Engine.tally(game_name)
    assign(socket, tally) |> assign(guess: nil, game_name: game_name)
  end

  @spec make_move(Socket.t(), String.codepoint()) :: Socket.t()
  def make_move(%Socket{assigns: %{game_name: game_name}} = socket, guess) do
    tally = Engine.make_move(game_name, guess)
    assign(socket, tally) |> assign(guess: guess)
  end

  @spec terminate(term, Socket.t()) :: :ok
  def terminate(reason, %Socket{assigns: %{game_name: game_name}} = _socket) do
    :ok = Logger.warning("Ending game #{game_name}...")
    :ok = Logger.warning("Reason: #{inspect(reason)}")
    :ok = Engine.end_game(game_name)
  end
end
