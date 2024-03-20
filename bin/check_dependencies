
#!/usr/bin/env ruby
# Usage Hint
require 'optparse'
require 'json'
require 'set'

# Method to check for required options and print usage if missing
def check_required_options(options, required_keys, parser)
  missing_options = required_keys.select { |key| options[key].nil? }
  unless missing_options.empty?
    puts "Missing required options: #{missing_options.join(', ')}"
    puts parser
    exit
  end
end

# Define and parse options based on the command
options = {}
global_options = OptionParser.new do |opts|
  opts.banner = "Usage: script.rb [command] [options]"
  opts.separator ""
  opts.separator "Commands:"
  opts.separator "  gen_pod: Generate podfile entries for new dependencies"
  opts.separator "  dif_pod: Generate differences between Podfile.lock files"
  opts.separator ""
  opts.separator "For command-specific help, run: check_dependencies [command] --help"
end

gen_pod_config_string = <<~CONFIG
{
  "A": {
    "branch": "release",
    "path": "XXXXXXXXXXXXXXX",
    "git_url": "XXXXXXXXXXXXXXX"
  },
  "B": {
    "branch": "release",
    "path": "XXXXXXXXXXXXXXX",
    "git_url": "XXXXXXXXXXXXXXX"
  },
}
CONFIG

dif_pod_config_string = <<~CONFIG
[
  "A",
  "B"
]
CONFIG


command = ARGV.shift
case command
when "gen_pod"
command_options = OptionParser.new do |opts|
    opts.banner = "Usage: gen_pod --lockPath LOCK_PATH --depWay DEP_WAY [--configPath CONFIG_PATH]"
    opts.on("--lockPath LOCK_PATH", String, "Specify the Podfile.lock path") { |v| options[:lockPath] = v }
    opts.on("--depWay DEP_WAY", String, "Specify the depWay parameter (path or branch)") { |v| options[:depWay] = v }
    opts.on("--configPath CONFIG_PATH", String, "Specify the path to repo_configs\n\n\n repo_configs examples:\n#{gen_pod_config_string}") { |v| options[:configPath] = v }
  end.parse!(ARGV)
  check_required_options(options, [:lockPath, :depWay, :configPath], command_options)

when "dif_pod"
  command_options = OptionParser.new do |opts|
    opts.banner = "Usage: dif_pod --oldLockPath OLD_LOCK_PATH --newLockPath NEW_LOCK_PATH [--configPath CONFIG_PATH]"
    opts.on("--oldLockPath OLD_LOCK_PATH", String, "Specify old Podfile.lock path") { |v| options[:oldLockPath] = v }
    opts.on("--newLockPath NEW_LOCK_PATH", String, "Specify new Podfile.lock path") { |v| options[:newLockPath] = v }
    opts.on("--configPath CONFIG_PATH", String, "Specify the path of conf which contains dif libs (optional) \n\n\n repo_configs examples:\n#{dif_pod_config_string}") { |v| options[:configPath] = v }
  end.parse!(ARGV)
  check_required_options(options, [:oldLockPath, :newLockPath], command_options)

else
  puts global_options
  exit
end


# Analyzes the Podfile.lock content to extract pod dependencies
def analyze_podfile_lock(podfile_lock_content)
  unless podfile_lock_content.is_a?(String)
    raise ArgumentError, 'podfile_lock_content must be a string.'
  end

  pods_section_match = podfile_lock_content.match(/^PODS:\n(.*?)(?=\n\n|\z)/m)
  if pods_section_match
    pods_section_content = pods_section_match[1]
    pods_lines = pods_section_content.split("\n")
    pods_lines.map(&:strip)
  else
    raise 'PODS section not found in the provided Podfile.lock content.'
  end
end

# Reads the local Podfile.lock content
def read_local_podfile_lock(file_path)
  unless File.exist?(file_path)
    raise "File not found: #{file_path}"
  end
  
  podfile_lock_content = File.read(file_path)
  analyze_podfile_lock(podfile_lock_content)
end

# Extracts unique specs from dependencies
def extract_unique_dependencies(pods)
  unless pods.is_a?(Array)
    raise ArgumentError, 'Input must be an array.'
  end

  return [] if pods.empty?

  unique_repositories = pods.each_with_object([]) do |dependency, unique|
    repo_name = dependency.split('(').first.strip
    cleaned_repo_name = repo_name.gsub(/- /, '')
    unique << cleaned_repo_name unless unique.include?(cleaned_repo_name)
  end

  unique_repositories
end

# Finds the shortest paths for dependencies
def find_shortest_paths(paths)
  raise ArgumentError, 'Input must be an array' unless paths.is_a?(Array)
  return [] if paths.empty?
  raise ArgumentError, 'All elements in the array must be strings' unless paths.all? { |path| path.is_a?(String) }

  shortest_paths = []
  paths.each do |path|
    is_shortest = true
    paths.each do |other_path|
      if path != other_path && other_path.start_with?(path)
        is_shortest = false
        break
      end
    end
    shortest_paths << path if is_shortest
  end
  shortest_paths
end

# Builds all subspecs dependencies for a repo
def generate_repo_subspecs(repo,unique_repositories)
    repo_subspecs = {}
    unique_repositories.select { |dependency| dependency.start_with?(repo) }.each do |dependency|
        if repo_subspecs.key?(repo)
          repo_subspecs[repo] << dependency
        else
          repo_subspecs[repo] = [dependency]
        end
    end
    return repo_subspecs
end

# Generates Podfile entry for path dependency
def generate_path_podfile_entry(lib,subspecs, base_path)
  sub_specs = subspecs.map { |path| path.split('/', 2).last }.uniq
  return "pod '#{lib}', :path => '#{base_path}'" if sub_specs.length <= 1
  podfile_entry = "pod '#{lib}', :path => '#{base_path}', :subspecs => [\n"
  sub_specs.each_with_index do |path, index|
    subspec = path.gsub("#{lib}/", '')
    podfile_entry << "  '#{subspec}'"
    podfile_entry << "," unless index == sub_specs.length - 1
    podfile_entry << "\n"
  end
  podfile_entry << "]"
  podfile_entry
end

# Generates Podfile entry for branch dependency
def generate_branch_podfile_entry(lib,subspecs, git_url, branch)
  sub_specs = subspecs.map { |path| path.split('/', 2).last }.uniq
  return "pod '#{lib}', :git => '#{git_url}', :branch => '#{branch}'" if sub_specs.length <= 1
  podfile_entry = "pod '#{lib}', :git => '#{git_url}', :branch => '#{branch}', :subspecs => [\n"
  sub_specs.each_with_index do |path, index|
    subspec = path.gsub("#{lib}/", '')
    podfile_entry << "  '#{subspec}'"
    podfile_entry << "," unless index == sub_specs.length - 1
    podfile_entry << "\n"
  end
  podfile_entry << "]"
  podfile_entry
end

# Generates all branch dependencies
def generate_map_branch_podfiles(lockPath, repo_configs)
  raise ArgumentError, 'lockPath must be a string.' unless lockPath.is_a?(String)
  raise ArgumentError, 'repo_configs must be a hash.' unless repo_configs.is_a?(Hash)

  dependencies = read_local_podfile_lock(lockPath)
  unique_dependencies = extract_unique_dependencies(dependencies)
  # Throws an exception if unique_dependencies is empty
  raise 'No unique dependencies found. Please check your Podfile.lock content and repo_configs.' if unique_dependencies.empty?

  puts "====branch dependencies===="
  podfile_entrys = []
  repo_configs.each do |key, value|
    next unless value.is_a?(Hash) && value.key?("git_url") && value.key?("branch")

    git_url = value["git_url"]
    branch = value["branch"]
    repo_subspecs = generate_repo_subspecs(key, unique_dependencies)
    repo_shortest_subspecs = find_shortest_paths(repo_subspecs[key])
    # Generates Podfile entry
    podfile_entry = generate_branch_podfile_entry(key, repo_shortest_subspecs, git_url, branch)
    podfile_entrys << podfile_entry
  end
  puts podfile_entrys.join("\n")
  podfile_entrys.join("\n")
end

# Generates all path dependencies
def generate_map_path_podfiles(lockPath, repo_configs)
  raise ArgumentError, 'lockPath must be a string.' unless lockPath.is_a?(String)
  raise ArgumentError, 'repo_configs must be a hash.' unless repo_configs.is_a?(Hash)

  pods = read_local_podfile_lock(lockPath)
  unique_dependencies = extract_unique_dependencies(pods)

  # Throws an exception if unique_dependencies is empty
  raise 'No unique dependencies found. Please check your Podfile.lock content and repo_configs.' if unique_dependencies.empty?

  puts "====path dependencies===="
  podfile_entrys = []
  repo_configs.each do |key, value|
    next unless value.is_a?(Hash) && value.key?("path")

    path = value["path"]
    repo_subspecs = generate_repo_subspecs(key, unique_dependencies)
    repo_shortest_subspecs = find_shortest_paths(repo_subspecs[key])
    # Generates Podfile entry
    podfile_entry = generate_path_podfile_entry(key, repo_shortest_subspecs, path)
    podfile_entrys << podfile_entry
  end
  puts podfile_entrys.join("\n")
  podfile_entrys.join("\n")
end


def colorize(text, color_code)
  "\e[#{color_code}m#{text}\e[0m"
end
def red(text); colorize(text, 31); end
def green(text); colorize(text, 32); end

def read_json_array_from_file_as_set(file_path)
  # 确保文件存在
  if File.exist?(file_path)
    # 读取文件内容
    file_content = File.read(file_path)
    # 解析 JSON 字符串为 Ruby 数组
    json_array = JSON.parse(file_content)
    # 将数组转换为 Set 并返回
    return json_array.to_set
  else
    puts "File not found: #{file_path}"
    exit
  end
rescue JSON::ParserError => e
  puts "Error parsing JSON from #{file_path}: #{e.message}"
  exit
end

def compare_podfile_locks(old_lock_path, new_lock_path, config_path = nil)
  config_set = read_json_array_from_file_as_set(config_path)
  
  old_pods = read_local_podfile_lock(old_lock_path)
  new_pods = read_local_podfile_lock(new_lock_path)

  old_unique_deps = find_shortest_paths(extract_unique_dependencies(old_pods)).to_set
  new_unique_deps = find_shortest_paths(extract_unique_dependencies(new_pods)).to_set
  if !config_set.empty?
      old_unique_deps = old_unique_deps.select { |dep| config_set.include?(dep.split('/').first) }
      new_unique_deps = new_unique_deps.select { |dep| config_set.include?(dep.split('/').first) }
  end
  only_in_old = old_unique_deps - new_unique_deps
  only_in_new = new_unique_deps - old_unique_deps
  
  # 检查差异并决定退出状态
  if only_in_old.empty? && only_in_new.empty?
    puts "没有差异，成功退出"
    exit 0
  else
    puts "存在差异："
    only_in_old.each { |dep| puts "#{red('-')} #{dep}" }
    only_in_new.each { |dep| puts "#{green('+')} #{dep}" }
    exit 1
  end
end

if command == "gen_pod"
    file_content = File.read(options[:configPath])
    puts file_content
    repo_configs =JSON.parse(file_content)
    puts repo_configs
    # Calls before pod install complete
    if options[:depWay] == "path"
        generate_map_path_podfiles(options[:lockPath], repo_configs)
    elsif options[:depWay] == "branch"
        generate_map_branch_podfiles(options[:lockPath], repo_configs)
    else
      puts "Invalid argument. Please provide 'path' or 'branch'."
    end
elsif command == "dif_pod"
  compare_podfile_locks(options[:oldLockPath], options[:newLockPath], options[:configPath])
end

