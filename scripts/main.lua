local engine = EngineFactory.new()
    :set_title("Carimbo")
    :set_width(854)
    :set_height(480)
    :set_fullscreen(false)
    :create()

engine:prefetch({ "blobs/01.avif", "blobs/deitzis.ogg" })

local Directions = {
  NORTH = "north",
  SOUTH = "south",
  EAST = "east",
  WEST = "west"
}

local change_to = nil
local direction = Directions.SOUTH
local wiggler = engine:spawn()
local elapsed = 0

wiggler.pixmap = "blobs/01.avif"

wiggler:on_update(function(self)
  if engine:is_keydown(KeyEvent.w) then
    change_to = Directions.NORTH
  end

  if engine:is_keydown(KeyEvent.a) then
    change_to = Directions.WEST
  end

  if engine:is_keydown(KeyEvent.s) then
    change_to = Directions.SOUTH
  end

  if engine:is_keydown(KeyEvent.d) then
    change_to = Directions.EAST
  end

  if engine:is_keydown(KeyEvent.space) then
    wiggler.play = "blobs/deitzis.ogg"
  end

  if change_to == Directions.NORTH and direction ~= Directions.SOUTH then
    direction = Directions.NORTH
  end

  if change_to == Directions.WEST and direction ~= Directions.EAST then
    direction = Directions.WEST
  end

  if change_to == Directions.SOUTH and direction ~= Directions.NORTH then
    direction = Directions.SOUTH
  end

  if change_to == Directions.EAST and direction ~= Directions.WEST then
    direction = Directions.EAST
  end

  local now = engine:ticks()
  if now - elapsed > 500 then
    elapsed = now
    if direction == Directions.NORTH then
      self:move(0, -64)
    end

    if direction == Directions.WEST then
      self:move(-64, 0)
    end

    if direction == Directions.SOUTH then
      self:move(0, 64)
    end

    if direction == Directions.EAST then
      self:move(64, 0)
    end
  end
end)

local gc = engine:spawn()

gc:on_update(function(self)
  if collectgarbage("count") / 1024 > 16 then
    collectgarbage("collect")
  else
    collectgarbage("step", 8)
  end
end)

engine:run()
