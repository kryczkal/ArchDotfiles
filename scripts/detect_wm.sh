#!/bin/bash
if pgrep -x "river" >/dev/null; then
    echo "river"
elif pgrep -x "qtile" >/dev/null; then
    echo "qtile"
else
    echo "unknown"
fi

