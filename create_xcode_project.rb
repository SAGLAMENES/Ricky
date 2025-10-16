#!/usr/bin/env ruby

require 'xcodeproj'

project_path = 'RickyApp.xcodeproj'
project = Xcodeproj::Project.new(project_path)

# Create main target
target = project.new_target(:application, 'RickyApp', :ios, '15.0')

# Add source files
app_group = project.new_group('RickyApp')
app_group.set_source_tree('SOURCE_ROOT')
app_group.set_path('RickyApp/RickyApp')

# Add Swift files
swift_files = [
  'RickyApp/RickyApp/RickyAppApp.swift',
  'RickyApp/RickyApp/ContentView.swift',
  'RickyApp/RickyApp/VM/CharacterListViewModel.swift',
  'RickyApp/RickyApp/VM/LocationListViewModel.swift',
  'RickyApp/RickyApp/View/CharacterListView.swift',
  'RickyApp/RickyApp/View/CharacterDetailView.swift',
  'RickyApp/RickyApp/View/LocationListView.swift',
  'RickyApp/RickyApp/View/LocationDetailView.swift'
]

swift_files.each do |file_path|
  file_ref = app_group.new_file(file_path)
  target.add_file_references([file_ref])
end

# Add assets
assets_ref = app_group.new_file('RickyApp/RickyApp/Assets.xcassets')
target.resources_build_phase.add_file_reference(assets_ref)

# Set build settings
target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.burakarslan.RickyApp'
  config.build_settings['SWIFT_VERSION'] = '6.0'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
  config.build_settings['INFOPLIST_FILE'] = 'RickyApp/RickyApp/Info.plist'
end

project.save

puts "Xcode project created successfully at #{project_path}"
