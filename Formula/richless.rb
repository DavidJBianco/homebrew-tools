class Richless < Formula
  include Language::Python::Virtualenv

  desc "LESSOPEN filter for Markdown rendering and syntax highlighting with less"
  homepage "https://github.com/DavidJBianco/richless"
  url "https://files.pythonhosted.org/packages/5f/06/b58d7da1c07f33f3fec1260ab7c00b88385c1358f8b32aa6e5c73f0b371d/richless-0.2.1.tar.gz"
  sha256 "d63161c6e2070fb9f072363393d9621eae737099436072926a6aa56a9203bc33"
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
    url "https://files.pythonhosted.org/packages/b0/77/a5b8c569bf593b0140bde72ea885a803b82086995367bf2037de0159d924/pygments-2.19.2.tar.gz"
    sha256 "636cb2477cec7f8952536970bc533bc43743542f70392ae026374600add5b887"
  end

  resource "rich" do
    url "https://files.pythonhosted.org/packages/b3/c6/f3b320c27991c46f43ee9d856302c70dc2d0fb2dba4842ff739d5f46b393/rich-14.3.3.tar.gz"
    sha256 "b8daa0b9e4eef54dd8cf7c86c03713f53241884e814f4e2f5fb342fe520f639b"
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
