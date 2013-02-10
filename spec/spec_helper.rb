require 'rspec'

$:.unshift(File.expand_path("../..", __FILE__))
$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'scry'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.before(:each) do
    @fixture_path = Pathname.new(File.expand_path('../fixtures/', __FILE__))
    ENV['SCRYFILE'] = File.join(@fixture_path, 'Scryfile')
  end

end
