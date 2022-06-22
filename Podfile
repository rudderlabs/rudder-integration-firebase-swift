source 'https://github.com/CocoaPods/Specs.git'
workspace 'RudderFirebase.xcworkspace'
use_frameworks!
inhibit_all_warnings!
platform :ios, '13.0'

def shared_pods
    pod 'Rudder', '~> 2.1.0'
end

target 'RudderFirebase' do
    project 'RudderFirebase.xcodeproj'
    shared_pods
    pod 'Firebase/Analytics', '8.15.0'
end

target 'SampleAppObjC' do
    project 'Examples/SampleAppObjC/SampleAppObjC.xcodeproj'
    shared_pods
    pod 'RudderFirebase', :path => '.'
end

target 'SampleAppSwift' do
    project 'Examples/SampleAppSwift/SampleAppSwift.xcodeproj'
    shared_pods
    pod 'RudderFirebase', :path => '.'
end
