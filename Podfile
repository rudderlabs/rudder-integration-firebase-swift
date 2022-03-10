workspace 'RudderFirebase.xcworkspace'
use_frameworks!
inhibit_all_warnings!
platform :ios, '10.0'

def shared_pods
    pod 'Rudder', :path => '~/Documents/Rudder/RudderStack-Cocoa/'
end

target 'SampleiOSObjC' do
    project 'Examples/SampleiOSObjC/SampleiOSObjC.xcodeproj'
    shared_pods
    pod 'RudderFirebase', :path => '.'
end

target 'RudderFirebase' do
    project 'RudderFirebase.xcodeproj'
    shared_pods
    pod 'Firebase/Analytics', '8.12.1'
end
