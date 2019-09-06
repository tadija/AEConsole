Pod::Spec.new do |s|

s.name = 'AEConsole'
s.version = '0.7.0'
s.license = { :type => 'MIT', :file => 'LICENSE' }
s.summary = 'Customizable Console UI overlay with debug log on top of your iOS App'

s.source = { :git => 'https://github.com/tadija/AEConsole.git', :tag => s.version }
s.source_files = 'Sources/AEConsole/*.swift'

s.swift_version = '5.0'
s.static_framework = true

s.ios.deployment_target = '10.0'

#NOTE: this should work when v0.6.0 becomes available for Swift 5
s.dependency 'AELog', '~> 0.6.0'

s.homepage = 'https://github.comtadija//AEConsole'
s.author = { 'tadija' => 'tadija@me.com' }
s.social_media_url = 'http://twitter.com/tadija'

end
