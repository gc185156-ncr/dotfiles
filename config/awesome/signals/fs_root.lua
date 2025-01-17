-- Provides:
-- signal::disk
--      used (integer - mega bytes)
--      total (integer - mega bytes)
local awful = require("awful")

local update_interval = 60

-- Use /dev/sdxY according to your setup
local disk_script = [[
    sh -c "
    df -kh -B 1MB /dev/sdb5 | tail -1 | awk '{printf \"%d@%d\", $4, $3}'
    "
]]

-- Periodically get disk space info
awful.widget.watch(disk_script, update_interval, function(_, stdout)
  local available = tonumber(stdout:match("^(.*)@")) / 1000
  local used = tonumber(stdout:match("@(.*)$")) / 1000
  awesome.emit_signal("signal::fs_root", used, available + used)
end)
