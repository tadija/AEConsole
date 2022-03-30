Pod::Spec.new do |s|

s.name = 'AEConsole'
s.version = '0.7.2'
s.license = { :type => 'MIT', :file => 'LICENSE' }
s.summary = 'Customizable Console UI overlay with debug log on top of your iOS App'

s.source = { :git => 'https://github.com/tadija/AEConsole.git', :tag => s.version }
s.source_files = 'Sources/AEConsole/*.swift'

s.swift_versions = ['4.2', '5.0', '5.1', '5.2', '5.3', '5.4', '5.5', '5.6']

s.ios.deployment_target = '12.0'

s.dependency 'AELog', '~> 0.6.3'

s.homepage = 'https://github.com/tadija/AEConsole'
s.author = { 'tadija' => 'tadija@me.com' }
s.social_media_url = 'http://twitter.com/tadija'

end
