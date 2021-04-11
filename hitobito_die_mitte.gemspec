$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your wagon's version:
require 'hitobito_die_mitte/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  # rubocop:disable SingleSpaceBeforeFirstArg
  s.name        = 'hitobito_die_mitte'
  s.version     = HitobitoDieMitte::VERSION
  s.authors     = ['Andreas Maierhofer']
  s.email       = ['maierhofer@puzzle.ch']
  s.summary     = 'Die Mitte organization specific features'
  s.description = 'Die Mitte organization specific features'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['Rakefile']
  s.test_files = Dir['test/**/*']
  s.add_runtime_dependency 'pg' # for migration
  s.add_runtime_dependency 'fuzzy-string-match' # for matching emails fuzz

  # rubocop:enable SingleSpaceBeforeFirstArg
end
