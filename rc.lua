-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

require("vicious")

require("battery")


-- Load Debian menu entries
require("debian.menu")

-- require("awesompd/awesompd")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/reox/.config/awesome/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "xterm"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor


-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ "term", "www", "mail", "chat", 5, 6, 7, 8, 9 }, s, layouts[1])
end

-- console tab needs other layout:
awful.tag.viewonly(tags[1][1])
awful.layout.set(awful.layout.suit.tile, tags[1][1])
awful.tag.incmwfact(0.15, tags[1][1])

-- pidgin tab need also other layout...
awful.tag.viewonly(tags[1][4])
awful.layout.set(awful.layout.suit.tile, tags[1][4])
awful.tag.incmwfact(0.3, tags[1][4])

-- mail need another layout
awful.tag.viewonly(tags[1][3])
awful.layout.set(awful.layout.suit.magnifier, tags[1][3])

-- jump back to default
awful.tag.viewonly(tags[1][1])

-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "Debian", debian.menu.Debian_menu.Debian },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox

-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" })

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))


--   musicwidget = awesompd:create() -- Create awesompd widget
--   musicwidget.font = "Liberation Mono" -- Set widget font 
--   musicwidget.scrolling = true -- If true, the text in the widget will be scrolled
--   musicwidget.output_size = 30 -- Set the size of widget in symbols
--   musicwidget.update_interval = 10 -- Set the update interval in seconds
--   -- Set the folder where icons are located (change username to your login name)
--   musicwidget.path_to_icons = "/home/reox/.config/awesome/awesompd/icons" 
--   -- Set the default music format for Jamendo streams. You can change
--   -- this option on the fly in awesompd itself.
--   -- possible formats: awesompd.FORMAT_MP3, awesompd.FORMAT_OGG
--   musicwidget.jamendo_format = awesompd.FORMAT_MP3
--   -- If true, song notifications for Jamendo tracks and local tracks will also contain
--   -- album cover image.
--   musicwidget.show_album_cover = true
--   -- Specify how big in pixels should an album cover be. Maximum value
--   -- is 100.
--   musicwidget.album_cover_size = 50
--   -- Specify decorators on the left and the right side of the
--   -- widget. Or just leave empty strings if you decorate the widget
--   -- from outside.
--   musicwidget.ldecorator = " "
--   musicwidget.rdecorator = " "
--   -- Set all the servers to work with (here can be any servers you use)
--   musicwidget.servers = {
--      { server = "127.0.0.1",
--           port = 6600 },
--      { server = "10.20.30.40",
--           port = 6600 },
--   }
--   -- Set the buttons of the widget
--   musicwidget:register_buttons({ { "", awesompd.MOUSE_LEFT, musicwidget:command_toggle() },
--       			       { "Control", awesompd.MOUSE_SCROLL_UP, musicwidget:command_prev_track() },
--  			       { "Control", awesompd.MOUSE_SCROLL_DOWN, musicwidget:command_next_track() },
--  			       { "", awesompd.MOUSE_SCROLL_UP, musicwidget:command_volume_up() },
--  			       { "", awesompd.MOUSE_SCROLL_DOWN, musicwidget:command_volume_down() },
--  			       { "", awesompd.MOUSE_RIGHT, musicwidget:command_show_menu() },
--                                { "", "XF86AudioLowerVolume", musicwidget:command_volume_down() },
--                                { "", "XF86AudioRaiseVolume", musicwidget:command_volume_up() },
--                                { modkey, "Pause", musicwidget:command_playpause() } })
--   musicwidget:run() -- After all configuration is done, run the widget

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

	-- RAM Widget
	memwidget = widget({ type = "textbox" })
	vicious.register(memwidget, vicious.widgets.mem, "[ RAM $1% ]", 20)
	-- BAT Widget
	batwidget_time = widget({ type = "textbox" })
	ipwidget = widget({ type = "textbox" })
	dnswidget = widget({ type = "textbox" })
	backupwidget = widget({ type = "textbox" })

	vicious.register(ipwidget, function() return awful.util.pread("/home/reox/git/localbin/getAllIPs.sh") end, "$1 ", 30)
	vicious.register(dnswidget, function() return awful.util.pread("/home/reox/git/localbin/dnsscript.sh") end, "$1 ", 30)
	vicious.register(backupwidget, function() return awful.util.pread("/home/reox/git/localbin/backup-status") end, "$1 ", 30)

    batterywidget = widget({type = "textbox", name = "batterywidget", align = "right" })



    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        mytextclock,
        s == 1 and mysystray or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft,

    }

    -- Create the wibox
    botwibox = awful.wibox({ position = "bottom", screen = s })
    botwibox.widgets = {
		memwidget,
        batterywidget,
		dnswidget,
		ipwidget,
		backupwidget,
        layout = awful.widget.layout.horizontal.rightleft
    }

end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
	awful.key({ modkey,           }, "L"     , function () awful.util.spawn("slock") end),
	awful.key({ Button3,                  }, "Print",  function () awful.util.spawn("scrot", false) end),
	-- awful.key({ "Shift"           }, "Print",  function () awful.util.spawn("scrot -s -e 'mv $f ~/screenshots/ 2>/dev/null'") end),
	-- Audio
	awful.key({			    	  }, "#121", 		function () awful.util.spawn("volume mute", false) end),
	awful.key({					  }, "#122", 		function () awful.util.spawn("volume voldown", false) end),
	awful.key({					  }, "#123",	  	function () awful.util.spawn("volume volup", false) end),

    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)

)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    { rule = { class = "keepassx" },
      properties = { floating = true } },
	-- set some windows
	{ rule = { instance = "xterm" }, 
	  properties = { tag = tags[1][1] } },
	{ rule = { instance = "google-chrome" }, 
	  properties = { tag = tags[1][2] } },
	{ rule = { class = "Icedove" }, 
	  properties = { tag = tags[1][3] } },
	{ rule = { class = "Pidgin", role = "buddy_list" },
	  properties = { tag = tags[1][4] },
	  callback = awful.client.setslave
	},
	{ rule = { class = "Pidgin", role = "conversation" },
	  properties = { tag = tags[1][4] },
	},
	 
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}


-- {{{ autostart

function run_once(prg, arg_string)
    if not prg then
        do return nil end
    end

    if not arg_string then 
        awful.util.spawn_with_shell("pgrep -u $USER -x '" .. prg .. "' || (" .. prg .. ")")
    else
        awful.util.spawn_with_shell("pgrep -u $USER -x '" .. prg .. "' || (" .. prg .. " " .. arg_string .. ")")
    end
end

-- gnome stuff
run_once("/usr/lib/at-spi2-core/at-spi-bus-launcher --launch-immediately")
run_once("/usr/lib/notification-daemon/notification-daemon")



run_once("google-chrome")
run_once("pidgin")
run_once("icedove")
-- two times xterm :)
run_once("xterm")
--run_once("xterm")
run_once("wicd-gtk --tray")
-- load calibration for monitor
run_once("dispwin /home/reox/git/dispcal/2011-12-23_HIGH_Laptop.cal")
-- set the name of the window manager, should fix jdk problems
run_once("wmname LG3D")
run_once("dropboxd")


-- }}}


-- {{{ Widget stuff (naughty config)
naughty.config.default_preset.timeout          = 5
naughty.config.default_preset.screen           = 1
naughty.config.default_preset.position         = "top_right"
naughty.config.default_preset.margin           = 4
naughty.config.default_preset.gap              = 1
naughty.config.default_preset.ontop            = true
naughty.config.default_preset.font             = beautiful.font or "Verdana 8"
naughty.config.default_preset.icon             = nil
naughty.config.default_preset.icon_size        = 16
naughty.config.default_preset.fg               = beautiful.fg_focus or '#ffffff'
naughty.config.default_preset.bg               = beautiful.bg_focus or '#535d6c'
naughty.config.presets.normal.border_color     = beautiful.border_focus or '#535d6c'
naughty.config.default_preset.border_width     = 1
naughty.config.default_preset.hover_timeout    = nil

naughty.config.presets.normal.icon_size        = 32
naughty.config.presets.low.icon_size           = 32
naughty.config.presets.critical.icon_size      = 32

bat_clo = battery.batclosure("BAT0")
batterywidget.text = bat_clo()
battimer = timer({ timeout = 30 })
battimer:add_signal("timeout", function() batterywidget.text = bat_clo() end)
battimer:start()

-- }}}

