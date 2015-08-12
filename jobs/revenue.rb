require 'pg'

pg_info = {
  dbname: ENV['DB_NAME'],
  user: ENV['DB_USER'],
  password: ENV['DB_PASSWORD'],
  hostaddr: ENV['DB_HOST']
}

@pg = PG.connect(pg_info)

def get_reports_in_previous_span(hours)
  query = "SELECT COUNT(*) FROM reports WHERE created_at > current_timestamp AT TIME ZONE 'GMT' - interval '#{hours} hours' AND created_at > current_timestamp AT TIME ZONE 'GMT' - interval '#{hours} hours'"
  @pg.query(query)[0]['count'].to_i
end

def get_reports_in_span(hours)
  query = "SELECT COUNT(*) FROM reports WHERE created_at > current_timestamp AT TIME ZONE 'GMT' - interval '#{hours} hours'"
  @pg.query(query)[0]['count'].to_i
end

def get_revenue_for_span(hours)
  return {
    current: get_reports_in_span(hours) / 10,
    last: get_reports_in_previous_span(hours) / 10
  }
end

SCHEDULER.every '5m', :first_in => 0 do
  send_event 'daily_revenue', get_revenue_for_span(24)
end

SCHEDULER.every '1d', :first_in => 10 do
  send_event 'quarterly_revenue', get_revenue_for_span(2190)
end

SCHEDULER.every '1d', :first_in => 30 do
  send_event 'annual_revenue', get_revenue_for_span(8760)
end
