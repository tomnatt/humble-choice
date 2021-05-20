require './lib/humble_choice_generator'

# Generate everything with output
task :generate do
  puts 'Generating...'
  hc = HumbleChoiceGenerator.new
  hc.generate

  system "grep -B3 --color -e 'steam_id: $' output/humble-choice-20*"
  puts '--'
  system "for file in output/humble-choice-20* ; do echo \"$file: \"; grep -e 'steam_id: $' $file | wc -l ; done"
end

# Generate everything silently
task :default do
  hc = HumbleChoiceGenerator.new
  hc.generate
end
