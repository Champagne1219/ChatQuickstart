# source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '13.0'

target 'ChatQuickstart' do
  use_frameworks!
  pod 'EaseChatUIKit','4.11.1'
  pod 'HyphenateChat','4.12.0'
  pod 'KakaJSON', '~> 1.1.2'
  pod 'SwiftFFDBHotFix'
  pod 'FMDB','2.7.11'
end

post_install do |installer|
    installer.generated_projects.each do |project|
      project.targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "13.0"
          config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
          # config.build_settings["DEVELOPMENT_TEAM"] = "JC854K845H"
      end
    end
  end
end
