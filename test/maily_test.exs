defmodule MailyTest do
  use ExUnit.Case
  doctest Maily

  test "greets the world" do
    assert Maily.hello() == :world
  end
end
