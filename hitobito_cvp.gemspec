$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your wagon's version:
require 'hitobito_cvp/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  # rubocop:disable SingleSpaceBeforeFirstArg
  s.name        = 'hitobito_cvp'
  s.version     = HitobitoCvp::VERSION
  s.authors     = ['Andreas Maierhofer']
  s.email       = ['maierhofer@puzzle.ch']
  s.summary     = 'CVP organization specific features'
  s.description = 'CVP organization specific features'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['Rakefile']
  s.test_files = Dir['test/**/*']
  s.add_runtime_dependency 'pg' # for migration

  # rubocop:enable SingleSpaceBeforeFirstArg
end
