module Uploader
  def accounts
    if File.exists?('database/accounts.yml')
      YAML.load_file('database/accounts.yml')
    else
      []
    end
  end
end
