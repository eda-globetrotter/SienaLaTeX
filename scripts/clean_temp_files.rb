#!/usr/bin/ruby -w

=begin
	This is written by Zhiyang Ong for task automation.
 
	Synopsis:
	Script to remove all temporary files.
	
	Types of temporary files include:
	@ *~
	@ *.o
	@ *.out
	@ *.exe
	@ output files

 Revision History:
 1) Late Winter 2012. Updated script to clean temporary files
 with Mercurial distributed version control system (DVCS).
 2) November 25, 2013. Updated script for the Git DVCS.
 3) November 28, 2013. Updated script to remove temporary LaTeX files.
 4) February 19, 2014. Re-updated script for Mercurial.
 
 
 
 	The MIT License (MIT)
 
 	Copyright (c) <2014> <Zhiyang Ong>
 
 	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 	The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 	Email address: echo "-wb- cukj 23wU4X5M589 UNIX cqkz wM poiuy" | awk '{ sub("23wU4X5M589","F.d_c_b. "); print $5, $1,$6; for (i=1; i<=1; i++) print "6\b"; print $3, $2 }' | sed y/kqcbuwM6/gnotracm/ | tr -d [:cntrl:] | tr Fj " ""\n"
 =end





# -------------------------------------------------------------------

=begin
	Method to remove characters in an absolute path till the last slash.
	
	@param a_path -	Absolute path of filename
	@return Absolute path of the file's/subdirectory's directory
=end
def till_slash(f_path)
	# Remove characters from the absolute path till a "/" is encountered.
	loop {
		# If the last character of the absolute path is "/"
		if f_path[-1].chr == "/"
			# Exit indefinite loop
			break
		end
		
		# Remove a character following the "/" character
		f_path = f_path.chop
	}
	
	# Remove the "/" character
	f_path = f_path.chop
	
	# Return absolute path of the file's/subdirectory's directory
	return f_path
end




# -------------------------------------------------------------------

=begin
	Method to recursively remove temporary files
	
	@param s_dir -		The directory to commence recursive removal
						of temporary files.
	@param file_ext -	The set of file extensions considered.
	@return Nothing
=end
def remove_temp(s_dir, file_ext)	
	# For each file in this directory...
	for i in Dir.entries("#{s_dir}")
		temp_i = s_dir.concat("/")
		temp_i = s_dir.concat(i)
		# Is this file a directory?
		if File.directory?(temp_i)
			# Yes. Does this directory refers to the working or
			# previous directory?
			if temp_i[-1].chr.eql?(".")
				# Yes. Ignore it.
				### IMPORTANT ASSUMPTIONS
				# I assume that only two files end with periods.
				# Other files ending with periods are ignored
			else
				# No. This directory does not refer to the working
				# or previous directory. 
				# Recursively count the number of lines of code in
				# that directory.
				remove_temp(temp_i,file_ext)
				s_dir=till_slash(s_dir)
			end

			s_dir=till_slash(s_dir)
		# No. Is it a regular file?
		elsif File.file?(temp_i)

			# Is this file a temporary backup file?
			if temp_i[-1].chr.eql?("~")
				# Delete the file
				File.delete(temp_i)
				system("hg remove -f #{temp_i}")
#				system("git rm #{temp_i}")
			else
				# For each type of file extension
				for f_ext in file_ext
					# Does this file end with a specified file extension
					if (File.extname(temp_i)).eql?(f_ext)
						# Delete the file from repository and local file system.
						system("hg remove -f #{temp_i}")
#						system("git rm #{temp_i}")
						File.delete(temp_i)
						# Ignore remaining file extensions
						break
					end
				end
			end
			
			s_dir=till_slash(s_dir)

		# Else, ignore files that aren't regular nor directories.
		end
	end
end



# -------------------------------------------------------------------


# Current search/working directory: "binaries" directory
search_dir = Dir.pwd + "\/.."
#search_dir = Dir.pwd
# Types of source files
file_extension = [ ".aux", ".bbl", ".blg", ".gz", ".log", ".nav", ".nlo", ".o", ".out", ".txt", ".snm", ".toc", ".idx", ".ilg", ".ind", ".ddf", ".lof", ".lot", ".tdo" ]

# Start removing temporary files from the working directory
remove_temp(search_dir, file_extension)

#system("hg remove sizer")
#File.delete("sizer")

# Remove all generated output files
#system("rm ../outputs/*")