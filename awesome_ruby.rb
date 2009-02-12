require 'fileutils'

rubydir = "/opt/ruby"
gitdir = "/opt/repos"

system "gem install rack --no-rdoc --no-ri"
system "gem install rspec --no-rdoc --no-ri"
system "gem install json --no-rdoc --no-ri"
system "gem install uuid --no-rdoc --no-ri"


Dir.chdir gitdir do
  # Clone patched ruby
  system "git clone git://github.com/tmm1/ruby187.git"

  # Other handy gems
  system "git clone git://github.com/eventmachine/eventmachine.git"
  system "git clone git://github.com/raggi/thin.git"
  system "git clone git://github.com/tmm1/amqp.git"

  #Dir.chdir "ruby187" do
  #  system "./configure --prefix=/opt/ruby"
  #  system "make -j2" 
  #  system "make install"
  #end
  #
  #Dir.chdir "/tmp" do
  #  system "wget http://rubyforge.org/frs/download.php/45905/rubygems-1.3.1.tgz"
  #  system "tar xvzf rubygems-1.3.1.tgz"
  #  Dir.chdir "rubygems-1.3.1" do
  #    system "/opt/ruby/bin/ruby setup.rb"
  #  end
  #end

  Dir.chdir "eventmachine" do
    system "gem build eventmachine.gemspec"
    system "gem install --no-rdoc --no-ri eventmachine-0.12.5.gem"
  end

  Dir.chdir "thin" do
    system "git checkout origin/async_for_rack"
    system "rake gem"
    system "gem install pkg/thin-1.0.1.gem --no-rdoc --no-ri"
  end
  
  Dir.chdir "amqp" do
    system "gem build amqp.gemspec"
    system "gem install --no-ri --no-rdoc amqp-0.6.0.gem"
  end
  

end

#FileUtils.mkdir_p(rubydir)
#Dir.chdir rubydir do
#end