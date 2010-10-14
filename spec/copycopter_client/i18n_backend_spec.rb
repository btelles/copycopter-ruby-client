require 'spec_helper'

describe CopycopterClient::I18nBackend do
  let(:sync) { {} }

  def build_backend(config = {})
    default_config = CopycopterClient::Configuration.new.to_hash
    CopycopterClient::I18nBackend.new(sync, default_config.update(config))
  end

  subject { build_backend }

  it "waits until the first download when reloaded" do
    sync.stubs(:wait_for_download)

    subject.reload!

    sync.should have_received(:wait_for_download)
  end

  it "includes the base i18n backend" do
    should be_kind_of(I18n::Backend::Base)
  end

  it "looks up a key in sync" do
    value = 'hello'
    sync['en.prefix.test.key'] = value

    backend = build_backend(:public => true)

    backend.translate('en', 'test.key', :scope => 'prefix').should == value
  end

  it "finds available locales" do
    sync['en.key'] = ''
    sync['fr.key'] = ''

    subject.available_locales.should =~ %w(en fr)
  end

  it "queues missing keys" do
    default = 'default value'

    subject.translate('en', 'test.key', :default => default).should == default

    sync['en.test.key'].should == default
  end

  it "adds edit links in development" do
    backend = build_backend(:public   => false,
                            :host     => 'example.com',
                            :protocol => 'https',
                            :port     => 443,
                            :api_key  => 'xyzabc')
    backend.translate('en', 'test.key', :default => 'default').
      should include(%{<a href="https://example.com/edit/xyzabc/en.test.key" target="_blank">Edit</a>})
  end

  it "doesn't add edit links in public" do
    backend = build_backend(:public   => true)
    backend.translate('en', 'test.key', :default => 'default').
      should_not include("<a href")
  end

  it "marks strings as html safe" do
    sync['en.test.key'] = FakeHtmlSafeString.new("Hello")
    backend = build_backend(:public => true)
    backend.translate('en', 'test.key').should be_html_safe
  end

  describe "with a fallback" do
    let(:fallback) { I18n::Backend::Simple.new }
    subject { build_backend(:fallback_backend => fallback) }

    it "uses the fallback as a default" do
      fallback.store_translations('en', 'test' => { 'key' => 'Expected' })
      subject.translate('en', 'test.key', :default => 'Unexpected').should == 'Expected'
    end

    it "uses the default if the fallback doesn't have the key" do
      subject.translate('en', 'test.key', :default => 'expected').should == 'expected'
    end

    it "uses the syncd key when present" do
      fallback.store_translations('en', 'test' => { 'key' => 'unxpected' })
      sync['en.test.key'] = 'expected'
      subject.translate('en', 'test.key', :default => 'default').should == 'expected'
    end
  end
end