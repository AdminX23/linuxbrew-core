class Awscli < Formula
  include Language::Python::Virtualenv

  desc "Official Amazon AWS command-line interface"
  homepage "https://aws.amazon.com/cli/"
  # awscli should only be updated every 10 releases on multiples of 10
  url "https://github.com/aws/aws-cli/archive/1.16.140.tar.gz"
  sha256 "1d18e3e89fd4363caec20853ecca7cd189d537ae07da6de037416c51b8357732"
  head "https://github.com/aws/aws-cli.git", :branch => "develop"

  bottle do
    root_url "https://linuxbrew.bintray.com/bottles"
    cellar :any_skip_relocation
    sha256 "19d8fcd0b354aa21192451ceb9dd120a9192cf69aed1685aa13eb3c2a9b65021" => :mojave
    sha256 "916e31bdbf8d7229dee2f0d7e7387e081952e8ec006c22817975833d8c98bd57" => :high_sierra
    sha256 "e6929aae730d4b658ce6ea9327cd6ee6c89fa952861360a5d44ffc87acb96cdf" => :sierra
    sha256 "f4872acd7247218d66673d349c7dd40937b5f059e25ae28898b34226030b0d55" => :x86_64_linux
  end

  # Some AWS APIs require TLS1.2, which system Python doesn't have before High
  # Sierra
  depends_on "python"

  depends_on "libyaml" unless OS.mac?

  def install
    venv = virtualenv_create(libexec, "python3")
    system libexec/"bin/pip", "install", "-v", "--no-binary", ":all:",
                              "--ignore-installed", buildpath
    system libexec/"bin/pip", "uninstall", "-y", "awscli"
    venv.pip_install_and_link buildpath
    pkgshare.install "awscli/examples"

    rm Dir["#{bin}/{aws.cmd,aws_bash_completer,aws_zsh_completer.sh}"]
    bash_completion.install "bin/aws_bash_completer"
    zsh_completion.install "bin/aws_zsh_completer.sh"
    (zsh_completion/"_aws").write <<~EOS
      #compdef aws
      _aws () {
        local e
        e=$(dirname ${funcsourcetrace[1]%:*})/aws_zsh_completer.sh
        if [[ -f $e ]]; then source $e; fi
      }
    EOS
  end

  def caveats; <<~EOS
    The "examples" directory has been installed to:
      #{HOMEBREW_PREFIX}/share/awscli/examples
  EOS
  end

  test do
    if OS.mac?
      assert_match "topics", shell_output("#{bin}/aws help")
    else
      # aws-cli needs groff as dependency, which we do not want to install
      # just to display the help.
      system "#{bin}/aws", "--version"
    end
  end
end
