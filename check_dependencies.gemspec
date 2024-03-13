Gem::Specification.new do |spec|
  spec.name          = "check_dependencies"
  spec.version       = "0.1.1"
  spec.authors       = ["ITxiansheng"]
  spec.email         = ["itxiansheng@gmail.com"]

  spec.summary       = %q{check all dependencies}
  spec.description   = %q{Long description of your gem}
  spec.homepage      = "https://github.com/ITxiansheng/check_dependencies"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # 添加依赖
  spec.add_dependency "bundler", "~> 2.0"
  spec.add_dependency "rake", "~> 13.0"
end
