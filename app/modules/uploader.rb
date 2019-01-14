module Uploader
  ACCOUNTS_PATH_ROUTE = 'database/'.freeze
  ACCOUNTS_PATH_NAME = 'accounts'.freeze
  ACCOUNTS_PATH_FORMAT = '.yml'.freeze
  ACCOUNTS_PATH = ACCOUNTS_PATH_ROUTE + ACCOUNTS_PATH_NAME + ACCOUNTS_PATH_FORMAT

  def save_to_db(new_accounts)
    File.open(ACCOUNTS_PATH, 'w') { |f| f.write new_accounts.to_yaml }
  end

  def load_db
    File.exist?(ACCOUNTS_PATH) ? YAML.load_file(ACCOUNTS_PATH) : []
  end

  def update_db(account)
    loaded_db = load_db
    loaded_db << account
    save_to_db(loaded_db.reverse.uniq(&:login))
  end
end
