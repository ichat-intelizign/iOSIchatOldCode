source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

def shared_pods
  # Crash Report
  pod 'Fabric'
  pod 'Crashlytics'
  
  # Code utilities
  pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git', :tag => '4.0.0-alpha.1'
  pod 'semver', :git => 'https://github.com/rafaelks/Semver.Swift.git', :branch => 'chore/swift4'

  # UI
  pod 'SideMenuController', :git => 'https://github.com/rafaelks/SideMenuController.git'
  pod 'SlackTextViewController', :git => 'https://github.com/rafaelks/SlackTextViewController.git', :branch => 'master'
  pod 'MobilePlayer'
  pod 'SimpleImageViewer', :git => 'https://github.com/cardoso/SimpleImageViewer.git'

  # Text Processing
  pod 'RCMarkdownParser'
  pod 'Fontello-Swift'

  # Database
  pod 'RealmSwift'
  pod 'SZMentionsSwift'
  # Network
  pod 'SDWebImage', '~> 4'
  pod 'SDWebImage/GIF'
  pod 'Starscream'
  pod 'ReachabilitySwift'
  
  # Authentication SDKs
  pod 'JVFloatLabeledTextField'
  pod 'IQKeyboardManagerSwift'
  pod 'OAuthSwift'
  pod '1PasswordExtension'
  pod 'Google/SignIn'
  pod 'SwiftLint'
end

target 'iChat' do
  # Shared pods
  shared_pods
end

target 'iChatTests' do
  # Shared pods
  shared_pods
end

post_install do |installer|
  swift4Targets = ['OAuthSwift']
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.1'
    end
    if swift4Targets.include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.0'
      end
    end
  end
end
