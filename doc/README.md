# useful ideas

This file records necessary or interesting ideas not done yet

## Display status of the Caplock
```bash
xset -q | sed -n 's/^.*Caps Lock:\s*\(\S*\).*$/\1/p'
```
This command captures the status of the caplock as on/off
the indication function could be like 

```bash
caps_lock_status=$(xset -q | sed -n 's/^.*Caps Lock:\s*\(\S*\).*$/\1/p')
if [ $caps_lock_status == "on" ]; then
  echo "Caps lock on, turning off"
  xdotool key Caps_Lock
else
  echo "Caps lock already off"
fi
```
