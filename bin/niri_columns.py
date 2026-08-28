#!/usr/bin/env python3
import html
import json
import os
import re
import subprocess
import sys

NIRI_MSG = "/usr/bin/niri"
MAX_TITLE = 40

ACCENT = "#7aa2f7"
FOCUSED_OPEN = f'<b><span color="{ACCENT}">'
FOCUSED_CLOSE = "</span></b>"
COL_SEP = f'<span color="{ACCENT}">│</span>'
WIN_SEP = f'<span color="{ACCENT}">·</span>'

workspaces = {}
windows = {}


def sanitize(text):
    return html.escape(text)


def truncate(text, limit=MAX_TITLE):
    if len(text) <= limit:
        return text
    return text[: limit - 1] + "…"


def focused_workspace():
    candidates = [
        ws["id"]
        for ws in workspaces.values()
        if ws.get("is_focused") or ws.get("is_active")
    ]
    if candidates:
        return candidates[0]
    return None


def render():
    ws_id = focused_workspace()
    if ws_id is None:
        return ""

    cols = {}
    for win in windows.values():
        if win.get("workspace_id") != ws_id or win.get("is_floating"):
            continue
        layout = win.get("layout") or {}
        pos = layout.get("pos_in_scrolling_layout")
        if not pos:
            continue
        col, row = int(pos[0]), int(pos[1])
        cols.setdefault(col, []).append((row, win))

    if not cols:
        return ""

    groups = []
    for col in sorted(cols):
        wins = sorted(cols[col])
        parts = []
        for _, win in wins:
            title = truncate(sanitize(win.get("title") or win.get("app_id") or "?"))
            if win.get("is_focused"):
                parts.append(FOCUSED_OPEN + title + FOCUSED_CLOSE)
            else:
                parts.append(title)
        groups.append(f"{col}{COL_SEP}{WIN_SEP.join(parts)}")

    return "   ".join(groups)


def main():
    env = dict(os.environ)
    env.setdefault("WAYLAND_DISPLAY", "wayland-1")

    proc = subprocess.Popen(
        [NIRI_MSG, "msg", "-j", "event-stream"],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
        env=env,
    )

    for line in proc.stdout:
        line = line.strip()
        if not line:
            continue
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue

        if "WorkspacesChanged" in event:
            for ws in event["WorkspacesChanged"]["workspaces"]:
                workspaces[ws["id"]] = ws
            out = render()
        elif "WindowsChanged" in event:
            windows.clear()
            for win in event["WindowsChanged"]["windows"]:
                windows[win["id"]] = win
            out = render()
        elif "WindowFocusChanged" in event:
            out = render()
        elif "WorkspaceActivatedChanged" in event:
            out = render()
        else:
            continue

        sys.stdout.write(out + "\n")
        sys.stdout.flush()

    sys.exit(1)


if __name__ == "__main__":
    main()
