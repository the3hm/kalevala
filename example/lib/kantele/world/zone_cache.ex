defmodule Kantele.World.ZoneCache do
  @moduledoc """
  Cache for world data
  """

  use Kalevala.Cache

  alias Kantele.MiniMap

  def cache(zone) do
    :ok = put(zone.id, zone)
    zone
  end

  def mini_map(zone_id, current_location) do
    {:ok, zone} = get(zone_id)
    {:ok, MiniMap.display(zone.mini_map, current_location)}
  end
end
