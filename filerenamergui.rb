require 'rubygems'
require 'launchy'
require 'Qt4'

class FileRenamerGui < Qt::Widget

	slots 'updateDirName(const QString&)', 'updateDirView()', 'checkParameters()', 'openRegexDrafts()', 'rename()'

	def initialize(parent = nil)
		super(parent)
		self.setWindowTitle('File Renamer')
		@layout = Qt::GridLayout.new
		
		@dir_path_chooser = Qt::FileDialog.new
		@dir_path_chooser.setFileMode(Qt::FileDialog::Directory)
		@dir_path = Qt::LineEdit.new
		@dir_path_content = Qt::FileSystemModel.new
		@dir_path_content_view = Qt::ListView.new
		@dir_path_content_view.setModel(@dir_path_content)
		@file_pattern = Qt::LineEdit.new
		@file_pattern.setPlaceholderText('Filename Pattern')
		@new_file_pattern = Qt::LineEdit.new
		@new_file_pattern.setPlaceholderText('New Filename Pattern')
		@group_place = Qt::LineEdit.new
		@group_place.setPlaceholderText('Group Identifier in new filename')
		
		
		dir_path_chooser_label = Qt::Label.new('Directory path: ')
		dir_path_chooser_dialog = Qt::PushButton.new('Choose Directory')
		file_pattern_label = Qt::Label.new('Filename Pattern: ')
		new_file_pattern_label = Qt::Label.new('New Filename Pattern: ')
		group_place_label = Qt::Label.new('Group Place identifier in new filename: ')
		
		@start_button = Qt::PushButton.new('Start renaming')
		@start_button.setEnabled(false)
		
		@regex_button = Qt::PushButton.new('Regular expression drafts tryouts')
		
		@console = Qt::ListWidget.new
				
		@layout.addWidget(dir_path_chooser_label,0,0)
		@layout.addWidget(@dir_path,0,1)
		@layout.addWidget(dir_path_chooser_dialog,0,2)
		@layout.addWidget(file_pattern_label,2,0)
		@layout.addWidget(@dir_path_content_view,1,0,1,3)
		@layout.addWidget(@file_pattern,2,1,1,2)
		@layout.addWidget(group_place_label,3,0)
		@layout.addWidget(@group_place,3,1,1,2)
		@layout.addWidget(new_file_pattern_label,4,0)
		@layout.addWidget(@new_file_pattern,4,1,1,2)
		
		@layout.addWidget(@regex_button,5,1)
		@layout.addWidget(@start_button,5,2)
		@layout.addWidget(@console,6,0,1,3)
		
		self.setLayout(@layout)
		
		Qt::Object::connect(dir_path_chooser_dialog, SIGNAL('clicked()'), @dir_path_chooser, SLOT('show()'))
		Qt::Object::connect(@dir_path_chooser, SIGNAL('fileSelected(const QString&)'), self, SLOT('updateDirName(const QString&)'))
		Qt::Object::connect(@dir_path, SIGNAL('editingFinished()'), self, SLOT('checkParameters()'))
		Qt::Object::connect(@dir_path, SIGNAL('editingFinished()'), self, SLOT('updateDirView()'))
		Qt::Object::connect(@file_pattern, SIGNAL('editingFinished()'), self, SLOT('checkParameters()'))
		Qt::Object::connect(@new_file_pattern, SIGNAL('editingFinished()'), self, SLOT('checkParameters()'))
		Qt::Object::connect(@group_place, SIGNAL('editingFinished()'), self, SLOT('checkParameters()'))
		Qt::Object::connect(@start_button, SIGNAL('clicked()'), self, SLOT('rename()'))
		Qt::Object::connect(@regex_button, SIGNAL('clicked()'), self, SLOT('openRegexDrafts()'))
	end
	
	def openRegexDrafts
		Launchy.open('http://rubular.com/')
	end
	
	def updateDirName(path)
		@dir_path.setText(path)
		@dir_path.editingFinished()
	end
	
	def updateDirView
		@dir_path_content.setRootPath(@dir_path.text())
		@dir_path_content_view.setRootIndex(@dir_path_content.index(@dir_path.text()))
	end
	
	def checkParameters
		valid = true
		valid = valid && not(@file_pattern.text().empty?) && @file_pattern.text().match(/(\([^\)\(]+\)){1}/)
		valid = valid && not(@new_file_pattern.text().empty?)
		valid = valid && not(@group_place.text().empty?)
		valid = valid && not(@dir_path.text().empty?) && Qt::Dir.new(@dir_path.text()).exists()
		@start_button.setEnabled(valid)
	end
	
	def rename
		@console.clear()
		dir_path = @dir_path.text()
		file_pattern = @file_pattern.text()
		new_file_pattern = @new_file_pattern.text()
		episode_number_placeholder = @group_place.text()
		
		files_names = Dir.entries(dir_path)

		for file in files_names
			if match = file.match(/#{file_pattern}/i)
				data = match.captures
				new_filename = new_file_pattern.gsub(episode_number_placeholder, data[0])
				file_extension = file.match(/(\.(.*))+$/i, file.rindex(".")-1).captures[0]
				puts dir_path + "/" + file
				puts dir_path + "/" + new_filename + file_extension
				puts file_extension
				File.rename(dir_path + "/" + file, dir_path + "/" + new_filename + file_extension)
				#puts "Renamed #{file} to #{new_filename}"
				@console.addItem("Renamed #{file} to #{new_filename}")
			end
		end
	end
end

app = Qt::Application.new(ARGV)

frg = FileRenamerGui.new

frg.show

app.exec