class Richless < Formula
  include Language::Python::Virtualenv

  desc "LESSOPEN filter for Markdown rendering and syntax highlighting with less"
  homepage "https://github.com/DavidJBianco/richless"
  url "https://files.pythonhosted.org/packages/4d/dc/b089233193b2c7cedb3e566c84a46d28f2b6c077080a14303b67d64f8858/richless-0.3.0.tar.gz"
  sha256 "c044681f407c005bdb12b5ee19a77d476bafbb3d78e29ee1d20dbf534ab50298"
  license "MIT"
  head "https://github.com/DavidJBianco/richless.git", branch: "main"

  depends_on "python@3.13"

  resource "markdown-it-py" do
    url "https://files.pythonhosted.org/packages/5b/f5/4ec618ed16cc4f8fb3b701563655a69816155e79e24a17b651541804721d/markdown_it_py-4.0.0.tar.gz"
    sha256 "cb0a2b4aa34f932c007117b194e945bd74e0ec24133ceb5bac59009cda1cb9f3"
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
