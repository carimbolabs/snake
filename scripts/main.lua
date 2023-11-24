local engine = EngineFactory.new()
    :set_title("Rainbow Wiggler")
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

local function addSegment(color)
  local segment = engine:spawn()
  segment.pixmap = "blobs/" .. color .. ".avif"
  -- Initialize segments off-screen
  segment.x = -100
  segment.y = -100
  table.insert(segments, segment)
end

local colors = { "red", "orange", "yellow", "green", "blue", "indigo", "violet" }
for _, color in ipairs(colors) do
  addSegment(color)
end

-- Set initial positions for the head and segments
local function initializePositions()
  head.x = (engine.width - 64) / 2
  head.y = (engine.height - 64) / 2

  local initialOffsetY = 34                 -- reduced space between the segments
  for i, segment in ipairs(segments) do
    segment.x = head.x                      -- Align horizontally with the head
    segment.y = head.y + initialOffsetY * i -- Position below the head with reduced spacing
    -- Add the position to the queue
    queue[i] = { x = segment.x, y = segment.y }
  end
end

head:on_update(function(self, dt)
  -- Ensure the head dimensions are set before initializing positions
  if not self.width or not self.height then return end
  if #queue == 0 then
    initializePositions()
  end

  if engine:is_keydown(KeyEvent.w) then change_to = Directions.NORTH end
  if engine:is_keydown(KeyEvent.a) then change_to = Directions.WEST end
  if engine:is_keydown(KeyEvent.s) then change_to = Directions.SOUTH end
  if engine:is_keydown(KeyEvent.d) then change_to = Directions.EAST end

  if change_to and ((change_to == Directions.NORTH and direction ~= Directions.SOUTH) or
        (change_to == Directions.WEST and direction ~= Directions.EAST) or
        (change_to == Directions.SOUTH and direction ~= Directions.NORTH) or
        (change_to == Directions.EAST and direction ~= Directions.WEST)) then
    direction = change_to
  end

  local now = engine:ticks()
  if now - elapsed > 500 then
    elapsed = now
    -- Move head based on direction
    if direction == Directions.NORTH then self.y = self.y - 64 end
    if direction == Directions.WEST then self.x = self.x - 64 end
    if direction == Directions.SOUTH then self.y = self.y + 64 end
    if direction == Directions.EAST then self.x = self.x + 64 end

    -- Insert new head position at the beginning of the queue
    table.insert(queue, 1, { x = self.x, y = self.y })

    -- Update segments based on the new positions in the queue
    for i = 1, #segments do
      local pos = queue[i + 1] -- Get the position ahead of the current one in the queue
      if pos then
        segments[i].x = pos.x + (64 - segments[i].width) / 2
        segments[i].y = pos.y + (64 - segments[i].height) / 2
      end
    end

    -- Remove the last position if we have more positions than segments
    while #queue > #segments + 1 do
      table.remove(queue)
    end
  end
end)

engine:run()
