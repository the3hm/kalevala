defmodule Kantele.Commands do
  @moduledoc false

  use Kalevala.Command.Router

  scope(Kantele) do
    module(CombatCommand) do
      command("combat start", :start)
      command("combat stop", :stop)
      command("combat tick", :tick)
    end

    module(LookCommand) do
      command("look", :run)
    end

    module(MoveCommand) do
      command("north", :north)
      command("south", :south)
      command("east", :east)
      command("west", :west)
    end

    module(QuitCommand) do
      command("quit", :run)
      command(<<4>>, :run, display: false)
    end

    module(SayCommand) do
      command("say :text", :run)
    end

    module(ChannelCommand) do
      command("general :text", :general)
    end

    module(WhoCommand) do
      command("who", :run)
    end
  end
end
