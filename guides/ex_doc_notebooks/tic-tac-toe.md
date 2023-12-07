# TicTacToe

[![Run in Livebook](https://livebook.dev/badge/v1/blue.svg)](https://livebook.dev/run?url=https%3A%2F%2Fraw.githubusercontent.com%2Fliveview-native%2Flive_view_native%2Fmain%2Fguides%2Fnotebooks%tic-tac-toe.livemd)

## Overview

In this guide, you'll learn about event-bindings in LiveView Native by building a TicTacToe game.

## Game

To track the state of the game we're going to use a `Game` struct. The `Game` struct will have a `board` field that will be a list of lists of `:x`, `:o`, or `nil`. The `:x` and `:o` atoms will represent the player who has marked that space. The `nil` atom will represent an empty space. The `Game` struct will also have a `turn` field that will be either `:x` or `:o` to represent whose turn it is.

```elixir
defmodule Game do
  @blank_game [
    [nil, nil, nil],
    [nil, nil, nil],
    [nil, nil, nil]
  ]

  defstruct board: @blank_game, turn: :x
end
```

## TicTacToe

The `TicTacToe` module will take in a `Game` struct and allow players to mark spaces on the board. The `TicTacToe` module will have a `mark` function that takes in a `Game` struct, a `row` integer, and a `column` integer. The `mark` function will return a new `Game` struct with the space at the given `row` and `column` marked with the current player's mark. The `mark` function will also update the `turn` field of the `Game` struct to the other player.

```elixir
defmodule TicTacToe do
  @doc """
  iex> game = %Game{}
  iex> TicTacToe.mark(game, 1, 2)
  %Game{board: [[nil, nil, nil], [nil, nil, :x], [nil, nil, nil]], turn: :o}
  """
  def mark(game, row, column) do
    game_row = Enum.at(game.board, row)
  end
end
```