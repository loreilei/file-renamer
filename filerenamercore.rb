#!/usr/bin/ruby

def rename(dit_path, file_pattern, new_file_pattern)
	files_names = Dir.entries(dir_path)

	for file in files_names
		if match = file.match(/#{file_pattern}/i)
			data = match.captures
			new_filename = new_file_pattern.gsub("@episode_number@", data[0])
			file_extension = file.match(/(\.(.*))+$/i).captures[0]
			File.rename(dir_path + "/" + file, dir_path + "/" + new_filename + file_extension)
			puts "Renamed #{file} to #{new_filename}"
		end
	end
end