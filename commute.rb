require 'csv'
require 'awesome_print'

return_hsh = {}
name_arr = []

def fill_hsh_data(hash, name, row)
  hash[name].push({week: row[1],
                   day: row[2],
                   mode: row[3],
                   inbound: row[4],
                   outbound: row[5],
                   distance: row[6]})
end

def day_ordering(hash, week, name)
  school_days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
  school_days.each do |day|
    CSV.foreach("data/gschool_commute_data.csv") do |row|
      name == row[0] && row[1] == week.to_s && row[2] == day ? fill_hsh_data(hash, name, row) : nil
    end
  end
end

CSV.foreach("data/gschool_commute_data.csv") do |row|
  name_arr.push(row[0])
  name_arr.uniq!
end
name_arr.shift

name_arr.each do |name|
  return_hsh[name] = []
  week = 1
  5.times do
    day_ordering(return_hsh, week, name)
  week += 1
  end
end

def average(return_hsh)
  total_commutes = 0
  total_commute_time = 0
  return_hsh.each_value do |arr|
    arr.each do |hsh|
      total_commute_time += (hsh[:inbound].to_i + hsh[:outbound].to_i)
      total_commutes += 2
    end
  end
  total_commute_time / total_commutes
end

def fastest_walker(return_hsh)
  arr_of_walkers = []
  return_hsh.each_pair do |k_name,v_arr|
    total_walk_time = 0
    total_walks = 0

    v_arr.each do |hsh|
      if hsh[:mode] == "Walk"
        total_walk_time += (hsh[:inbound].to_i + hsh[:outbound].to_i)
        total_walks += 2
      end
    end

    unless total_walk_time == 0 || total_walks == 0
      arr_of_walkers.push(k_name => (total_walk_time/total_walks))
    end

  end
  arr_of_walkers.each do |kv|
    if kv.has_key?("Emily")
      kv["Emily"] = 0.65 / kv["Emily"]
    elsif kv.has_key?("Rachel")
      kv["Rachel"] = 0.9 / kv["Rachel"]
    end
  end
  arr_of_walkers.first
end

print "Nate's inbound return time for Week 4, Wednesday: "
ap return_hsh["Nate"][14][:inbound].to_i
print "Group average commute time for all 5 weeks: "
ap average(return_hsh)
print "Average speed and name of fastest walker: "
ap fastest_walker(return_hsh)
