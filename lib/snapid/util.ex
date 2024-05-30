defmodule Snapid.Util do
  def date_string(datetime, timezone) do
    {:ok, now} = DateTime.now(timezone)
    today = now |> DateTime.to_date()
    yesterday = Date.add(today, -1)

    datetime_tz = DateTime.shift_zone!(datetime, timezone)
    date = DateTime.to_date(datetime_tz)
    time = Calendar.strftime(datetime_tz, "%H:%M")

    cond do
      Date.compare(date, today) == :eq -> {"Today", time}
      Date.compare(date, yesterday) == :eq -> {"Yesterday", time}
      true -> {Calendar.strftime(date, "%-d %b"), time}
    end
  end
end
