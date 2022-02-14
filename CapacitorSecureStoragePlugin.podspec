Pod::Spec.new do |s|
  s.name = 'CapacitorSecureStoragePlugin'
  s.version = '0.6.2'
  s.summary = 'securely store secrets such as usernames, passwords, tokens, certificates or other sensitive information (strings) on iOS & Android'
  s.license = 'MIT'
  s.homepage = 'https://github.com/martinkasa/capacitor-secure-storage-plugin.git'
  s.author = 'martinkasa'
  s.source = { :git => 'https://github.com/martinkasa/capacitor-secure-storage-plugin.git', :tag => s.version.to_s }
  s.source_files = 'ios/Plugin/**/*.{swift,h,m,c,cc,mm,cpp}'
  s.ios.deployment_target  = '12.0'
  s.dependency 'Capacitor'
end 