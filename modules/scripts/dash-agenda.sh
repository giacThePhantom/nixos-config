# dash-agenda: the next 7 days of renCal events (read by the caldir CLI from
# its calendar_dir) as JSON for the calendar panel:
#   [{label, events: [{title, time, location, cal, url}]}]
# `cal` numbers each calendar (for its colour); `url` opens the event in renCal.
today="$(date +%F)"
events="$(caldir events --json --from "$today" --to "$(date -d '+6 day' +%F)" 2>/dev/null || true)"

jq -c --arg today "$today" --arg tomorrow "$(date -d tomorrow +%F)" '
  # caldir gives times with an offset (+01:00, +00:00...); show them in local time
  def epoch: (.[0:19] + "Z" | fromdateiso8601)
    - (.[19:] | if . == "" or . == "Z" then 0
        else ((.[1:3] | tonumber) * 3600 + (.[4:6] | tonumber) * 60)
          * (if .[0:1] == "-" then -1 else 1 end) end);
  def local(f): epoch | localtime | strftime(f);
  def day: if .all_day then .start[0:10] else .start | local("%Y-%m-%d") end;

  (map(.calendar) | unique) as $cals
  | sort_by(if .all_day then .start[0:10] + "T00:00:00Z" else .start end | epoch)
  | group_by(day)
  | map({
      label: (.[0] | day
        | if . == $today then "Today"
          elif . == $tomorrow then "Tomorrow"
          else strptime("%Y-%m-%d") | strftime("%A %-d %B") end),
      events: map({
        title: (.title // .summary // "(no title)"),
        time: (if .all_day then "All day"
          else "\(.start | local("%H:%M")) – \(.end | local("%H:%M"))" end),
        location: (.location // ""),
        cal: ((.calendar as $c | $cals | index($c)) % 4),
        url: ("rencal://event?uid=\(.uid | @uri)"
          + (if .recurrence_id then "&recurrence-id=\(.recurrence_id | tostring | @uri)" else "" end))
      })
    })' <<<"${events:-[]}" 2>/dev/null || echo '[]'
