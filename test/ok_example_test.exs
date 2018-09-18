defmodule OkExampleTest do
  use ExUnit.Case
  doctest OkExample

  test "greets the world" do
    assert OkExample.hello() == :world
  end
end
