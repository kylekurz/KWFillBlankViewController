Pod::Spec.new do |s|
  s.name             = "KWFillBlankViewController"
  s.version          = "2.0.0"
  s.summary          = "A view controller can fill blank in the text view written by Swift"
  s.description      = <<-DESC
                       It is a  view controller can fill blank in the text view ,written by Swift
                       DESC
  s.homepage         = "https://github.com/oooneFolder/KWFillBlankViewController"
  s.license          = 'MIT'
  s.author           = { "oneFolder" => "ooonefolder@gmail.com" }
  s.author           = { "Kyle Kurz" => "kyle@kylekurz.com" } 
  s.source           = { :git => "https://github.com/oooneFolder/KWFillBlankViewController.git", :tag => s.version.to_s }

  s.platform     = :ios, '10.0'
  s.requires_arc = true

  s.source_files = 'KWFillBlankViewController/*'
  s.frameworks = 'Foundation', 'UIKit'

end
