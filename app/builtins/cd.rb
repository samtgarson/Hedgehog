unless Hedgehog::Settings
         .shared_instance
         .disabled_built_ins
         .map(&:to_s)
         .include?("cd")

  function "cd" do |args|
    begin
      Dir.chdir(args.to_s.gsub("~", "#{ENV['HOME']}"))
    rescue Exception => e
      puts e.to_s.gsub(" @ dir_s_chdir", "")
    end
  end

end
