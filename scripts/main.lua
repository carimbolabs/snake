local engine = EngineFactory.new()
    :set_title("Henrique the rainbow wiggler")
    :set_width(854)
    :set_height(480)
    :set_fullscreen(false)
    :create()

engine:prefetch({
  "blobs/head.avif",
  "blobs/red.avif",
  "blobs/orange.avif",
  "blobs/yellow.avif",
  "blobs/green.avif",
  "blobs/blue.avif",
  "blobs/indigo.avif",
  "blobs/violet.avif",
})

local Directions = {
  NORTH = "north",
  SOUTH = "south",
  EAST = "east",
  WEST = "west"
}

local change_to = nil
local direction = Directions.SOUTH
local segments = {}
local queue = {}
local elapsed = 0

local head = engine:spawn()
head.pixmap = "blobs/head.avif"

local colors = { "red", "orange", "yellow", "green", "blue", "indigo", "violet" }
for _, color in ipairs(colors) do
  local segment = engine:spawn()
  segment.pixmap = "blobs/" .. color .. ".avif"

  segment.x = -512
  segment.y = -512
  table.insert(segments, segment)
end

local function init()
  head.x = (engine.width - 64) / 2
  head.y = (engine.height - 64) / 2

  local initialOffsetY = 34
  for i, segment in ipairs(segments) do
    segment.x = head.x
    segment.y = head.y + initialOffsetY * i

    queue[i] = { x = segment.x, y = segment.y }
  end
end

head:on_update(function(self)
  if #queue == 0 then
    init()
  end

  if engine:is_keydown(KeyEvent.w) then change_to = Directions.NORTH end
  if engine:is_keydown(KeyEvent.a) then change_to = Directions.WEST end
  if engine:is_keydown(KeyEvent.s) then change_to = Directions.SOUTH end
  if engine:is_keydown(KeyEvent.d) then change_to = Directions.EAST end

  if change_to and (
        (change_to == Directions.NORTH and direction ~= Directions.SOUTH) or
        (change_to == Directions.WEST and direction ~= Directions.EAST) or
        (change_to == Directions.SOUTH and direction ~= Directions.NORTH) or
        (change_to == Directions.EAST and direction ~= Directions.WEST)
      )
  then
    direction = change_to
  end

  local now = engine:ticks()
  if now - elapsed > 400 then
    elapsed = now

    if direction == Directions.NORTH then self.y = self.y - 64 end
    if direction == Directions.WEST then self.x = self.x - 64 end
    if direction == Directions.SOUTH then self.y = self.y + 64 end
    if direction == Directions.EAST then self.x = self.x + 64 end

    table.insert(queue, 1, { x = self.x, y = self.y })

    for i = 1, #segments do
      local pos = queue[i + 1]
      if pos then
        segments[i].x = pos.x + (64 - segments[i].width) / 2
        segments[i].y = pos.y + (64 - segments[i].height) / 2
      end
    end

    while #queue > #segments + 1 do
      table.remove(queue)
    end
  end
end)

engine:run()
