# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'MotorcycleLoan' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!

  # Pods for MotorcycleLoan
  pod 'YYText', '~> 1.0.7'
  pod 'R.swift', '~> 7.3.2'
  pod 'SnapKit', '~> 5.6.0'
  pod 'WisdomHUD', '~> 0.3.5'
  pod 'Alamofire', '~> 5.8.1'
  pod 'SwiftyRSA', '~> 1.7.0'
  pod 'Kingfisher', '~> 7.9.1'
  pod 'CryptoSwift', '~> 1.8.2'
  pod 'SwiftPageView', '~> 0.9.0'
  pod 'DYFCryptoUtils', '~> 1.0.2'
  pod 'KeychainAccess', '~> 4.2.2'
  
  pod 'FirebaseAnalytics'
  pod 'FirebaseCrashlytics'
  
  pod 'IQKeyboardManagerSwift', '~> 7.0.2'
  pod 'AAINetwork', :http => 'https://prod-guardian-cv.oss-ap-southeast-5.aliyuncs.com/sdk/iOS-libraries/AAINetwork/AAINetwork-V1.0.1.tar.bz2', type: :tbz
  pod 'AAILiveness', :http => 'https://prod-guardian-cv.oss-ap-southeast-5.aliyuncs.com/sdk/iOS-liveness-detection/3.0.4/iOS-Liveness-SDK-V3.0.4.tar.bz2', type: :tbz

  post_install do |installer|
    installer.generated_projects.each do |project|
      project.targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        end
      end
    end
  end

  target 'MotorcycleLoanTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'MotorcycleLoanUITests' do
    # Pods for testing
  end

end
