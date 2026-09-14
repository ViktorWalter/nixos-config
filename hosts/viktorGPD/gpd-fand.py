#!/usr/bin/env python3
import glob
import time
import gpiod
from gpiod.line import Direction, Value

CHIP = "/dev/gpiochip1"
LINE0, LINE1 = 0, 1

TEMP_MIN = 55000   # millidegrees C - speed 1 threshold
TEMP_MED = 65000   # speed 2 threshold
TEMP_MAX = 75000   # speed 3 threshold
HYSTERESIS = 3000  # must drop this far below a threshold before stepping down
POLL_SECONDS = 5

THRESHOLDS = [TEMP_MIN, TEMP_MED, TEMP_MAX]

def get_temp():
    temps = []
    for f in glob.glob("/sys/devices/platform/coretemp.0/hwmon/hwmon*/temp*_input"):
        try:
            with open(f) as fh:
                temps.append(int(fh.read().strip()))
        except (OSError, ValueError):
            pass
    return max(temps) if temps else 0

def speed_for(temp, last_speed):
    if temp == 0:
        return 3  # unknown temp -> assume worst, max speed

    # raw target speed from thresholds, no hysteresis applied yet
    raw_speed = 0
    for i, t in enumerate(THRESHOLDS, start=1):
        if temp >= t:
            raw_speed = i

    if raw_speed >= last_speed:
        # rising or steady - always allowed immediately, no hysteresis needed
        return raw_speed

    # falling - only step down if temp has dropped HYSTERESIS below the
    # threshold that put us at the current speed in the first place
    current_threshold = THRESHOLDS[last_speed - 1] if last_speed > 0 else 0
    if temp <= current_threshold - HYSTERESIS:
        return raw_speed
    return last_speed  # not fallen far enough yet, hold current speed

def main():
    with gpiod.request_lines(
        CHIP,
        consumer="gpd-fand",
        config={
            LINE0: gpiod.LineSettings(direction=Direction.OUTPUT, output_value=Value.INACTIVE),
            LINE1: gpiod.LineSettings(direction=Direction.OUTPUT, output_value=Value.INACTIVE),
        },
    ) as request:
        last_speed = 0
        while True:
            temp = get_temp()
            speed = speed_for(temp, last_speed)
            if speed != last_speed:
                request.set_values({
                    LINE0: Value.ACTIVE if speed & 1 else Value.INACTIVE,
                    LINE1: Value.ACTIVE if speed & 2 else Value.INACTIVE,
                })
                last_speed = speed
            time.sleep(POLL_SECONDS)

if __name__ == "__main__":
    main()
