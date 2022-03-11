workspace 'RudderFirebase.xcworkspace'
use_frameworks!
inhibit_all_warnings!
platform :ios, '12.0'

def shared_pods
    pod 'RudderStack', :path => '~/Documents/Rudder/RudderStack-Cocoa/'
end

target 'RudderFirebase' do
    project 'RudderFirebase.xcodeproj'
    shared_pods
    pod 'Firebase/Analytics', '8.12.1'
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
