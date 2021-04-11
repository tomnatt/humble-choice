task :default do
  system 'bundle exec ruby lib/generate.rb'
end

task :generate do
  puts 'Generating...'
  system 'bundle exec ruby lib/generate.rb'
  system "grep -B3 --color -e 'steam_id: $' output/humble-choice-20*"
  puts '--'
  system "for file in output/humble-choice-20* ; do echo \"$file: \"; grep -e 'steam_id: $' $file | wc -l ; done"
end
