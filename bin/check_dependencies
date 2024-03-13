
#!/usr/bin/env ruby
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

require 'optparse'
require 'json'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: check_dependencies --lockPath LOCK_PATH --depWay DEP_WAY --configPath CONFIG_PATH"

  opts.on("--lockPath LOCK_PATH", "Specify the Podfile.lock path") do |lockPath|
    options[:lockPath] = lockPath
  end

  opts.on("--depWay DEP_WAY", "Specify the depWay parameter (path or branch)") do |depWay|
    options[:depWay] = depWay
  end

  # repo_configs examples
  config_string = <<~CONFIG
    repo_configs = {
      'Lib1' => {
        "branch" => "dev1",
        "path" => "/Users/xxxxxxxxx/xxxxlib",
        "git_url" => "xxxxxxxxxxxxxxxxxx"
      },
      'Lib2' => {
        "branch" => "dev2",
        "path" => "/Users/xxxxxxxxx/xxxxlib",
        "git_url" => "xxxxxxxxxxxxxxxxxx"
      },
      'Lib3' => {
        "branch" => "dev3",
        "path" => "/Users/xxxxxxxxx/xxxxlib",
        "git_url" => "xxxxxxxxxxxxxxxxxx"
      }
    }
  CONFIG
  
  opts.on("--configPath CONFIG_PATH", "Specify the path to repo_configs\n\n\n repo_configs examples:\n #{config_string}") do |configPath|
    options[:configPath] = configPath
  end
end.parse!

# Check if all required arguments were provided
if options[:lockPath].nil? || options[:depWay].nil? || options[:configPath].nil?
  puts "Please provide lockPath, depWay, and configPath parameters.\n  you can run:\n ruby MapHelper.rb --help "
  exit
end

# Function to read and parse the repo_configs.txt file
def read_repo_configs(config_path)
  content = File.read(config_path)
  eval(content) # Using eval to parse the Ruby hash from the file, be cautious with its use!
rescue
  puts "Failed to read or parse the repo_configs from #{config_path}"
  exit
end

repo_configs = read_repo_configs(options[:configPath])

# Calls before pod install complete
if options[:depWay] == "path"
    generate_map_path_podfiles(options[:lockPath], repo_configs)
elsif options[:depWay] == "branch"
    generate_map_branch_podfiles(options[:lockPath], repo_configs)
else
  puts "Invalid argument. Please provide 'path' or 'branch'."
end
