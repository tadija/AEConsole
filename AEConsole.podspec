Pod::Spec.new do |s|
    s.name = 'AEConsole'
    s.version = '0.2.2'
    s.summary = 'Customizable Console UI overlay with debug log on top of your iOS App'

    s.homepage = 'https://github.com/tadija/AEConsole'
    s.license = { :type => 'MIT', :file => 'LICENSE' }
    s.author = { 'tadija' => 'tadija@me.com' }
    s.social_media_url = 'http://twitter.com/tadija'

    s.ios.deployment_target = '9.0'

    s.source = { :git => 'https://github.com/tadija/AEConsole.git', :tag => s.version }
    s.source_files = 'Sources/*.swift'

    s.dependency 'AELog', '~> 0.2'
end