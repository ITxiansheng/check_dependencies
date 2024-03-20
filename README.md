```markdown
# check_dependencies Gem

check_dependencies Gem is a Ruby gem that offers utilities to assist in managing CocoaPods dependencies within iOS projects. This gem provides functionality to dynamically switch between local path-based dependencies and remote git branch-based dependencies.

## Installation

Install the gem by adding it to your Gemfile:

```bash
gem 'check_dependencies', git: 'https://github.com/ITxiansheng/check_dependencies.git'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install check_dependencies
```

Remember to add GEM_BIN_DIR to your PATH.

you can run :
```bash
 curl -sSL https://raw.githubusercontent.com/ITxiansheng/check_dependencies/main/gem_env_install.sh | bash
 ```

## Usage

The gem provides a command-line interface for interacting with its functionalities. You can use the `check_dependencies` command followed by appropriate options.
```bash
check_dependencies --help
``` 
### Command Syntax

```bash
check_dependencies --lockPath LOCK_PATH --depWay DEP_WAY --configPath CONFIG_PATH
```

### Options

- `--lockPath LOCK_PATH`: Specifies the path to your Podfile.lock file.
- `--depWay DEP_WAY`: Specifies the dependency mode. This can be either `path` for local path dependencies or `branch` for remote git branch dependencies.
- `--configPath CONFIG_PATH`: Specifies the path to the configuration file containing dependency configurations.

### Example

```bash
check_dependencies --lockPath ./Podfile.lock --depWay path --configPath ./repo_configs.txt
```

## Functions Overview

The gem provides the following key functionalities:

- Parsing `Podfile.lock` content to extract pod dependencies.
- Generating Podfile entries for local path or remote git branch dependencies.
- Processing and formatting dependencies for correct integration into Podfiles.

## Workflow

1. **Configuration Preparation**: Prepare the `repo_configs` file with the necessary configuration for each library. This file should map library names to their configuration, including local path, branch name, and git URL.

2. **Running the Gem**: Execute the gem with the required options. Based on the specified `depWay`, the gem will process the `Podfile.lock` file and the `repo_configs` to output the necessary Podfile entries.

3. **Integration**: After generating the Podfile entries, integrate them into your Podfile as needed. This allows you to switch between using local versions of libraries (for development or debugging) and their remote versions (for production or shared development).

## Note

- Ensure that the `repo_configs` file is properly formatted and from a trusted source to avoid potential security risks.

## Contributing

Bug reports and pull requests are welcome on GitHub at [example/check_dependencies](https://github.com/ITxiansheng/check_dependencies). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/ITxiansheng/check_dependencies/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
```

This README provides an overview of the gem's installation, usage, functions, workflow, notes, contributing guidelines, and license information. Adjust as needed for your specific project and preferences.
