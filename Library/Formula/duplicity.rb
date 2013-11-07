require 'formula'

class Duplicity < Formula
  homepage 'http://www.nongnu.org/duplicity/'
  url 'http://code.launchpad.net/duplicity/0.6-series/0.6.22/+download/duplicity-0.6.22.tar.gz'
  sha1 'afa144f444148b67d7649b32b80170d917743783'

  depends_on 'librsync'
  depends_on 'gnupg'

  option :universal

  # TODO: Move this into Library/Homebrew somewhere (see also mitmproxy.rb).

  def wrap bin_file, pythonpath
    puts bin_file
    bin_file = Pathname.new bin_file
    libexec_bin = Pathname.new libexec/'bin'
    libexec_bin.mkpath
    mv bin_file, libexec_bin
    puts libexec_bin
    bin_file.write <<-EOS.undent
      #!/bin/sh
      PYTHONPATH="#{pythonpath}:$PYTHONPATH" "#{libexec_bin}/#{bin_file.basename}" "$@"
    EOS
  end

  def pythonpath
    "#{lib}/python2.7/site-packages"
  end

  def install
    ENV.universal_binary if build.universal?

    system "python", "setup.py", "install", "--prefix=#{prefix}"

    Dir["#{bin}/*"].each do |bin_file|
      wrap bin_file, pythonpath
    end
  end
end
