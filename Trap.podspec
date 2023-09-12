Pod::Spec.new do |s|
  
  $version = ENV["GITHUB_REF_NAME"]
  if $version == nil
    $version = '0.0.0-local'
  end

  s.name = 'Trap'
  s.version = $version
  s.summary = 'Sensor and peripheral collection library for iOS'
  s.homepage = 'https://github.com/cursorinsight/ci-trap-ios'
  s.source = { :git => 'https://github.com/cursorinsight/ci-trap-ios.git', :tag => s.version }
  s.license = { :type => "MIT" }
  s.author = { 'Cursor Insight Ltd' => 'hello@cursorinsight.com' }
  
  s.swift_version = '5.4.2'
  s.ios.deployment_target = '13.0'

  s.source_files = 'Sources/Trap/**/*.swift'

end
