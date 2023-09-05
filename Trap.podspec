Pod::Spec.new do |s|

  s.name = 'Trap'
  s.version = '1.0.0'
  s.summary = 'Sensor and peripheral collection library for iOS'
  s.homepage = 'https://github.com/cursorinsight/ci-trap-ios'
  s.source = { :git => 'https://github.com/cursorinsight/ci-trap-ios.git', :tag => s.version }
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { 'Cursor Insight Ltd' => 'hello@cursorinsight.com' }
  
  s.swift_version = '5.1'
  s.ios.deployment_target = '13.0'

  s.source_files = 'Sources/Trap/**/*.swift'

end
