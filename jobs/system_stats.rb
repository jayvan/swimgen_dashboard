def get_cpu_usage
  (`uptime`.split(',')[-2].to_f * 100).round
end

def get_disk_usage
  `df`.lines[1].split(' ')[-2].to_i
end

def get_memory_usage
  used, free = `free`.lines[2].split(' ')[-2..-1].map(&:to_f)
  (100 * used / (used + free)).round(1)
end

SCHEDULER.every '15s' do
  send_event 'cpu_usage', { value: get_cpu_usage }
  send_event 'disk_usage', { value: get_disk_usage }
  send_event 'memory_usage', { value: get_memory_usage }
end
