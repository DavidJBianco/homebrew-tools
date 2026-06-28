class Richless < Formula
  include Language::Python::Virtualenv

  desc "LESSOPEN filter for Markdown rendering and syntax highlighting with less"
  homepage "https://github.com/DavidJBianco/richless"
  url "https://files.pythonhosted.org/packages/82/df/abbba537389de148df34134cbe2112fd9bdb0dcd3aac8e7f61ce944eab6e/richless-0.3.2.tar.gz"
  sha256 "76c23c41fbaaa2dd19d91ec56398dc4ecae920f0641914f65253fac8e09eb6de"
  license "MIT"
  head "https://github.com/DavidJBianco/richless.git", branch: "main"

  depends_on "python@3.13"

  resource "markdown-it-py" do
    url "https://files.pythonhosted.org/packages/06/ff/7841249c247aa650a76b9ee4bbaeae59370dc8bfd2f6c01f3630c35eb134/markdown_it_py-4.2.0.tar.gz"
    sha256 "04a21681d6fbb623de53f6f364d352309d4094dd4194040a10fd51833e418d49"
  end

  resource "mdurl" do
    url "https://files.pythonhosted.org/packages/d6/54/cfe61301667036ec958cb99bd3efefba235e65cdeb9c84d24a8293ba1d90/mdurl-0.1.2.tar.gz"
    sha256 "bb413d29f5eea38f31dd4754dd7377d4465116fb207585f97bf925588687c1ba"
  end

  resource "Pygments" do
    url "https://files.pythonhosted.org/packages/c3/b2/bc9c9196916376152d655522fdcebac55e66de6603a76a02bca1b6414f6c/pygments-2.20.0.tar.gz"
    sha256 "6757cd03768053ff99f3039c1a36d6c0aa0b263438fcab17520b30a303a82b5f"
  end

  resource "rich" do
    url "https://files.pythonhosted.org/packages/c0/8f/0722ca900cc807c13a6a0c696dacf35430f72e0ec571c4275d2371fca3e9/rich-15.0.0.tar.gz"
    sha256 "edd07a4824c6b40189fb7ac9bc4c52536e9780fbbfbddf6f1e2502c31b068c36"
  end

  def install
    virtualenv_install_with_resources

    # Install the shell integration script
    (share/"richless").install buildpath/"richless-init.sh"
  end

  def caveats
    <<~EOS
      To enable the shell integration (recommended), add this to your
      ~/.bashrc or ~/.zshrc:

        source #{share}/richless/richless-init.sh

      Or for basic LESSOPEN integration only:

        export LESSOPEN="|#{bin}/richless %s"
        export LESS="-R"
    EOS
  end

  test do
    (testpath/"test.md").write("# Hello\n\nThis is **bold** text.\n")
    output = shell_output("#{bin}/richless #{testpath}/test.md")
    assert_match "Hello", output

    (testpath/"test.py").write("print('hello')\n")
    output = shell_output("#{bin}/richless #{testpath}/test.py")
    assert_match "hello", output
  end
end
