# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
from enum import Enum

from libqtile import bar, layout, qtile, widget, hook
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
from libqtile.backend.wayland import InputConfig

import subprocess
import os

import colors

mod = "mod4"
terminal = guess_terminal()


keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html

################################################################################
#                                 Normal Mode                                  #
################################################################################
#------------------------------------------------------------------------------#
#                             Normal Mode : Focus                              #
#------------------------------------------------------------------------------#
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),

    Key([mod], "Left", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "Right", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "Down", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "Up", lazy.layout.up(), desc="Move focus up"),
#------------------------------------------------------------------------------#
#                          Normal Mode : Move Windows                          #
#------------------------------------------------------------------------------#
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),

    Key([mod, "shift"], "Left", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "Right", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "Down", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "Up", lazy.layout.shuffle_up(), desc="Move window up"),
#------------------------------------------------------------------------------#
#                         Normal Mode : Resize Windows                         #
#------------------------------------------------------------------------------#
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),

    Key([mod, "control"], "Left", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "Right", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "Down", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "Up", lazy.layout.grow_up(), desc="Grow window up"),

    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
################################################################################
#                               Common Bindings                                #
################################################################################
#------------------------------------------------------------------------------#
#                                 Toggle Float                                 #
#------------------------------------------------------------------------------#
    Key([mod], "space", lazy.window.toggle_floating(), desc="Toggle floating on the focused window"),
    # TODO: Potentialy make this KeyChained
#------------------------------------------------------------------------------#
#                              Toggle Fullscreen                               #
#------------------------------------------------------------------------------#
Key([mod], "f",
    lazy.window.toggle_fullscreen(),
    desc="Toggle fullscreen",
),
#------------------------------------------------------------------------------#
#                                 Kill Window                                  #
#------------------------------------------------------------------------------#
    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),
################################################################################
#                              App Start Bindings                              #
################################################################################
#------------------------------------------------------------------------------#
#                                   Terminal                                   #
#------------------------------------------------------------------------------#
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
#------------------------------------------------------------------------------#
#                                  Screenshot                                  #
#------------------------------------------------------------------------------#
    Key([], "Print", lazy.spawn("grimshot copy area")),
    # TODO: Make screenshot command a variable
#------------------------------------------------------------------------------#
#                                   Launcher                                   #
#------------------------------------------------------------------------------#
    Key([mod], "Tab", lazy.spawn("rofi -show drun"), desc="Start app launcher"),
#------------------------------------------------------------------------------#
#                                 File Manager                                 #
#------------------------------------------------------------------------------#
    Key([mod], "e", lazy.spawn("nautilus"), desc="Start file manager"),
    # Toggle between different layouts as defined below
#------------------------------------------------------------------------------#
#                                Reload Config                                 #
#------------------------------------------------------------------------------#
    Key([mod, "Shift"], "r", lazy.reload_config(), desc="Reload the config"),
#------------------------------------------------------------------------------#
#                                   Shutdown                                   #
#------------------------------------------------------------------------------#
    Key([mod], "Escape", lazy.shutdown(), desc="Shutdown Qtile"),

    # Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
    # TODO: Think about this command
]

# Add key bindings to switch VTs in Wayland.
# We can't check qtile.core.name in default config as it is loaded before qtile is started
# We therefore defer the check until the key binding is run by using .when(func=...)
for vt in range(1, 8):
    keys.append(
        Key(
            ["control", "mod1"],
            f"f{vt}",
            lazy.core.change_vt(vt).when(func=lambda: qtile.core.name == "wayland"),
            desc=f"Switch to VT{vt}",
        )
    )


groups = [Group(i) for i in "123456789"]

# TODO: Consider
for i in groups:
    keys.extend(
        [
            # mod1 + group number = switch to group
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc="Switch to group {}".format(i.name),
            ),
            # mod1 + shift + group number = switch to & move focused window to group
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name, switch_group=True),
                desc="Switch to & move focused window to group {}".format(i.name),
            ),
            # Or, use below if you prefer not to switch to that group.
            # # mod1 + shift + group number = move focused window to group
            # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
            #     desc="move focused window to group {}".format(i.name)),
        ]
    )


border_focus='#FFFFFF'
border_normal='#AAAAAA'
border_width=1
layouts = [
    layout.Columns(border_focus = border_focus,border_normal=border_normal , border_width=border_width),
    layout.Max(),
    # Try more layouts by unleashing below layouts.
    # layout.Stack(num_stacks=2),
    # layout.Bsp(),
    # layout.Matrix(),
    layout.MonadTall(border_focus=border_focus, border_normal=border_normal,border_width=border_width),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    layout.Zoomy(border_focus=border_focus, border_width=border_width,border_normal=border_normal),
]

widget_defaults = dict(
    font="sans",
    fontsize=12,
    padding=3,
)
extension_defaults = widget_defaults.copy()

screens = [
    Screen(
    ),
]

@hook.subscribe.startup_once
def autostart():
    subprocess.Popen(["waybar"])

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
floating_layout = layout.Floating(
    border_normal=border_normal,
    border_focus=border_focus,
    border_width=border_width,
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="waybar"),
        Match(title="waybar"),
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = {
    "type:keyboard": InputConfig(
        kb_repeat_rate=25,
        kb_repeat_delay=250,
    ),
    "type:touchpad": InputConfig(drag=True, tap=True, natural_scroll=True),
}

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"

################################################################################
#                                Waybar Widgets                                #
################################################################################

class GroupState(Enum):
    EMPTY = 1
    OCCUPIED = 2
    FOCUSED = 3


@hook.subscribe.focus_change
@hook.subscribe.client_killed
@hook.subscribe.client_managed
def update_waybar(*_args) -> None:
    """Update Waybar of open groups and windows"""
    existing_groups = dict.fromkeys(qtile.groups_map.keys(), GroupState.EMPTY)  # type: ignore[attr-defined]

    existing_groups.pop("scratchpad", None)

    current_group: str = qtile.current_screen.group.label  # type: ignore[attr-defined]

    for window in qtile.windows():  # type: ignore[attr-defined]
        if (
            window["wm_class"] is not None
            and window["group"] is not None
            and window["group"] in existing_groups
        ):
            existing_groups[window["group"]] = GroupState.OCCUPIED

    existing_groups[current_group] = GroupState.FOCUSED

    text: str = ""

    for group, status in existing_groups.items():
        match status:
            case GroupState.OCCUPIED:
                text += f"""<span fgcolor='{colors["primary"]}'> {group} </span>"""
            case GroupState.EMPTY:
                text += f"""<span fgcolor='{colors["secondary"]}'> {group} </span>"""
            case GroupState.FOCUSED:
                text += f"""<span fgcolor='{colors["background"]}' bgcolor='{colors["primary"]}' line_height='2'> {group} </span>"""

    with open("/tmp/qtile-groups.txt", "w", encoding="utf-8") as output:
        output.write(text)
        output.close()

    subprocess.call(["pkill -RTMIN+8 waybar"], shell=True)

