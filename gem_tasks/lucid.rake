require 'lucid/rake/task'
require 'lucid/platform'

class Lucid::Rake::Task
  def set_profile_for_current_ruby
    self.profile = if Lucid::JRUBY
      Lucid::WINDOWS ? 'jruby_win' : 'jruby'
    elsif Lucid::WINDOWS_MRI
      'windows_mri'
    elsif Lucid::RUBY_1_9
      'ruby_1_9'
    elsif Lucid::RUBY_2_0
      'ruby_2_0'
    end
  end
end

Lucid::Rake::Task.new(:features) do |t|
  t.fork = false
  t.set_profile_for_current_ruby
end

Lucid::Rake::Task.new(:legacy_features) do |t|
  t.fork = false
  t.cucumber_opts = %w{legacy_features}
  t.set_profile_for_current_ruby
end

task :cucumber => [:features, :legacy_features]
