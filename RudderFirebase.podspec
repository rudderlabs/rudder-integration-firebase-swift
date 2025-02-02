Pod::Spec.new do |s|
    s.name             = 'RudderFirebase'
    s.version          = '1.3.0'
    s.summary          = 'Privacy and Security focused Segment-alternative. Firebase Native SDK integration support.'
    s.description      = <<-DESC
    Rudder is a platform for collecting, storing and routing customer event data to dozens of tools. Rudder is open-source, can run in your cloud environment (AWS, GCP, Azure or even your data-centre) and provides a powerful transformation framework to process your event data on the fly.
    DESC
    s.homepage         = 'https://github.com/rudderlabs/rudder-integration-firebase-swift'
    s.license          = { :type => "Apache", :file => "LICENSE.md" }
    s.author           = { 'RudderStack' => 'arnab@rudderlabs.com' }
    s.source           = { :git => 'https://github.com/rudderlabs/rudder-integration-firebase-swift.git' , :tag => "v#{s.version}"}
    
    s.ios.deployment_target = '13.0'
    s.osx.deployment_target   = '10.13'
    s.tvos.deployment_target  = '12.0'

    s.source_files = 'Sources/**/*{h,m,swift}'
    s.module_name = 'RudderFirebase'
    s.static_framework = true
    s.swift_version = '5.3'

    s.dependency 'Rudder', '~> 2.0'
    s.dependency 'FirebaseAnalytics', '10.28.0'
end
