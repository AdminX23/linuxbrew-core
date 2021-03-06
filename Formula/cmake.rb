class Cmake < Formula
  desc "Cross-platform make"
  homepage "https://www.cmake.org/"
  url "https://github.com/Kitware/CMake/releases/download/v3.14.2/cmake-3.14.2.tar.gz"
  sha256 "a3cbf562b99270c0ff192f692139e98c605f292bfdbc04d70da0309a5358e71e"
  head "https://cmake.org/cmake.git"

  bottle do
    root_url "https://linuxbrew.bintray.com/bottles"
    cellar :any_skip_relocation
    sha256 "b6a57cf1c85f9f4f554070801ea4498ff73f0447a1ec63e719295706c6dee6bc" => :mojave
    sha256 "3da842b2c1c3214bcd716e42a761442a7766d55681be2de48d0eb1e10670357d" => :high_sierra
    sha256 "30cf08a31a3dfc26c64d00ce177343427a56a78889f6c320e99df5764e413fb2" => :sierra
    sha256 "b1c0abf1b2c0983b4918579eb24054667c60dd29b2db7577f8f577a919e5a2da" => :x86_64_linux
  end

  depends_on "sphinx-doc" => :build
  unless OS.mac?
    depends_on "ncurses"
    depends_on "openssl"
  end

  # The completions were removed because of problems with system bash

  # The `with-qt` GUI option was removed due to circular dependencies if
  # CMake is built with Qt support and Qt is built with MySQL support as MySQL uses CMake.
  # For the GUI application please instead use `brew cask install cmake`.

  def install
    # Reduce memory usage below 4 GB for Circle CI.
    ENV.deparallelize if ENV["CIRCLECI"]

    ENV.cxx11 unless OS.mac?

    args = %W[
      --prefix=#{prefix}
      --no-system-libs
      --parallel=#{ENV.make_jobs}
      --datadir=/share/cmake
      --docdir=/share/doc/cmake
      --mandir=/share/man
      --sphinx-build=#{Formula["sphinx-doc"].opt_bin}/sphinx-build
      --sphinx-html
      --sphinx-man
      --system-zlib
      --system-bzip2
      --system-curl
    ]
    args -= ["--system-zlib", "--system-bzip2", "--system-curl"] unless OS.mac?

    # There is an existing issue around macOS & Python locale setting
    # See https://bugs.python.org/issue18378#msg215215 for explanation
    ENV["LC_ALL"] = "en_US.UTF-8"

    system "./bootstrap", *args, "--", "-DCMAKE_BUILD_TYPE=Release"
    system "make"
    system "make", "install"

    elisp.install "Auxiliary/cmake-mode.el"
  end

  test do
    (testpath/"CMakeLists.txt").write("find_package(Ruby)")
    system bin/"cmake", "."
  end
end
