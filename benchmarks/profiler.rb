require "dry-initializer"
require "ruby-prof"
require "fileutils"

class User
  extend Dry::Initializer

  param  :first_name,  proc(&:to_s), default: proc { "Unknown" }
  param  :second_name, proc(&:to_s), default: proc { "Unknown" }
  option :email,       proc(&:to_s), optional: true
  option :phone,       proc(&:to_s), optional: true
end

result = RubyProf.profile do
  User.new :Andy, email: :"andy@example.com"
end

FileUtils.mkdir_p "./tmp"
FileUtils.touch "./tmp/profile.dot"
File.open("./tmp/profile.dot", "w+") do |output|
  RubyProf::DotPrinter.new(result).print(output, min_percent: 0)
end
