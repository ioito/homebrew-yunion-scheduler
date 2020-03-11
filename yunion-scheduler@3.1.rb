class YunionSchedulerAT31 < Formula
  desc "Yunion Cloud Region Scheduler Service"
  homepage "https://github.com/yunionio/onecloud.git"
  url "https://github.com/yunionio/onecloud.git",
    :tag      => "release/3.1"
  version_scheme 1
  head "https://github.com/yunionio/onecloud.git"

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath

    (buildpath/"src/yunion.io/x/onecloud").install buildpath.children
    cd buildpath/"src/yunion.io/x/onecloud" do
      system "make", "cmd/scheduler"
      bin.install "_output/bin/scheduler"
      prefix.install_metafiles
    end
  end

  def post_install
    (var/"log/scheduler").mkpath
  end

  def caveats; <<~EOS
    brew services start yunion-scheduler
    source #{etc}/keystone/config/rc_admin
    climc service-create --enabled scheduler scheduler
    climc endpoint-create --enabled scheduler Yunion public http://127.0.0.1:8897
    climc endpoint-create --enabled scheduler Yunion internal http://127.0.0.1:8897
    climc endpoint-create --enabled scheduler Yunion admin http://127.0.0.1:8897
    brew services restart yunion-yunionapi
  EOS
  end


  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>KeepAlive</key>
      <true/>
      <key>RunAtLoad</key>
      <true/>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/scheduler</string>
        <string>--conf</string>
        <string>#{etc}/region.conf</string>
      </array>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>StandardErrorPath</key>
      <string>#{var}/log/scheduler/output.log</string>
      <key>StandardOutPath</key>
      <string>#{var}/log/scheduler/output.log</string>
    </dict>
    </plist>
  EOS
  end

  test do
    system "false"
  end
end
