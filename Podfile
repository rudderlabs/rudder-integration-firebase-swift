source 'https://github.com/CocoaPods/Specs.git'
workspace 'RudderFirebase.xcworkspace'
use_frameworks!
inhibit_all_warnings!
platform :ios, '13.0'


target 'RudderFirebase' do
    project 'RudderFirebase.xcodeproj'
    pod 'Rudder', '~> 2.0'
    pod 'FirebaseAnalytics', '9.2.0'
end

target 'SampleAppObjC' do
    project 'Examples/SampleAppObjC/SampleAppObjC.xcodeproj'
    pod 'RudderFirebase', :path => '.'
end

target 'SampleAppSwift' do
    project 'Examples/SampleAppSwift/SampleAppSwift.xcodeproj'
    pod 'RudderFirebase', :path => '.'
end
