local beautiful = require("beautiful")
local awful = require("awful")

local update_interval = 300
local update_script = [[
  sh -c "
    checkupdates | wc -l
  "]]

return awful.widget.watch(update_script, update_interval, function(widget, stdout)
  widget.markup = "<span foreground='" .. beautiful.xcolor6 .. "'> " .. stdout .. "</span>"
  widget.font = beautiful.font_name .. "14"
end)
